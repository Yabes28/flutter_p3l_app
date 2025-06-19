class Transaction {
  final int transactionId;
  final String transactionDate;
  final String status;
  final double totalAmount; // Ubah dari int ke double
  final int pointsEarned;
  final List<Detail> details;

  Transaction({
    required this.transactionId,
    required this.transactionDate,
    required this.status,
    required this.totalAmount,
    required this.pointsEarned,
    required this.details,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transaksiID'] as int,
      transactionDate: json['waktu_transaksi'] as String,
      status: json['status'] as String,
      totalAmount: double.parse(json['totalHarga'] as String), // Parse string ke double
      pointsEarned: json['poinEarned'] as int,
      details: (json['details'] as List)
          .map((detail) => Detail.fromJson(detail))
          .toList(),
    );
  }
}

class Detail {
  final int idDetailTransaksi;
  final int produkID;
  final String productName;
  final int quantity;
  final int hargaSatuan;
  final double subtotal; // Ubah dari int ke double

  Detail({
    required this.idDetailTransaksi,
    required this.produkID,
    required this.productName,
    required this.quantity,
    required this.hargaSatuan,
    required this.subtotal,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      idDetailTransaksi: json['id_detail_transaksi'] as int,
      produkID: json['produkID'] as int,
      productName: json['produkNama'] as String,
      quantity: json['jumlah'] as int,
      hargaSatuan: json['harga_satuan'] as int,
      subtotal: double.parse(json['subtotal'] as String), // Parse string ke double
    );
  }
}