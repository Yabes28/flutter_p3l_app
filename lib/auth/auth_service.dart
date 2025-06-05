import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';


final storage = FlutterSecureStorage();

Future<void> logoutUser() async {
  final token = await FirebaseMessaging.instance.getToken();

  // Hapus token di server Laravel
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/api/hapus-fcm-token'),
    headers: {
      'Authorization': 'Bearer ${await storage.read(key: 'token')}',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'fcm_token': token}),
  );

  print('🚪 Logout: Token FCM dihapus? ${response.statusCode}');

  // Hapus dari local
  await storage.deleteAll();
}