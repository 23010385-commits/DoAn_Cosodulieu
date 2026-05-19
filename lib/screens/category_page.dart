import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'category_books_page.dart';

class CategoryPage extends StatelessWidget {
  final NgonNgu ngonNgu;

  const CategoryPage({super.key, required this.ngonNgu});

  final List<String> categories = const [
    'Văn học',
    'Kinh tế',
    'Self-help',
    'Lịch sử',
    'Khoa học',
    'Thiếu nhi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.get(StringsEnum.chuDe, ngonNgu))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.5,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryBooksPage(
                      categoryName: categories[index],
                      ngonNgu: ngonNgu,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  categories[index],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
