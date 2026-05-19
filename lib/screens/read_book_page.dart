import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReadBookPage extends StatefulWidget {
  final String bookTitle;
  final String readUrl;

  const ReadBookPage({
    super.key,
    required this.bookTitle,
    required this.readUrl,
  });

  @override
  State<ReadBookPage> createState() => _ReadBookPageState();
}

class _ReadBookPageState extends State<ReadBookPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.readUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đang đọc: ${widget.bookTitle}')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
