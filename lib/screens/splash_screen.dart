import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:smart_doc/screens/role_selection_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLogo = false;
  bool _showText = false;
  bool _isTypingAnimationFinished = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 300), () => setState(() => _showLogo = true));
    Timer(const Duration(milliseconds: 1000), () => setState(() => _showText = true));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 4000,
      splash: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: _showLogo ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                ),
              ),
              const SizedBox(height: 25),
              if (_showText)
                _isTypingAnimationFinished
                    ? _buildRichText()
                    : _buildAnimatedText(),
              const SizedBox(height: 30),
              Lottie.asset(
                'assets/loader.json',
                height: 80,
              ),
            ],
          ),
        ),
      ),
      nextScreen: const RoleSelectionScreen(),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedTextKit(
      isRepeatingAnimation: false,
      animatedTexts: [
        TypewriterAnimatedText(
          'SmartDoc',
          speed: const Duration(milliseconds: 150),
          cursor: '|',
          textStyle: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E), // Initial color
            letterSpacing: 1.5,
          ),
        ),
      ],
      onFinished: () {
        setState(() {
          _isTypingAnimationFinished = true;
        });
      },
    );
  }

  Widget _buildRichText() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        children: <TextSpan>[
          TextSpan(
            text: 'Smart',
            style: TextStyle(color: Color(0xFF1A237E)), // Dark Navy Blue
          ),
          TextSpan(
            text: 'Doc',
            style: TextStyle(color: Color(0xFF03A9F4)), // Sky Blue
          ),
        ],
      ),
    );
  }
}
