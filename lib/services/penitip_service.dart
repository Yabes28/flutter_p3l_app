import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/penitip_profile_model.dart';
import '../models/penitip_history_model.dart';

class PenitipService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const storage = FlutterSecureStorage();

  static Future<PenitipProfile> fetchPenitipProfile() async {
    final token = await storage.read(key: 'token');
    print('Token: $token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$baseUrl/penitip/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Profile Response Status: ${response.statusCode}');
    print('Profile Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Parsed Profile Data: $data');
      return PenitipProfile.fromJson(data);
    } else {
      throw Exception('Gagal memuat profil penitip: ${response.body}');
    }
  }

  static Future<List<BarangDititipkan>> fetchBarangDititipkan() async {
    final token = await storage.read(key: 'token');
    final penitipID = await storage.read(key: 'penitipID');
    print('PenitipID: $penitipID');

    if (penitipID == null) {
      print('❌ penitipID tidak ditemukan, mencoba ambil dari profil');
      final profile = await fetchPenitipProfile();
      await storage.write(key: 'penitipID', value: profile.penitipID.toString());
      print('✅ Disimpan penitipID dari profil: ${profile.penitipID}');
    }

    final effectivePenitipID = await storage.read(key: 'penitipID');
    if (effectivePenitipID == null || token == null) {
      throw Exception('Token atau penitipID tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/barang-penitip/$effectivePenitipID'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Barang Response Status: ${response.statusCode}');
    print('Barang Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) {
        print('⚠ Tidak ada data riwayat barang.');
      }
      return data.map((json) => BarangDititipkan.fromJson(json)).toList();
    } else {
      print('❌ Gagal memuat riwayat barang: ${response.body}');
      throw Exception('Gagal memuat riwayat barang: ${response.body}');
    }
  }
}