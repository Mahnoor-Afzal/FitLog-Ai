import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitness_tracker_app/modules/user_module.dart';
import 'package:fitness_tracker_app/screens/weekly_goal_screen.dart';

class FocusAreaScreen extends StatefulWidget {
  const FocusAreaScreen({super.key});

  @override
  State<FocusAreaScreen> createState() => _FocusAreaScreenState();
}

class _FocusAreaScreenState extends State<FocusAreaScreen> {
  // List to store selected focus areas
  List<String> selectedAreas = [];

  final List<Map<String, dynamic>> areas = [
    {"name": "Full Body", "icon": FontAwesomeIcons.person},
    {"name": "Arms", "icon": FontAwesomeIcons.dumbbell},
    {"name": "Chest", "icon": FontAwesomeIcons.personRunning},
    {"name": "Abs", "icon": FontAwesomeIcons.child},
    {"name": "Legs", "icon": FontAwesomeIcons.shoePrints},
  ];

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0A0E14);
    const Color surfaceColor = Color(0xFF1C222B);
    const Color accentNeon = Color(0xFFCCFF00);

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
              "STEP 3 OF 6",
              style: GoogleFonts.poppins(
                color: accentNeon,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text("WHAT IS YOUR",
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16, letterSpacing: 2)),
            Text("FOCUS AREA?",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // --- List of Focus Areas (Horizontal style like Main Goal) ---
            Expanded(
              child: ListView.builder(
                itemCount: areas.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedAreas.contains(areas[index]['name']);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedAreas.remove(areas[index]['name']);
                          } else {
                            selectedAreas.add(areas[index]['name']);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: isSelected ? accentNeon : surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? null : Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              areas[index]['icon'],
                              size: 28,
                              color: isSelected ? Colors.black : accentNeon,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                areas[index]['name'].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isSelected ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.black,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // --- Continue Button ---
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: selectedAreas.isEmpty ? null : () {
                    UserModel().focusArea = selectedAreas.join(", ");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WeeklyGoalScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentNeon,
                    disabledBackgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("CONTINUE",
                      style: GoogleFonts.poppins(
                          color: selectedAreas.isEmpty ? Colors.white24 : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
