// penitip_profile_model.dart
class PenitipProfile {
  final int penitipID;
  final String nama;
  final String email;
  final double saldo;
  final int poinLoyalitas;
  final String role;
  final bool isTopSeller; // Tambahkan field ini
  final DateTime? topSellerUntil; // Tambahkan field ini

  PenitipProfile({
    required this.penitipID,
    required this.nama,
    required this.email,
    required this.saldo,
    required this.poinLoyalitas,
    required this.role,
    required this.isTopSeller, // Tambahkan parameter
    this.topSellerUntil, // Tambahkan parameter
  });

  factory PenitipProfile.fromJson(Map<String, dynamic> json) {
    return PenitipProfile(
      penitipID: json['penitipID'] as int,
      nama: json['nama'] as String,
      email: json['email'] as String,
      saldo: (json['saldo'] is String) ? double.parse(json['saldo']) : (json['saldo'] as num).toDouble(),
      poinLoyalitas: json['poinLoyalitas'] as int,
      role: json['role'] as String,
      isTopSeller: json['isTopSeller'] as bool, // Map field ini
      topSellerUntil: json['topSellerUntil'] != null ? DateTime.parse(json['topSellerUntil']) : null, // Map field ini
    );
  }
}