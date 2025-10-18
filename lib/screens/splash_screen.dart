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

  @override
  void initState() {
    super.initState();

    // Step 1: Show logo with pop-up animation
    Timer(const Duration(milliseconds: 300), () {
      setState(() => _showLogo = true);
    });

    // Step 2: Show "SmartDoc" typing effect after logo appears
    Timer(const Duration(milliseconds: 1000), () {
      setState(() => _showText = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3500,
      splash: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Logo Pop-up Animation
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

            // 🔹 Typing Effect for SmartDoc Text
            if (_showText)
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                  letterSpacing: 1.5,
                ),
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'SmartDoc',
                      speed: Duration(milliseconds: 150),
                      cursor: '|',
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // 🔹 Lottie Loader
            Lottie.asset(
              'assets/loader.json',
              height: 80,
            ),
          ],
        ),
      ),
      nextScreen: const RoleSelectionScreen(),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white,
    );
  }
}
