import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class AttendanceService {
  String baseUrl = AppConstants.backendUrl;

  Future<String> markAttendance(String date, String time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token =
          prefs.getString('token') ??
          'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyMjIxMjNAYnZyaXQuYWMuaW4iLCJyb2xlIjoiU3R1ZGVudCIsImlhdCI6MTc0NzQwMTU5MCwiZXhwIjoxNzQ3NDg3OTkwfQ.rwFX-8VQsuAoolms3gLQVRadDzSH-V8D5ZXJ5f8RDSA';
      final email = prefs.getString('studentEmail');

      final apiUrl = '$baseUrl/api/attendance/mark-present';

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"date": date, "time": time, "email": email}),
      );

      return response.body.toString();
    } catch (e) {
      print(e);
      return e.toString();
    }
  }
}
