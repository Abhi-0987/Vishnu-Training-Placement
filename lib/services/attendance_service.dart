import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class AttendanceService {
  String baseUrl = AppConstants.backendUrl;

  Future<String> markAttendance(String date, String fromTime, String toTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final email = prefs.getString('studentEmail');

      final apiUrl = '$baseUrl/api/attendance/mark-present';

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "date": date, 
          "fromTime": fromTime, 
          "toTime": toTime, 
          "email": email
        }),
      );

      return response.body.toString();
    } catch (e) {
      print(e);
      return e.toString();
    }
  }
}
