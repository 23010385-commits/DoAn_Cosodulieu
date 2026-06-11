import os
import sys
import json
import urllib.request
from flask import Flask, jsonify
from flask_cors import CORS
from neo4j import GraphDatabase
from dotenv import load_dotenv

# Load config tu file .env
load_dotenv()

# Doc bien moi truong
NEO4J_URI = os.getenv("NEO4J_URI", "bolt://127.0.0.1:7687")
NEO4J_USER = os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "123456a@")

app = Flask(__name__)
# Bat CORS de cho phep web portal truy cap
CORS(app, resources={r"/api/*": {"origins": "*"}})

# Khoi tao Neo4j Driver
try:
    neo4j_driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))
    # Test ket noi
    with neo4j_driver.session() as session:
        session.run("RETURN 1")
    print(f"[OK] Da ket noi thanh cong den Neo4j tai {NEO4J_URI}")
except Exception as e:
    print(f"[ERROR] Khong the ket noi toi Neo4j tai {NEO4J_URI}")
    print("Chi tiet loi:", e)
    sys.exit(1)

def get_mysql_book_titles():
    # Goi API cua Dung o cong 3000 de lay danh muc sach hop le
    urls = [
        "http://localhost:3000/api/books",
        "http://localhost:3000/books"
    ]
    for url in urls:
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req, timeout=2) as response:
                books = json.loads(response.read().decode('utf-8'))
                # Lay tieu de sach, strip va convert ve chu thuong
                return {b["title"].strip().lower() for b in books if "title" in b}
        except Exception as e:
            # Dung tieng Viet khong dau de tranh loi console Windows
            print(f"[Warning] Khong the lay danh sach sach tu {url}: {e}")
    return set()

