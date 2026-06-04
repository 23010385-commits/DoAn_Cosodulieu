// ============================================================================
// SCHEMA & CONSTRAINTS DEFINITION
// ============================================================================

// 1. Tạo các ràng buộc UNIQUE để đảm bảo dữ liệu không bị trùng lặp
CREATE CONSTRAINT unique_user_id IF NOT EXISTS
FOR (u:User) REQUIRE u.id IS UNIQUE;

CREATE CONSTRAINT unique_book_id IF NOT EXISTS
FOR (b:Book) REQUIRE b.id IS UNIQUE;

CREATE CONSTRAINT unique_author_id IF NOT EXISTS
FOR (a:Author) REQUIRE a.id IS UNIQUE;

CREATE CONSTRAINT unique_category_id IF NOT EXISTS
FOR (c:Category) REQUIRE c.id IS UNIQUE;

// ============================================================================
// HÌNH MẪU INSERT DỮ LIỆU ĐỂ TEST (SEED DATA)
// ============================================================================

// Tạo Thể loại (Category)
MERGE (c1:Category {id: "cat_it", name: "Công nghệ thông tin"});
MERGE (c2:Category {id: "cat_novel", name: "Tiểu thuyết"});

// Tạo Tác giả (Author)
MERGE (a1:Author {id: "auth_1", name: "Nguyễn Nhật Ánh"});
MERGE (a2:Author {id: "auth_2", name: "Martin Fowler"});

// Tạo Sách (Book)
MERGE (b1:Book {id: "book_1", title: "Mắt Biếc"});
MERGE (b2:Book {id: "book_2", title: "Refactoring"});

// Tạo mối quan hệ Sách - Thể loại & Tác giả
MERGE (b1)-[:BELONGS_TO]->(c2);
MERGE (b1)-[:WRITTEN_BY]->(a1);

MERGE (b2)-[:BELONGS_TO]->(c1);
MERGE (b2)-[:WRITTEN_BY]->(a2);

// Tạo Người dùng (User)
MERGE (u1:User {id: "user_test1", name: "Minh Đức"});
MERGE (u2:User {id: "user_test2", name: "Tấn Dũng"});

// Tạo hành động Đọc / Yêu thích
MERGE (u1)-[:READS {rating: 5, date: "2026-06-03"}]->(b1);
MERGE (u2)-[:READS {rating: 4, date: "2026-06-03"}]->(b2);
MERGE (u1)-[:LIKES]->(b2);
