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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B00FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        backgroundColor: Color(0xFF0A0A0F),
        body: Center(
          child: Text(
            'RaveCards',
            style: TextStyle(
              color: Color(0xFF8B00FF),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
