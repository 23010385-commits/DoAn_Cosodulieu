import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../widgets/book_card.dart';
import '../utils/localization.dart';
import 'book_details_page.dart';

class CategoryBooksPage extends StatelessWidget {
  final String categoryName;
  final NgonNgu ngonNgu;

  const CategoryBooksPage({
    super.key,
    required this.categoryName,
    required this.ngonNgu,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .where('category', isEqualTo: categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Đã có lỗi xảy ra'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!.docs
              .map((doc) => Book.fromFirestore(doc))
              .toList();

          if (books.isEmpty) {
            return const Center(child: Text('Chưa có sách nào trong mục này'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return BookCard(
                title: books[index].title,
                author: books[index].author,
                imageUrl: books[index].imageUrl,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailsPage(
                        bookId: books[index].id,
                        ngonNgu: ngonNgu,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
