import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

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

    // ✅ Dengarkan notifikasi ketika app dibuka (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🟢 [HomePenitip] Notif Masuk (foreground): ${message.notification?.title}');

      NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification?.title ?? 'Notifikasi',
        body: message.notification?.body ?? 'Ada pesan baru!',
      );
    });

    // Optional: Tambahkan ini jika ingin respon saat notifikasi di-tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 [HomePenitip] Notif ditekan: ${message.notification?.title}');
      // Bisa arahkan ke halaman tertentu
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
          content: Text(response.statusCode == 200
              ? '✅ Notifikasi berhasil dikirim!'
              : '❌ Gagal kirim notifikasi!'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda Penitip'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text('Halo Penitip, ini halaman Anda.'),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100.0, right: 16.0),
                child: FloatingActionButton.extended(
                  onPressed: () => kirimNotifikasiUji(context),
                  icon: Icon(Icons.notifications_active),
                  label: Text('Kirim Notifikasi Uji 🔔'),
                  backgroundColor: Colors.deepOrange,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0, right: 16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: Icon(Icons.person),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
