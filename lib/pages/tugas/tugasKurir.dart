import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/kurir_service.dart'; // <-- Import service yang baru dibuat

class HalamanTugasKurir extends StatefulWidget {
  const HalamanTugasKurir({super.key});

  @override
  State<HalamanTugasKurir> createState() => _HalamanTugasKurirState();
}

class _HalamanTugasKurirState extends State<HalamanTugasKurir> {
  // Instance dari service, untuk memanggil fungsi-fungsi API
  final KurirService _kurirService = KurirService();
  
  // State untuk mengelola data dan tampilan UI
  List<Map<String, dynamic>> _daftarTugas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTugas();
  }

  /// Memuat data tugas dari service dan mengupdate UI.
  Future<void> _loadTugas() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tugas = await _kurirService.getTugas();
      if (mounted) {
        setState(() {
          _daftarTugas = tugas;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Menangani aksi 'Tandai Selesai' dari UI.
  Future<void> _handleTandaiSelesai(int idTugas) async {
    // Tampilkan dialog konfirmasi sebelum update
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menandai tugas ini telah selesai dikirim?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Yakin'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    // Tampilkan dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _kurirService.updateStatusSelesai(idTugas);
      if (mounted) {
        Navigator.pop(context); // Tutup dialog loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status berhasil diupdate!'), backgroundColor: Colors.green),
        );
        _loadTugas(); // Muat ulang data setelah berhasil
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup dialog loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- BAGIAN UI (TAMPILAN) DENGAN TAB ---
  // Kode UI tidak berubah, hanya cara memanggil logikanya

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tugas Pengiriman'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadTugas,
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.local_shipping), text: 'Tugas Aktif'),
              Tab(icon: Icon(Icons.history), text: 'Riwayat'),
            ],
          ),
        ),
        body: _buildBodyContent(),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: $_errorMessage'),
        ),
      );
    }
    return TabBarView(
      children: [
        _buildTugasListView(
          tugas: _daftarTugas.where((t) => t['status'] == 'berhasil dikirim').toList(),
          isAktif: true,
        ),
        _buildTugasListView(
          tugas: _daftarTugas.where((t) => t['status'] == 'selesai').toList(),
          isAktif: false,
        ),
      ],
    );
  }

  Widget _buildTugasListView({required List<Map<String, dynamic>> tugas, required bool isAktif}) {
    if (tugas.isEmpty) {
      return Center(
        child: Text(isAktif ? 'Tidak ada tugas aktif.' : 'Belum ada riwayat pengiriman.'),
      );
    }

    if (!isAktif) {
      tugas.sort((a, b) {
        final dateA = DateTime.tryParse(a['tanggal'] ?? '');
        final dateB = DateTime.tryParse(b['tanggal'] ?? '');
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: tugas.length,
      itemBuilder: (context, index) {
        final item = tugas[index];
        final status = item['status']?.toString().toUpperCase() ?? 'UNKNOWN';
        final isSelesai = status == 'BERHASIL DIKIRIM' || status == 'SELESAI';
        
        DateTime? tanggal;
        if(item['tanggal'] != null) {
          tanggal = DateTime.tryParse(item['tanggal']);
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['namaPembeli'] ?? 'Nama tidak ada',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Chip(
                      label: Text(
                        status,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: isSelesai ? Colors.green : Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    ),
                  ],
                ),
                if (tanggal != null)
                 Padding(
                   padding: const EdgeInsets.only(top: 4.0),
                   child: Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(tanggal),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                   ),
                 ),
                const Divider(height: 20),
                Text(item['alamat'] ?? 'Alamat tidak tersedia', style: TextStyle(color: Colors.grey[800])),
                const SizedBox(height: 8),
                Text('Produk: ${item['produk'] ?? '-'}', style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic)),
                
                if (isAktif)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Tandai Selesai Dikirim'),
                        onPressed: () {
                          final idTugas = item['penjadwalanID'];
                          if (idTugas is int) {
                            _handleTandaiSelesai(idTugas);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
