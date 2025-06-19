import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

        final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
        await http.post(
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

        // ✅ Tampilkan toast dengan animasi slide
        Fluttertoast.showToast(
          msg: "✅ Login berhasil. Selamat datang!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
          timeInSecForIosWeb: 1,
        );

        // Delay agar toast terlihat
        await Future.delayed(const Duration(seconds: 1));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainBottomNav()),
          (route) => false,
        );
      } else {
        Fluttertoast.showToast(
          msg: "❌ Login gagal. Periksa email dan password.",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "❗ Terjadi kesalahan: $e",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((message) {
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
      backgroundColor: const Color(0xFFEFFFEF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.jpg', height: 100),
              const SizedBox(height: 16),
              const Text(
                'Selamat Datang di ReuseMart',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : loginUser,
                          icon: const Icon(Icons.login),
                          label: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Login'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
