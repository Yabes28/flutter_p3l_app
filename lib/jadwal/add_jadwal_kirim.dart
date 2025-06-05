import 'package:flutter_p3l_app/services/notification_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


Future<void> submitPenjadwalan({
  required int transaksiID,
  required int pegawaiID,
  required String tanggal,
  required String waktu,
}) async {
  final response = await http.post(
    Uri.parse('http://10.5.50.11:8000/api/penjadwalans'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'transaksiID': transaksiID,
      'pegawaiID': pegawaiID,
      'tipe': 'pengiriman',
      'tanggal': tanggal,
      'waktu': waktu,
    }),
  );

  if (response.statusCode == 200) {
    // ✅ Tampilkan notifikasi lokal
    await NotificationService.showNotification(
      id: 1,
      title: 'Pengiriman Dijadwalkan',
      body: 'Barang akan dikirim oleh kurir sesuai jadwal.',
    );
  } else {
    print('Gagal menjadwalkan pengiriman');
  }
}
