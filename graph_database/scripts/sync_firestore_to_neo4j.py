import os
import sys
import json
import urllib.request
import ssl
from neo4j import GraphDatabase
from dotenv import load_dotenv

# Load env variables
load_dotenv()

# ============================================================================
# CẤU HÌNH KẾT NỐI
# ============================================================================
FIRESTORE_PROJECT_ID = "your-online-bookshelf-7adba"
BASE_REST_URL = f"https://firestore.googleapis.com/v1/projects/{FIRESTORE_PROJECT_ID}/databases/(default)/documents"

NEO4J_URI = os.getenv("NEO4J_URI", "bolt://localhost:7687")
NEO4J_USER = os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "password")

# ============================================================================
# HÀM BỔ TRỢ ĐỌC DỮ LIỆU QUA REST API
# ============================================================================
def parse_firestore_value(val):
    """Phan tich cac kieu du lieu cua Firestore REST API sang Python"""
    if not isinstance(val, dict):
        return val
    if "stringValue" in val:
        return val["stringValue"]
    elif "booleanValue" in val:
        return val["booleanValue"]
    elif "integerValue" in val:
        return int(val["integerValue"])
    elif "doubleValue" in val:
        return float(val["doubleValue"])
    elif "timestampValue" in val:
        return val["timestampValue"]
    elif "arrayValue" in val:
        values = val["arrayValue"].get("values", [])
        return [parse_firestore_value(v) for v in values]
    elif "mapValue" in val:
        fields = val["mapValue"].get("fields", {})
        return {k: parse_firestore_value(v) for k, v in fields.items()}
    return None

def parse_firestore_document(doc):
    """Chuyen doi mot Document Firestore REST API sang Dictionary phang"""
    doc_id = doc["name"].split("/")[-1]
    fields = doc.get("fields", {})
    parsed_fields = {k: parse_firestore_value(v) for k, v in fields.items()}
    parsed_fields["id"] = doc_id
    return parsed_fields

def fetch_collection(collection_name):
    """Tai va parse toan bo tai lieu tu mot collection trong Firestore"""
    url = f"{BASE_REST_URL}/{collection_name}"
    print(f"Dang tai du lieu tu Firestore REST API: {url} ...")
    try:
        req = urllib.request.Request(
            url, 
            headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        )
        # Tao SSL Context khong xac thuc de tranh loi SSL tren Windows
        context = ssl._create_unverified_context()
        with urllib.request.urlopen(req, context=context) as response:
            data = json.loads(response.read().decode('utf-8'))
            documents = data.get("documents", [])
            parsed_docs = [parse_firestore_document(doc) for doc in documents]
            return parsed_docs
    except Exception as e:
        print(f"[Warning] Khong the lay du lieu tu collection '{collection_name}': {e}")
        return []

# ============================================================================
# KHỞI TẠO NEO4J CONNECTION
# ============================================================================
def init_neo4j():
    try:
        driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))
        # Test ket noi
        with driver.session() as session:
            session.run("RETURN 1")
        return driver
    except Exception as e:
        print(f"\n[ERROR] Khong the ket noi toi Neo4j tai: {NEO4J_URI}")
        print("Chi tiet loi:", e)
        print("Hay chac chan rang Neo4j Server dang chay va mat khau dang nhap chinh xac.")
        sys.exit(1)

# ============================================================================
# TIẾN TRÌNH ĐỒNG BỘ CHÍNH
# ============================================================================
def sync_data(books, users, bookshelves, neo4j_driver):
    print("\n--- Bat dau dong bo du lieu vao Neo4j ---")
    
    with neo4j_driver.session() as session:
        # 1. Dong bo Sach
        print("\n1. Dang ghi Sach (Books) vao Neo4j...")
        for book in books:
            book_id = book.get("id")
            title = book.get("title", "Khong co tieu de")
            author = book.get("author", "An danh")
            category = book.get("category", "Chung")
            image_url = book.get("imageUrl", "")
            description = book.get("description", "")
            
            query = """
            MERGE (b:Book {id: $book_id})
            SET b.title = $title, b.imageUrl = $image_url, b.description = $description
            
            MERGE (a:Author {name: $author})
            MERGE (b)-[:WRITTEN_BY]->(a)
            
            MERGE (c:Category {name: $category})
            MERGE (b)-[:BELONGS_TO]->(c)
            """
            session.run(query, {
                'book_id': book_id,
                'title': title,
                'author': author,
                'category': category,
                'image_url': image_url,
                'description': description
            })
        print(f"-> Da ghi xong {len(books)} cuon sach.")

        # 2. Dong bo Nguoi dung
        print("\n2. Dang ghi Nguoi dung (Users) vao Neo4j...")
        history_rel_count = 0
        for user in users:
            user_id = user.get("id")
            name = user.get("username", "User_" + user_id[:5])
            reading_history = user.get("reading_history", [])
            
            user_query = """
            MERGE (u:User {id: $user_id})
            SET u.name = $name
            """
            session.run(user_query, {
                'user_id': user_id,
                'name': name
            })
            
            # Tao quan he cho lich su doc sach (khop theo Book Title)
            if reading_history:
                for book_title in reading_history:
                    if not book_title:  # Bo qua chuoi trong
                        continue
                    history_query = """
                    MATCH (u:User {id: $user_id})
                    MATCH (b:Book {title: $book_title})
                    MERGE (u)-[:READ]->(b)
                    """
                    session.run(history_query, {
                        'user_id': user_id,
                        'book_title': book_title
                    })
                    history_rel_count += 1
        print(f"-> Da ghi xong {len(users)} nguoi dung.")
        print(f"-> Da tao {history_rel_count} lien ket doc sach (:READ).")

        # 3. Dong bo Tu sach (Bookshelves)
        print("\n3. Dang ghi lien ket Tu sach (Bookshelves) vao Neo4j...")
        shelf_count = 0
        for item in bookshelves:
            user_id = item.get("userId")
            book_id = item.get("bookId")
            added_at = item.get("addedAt", "")
            
            if not user_id or not book_id:
                continue
                
            shelf_query = """
            MATCH (u:User {id: $user_id})
            MATCH (b:Book {id: $book_id})
            MERGE (u)-[r:ADDED_TO_SHELF]->(b)
            SET r.addedAt = $added_at
            """
            session.run(shelf_query, {
                'user_id': user_id,
                'book_id': book_id,
                'added_at': added_at
            })
            shelf_count += 1
        print(f"-> Da tao {shelf_count} lien ket tu sach (:ADDED_TO_SHELF).")
        
    print("\n=== DONG BO DU LIEU HOAN TAT THANH CONG! ===")

# ============================================================================
# MAIN RUNNER
# ============================================================================
if __name__ == "__main__":
    # 1. Tai du lieu tu Firestore qua REST API
    books_data = fetch_collection("books")
    users_data = fetch_collection("users")
    bookshelves_data = fetch_collection("bookshelves")
    
    if not books_data and not users_data:
        print("[Error] Khong tai duoc du lieu tu Firestore. Ket thuc chuong trinh.")
        sys.exit(1)
        
    # 2. Ket noi Neo4j
    neo4j_driver = init_neo4j()
    
    try:
        # 3. Chay dong bo vao Neo4j
        sync_data(books_data, users_data, bookshelves_data, neo4j_driver)
    finally:
        neo4j_driver.close()
