// lib/models/penjadwalan.dart  <-- GANTI SEMUA ISI FILE INI

import 'dart:convert';

// Fungsi untuk parsing list JSON
List<Penjadwalan> penjadwalanFromJson(String str) => List<Penjadwalan>.from(json.decode(str).map((x) => Penjadwalan.fromJson(x)));

///
/// INI ADALAH MODEL YANG BENAR
/// Model ini cocok dengan JSON yang dikirim oleh PenjadwalanController Anda,
/// yang sudah berisi namaPembeli, alamat, namaKurir, dll.
///
class Penjadwalan {
    Penjadwalan({
        required this.penjadwalanID,
        required this.tanggal,
        required this.waktu,
        required this.tipe,
        required this.status,
        required this.namaKurir,
        required this.namaPembeli,
        required this.alamat,
        required this.transaksiID,
        required this.produk,
    });

    final int penjadwalanID;
    final DateTime tanggal;
    final String waktu;
    final String tipe;
    final String status;
    final String namaKurir;
    final String namaPembeli;
    final String alamat;
    final int transaksiID;
    final List<String> produk;

    factory Penjadwalan.fromJson(Map<String, dynamic> json) => Penjadwalan(
        penjadwalanID: json["penjadwalanID"],
        tanggal: DateTime.parse(json["tanggal"]),
        waktu: json["waktu"].substring(0, 5), // Ambil H:i saja
        tipe: json["tipe"],
        status: json["status"],
        namaKurir: json["namaKurir"],
        namaPembeli: json["namaPembeli"],
        alamat: json["alamat"],
        transaksiID: json["transaksiID"],
        produk: List<String>.from(json["produk"].map((x) => x)),
    );
}