// penitip_history_model.dart
class BarangDititipkan {
  final int idProduk;
  final String namaProduk;
  final String status;
  final String tglMulai;
  final String tglSelesai;
  final double harga;
  final String? gambarUrl;
  final String? gambar2Url;

  BarangDititipkan({
    required this.idProduk,
    required this.namaProduk,
    required this.status,
    required this.tglMulai,
    required this.tglSelesai,
    required this.harga,
    this.gambarUrl,
    this.gambar2Url,
  });

  factory BarangDititipkan.fromJson(Map<String, dynamic> json) {
    return BarangDititipkan(
      idProduk: json['idProduk'] as int,
      namaProduk: json['namaProduk'] as String,
      status: json['status'] as String,
      tglMulai: json['tglMulai'] as String,
      tglSelesai: json['tglSelesai'] as String,
      harga: (json['harga'] is String) ? double.parse(json['harga']) : (json['harga'] as num).toDouble(),
      gambarUrl: json['gambar_url'] as String?,
      gambar2Url: json['gambar2_url'] as String?,
    );
  }
}