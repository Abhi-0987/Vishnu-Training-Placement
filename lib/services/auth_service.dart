import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:8080';
  Future<http.Response> login(
    String email,
    String password,
    bool isAdmin,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/auth/${isAdmin ? 'admin/login' : 'student/login'}',
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return response;
  }
}
