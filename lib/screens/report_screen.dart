import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'profile_screen.dart';
import '../modules/user_module.dart';
import '../services/database_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const Color bgColor = Color(0xFF0A0E14);
  static const Color surfaceColor = Color(0xFF1C222B);
  static const Color accentNeon = Color(0xFFCCFF00);

  Stream<QuerySnapshot>? _weightStream;

  @override
  void initState() {
    super.initState();
    _weightStream = DatabaseService().getWeightHistory();
  }

  String calculateBMI() {
    try {
      double weight = UserModel().weight ?? 0.0;
      double height = UserModel().height ?? 0.0;

      if (height <= 0 || weight <= 0) return "0.0";

      // Lbs to Kg (0.453592) and Cm to Meters (/100)
      double weightKg = weight * 0.453592;
      double heightM = height / 100;
      double bmi = weightKg / (heightM * heightM);

      return bmi.toStringAsFixed(1);
    } catch (e) {
      return "0.0";
    }
  }

  String getBMICategory(double bmi) {
    if (bmi <= 0) return "N/A";
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  @override
  Widget build(BuildContext context) {
    String bmiString = calculateBMI();
    double bmiValue = double.tryParse(bmiString) ?? 0.0;
    String category = getBMICategory(bmiValue);

    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService().getWorkoutHistory(),
      builder: (context, snapshot) {
        int totalWorkouts = 0;
        int totalCalories = 0;
        int totalMinutes = 0;
        List<BarChartGroupData> calorieBarGroups = [];
        double maxCal = 100;
        List<DocumentSnapshot> workoutDocs = [];

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          final String currentUserId = UserModel().userId ?? "";
          workoutDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['userId'] == currentUserId || data['userId'] == null;
          }).toList();

          // Sort in-memory: newest first
          workoutDocs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final t1 = dataA['date'] as Timestamp;
            final t2 = dataB['date'] as Timestamp;
            return t2.compareTo(t1);
          });

          totalWorkouts = workoutDocs.length;
          
          for (final doc in workoutDocs) {
            final data = doc.data() as Map<String, dynamic>;
            totalCalories += (data['calories'] as int? ?? 0);
            totalMinutes += (data['minutes'] as int? ?? 0);
          }

          // Group by last 7 days for chart
          Map<int, double> weeklyData = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          for (final doc in workoutDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final ts = data['date'] as Timestamp;
            final date = ts.toDate();
            DateTime workoutDate = DateTime(date.year, date.month, date.day);
            int diff = today.difference(workoutDate).inDays;
            
            if (diff >= 0 && diff < 7) {
              int dayIndex = 6 - diff; 
              weeklyData[dayIndex] = (weeklyData[dayIndex] ?? 0) + (doc['calories'] as int? ?? 0).toDouble();
            }
          }

          for (int i = 0; i < 7; i++) {
            double cal = weeklyData[i]!;
            if (cal > maxCal) maxCal = cal;
            calorieBarGroups.add(_makeGroupData(i, cal));
          }
        }

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "REPORT",
                        style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                          if (result == true) {
                            setState(() {}); // Refresh if profile was saved
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: surfaceColor,
                          backgroundImage: UserModel().profileImageUrl != null && UserModel().profileImageUrl!.startsWith('http')
                              ? NetworkImage(UserModel().profileImageUrl!) as ImageProvider
                              : (UserModel().profileImageUrl != null 
                                  ? FileImage(File(UserModel().profileImageUrl!)) as ImageProvider
                                  : null),
                          child: UserModel().profileImageUrl == null
                              ? const Icon(Icons.person, color: accentNeon)
                              : null,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 25),
                  
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(child: _buildSummaryCard("Total Burned", "$totalCalories", "kcal", Icons.local_fire_department, Colors.orange)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildSummaryCard("Duration", "$totalMinutes", "mins", Icons.timer, Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildChartCard(
                    title: "Calories Burned",
                    subtitle: "Last 7 sessions progress",
                    child: SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          maxY: maxCal + 50,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.grey[800],
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  "${rod.toY.round()} kcal",
                                  GoogleFonts.poppins(color: accentNeon, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  DateTime now = DateTime.now();
                                  DateTime day = now.subtract(Duration(days: 6 - value.toInt()));
                                  String label = DateFormat('E').format(day)[0]; // M, T, W...
                                  return Text(
                                    label,
                                    style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: calorieBarGroups,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  _buildChartCard(
                    title: "Weight Progress",
                    subtitle: "Current: ${UserModel().weight ?? 0} lbs",
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _weightStream,
                        builder: (context, weightSnapshot) {
                          if (!weightSnapshot.hasData || weightSnapshot.data!.docs.isEmpty) {
                            return _buildWeightChart([]);
                          }
                          var docs = weightSnapshot.data!.docs.toList();
                          // Sort in-memory: oldest first for the chart x-axis
                          docs.sort((a, b) {
                            Timestamp t1 = (a.data() as Map<String, dynamic>)['date'] as Timestamp;
                            Timestamp t2 = (b.data() as Map<String, dynamic>)['date'] as Timestamp;
                            return t1.compareTo(t2);
                          });

                          List<FlSpot> spots = [];
                          for (int i = 0; i < docs.length; i++) {
                            final data = docs[i].data() as Map<String, dynamic>;
                            double weight = (data['weight'] as num).toDouble();
                            spots.add(FlSpot(i.toDouble(), weight));
                          }
                          return _buildWeightChart(spots);
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          "BMI Index", 
                          bmiString, 
                          category,
                          bmiValue >= 18.5 && bmiValue < 25 ? accentNeon : Colors.orangeAccent
                        )
                      ),
                      const SizedBox(width: 15),
                      Expanded(child: _buildStatBox("Workouts", "$totalWorkouts", "Completed", Colors.purpleAccent)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Recent Activity",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  if (totalWorkouts == 0)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text("No workouts tracked yet.", style: GoogleFonts.poppins(color: Colors.white24)),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workoutDocs.length > 10 ? 10 : workoutDocs.length,
                      itemBuilder: (context, index) {
                        final doc = workoutDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildActivityItem(data);
                      },
                    ),
                  const SizedBox(height: 30), 
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(unit, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
              ),
            ],
          ),
          Text(title, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChartCard({required String title, required String subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
                ],
              ),
              Icon(Icons.bar_chart, color: accentNeon.withAlpha(128)),
            ],
          ),
          const SizedBox(height: 25),
          child,
        ],
      ),
    );
  }

  Widget _buildWeightChart(List<FlSpot> spots) {
    if (spots.isEmpty) {
      double baseWeight = (UserModel().weight != null && UserModel().weight! > 0) ? UserModel().weight! : 150.0;
      spots = [
        FlSpot(0, baseWeight + 2),
        FlSpot(1, baseWeight + 1.5),
        FlSpot(2, baseWeight + 1.2),
        FlSpot(3, baseWeight + 1.8),
        FlSpot(4, baseWeight + 0.9),
        FlSpot(5, baseWeight + 0.5),
        FlSpot(6, baseWeight),
      ];
    }

    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 5;
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: accentNeon,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true, 
              gradient: LinearGradient(
                colors: [accentNeon.withAlpha(51), accentNeon.withAlpha(0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: accentNeon,
          width: 18,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> data) {
    DateTime date = (data['date'] as Timestamp).toDate();
    String formattedDate = DateFormat('MMM d, h:mm a').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentNeon.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fitness_center, color: accentNeon, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['workoutTitle'] ?? "Workout", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(formattedDate, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${data['calories']} kcal", style: GoogleFonts.poppins(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              Text("${data['minutes']} mins", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          Text(desc, style: GoogleFonts.poppins(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
