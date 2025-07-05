// lib/services/attendance_service.dart

import 'dart:convert';
import 'dart:math' show min;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../utils/app_constants.dart';

//attendance service
class AttendanceService {
  static String baseUrl = AppConstants.backendUrl;

  static Future<Map<String, dynamic>> fetchScheduleDetails(
    int scheduleId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http
        .get(
          Uri.parse('$baseUrl/api/schedules/$scheduleId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception(
              'Connection timeout. Please check your server or internet connection.',
            );
          },
        );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to load schedule details: ${response.statusCode}',
      );
    }
  }

  static Future<List<Student>> fetchStudents(int scheduleId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http
        .get(
          Uri.parse('$baseUrl/api/schedules/$scheduleId/students'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception(
              'Connection timeout. Please check your server or internet connection.',
            );
          },
        );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return [];
      }

      if (response.body.trim().startsWith('<')) {
        throw Exception(
          'Server returned HTML/XML instead of JSON. Check server logs.',
        );
      }

      final List<dynamic> studentsJson = json.decode(response.body);
      return studentsJson
          .whereType<Map<String, dynamic>>()
          .map(
            (json) => Student(
              email: json['email'] ?? '',
              isPresent: json['present'] ?? false,
            ),
          )
          .toList();
    } else {
      String errorMsg = 'Failed to load students: ${response.statusCode}';
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map && errorData.containsKey('error')) {
          errorMsg = errorData['error'];
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          errorMsg +=
              ' - ${response.body.substring(0, min(100, response.body.length))}...';
        }
      }
      throw Exception(errorMsg);
    }
  }

  static Future<void> markAttendance(
    int scheduleId,
    List<String> emails,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http
        .post(
          Uri.parse('$baseUrl/api/schedules/$scheduleId/mark-attendance'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(emails),
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception(
              'Connection timeout. Please check your server or internet connection.',
            );
          },
        );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark attendance: ${response.statusCode}');
    }
  }
}
