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
        title: const Text('Keluar dari Akun'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              logout();
            },
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
              ? const Center(child: Text('❌ Gagal memuat profil.'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SafeArea(child: _buildHeader(context)),
                      const SizedBox(height: 20),
                      _buildKomisiBox(),
                      const SizedBox(height: 24),
                      _buildRiwayatKomisiList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 210,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: confirmLogout,
          ),
        ),
        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Text(
                  profile!.nama.isNotEmpty ? profile!.nama[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profile!.nama,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(profile!.email, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Chip(
                label: Text('Role: ${profile!.jabatan.toUpperCase()}'),
                backgroundColor: Colors.white,
                labelStyle: const TextStyle(color: Colors.deepPurple),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKomisiBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.attach_money, size: 28, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Total Komisi yang Diperoleh',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Rp ${profile!.totalKomisi}',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiwayatKomisiList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📄 Riwayat Komisi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (profile!.riwayatKomisi.isEmpty)
            const Text('Belum ada riwayat komisi.', style: TextStyle(color: Colors.grey))
          else
            ...profile!.riwayatKomisi.map(
              (komisi) => Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Text('Transaksi #${komisi.transaksiID}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.calendar_month, size: 16, color: Colors.red),
                        const SizedBox(width: 6),
                        Text('Tanggal: ${komisi.tanggalKomisi}'),
                      ]),
                      Row(children: [
                        const Icon(Icons.percent, size: 16, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text('Persentase: ${komisi.persentase}%'),
                      ]),
                      Row(children: [
                        const Icon(Icons.track_changes, size: 16, color: Colors.redAccent),
                        const SizedBox(width: 6),
                        Text('Komisi Hunter: Rp ${komisi.komisiHunter}'),
                      ]),
                      Row(children: [
                        const Icon(Icons.attach_money, size: 16, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text('Total Komisi: Rp ${komisi.jumlahKomisi}'),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
