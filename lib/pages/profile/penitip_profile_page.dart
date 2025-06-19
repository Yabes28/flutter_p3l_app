import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/penitip_profile_model.dart';
import '../../models/penitip_history_model.dart';
import '../../services/penitip_service.dart';
import '../login_page.dart';

class PenitipProfilePage extends StatefulWidget {
  const PenitipProfilePage({super.key});

  @override
  State<PenitipProfilePage> createState() => _PenitipProfilePageState();
}

class _PenitipProfilePageState extends State<PenitipProfilePage> {
  PenitipProfile? penitipProfile;
  List<BarangDititipkan> barangDititipkan = [];
  bool isLoading = true;
  bool isHistoryVisible = false; // Untuk mengontrol visibilitas riwayat
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loadPenitipProfile();
  }

  Future<void> loadPenitipProfile() async {
    try {
      final data = await PenitipService.fetchPenitipProfile();
      setState(() {
        penitipProfile = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('❌ Error loading penitip profile: $e');
    }
  }

  Future<void> loadBarangDititipkan() async {
    try {
      final data = await PenitipService.fetchBarangDititipkan();
      setState(() {
        barangDititipkan = data;
        isHistoryVisible = true; // Tampilkan riwayat setelah data dimuat
        print('Loaded ${data.length} barang dititipkan');
      });
    } catch (e) {
      setState(() {
        barangDititipkan = [];
        isHistoryVisible = false;
      });
      print('❌ Error loading barang dititipkan: $e');
    }
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
        title: const Text('Profil Saya'),
        backgroundColor: Color(0xFF6B48FF),
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
          : penitipProfile == null
              ? const Center(child: Text('❌ Gagal memuat profil.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Color(0xFF6B48FF),
                                child: Text(
                                  penitipProfile!.nama.isNotEmpty
                                      ? penitipProfile!.nama[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 32, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    penitipProfile!.nama,
                                    style: const TextStyle(
                                        fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  if (penitipProfile!.isTopSeller)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Text(
                                        '⭐ Top Seller',
                                        style: TextStyle(
                                            color: Colors.yellow,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                penitipProfile!.email,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              Chip(
                                label: Text(
                                    'Role: ${penitipProfile!.role.toUpperCase()}'),
                                backgroundColor: Color(0xFFD1C4E9),
                                labelStyle: TextStyle(color: Color(0xFF6B48FF)),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.account_balance_wallet,
                                      color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Saldo',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rp ${penitipProfile!.saldo.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.green),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.star, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Poin Reward',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${penitipProfile!.poinLoyalitas}',
                                style: const TextStyle(
                                    fontSize: 20, color: Color(0xFF6B48FF)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: loadBarangDititipkan,
                        child: const Text('Lihat Riwayat Transaksi'),
                      ),
                      if (isHistoryVisible && barangDititipkan.isNotEmpty)
                        const SizedBox(height: 16),
                      if (isHistoryVisible && barangDititipkan.isNotEmpty)
                        const Text(
                          '📦 Riwayat Barang Titipan',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      if (isHistoryVisible && barangDititipkan.isNotEmpty)
                        const SizedBox(height: 8),
                      if (isHistoryVisible)
                        ...barangDititipkan.map(
                          (barang) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.inventory),
                              title: Text('Barang #${barang.idProduk}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nama: ${barang.namaProduk}'),
                                  Text('Status: ${barang.status}'),
                                  Text(
                                      'Tanggal Mulai: ${DateTime.parse(barang.tglMulai).toLocal().toString().split(' ')[0]}'),
                                  Text(
                                      'Tanggal Selesai: ${DateTime.parse(barang.tglSelesai).toLocal().toString().split(' ')[0]}'),
                                  Text('Harga: Rp ${barang.harga.toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (isHistoryVisible && barangDititipkan.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Tidak ada riwayat transaksi.'),
                        ),
                    ],
                  ),
                ),
    );
  }
}