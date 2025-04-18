import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiServices {
  static const String baseUrl = 'http://localhost:8080/api'; // Change this to your actual backend URL
  
  // Method to save schedule
  static Future<Map<String, dynamic>> saveSchedule(Map<String, dynamic> scheduleData) async {
    try {
      final token =
          'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyMjIxMkBidnJpdC5hYy5pbiIsInJvbGUiOiJTdHVkZW50IiwiaWF0IjoxNzQ0OTEwNjM2LCJleHAiOjE3NDU1MTU0MzZ9.lsFgLNZpsw-utVjSSTbVgggBQPYxfa24qlSaSYScpHA';
      final response = await http.post(
        Uri.parse('$baseUrl/schedules'),
        headers: {
          'Content-Type': 'application/json',
           'Authorization': 'Bearer $token',
        },
        body: jsonEncode(scheduleData),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Failed to create schedule',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
  
  // Method to check availability
  static Future<Map<String, dynamic>> checkAvailability(
      String location, String date, String timeSlot) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedules/check-availability?location=$location&date=$date&timeSlot=$timeSlot'),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'available': responseData['available'],
        };
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Failed to check availability',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
}