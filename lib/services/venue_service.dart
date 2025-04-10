import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Venue {
  final int id;
  final String blockName;
  final String roomNumber;
  final double latitude;
  final double longitude;

  Venue({
    required this.id,
    required this.blockName,
    required this.roomNumber,
    required this.latitude,
    required this.longitude,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      blockName: json['blockName'],
      roomNumber: json['roomNumber'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class VenueService {
  // For web or desktop applications, localhost works
  // You might need to adjust this URL based on where your backend is running
  String get baseUrl {
    if (kIsWeb) {
      // For web, we need to use the exact URL where the backend is hosted
      return 'http://localhost:8080'; // Change this if your backend is on a different URL
    }
    return 'http://localhost:8080';
  }

  Future<List<Venue>> fetchVenues() async {
    try {
      // Get the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token =
          'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhQGJ2cml0LmFjLmluIiwicm9sZSI6IlN0dWRlbnQiLCJpYXQiOjE3NDQyMDc2NDYsImV4cCI6MTc0NDI5NDA0Nn0.h31OSY5CKlin_yOr6FTv_R1Pj4NhHI6JhFDO8rJx2uw';
      //prefs.getString('token') ?? '';

      final apiUrl = '$baseUrl/api/venues';
      print('Fetching venues from: $apiUrl');
      print(
        'Using token: ${token.isNotEmpty ? 'Yes (token available)' : 'No (token not found)'}',
      );

      // Don't add CORS headers from the client side - they need to come from the server
      final response = await http
          .get(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Handle different status codes
      switch (response.statusCode) {
        case 200:
          List<dynamic> venuesJson = jsonDecode(response.body);
          return venuesJson.map((json) => Venue.fromJson(json)).toList();
        case 401:
          throw Exception('Unauthorized: Your token is invalid or expired');
        case 403:
          throw Exception(
            'Forbidden: You do not have permission to access this resource',
          );
        case 404:
          throw Exception('Not Found: The venues endpoint does not exist');
        case 500:
          throw Exception('Server Error: Something went wrong on the server');
        default:
          throw Exception(
            'Failed to load venues: Status code ${response.statusCode}, Response: ${response.body}',
          );
      }
    } catch (e) {
      print('Error details: $e');

      // Check for specific error types
      if (e is http.ClientException) {
        throw Exception(
          'Connection error: Could not connect to the server. Check if the server is running.',
        );
      } else if (e is FormatException) {
        throw Exception(
          'Format error: The response was not in the expected format.',
        );
      } else if (e is Exception) {
        throw Exception('Error fetching venues: $e');
      } else {
        throw Exception('Unknown error occurred: $e');
      }
    }
  }

  // You can add a method to check if the token is valid
  Future<bool> isTokenValid(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/auth/validate'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }
}
