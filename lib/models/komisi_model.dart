class Komisi {
  final int transaksiID;
  final String komisiHunter;
  final int jumlahKomisi;
  final String persentase;
  final String tanggalKomisi;

  Komisi({
    required this.transaksiID,
    required this.komisiHunter,
    required this.jumlahKomisi,
    required this.persentase,
    required this.tanggalKomisi,
  });

  factory Komisi.fromJson(Map<String, dynamic> json) {
    return Komisi(
      transaksiID: json['transaksiID'],
      komisiHunter: json['komisi_hunter'].toString(),
      jumlahKomisi: json['jumlahKomisi'],
      persentase: json['persentase'].toString(),
      tanggalKomisi: json['tanggalKomisi'],
    );
  }
}
