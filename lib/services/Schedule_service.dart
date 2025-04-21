import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class ScheduleServices {
  static const String baseUrl = AppConstants.backendUrl;

  // Method to save schedule
  static Future<Map<String, dynamic>> saveSchedule(
    Map<String, dynamic> scheduleData, // Ensure this map contains a 'branches': ['CSE', 'IT'] list
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Use actual token retrieval, the hardcoded one is just for example
      final token = prefs.getString('token') ?? 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyMjIxMkBidnJpdC5hYy5pbiIsInJvbGUiOiJTdHVkZW50IiwiaWF0IjoxNzQ0OTEwNjM2LCJleHAiOjE3NDU1MTU0MzZ9.lsFgLNZpsw-utVjSSTbVgggBQPYxfa24qlSaSYScpHA';

      print('Sending schedule data: ${jsonEncode(scheduleData)}'); // Add logging

      final response = await http.post(
        Uri.parse('$baseUrl/api/schedules'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(scheduleData), // scheduleData should include the 'branches' list
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
      print('Error saving schedule: $e'); // Add logging
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
  
  // Method to fetch schedules by branch
  static Future<List<dynamic>> fetchSchedulesByBranch(String branch) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/schedules/branch/$branch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        // Make sure we're properly parsing the JSON response
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Failed to load schedules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Add this method to your ScheduleServices class
  static Future<List<dynamic>> getAllSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/schedules'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load schedules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
