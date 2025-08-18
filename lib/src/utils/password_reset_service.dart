import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordResetService {
  static const String baseUrl = 'https://lsa-reset.onrender.com';
  static const String apiKey = 'LsaSupaResetPass47';
  
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final url = Uri.parse('$baseUrl/admin/reset-password');
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };
      
      final body = json.encode({
        'email': email,
      });
      
      print('Sending password reset request to: $url');
      print('Headers: $headers');
      print('Body: $body');
      
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['detail'] ?? 'Password reset failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Error in password reset: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
}
