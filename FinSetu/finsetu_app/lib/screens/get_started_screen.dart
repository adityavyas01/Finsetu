import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finsetu_app/screens/signup_page.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  @override
  void initState() {
    super.initState();

    // Set preferred orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style for better contrast
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Define the gradient for the logo text
    const logoGradient = LinearGradient(
      colors: [Color(0xFFE8FA7A), Color(0xFFAADF50)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 1),
              // Logo with FinSetu Text with Hero animation
              Hero(
                tag: 'app_logo',
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
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
                            const BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 15,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        // Apply ShaderMask for gradient text
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => logoGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: const Text(
                            "F",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => logoGradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        child: const Text(
                          "FinSetu",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              const SizedBox(height: 24),
              // Heading with improved styling
              const Text(
                "It's time to\nstart investing",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle with improved styling
              const Text(
                "Build your financial future\nwith insights that work.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              // Feature points with enhanced visuals
              _buildFeatureItem(
                icon: Icons.bar_chart,
                text: "Personalized Portfolio",
                gradient: logoGradient,
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(
                icon: Icons.notifications,
                text: "Real-Time Alerts",
                gradient: logoGradient,
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(
                icon: Icons.smart_toy,
                text: "AI-Powered Suggestions",
                gradient: logoGradient,
              ),
              const Spacer(flex: 2),
              // Get Started Button with improved visuals and page transition
              _buildGradientButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _navigateToSignup(context);
                },
                gradient: logoGradient,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black26,
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Your data is secure with improved visuals
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => logoGradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: const Icon(Icons.shield, size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Your data is secure",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSignup(BuildContext context) {
    // Simple navigation without animations
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupPage(),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required Gradient gradient,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => gradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: Icon(icon, size: 24),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
        borderRadius: BorderRadius.circular(28),
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
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: child,
      ),
    );
  }
}
