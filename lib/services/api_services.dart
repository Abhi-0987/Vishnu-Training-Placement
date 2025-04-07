import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://localhost:8080";

  static Future<List<String>> fetchAbsentees() async {
    try {
      print("Fetching absentees from: $baseUrl/api/whatsapp/numbers");
      final response = await http.get(
        Uri.parse('$baseUrl/api/whatsapp/numbers'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<String>().toList();
      } else {
        throw Exception(
          "Failed to load phone numbers. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Error fetching numbers: $e");
      throw Exception("Failed to connect to server");
    }
  }

  static Future<bool> checkServerConnection() async {
    try {
      print("Checking server connection at $baseUrl");
      final response = await http
          .get(Uri.parse('$baseUrl/'))
          .timeout(const Duration(seconds: 5));
      print("Server response: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("Server connection error: $e");
      return false;
    }
  }

  static Future<String> sendBulkMessages(
    List<String> phoneNumbers,
    String message,
  ) async {
    int successCount = 0;
    int failureCount = 0;

    try {
      print("Starting bulk message send to ${phoneNumbers.length} numbers");

      for (var phoneNumber in phoneNumbers) {
        try {
          print("Sending message to: $phoneNumber");
          final response = await http.post(
            Uri.parse('$baseUrl/api/whatsapp/send'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phone': phoneNumber,
              'message': message,
              'type': 'whatsapp',
            }),
          );

          print("Response status: ${response.statusCode}");
          print("Response body: ${response.body}");

          if (response.statusCode == 200) {
            successCount++;
          } else {
            failureCount++;
            var errorMessage = "Unknown error";
            try {
              var jsonResponse = json.decode(response.body);
              errorMessage = jsonResponse['error'] ?? errorMessage;
            } catch (e) {
              print("Error parsing error response: $e");
            }
            print("Failed to send message: $errorMessage");
          }
        } catch (e) {
          failureCount++;
          print("Error sending message to $phoneNumber: $e");
        }
      }

      String resultMessage = "Messages sent: $successCount successful";
      if (failureCount > 0) {
        resultMessage += ", $failureCount failed";
      }
      return resultMessage;
    } catch (e) {
      print("Bulk send error: $e");
      throw Exception('Error sending messages: ${e.toString()}');
    }
  }
}
