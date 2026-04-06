import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SpaceCoffeeApp(),
    ),
  );
}

class SpaceCoffeeApp extends StatelessWidget {
  const SpaceCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Coffee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4A843),    // dusty gold
          secondary: Color(0xFF8B6914),  // dark amber
          surface: Color(0xFF1A1A2E),    // deep space navy
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
      ),
      home: const HomeScreen(),
    );
  }
}
