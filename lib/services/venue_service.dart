import 'dart:convert';
import 'package:http/http.dart' as http;

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
  // Base URL for your Spring Boot backend
  final String baseUrl = 'http://10.0.2.2:8080'; // Use this for Android emulator
  // For physical devices or iOS simulator, use your actual IP address
  // final String baseUrl = 'http://192.168.1.X:8080';

  Future<List<Venue>> fetchVenues() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/venues'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> venuesJson = jsonDecode(response.body);
        return venuesJson.map((json) => Venue.fromJson(json)).toList();
      } else {
        print('Failed to load venues: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load venues');
      }
    } catch (e) {
      print('Error fetching venues: $e');
      throw Exception('Error fetching venues: $e');
    }
  }
}