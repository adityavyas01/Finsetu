import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finsetu_app/screens/login_screen.dart';
import 'dart:async';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // Controllers
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6, 
    (index) => TextEditingController()
  );
  final _formKey = GlobalKey<FormState>();

  // Track the current step in the password reset flow
  // 0 = Phone entry, 1 = OTP verification, 2 = New password
  int _currentStep = 0;
  
  // Password visibility toggles
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // OTP countdown timer
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResendOTP = false;

  @override
  void initState() {
    super.initState();
    _mobileController.text = '+91 ';
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startOTPTimer() {
    _secondsRemaining = 60;
    _canResendOTP = false;
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _canResendOTP = true;
            timer.cancel();
          }
        });
      },
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
    const Color darkSurfaceColor = Colors.black;

    return Scaffold(
      backgroundColor: darkSurfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          _getStepTitle(),
          style: const TextStyle(
            color: primaryTextColor,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => mainGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: Text(
                    _getStepTitle(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getStepDescription(),
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Display appropriate step content
                _buildStepContent(
                  inputFillColor: inputFillColor,
                  accentColor: accentColor,
                  secondaryTextColor: secondaryTextColor,
                  primaryTextColor: primaryTextColor
                ),
                
                const SizedBox(height: 40),
                
                // Action Button
                Container(
                  decoration: BoxDecoration(
                    gradient: mainGradient,
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
                    onPressed: () => _handleStepAction(context),
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
                    child: Text(
                      _getActionButtonText(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                
                // "Resend OTP" button for OTP step
                if (_currentStep == 1) _buildResendOTPSection(secondaryTextColor, accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return "Verify Mobile";
      case 1:
        return "Enter OTP";
      case 2:
        return "Reset Password";
      default:
        return "Reset Password";
    }
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return "Enter your registered mobile number to receive a verification code.";
      case 1:
        return "Enter the 6-digit code sent to ${_mobileController.text}";
      case 2:
        return "Create a new password for your account.";
      default:
        return "";
    }
  }

  String _getActionButtonText() {
    switch (_currentStep) {
      case 0:
        return "Send OTP";
      case 1:
        return "Verify";
      case 2:
        return "Reset Password";
      default:
        return "Next";
    }
  }
  
  Widget _buildStepContent({
    required Color inputFillColor,
    required Color accentColor, 
    required Color secondaryTextColor, 
    required Color primaryTextColor
  }) {
    switch (_currentStep) {
      case 0:
        return _buildMobileInputStep(inputFillColor, accentColor, secondaryTextColor, primaryTextColor);
      case 1:
        return _buildOTPVerificationStep(inputFillColor, accentColor, secondaryTextColor, primaryTextColor);
      case 2:
        return _buildNewPasswordStep(inputFillColor, accentColor, secondaryTextColor, primaryTextColor);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMobileInputStep(
    Color inputFillColor, 
    Color accentColor, 
    Color secondaryTextColor, 
    Color primaryTextColor
  ) {
    return TextFormField(
      controller: _mobileController,
      onTap: () {
        if (_mobileController.text.isEmpty) {
          _mobileController.text = '+91 ';
          _mobileController.selection = TextSelection.collapsed(offset: _mobileController.text.length);
        }
      },
      style: TextStyle(color: primaryTextColor),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.phone_iphone, color: secondaryTextColor),
        filled: true,
        fillColor: inputFillColor,
        hintText: 'Mobile Number',
        hintStyle: TextStyle(color: secondaryTextColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 1.5),
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
    );
  }

  Widget _buildOTPVerificationStep(
    Color inputFillColor, 
    Color accentColor, 
    Color secondaryTextColor, 
    Color primaryTextColor
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (index) {
              // Create a separate focus node for each OTP field
              final focusNode = FocusNode();
              
              return SizedBox(
                width: 45,
                child: TextFormField(
                  controller: _otpControllers[index],
                  focusNode: focusNode,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  decoration: InputDecoration(
                    counter: const Offstage(),
                    filled: true,
                    fillColor: inputFillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                  onChanged: (value) {
                    // Avoid immediate focus changes to prevent keyboard flicker
                    if (value.isNotEmpty && index < 5) {
                      // Use a more reliable approach to change focus
                      focusNode.unfocus();
                      // Add a short delay before changing focus to next field
                      Future.delayed(const Duration(milliseconds: 100), () {
                        FocusScope.of(context).requestFocus(_otpControllers[index + 1].focusNode);
                      });
                    } else if (value.isEmpty && index > 0) {
                      // Go to previous field when backspacing
                      focusNode.unfocus();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        FocusScope.of(context).requestFocus(_otpControllers[index - 1].focusNode);
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    }
                    return null;
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep(
    Color inputFillColor, 
    Color accentColor, 
    Color secondaryTextColor, 
    Color primaryTextColor
  ) {
    return Column(
      children: [
        // New Password field
        TextFormField(
          controller: _newPasswordController,
          style: TextStyle(color: primaryTextColor),
          obscureText: _obscureNewPassword,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline, color: secondaryTextColor),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? 
                  Icons.visibility_off_outlined : 
                  Icons.visibility_outlined, 
                color: secondaryTextColor
              ),
              onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
            ),
            filled: true,
            fillColor: inputFillColor,
            hintText: 'New Password',
            hintStyle: TextStyle(color: secondaryTextColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        
        // Confirm Password field
        TextFormField(
          controller: _confirmPasswordController,
          style: TextStyle(color: primaryTextColor),
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline, color: secondaryTextColor),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? 
                  Icons.visibility_off_outlined : 
                  Icons.visibility_outlined, 
                color: secondaryTextColor
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            filled: true,
            fillColor: inputFillColor,
            hintText: 'Confirm Password',
            hintStyle: TextStyle(color: secondaryTextColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _newPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildResendOTPSection(Color secondaryTextColor, Color accentColor) {
    const mainGradient = LinearGradient(
      colors: [Color(0xFFE8FA7A), Color(0xFFAADF50)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _canResendOTP ? "Didn't receive the code? " : "Resend code in $_secondsRemaining seconds",
            style: TextStyle(color: secondaryTextColor, fontSize: 14),
          ),
          if (_canResendOTP)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _startOTPTimer();
                // Here we would actually resend the OTP in a real app
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => mainGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: const Text(
                  "Resend",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleStepAction(BuildContext context) {
    HapticFeedback.mediumImpact();
    
    // Hide keyboard when moving between steps to prevent UI issues
    FocusScope.of(context).unfocus();
    
    if (_formKey.currentState!.validate()) {
      switch (_currentStep) {
        case 0:
          // Request OTP for the entered mobile number
          setState(() {
            _currentStep = 1;
            _startOTPTimer();
          });
          break;
        case 1:
          // Check if all OTP fields have values
          bool allOTPFilled = _otpControllers.every((controller) => controller.text.isNotEmpty);
          
          if (!allOTPFilled) {
            // Show a snackbar if OTP is incomplete
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter the complete 6-digit OTP'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          
          // Proceed to password reset screen
          setState(() {
            _currentStep = 2;
          });
          break;
        case 2:
          // Reset password
          _showPasswordResetSuccessDialog(context);
          break;
      }
    }
  }

  void _showPasswordResetSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFFAADF50),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Password Reset Successful',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your password has been updated successfully. Please use your new password to login.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to login screen
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8FA7A),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension on TextEditingController {
  FocusNode? get focusNode => null;
}
