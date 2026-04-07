import 'package:flutter/material.dart';

void main() {
  runApp(const RaveCardsApp());
}

class RaveCardsApp extends StatelessWidget {
  const RaveCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RaveCards',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB300FF)),
        scaffoldBackgroundColor: const Color(0xFF06000F),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'RAVECARDS',
            style: TextStyle(color: Color(0xFFB300FF), letterSpacing: 5),
          ),
        ),
      ),
    );
  }
}
