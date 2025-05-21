import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class StudentService {
  static const String baseUrl = AppConstants.backendUrl;

  static Future<Map<String, dynamic>?> getStudentDetails(String email) async {
    final url = Uri.parse('$baseUrl/api/student/details');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({'email': email});

    print('Fetching student details for email: $email');
    print('Request URL: $url');

    try {
      final response = await http.post(url, headers: headers, body: body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch student details: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching student details: $e');
      return null;
    }
  }
  static Future<bool> changePassword(String email, String newPassword) async {
    final url = Uri.parse('$baseUrl/api/student/change-password');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'email': email,
      'newPassword': newPassword,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Change password status: ${response.statusCode}');
      print('Change password body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }
}
