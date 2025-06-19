import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/pembeli_history_model.dart';

final storage = FlutterSecureStorage();

Future<List<Transaction>> fetchTransactionHistory() async {
  try {
    final token = await storage.read(key: 'token');
    if (token == null) {
      print('❌ ERROR: No token found in storage');
      return [];
    }

    print('Fetching transactions with token: $token');
    print('Request URL: http://10.0.2.2:8000/api/pembeli/transactions');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/pembeli/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final transactions = (data as List).map((item) => Transaction.fromJson(item)).toList();
      print('Parsed Transactions: $transactions');
      return transactions;
    } else if (response.statusCode == 401) {
      print('❌ ERROR: Unauthorized - Token may be invalid or expired');
    } else if (response.statusCode == 404) {
      print('❌ ERROR: Not Found - Endpoint or route may not exist');
    } else {
      print('❌ ERROR: ${response.statusCode} - ${response.body}');
    }
    return [];
  } catch (e) {
    print('❌ EXCEPTION: Terjadi kesalahan saat fetch data: $e');
    return [];
  }
}