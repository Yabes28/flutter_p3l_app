import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/hunter_profile_model.dart';
import '../../services/hunter_service.dart';
import '../login_page.dart';

class HunterProfilePage extends StatefulWidget {
  const HunterProfilePage({super.key});

  @override
  State<HunterProfilePage> createState() => _HunterProfilePageState();
}

class _HunterProfilePageState extends State<HunterProfilePage> {
  HunterProfile? profile;
  bool isLoading = true;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await fetchHunterProfile();
    setState(() {
      profile = data;
      isLoading = false;
    });
  }

  Future<void> logout() async {
    await storage.deleteAll();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(ctx);
              logout();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Hunter'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: confirmLogout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
              ? const Center(child: Text('❌ Gagal memuat profil.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.deepPurple,
                                child: Text(
                                  profile!.nama.isNotEmpty ? profile!.nama[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 32, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                profile!.nama,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(profile!.email, style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 12),
                              Chip(
                                label: Text('Role: ${profile!.jabatan.toUpperCase()}'),
                                backgroundColor: Colors.deepPurple.shade100,
                                labelStyle: TextStyle(color: Colors.deepPurple.shade800),
                              ),
                              const Divider(height: 32),
                              const Text(
                                '💰 Total Komisi yang Diperoleh',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rp ${profile!.totalKomisi}',
                                style: const TextStyle(fontSize: 20, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '📄 Riwayat Komisi',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...profile!.riwayatKomisi.map(
                        (komisi) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long),
                            title: Text('Transaksi #${komisi.transaksiID}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tanggal: ${komisi.tanggalKomisi}'),
                                Text('Persentase: ${komisi.persentase}%'),
                                Text('Komisi Hunter: Rp ${komisi.komisiHunter}'),
                                Text('Total Komisi: Rp ${komisi.jumlahKomisi}'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
