import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../utils/localization.dart';
import 'book_details_page.dart';

class LibraryPage extends StatelessWidget {
  final NgonNgu ngonNgu;

  const LibraryPage({super.key, required this.ngonNgu});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(Strings.get(StringsEnum.dangNhap, ngonNgu))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(Strings.get(StringsEnum.tuSach, ngonNgu))),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookshelves')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final savedDocs = snapshot.data!.docs;
          if (savedDocs.isEmpty) {
            return const Center(
              child: Text('Tủ sách đang trống. Hãy thêm vài cuốn nhé!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: savedDocs.length,
            itemBuilder: (context, index) {
              String bookId = savedDocs[index]['bookId'];
              String shelfDocId = savedDocs[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('books')
                    .doc(bookId)
                    .get(),
                builder: (context, bookSnapshot) {
                  if (!bookSnapshot.hasData) return const SizedBox();
                  final book = Book.fromFirestore(bookSnapshot.data!);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          book.imageUrl,
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        book.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(book.author),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_sweep,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _confirmDelete(context, shelfDocId),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailsPage(
                              bookId: book.id,
                              ngonNgu: ngonNgu,
                            ),
                          ),
                        );
                      },
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

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bỏ sách?'),
        content: const Text('Bạn muốn xóa cuốn sách này khỏi tủ cá nhân?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('bookshelves')
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
