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
  
  final FocusNode _mobileFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _mobileFocus.dispose();
    _passwordFocus.dispose();
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GetStartedScreen(),
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: darkSurfaceColor,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
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
                            const SizedBox(height: 80),
                            const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _mobileController,
                              focusNode: _mobileFocus,
                              textInputAction: TextInputAction.next,
                              onTap: () {
                                // Remove the automatic +91 prefix addition when field is tapped
                              },
                              style: const TextStyle(color: primaryTextColor),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.phone_iphone, color: secondaryTextColor, size: 20),
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
                                if (txt.trim().isEmpty) return 'Enter mobile number';
                                if (txt.trim().length != 10) return 'Enter a valid 10-digit number';
                                return null;
                              },
                              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                              onSaved: (v) {/* Field validation handled in validator */},
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
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
                              onFieldSubmitted: (_) => _login(),
                              onSaved: (v) { /* no-op since password is not stored */ },
                            ),
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 24),
                          ],
                        ),
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
                                      _login();
                                    },
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
                            const SizedBox(height: 40),
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
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: child,
      ),
    );
  }

  void _navigateBackToSignup(BuildContext context) {
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
        // Get the phone number and password
        final phoneNumber = _mobileController.text.trim();
        final password = _passwordController.text;

        print('=== Login Attempt ===');
        print('Phone: $phoneNumber');
        print('Password: ${password.replaceAll(RegExp(r'.'), '*')}'); // Mask password for logging

        // Call the login API
        final response = await ApiService.loginUser(
          phoneNumber: phoneNumber,
          password: password,
        );

        print('=== Login Response ===');
        print('Success: ${response['success']}');
        print('Message: ${response['message']}');

        if (!mounted) {
          print('Widget not mounted, returning');
          return;
        }
        
        setState(() {
          _isLoading = false;
        });

        if (response['success']) {
          print('=== Login Successful ===');
          print('User Data: ${response['data']}');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Login successful!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
          
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (!mounted) return;
          
          // Navigate to home screen, removing all previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false,
          );
        } else {
          print('=== Login Failed ===');
          print('Error: ${response['message']}');
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        print('=== Login Error ===');
        print('Error: $error');
        print('Stack trace: ${StackTrace.current}');
        
        if (!mounted) {
          print('Widget not mounted during error, returning');
          return;
        }
        
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
