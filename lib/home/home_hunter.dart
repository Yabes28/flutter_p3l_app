import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/notification_service.dart';

class HomeHunter extends StatefulWidget {
  const HomeHunter({super.key});

  @override
  _HomeHunterState createState() => _HomeHunterState();
}

class _HomeHunterState extends State<HomeHunter> {
  @override
  void initState() {
    super.initState();

    // ✅ Minta izin notifikasi (Android 13+)
    FirebaseMessaging.instance.requestPermission();

    // ✅ Cetak token FCM
    FirebaseMessaging.instance.getToken().then((token) {
      print('📱 [Hunter] Token FCM: $token');
    });

    // ✅ Tangani notifikasi saat aplikasi aktif (popup)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🎯 [Hunter] Pesan Masuk: ${message.notification?.title}');
      NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification?.title ?? 'Notifikasi',
        body: message.notification?.body ?? 'Ada info baru untukmu, Hunter!',
      );
    });

    // ✅ Tangani jika notifikasi dibuka dari background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Dibuka dari notifikasi: ${message.notification?.title}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda Hunter'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Selamat bertugas, Hunter!',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/profile');
        },
        backgroundColor: Colors.deepPurple,
        tooltip: 'Profil Saya',
        child: Icon(Icons.person),
      ),
    );
  }
}
