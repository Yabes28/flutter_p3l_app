import 'package:flutter/material.dart';
import '../models/barang_model.dart';

class DetailBarangPage extends StatefulWidget {
  final Barang barang;
  const DetailBarangPage({Key? key, required this.barang}) : super(key: key);

  @override
  State<DetailBarangPage> createState() => _DetailBarangPageState();
}

class _DetailBarangPageState extends State<DetailBarangPage> {
  late final String? imageUrl1;
  late final String? imageUrl2;

  @override
  void initState() {
    super.initState();
    const baseImageUrl = 'http://10.0.2.2:8000/storage/';
    imageUrl1 = widget.barang.gambar != null ? '$baseImageUrl${widget.barang.gambar}' : null;
    imageUrl2 = widget.barang.gambar2 != null ? '$baseImageUrl${widget.barang.gambar2}' : null;

    print('📦 Produk: ${widget.barang.namaProduk}');
    print('🖼️ Gambar 1: $imageUrl1');
    print('🖼️ Gambar 2: $imageUrl2');
    print('📅 Garansi: ${widget.barang.garansi}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Foto Utama', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      _buildImage(imageUrl1),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Foto Kedua', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      _buildImage(imageUrl2),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.barang.namaProduk,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${widget.barang.harga.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.deepPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Deskripsi:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              widget.barang.deskripsi.isNotEmpty ? widget.barang.deskripsi : '-',
              style: const TextStyle(fontSize: 15),
            ),
            const Divider(height: 30, thickness: 1.2),
            _infoTile('Kategori', widget.barang.kategori),
            _infoTile('Status', widget.barang.status),
            _infoTile('Tanggal Mulai', formatDate(widget.barang.tglMulai)),
            _infoTile('Tanggal Selesai', formatDate(widget.barang.tglSelesai)),
            const SizedBox(height: 12),
            if (widget.barang.garansi != null && widget.barang.garansi!.isNotEmpty)
              _buildGaransiBadge(widget.barang.garansi!)
            else
              _buildNoGaransiBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
  print('📸 Menampilkan gambar detail: $imageUrl'); // <--- Tambahkan ini

  return AspectRatio(
    aspectRatio: 1.5,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl == null || imageUrl.isEmpty
          ? Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 40),
              ),
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                print('❌ Gagal load gambar detail: $imageUrl'); // <--- Tambahkan ini
                return const Icon(Icons.broken_image);
              },
            ),
    ),
  );
}


  Widget _infoTile(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value ?? '-', style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}-${date.month}-${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildGaransiBadge(String garansiStr) {
    final garansiDate = DateTime.tryParse(garansiStr);
    final now = DateTime.now();

    if (garansiDate == null) return _buildNoGaransiBadge();

    final sisaHari = garansiDate.difference(now).inDays;
    final isActive = garansiDate.isAfter(now);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? Colors.green : Colors.red),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.verified : Icons.error_outline,
            color: isActive ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isActive
                  ? 'Garansi aktif • sisa ${sisaHari.clamp(0, 999)} hari (sampai ${formatDate(garansiStr)})'
                  : 'Garansi berakhir pada ${formatDate(garansiStr)}',
              style: TextStyle(
                color: isActive ? Colors.green[900] : Colors.red[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoGaransiBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: const [
          Icon(Icons.cancel, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text('❌ Tidak bergaransi', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
