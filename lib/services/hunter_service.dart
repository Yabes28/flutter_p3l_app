import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/hunter_profile_model.dart';

final storage = FlutterSecureStorage();

Future<HunterProfile?> fetchHunterProfile() async {
  final token = await storage.read(key: 'token');
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8000/api/hunter/profile'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return HunterProfile.fromJson(data);
  } else {
    print('❌ ERROR: ${response.body}');
    return null;
  }
}
