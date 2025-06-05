import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../login_page.dart'; // arahkan ke file login-mu yang benar

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = FlutterSecureStorage();
  String name = '';
  String email = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final storedName = await storage.read(key: 'name') ?? '-';
    final storedEmail = await storage.read(key: 'email') ?? '-';
    final storedRole = await storage.read(key: 'role') ?? '-';

    setState(() {
      name = storedName;
      email = storedEmail;
      role = storedRole.replaceAll('App\\Models\\', '').toUpperCase();
    });
  }

  Future<void> _logout() async {
    await storage.deleteAll(); // hapus semua data
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Profil Saya'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Konfirmasi Logout'),
                  content: Text('Apakah kamu yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      child: Text('Batal'),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    TextButton(
                      child: Text('Logout', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _logout();
                      },
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(email, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                SizedBox(height: 16),
                Chip(
                  label: Text('Role: $role'),
                  backgroundColor: Colors.deepPurple.shade100,
                  labelStyle: TextStyle(color: Colors.deepPurple[900]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
