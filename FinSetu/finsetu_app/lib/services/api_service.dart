import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Use different URLs for development and production
  static String get baseUrl {
    if (kDebugMode) {
      // In debug mode, use ngrok URL
      return 'https://e3a4-2409-40c4-32-576-dc2f-bb3d-aea4-367c.ngrok-free.app/api/auth';
    } else {
      // In release mode, use production URL
      return 'https://api.finsetu.com/api/auth';
    }
  }
  
  // Register a new user
  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      print('=== API Registration Request ===');
      print('URL: $baseUrl/register');
      print('Username: $username');
      print('Phone: $phoneNumber');
      
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('=== API Registration Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
          'data': responseData,
        };
      }
    } catch (e) {
      print('=== API Registration Error ===');
      print('Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String userId,
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'phoneNumber': phoneNumber,
          'otp': otp,
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'OTP verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Resend OTP
  static Future<Map<String, dynamic>> resendOtp({
    required String userId,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resend-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'phoneNumber': phoneNumber,
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to resend OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
} 