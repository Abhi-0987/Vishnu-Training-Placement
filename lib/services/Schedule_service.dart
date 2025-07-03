// ignore: file_names
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

      final url = '$baseUrl/api/schedules/$scheduleId';
      print('Calling DELETE: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'error': 'Failed to delete schedule'};
      }
    } catch (e) {
      print('Error deleting schedule: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // New method to update the mark status
  static Future<Map<String, dynamic>> updateScheduleMarkStatus(
    String scheduleId,
    bool mark,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/schedules/$scheduleId/mark',
        ), // Use the new endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'mark': mark}), // Send the mark status in the body
      );

      if (response.statusCode == 200) {
        // Successfully updated
        return {
          'success': true,
          'message': 'Attendance status updated successfully',
        };
      } else {
        // Handle errors
        String errorMessage = 'Failed to update attendance status';
        try {
          // Try to parse error message from backend response
          final responseData = jsonDecode(response.body);
          errorMessage =
              responseData['error'] ?? responseData['message'] ?? errorMessage;
        } catch (e) {
          // Ignore parsing errors if response is not JSON
          print('Error parsing error response: $e');
        }
        return {
          'success': false,
          'message': '$errorMessage (Status code: ${response.statusCode})',
        };
      }
    } catch (e) {
      // print('Error updating mark status: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Method to get attendance statistics for a schedule
  static Future<Map<String, dynamic>> getAttendanceStatistics(
    String scheduleId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/schedules/$scheduleId/attendance-stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'data': responseData};
      } else {
        String errorMessage = 'Failed to fetch attendance statistics';
        try {
          final responseData = jsonDecode(response.body);
          errorMessage =
              responseData['error'] ?? responseData['message'] ?? errorMessage;
        } catch (e) {
          print('Error parsing error response: $e');
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Error fetching attendance statistics: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': {'totalStudents': 0, 'presentCount': 0, 'absentCount': 0},
      };
    }
  }

  // Method to get detailed schedule information
  static Future<Map<String, dynamic>> getScheduleDetails(
    String scheduleId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/schedules/$scheduleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Process the data to ensure all fields have valid values
        final processedData = {
          'id': data['id'],
          'title': data['title'] ?? 'Untitled Schedule',
          'date': data['date'] ?? 'Not specified',
          'time': data['time'] ?? 'Not specified',
          'location': data['location'] ?? 'Not specified',
          'roomNo': data['roomNo'] ?? 'Not specified',
          'mark': data['mark'] ?? false,
          'studentBranch': _processBranchData(data['studentBranch']),
        };

        return {'success': true, 'data': processedData};
      } else {
        String errorMessage = 'Failed to fetch schedule details';
        try {
          final responseData = jsonDecode(response.body);
          errorMessage =
              responseData['error'] ?? responseData['message'] ?? errorMessage;
        } catch (e) {
          print('Error parsing error response: $e');
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Error fetching schedule details: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Helper method to process branch data which might come in different formats
  static List<String> _processBranchData(dynamic branchData) {
    if (branchData == null) {
      return ['All Branches'];
    }

    if (branchData is String) {
      if (branchData.isEmpty) {
        return ['All Branches'];
      }
      return branchData
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (branchData is List) {
      if (branchData.isEmpty) {
        return ['All Branches'];
      }
      return List<String>.from(branchData.map((item) => item.toString()));
    }

    return ['All Branches'];
  }
}
