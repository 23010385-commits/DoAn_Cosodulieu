# Graph Database Module

Thư mục này chứa toàn bộ thiết kế, kịch bản (scripts) và các câu lệnh truy vấn liên quan đến Cơ sở dữ liệu đồ thị (Graph Database) của đồ án.

## 📂 Cấu trúc thư mục đề xuất
- `/schema`: Chứa các định nghĩa về các nút (Nodes), mối quan hệ (Relationships) và các ràng buộc (Constraints).
- `/queries`: Chứa các câu lệnh truy vấn mẫu (Cypher queries), ví dụ: truy vấn gợi ý sách, thống kê tương tác, phân tích mạng lưới người dùng.
- `/scripts`: Các script Python, Node.js hoặc Cypher dùng để import dữ liệu từ Firebase hoặc file CSV vào Graph Database.
- `/docs`: Tài liệu hướng dẫn cài đặt và thiết lập cơ sở dữ liệu (ví dụ: Neo4j Desktop, Neo4j AuraDB).

---

## 🛠 Lựa chọn Công nghệ (Đề xuất: Neo4j)
Neo4j là cơ sở dữ liệu đồ thị phổ biến nhất hiện nay, rất phù hợp cho các bài toán:
- Hệ thống gợi ý sách (Recommendation System).
- Quản lý mối quan hệ giữa Người dùng - Sách - Thể loại - Tác giả.
- Phân tích hành vi đọc sách của người dùng.

### Các Node và Relationship dự kiến:
1. **Nodes (Thực thể):**
   - `User`: `{id, username, email, role}`
   - `Book`: `{id, title, author, category, publisher}`
   - `Author`: `{id, name}`
   - `Category`: `{id, name}`

2. **Relationships (Mối quan hệ):**
   - `(:User)-[:READS {rating, read_at}]->(:Book)`
   - `(:User)-[:LIKES]->(:Book)`
   - `(:Book)-[:BELONGS_TO]->(:Category)`
   - `(:Book)-[:WRITTEN_BY]->(:Author)`
   - `(:User)-[:FOLLOWS]->(:User)` (Nếu có tính năng mạng xã hội học tập)
