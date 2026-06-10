import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../services/database_service.dart';
import '../modules/workout_history.dart';

class WorkoutPlayerScreen extends StatefulWidget {
  final String workoutTitle;
  final List<Map<String, dynamic>> exercises;

  const WorkoutPlayerScreen({super.key, required this.workoutTitle, required this.exercises});

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> with TickerProviderStateMixin {
  static const Color bgColor = Color(0xFF0A0E14);
  static const Color surfaceColor = Color(0xFF1C222B);
  static const Color accentNeon = Color(0xFFCCFF00);

  int _currentExerciseIndex = 0;
  int _secondsRemaining = 30;
  bool _isPaused = false;
  bool _isResting = false;
  Timer? _timer;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startExercise();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = _isResting ? 15 : (widget.exercises[_currentExerciseIndex]['seconds'] ?? 30);
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _nextExercise();
          }
        });
      }
    });
  }

  void _nextExercise() {
    if (!_isResting && _currentExerciseIndex < widget.exercises.length - 1) {
      setState(() {
        _isResting = true;
        _startExercise();
      });
    } else if (_isResting) {
      setState(() {
        _isResting = false;
        _currentExerciseIndex++;
        _startExercise();
      });
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() async {
    _timer?.cancel();
    
    // Calculate actual duration
    int minutes = DateTime.now().difference(_startTime!).inMinutes;
    if (minutes == 0) minutes = 1; // Minimum 1 minute
    
    // Better calorie estimation based on intensity if possible, 
    // but for now 8 kcal/min is a good average for HIIT/Strength.
    int calories = minutes * 8;

    final history = WorkoutHistory(
      workoutTitle: widget.workoutTitle,
      calories: calories,
      minutes: minutes,
      date: DateTime.now(),
    );

    try {
      await DatabaseService().saveWorkoutHistory(history);
    } catch (e) {
      debugPrint("Error saving history: $e");
    }

    if (mounted) {
      _showCompletionDialog(calories, minutes);
    }
  }

  void _shareWorkout(int calories, int minutes) {
    final text = "I just finished the '${widget.workoutTitle}' workout on Fitness AI! "
                 "Burned $calories kcal in $minutes minutes. #FitnessAI #Workout";
    Share.share(text);
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _isResting = false;
        _startExercise();
      });
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _showCompletionDialog(int calories, int minutes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.stars_rounded, color: accentNeon, size: 60),
            const SizedBox(height: 10),
            Text("Workout Complete!", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Great job finishing your workout!", style: GoogleFonts.poppins(color: Colors.white70)),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("CALORIES", "$calories", "kcal"),
                _buildStatItem("DURATION", "$minutes", "mins"),
              ],
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _shareWorkout(calories, minutes),
                  icon: const Icon(Icons.share, color: accentNeon),
                  label: Text("SHARE", style: GoogleFonts.poppins(color: accentNeon, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentNeon,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back home
                  },
                  child: Text("DONE", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(color: accentNeon, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(unit, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentExercise = widget.exercises[_currentExerciseIndex];
    double progress = (_currentExerciseIndex + (_isResting ? 0.5 : 0)) / widget.exercises.length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isResting ? "REST" : widget.workoutTitle.toUpperCase(),
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(accentNeon),
                            minHeight: 6,
                          ),
                          const SizedBox(height: 20),
                          Stack(
                            children: [
                              Container(
                                height: 320,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(30),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      _isResting 
                                        ? "https://images.unsplash.com/photo-1518622358151-22c1d8550300?q=80&w=600" 
                                        : (currentExercise['image'] ?? "https://images.unsplash.com/photo-1594882645126-14020914d58d")
                                    ),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                left: 20,
                                child: Text(
                                  _isResting ? "Get Ready" : currentExercise['name'].toString().toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!_isResting && currentExercise['description'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                              child: Text(
                                currentExercise['description'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),

                      // Circular Timer
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 150,
                            width: 150,
                            child: CircularProgressIndicator(
                              value: _secondsRemaining / (_isResting ? 15 : (currentExercise['seconds'] ?? 30)),
                              strokeWidth: 8,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation<Color>(accentNeon),
                            ),
                          ),
                          Text(
                            "$_secondsRemaining",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Controls
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _previousExercise,
                              icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 45),
                            ),
                            const SizedBox(width: 30),
                            GestureDetector(
                              onTap: _togglePause,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                  color: accentNeon,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                  size: 45,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 30),
                            IconButton(
                              onPressed: _nextExercise,
                              icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 45),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}