import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

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
  String baseUrl = AppConstants.backendUrl;

  Future<List<Venue>> fetchVenues() async {
    try {
      // Get the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final apiUrl = '$baseUrl/api/venues';

      // Don't add CORS headers from the client side - they need to come from the server
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> venuesJson = jsonDecode(response.body);
        return venuesJson.map((json) => Venue.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load venues: ${response.body}');
      }
    } catch (e) {
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
}
