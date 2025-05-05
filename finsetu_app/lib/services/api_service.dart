import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Use different URLs for development and production
  static String get baseUrl {
    if (kDebugMode) {
      return 'https://8be2-2409-40c4-33-b98c-4486-5b6b-ae2-243c.ngrok-free.app';
    } else {
      return 'https://api.finsetu.com';
    }
  }
  
  // Static variable to store the user's ID
  static String? userId;

  // Method to set the user ID after login
  static void setUserId(String id) {
    userId = id;
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
        // Store the user ID
        if (responseData['data'] != null && responseData['data']['id'] != null) {
          setUserId(responseData['data']['id'].toString());
        }
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

  // Get user's groups
  static Future<Map<String, dynamic>> getUserGroups() async {
    try {
      if (userId == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      final url = '$baseUrl/api/groups';
      print('=== Get User Groups Request ===');
      print('URL: $url');
      print('User ID: $userId');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-ID': userId!,
        },
      ).timeout(const Duration(seconds: 10));

      print('=== Get User Groups Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData['data'],
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
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Create a new group
  static Future<Map<String, dynamic>> createGroup({
    required String name,
    required List<String> memberIds,
  }) async {
    try {
      if (userId == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      final url = '$baseUrl/api/groups';
      print('=== Create Group Request ===');
      print('URL: $url');
      print('Name: $name');
      print('Members: $memberIds');
      print('User ID: $userId');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-ID': userId!,
        },
        body: jsonEncode({
          'name': name,
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
          'message': responseData['message'],
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
        'message': 'Network error: ${e.toString()}',
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

      final url = '$baseUrl/api/groups/$groupId';
      print('=== Delete Group Request ===');
      print('URL: $url');
      print('User ID: $userId');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-ID': userId!,
        },
      ).timeout(const Duration(seconds: 10));

      print('=== Delete Group Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'],
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
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
} 