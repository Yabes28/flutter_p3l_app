import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/merchandise_model.dart';

class MerchandiseService {
  static const String _baseUrl = 'http://10.0.2.2:8000';

  /// ✅ Fetch semua merchandise yang tersedia
  static Future<List<Merchandise>> fetchAllMerch() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/merchandise'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Merchandise.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat data merchandise. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat fetch merchandise: $e');
    }
  }

  /// ✅ Klaim merchandise
  static Future<String> klaimMerchandise(int pembeliID, int merchandiseID) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/klaim-merchandise'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pembeliID': pembeliID,
          'merchandiseID': merchandiseID,
        }),
      );

      final data = jsonDecode(response.body);
      return data['message'] ?? 'Tidak ada pesan';
    } catch (e) {
      return '❌ Gagal klaim: $e';
    }
  }
}
