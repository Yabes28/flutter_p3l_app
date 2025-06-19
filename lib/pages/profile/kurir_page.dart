import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../login_page.dart'; // Sesuaikan path import jika perlu

class CourierProfilePage extends StatefulWidget {
  const CourierProfilePage({super.key});

  @override
  State<CourierProfilePage> createState() => _CourierProfilePageState();
}

class _CourierProfilePageState extends State<CourierProfilePage> {
  final _storage = const FlutterSecureStorage();
  
  // State untuk loading dan data user
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Fungsi ini sama seperti sebelumnya, mengambil data dari server
    try {
      final token = await _storage.read(key: 'token');
      final tipeAkun = await _storage.read(key: 'role'); 
      final userIdFromStorage = await _storage.read(key: 'user_id'); 

      if (token == null || tipeAkun == null) {
        handleLogout();
        return;
      }

      final response = await http.get(
        // Gunakan 10.0.2.2 untuk emulator Android, atau alamat IP mesin Anda untuk perangkat fisik
        Uri.parse('http://10.0.2.2:8000/api/user'), 
        headers: {
          'Authorization': 'Bearer $token',
          'tipe-akun': tipeAkun,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _user = data['user'];
          _userId = userIdFromStorage;
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data pengguna');
      }
    } catch (e) {
      print('❌ Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void handleLogout() async {
    await _storage.deleteAll();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child: Text(
                    'Gagal memuat informasi kurir.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : buildProfileView(),
    );
  }

  // Widget untuk membangun tampilan profil utama
  Widget buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        children: [
          // Bagian Header Profil
          _buildProfileHeader(),
          const SizedBox(height: 24),

          // Kartu Informasi Personal
          _buildInfoCard(
            title: 'Informasi Personal',
            children: [
              _buildInfoRow(
                icon: Icons.badge_outlined,
                label: 'ID Kurir',
                // Pastikan backend mengirimkan 'courier_id' atau sejenisnya
                // value: _user?['user_id'] ?? 'Tidak ada ID',
                value: _userId ?? 'Tidak ada ID',
              ),
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: _user?['email'] ?? 'Tidak ada email',
              ),
              _buildInfoRow(
                icon: Icons.phone_outlined,
                label: 'Jabatan',
                value: _user?['jabatan'] ?? _user?['jabatan'] ?? 'Tidak ada jabatan',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Kartu Informasi Kendaraan & Kinerja
          // _buildInfoCard(
          //   title: 'Informasi Kerja',
          //   children: [
          //      _buildInfoRow(
          //       icon: Icons.delivery_dining_outlined,
          //       label: 'Kendaraan',
          //       // Contoh data, sesuaikan dengan data dari API Anda
          //       value: _user?['vehicle_info'] ?? 'Motor - B 1234 XYZ',
          //     ),
          //     _buildInfoRow(
          //       icon: Icons.star_border_outlined,
          //       label: 'Rating',
          //       value: _user?['rating']?.toString() ?? '4.8 / 5.0',
          //     ),
          //      _buildInfoRow(
          //       icon: Icons.task_alt_outlined,
          //       label: 'Paket Terkirim Hari Ini',
          //       value: _user?['deliveries_today']?.toString() ?? '15 Paket',
          //     ),
          //   ],
          // ),
          const SizedBox(height: 32),

          // Tombol Logout
          ElevatedButton.icon(
            onPressed: handleLogout,
            icon: const Icon(Icons.logout),
            label: const Text('LOGOUT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk membuat header profil
  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/courier_avatar.png'),
          backgroundColor: Colors.grey,
        ),
        const SizedBox(height: 12),
        Text(
          _user?['name'] ?? _user?['nama'] ?? 'Nama Kurir',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Chip(
          label: Text(
            _user?['status'] ?? 'Aktif',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ],
    );
  }

  // Helper widget untuk membuat kartu informasi
  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat baris informasi (Ikon - Label - Value)
  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green[700], size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}