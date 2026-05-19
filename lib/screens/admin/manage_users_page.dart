import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/localization.dart';

class ManageUsersPage extends StatefulWidget {
  final NgonNgu ngonNgu;

  const ManageUsersPage({super.key, required this.ngonNgu});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  Future<void> _toggleRole(
    String userId,
    String currentRole,
    String userName,
  ) async {
    String newRole = (currentRole == 'Admin') ? 'User' : 'Admin';

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'role': newRole,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã đổi quyền của $userName thành $newRole')),
      );
    }
  }

  Future<void> _toggleUserStatus(
    String userId,
    bool currentStatus,
    String userName,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'is_disabled': !currentStatus,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !currentStatus
                ? 'Đã khóa tài khoản $userName'
                : 'Đã mở khóa tài khoản $userName',
          ),
          backgroundColor: !currentStatus ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  void _deleteUser(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa tài khoản $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFakeEmailDialog(String name, String email) {
    print('-----------------------------------------');
    print('SENDING EMAIL TO: $email');
    print('SUBJECT: [Thư viện Online] Thông báo quan trọng');
    print(
      'CONTENT: Chào $name, tài khoản của bạn đã được cập nhật trạng thái.',
    );
    print('-----------------------------------------');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mark_email_read, color: Colors.blue),
            SizedBox(width: 10),
            Text('Thông báo hệ thống'),
          ],
        ),
        content: Text(
          'Hệ thống đang gửi email thông báo tới địa chỉ:\n\n$email',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐÓNG'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Người dùng'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final String userId = users[index].id;
              final String role = userData['role'] ?? 'User';
              final String name = userData['name'] ?? 'No Name';
              bool isAdmin = role == 'Admin';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAdmin
                        ? Colors.red.shade100
                        : Colors.blue.shade100,
                    child: Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: isAdmin ? Colors.red : Colors.blue,
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${userData['email']}\nQuyền: $role'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.email_outlined,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () => _showFakeEmailDialog(
                          name,
                          userData['email'] ?? 'No Email',
                        ),
                        tooltip: 'Gửi thông báo Email',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.published_with_changes,
                          color: Colors.green,
                        ),
                        onPressed: () => _toggleRole(userId, role, name),
                        tooltip: 'Đổi quyền Admin/User',
                      ),
                      IconButton(
                        icon: Icon(
                          userData['is_disabled'] == true
                              ? Icons.lock
                              : Icons.lock_open,
                          color: userData['is_disabled'] == true
                              ? Colors.red
                              : Colors.green,
                        ),
                        onPressed: () => _toggleUserStatus(
                          userId,
                          userData['is_disabled'] == true,
                          name,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteUser(userId, name),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
