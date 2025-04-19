import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vishnu_training_and_placements/utils/app_constants.dart';

class TokenService {
  static const String baseUrl = AppConstants.backendUrl;

  Future<bool> checkAndRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('token');
    final refreshToken = prefs.getString('refreshToken');

    if (accessToken == null || refreshToken == null) {
      return false; // Not logged in
    }

    if (_isTokenExpired(accessToken)) {
      if (_isTokenExpired(refreshToken)) {
        return false; // Both expired → login again
      } else {
        return await _refreshToken(refreshToken); // Try refreshing
      }
    }

    return true; // Token valid
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final expiry = payload['exp'];
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      return now >= expiry;
    } catch (e) {
      return true; // Safe fallback
    }
  }

  Future<bool> _refreshToken(String refreshToken) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['accessToken']);
        await prefs.setString('refreshToken', data['refreshToken']);
        return true;
      }
    } catch (e) {
      throw Exception("Refresh Failed: $e");
    }

    return false;
  }
}
