// ============================================================================
// CYPHER QUERIES FOR RECOMMENDATION SYSTEM
// ============================================================================

// 1. Gợi ý sách theo thể loại của những sách người dùng đã đọc
// Tìm các sách cùng thể loại với các sách mà User "user_test1" đã đọc, nhưng loại trừ những sách chính user đó đã đọc.
MATCH (u:User {id: "user_test1"})-[:READS]->(b1:Book)-[:BELONGS_TO]->(c:Category)
MATCH (b2:Book)-[:BELONGS_TO]->(c)
WHERE NOT (u)-[:READS]->(b2)
RETURN b2.title AS RecommendedBook, c.name AS CategoryName, count(*) AS Strength
ORDER BY Strength DESC
LIMIT 5;

// 2. Gợi ý sách theo phương pháp lọc cộng tác (Collaborative Filtering)
// Gợi ý những cuốn sách được đọc bởi những người dùng khác có cùng sở thích đọc sách với "user_test1"
MATCH (u1:User {id: "user_test1"})-[:READS]->(b:Book)<-[:READS]-(u2:User)
MATCH (u2)-[:READS]->(recBook:Book)
WHERE NOT (u1)-[:READS]->(recBook)
RETURN recBook.title AS RecommendedBook, count(u2) AS RecommendationScore
ORDER BY RecommendationScore DESC
LIMIT 5;

// 3. Tìm các tác giả mà người dùng đọc nhiều nhất
MATCH (u:User {id: "user_test1"})-[:READS]->(b:Book)-[:WRITTEN_BY]->(a:Author)
RETURN a.name AS AuthorName, count(b) AS BooksRead
ORDER BY BooksRead DESC;
