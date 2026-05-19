import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../screens/book_details_page.dart';
import '../utils/localization.dart';

class BookSearch extends SearchDelegate {
  final List<Book> allBooks;
  final NgonNgu ngonNgu;

  BookSearch({required this.allBooks, required this.ngonNgu});

  @override
  String get searchFieldLabel => 'Tìm tên sách...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResult();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResult();
  }

  Widget _buildSearchResult() {
    final results = allBooks
        .where((b) => b.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final book = results[index];
        return ListTile(
          leading: Image.network(book.imageUrl, width: 50, fit: BoxFit.cover),
          title: Text(book.title),
          subtitle: Text(book.author),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BookDetailsPage(bookId: book.id, ngonNgu: ngonNgu),
              ),
            );
          },
        );
      },
    );
  }
}
