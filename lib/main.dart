import 'package:collegeapplication/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

void main() {
  runApp(const SmartDocApp());
}

class SmartDocApp extends StatelessWidget {
  const SmartDocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'SmartDoc',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blueAccent,
          hintColor: Colors.lightBlueAccent,
          fontFamily: 'Inter', // Ensure you have this font or remove/replace
          scaffoldBackgroundColor: Colors.blueGrey[50],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: CardTheme(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              elevation: 4,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueGrey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueGrey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            labelStyle: TextStyle(color: Colors.blueGrey.shade700),
            hintStyle: TextStyle(color: Colors.blueGrey.shade400),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Colors.blueGrey.shade100,
            labelStyle: TextStyle(color: Colors.blueGrey.shade800, fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}