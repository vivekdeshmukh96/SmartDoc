import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:smart_doc/screens/auth_screen.dart'; // your main screen
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3000, // 3 seconds
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo.png', height: 120),
          const SizedBox(height: 20),
          Lottie.asset('assets/loader.json', height: 100), // optional animation
        ],
      ),
      nextScreen: const AuthScreen(),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white,
    );
  }
}
