import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService{
  final _storage = const FlutterSecureStorage();
  final String baseUrl = "http://10.0.2.2:8000/api"; //backend ip

  Future<bool> loginWithSchoolEmail(String email) async {
    final url = Uri.parse('$baseUrl/token/');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);

      await _storage.write(key: "access", value: data['access']);
      await _storage.write(key: "refresh", value: data['refresh']);
      return true;
    }else {
      return false;
      }
    }

    Future<String?> getAccessToken() async {
      return await _storage.read(key: "access");
    }
  }

