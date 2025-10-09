import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/scanner_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'SmartDoc',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ScannerScreen(), // Temporarily set to ScannerScreen for development
      ),
    );
  }
}
