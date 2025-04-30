import 'package:finsetu_app/screens/login_screen.dart';
import 'package:finsetu_app/screens/get_started_screen.dart';
import 'package:finsetu_app/screens/otp_verification_screen.dart';
import 'package:finsetu_app/services/api_service.dart';
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

  // Track error states to show constraints only when needed
  bool _usernameError = false;
  bool _mobileError = false;
  bool _passwordError = false;

  // Add properties to track specific error messages
  String? _usernameErrorMsg;
  String? _mobileErrorMsg;
  String? _passwordErrorMsg;

  // Regular expressions for validation
  final RegExp _usernameRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{3,19}$');
  final RegExp _mobileRegex = RegExp(r'^[0-9]{10}$');
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&+=!])(?!.*\s).{8,20}$'
  );

  // Add color constants for error text
  final Color _errorColor = Colors.red.shade300;

  // Add a focus node for each field to detect focus changes
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    // Add listeners to focus nodes to validate on focus change
    _usernameFocus.addListener(() {
      if (!_usernameFocus.hasFocus) {
        _validateField(_usernameController, 'username');
      }
    });

    _mobileFocus.addListener(() {
      if (!_mobileFocus.hasFocus) {
        _validateField(_mobileController, 'mobile');
      }
    });

    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) {
        _validateField(_passwordController, 'password');
      }
    });
  }

  @override
  void dispose() {
    // Dispose focus nodes
    _usernameFocus.dispose();
    _mobileFocus.dispose();
    _passwordFocus.dispose();

    _usernameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method to validate individual fields without submitting the form
  void _validateField(TextEditingController controller, String fieldType) {
    if (fieldType == 'username') {
      final value = controller.text;
      setState(() {
        if (value.isEmpty) {
          _usernameError = true;
          _usernameErrorMsg = 'Username is required';
        } else if (!_usernameRegex.hasMatch(value)) {
          _usernameError = true;
          if (value.length < 4 || value.length > 20) {
            _usernameErrorMsg = 'Must be 4-20 characters long';
          } else if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
            _usernameErrorMsg = 'Must start with a letter';
          } else {
            _usernameErrorMsg = 'Only letters, numbers, and underscores allowed';
          }
        } else {
          _usernameError = false;
          _usernameErrorMsg = null;
        }
      });
    } else if (fieldType == 'mobile') {
      final value = controller.text;
      setState(() {
        if (value.isEmpty) {
          _mobileError = true;
          _mobileErrorMsg = 'Mobile number is required';
        } else if (!_mobileRegex.hasMatch(value)) {
          _mobileError = true;
          _mobileErrorMsg = 'Must be exactly 10 digits';
        } else {
          _mobileError = false;
          _mobileErrorMsg = null;
        }
      });
    } else if (fieldType == 'password') {
      final value = controller.text;
      setState(() {
        if (value.isEmpty) {
          _passwordError = true;
          _passwordErrorMsg = 'Password is required';
        } else if (value.length < 8 || value.length > 20) {
          _passwordError = true;
          _passwordErrorMsg = 'Must be 8-20 characters long';
        } else if (!_passwordRegex.hasMatch(value)) {
          _passwordError = true;
          if (!RegExp(r'[A-Z]').hasMatch(value)) {
            _passwordErrorMsg = 'Must include at least one uppercase letter';
          } else if (!RegExp(r'[a-z]').hasMatch(value)) {
            _passwordErrorMsg = 'Must include at least one lowercase letter';
          } else if (!RegExp(r'[0-9]').hasMatch(value)) {
            _passwordErrorMsg = 'Must include at least one number';
          } else if (!RegExp(r'[@#$%^&+=!]').hasMatch(value)) {
            _passwordErrorMsg = 'Must include at least one special character (@#\$%^&+=!)';
          } else if (RegExp(r'\s').hasMatch(value)) {
            _passwordErrorMsg = 'Spaces are not allowed';
          }
        } else {
          _passwordError = false;
          _passwordErrorMsg = null;
        }
      });
    }
  }

  Future<void> _registerUser() async {
    // Validate all fields in order
    _validateField(_usernameController, 'username');
    _validateField(_mobileController, 'mobile');
    _validateField(_passwordController, 'password');
    
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

        print('=== Registration Attempt ===');
        print('Username: $username');
        print('Mobile: $mobile');
        print('Password: ${password.replaceAll(RegExp(r'.'), '*')}'); // Mask password for logging

        // Make API call to register user
        final response = await ApiService.registerUser(
          username: username,
          phoneNumber: mobile,
          password: password,
        );

        print('=== Registration Response ===');
        print('Status Code: ${response['success']}');
        print('Message: ${response['message']}');
        print('Data: ${response['data']}');

        // Check mounted before updating state to prevent errors if widget is disposed
        if (!mounted) {
          print('Widget not mounted, returning');
          return;
        }

        setState(() {
          _isLoading = false;
        });

        if (response['success']) {
          print('=== Navigation to OTP Screen ===');
          print('Username: $username');
          print('Mobile: $mobile');
          print('User ID: ${response['data']['id']}');
          
          // Navigate to OTP verification screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                username: username,
                mobile: mobile,
                userId: response['data']['id'].toString(),
              ),
            ),
          );
        } else {
          print('=== Registration Failed ===');
          print('Error: ${response['message']}');
          _showErrorDialog(response['message'] ?? 'Registration failed');
        }
      } catch (error) {
        print('=== Registration Error ===');
        print('Error: $error');
        print('Stack trace: ${StackTrace.current}');
        
        if (!mounted) {
          print('Widget not mounted during error, returning');
          return;
        }
        
        setState(() {
          _isLoading = false;
        });
        
        _showErrorDialog('Registration failed: ${error.toString()}');
      }
    } else {
      print('=== Form Validation Failed ===');
      print('Username error: $_usernameErrorMsg');
      print('Mobile error: $_mobileErrorMsg');
      print('Password error: $_passwordErrorMsg');
    }
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
    const Color helperTextColor = Color(0xFF9E9E9E);

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
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                                        border: Border.all(
                                          color: const Color(0xFFE8FA7A).withOpacity(0.4),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFE8FA7A).withOpacity(0.2),
                                            blurRadius: 25,
                                            spreadRadius: 3,
                                            offset: const Offset(0, 5),
                                          ),
                                          const BoxShadow(
                                            color: Color(0x33000000),
                                            blurRadius: 12,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Background glow effect
                                          Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  const Color(0xFFE8FA7A).withOpacity(0.4),
                                                  const Color(0xFFE8FA7A).withOpacity(0.0),
                                                ],
                                                stops: const [0.1, 1.0],
                                              ),
                                            ),
                                          ),
                                          // Text with gradient
                                          ShaderMask(
                                            blendMode: BlendMode.srcIn,
                                            shaderCallback: (bounds) => const LinearGradient(
                                              colors: [Color(0xFFE8FA7A), Color(0xFFA3E635), Color(0xFF86C332)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              stops: [0.0, 0.7, 1.0],
                                            ).createShader(
                                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "F",
                                                style: TextStyle(
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.w900,
                                                  height: 1,
                                                  shadows: [
                                                    Shadow(
                                                      color: Color(0x60000000),
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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
                            const Center(
                              child: Text(
                                "Register",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30), // Adjusted spacing after removing the line
                          ],
                        ),

                        // Form inputs with spacing matching login screen
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              focusNode: _usernameFocus,
                              textInputAction: TextInputAction.next,  // Use next to move to the next field
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
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: _errorColor, width: 1.5),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: _errorColor, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                helperText: _usernameError ? _usernameErrorMsg : null,
                                helperStyle: TextStyle(color: _usernameError ? _errorColor : helperTextColor, fontSize: 12),
                                errorStyle: TextStyle(color: _errorColor),
                              ),
                              onChanged: (value) {
                                // Don't show errors immediately during typing
                                if (_usernameError) {
                                  _validateField(_usernameController, 'username');
                                }
                              },
                              onEditingComplete: () {
                                _validateField(_usernameController, 'username');
                                _mobileFocus.requestFocus();  // Explicitly request focus on the mobile field
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Username is required';
                                }
                                if (!_usernameRegex.hasMatch(value)) {
                                  if (value.length < 4 || value.length > 20) {
                                    return 'Must be 4-20 characters long';
                                  }
                                  if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
                                    return 'Must start with a letter';
                                  }
                                  return 'Only letters, numbers, and underscores allowed';
                                }
                                return null;
                              },
                              onSaved: (v) { /* Value is already in controller */ },
                              onFieldSubmitted: (_) {
                                _validateField(_usernameController, 'username');
                                _mobileFocus.requestFocus();  // Explicitly request focus on the mobile field
                              },
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _mobileController,
                              focusNode: _mobileFocus,
                              textInputAction: TextInputAction.next,  // Use next to move to the next field
                              style: const TextStyle(color: primaryTextColor),
                              decoration: InputDecoration(
                                prefixIcon: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  margin: const EdgeInsets.only(right: 8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.phone_iphone, color: secondaryTextColor, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        '+91',
                                        style: TextStyle(
                                          color: _mobileFocus.hasFocus ? accentColor : secondaryTextColor, 
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        height: 24,
                                        width: 1,
                                        color: _mobileFocus.hasFocus ? accentColor.withOpacity(0.5) : secondaryTextColor.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
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
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: _errorColor, width: 1.5),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: _errorColor, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                helperText: _mobileError ? _mobileErrorMsg : null,
                                helperStyle: TextStyle(color: _mobileError ? _errorColor : helperTextColor, fontSize: 12),
                                errorStyle: TextStyle(color: _errorColor),
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              onChanged: (value) {
                                if (_mobileError) {
                                  _validateField(_mobileController, 'mobile');
                                }
                              },
                              onEditingComplete: () {
                                _validateField(_mobileController, 'mobile');
                                _passwordFocus.requestFocus();  // Explicitly request focus on the password field
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Mobile number is required';
                                }
                                if (!_mobileRegex.hasMatch(value)) {
                                  return 'Must be exactly 10 digits';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                _validateField(_mobileController, 'mobile');
                                _passwordFocus.requestFocus();  // Explicitly request focus on the password field
                              },
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              textInputAction: TextInputAction.done,  // Use done on the last field
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
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: _errorColor, width: 1.5),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: _errorColor, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                helperText: _passwordError ? _passwordErrorMsg : null,
                                helperStyle: TextStyle(color: _passwordError ? _errorColor : helperTextColor, fontSize: 12),
                                errorStyle: TextStyle(color: _errorColor),
                              ),
                              onChanged: (value) {
                                // Don't show errors immediately during typing
                                if (_passwordError) {
                                  _validateField(_passwordController, 'password');
                                }
                              },
                              onEditingComplete: () {
                                _validateField(_passwordController, 'password');
                                _passwordFocus.unfocus();  // Unfocus to hide keyboard
                                // Optional: trigger signup
                                // _registerUser();
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 8 || value.length > 20) {
                                  return 'Must be 8-20 characters long';
                                }
                                if (!_passwordRegex.hasMatch(value)) {
                                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                    return 'Must include at least one uppercase letter';
                                  }
                                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                                    return 'Must include at least one lowercase letter';
                                  }
                                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                                    return 'Must include at least one number';
                                  }
                                  if (!RegExp(r'[@#$%^&+=!]').hasMatch(value)) {
                                    return 'Must include at least one special character (@#\$%^&+=!)';
                                  }
                                  if (RegExp(r'\s').hasMatch(value)) {
                                    return 'Spaces are not allowed';
                                  }
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                _validateField(_passwordController, 'password');
                                _passwordFocus.unfocus();  // Unfocus to hide keyboard
                                // Optional: trigger signup
                                // _registerUser();
                              },
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
                                : _buildSignUpButton(
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      _registerUser();
                                    },
                                    gradient: mainGradient,
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

  Widget _buildSignUpButton({
    required VoidCallback onPressed,
    required Gradient gradient,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
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
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
