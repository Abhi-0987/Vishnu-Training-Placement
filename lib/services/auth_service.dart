import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class AuthService {
  static const String baseUrl = AppConstants.backendUrl;
  Future<http.Response> login(
    String email,
    String password,
    String deviceId,
    bool isAdmin,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/auth/${isAdmin ? 'admin/login' : 'student/login'}',
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "deviceId": deviceId,
      }),
    );

    return response;
  }
}
