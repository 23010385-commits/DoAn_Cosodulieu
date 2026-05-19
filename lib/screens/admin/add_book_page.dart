import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/book_model.dart';
import '../../utils/localization.dart';

class AddBookPage extends StatefulWidget {
  final Book? initialData;
  final NgonNgu ngonNgu;

  const AddBookPage({super.key, this.initialData, required this.ngonNgu});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _imageController;
  late TextEditingController _categoryController;
  late TextEditingController _readUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialData?.title ?? '',
    );
    _authorController = TextEditingController(
      text: widget.initialData?.author ?? '',
    );
    _imageController = TextEditingController(
      text: widget.initialData?.imageUrl ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.initialData?.category ?? 'Self-help',
    );
    _readUrlController = TextEditingController(
      text: widget.initialData?.readUrl ?? '',
    );
  }

  // Giải phóng bộ nhớ
  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _imageController.dispose();
    _categoryController.dispose();
    _readUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final bookData = {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'imageUrl': _imageController.text.trim(),
        'category': _categoryController.text.trim(),
        'readUrl': _readUrlController.text.trim(),
        'description': 'Đây là mô tả mặc định cho sách mới...',
      };

      try {
        if (widget.initialData == null) {
          await FirebaseFirestore.instance.collection('books').add(bookData);
        } else {
          await FirebaseFirestore.instance
              .collection('books')
              .doc(widget.initialData!.id)
              .update(bookData);
        }
        if (mounted) Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu dữ liệu thành công!')),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialData == null ? 'Thêm sách mới' : 'Sửa thông tin',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                _titleController,
                'Tên sách',
                'Vui lòng nhập tên sách',
              ),
              const SizedBox(height: 15),
              _buildTextField(
                _authorController,
                'Tác giả',
                'Vui lòng nhập tên tác giả',
              ),
              const SizedBox(height: 15),
              _buildTextField(
                _categoryController,
                'Thể loại',
                'Vui lòng nhập thể loại',
              ),
              const SizedBox(height: 15),
              _buildTextField(
                _imageController,
                'URL Ảnh bìa',
                'Vui lòng nhập link ảnh',
              ),
              const SizedBox(height: 15),
              _buildTextField(
                _readUrlController,
                'Link đọc Online (PDF/Web)',
                'Vui lòng nhập link đọc',
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('LƯU LÊN HỆ THỐNG'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String errorMsg,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? errorMsg : null,
    );
  }
}
