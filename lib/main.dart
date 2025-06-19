import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'firebase/firebase_options.dart';
import 'services/notification_service.dart';

import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/navigation/main_bottom_nav.dart';

import 'home/home_pembeli.dart';
import 'home/home_penitip.dart';
import 'home/home_kurir.dart';
import 'home/home_hunter.dart';

import 'pages/profile/profile_page.dart';
import 'pages/profile/hunter_profile_page.dart';

import 'pages/DetailBarangPage.dart';
import 'models/barang_model.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();
  await NotificationService.showNotification(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: message.notification?.title ?? 'Notifikasi',
    body: message.notification?.body ?? 'Ada pesan baru untukmu',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();

  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ReuseMartApp());
}

class ReuseMartApp extends StatelessWidget {
  const ReuseMartApp({super.key});

  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReUseMart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      // 👉 Halaman pertama kini SplashPage
      home: const SplashPage(),

      // Routing (detail dan lainnya)
      onGenerateRoute: (settings) {
        if (settings.name == '/detail-barang') {
          final args = settings.arguments;
          if (args is Barang) {
            return MaterialPageRoute(
              builder: (_) => DetailBarangPage(barang: args),
            );
          } else {
            return _errorRoute("Barang tidak ditemukan");
          }
        }

        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/homePembeli':
            return MaterialPageRoute(builder: (_) => const HomePembeli());
          case '/homePenitip':
            return MaterialPageRoute(builder: (_) => const HomePenitip());
          case '/homeKurir':
            return MaterialPageRoute(builder: (_) => const HomeKurir());
          case '/homeHunter':
            return MaterialPageRoute(builder: (_) => const HomeHunter());
          case '/main':
            return MaterialPageRoute(builder: (_) => const MainBottomNav());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfilePage());
          case '/hunter-profile':
            return MaterialPageRoute(builder: (_) => const HunterProfilePage());
          default:
            return _errorRoute("Halaman tidak ditemukan");
        }
      },
    );
  }
}
