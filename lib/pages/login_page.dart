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
  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() => isLoading = true);

    try {
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

        print('✅ Login sukses. Role: $role');

        // 🔥 Ambil token FCM
        final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
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

        // Delay kecil agar semua storage selesai
        await Future.delayed(const Duration(milliseconds: 300));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainBottomNav()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal. Periksa email dan password.')),
        );
      }
    } catch (e) {
      print('❗ ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => isLoading = false);
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
          const SnackBar(content: Text('✅ Notifikasi berhasil dikirim')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Gagal kirim notifikasi!')),
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
      appBar: AppBar(title: const Text('Login & Notifikasi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : loginUser,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Login'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : testPushNotification,
            child: const Text('Kirim Notifikasi Uji 🔔'),
          ),
        ]),
      ),
    );
  }
}
