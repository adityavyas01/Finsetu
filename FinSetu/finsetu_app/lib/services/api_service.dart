import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static String? _baseUrl;
  static String? _currentUserId;

  // Use different URLs for development and production
  static String get baseUrl {
    if (kDebugMode) {
      // In debug mode, use ngrok URL
      return 'https://7584-2409-40c4-ef-d547-4591-8a56-c763-d198.ngrok-free.app/api';
    } else {
      // In release mode, use production URL
      return 'https://api.finsetu.com/api';
    }
  }
  
  // Static variable to store the user's ID
  static String? userId;

  // Method to set the user ID after login
  static void setUserId(String id) {
    userId = id;
    print('Setting user ID: $id');
  }

  // Get headers with user ID
  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (userId != null) 'X-User-ID': userId!,
    };
  }

  // Register a new user
  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final url = '$baseUrl/auth/register';
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
          'data': responseData['data'],
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
        'message': 'Network error: $e',
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
      final url = '$baseUrl/auth/verify-otp';
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
          'userId': userId,
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
          'data': responseData['data'],
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
        'message': 'Network error: $e',
      };
    }
  }

  // Resend OTP
  static Future<Map<String, dynamic>> resendOtp({
    required String userId,
    required String phoneNumber,
  }) async {
    try {
      final url = '$baseUrl/auth/resend-otp';
      print('=== Resend OTP Request ===');
      print('URL: $url');
      print('User ID: $userId');
      print('Phone: $phoneNumber');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'phoneNumber': phoneNumber,
        }),
      ).timeout(const Duration(seconds: 10));

      print('=== Resend OTP Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'OTP resent successfully',
        };
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Failed to resend OTP';
        } catch (e) {
          errorMessage = 'Failed to resend OTP: Invalid response from server';
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('=== Resend OTP Error ===');
      print('Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> loginUser({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final url = '$baseUrl/auth/login';
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
        if (responseData['data'] != null && responseData['data']['userId'] != null) {
          setUserId(responseData['data']['userId'].toString());
          print('User ID set to: ${responseData['data']['userId']}');
        } else {
          print('Warning: No user ID in response data');
        }
        return {
          'success': true,
          'data': responseData['data'],
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
        'message': 'Network error: $e',
      };
    }
  }

  // Get user's groups
  static Future<Map<String, dynamic>> getUserGroups() async {
    try {
      if (userId == null) {
        print('Error: User ID is null when trying to get groups');
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      final url = '$baseUrl/groups';
      print('=== Get User Groups Request ===');
      print('URL: $url');
      print('User ID: $userId');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      print('=== Get User Groups Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Groups fetched successfully',
        };
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Failed to fetch groups';
        } catch (e) {
          errorMessage = 'Failed to fetch groups: Invalid response from server';
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('=== Get User Groups Error ===');
      print('Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Create a new group
  static Future<Map<String, dynamic>> createGroup({
    required String name,
    required String description,
    required List<String> memberIds,
  }) async {
    try {
      if (userId == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      final url = '$baseUrl/groups';
      print('=== Create Group Request ===');
      print('URL: $url');
      print('Name: $name');
      print('Description: $description');
      print('Members: $memberIds');
      print('User ID: $userId');
      
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'description': description,
          'members': memberIds,
        }),
      ).timeout(const Duration(seconds: 10));

      print('=== Create Group Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Group created successfully',
        };
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Failed to create group';
        } catch (e) {
          errorMessage = 'Failed to create group: Invalid response from server';
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('=== Create Group Error ===');
      print('Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Delete a group
  static Future<Map<String, dynamic>> deleteGroup(String groupId) async {
    try {
      if (userId == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      final url = '$baseUrl/groups/$groupId';
      print('=== Delete Group Request ===');
      print('URL: $url');
      print('User ID: $userId');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      print('=== Delete Group Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Group deleted successfully',
        };
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Failed to delete group';
        } catch (e) {
          errorMessage = 'Failed to delete group: Invalid response from server';
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('=== Delete Group Error ===');
      print('Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get all users
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final url = '$baseUrl/users/all';
      print('=== Get All Users Request ===');
      print('URL: $url');
      print('Headers: $_headers');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      print('=== Get All Users Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Users fetched successfully',
        };
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Failed to fetch users';
        } catch (e) {
          errorMessage = 'Failed to fetch users: Invalid response from server';
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('=== Get All Users Error ===');
      print('Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
} 