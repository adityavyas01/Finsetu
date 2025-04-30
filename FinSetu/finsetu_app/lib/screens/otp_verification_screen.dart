import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:finsetu_app/screens/login_screen.dart';
import 'package:finsetu_app/screens/home_screen.dart';
import 'package:finsetu_app/services/api_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String username;
  final String mobile;
  final String userId;

  const OtpVerificationScreen({
    super.key,
    required this.username,
    required this.mobile,
    required this.userId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  static const Color inputFillColor = Color(0xFF1E1E1E);
  
  bool _isLoading = false;
  bool _canResendOtp = false;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start countdown for resend OTP button
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _canResendOtp = false;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResendOtp = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      setState(() {
        _isLoading = true;
      });

      try {
        print('=== OTP Verification Attempt ===');
        print('User ID: ${widget.userId}');
        print('Phone: ${widget.mobile}');
        print('OTP: ${_otpController.text}');

        final response = await ApiService.verifyOtp(
          userId: widget.userId,
          phoneNumber: widget.mobile,
          otp: _otpController.text,
        );

        print('=== OTP Verification Response ===');
        print('Success: ${response['success']}');
        print('Message: ${response['message']}');
        print('Data: ${response['data']}');

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (response['success']) {
          print('=== OTP Verification Successful ===');
          print('Navigating to home screen');
          
          // Navigate to home screen and remove all previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false, // Remove all previous routes
          );
        } else {
          print('=== OTP Verification Failed ===');
          print('Error: ${response['message']}');
          _showErrorDialog(response['message'] ?? 'OTP verification failed');
        }
      } catch (error) {
        print('=== OTP Verification Error ===');
        print('Error: $error');
        print('Stack trace: ${StackTrace.current}');
        
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });
        
        _showErrorDialog('OTP verification failed: ${error.toString()}');
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResendOtp) return;

    setState(() => _isLoading = true);

    try {
      // Call API to resend OTP
      final response = await ApiService.resendOtp(
        userId: widget.userId,
        phoneNumber: widget.mobile,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully')),
        );
        // Reset resend timer
        _startResendTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to resend OTP')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend OTP: ${error.toString()}')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Verification Successful'),
        content: Text('User ${widget.username} verified successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to home screen and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
                (route) => false, // Remove all previous routes
              );
            },
            child: const Text('Continue'),
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
    const Color secondaryTextColor = Colors.white70;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'OTP Verification',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // Main header
              const Text(
                "Verification",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Description
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: secondaryTextColor, fontSize: 16),
                  children: [
                    const TextSpan(text: 'Enter the 6-digit code sent to '),
                    TextSpan(
                      text: widget.mobile,
                      style: const TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              
              // OTP input fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => _buildOtpDigitField(index),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Resend OTP section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  GestureDetector(
                    onTap: _canResendOtp ? _resendOtp : null,
                    child: Text(
                      _canResendOtp 
                          ? "RESEND" 
                          : "RESEND in $_resendTimer s",
                      style: TextStyle(
                        color: _canResendOtp ? accentColor : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Verify button
              _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8FA7A)),
                    ),
                  )
                : _buildGradientButton(
                    onPressed: _verifyOtp,
                    gradient: mainGradient,
                    child: const Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpDigitField(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: const TextStyle(color: Colors.white, fontSize: 24),
        decoration: const InputDecoration(
          filled: true,
          fillColor: inputFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xFFE8FA7A), width: 1.5),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to next field
            if (index < 5) {
              _focusNodes[index].unfocus();
              _focusNodes[index + 1].requestFocus();
            }
          } else if (index > 0) {
            // Move to previous field on backspace
            _focusNodes[index].unfocus();
            _focusNodes[index - 1].requestFocus();
          }
        },
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
}
