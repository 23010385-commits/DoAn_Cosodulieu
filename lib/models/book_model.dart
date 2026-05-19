import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String category;
  final String description;
  final String readUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.category,
    required this.readUrl,
    this.description = '',
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? 'Ẩn danh',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'Chung',
      readUrl: data['readUrl'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
