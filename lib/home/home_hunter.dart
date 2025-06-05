import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/notification_service.dart';
import '../../models/barang_model.dart';
import '../../services/barang_service.dart';

class HomeHunter extends StatefulWidget {
  const HomeHunter({super.key});

  @override
  _HomeHunterState createState() => _HomeHunterState();
}

class _HomeHunterState extends State<HomeHunter> {
  late Future<List<Barang>> _barangList;

  @override
  void initState() {
    super.initState();

    // 🔔 FCM: Izin dan Event
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getToken().then((token) {
      print('📱 [Hunter] Token FCM: $token');
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🎯 [Hunter] Pesan Masuk: ${message.notification?.title}');
      NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification?.title ?? 'Notifikasi',
        body: message.notification?.body ?? 'Ada info baru untukmu, Hunter!',
      );
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Dibuka dari notifikasi: ${message.notification?.title}');
    });

    // 🚚 Fetch Barang
    _barangList = BarangService.fetchBarangAvailable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda Hunter'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Barang>>(
        future: _barangList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat barang'));
          }

          final barangs = snapshot.data!;
          if (barangs.isEmpty) {
            return Center(child: Text('Belum ada barang aktif.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: barangs.length,
            itemBuilder: (context, index) {
              final barang = barangs[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Image.network(
                    barang.gambarUrl ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.image_not_supported),
                  ),
                  title: Text(barang.namaProduk),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rp ${barang.harga.toStringAsFixed(0)}'),
                      Text('Kategori: ${barang.kategori}'),
                    ],
                  ),
                  onTap: () {
                    // TODO: buka detail barang
                  },
                ),
              );
            },
          );
        },
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
