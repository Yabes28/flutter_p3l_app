import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/pembeli_profile_model.dart';
import '../../models/pembeli_history_model.dart';
import '../../services/pembeli_service.dart';
import '../../services/transaksi_service.dart';
import '../login_page.dart';

class PembeliProfilePage extends StatefulWidget {
  const PembeliProfilePage({super.key});

  @override
  State<PembeliProfilePage> createState() => _PembeliProfilePageState();
}

class _PembeliProfilePageState extends State<PembeliProfilePage> {
  PembeliProfile? buyerProfile;
  List<Transaction> transactions = [];
  bool isLoading = true;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loadBuyerProfile();
    loadTransactionHistory();
  }

  Future<void> loadBuyerProfile() async {
    try {
      final data = await fetchBuyerProfile();
      setState(() {
        buyerProfile = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('❌ Error loading buyer profile: $e');
    }
  }

  Future<void> loadTransactionHistory() async {
    try {
      final data = await fetchTransactionHistory();
      setState(() {
        transactions = data;
      });
    } catch (e) {
      setState(() {
        transactions = [];
      });
      print('❌ Error loading transaction history: $e');
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
        title: const Text('My Profile'),
        backgroundColor: Color(0xFF6B48FF), // Warna ungu sesuai gambar
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
          : buyerProfile == null
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
                                  buyerProfile!.name.isNotEmpty
                                      ? buyerProfile!.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 32, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                buyerProfile!.name,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                buyerProfile!.email,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              Chip(
                                label: Text(
                                    'Role: ${buyerProfile!.role.toUpperCase()}'),
                                backgroundColor: Color(0xFFD1C4E9),
                                labelStyle:
                                    TextStyle(color: Color(0xFF6B48FF)),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.star, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Total Poin Loyalitas',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${buyerProfile!.rewardPoints.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 20, color: Color(0xFF6B48FF)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '📜 Riwayat Transaksi',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...transactions.map(
                        (trx) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long),
                            title: Text('Transaksi #${trx.transactionId}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Tanggal: ${DateTime.parse(trx.transactionDate).toLocal().toString().split(' ')[0]}'),
                                Text('Status: ${trx.status}'),
                                Text(
                                    'Total Harga: Rp ${trx.totalAmount.toStringAsFixed(2)}'),
                                Text('Poin Dapat: ${trx.pointsEarned}'),
                                ...trx.details.map((detail) => Padding(
                                      padding:
                                          const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        '- ${detail.productName} (x${detail.quantity}, Rp ${detail.subtotal.toStringAsFixed(2)})',
                                      ),
                                    )),
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