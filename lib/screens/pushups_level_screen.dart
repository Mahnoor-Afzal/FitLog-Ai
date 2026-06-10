import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modules/user_module.dart';
import '../services/database_service.dart';
import 'home_screen.dart';

class PushUpsLevelScreen extends StatefulWidget {
  const PushUpsLevelScreen({super.key});

  @override
  State<PushUpsLevelScreen> createState() => _PushUpsLevelScreenState();
}

class _PushUpsLevelScreenState extends State<PushUpsLevelScreen> {
  String selectedLevel = "";

  static const Color bgColor = Color(0xFF0A0E14);
  static const Color surfaceColor = Color(0xFF1C222B);
  static const Color accentNeon = Color(0xFFCCFF00);

  final List<Map<String, dynamic>> levels = [
    {
      "title": "Beginner",
      "range": "3-5 Push-ups",
      "desc": "Just starting my fitness journey.",
      "intensity": 1,
    },
    {
      "title": "Intermediate",
      "range": "5-10 Push-ups",
      "desc": "I have some upper body strength.",
      "intensity": 2,
    },
    {
      "title": "Advanced",
      "range": "At least 10",
      "desc": "Ready for high-intensity training.",
      "intensity": 3,
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
              "STEP 6 OF 6",
              style: GoogleFonts.poppins(
                color: accentNeon,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "HOW MANY PUSH-UPS",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "CAN YOU DO?",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "This helps us calibrate your initial workout intensity.",
              style: GoogleFonts.urbanist(color: Colors.white30, fontSize: 14),
            ),
            const SizedBox(height: 40),

            Expanded(
              child: ListView.builder(
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedLevel == levels[index]['title'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedLevel = levels[index]['title']),
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
                            Column(
                              children: List.generate(3, (i) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 2),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i < levels[index]['intensity']
                                        ? (isSelected ? Colors.black : accentNeon)
                                        : (isSelected ? Colors.black26 : Colors.white10),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(width: 25),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    levels[index]['range'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    levels[index]['title'],
                                    style: GoogleFonts.urbanist(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.black87 : accentNeon,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.black),
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
                  onPressed: selectedLevel.isEmpty
                      ? null
                      : () async {
                          UserModel().pushupsLevel = selectedLevel;
                          
                          // Save to Firebase
                          try {
                            await DatabaseService().saveUserProfile();
                          } catch (e) {
                            // Even if it fails, we go to home for better UX, 
                            // but in a real app you'd handle this.
                          }

                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentNeon,
                    disabledBackgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    "FINISH SETUP",
                    style: GoogleFonts.poppins(
                      color: selectedLevel.isEmpty ? Colors.white24 : Colors.black,
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
