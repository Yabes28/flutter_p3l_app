class PembeliProfile {
  final int pembeliID;
  final String name;
  final String email;
  final String nomorHP;
  final String alamat;
  final int rewardPoints;
  final String role;
  final List<dynamic> transactionHistory; // Placeholder, adjust if needed

  PembeliProfile({
    required this.pembeliID,
    required this.name,
    required this.email,
    required this.nomorHP,
    required this.alamat,
    required this.rewardPoints,
    required this.role,
    required this.transactionHistory,
  });

  factory PembeliProfile.fromJson(Map<String, dynamic> json) {
    return PembeliProfile(
      pembeliID: json['pembeliID'] ?? 0,
      name: json['nama'] ?? '',
      email: json['email'] ?? '',
      nomorHP: json['nomorHP'] ?? '',
      alamat: json['alamat'] ?? '',
      rewardPoints: json['poinLoyalitas'] ?? 0,
      role: json['role'] ?? 'pembeli',
      transactionHistory: json['transaksiMerchandise'] as List<dynamic>? ?? [],
    );
  }
}