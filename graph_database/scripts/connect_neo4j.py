import os
from neo4j import GraphDatabase

# Cấu hình thông tin kết nối Neo4j
# Nhớ cài đặt thư viện bằng lệnh: pip install neo4j
NEO4J_URI = os.getenv("NEO4J_URI", "bolt://localhost:7687")
NEO4J_USER = os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "password")

class Neo4jConnection:
    def __init__(self, uri, user, pwd):
        self.__driver = GraphDatabase.driver(uri, auth=(user, pwd))

    def close(self):
        self.__driver.close()

    def query(self, query, parameters=None):
        with self.__driver.session() as session:
            result = session.run(query, parameters)
            return [record.data() for record in result]

if __name__ == "__main__":
    print("Đang kết nối tới Neo4j tại:", NEO4J_URI)
    try:
        conn = Neo4jConnection(NEO4J_URI, NEO4J_USER, NEO4J_PASSWORD)
        
        # Truy vấn kiểm tra kết nối
        test_query = "MATCH (n) RETURN count(n) as node_count"
        res = conn.query(test_query)
        print("Kết nối thành công! Tổng số node hiện tại trong database:", res[0]['node_count'])
        
        conn.close()
    except Exception as e:
        print("Kết nối thất bại. Lỗi:", e)
        print("\nHãy chắc chắn rằng Neo4j Server đang chạy và bạn đã cấu hình đúng URI/Username/Password.")
