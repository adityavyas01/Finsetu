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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
    ));
  }

  @override
  Widget build(BuildContext context) {
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
              const Spacer(),
              // Logo with gradient
              Hero(
                tag: 'app_logo',
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFE8FA7A).withOpacity(0.4),
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE8FA7A).withOpacity(0.25),
                              blurRadius: 35,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => logoGradient.createShader(bounds),
                          child: const Center(
                            child: Text(
                              "F",
                              style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => logoGradient.createShader(bounds),
                        child: const Text(
                          "FinSetu",
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Heading and subtitle
              const Text(
                "It's time to\nstart Analyzing...",
                style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold, height: 1.1),
              ),
              const SizedBox(height: 16),
             
              const SizedBox(height: 32),
              // Feature points
              _buildFeatureItem(icon: Icons.bar_chart, text: "Personalized Portfolio", gradient: logoGradient),
              const SizedBox(height: 16),
              _buildFeatureItem(icon: Icons.notifications, text: "Real-Time Alerts", gradient: logoGradient),
              const SizedBox(height: 16),
              _buildFeatureItem(icon: Icons.smart_toy, text: "AI-Powered Suggestions", gradient: logoGradient),
              const Spacer(flex: 2),
              // Get Started Button
              _buildGradientButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignupPage())),
                gradient: logoGradient,
                child: const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              const SizedBox(height: 16),
              // Data security indication
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => logoGradient.createShader(bounds),
                      child: const Icon(Icons.shield, size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text("Your data is secure", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text, required Gradient gradient}) {
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
            shaderCallback: (bounds) => gradient.createShader(bounds),
            child: Icon(icon, size: 24),
          ),
        ),
        const SizedBox(width: 16),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildGradientButton({required VoidCallback onPressed, required Widget child, required Gradient gradient}) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: const Color(0xFFE8FA7A).withOpacity(0.3), blurRadius: 12)],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}
