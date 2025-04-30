import 'package:finsetu_app/screens/signup_page.dart';
import 'package:finsetu_app/screens/get_started_screen.dart';
import 'package:finsetu_app/screens/home_screen.dart';
import 'package:finsetu_app/screens/reset_password_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finsetu_app/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    const Color darkSurfaceColor = Colors.black;

    return WillPopScope(
      onWillPop: () async {
        // Navigate to get started page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GetStartedScreen(),
          ),
        );
        return false; // Prevents default back button behavior
      },
      child: Scaffold(
        backgroundColor: darkSurfaceColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top - 
                    kToolbarHeight,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top section - Logo and header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Logo
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
                                    "FinSetu",  // Reverted back to original text without space
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
                        const SizedBox(height: 70), // Increased spacing from 50 to 70
                        // Heading Text
                        const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28, // Reduced from 32
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16), // Slightly increased
                        // Subtitle
                        const Text(
                          "Please sign in to continue.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    
                    // Middle section - Form fields
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mobile number field
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
                          onSaved: (v) {/* Field validation handled in validator */},
                        ),
                        const SizedBox(height: 24), // Increased spacing
                        // Password field
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
                          onSaved: (v) { /* no-op since password is not stored */ },
                        ),
                        const SizedBox(height: 16),
                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ResetPasswordScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) => mainGradient.createShader(
                                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                              ),
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Bottom section - Buttons and links
                    Column(
                      children: [
                        const SizedBox(height: 40), // More spacing before button
                        // Sign In Button
                        _buildGradientButton(
                          onPressed: _login,
                          gradient: mainGradient,
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32), // Increased spacing
                        // OR divider
                        const Row(
                          children: [
                            Expanded(child: Divider(color: secondaryTextColor)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('OR', style: TextStyle(color: secondaryTextColor)),
                            ),
                            Expanded(child: Divider(color: secondaryTextColor)),
                          ],
                        ),
                        const SizedBox(height: 32), // Increased spacing
                        // Google Sign-in button
                        // Center(
                        //   child: _buildGoogleButton(
                        //     onPressed: () {
                        //       HapticFeedback.lightImpact();
                        //     },
                        //   ),
                        // ),
                        const SizedBox(height: 40), // More bottom padding
                        // Don't have an account
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: secondaryTextColor, fontSize: 14),
                              children: [
                                const TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: const TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _navigateBackToSignup(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24), // Padding at bottom
                      ],
                    ),
                  ],
                ),
              ),
            ),
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

  // Widget _buildGoogleButton({
  //   required VoidCallback onPressed,
  // }) {
  //   return ElevatedButton.icon(
  //     onPressed: onPressed,
  //     icon: Image.asset(
  //       'assets/images/google_logo.png',
  //       height: 20.0,
  //       width: 20.0,
  //     ),
  //     label: const Text('Sign in with Google'),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.white,
  //       foregroundColor: Colors.black87,
  //       minimumSize: const Size(280, 46),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         side: BorderSide(color: Colors.white.withOpacity(0.1)),
  //       ),
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
  //     ),
  //   );
  // }

  void _navigateBackToSignup(BuildContext context) {
    // Function remains for the "Sign Up" text button at the bottom
    // but now it just navigates to SignupPage without the "back" behavior
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupPage(),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      setState(() {
        _isLoading = true;
      });

      try {
        final mobile = _mobileController.text.replaceFirst('+91 ', '').trim();
        final password = _passwordController.text.trim();

        print('Attempting to login user: $mobile'); // Debug log

        // Make API call to login
        final response = await ApiService.login(
          phoneNumber: mobile,
          password: password,
        );

        print('Login response: $response'); // Debug log

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        if (response['success']) {
          print('Login successful, navigating to home screen'); // Debug log
          // Navigate to home screen and remove all previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false, // Remove all previous routes
          );
        } else {
          print('Login failed: ${response['message']}'); // Debug log
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Login failed')),
          );
        }
      } catch (error) {
        print('Login error: $error'); // Debug log
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${error.toString()}')),
        );
      }
    }
  }
}
