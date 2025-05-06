import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static String? userId;
  static const bool isDevelopment = true;

  static String get baseUrl {
    return isDevelopment
        ? 'http://localhost:3000/api'
        : 'https://your-production-url.com/api';
  }

  static void setUserId(String id) {
    userId = id;
    print('User ID set to: $userId');
  }

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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201,
        'data': responseData['data'],
        'message': responseData['message'] ?? 'Registration successful',
      };
    } catch (e) {
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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null && responseData['data']['userId'] != null) {
          setUserId(responseData['data']['userId'].toString());
          print('User ID set to: ${responseData['data']['userId']}');
        } else {
          print('Warning: No user ID in response data');
          print('Response data: $responseData');
        }
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Login successful',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': false,
        'message': responseData['message'] ?? 'Login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get user's groups
  static Future<Map<String, dynamic>> getUserGroups() async {
    if (userId == null) {
      print('Error: No user ID available for fetching groups');
      return {
        'success': false,
        'message': 'User not logged in',
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groups'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Groups fetched successfully',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to fetch groups',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Create a new group
  static Future<Map<String, dynamic>> createGroup({
    required String name,
    required List<String> memberIds,
  }) async {
    if (userId == null) {
      return {
        'success': false,
        'message': 'User not logged in',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/groups'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'memberIds': memberIds,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Group created successfully',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to create group',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Delete a group
  static Future<Map<String, dynamic>> deleteGroup(String groupId) async {
    if (userId == null) {
      return {
        'success': false,
        'message': 'User not logged in',
      };
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/groups/$groupId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Group deleted successfully',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': false,
        'message': responseData['message'] ?? 'Failed to delete group',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Create a new bill in a group
  static Future<Map<String, dynamic>> createBill({
    required String groupId,
    required String title,
    required double amount,
    required String paidBy,
    required List<Map<String, dynamic>> splits,
  }) async {
    try {
      final url = '$baseUrl/api/groups/$groupId/bills';
      print('=== Create Bill Request ===');
      print('URL: $url');
      print('Group ID: $groupId');
      print('Title: $title');
      print('Amount: $amount');
      print('Paid By: $paidBy');
      print('Splits: $splits');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'title': title,
          'amount': amount,
          'paidBy': paidBy,
          'splits': splits,
        }),
      ).timeout(const Duration(seconds: 10));

      print('=== Create Bill Response ===');
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
          errorMessage = errorData['message'] ?? 'Failed to create bill';
        } catch (e) {
          errorMessage = 'Failed to create bill: Invalid response from server';
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('=== Create Bill Error ===');
      print('Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get all bills for a group
  static Future<Map<String, dynamic>> getGroupBills(String groupId) async {
    try {
      final url = '$baseUrl/api/groups/$groupId/bills';
      print('=== Get Group Bills Request ===');
      print('URL: $url');
      print('Group ID: $groupId');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      ).timeout(const Duration(seconds: 10));

      print('=== Get Group Bills Response ===');
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
          errorMessage = errorData['message'] ?? 'Failed to fetch bills';
        } catch (e) {
          errorMessage = 'Failed to fetch bills: Invalid response from server';
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('=== Get Group Bills Error ===');
      print('Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Delete a bill
  static Future<Map<String, dynamic>> deleteBill({
    required String groupId,
    required String billId,
  }) async {
    try {
      final url = '$baseUrl/api/groups/$groupId/bills/$billId';
      print('=== Delete Bill Request ===');
      print('URL: $url');
      print('Group ID: $groupId');
      print('Bill ID: $billId');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      ).timeout(const Duration(seconds: 10));

      print('=== Delete Bill Response ===');
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
          errorMessage = errorData['message'] ?? 'Failed to delete bill';
        } catch (e) {
          errorMessage = 'Failed to delete bill: Invalid response from server';
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('=== Delete Bill Error ===');
      print('Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get bill summary for a group
  static Future<Map<String, dynamic>> getGroupBillSummary(String groupId) async {
    try {
      final url = '$baseUrl/api/groups/$groupId/bills/summary';
      print('=== Get Group Bill Summary Request ===');
      print('URL: $url');
      print('Group ID: $groupId');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      ).timeout(const Duration(seconds: 10));

      print('=== Get Group Bill Summary Response ===');
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
          errorMessage = errorData['message'] ?? 'Failed to fetch bill summary';
        } catch (e) {
          errorMessage = 'Failed to fetch bill summary: Invalid response from server';
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('=== Get Group Bill Summary Error ===');
      print('Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Static variable to store the user's token
  static String? userToken;

  // Method to set the token after login
  static void setToken(String token) {
    userToken = token;
  }
} 