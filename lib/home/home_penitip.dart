import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../services/notification_service.dart';

class HomePenitip extends StatefulWidget {
  const HomePenitip({super.key});

  @override
  State<HomePenitip> createState() => _HomePenitipState();
}

class _HomePenitipState extends State<HomePenitip> {
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    // ✅ Listener saat notifikasi masuk (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🟢 [HomePenitip] Notif Masuk: ${message.notification?.title}');
      NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification?.title ?? 'Notifikasi',
        body: message.notification?.body ?? 'Ada pesan baru!',
      );
    });

    // ✅ Listener saat notifikasi dibuka
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 [HomePenitip] Dibuka dari notif: ${message.notification?.title}');
      // Tambahkan navigasi jika diperlukan
    });
  }

  Future<void> kirimNotifikasiUji(BuildContext context) async {
    final token = await storage.read(key: 'token');
    print('🚀 Kirim Notifikasi Uji dari Penitip');

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 200
                ? '✅ Notifikasi berhasil dikirim!'
                : '❌ Gagal kirim notifikasi!',
          ),
        ),
      );
    } catch (e) {
      print('❌ ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❗ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Center(
          child: Text(
            'Halo Penitip, ini halaman Anda.',
            style: TextStyle(fontSize: 18),
          ),
        ),
        Positioned(
          bottom: 86,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => kirimNotifikasiUji(context),
            icon: const Icon(Icons.notifications_active),
            label: const Text('Notifikasi Uji 🔔'),
            backgroundColor: Colors.deepOrange,
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: const Icon(Icons.person),
          ),
        ),
      ],
    );
  }
}
