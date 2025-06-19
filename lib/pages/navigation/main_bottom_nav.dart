import 'package:flutter/material.dart';
import 'package:flutter_p3l_app/pages/merch/MerchPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../home/home_hunter.dart';
import '../../home/home_kurir.dart';
import '../../home/home_pembeli.dart';
import '../../home/home_penitip.dart';

import '../orders/my_order_page.dart';
// import '../info/info_page.dart';
//import '../profile/profile_page.dart';
import '../profile/hunter_profile_page.dart';
import '../profile/pembeli_profile_page.dart';
import '../profile/penitip_profile_page.dart';


class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  final storage = FlutterSecureStorage();
  int _selectedIndex = 0;

  Future<String> getRole() async {
    final role = await storage.read(key: 'role') ?? '';
    print('🔍 Role dari storage: $role');
    return role;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!;
        late Widget homePage;

        // Role-based home
        switch (role) {
          case 'kurir':
            homePage = const HomeKurir();
            break;
          case 'penitip':
            homePage = const HomePenitip();
            break;
          case 'hunter':
            homePage = const HomeHunter();
            break;
          case 'pembeli':
          default:
            homePage = const HomePembeli();
        }

        final List<Widget> pages;

        if (role == 'hunter') {
          pages = [
            homePage,
            const MyOrderPage(),
            const MerchPage(),
            const HunterProfilePage(),
          ];
        } else if (role == 'penitip') {
          pages = [
            homePage,
            const MyOrderPage(),
            const MerchPage(),
            const PenitipProfilePage(),
          ];
        } else {
          // Default: pembeli atau role lain
          pages = [
            homePage,
            const MyOrderPage(),
            const MerchPage(),
            const PembeliProfilePage(),
          ];
        }


        return Scaffold(
          body: pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping),
                label: 'My Order',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.card_giftcard), // Ganti icon info → gift
                label: 'Merch',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'My Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
