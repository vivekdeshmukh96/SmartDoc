import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:smart_doc/screens/role_selection_screen.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showFirst = false;
  bool _showSecond = false;
  bool _showThird = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 300), () => setState(() => _showSecond = true));
    Timer(const Duration(milliseconds: 600), () => setState(() => _showThird = true));
    Timer(const Duration(milliseconds: 100), () => setState(() => _showFirst = true));

  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3000,
      splash: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                opacity: _showFirst ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  transform: Matrix4.translationValues(0, _showFirst ? 0 : -20, 0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _showSecond ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1000),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  transform: Matrix4.translationValues(0, _showSecond ? 0 : -20, 0),
                  child: Column(
                    children: [
                      Text(
                        'SmartDoc',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Lottie.asset(
                        'assets/loader.json',
                        height: 100,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              AnimatedOpacity(
                opacity: _showThird ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
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
}
