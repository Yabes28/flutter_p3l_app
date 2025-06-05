import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../auth/auth_service.dart';
import '../login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = FlutterSecureStorage();
  String name = '', email = '', role = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final name = await storage.read(key: 'name') ?? 'Tidak diketahui';
    final email = await storage.read(key: 'email') ?? 'Tidak diketahui';
    final role = await storage.read(key: 'role') ?? 'Tidak diketahui';

    setState(() {
      this.name = name;
      this.email = email;
      this.role = role;
    });
  }

  void handleLogout() async {
    try {
      await logoutUser(); // Kirim ke backend untuk hapus token FCM + revoke access token
    } catch (e) {
      print('❌ Error saat logout: $e');
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Saya'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: handleLogout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: $name', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Email: $email', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Role: $role', style: TextStyle(fontSize: 18)),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: handleLogout,
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}
