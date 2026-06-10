import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modules/user_module.dart';
import 'metrics_screen.dart';

class WeeklyGoalScreen extends StatefulWidget {
  const WeeklyGoalScreen({super.key});

  @override
  State<WeeklyGoalScreen> createState() => _WeeklyGoalScreenState();
}

class _WeeklyGoalScreenState extends State<WeeklyGoalScreen> {
  int selectedDays = 4; // Default selection
  String firstDayOfWeek = "SUNDAY";

  // Elite Theme Colors
  static const Color bgColor = Color(0xFF0A0E14);
  static const Color surfaceColor = Color(0xFF1C222B);
  static const Color accentNeon = Color(0xFFCCFF00);

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "STEP 4 OF 6",
                style: GoogleFonts.poppins(
                  color: accentNeon,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "SET YOUR",
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
              Text(
                "WEEKLY GOAL",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "We recommend training at least 3 days weekly for a better result.",
                style: GoogleFonts.urbanist(
                  color: Colors.white30,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              // Section: Weekly training days
              _buildSectionHeader("🎯 Weekly training days"),
              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(7, (index) {
                    int day = index + 1;
                    bool isSelected = selectedDays == day;
                    return GestureDetector(
                      onTap: () => setState(() => selectedDays = day),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: isSelected ? accentNeon : surfaceColor,
                          borderRadius: BorderRadius.circular(15),
                          border: isSelected ? null : Border.all(color: Colors.white10),
                        ),
                        child: Center(
                          child: Text(
                            "$day",
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : Colors.white
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 40),

              // Section: First day of week
              _buildSectionHeader("🗓️ First day of week"),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: firstDayOfWeek,
                    isExpanded: true,
                    dropdownColor: surfaceColor,
                    icon: const Icon(Icons.keyboard_arrow_down, color: accentNeon),
                    style: GoogleFonts.poppins(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    ),
                    items: ["SUNDAY", "MONDAY", "SATURDAY"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value, 
                        child: Text(value)
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => firstDayOfWeek = val!),
                  ),
                ),
              ),

              const SizedBox(height: 60), // Space instead of Spacer()

              // Continue Button
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                    UserModel().weeklyGoal = selectedDays;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MetricsScreen()),
                    );
                  },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentNeon,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      "CONTINUE",
                      style: GoogleFonts.poppins(
                        color: Colors.black, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 18
                      ),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title, 
      style: GoogleFonts.urbanist(
        color: Colors.white70, 
        fontSize: 16, 
        fontWeight: FontWeight.w600
      )
    );
  }
}
