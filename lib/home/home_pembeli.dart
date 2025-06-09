import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/barang_model.dart';
import '../../services/barang_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../pages/DetailBarangPage.dart';

class HomePembeli extends StatefulWidget {
  const HomePembeli({super.key});

  @override
  State<HomePembeli> createState() => _HomePembeliState();
}

class _HomePembeliState extends State<HomePembeli> {
  late Future<List<Barang>> _barangFuture;
  final storage = FlutterSecureStorage();
  String? namaUser;

  final List<String> bannerUrls = [
    'http://10.0.2.2:8000/storage/barang_foto/caro1.jpg',
    'http://10.0.2.2:8000/storage/barang_foto/caro2.jpg',
    'http://10.0.2.2:8000/storage/barang_foto/caro3.jpg',
  ];

  @override
  void initState() {
    super.initState();

    for (var url in bannerUrls) {
    print('🖼️ Banner URL: $url');
  }
    _barangFuture = BarangService.fetchBarangAvailable()
      ..then((barangs) {
        for (var barang in barangs) {
          print('✅ [DEBUG] Produk: ${barang.namaProduk}');
          print('🖼️ [DEBUG] URL Gambar: ${barang.gambar}');
        }
      });
    _loadUser();
  }

  Future<void> _loadUser() async {
    final nama = await storage.read(key: 'name');
    setState(() {
      namaUser = nama ?? 'Pengguna';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hi, ${namaUser ?? '...'}!',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const Text('Welcome back', style: TextStyle(fontSize: 14))
              ],
            ),
            const CircleAvatar(
              backgroundImage:
                  NetworkImage('https://i.pravatar.cc/150?img=3'),
            )
          ],
        ),
      ),
      body: FutureBuilder<List<Barang>>(
        future: _barangFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Gagal memuat: ${snapshot.error}'));
          }

          final barangs = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                CarouselSlider(
  options: CarouselOptions(
    height: 150,
    enlargeCenterPage: true,
    autoPlay: true,
    aspectRatio: 16 / 9,
    autoPlayInterval: const Duration(seconds: 3),
    viewportFraction: 0.85,
  ),
  items: bannerUrls.map((url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.broken_image, size: 40, color: Colors.red),
            ),
          );
        },
      ),
    );
  }).toList(),
),

                const SizedBox(height: 20),
                const Divider(thickness: 1.2),
                const SizedBox(height: 10),
                const Text('Produk Tersedia',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    itemCount: barangs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final barang = barangs[index];
                      final imageUrl = barang.gambar != null &&
                              barang.gambar!.isNotEmpty
                          ? barang.gambar!
                          : 'https://via.placeholder.com/150';

                      print('📸 Menampilkan: ${barang.namaProduk} - $imageUrl');

                      return GestureDetector(
                        onTap: () {
                          print('🔍 Barang diklik: ${barang.namaProduk}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailBarangPage(barang: barang),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      barang.namaProduk,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${barang.harga.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
