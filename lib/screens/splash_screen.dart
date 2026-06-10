import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_tracker_app/screens/gender_selection_screen.dart';
import 'package:fitness_tracker_app/screens/home_screen.dart';
import 'package:fitness_tracker_app/services/database_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    // Wait for animation
    await Future.delayed(const Duration(seconds: 3));

    // Check if user profile exists
    final profile = await DatabaseService().getUserProfile();

    if (!mounted) return;

    if (profile != null) {
      // User already completed onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // First time user
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GenderSelectionScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCCFF00), width: 2),
                ),
                child: const Icon(
                  Icons.bolt,
                  size: 80,
                  color: Color(0xFFCCFF00),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "FITNESS AI",
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Transforming Lives with AI",
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: Colors.white54,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              color: Color(0xFFCCFF00),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
