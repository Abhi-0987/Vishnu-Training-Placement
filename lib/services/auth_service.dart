import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';
class AuthService {
  static const String baseUrl = AppConstants.backendUrl;
  Future<http.Response> login(
    String email,
    String password,
    UserRole role,   // Accept role as enum here
  ) async {
    // Map UserRole enum to backend endpoint string
    String rolePath;
    switch (role) {
      case UserRole.Admin:
        rolePath = 'admin/login';
        break;
      case UserRole.Coordinator:
        rolePath = 'coordinator/login';
        break;
      case UserRole.Student:
        rolePath = 'student/login';
        break;
    }

    final url = Uri.parse('$baseUrl/api/auth/$rolePath');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        // "deviceId": deviceId,
      }),
    );

    return response;
  }
}
