import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/Pages/feedbackHistory.dart';
import 'firebase_options.dart';
import 'package:flutter_application_1/Pages/FAQ.dart';
import 'package:flutter_application_1/Pages/Feedback.dart';
import 'package:flutter_application_1/Pages/History.dart';
import 'package:flutter_application_1/Pages/News.dart';
import 'package:flutter_application_1/Pages/OnboardingScreen.dart';
import 'package:flutter_application_1/Pages/home_screen.dart';
import 'package:flutter_application_1/Pages/login.dart';
import 'package:flutter_application_1/Pages/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CurrenSee',
      theme: ThemeData(
        primaryColor: const Color(0xFF007BFF),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF007BFF),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF34C759),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.black),
        ),
      ),
      initialRoute: 'OnboardingScreen',
      routes: {
        'login': (context) => Login(),
        'register': (context) => Register(),
        'home': (context) => HomeScreen(),
        'OnboardingScreen': (context) => OnboardingScreen(),
        'faq': (context) => FAQScreen(),
        'feedback': (context) => FeedbackScreen(),
        'News': (context) => ForexNewsScreen(),
        'history': (context) => HistoryScreen(),
        'feedback_history' : (context) => FeedbackHistoryScreen(),
        
        
      },
    );
  }
}
