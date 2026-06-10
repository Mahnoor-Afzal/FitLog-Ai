import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitness_tracker_app/modules/user_module.dart';
import 'package:fitness_tracker_app/screens/main_goal_screen.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String selectedGender = "";

  static const Color bgColor = Color(0xFF0A0E14);
  static const Color surfaceColor = Color(0xFF1C222B);
  static const Color accentNeon = Color(0xFFCCFF00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "STEP 1 OF 6",
                style: GoogleFonts.poppins(
                  color: accentNeon,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "TELL US ABOUT",
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
              Text(
                "YOURSELF",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "To personalize your AI workout plan, we need to know your gender.",
                style: GoogleFonts.urbanist(
                  color: Colors.white30,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 50),
              Row(
                children: [
                  Expanded(
                    child: _genderCard(
                      label: "MALE",
                      icon: FontAwesomeIcons.mars,
                      isSelected: selectedGender == "Male",
                      onTap: () => setState(() => selectedGender = "Male"),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _genderCard(
                      label: "FEMALE",
                      icon: FontAwesomeIcons.venus,
                      isSelected: selectedGender == "Female",
                      onTap: () => setState(() => selectedGender = "Female"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: selectedGender.isEmpty
                      ? null
                      : () {
                          UserModel().gender = selectedGender;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainGoalScreen(),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentNeon,
                    disabledBackgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "CONTINUE",
                    style: GoogleFonts.poppins(
                      color: selectedGender.isEmpty ? Colors.white24 : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 180,
        decoration: BoxDecoration(
          color: isSelected ? accentNeon : surfaceColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: isSelected ? Colors.black : Colors.white24,
            ),
            const SizedBox(height: 15),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? Colors.black : Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
