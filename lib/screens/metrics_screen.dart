import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modules/user_module.dart';
import 'pushups_level_screen.dart';

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({super.key});

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  double weight = 165.0;
  double height = 175.0;
  
  late ScrollController _weightController;
  late ScrollController _heightController;

  static const Color bgColor = Color(0xFF0A0E14);
  static const Color surfaceColor = Color(0xFF1C222B);
  static const Color accentNeon = Color(0xFFCCFF00);

  @override
  void initState() {
    super.initState();
    _weightController = ScrollController(initialScrollOffset: (weight - 40) * 10);
    _heightController = ScrollController(initialScrollOffset: (height - 100) * 10);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic padding to center the scale
    final double centerPadding = MediaQuery.of(context).size.width / 2 - 5;

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
                "STEP 5 OF 6",
                style: GoogleFonts.poppins(color: accentNeon, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              Text(
                "INPUT YOUR",
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16, letterSpacing: 2),
              ),
              Text(
                "BODY METRICS",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Weight Section
              _buildSectionHeader("WEIGHT", "${weight.toInt()} Lbs"),
              const SizedBox(height: 20),
              _buildHorizontalScale(
                controller: _weightController,
                min: 40,
                max: 300,
                padding: centerPadding,
                onChanged: (val) {
                  if (weight != val) setState(() => weight = val);
                },
              ),

              const SizedBox(height: 50),

              // Height Section
              _buildSectionHeader("HEIGHT", "${height.toInt()} Cm"),
              const SizedBox(height: 20),
              _buildHorizontalScale(
                controller: _heightController,
                min: 100,
                max: 250,
                padding: centerPadding,
                onChanged: (val) {
                  if (height != val) setState(() => height = val);
                },
              ),

              const SizedBox(height: 80),

              // Continue Button
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      UserModel().weight = weight;
                      UserModel().height = height;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PushUpsLevelScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentNeon,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      "CONTINUE",
                      style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
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

  Widget _buildSectionHeader(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.urbanist(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
        Text(value, style: GoogleFonts.poppins(color: accentNeon, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHorizontalScale({
    required ScrollController controller,
    required int min,
    required int max,
    required double padding,
    required Function(double) onChanged,
  }) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              double newValue = min + (controller.offset / 10);
              if (newValue >= min && newValue <= max) {
                onChanged(newValue.roundToDouble());
              }
              return true;
            },
            child: ListView.builder(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: padding),
              itemCount: (max - min) + 1,
              itemBuilder: (context, index) {
                int val = min + index;
                bool isTen = val % 10 == 0;
                bool isFive = val % 5 == 0;

                return Container(
                  width: 10,
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: isTen ? 2 : 1,
                        height: isTen ? 40 : (isFive ? 25 : 15),
                        color: isTen ? accentNeon : Colors.white24,
                      ),
                      const SizedBox(height: 8),
                      if (isTen)
                        Text(
                          "$val",
                          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10),
                        )
                      else
                        const SizedBox(height: 15),
                    ],
                  ),
                );
              },
            ),
          ),
          // Center Pointer
          Positioned(
            top: 0,
            child: Container(
              width: 3,
              height: 50,
              decoration: BoxDecoration(
                color: accentNeon,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(color: accentNeon.withOpacity(0.5), blurRadius: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
