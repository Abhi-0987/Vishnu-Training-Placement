import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class AdminService {
  static const String baseUrl = AppConstants.backendUrl;

  static Future<Map<String, dynamic>?> getAdminDetails(String email) async {
    final url = Uri.parse('$baseUrl/api/admin/details');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({'email': email});

    print('Fetching admin details for email: $email');
    print('Request URL: $url');

    try {
      final response = await http.post(url, headers: headers, body: body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch admin details: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching admin details: $e');
      return null;
    }
  }
}
