import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/localization.dart';
import '../../models/book_model.dart';
import 'add_book_page.dart';

class ManageBookPage extends StatefulWidget {
  final NgonNgu ngonNgu;

  const ManageBookPage({super.key, required this.ngonNgu});

  @override
  State<ManageBookPage> createState() => _ManageBookPageState();
}

class _ManageBookPageState extends State<ManageBookPage> {
  Future<void> _openForm({Book? book}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddBookPage(initialData: book, ngonNgu: widget.ngonNgu),
      ),
    );
  }

  void _deleteBook(String bookId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa cuốn "$title" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('books')
                  .doc(bookId)
                  .delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa sách khỏi hệ thống')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Kho sách'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!.docs
              .map((doc) => Book.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Image.network(
                    book.imageUrl,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, e, s) => const Icon(Icons.book),
                  ),
                  title: Text(book.title),
                  subtitle: Text('Tác giả: ${book.author}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openForm(book: book),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBook(book.id, book.title),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: Colors.tealAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
