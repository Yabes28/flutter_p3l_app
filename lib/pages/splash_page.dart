import 'package:flutter/material.dart';
import 'login_page.dart';
import 'navigation/main_bottom_nav.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.jpg', width: 100), // Ganti dengan logo Anda
            const SizedBox(height: 20),
            const Text('ReuseMart',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 12),
            const Text(
              'Fasilitas bagi masyarakat untuk menjual atau membeli barang bekas yang berkualitas',
              style: TextStyle(color: Colors.black87, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Visi dan Misi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mengurangi penumpukan sampah dan memberikan kesempatan kedua bagi barang-barang bekas yang layak pakai.\nReuseMart hadir sebagai solusi inovatif yang memadukan nilai sosial dan bisnis.',
              style: TextStyle(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text("Login"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MainBottomNav()));
              },
              child: const Text("View Products", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
