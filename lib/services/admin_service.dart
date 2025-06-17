import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class AdminService {
  static const String baseUrl = AppConstants.backendUrl;

  // Get Admin Details
  static Future<Map<String, dynamic>?> getAdminDetails(String email) async {
    final url = Uri.parse('$baseUrl/api/admin/details');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({'email': email});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> changePassword(String email, String newPassword) async {
    final url = Uri.parse('$baseUrl/api/admin/change-password');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({'email': email, 'newPassword': newPassword});

    try {
      final response = await http.post(url, headers: headers, body: body);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> resetStudentPassword(String email) async {
    final url = Uri.parse('$baseUrl/api/auth/admin/reset-student-password');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({'email': email});

    try {
      final response = await http.post(url, headers: headers, body: body);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
