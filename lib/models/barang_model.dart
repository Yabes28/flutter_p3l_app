class Barang {
  final int idProduk;
  final String namaProduk;
  final String deskripsi;
  final double harga;
  final String kategori;
  final String status;
  final String? gambar;
  final String? gambar2;
  final String? tglMulai;
  final String? tglSelesai;
  final String? garansi;

  Barang({
    required this.idProduk,
    required this.namaProduk,
    required this.deskripsi,
    required this.harga,
    required this.kategori,
    required this.status,
    this.gambar,
    this.gambar2,
    this.tglMulai,
    this.tglSelesai,
    this.garansi,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      idProduk: json['idProduk'],
      namaProduk: json['namaProduk'],
      deskripsi: json['deskripsi'],
      harga: double.tryParse(json['harga'].toString()) ?? 0,
      kategori: json['kategori'],
      status: json['status'],
      gambar: json['gambar_url'],
      gambar2: json['gambar2_url'],
      tglMulai: json['tglMulai'],
      tglSelesai: json['tglSelesai'],
      garansi: json['garansi'],
    );
  }
}
