import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modules/user_module.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import 'report_screen.dart';
import 'workout_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color bgColor = Color(0xFF0A0E14);
  static const Color surfaceColor = Color(0xFF1C222B);
  static const Color accentNeon = Color(0xFFCCFF00);

  int _selectedIndex = 0;
  String selectedCategory = "Abs";
  final List<String> categories = ["Abs", "Arm", "Chest", "Leg", "Shoulder", "Back", "Full Body", "Custom"];

  // Custom Workouts
  List<Map<String, dynamic>> customWorkouts = [];

  // AI Chat and Discover logic
  final TextEditingController _aiController = TextEditingController();
  List<Map<String, dynamic>> aiMessages = [
    {
      "role": "ai",
      "text": "Hello! I am your AI Fitness Assistant. How can I help you today?",
    }
  ];

  List<Map<String, dynamic>> discoveredWorkouts = [];

  Stream<List<Map<String, dynamic>>>? _discoverStream;
  int _streak = 0;
  int _weeklyProgress = 0;

  @override
  void initState() {
    super.initState();
    _loadCustomWorkouts();
    _loadStats();
    _discoverStream = DatabaseService().getAIDiscoveredWorkouts().asBroadcastStream();
    
    // Listen to discover stream to keep track of added plans for the UI
    _discoverStream?.listen((data) {
      if (mounted) {
        setState(() {
          discoveredWorkouts = data;
        });
      }
    });
  }

  Future<void> _loadCustomWorkouts() async {
    final workouts = await DatabaseService().getCustomWorkouts();
    if (mounted) {
      setState(() {
        customWorkouts = workouts;
      });
    }
  }

  Future<void> _loadStats() async {
    final streak = await DatabaseService().calculateStreak();
    final progress = await DatabaseService().getWeeklyProgress();
    if (mounted) {
      setState(() {
        _streak = streak;
        _weeklyProgress = progress;
      });
    }
  }

  final Map<String, List<Map<String, dynamic>>> workoutData = {
    "Abs": [
      {
        "title": "Core Crusher",
        "duration": "15 mins",
        "exercises_count": "10 Exercises",
        "intensity": 1,
        "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=300",
        "exercises": [
          {"name": "Jumping Jacks", "seconds": 30, "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=600", "description": "Start with feet together and arms at sides. Jump while spreading feet and bringing hands together above head. Keep a steady rhythm."},
          {"name": "Abdominal Crunches", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Lie on back with knees bent. Curl shoulders toward pelvis, keeping lower back on floor. Focus on using your core, not your neck."},
          {"name": "Russian Twist", "seconds": 30, "image": "https://images.unsplash.com/photo-1544033527-b192daee1f5b?q=80&w=600", "description": "Sit with knees bent, feet slightly off ground. Twist torso from side to side, touching floor with hands. Keep your back straight."},
          {"name": "Mountain Climber", "seconds": 30, "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600", "description": "Start in plank position. Alternately bring knees toward chest as if running in place. Maintain a flat back."},
          {"name": "Heel Touch", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Lie on back with knees bent. Reach sideways to touch each heel alternately. Squeeze your obliques."},
          {"name": "Leg Raises", "seconds": 30, "image": "https://images.unsplash.com/photo-1544033527-b192daee1f5b?q=80&w=600", "description": "Lie on back with legs straight. Raise legs toward ceiling without bending knees, then lower slowly. Don't let your back arch."},
          {"name": "Plank", "seconds": 30, "image": "https://images.unsplash.com/photo-1518622358151-22c1d8550300?q=80&w=600", "description": "Hold a push-up position but rest on forearms instead of hands. Keep body in a perfectly straight line from head to heels."},
          {"name": "Bicycle Crunches", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Lie on back. Bring opposite elbow to opposite knee in a pedaling motion. Fully extend the other leg."},
          {"name": "V-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1544033527-b192daee1f5b?q=80&w=600", "description": "Lie on back. Simultaneously lift torso and legs to form a V shape, reaching for toes. Control the movement down."},
          {"name": "Cobra Stretch", "seconds": 30, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600", "description": "Lie face down. Push up with hands to arch back and stretch abdominal muscles. Breathe deeply and look upward."},
        ]
      },
      {
        "title": "Six-Pack Quest",
        "duration": "10 mins",
        "exercises_count": "8 Exercises",
        "intensity": 2,
        "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=300",
        "exercises": [
          {"name": "Sit-Ups", "seconds": 45, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Full sit-ups to engage the entire rectus abdominis."},
          {"name": "Flutter Kicks", "seconds": 30, "image": "https://images.unsplash.com/photo-1544033527-b192daee1f5b?q=80&w=600", "description": "Keep legs straight and kick them up and down in a small range."},
          {"name": "Plank Jacks", "seconds": 30, "image": "https://images.unsplash.com/photo-1518622358151-22c1d8550300?q=80&w=600", "description": "Plank position, jumping feet in and out."},
          {"name": "Dead Bug", "seconds": 45, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Opposite arm and leg extension while maintaining a flat back."},
          {"name": "Windshield Wipers", "seconds": 30, "image": "https://images.unsplash.com/photo-1544033527-b192daee1f5b?q=80&w=600", "description": "Lying on back, rotate legs side to side."},
          {"name": "Reverse Crunches", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Lift hips off the floor using lower abs."},
          {"name": "Side Plank Left", "seconds": 30, "image": "https://images.unsplash.com/photo-1518622358151-22c1d8550300?q=80&w=600", "description": "Hold on left forearm, body straight."},
          {"name": "Side Plank Right", "seconds": 30, "image": "https://images.unsplash.com/photo-1518622358151-22c1d8550300?q=80&w=600", "description": "Hold on right forearm, body straight."},
        ]
      },
      {
        "title": "Oblique Carver",
        "duration": "12 mins",
        "exercises_count": "8 Exercises",
        "intensity": 1,
        "image": "https://images.unsplash.com/photo-1544033527-b192daee1f5b?q=80&w=300",
        "exercises": [
          {"name": "Russian Twist", "seconds": 40, "image": "https://images.unsplash.com/photo-1544033527-b192daee1f5b?q=80&w=600", "description": "Twist torso to target obliques."},
          {"name": "Side Crunches", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Lying on side, crunch upward."},
          {"name": "Bicycle Crunches", "seconds": 45, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Elbow to opposite knee."},
          {"name": "Heel Touches", "seconds": 45, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Side to side reaching for heels."},
          {"name": "Spider-Man Plank", "seconds": 30, "image": "https://images.unsplash.com/photo-1518622358151-22c1d8550300?q=80&w=600", "description": "Knee to outside of elbow in plank."},
          {"name": "Cross Crunches", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Opposite elbow to knee while lying."},
          {"name": "Plank Hip Dips", "seconds": 30, "image": "https://images.unsplash.com/photo-1518622358151-22c1d8550300?q=80&w=600", "description": "In plank, dip hips to each side."},
          {"name": "Standing Side Bends", "seconds": 30, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600", "description": "Reach down one side while standing."},
        ]
      }
    ],
    "Arm": [
      {
        "title": "Bicep & Tricep Blast",
        "duration": "12 mins",
        "exercises_count": "10 Exercises",
        "intensity": 1,
        "image": "https://images.unsplash.com/photo-1581009146145-b5ef03a7403f?q=80&w=300",
        "exercises": [
          {"name": "Arm Circles", "seconds": 30, "image": "https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?q=80&w=600", "description": "Extend arms to sides at shoulder height. Make small circles forward."},
          {"name": "Diamond Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1581009146145-b5ef03a7403f?q=80&w=600", "description": "Place hands close together so thumbs and index fingers form a diamond."},
          {"name": "Tricep Dips", "seconds": 30, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600", "description": "Use a sturdy chair or bench to dip and push up."},
          {"name": "Bicep Curls (Air)", "seconds": 30, "image": "https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?q=80&w=600", "description": "Squeeze your biceps hard as you curl your fists toward your shoulders."},
          {"name": "Wall Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=600", "description": "Stand facing a wall. Lean in and push away."},
          {"name": "Shadow Boxing", "seconds": 30, "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600", "description": "Throw alternating jabs and crosses."},
          {"name": "Triceps Kickbacks", "seconds": 30, "image": "https://images.unsplash.com/photo-1581009146145-b5ef03a7403f?q=80&w=600", "description": "Lean forward slightly and extend lower arms back."},
          {"name": "Inchworms", "seconds": 30, "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600", "description": "Walk hands out to plank and back."},
          {"name": "Floor Tricep Dips", "seconds": 30, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600", "description": "Sit on floor and push up with hands."},
          {"name": "Arm Scissors", "seconds": 30, "image": "https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?q=80&w=600", "description": "Cross your arms in front of your chest."},
        ]
      },
      {
        "title": "Upper Body Toning",
        "duration": "15 mins",
        "exercises_count": "8 Exercises",
        "intensity": 2,
        "image": "https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?q=80&w=300",
        "exercises": [
          {"name": "Pike Push-Ups", "seconds": 40, "image": "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=600", "description": "Push-up from a pike position for shoulders and triceps."},
          {"name": "Puncheurs", "seconds": 30, "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600", "description": "Fast punches to engage arms and cardio."},
          {"name": "Plank Up-Downs", "seconds": 30, "image": "https://images.unsplash.com/photo-1518622358151-22c1d8550300?q=80&w=600", "description": "Switch between forearm plank and high plank."},
          {"name": "Clapping Push-Ups", "seconds": 20, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Explosive push-ups with a clap."},
          {"name": "Shoulder Taps", "seconds": 45, "image": "https://images.unsplash.com/photo-1518622358151-22c1d8550300?q=80&w=600", "description": "Tap shoulders in plank position."},
          {"name": "Tricep Extension", "seconds": 30, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600", "description": "Overhead arm extension simulation."},
          {"name": "Lateral Arm Circles", "seconds": 30, "image": "https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?q=80&w=600", "description": "Small circles with arms to the side."},
          {"name": "Wall Sit Arm Flaps", "seconds": 30, "image": "https://images.unsplash.com/photo-1550345332-09e3ac987658?q=80&w=600", "description": "Wall sit while moving arms up and down."},
        ]
      }
    ],
    "Chest": [
      {
        "title": "Chest Sculptor",
        "duration": "12 mins",
        "exercises_count": "10 Exercises",
        "intensity": 1,
        "image": "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=300",
        "exercises": [
          {"name": "Warm Up Jacks", "seconds": 30, "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=600", "description": "Jump and spread legs while clapping overhead."},
          {"name": "Standard Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Lower body until chest nearly touches floor."},
          {"name": "Wide Arm Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600", "description": "Perform push-ups with hands wider than shoulder-width."},
          {"name": "Incline Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1532384748853-8f54a8f476e2?q=80&w=600", "description": "Place hands on a chair or stairs."},
          {"name": "Knee Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=600", "description": "Keep knees on floor for a slightly easier version."},
          {"name": "Box Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=600", "description": "On all fours, lower your head and chest."},
          {"name": "Hindu Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=300", "description": "From downward dog, swoop your chest down and up."},
          {"name": "Decline Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Place feet on a chair and hands on floor."},
          {"name": "Staggered Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600", "description": "One hand forward, one hand back."},
          {"name": "Cobra Stretch", "seconds": 30, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600", "description": "Arch back from prone position."},
        ]
      },
      {
        "title": "Pectoral Pump",
        "duration": "15 mins",
        "exercises_count": "8 Exercises",
        "intensity": 3,
        "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=300",
        "exercises": [
          {"name": "Explosive Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Push up as hard as possible."},
          {"name": "Diamond Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1581009146145-b5ef03a7403f?q=80&w=600", "description": "Hands close together for inner chest."},
          {"name": "Burpees", "seconds": 45, "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=600", "description": "Full body movement with push-up."},
          {"name": "Plank Taps", "seconds": 45, "image": "https://images.unsplash.com/photo-1518622358151-22c1d8550300?q=80&w=600", "description": "Stabilize chest while tapping shoulders."},
          {"name": "Pseudo Planche Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Leaning forward push-ups."},
          {"name": "Wide Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600", "description": "Broaden the chest focus."},
          {"name": "Archer Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "One arm stays straight while other bends."},
          {"name": "Chest Stretch", "seconds": 30, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600", "description": "Hands behind back and pull."},
        ]
      }
    ],
    "Leg": [
      {
        "title": "Lower Body Power",
        "duration": "15 mins",
        "exercises_count": "10 Exercises",
        "intensity": 1,
        "image": "https://images.unsplash.com/photo-1434608519344-49d77a699e1d?q=80&w=300",
        "exercises": [
          {"name": "Air Squats", "seconds": 30, "image": "https://images.unsplash.com/photo-1550345332-09e3ac987658?q=80&w=600", "description": "Lower hips as if sitting in a chair."},
          {"name": "Forward Lunges", "seconds": 30, "image": "https://images.unsplash.com/photo-1434608519344-49d77a699e1d?q=80&w=600", "description": "Step forward and lower hips."},
          {"name": "Wall Sit", "seconds": 30, "image": "https://images.unsplash.com/photo-1550345332-09e3ac987658?q=80&w=600", "description": "Back against wall, lower until thighs parallel."},
          {"name": "Calf Raises", "seconds": 30, "image": "https://images.unsplash.com/photo-1590239068531-979373241865?q=80&w=600", "description": "Stand tall and lift heels off ground."},
          {"name": "Side Leg Raises", "seconds": 30, "image": "https://images.unsplash.com/photo-1550345332-09e3ac987658?q=80&w=600", "description": "Lie on your side. Lift top leg."},
          {"name": "Glute Bridges", "seconds": 30, "image": "https://images.unsplash.com/photo-1434608519344-49d77a699e1d?q=80&w=600", "description": "Lie on back with knees bent. Lift hips."},
          {"name": "Jump Squats", "seconds": 30, "image": "https://images.unsplash.com/photo-1550345332-09e3ac987658?q=80&w=600", "description": "Perform a squat then jump up explosively."},
          {"name": "Sumo Squats", "seconds": 30, "image": "https://images.unsplash.com/photo-1434608519344-49d77a699e1d?q=80&w=600", "description": "Take a wide stance with toes pointed out."},
          {"name": "Curtsy Lunges", "seconds": 30, "image": "https://images.unsplash.com/photo-1590239068531-979373241865?q=80&w=600", "description": "Step one leg back and across the other."},
          {"name": "High Knees", "seconds": 30, "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=600", "description": "Run in place, bringing knees up high."},
        ]
      },
      {
        "title": "Glute & Leg Toning",
        "duration": "20 mins",
        "exercises_count": "8 Exercises",
        "intensity": 2,
        "image": "https://images.unsplash.com/photo-1590239068531-979373241865?q=80&w=300",
        "exercises": [
          {"name": "Donkey Kicks Left", "seconds": 45, "image": "https://images.unsplash.com/photo-1434608519344-49d77a699e1d?q=80&w=600", "description": "On all fours, kick left leg back."},
          {"name": "Donkey Kicks Right", "seconds": 45, "image": "https://images.unsplash.com/photo-1434608519344-49d77a699e1d?q=80&w=600", "description": "On all fours, kick right leg back."},
          {"name": "Fire Hydrants", "seconds": 30, "image": "https://images.unsplash.com/photo-1434608519344-49d77a699e1d?q=80&w=600", "description": "Lift leg to side in tabletop."},
          {"name": "Reverse Lunges", "seconds": 45, "image": "https://images.unsplash.com/photo-1434608519344-49d77a699e1d?q=80&w=600", "description": "Step back into a lunge."},
          {"name": "Squat Hold", "seconds": 45, "image": "https://images.unsplash.com/photo-1550345332-09e3ac987658?q=80&w=600", "description": "Hold the bottom of a squat."},
          {"name": "Pulsing Squats", "seconds": 30, "image": "https://images.unsplash.com/photo-1550345332-09e3ac987658?q=80&w=600", "description": "Short bounce at the bottom of a squat."},
          {"name": "Single Leg Bridges", "seconds": 30, "image": "https://images.unsplash.com/photo-1434608519344-49d77a699e1d?q=80&w=600", "description": "Bridge with one leg in the air."},
          {"name": "Leg Stretch", "seconds": 30, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600", "description": "Hamstring stretch sitting or standing."},
        ]
      }
    ],
    "Shoulder": [
      {
        "title": "Shoulder Definition",
        "duration": "12 mins",
        "exercises_count": "10 Exercises",
        "intensity": 1,
        "image": "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=300",
        "exercises": [
          {"name": "Jumping Jacks", "seconds": 30, "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=600", "description": "Warm-up to get shoulders moving."},
          {"name": "Arm Circles (Large)", "seconds": 30, "image": "https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?q=80&w=600", "description": "Make large circles with your arms."},
          {"name": "Side Lateral Raise", "seconds": 30, "image": "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=600", "description": "Lift arms out to sides to shoulder height."},
          {"name": "Front Raise", "seconds": 30, "image": "https://images.unsplash.com/photo-1532384748853-8f54a8f476e2?q=80&w=600", "description": "Lift arms straight out in front."},
          {"name": "Pike Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=600", "description": "Lower head toward floor from pike."},
          {"name": "Shoulder Shrugs", "seconds": 30, "image": "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=300", "description": "Lift shoulders as high as possible."},
          {"name": "Plank Shoulder Taps", "seconds": 30, "image": "https://images.unsplash.com/photo-1518622358151-22c1d8550300?q=80&w=600", "description": "Touch opposite shoulder in plank."},
          {"name": "Overhead Press (Air)", "seconds": 30, "image": "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=600", "description": "Press your fists toward the ceiling."},
          {"name": "Shoulder Stretch", "seconds": 30, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600", "description": "Pull one arm across your chest."},
          {"name": "Doorway Stretch", "seconds": 30, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600", "description": "Leaning forward against a frame."},
        ]
      }
    ],
    "Back": [
      {
        "title": "Strong Back",
        "duration": "14 mins",
        "exercises_count": "10 Exercises",
        "intensity": 1,
        "image": "https://images.unsplash.com/photo-1605296867304-46d5465a13f1?q=80&w=300",
        "exercises": [
          {"name": "Cat Cow Stretch", "seconds": 30, "image": "https://images.unsplash.com/photo-1574406280735-351fc1a7c5b0?q=80&w=600", "description": "Alternate between arching and rounding."},
          {"name": "Superman", "seconds": 30, "image": "https://images.unsplash.com/photo-1581009146145-b5ef03a7403f?q=80&w=600", "description": "Lie on stomach. Lift arms and legs."},
          {"name": "Bird Dog", "seconds": 30, "image": "https://images.unsplash.com/photo-1544033527-b192daee1f5b?q=80&w=600", "description": "On all fours, extend opposite arm and leg."},
          {"name": "Cobra Stretch", "seconds": 30, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600", "description": "Arch the lower back gently."},
          {"name": "Child's Pose", "seconds": 30, "image": "https://images.unsplash.com/photo-1574406280735-351fc1a7c5b0?q=80&w=600", "description": "Sit back on your heels and reach forward."},
          {"name": "Swimmer", "seconds": 30, "image": "https://images.unsplash.com/photo-1574406280735-351fc1a7c5b0?q=80&w=300", "description": "Lying on stomach, flutter arms and legs."},
          {"name": "Reverse Fly (Air)", "seconds": 30, "image": "https://images.unsplash.com/photo-1581009146145-b5ef03a7403f?q=80&w=600", "description": "Squeeze shoulder blades together."},
          {"name": "Glute Bridge", "seconds": 30, "image": "https://images.unsplash.com/photo-1544033527-b192daee1f5b?q=80&w=600", "description": "Lying on back, lift hips high."},
          {"name": "Knee to Chest", "seconds": 30, "image": "https://images.unsplash.com/photo-1581009146145-b5ef03a7403f?q=80&w=600", "description": "Pull one knee into chest at a time."},
          {"name": "Wall Pulls", "seconds": 30, "image": "https://images.unsplash.com/photo-1605296867304-46d5465a13f1?q=80&w=300", "description": "Use a doorway to pull chest forward."},
        ]
      }
    ],
    "Full Body": [
      {
        "title": "Fat Burning HIIT",
        "duration": "25 mins",
        "exercises_count": "10 Exercises",
        "intensity": 2,
        "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=300",
        "exercises": [
          {"name": "Burpees", "seconds": 30, "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=600", "description": "Drop to plank, do a push-up, jump up."},
          {"name": "Mountain Climbers", "seconds": 30, "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600", "description": "In plank position, run your knees toward chest."},
          {"name": "Squat to Press", "seconds": 30, "image": "https://images.unsplash.com/photo-1550345332-09e3ac987658?q=80&w=600", "description": "Perform a squat and press arms overhead."},
          {"name": "Plank Jacks", "seconds": 30, "image": "https://images.unsplash.com/photo-1518622358151-22c1d8550300?q=80&w=600", "description": "In plank position, jump your feet wide."},
          {"name": "Lunges with Twist", "seconds": 30, "image": "https://images.unsplash.com/photo-1434608519344-49d77a699e1d?q=80&w=600", "description": "Step into a lunge and twist torso."},
          {"name": "Push-Up to Side Plank", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Do a push-up, then rotate into side plank."},
          {"name": "High Knees", "seconds": 30, "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=600", "description": "Run in place with knees as high as possible."},
          {"name": "Butt Kicks", "seconds": 30, "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600", "description": "Run in place, kicking heels toward glutes."},
          {"name": "Spider-Man Push-Ups", "seconds": 30, "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600", "description": "Bring knee toward elbow during push-up."},
          {"name": "Slow Climber Stretch", "seconds": 30, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600", "description": "Slow mountain climber with deep hip stretch."},
        ]
      },
      {
        "title": "Morning Cardio",
        "duration": "10 mins",
        "exercises_count": "6 Exercises",
        "intensity": 1,
        "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=300",
        "exercises": [
          {"name": "Jumping Jacks", "seconds": 45, "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=600", "description": "Classic wake-up movement."},
          {"name": "Run in Place", "seconds": 60, "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600", "description": "Light jogging to get blood flowing."},
          {"name": "Windmills", "seconds": 30, "image": "https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?q=80&w=600", "description": "Rotate torso and touch opposite foot."},
          {"name": "Squats", "seconds": 45, "image": "https://images.unsplash.com/photo-1550345332-09e3ac987658?q=80&w=600", "description": "Bodyweight squats to wake up legs."},
          {"name": "Arm Swings", "seconds": 30, "image": "https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?q=80&w=600", "description": "Dynamic stretching for arms and chest."},
          {"name": "Deep Breathing", "seconds": 30, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=600", "description": "Inhale deeply and stretch arms up."},
        ]
      }
    ],
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _loadStats();
    }
  }

  void _handleAISubmit() async {
    String text = _aiController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      aiMessages.add({"role": "user", "text": text});
      _aiController.clear();
      // Add a loading message
      aiMessages.add({"role": "ai", "text": "Thinking...", "loading": true});
    });

    try {
      final response = await AIService.getAIResponse(text);
      
      setState(() {
        // Remove loading message
        aiMessages.removeWhere((m) => m['loading'] == true);
        
        // Add actual AI response
        aiMessages.add({
          "role": "ai",
          "text": response['message'] ?? "I couldn't process that.",
          if (response.containsKey('plan')) "plan": response['plan'],
          if (response.containsKey('diet')) "diet": response['diet'],
        });
      });
    } catch (e) {
      setState(() {
        aiMessages.removeWhere((m) => m['loading'] == true);
        aiMessages.add({"role": "ai", "text": "Error: Could not connect to AI Coach. Please check your internet or API Key."});
      });
    }
  }

  void _handleAIReject(String? oldTitle) async {
    String text = "I didn't like the '${oldTitle ?? "previous"}' plan. Can you suggest a different workout plan?";
    
    setState(() {
      aiMessages.add({"role": "user", "text": "Not this one, give me another."});
      aiMessages.add({"role": "ai", "text": "Sure, let me suggest a different one for you...", "loading": true});
    });

    try {
      final response = await AIService.getAIResponse(text);
      
      setState(() {
        aiMessages.removeWhere((m) => m['loading'] == true);
        aiMessages.add({
          "role": "ai",
          "text": response['message'] ?? "Here is a new suggestion:",
          if (response.containsKey('plan')) "plan": response['plan'],
          if (response.containsKey('diet')) "diet": response['diet'],
        });
      });
    } catch (e) {
      setState(() {
        aiMessages.removeWhere((m) => m['loading'] == true);
        aiMessages.add({"role": "ai", "text": "Error: Could not fetch a new plan."});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildTrainingHome(),
          _buildDiscoverScreen(),
          _buildAIAssistScreen(),
          const ReportScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddWorkoutDialog,
              backgroundColor: accentNeon,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withAlpha(13), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: bgColor,
          selectedItemColor: accentNeon,
          unselectedItemColor: Colors.white30,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              activeIcon: Icon(Icons.fitness_center, color: accentNeon),
              label: "Training",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore, color: accentNeon),
              label: "Discover",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome, color: accentNeon),
              label: "AI Assist",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              activeIcon: Icon(Icons.bar_chart_rounded, color: accentNeon),
              label: "Report",
            ),
          ],
        ),
      ),
    );
  }

  // --- TRAINING HOME ---
  Widget _buildTrainingHome() {
    List<Map<String, dynamic>> currentWorkouts = [];
    if (selectedCategory == "Custom") {
      currentWorkouts = customWorkouts;
    } else {
      currentWorkouts = workoutData[selectedCategory] ?? [];
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "HOME WORKOUT",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        "$_streak",
                        style: GoogleFonts.poppins(color: Colors.orange, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildSearchBar(),
              const SizedBox(height: 30),
              _buildWeeklyGoalCard(),
              const SizedBox(height: 35),
              Text(
                "Body Focus",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildCategorySelector(),
              const SizedBox(height: 25),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentWorkouts.length,
                itemBuilder: (context, index) {
                  return _buildWorkoutItem(currentWorkouts[index]);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddWorkoutDialog() {
    final titleController = TextEditingController();
    final exerciseNameController = TextEditingController();
    final durationController = TextEditingController();
    List<Map<String, dynamic>> tempExercises = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Create Custom Workout", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Workout Title",
                    labelStyle: GoogleFonts.poppins(color: Colors.white54),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  ),
                ),
                const SizedBox(height: 20),
                Text("Add Exercises", style: GoogleFonts.poppins(color: accentNeon, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: exerciseNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Exercise Name",
                    labelStyle: GoogleFonts.poppins(color: Colors.white54),
                  ),
                ),
                TextField(
                  controller: durationController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Duration (seconds)",
                    labelStyle: GoogleFonts.poppins(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: accentNeon, foregroundColor: Colors.black),
                  onPressed: () {
                    if (exerciseNameController.text.isNotEmpty && durationController.text.isNotEmpty) {
                      setDialogState(() {
                        tempExercises.add({
                          "name": exerciseNameController.text,
                          "seconds": int.tryParse(durationController.text) ?? 30,
                          "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=600",
                          "description": "Custom exercise added by user."
                        });
                        exerciseNameController.clear();
                        durationController.clear();
                      });
                    }
                  },
                  child: const Text("Add Exercise to List"),
                ),
                const SizedBox(height: 10),
                if (tempExercises.isNotEmpty)
                  Column(
                    children: tempExercises
                        .map((e) => ListTile(
                              title: Text(e['name'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                              trailing: Text("${e['seconds']}s", style: const TextStyle(color: Colors.white54)),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentNeon, foregroundColor: Colors.black),
              onPressed: () async {
                if (titleController.text.isNotEmpty && tempExercises.isNotEmpty) {
                  final newWorkout = {
                    "title": titleController.text,
                    "duration": "${(tempExercises.length * 0.5).toStringAsFixed(0)} mins",
                    "exercises_count": "${tempExercises.length} Exercises",
                    "intensity": 1,
                    "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=300",
                    "exercises": tempExercises,
                  };

                  setState(() {
                    customWorkouts.insert(0, newWorkout);
                    selectedCategory = "Custom";
                  });

                  Navigator.pop(context);

                  try {
                    await DatabaseService().saveCustomWorkout(newWorkout);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to save workout to cloud: $e")),
                      );
                    }
                  }
                }
              },
              child: const Text("Save Workout"),
            ),
          ],
        ),
      ),
    );
  }

  // --- DISCOVER SCREEN ---
  Widget _buildDiscoverScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Text(
              "Discover",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Your personalized AI plans and fitness articles.",
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _discoverStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: accentNeon));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading plans",
                        style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 14),
                      ),
                    );
                  }

                  final discoveredPlans = snapshot.data ?? [];

                  if (discoveredPlans.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: accentNeon.withAlpha(51), size: 80),
                          const SizedBox(height: 20),
                          Text(
                            "No AI plans suggested yet.\nAsk AI Coach for a workout plan!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(color: Colors.white30, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: discoveredPlans.length,
                    itemBuilder: (context, index) {
                      return _buildWorkoutItem(discoveredPlans[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- AI ASSIST SCREEN ---
  Widget _buildAIAssistScreen() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: accentNeon, size: 28),
                const SizedBox(width: 12),
                Text(
                  "AI Fitness Coach",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: aiMessages.length,
              itemBuilder: (context, index) {
                var msg = aiMessages[index];
                bool isAI = msg['role'] == 'ai';
                return Column(
                  crossAxisAlignment: isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                      decoration: BoxDecoration(
                        color: isAI ? surfaceColor : accentNeon.withAlpha(26),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isAI ? 0 : 20),
                          bottomRight: Radius.circular(isAI ? 20 : 0),
                        ),
                        border: isAI ? null : Border.all(color: accentNeon.withAlpha(77)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (msg['loading'] == true)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: accentNeon),
                            )
                          else
                            Text(
                              msg['text'],
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, height: 1.5),
                            ),
                        ],
                      ),
                    ),
                    if (isAI && msg.containsKey('plan') && msg['plan'] != null) ...[
                      const SizedBox(height: 5),
                      _buildAIPlanCard(msg['plan']),
                    ],
                    if (isAI && msg.containsKey('diet') && msg['diet'] != null) ...[
                      const SizedBox(height: 10),
                      _buildAIDietCard(msg['diet']),
                    ],
                  ],
                );
              },
            ),
          ),
          _buildAIInput(),
        ],
      ),
    );
  }

  Widget _buildAIPlanCard(Map<String, dynamic> plan) {
    bool alreadyAdded = discoveredWorkouts.any((w) => w['title'] == plan['title']);

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentNeon.withAlpha(128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fitness_center, color: accentNeon, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "WORKOUT PLAN",
                  style: GoogleFonts.poppins(
                    color: accentNeon,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  plan['image'] ?? "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=300",
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.white10,
                    child: const Icon(Icons.fitness_center, color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['title'] ?? "AI Plan",
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${plan['duration'] ?? '15 mins'} • ${plan['exercises_count'] ?? '10 exercises'}",
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _handleAIReject(plan['title']),
                  child: Text("Reject", style: GoogleFonts.poppins(color: Colors.white38)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alreadyAdded ? Colors.grey[800] : accentNeon,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: alreadyAdded
                      ? null
                      : () async {
                          try {
                            await DatabaseService().saveAIDiscoveredWorkout(plan);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Plan added to Discover!"), duration: Duration(seconds: 1)),
                              );
                              setState(() {
                                // Add to local list and switch to Discover tab
                                discoveredWorkouts.add(plan);
                                _selectedIndex = 1; 
                              });
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          }
                        },
                  child: Text(
                    alreadyAdded ? "Added" : "Add Plan",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAIDietCard(Map<String, dynamic> diet) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orangeAccent.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu, color: Colors.orangeAccent, size: 24),
              const SizedBox(width: 10),
              Text(
                "DIET PLAN",
                style: GoogleFonts.poppins(
                  color: Colors.orangeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            diet['title'] ?? "Diet Plan",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            diet['desc'] ?? "",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              diet['calories'] ?? "",
              style: GoogleFonts.poppins(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAIInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: bgColor,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _aiController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Ask AI Coach...",
                  hintStyle: GoogleFonts.poppins(color: Colors.white30),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleAISubmit,
            child: const CircleAvatar(
              backgroundColor: accentNeon,
              child: Icon(Icons.send, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMMON WIDGETS ---
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(35)),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search workouts, plans...",
          hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == categories[index];
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = categories[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isSelected ? Colors.transparent : surfaceColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: isSelected ? accentNeon : Colors.transparent, width: 1.5),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: GoogleFonts.poppins(
                    color: isSelected ? accentNeon : Colors.white54,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyGoalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Weekly Goal", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text("$_weeklyProgress/4", style: GoogleFonts.poppins(color: accentNeon, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              DateTime now = DateTime.now();
              // Find the Monday of the current week
              DateTime monday = now.subtract(Duration(days: now.weekday - 1));
              DateTime dayDate = monday.add(Duration(days: index));
              bool isToday = dayDate.day == now.day && dayDate.month == now.month && dayDate.year == now.year;
              
              return Column(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isToday ? Border.all(color: accentNeon.withAlpha(128), width: 1.5) : null,
                      color: isToday ? accentNeon.withAlpha(26) : Colors.transparent,
                    ),
                    child: Text("${dayDate.day}", style: GoogleFonts.poppins(color: isToday ? accentNeon : Colors.white54, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  if (isToday) const Icon(Icons.arrow_drop_down, color: accentNeon, size: 20),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutItem(Map<String, dynamic> workout) {
    String title = workout['title'] ?? "Workout";
    String duration = workout['duration'] ?? "15 mins";
    
    // Improved exercise count logic
    String exercisesCount = workout['exercises_count']?.toString() ?? "10 Exercises";
    if (workout['exercises'] is List) {
      exercisesCount = "${(workout['exercises'] as List).length} Exercises";
    }

    int intensity = workout['intensity'] ?? 1;
    String imageUrl = workout['image'] ?? "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=300";

    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text("$duration • $exercisesCount", style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentNeon,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(100, 36),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () {
                        List<Map<String, dynamic>> exercises = [];
                        if (workout.containsKey('exercises') && workout['exercises'] is List) {
                          exercises = List<Map<String, dynamic>>.from(workout['exercises']);
                        } else {
                          exercises = [
                            {
                              "name": "Jumping Jacks",
                              "seconds": 30,
                              "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=600",
                              "description": "Stand with feet together and arms at sides. Jump while spreading legs and raising arms overhead. Jump back to start."
                            },
                            {
                              "name": "Push Ups",
                              "seconds": 30,
                              "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600",
                              "description": "Start in plank position. Lower body until chest nearly touches floor. Push back up to starting position."
                            },
                            {
                              "name": "Plank",
                              "seconds": 30,
                              "image": "https://images.unsplash.com/photo-1544033527-b192daee1f5b?q=80&w=600",
                              "description": "Hold a push-up position but on your elbows. Keep your body in a straight line from head to heels."
                            },
                          ];
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutPlayerScreen(
                              workoutTitle: title,
                              exercises: exercises,
                            ),
                          ),
                        ).then((_) => _loadStats());
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 20),
                          const SizedBox(width: 4),
                          Text("START", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white10, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
    );
  }
}
