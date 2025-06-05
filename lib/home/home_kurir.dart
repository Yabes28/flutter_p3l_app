import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/notification_service.dart';

class HomeKurir extends StatefulWidget {
  const HomeKurir({super.key});

  @override
  _HomeKurirState createState() => _HomeKurirState();
}

class _HomeKurirState extends State<HomeKurir> {
  @override
  void initState() {
    super.initState();

    // ✅ Minta izin notifikasi (Android 13+)
    FirebaseMessaging.instance.requestPermission();

    // ✅ Tampilkan token jika perlu
    FirebaseMessaging.instance.getToken().then((token) {
      print('📱 [Kurir] Token FCM: $token');
    });

    // ✅ Notifikasi saat app aktif (popup)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📦 [Kurir] Pesan masuk: ${message.notification?.title}');
      NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification?.title ?? 'Notifikasi',
        body: message.notification?.body ?? 'Ada tugas pengiriman untukmu',
      );
    });

    // ✅ Saat notifikasi dibuka dari background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Dibuka dari notifikasi: ${message.notification?.title}');
      // Tambah navigasi jika perlu
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda Kurir'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Text(
          'Tugas pengiriman menanti, Kurir!',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/profile');
        },
        backgroundColor: Colors.orange,
        tooltip: 'Profil Saya',
        child: Icon(Icons.person),
      ),
    );
  }
}
