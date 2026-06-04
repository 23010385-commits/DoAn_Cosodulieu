import os
import sys
import pymysql
from neo4j import GraphDatabase
from dotenv import load_dotenv

# Load env variables tu graph_database/.env hoac root
load_dotenv()

# ============================================================================
# CẤU HÌNH KẾT NỐI
# ============================================================================
# Cấu hình MySQL (Mặc định local của Tấn Dũng)
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_NAME = os.getenv("DB_NAME", "book_management")

# Cấu hình Neo4j (Đọc từ file .env của bạn)
NEO4J_URI = os.getenv("NEO4J_URI", "bolt://localhost:7687")
NEO4J_USER = os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "123456a@")

# ============================================================================
# KẾT NỐI CƠ SỞ DỮ LIỆU
# ============================================================================
def init_mysql():
    try:
        conn = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
        return conn
    except Exception as e:
        print(f"[ERROR] Khong the ket noi den MySQL tai {DB_HOST}.")
        print("Chi tiet loi:", e)
        print("Vui long kiem tra XAMPP/MySQL da chay chua va thong tin user/password trong file .env.")
        sys.exit(1)

def init_neo4j():
    try:
        driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))
        with driver.session() as session:
            session.run("RETURN 1")
        return driver
    except Exception as e:
        print(f"[ERROR] Khong the ket noi toi Neo4j tai: {NEO4J_URI}")
        print("Chi tiet loi:", e)
        sys.exit(1)

# ============================================================================
# ĐỒNG BỘ DỮ LIỆU SANG NEO4J
# ============================================================================
def sync_data(mysql_conn, neo4j_driver):
    print("\n--- Bat dau dong bo du lieu tu MySQL sang Neo4j ---")
    
    # 1. Lay du lieu tu MySQL
    with mysql_conn.cursor() as cursor:
        # Lay danh sach sach va nha xuat ban
        cursor.execute("""
            SELECT b.book_id, b.title, b.published_year, p.name AS publisher_name 
            FROM books b 
            LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
        """)
        books = cursor.fetchall()
        
        # Lay danh sach tac gia cua tung cuon sach
        cursor.execute("""
            SELECT ba.book_id, ba.author_id, a.name AS author_name 
            FROM book_authors ba 
            JOIN authors a ON ba.author_id = a.author_id
        """)
        book_authors = cursor.fetchall()
        
        # Lay danh sach the loai cua tung cuon sach
        cursor.execute("""
            SELECT bc.book_id, bc.category_id, c.name AS category_name 
            FROM book_categories bc 
            JOIN categories c ON bc.category_id = c.category_id
        """)
        book_categories = cursor.fetchall()
        
        # Lay danh sach nguoi dung
        cursor.execute("SELECT user_id, username FROM users")
        users = cursor.fetchall()
        
        # Lay danh sach tuong tac nguoi dung - sach
        cursor.execute("SELECT user_id, book_id, status, rating, note, added_at FROM user_books")
        user_books = cursor.fetchall()

    # 2. Dua du lieu vao Neo4j
    with neo4j_driver.session() as session:
        # A. Đồng bộ sách và nhà xuất bản
        print("\n1. Dong bo Sach va Nha xuat ban...")
        for book in books:
            pub_query = ""
            params = {
                'book_id': book['book_id'],
                'title': book['title'],
                'year': book['published_year'] or 0,
                'pub_name': book['publisher_name'] or ""
            }
            
            # Ghi book vao Neo4j
            session.run("""
                MERGE (b:Book {id: $book_id})
                SET b.title = $title, b.year = $year
            """, params)
            
            # Neu co Nha xuat ban, tao lien ket
            if book['publisher_name']:
                session.run("""
                    MATCH (b:Book {id: $book_id})
                    MERGE (p:Publisher {name: $pub_name})
                    MERGE (b)-[:PUBLISHED_BY]->(p)
                """, params)
        print(f"-> Da dong bo {len(books)} cuon sach.")

        # B. Đồng bộ tác giả của sách
        print("\n2. Dong bo Tac gia va lien ket voi Sach...")
        for ba in book_authors:
            session.run("""
                MATCH (b:Book {id: $book_id})
                MERGE (a:Author {id: $author_id})
                SET a.name = $author_name
                MERGE (b)-[:WRITTEN_BY]->(a)
            """, {
                'book_id': ba['book_id'],
                'author_id': ba['author_id'],
                'author_name': ba['author_name']
            })
        print(f"-> Da tao {len(book_authors)} lien ket giua Tac gia va Sach (:WRITTEN_BY).")

        # C. Đồng bộ thể loại của sách
        print("\n3. Dong bo The loai va lien ket voi Sach...")
        for bc in book_categories:
            session.run("""
                MATCH (b:Book {id: $book_id})
                MERGE (c:Category {id: $category_id})
                SET c.name = $category_name
                MERGE (b)-[:BELONGS_TO]->(c)
            """, {
                'book_id': bc['book_id'],
                'category_id': bc['category_id'],
                'category_name': bc['category_name']
            })
        print(f"-> Da tao {len(book_categories)} lien ket giua The loai va Sach (:BELONGS_TO).")

        # D. Đồng bộ người dùng
        print("\n4. Dong bo Nguoi dung...")
        for user in users:
            session.run("""
                MERGE (u:User {id: $user_id})
                SET u.name = $username
            """, {
                'user_id': user['user_id'],
                'username': user['username']
            })
        print(f"-> Da dong bo {len(users)} nguoi dung.")

        # E. Đồng bộ tương tác giữa Người dùng và Sách
        print("\n5. Dong bo tuong tac Nguoi dung - Sach (user_books)...")
        for ub in user_books:
            added_at_str = str(ub['added_at']) if ub['added_at'] else ""
            session.run("""
                MATCH (u:User {id: $user_id})
                MATCH (b:Book {id: $book_id})
                MERGE (u)-[r:INTERACTED]->(b)
                SET r.status = $status, r.rating = $rating, r.note = $note, r.addedAt = $added_at
            """, {
                'user_id': ub['user_id'],
                'book_id': ub['book_id'],
                'status': ub['status'],
                'rating': ub['rating'] or 0,
                'note': ub['note'] or "",
                'added_at': added_at_str
            })
        print(f"-> Da tao {len(user_books)} lien ket tuong tac doc sach (:INTERACTED).")

    print("\n=== DONG BO TU MYSQL SANG NEO4J HOAN TAT! ===")

# ============================================================================
# MAIN
# ============================================================================
if __name__ == "__main__":
    # Kết nối MySQL
    mysql_conn = init_mysql()
    
    # Kết nối Neo4j
    neo4j_driver = init_neo4j()
    
    try:
        # Chạy đồng bộ
        sync_data(mysql_conn, neo4j_driver)
    finally:
        mysql_conn.close()
        neo4j_driver.close()