# ============================================================================
# API ENDPOINT: LAY GOI Y SACH CHO USER
# ============================================================================
@app.route('/api/recommendations/<username>', methods=['GET'])
def get_recommendations(username):
    results = []
    history = []
    
    # 1. Lay danh sach sach hien co trong MySQL
    mysql_titles = get_mysql_book_titles()
    
    with neo4j_driver.session() as session:
        # Check xem user co ton tai trong database khong
        check_user = session.run("MATCH (u:User {name: $username}) RETURN count(u) AS count", {"username": username})
        user_exists = check_user.single()["count"] > 0
        
        if not user_exists:
            return jsonify({
                "username": username,
                "error": "User not found",
                "recommendations": [],
                "history": [],
                "count": 0
            }), 404
            
        # 2. Lay lich su tuong tac/doc sach cua user (Group các thể loại để tránh trùng lặp dòng)
        history_query = """
        MATCH (u:User {name: $username})-[r:INTERACTED]->(b:Book)
        OPTIONAL MATCH (b)-[:BELONGS_TO]->(c:Category)
        RETURN b.title AS title, collect(c.name) AS categories, r.status AS status, coalesce(r.rating, 0) AS rating
        """
        db_history = session.run(history_query, {"username": username})
        for record in db_history:
            categories = record["categories"]
            category_str = ", ".join(categories) if categories else "Chung"
            history.append({
                "title": record["title"],
                "category": category_str,
                "status": record["status"],
                "rating": record["rating"]
            })
            
        # 3. Chay truy van goi y theo loc cong tac (Collaborative Filtering)
        # Tim nhung nguoi doc co cung so thich voi user hien tai
        collaborative_query = """
        MATCH (u1:User {name: $username})-[r1:INTERACTED]->(b:Book)<-[r2:INTERACTED]-(u2:User)
        WHERE u1 <> u2 AND (r1.rating >= 3 OR r1.status = 'reading' OR r1.status = 'completed')
        MATCH (u2)-[r3:INTERACTED]->(b2:Book)
        WHERE NOT (u1)-[:INTERACTED]->(b2) AND (r3.rating >= 3 OR r3.status = 'reading' OR r3.status = 'completed')
        OPTIONAL MATCH (b2)-[:BELONGS_TO]->(c:Category)
        RETURN b2.title AS title, collect(c.name) AS categories, count(distinct u2) AS score
        ORDER BY score DESC
        LIMIT 30
        """
        db_collaborative = session.run(collaborative_query, {"username": username})
        for record in db_collaborative:
            categories = record["categories"]
            category_str = ", ".join(categories) if categories else "Chung"
            results.append({
                "title": record["title"],
                "category": category_str,
                "score": record["score"],
                "type": "Loc cong tac"
            })
            
        # 4. Neu so luong goi y < 5, bo sung them bang goi y theo sach lien quan (cung the loai, cung tac gia)
        if len(results) < 5:
            related_query = """
            MATCH (u:User {name: $username})-[r:INTERACTED]->(b1:Book)
            WHERE r.rating >= 3 OR r.status = 'reading' OR r.status = 'completed'
            MATCH (b1)-[:BELONGS_TO]->(c:Category)
            MATCH (b2:Book)-[:BELONGS_TO]->(c)
            WHERE NOT (u)-[:INTERACTED]->(b2)
            OPTIONAL MATCH (b1)-[:WRITTEN_BY]->(a:Author)
            OPTIONAL MATCH (b2)-[:WRITTEN_BY]->(a)
            WITH b2, count(distinct a) AS author_match
            OPTIONAL MATCH (b2)-[:BELONGS_TO]->(c2:Category)
            RETURN b2.title AS title, collect(c2.name) AS categories, (1 + author_match) AS score
            ORDER BY score DESC
            LIMIT 30
            """
            db_related = session.run(related_query, {"username": username})
            for record in db_related:
                if not any(r["title"].strip().lower() == record["title"].strip().lower() for r in results):
                    categories = record["categories"]
                    category_str = ", ".join(categories) if categories else "Chung"
                    results.append({
                        "title": record["title"],
                        "category": category_str,
                        "score": record["score"],
                        "type": "Sach lien quan"
                    })
                    
        # 5. Neu van chua du 5 goi y, bo sung sach pho bien nhat (Popular books fallback - Loai tru cac sach ma user da doc)
        if len(results) < 5:
            fallback_query = """
            MATCH (b:Book)
            WHERE NOT (:User {name: $username})-[:INTERACTED]->(b)
            OPTIONAL MATCH (b)<-[r:INTERACTED]-()
            WITH b, avg(r.rating) AS avg_rating, count(r) AS clicks
            OPTIONAL MATCH (b)-[:BELONGS_TO]->(c:Category)
            WITH b, avg_rating, clicks, collect(c.name) AS categories
            RETURN b.title AS title, categories, coalesce(avg_rating, 0.0) AS score, clicks
            ORDER BY clicks DESC, score DESC
            LIMIT 30
            """
            db_fallback = session.run(fallback_query, {"username": username})
            for record in db_fallback:
                if not any(r["title"].strip().lower() == record["title"].strip().lower() for r in results):
                    categories = record["categories"]
                    category_str = ", ".join(categories) if categories else "Chung"
                    results.append({
                        "title": record["title"],
                        "category": category_str,
                        "score": round(record["score"], 1),
                        "type": "Xem nhieu"
                    })
                    
    # 6. Loc ket qua de chi hien thi sach co trong database MySQL
    if mysql_titles:
        history = [h for h in history if h["title"].strip().lower() in mysql_titles]
        results = [r for r in results if r["title"].strip().lower() in mysql_titles]
        
    # Gioi han lai toi da 5 ket qua goi y sau khi loc
    results = results[:5]
                
    return jsonify({
        "username": username,
        "recommendations": results,
        "history": history,
        "count": len(results)
    })

# Run server o cong 5000
if __name__ == "__main__":
    print("Graph API server dang chay tai: http://localhost:5000")
    app.run(host="0.0.0.0", port=5000, debug=False)
