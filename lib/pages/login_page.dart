import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';

import '../services/notification_service.dart';
import '../pages/navigation/main_bottom_nav.dart';


final storage = FlutterSecureStorage();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> loginUser() async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/api/multi-login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': emailController.text,
      'password': passwordController.text,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    final token = data['access_token'];
    final role = data['role'];
    final user = data['user'];

    await storage.write(key: 'token', value: token);
    await storage.write(key: 'role', value: role);
    await storage.write(key: 'name', value: user['name'] ?? 'Tidak diketahui');
    await storage.write(key: 'email', value: user['email'] ?? 'Tidak diketahui');
    await storage.write(key: 'user_id', value: user['id'].toString());

    // 🔥 Ambil token FCM
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('📤 FCM Token: $fcmToken');

    // Kirim token FCM ke backend
    final tokenResponse = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/simpan-fcm-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'user_id': user['id'],
        'tipe': role,
        'token_dikirim': fcmToken,
      }),
    );

    if (tokenResponse.statusCode == 200) {
      print('✅ Token FCM berhasil dikirim.');
    } else {
      print('❌ Gagal kirim token FCM! Status: ${tokenResponse.statusCode}');
      print('👉 BODY: ${tokenResponse.body}');
    }

    // ✅ Navigasi ke halaman utama
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainBottomNav()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login gagal')),
    );
  }
}


  Future<void> testPushNotification() async {
  final token = await storage.read(key: 'token');
  print('🚀 Mulai kirim notifikasi uji...');

  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/kirim-notifikasi-uji'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📨 Status: ${response.statusCode}');
    print('🧾 Body: ${response.body}');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Notifikasi berhasil dikirim')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal kirim notifikasi!')),
      );
    }
  } catch (e) {
    print('❌ ERROR: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❗ Terjadi kesalahan: $e')),
    );
  }
}


  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((message) {
      print('📥 [Foreground] Notifikasi masuk!');
      NotificationService.showNotification(
        id: 0,
        title: message.notification?.title ?? 'No title',
        body: message.notification?.body ?? 'No body',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login & Notifikasi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
          TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: loginUser,
            child: Text('Login'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: testPushNotification,
            child: Text('Kirim Notifikasi Uji 🔔'),
          ),
        ]),
      ),
    );
  }
}
