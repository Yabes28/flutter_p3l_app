class Barang {
  final int idProduk;
  final String namaProduk;
  final String deskripsi;
  final double harga;
  final String kategori;
  final String status;
  final String? gambarUrl;

  Barang({
    required this.idProduk,
    required this.namaProduk,
    required this.deskripsi,
    required this.harga,
    required this.kategori,
    required this.status,
    this.gambarUrl,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      idProduk: json['idProduk'],
      namaProduk: json['namaProduk'],
      deskripsi: json['deskripsi'],
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      kategori: json['kategori'],
      status: json['status'],
      gambarUrl: json['gambar_url'],
    );
  }
}
