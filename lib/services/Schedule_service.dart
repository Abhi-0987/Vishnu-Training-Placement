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

      //print('Sending schedule data: ${jsonEncode(scheduleData)}');

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
      //print('Error saving schedule: $e');
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
      // Using hardcoded token for testing as explained by user
      final token = prefs.getString('token') ?? '';

      // Optional: Check if the token is empty (shouldn't happen with hardcoded fallback)
      // if (token.isEmpty) { ... }

      final response = await http.get(
        Uri.parse('$baseUrl/api/schedules/branch/$branch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );


      if (response.statusCode == 200) {
        return jsonDecode(response.body);
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
      // Use the SAME hardcoded token here for testing consistency
      final token = prefs.getString('token') ?? '';

      // Optional: Check if the token is empty (shouldn't happen with hardcoded fallback)
      // if (token.isEmpty) { ... }

      final response = await http.get(
        Uri.parse('$baseUrl/api/schedules'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      //print('Response status code: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        //print(
        //   'Error fetching all schedules: ${response.statusCode} ${response.body}',
        // );
        throw Exception('Failed to load schedules: ${response.statusCode}');
      }
    } catch (e) {
      // print('Network error in getAllSchedules: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Method to update an existing schedule
  static Future<Map<String, dynamic>> updateSchedule(
    String scheduleId,
    Map<String, dynamic> updatedScheduleData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      //print('Updating schedule data: ${jsonEncode(updatedScheduleData)}');

      final response = await http.put(
        Uri.parse('$baseUrl/api/schedules/$scheduleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatedScheduleData),
      );

      final contentType = response.headers['content-type'];

      if (contentType != null && contentType.contains('application/json')) {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': 'Schedule updated successfully',
            'data': responseData,
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to update schedule',
          };
        }
      } else {
        return {'success': false, 'message': 'Invalid response from server'};
      }
    } catch (e) {
      // print('Error updating schedule: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Method to delete a schedule
  static Future<Map<String, dynamic>> deleteSchedule(String scheduleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.delete(
        Uri.parse('$baseUrl/api/schedules/$scheduleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Schedule deleted successfully'};
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete schedule',
        };
      }
    } catch (e) {
      // print('Error deleting schedule: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
