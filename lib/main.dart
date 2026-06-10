import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:fitness_tracker_app/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kIsWeb) {
      const String webAppId = "1:686120793392:web:e9da65cb8a9090777604f5"; 
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyD1ZV8UXjdAhDKO0C8kn363XIsf8mZRtXk",
          appId: webAppId,
          messagingSenderId: "686120793392",
          projectId: "fitness-app-new-9be8b",
          storageBucket: "fitness-app-new-9be8b.firebasestorage.app",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFCCFF00),
        scaffoldBackgroundColor: const Color(0xFF0A0E14),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
