import 'package:flutter/material.dart';
import 'package:rhs/home.dart';
import 'package:rhs/numbers.dart';
import 'package:rhs/rhs.dart';
import 'package:rhs/wanderer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RHS',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.tealAccent, 
        scaffoldBackgroundColor: Color(0xFF121212), 
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.white70, 
            fontWeight: FontWeight.w500,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.white70, 
            fontWeight: FontWeight.w400,
          ),
          displayMedium: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.tealAccent, 
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212), 
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, 
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.tealAccent, 
          textTheme: ButtonTextTheme.primary, 
        ),
      ),
      routes: {
        '/': (context) => const Home(),
        '/home': (context) => const Home(),
        '/rhs': (context) => const RHSScreen(),
        '/wanderer': (context) => const WandererScreen(),
        '/phone': (context) => const ContactScreen(),
      },
    );
  }
}
