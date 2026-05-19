import 'package:flutter/material.dart';
import '../../utils/localization.dart';
import '../login_screen.dart';
import 'manage_book_page.dart';
import 'manage_users_page.dart';

class AdminDashboard extends StatelessWidget {
  final String role;
  final NgonNgu ngonNgu;
  final Function(NgonNgu) doiNgonNgu;
  const AdminDashboard({
    super.key,
    required this.role,
    required this.ngonNgu,
    required this.doiNgonNgu,
  });

  @override
  Widget build(BuildContext context) {
    bool isSuperAdmin = role == 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(isSuperAdmin ? 'Hệ thống quản trị' : 'Quản lý công vụ'),
        backgroundColor: isSuperAdmin ? Colors.redAccent : Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LoginScreen(ngonNgu: ngonNgu, doiNgonNgu: doiNgonNgu),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: <Widget>[
            _buildAdminCard(
              context,
              'Quản lý Sách',
              Icons.menu_book,
              Colors.orange,
              ManageBookPage(ngonNgu: ngonNgu),
            ),
            if (isSuperAdmin)
              _buildAdminCard(
                context,
                'Quản lý User',
                Icons.people,
                Colors.blue,
                ManageUsersPage(ngonNgu: ngonNgu),
              ),
            if (isSuperAdmin)
              _buildAdminCard(
                context,
                'Thống kê',
                Icons.analytics,
                Colors.green,
                null,
              ),
            _buildAdminCard(
              context,
              'Cài đặt hệ thống',
              Icons.settings,
              Colors.grey,
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget? destination,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          if (destination != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title đang được phát triển!')),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
