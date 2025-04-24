import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class StudentService {
  static const String baseUrl = AppConstants.backendUrl;

  static Future<String?> getBranchByEmail(String email) async {
    final url = Uri.parse('$baseUrl/api/student/branch');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('No token found in SharedPreferences');
      return null;
    }
    final headers = {'Content-Type': 'application/json','Authorization': 'Bearer $token',};
    final body = jsonEncode({'email': email});
    
    print('Sending request to $url');
    print('Request body: $body');
    
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final branch = data['branch'];
        print('Branch received: $branch');
        return branch as String?;
      } else {
        print('Failed to fetch branch: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }
}
