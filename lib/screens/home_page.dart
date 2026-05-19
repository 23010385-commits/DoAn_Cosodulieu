import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../widgets/book_card.dart';
import '../utils/localization.dart';
import 'book_details_page.dart';
import '../widgets/book_search.dart';

class HomePage extends StatelessWidget {
  final NgonNgu ngonNgu;
  const HomePage({super.key, required this.ngonNgu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.get(StringsEnum.trangChu, ngonNgu)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final snapshot = await FirebaseFirestore.instance
                  .collection('books')
                  .get();
              final allBooks = snapshot.docs
                  .map((doc) => Book.fromFirestore(doc))
                  .toList();
              showSearch(
                context: context,
                delegate: BookSearch(allBooks: allBooks, ngonNgu: ngonNgu),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildBookList(
            context,
            'Sách phổ biến',
            FirebaseFirestore.instance
                .collection('books')
                .where('category', isEqualTo: 'Self-help')
                .limit(10),
          ),

          _buildBookList(
            context,
            'Sách mới nhất',
            FirebaseFirestore.instance
                .collection('books')
                .orderBy('title', descending: false)
                .limit(10),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(BuildContext context, String title, Query query) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 250,
          child: StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final books = snapshot.data!.docs
                  .map((doc) => Book.fromFirestore(doc))
                  .toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return BookCard(
                    title: books[index].title,
                    author: books[index].author, //
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
        ),
      ],
    );
  }
}
