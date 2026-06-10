import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitness_tracker_app/modules/user_module.dart';
import 'package:fitness_tracker_app/screens/focus_area_screen.dart';

class MainGoalScreen extends StatefulWidget {
  const MainGoalScreen({super.key});

  @override
  State<MainGoalScreen> createState() => _MainGoalScreenState();
}

class _MainGoalScreenState extends State<MainGoalScreen> {
  String selectedGoal = "";

  static const Color bgColor = Color(0xFF0A0E14);
  static const Color surfaceColor = Color(0xFF1C222B);
  static const Color accentNeon = Color(0xFFCCFF00);

  final List<Map<String, dynamic>> goals = [
    {
      "title": "Lose Weight",
      "desc": "Burn fat and get leaner with high-intensity cardio.",
      "icon": FontAwesomeIcons.fire,
    },
    {
      "title": "Build Muscle",
      "desc": "Gain strength and size with heavy lifting routines.",
      "icon": FontAwesomeIcons.dumbbell,
    },
    {
      "title": "Keep Fit",
      "desc": "Maintain energy and stay healthy for a better lifestyle.",
      "icon": FontAwesomeIcons.heartPulse,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "STEP 2 OF 6",
              style: GoogleFonts.poppins(
                color: accentNeon,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "WHAT IS YOUR",
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            Text(
              "MAIN GOAL?",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedGoal == goals[index]['title'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedGoal = goals[index]['title']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? accentNeon : surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? null : Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              goals[index]['icon'],
                              size: 30,
                              color: isSelected ? Colors.black : accentNeon,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goals[index]['title'].toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    goals[index]['desc'],
                                    style: GoogleFonts.urbanist(
                                      fontSize: 13,
                                      color: isSelected ? Colors.black54 : Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected) const Icon(Icons.check_circle, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: selectedGoal.isEmpty
                      ? null
                      : () {
                          UserModel().goal = selectedGoal;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FocusAreaScreen()),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentNeon,
                    disabledBackgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    "CONTINUE",
                    style: GoogleFonts.poppins(
                      color: selectedGoal.isEmpty ? Colors.white24 : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
