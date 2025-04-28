import 'package:finsetu_app/screens/login_screen.dart';
import 'package:finsetu_app/screens/get_started_screen.dart';
import 'package:finsetu_app/screens/otp_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      setState(() {
        _isLoading = true;
      });

      try {
        // Get values from controllers
        final username = _usernameController.text.trim();
        final mobile = _mobileController.text.trim();
        final password = _passwordController.text.trim();

        // Make API call to register user but ensure it's not blocking the UI
        final response = await _registerUserAPI(username, mobile, password);

        // Check mounted before updating state to prevent errors if widget is disposed
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (response['success']) {
          // Navigate to OTP verification screen instead of showing success dialog
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                username: username,
                mobile: mobile,
                userId: response['data']['user_id'],
              ),
            ),
          );
        } else {
          _showErrorDialog(response['message'] ?? 'Registration failed');
        }
      } catch (error) {
        // Check mounted before updating state
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        _showErrorDialog('An unexpected error occurred: ${error.toString()}');
      }
    }
  }

  Future<Map<String, dynamic>> _registerUserAPI(
      String username,
      String mobile,
      String password) async {
    // For development, use a mock response instead of hitting a real API endpoint
    // Remove this and use the real API call when the backend is ready
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    
    // Mock success response for development testing
    return {
      'success': true,
      'data': {
        'user_id': '12345',
        'username': username,
        'message': 'Registration successful. Please verify OTP.'
      },
    };
    
    // Comment out the actual API implementation until backend is ready
    /*
    // Replace with your actual API endpoint when ready
    const String apiUrl = 'https://api.finsetu.com/register';

    try {
      // Add timeout to prevent indefinite waiting
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'mobile': mobile.replaceAll('+91 ', '').trim(), // Remove country code prefix
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('The connection has timed out. Please try again.');
      });

      // Parse the response
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Unknown error occurred',
        };
      }
    } catch (e) {
      // Handle network errors properly
      if (e is TimeoutException) {
        return {
          'success': false,
          'message': 'Connection timed out. Please try again.',
        };
      } else if (e is SocketException) {
        return {
          'success': false, 
          'message': 'No internet connection. Please check your network.',
        };
      } else if (e is FormatException) {
        return {
          'success': false,
          'message': 'Invalid response format from server.',
        };
      }

      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
    */
  }

  void _showErrorDialog(String errorMsg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Registration Failed'),
        content: Text(errorMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const mainGradient = LinearGradient(
      colors: [Color(0xFFE8FA7A), Color(0xFFAADF50)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    const Color accentColor = Color(0xFFE8FA7A);
    const Color primaryTextColor = Colors.white;
    const Color secondaryTextColor = Colors.white70;
    const Color inputFillColor = Color(0xFF1E1E1E);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GetStartedScreen(),
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top section - Logo and header (matching login screen structure)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // Logo in same position as login screen
                            Hero(
                              tag: 'app_logo',
                              child: Material(
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFE8FA7A).withOpacity(0.15),
                                            blurRadius: 25,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ShaderMask(
                                        blendMode: BlendMode.srcIn,
                                        shaderCallback: (bounds) => mainGradient.createShader(
                                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                        ),
                                        child: const Text(
                                          "F",
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) => mainGradient.createShader(
                                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                      ),
                                      child: const Text(
                                        "FinSetu",
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 70),
                            const Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Please register to login.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 30), // Added more space here between "Please register" and username field
                          ],
                        ),

                        // Form inputs with spacing matching login screen
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: primaryTextColor),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_outline, color: secondaryTextColor),
                                filled: true,
                                fillColor: inputFillColor,
                                hintText: 'Username',
                                hintStyle: const TextStyle(color: secondaryTextColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: accentColor, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (v) => v != null && v.isNotEmpty ? null : 'Enter a username',
                              onSaved: (v) { /* Value is already in controller */ },
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _mobileController,
                              onTap: () {
                                if (_mobileController.text.isEmpty) {
                                  _mobileController.text = '+91 ';
                                  _mobileController.selection = TextSelection.collapsed(offset: _mobileController.text.length);
                                }
                              },
                              style: const TextStyle(color: primaryTextColor),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.phone_iphone, color: secondaryTextColor),
                                filled: true,
                                fillColor: inputFillColor,
                                hintText: 'Mobile Number',
                                hintStyle: const TextStyle(color: secondaryTextColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: accentColor, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                final txt = v ?? '';
                                if (!txt.startsWith('+91 ') || txt.trim() == '+91') return 'Enter mobile number';
                                final num = txt.replaceFirst('+91 ', '').trim();
                                if (num.length != 10) return 'Enter a valid 10-digit number';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _passwordController,
                              style: const TextStyle(color: primaryTextColor),
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline, color: secondaryTextColor),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: secondaryTextColor),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                filled: true,
                                fillColor: inputFillColor,
                                hintText: 'Password',
                                hintStyle: const TextStyle(color: secondaryTextColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: accentColor, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                        // Buttons and footer matching login screen spacing
                        Column(
                          children: [
                            const SizedBox(height: 40),
                            _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8FA7A)),
                                    ),
                                  )
                                : _buildGradientButton(
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      _registerUser();
                                    },
                                    gradient: mainGradient,
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 40),
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: secondaryTextColor, fontSize: 14),
                                  children: [
                                    const TextSpan(text: 'Already have account? '),
                                    TextSpan(
                                      text: 'Sign In',
                                      style: const TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _navigateToLogin(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required Widget child,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8FA7A).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: child,
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}
