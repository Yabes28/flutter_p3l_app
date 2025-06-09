class Merchandise {
  final int merchandiseID;
  final String nama;
  final int hargaMerch;
  final int stok;
  final String? foto;

  Merchandise({
    required this.merchandiseID,
    required this.nama,
    required this.hargaMerch,
    required this.stok,
    this.foto,
  });

  factory Merchandise.fromJson(Map<String, dynamic> json) {
    return Merchandise(
      merchandiseID: json['merchandiseID'],
      nama: json['nama'],
      hargaMerch: json['hargaMerch'],
      stok: json['stok'],
      foto: json['foto'],
    );
  }
}
