import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barang_model.dart';

class BarangService {
  static const String _baseUrl = 'http://10.0.2.2:8000';

  /// ✅ Fetch semua barang yang tersedia
  static Future<List<Barang>> fetchBarangAvailable() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/barang/available'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Barang.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat data. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat fetch data: $e');
    }
  }

  /// ✅ Fetch detail barang berdasarkan ID
  static Future<Barang?> fetchBarangById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/barang-mobile/$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Barang.fromJson(data);
      } else {
        print('❌ Gagal mengambil detail barang. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error saat mengambil detail barang: $e');
      return null;
    }
  }
}
