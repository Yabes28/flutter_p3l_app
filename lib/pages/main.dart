import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase/firebase_options.dart';

// Notifikasi lokal
import '../services/notification_service.dart';

// Halaman internal
import 'login_page.dart';
import '../home/home_pembeli.dart';
import '../home/home_penitip.dart';
import '../home/home_kurir.dart';
import '../home/home_hunter.dart';
import 'profile_page.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();
  await NotificationService.showNotification(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: message.notification?.title ?? 'Notifikasi',
    body: message.notification?.body ?? 'Ada pesan baru untukmu',
  );
  print('🔴 [Background] Pesan masuk: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();

  // ✅ Minta izin notifikasi (Android 13+)
  await FirebaseMessaging.instance.requestPermission();

  // ✅ Daftarkan background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ReuseMartApp());
}

class ReuseMartApp extends StatelessWidget {
  const ReuseMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReUseMart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const LoginPage(),
      routes: {
        '/homePembeli': (_) => HomePembeli(),
        '/homePenitip': (_) => HomePenitip(),
        '/homeKurir': (_) => HomeKurir(),
        '/homeHunter': (_) => HomeHunter(),
        '/profile': (_) => ProfilePage(),
      },
    );
  }
}
