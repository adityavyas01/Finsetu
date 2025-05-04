import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Use different URLs for development and production
  static String get baseUrl {
    if (kDebugMode) {
      // In debug mode, use ngrok URL without /api/auth (it will be added in the endpoint)
      return 'https://05ac-2409-40c4-ee-f184-89f3-927a-556a-f4d0.ngrok-free.app';
    } else {
      // In release mode, use production URL
      return 'https://api.finsetu.com';
    }
  }
  
  // Register a new user
  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final url = '$baseUrl/api/auth/register';
      print('=== API Registration Request ===');
      print('URL: $url');
      print('Username: $username');
      print('Phone: $phoneNumber');
      
      final response = await http.post(
        Uri.parse(url),
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Registration successful',
        };
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Registration failed';
        } catch (e) {
          errorMessage = 'Registration failed: Invalid response from server';
        }
        return {
          'success': false,
          'message': errorMessage,
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
      final url = '$baseUrl/api/auth/verify-otp';
      print('=== OTP Verification Request ===');
      print('URL: $url');
      print('User ID: $userId');
      print('Phone: $phoneNumber');
      print('OTP: $otp');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'userId': userId, // Convert string to int for the backend
          'phoneNumber': phoneNumber,
          'otp': otp,
        }),
      ).timeout(const Duration(seconds: 10));

      print('=== OTP Verification Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'OTP verified successfully',
        };
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'OTP verification failed';
        } catch (e) {
          errorMessage = 'OTP verification failed: Invalid response from server';
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('=== OTP Verification Error ===');
      print('Error: $e');
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

  // Login user
  static Future<Map<String, dynamic>> loginUser({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final url = '$baseUrl/api/auth/login';
      print('=== API Login Request ===');
      print('URL: $url');
      print('Phone: $phoneNumber');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('=== API Login Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Login successful',
        };
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Login failed';
        } catch (e) {
          errorMessage = 'Login failed: Invalid response from server';
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('=== API Login Error ===');
      print('Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
} 