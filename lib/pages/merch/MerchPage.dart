import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../models/merchandise_model.dart';
import '../../services/merchandise_service.dart';

class MerchPage extends StatefulWidget {
  const MerchPage({super.key});

  @override
  State<MerchPage> createState() => _MerchPageState();
}

class _MerchPageState extends State<MerchPage> {
  List<Merchandise> merchList = [];
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    loadMerchandise();
  }

  Future<void> loadMerchandise() async {
    try {
      final list = await MerchandiseService.fetchAllMerch();
      setState(() {
        merchList = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(
        msg: '❌ Gagal memuat data: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14,
      );
    }
  }

  String? getValidImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return path.startsWith('http') ? path : 'http://10.0.2.2:8000/storage/$path';
  }

  Future<void> klaimMerch(int pembeliID, int merchandiseID, String namaMerch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Klaim'),
        content: Text('Apakah Anda yakin ingin klaim "$namaMerch"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Klaim')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isSubmitting = true);
    final message = await MerchandiseService.klaimMerchandise(pembeliID, merchandiseID);
    setState(() => isSubmitting = false);

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: message.contains("berhasil") ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 14,
    );

    if (message.contains("berhasil")) {
      loadMerchandise(); // refresh stok
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text("🎁 Daftar Merchandise"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : merchList.isEmpty
              ? const Center(child: Text('Tidak ada merchandise tersedia.'))
              : Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: merchList.length,
                      itemBuilder: (context, index) {
                        final merch = merchList[index];
                        final imageUrl = getValidImageUrl(merch.foto);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const SizedBox(
                                              width: 70,
                                              height: 70,
                                              child: Center(
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image, size: 40),
                                        )
                                      : const Icon(Icons.image_not_supported, size: 40),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          merch.nama,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '🎯 Poin Dibutuhkan: ${merch.hargaMerch}',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          merch.stok > 0
                                              ? '✅ Stok tersedia: ${merch.stok}'
                                              : '❌ Stok habis',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: merch.stok > 0 ? Colors.green[700] : Colors.red[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: (merch.stok > 0 && !isSubmitting)
                                          ? () => klaimMerch(1, merch.merchandiseID, merch.nama)
                                          : null,
                                      icon: const Icon(Icons.card_giftcard, size: 18),
                                      label: const Text("Klaim"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: merch.stok > 0
                                            ? Colors.deepPurple
                                            : Colors.grey,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 10),
                                        textStyle: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (isSubmitting)
                      Container(
                        color: Colors.black.withOpacity(0.2),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.deepPurple),
                        ),
                      ),
                  ],
                ),
    );
  }
}
