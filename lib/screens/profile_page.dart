import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/localization.dart';
import '../screens/login_screen.dart';

class ProfilePage extends StatelessWidget {
  final NgonNgu ngonNgu;
  final Function(NgonNgu) doiNgonNgu;
  const ProfilePage({
    super.key,
    required this.ngonNgu,
    required this.doiNgonNgu,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin cá nhân'), centerTitle: true),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final name = userData?['username'] ?? 'Người dùng';
          final email = userData?['email'] ?? 'Chưa cập nhật';
          final readingHistory = userData?['reading_history'] as List? ?? [];
          final searchHistory = userData?['search_history'] as List? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileHeader(name, email),
                const SizedBox(height: 20),

                _buildSectionHeader(Icons.history, 'Lịch sử đã đọc'),
                _buildHorizontalList(readingHistory, 'Chưa có lịch sử đọc'),

                const SizedBox(height: 20),

                _buildSectionHeader(Icons.search, 'Tìm kiếm gần đây'),
                _buildChipList(searchHistory),

                const SizedBox(height: 20),

                _buildSectionHeader(Icons.info_outline, 'Hệ thống'),
                _buildVersionCard(),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(
                              ngonNgu: ngonNgu,
                              doiNgonNgu: doiNgonNgu,
                            ),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'ĐĂNG XUẤT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7F5539),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7F5539),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFFEDE0D4),
            child: Icon(Icons.person, size: 40),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(email, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7F5539)),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List items, String emptyMsg) {
    if (items.isEmpty) return Text(emptyMsg);
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) => Card(
          child: SizedBox(width: 150, child: Center(child: Text(items[index]))),
        ),
      ),
    );
  }

  Widget _buildChipList(List items) {
    return Wrap(
      spacing: 8,
      children: items.map((s) => Chip(label: Text(s.toString()))).toList(),
    );
  }

  Widget _buildVersionCard() {
    return const Card(
      child: ListTile(
        title: Text('Phiên bản 1.2.0 (Build 2026)'),
        subtitle: Text('Cập nhật theme gỗ & Tính năng đọc Online'),
        trailing: Icon(Icons.verified, color: Colors.green),
      ),
    );
  }
}
