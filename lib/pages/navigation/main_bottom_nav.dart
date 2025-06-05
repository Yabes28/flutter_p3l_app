import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../home/home_hunter.dart';
import '../../home/home_kurir.dart';
import '../../home/home_pembeli.dart';
import '../../home/home_penitip.dart';

import '../orders/my_order_page.dart';
import '../info/info_page.dart';
import '../profile/profile_page.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({Key? key}) : super(key: key);

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  final storage = FlutterSecureStorage();
  int _selectedIndex = 0;
  Widget? _homePage;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await storage.read(key: 'role') ?? '';

    setState(() {
      if (role == 'kurir') {
        _homePage = HomeKurir();
      } else if (role == 'pembeli') {
        _homePage = HomePembeli();
      } else if (role == 'penitip') {
        _homePage = HomePenitip();
      } else {
        _homePage = HomeHunter(); // default
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _homePage ?? Center(child: CircularProgressIndicator()),
      MyOrderPage(),
      InfoPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'My Order'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Info'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Profile'),
        ],
      ),
    );
  }
}
