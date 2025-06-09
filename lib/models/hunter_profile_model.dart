import 'komisi_model.dart';

class HunterProfile {
  final String nama;
  final String email;
  final String jabatan;
  final String totalKomisi;
  final List<Komisi> riwayatKomisi;

  HunterProfile({
    required this.nama,
    required this.email,
    required this.jabatan,
    required this.totalKomisi,
    required this.riwayatKomisi,
  });

  factory HunterProfile.fromJson(Map<String, dynamic> json) {
    return HunterProfile(
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      jabatan: json['jabatan'] ?? '',
      totalKomisi: json['totalKomisi'] ?? '0',
      riwayatKomisi: (json['riwayatKomisi'] as List<dynamic>)
          .map((item) => Komisi.fromJson(item))
          .toList(),
    );
  }
}
