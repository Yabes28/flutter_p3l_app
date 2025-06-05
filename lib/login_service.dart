import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final storage = FlutterSecureStorage();

Future<Map<String, dynamic>> loginUser(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/multi-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final user = data['user'];
      final role = data['role'];
      final accessToken = data['access_token'];

      // Simpan ke secure storage
      await storage.write(key: 'token', value: accessToken);
      await storage.write(key: 'role', value: role);
      await storage.write(key: 'name', value: user['name'] ?? 'Tidak diketahui');
      await storage.write(key: 'email', value: user['email'] ?? 'Tidak diketahui');
      await storage.write(key: 'user_id', value: user['id'].toString());

      // Ambil token FCM
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('📤 FCM Token: $fcmToken');

      // Kirim ke backend
      final tokenResponse = await http.post(
  Uri.parse('http://10.0.2.2:8000/api/simpan-fcm-token'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  },
  body: jsonEncode({
    'user_id': user['id'],
    'tipe': role, // contoh: "App\\Models\\Penitip"
    'token_dikirim': fcmToken,
  }),
);


      if (tokenResponse.statusCode == 200) {
        print('✅ Token FCM berhasil dikirim.');
      } else {
        print('❌ Gagal kirim token FCM! Status: ${tokenResponse.statusCode}');
        print('👉 BODY: ${tokenResponse.body}');
      }

      return {'success': true, 'role': role, 'user': user};
    } else {
      return {'success': false, 'message': 'Email atau password salah'};
    }
  } catch (e) {
    print('❗ ERROR saat login: $e');
    return {'success': false, 'message': 'Terjadi kesalahan saat login'};
  }
}
