import 'package:flutter/material.dart';
import '../../models/merchandise_model.dart';
import '../../services/merchandise_service.dart';

class MerchPage extends StatefulWidget {
  const MerchPage({Key? key}) : super(key: key);

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
      for (var m in list) {
        print('📷 Foto merch: ${m.nama} => ${m.foto}');
      }
      setState(() {
        merchList = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal memuat data: $e')),
      );
    }
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

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    if (message.contains("berhasil")) {
      loadMerchandise(); // refresh stok
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Merchandise")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : merchList.isEmpty
              ? const Center(child: Text('Tidak ada merchandise tersedia.'))
              : Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: merchList.length,
                      itemBuilder: (context, index) {
                        final merch = merchList[index];

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: merch.foto != null
                                      ? Image.network(
                                          merch.foto!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            print('⚠️ Gagal load gambar: ${merch.foto}');
                                            return const Icon(Icons.broken_image, size: 40);
                                          },
                                        )
                                      : const Icon(Icons.image_not_supported),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(merch.nama,
                                          style: const TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('Poin: ${merch.hargaMerch} | Stok: ${merch.stok}'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: (merch.stok > 0 && !isSubmitting)
                                      ? () => klaimMerch(1, merch.merchandiseID, merch.nama)
                                      : null,
                                  icon: const Icon(Icons.card_giftcard, size: 18),
                                  label: const Text("Klaim"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    textStyle: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (isSubmitting)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.deepPurple),
                      ),
                  ],
                ),
    );
  }
}
