import 'package:flutter/material.dart';
import '../../models/komisi_model.dart';

class HunterHistoryPage extends StatelessWidget {
  final List<Komisi> riwayatKomisi;

  const HunterHistoryPage({super.key, required this.riwayatKomisi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Komisi Hunter')),
      body: riwayatKomisi.isEmpty
          ? const Center(child: Text('Belum ada komisi.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: riwayatKomisi.length,
              itemBuilder: (context, index) {
                final komisi = riwayatKomisi[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
                );
              },
            ),
    );
  }
}
