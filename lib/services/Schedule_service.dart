import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class ScheduleServices {
  static const String baseUrl = AppConstants.backendUrl;

  // Method to save schedule
  static Future<Map<String, dynamic>> saveSchedule(
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/api/schedules'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(scheduleData),
      );

      final contentType = response.headers['content-type'];

      if (contentType != null && contentType.contains('application/json')) {
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 201) {
          return {'success': true, 'data': responseData};
        } else {
          return {
            'success': false,
            'error': responseData['error'] ?? 'Failed to create schedule',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Unexpected response format: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Method to check availability
  static Future<Map<String, dynamic>> checkAvailability(
    String location,
    String date,
    String timeSlot,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/schedules/check-availability?location=$location&date=$date&timeSlot=$timeSlot',
        ),
      );

      final contentType = response.headers['content-type'];

      if (contentType != null && contentType.contains('application/json')) {
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {'success': true, 'available': responseData['available']};
        } else {
          return {
            'success': false,
            'error': responseData['error'] ?? 'Failed to check availability',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Unexpected response format: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
}
