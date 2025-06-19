import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Class ini menangani semua komunikasi API yang berhubungan dengan Kurir.
class KurirService {
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = 'http://10.0.2.2:8000/api'; // Sesuaikan jika perlu

  /// Mengambil header otentikasi yang dibutuhkan untuk setiap request.
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Unauthenticated. Token tidak ditemukan.');
    }
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json', // Menambahkan Content-Type untuk konsistensi
    };
  }

  /// Mengambil daftar tugas pengiriman dari server untuk kurir yang login.
  ///
  /// Mengembalikan `List<Map<String, dynamic>>` jika berhasil.
  /// Melemparkan `Exception` jika terjadi kegagalan.
  Future<List<Map<String, dynamic>>> getTugas() async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/kurir/tugas'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      if (decodedData is List) {
        // Filter data untuk memastikan semua item adalah Map, menghindari error
        return List<Map<String, dynamic>>.from(
          decodedData.where((item) => item is Map<String, dynamic>)
        );
      } else {
        throw Exception('Format data dari server tidak terduga.');
      }
    } else {
      // Mengambil pesan error dari body respons jika tersedia
      final errorBody = json.decode(response.body);
      throw Exception('Gagal memuat tugas: ${errorBody['message'] ?? response.reasonPhrase}');
    }
  }

  /// Mengupdate status tugas menjadi 'berhasil dikirim'.
  ///
  /// Mengembalikan `true` jika berhasil.
  /// Melemparkan `Exception` jika terjadi kegagalan.
  Future<bool> updateStatusSelesai(int idTugas) async {
    final headers = await _getAuthHeaders();

    final response = await http.put(
      Uri.parse('$_baseUrl/penjadwalans/$idTugas/konfirmasi-diterima'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Gagal update status: ${errorBody['message'] ?? response.reasonPhrase}');
    }
  }
}
