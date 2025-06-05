import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

class HomePembeli extends StatefulWidget {
  @override
  _HomePembeliState createState() => _HomePembeliState();
}

class _HomePembeliState extends State<HomePembeli> {
  @override
  void initState() {
    super.initState();

    // ✅ Minta izin notifikasi (Android 13+)
    FirebaseMessaging.instance.requestPermission();

    // ✅ Cek token FCM (jika perlu ditampilkan/log)
    FirebaseMessaging.instance.getToken().then((token) {
      print('📱 Token FCM: $token');
    });

    // ✅ Notifikasi saat app foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🟢 [Pembeli] Notif masuk: ${message.notification?.title}');
      NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification?.title ?? 'Notifikasi',
        body: message.notification?.body ?? 'Ada pesan baru untukmu',
      );
    });

    // ✅ Saat notifikasi dibuka dari background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Dibuka dari notifikasi: ${message.notification?.title}');
      // Arahkan ke halaman tertentu jika perlu
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda Pembeli'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          'Selamat datang, Pembeli!',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/profile');
        },
        child: Icon(Icons.person),
        backgroundColor: Colors.green,
        tooltip: 'Profil Saya',
      ),
    );
  }
}
