import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:fitness_tracker_app/modules/user_module.dart';
import 'package:fitness_tracker_app/modules/workout_history.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId == null) return null;

      final ref = _storage.ref().child('user_profiles').child('$userId.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      
      // Update local model
      UserModel().profileImageUrl = url;
      return url;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> saveUserProfile() async {
    final user = UserModel();
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) {
        userId = const Uuid().v4();
        await prefs.setString('userId', userId);
      }
      
      user.userId = userId;

      // Use doc(userId) to overwrite/update the same profile instead of adding a new one
      await _db.collection('users').doc(userId).set(user.toJson());
      
      // Save weight to history
      if (user.weight != null) {
        await _db.collection('weight_history').add({
          "userId": userId,
          "weight": user.weight,
          "date": Timestamp.now(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) return null;

      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        UserModel().fromMap(doc.data()!);
        return UserModel();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveWorkoutHistory(WorkoutHistory history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId') ?? "anonymous";
      
      await _db.collection('workout_history').add({
        ...history.toJson(),
        "userId": userId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> getWorkoutHistory() {
    return SharedPreferences.getInstance().asStream().asyncExpand((prefs) {
      String? userId = prefs.getString('userId') ?? "anonymous";
      return _db
          .collection('workout_history')
          .where('userId', isEqualTo: userId)
          .snapshots();
    });
  }

  Future<int> calculateStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId == null) return 0;

      final querySnapshot = await _db
          .collection('workout_history')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isEmpty) return 0;

      // Extract unique dates normalized to midnight
      final dates = querySnapshot.docs
          .map((doc) => (doc.data()['date'] as Timestamp).toDate())
          .map((date) => DateTime(date.year, date.month, date.day))
          .toSet()
          .toList();

      dates.sort((a, b) => b.compareTo(a)); // Descending order

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      if (!dates.contains(today) && !dates.contains(yesterday)) {
        return 0;
      }

      int streak = 0;
      DateTime currentCheck = dates.contains(today) ? today : yesterday;

      while (dates.contains(currentCheck)) {
        streak++;
        currentCheck = currentCheck.subtract(const Duration(days: 1));
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getWeeklyProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId == null) return 0;

      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeek = DateTime(monday.year, monday.month, monday.day);

      final querySnapshot = await _db
          .collection('workout_history')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .get();

      // Count unique days this week
      final uniqueDays = querySnapshot.docs
          .map((doc) => (doc.data()['date'] as Timestamp).toDate())
          .map((date) => DateTime(date.year, date.month, date.day))
          .toSet();

      return uniqueDays.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> saveCustomWorkout(Map<String, dynamic> workout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId') ?? "anonymous";
      
      await _db.collection('custom_workouts').add({
        ...workout,
        "userId": userId,
        "createdAt": Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCustomWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId == null) return [];

      final querySnapshot = await _db
          .collection('custom_workouts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  // --- AI DISCOVERED WORKOUTS ---

  Future<void> saveAIDiscoveredWorkout(Map<String, dynamic> workout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId') ?? "anonymous";

      // Relaxed validation: Provide defaults if missing
      String title = workout['title']?.toString() ?? "AI Suggested Workout";
      List exercises = (workout['exercises'] is List) ? workout['exercises'] : [];
      
      if (exercises.isEmpty && workout['plan'] != null && workout['plan']['exercises'] != null) {
        exercises = workout['plan']['exercises'];
      }

      if (exercises.isEmpty) return; // Still need at least some exercises

      // Check if already exists to avoid duplicates
      final existing = await _db
          .collection('ai_discovered_workouts')
          .where('userId', isEqualTo: userId)
          .where('title', isEqualTo: title)
          .get();

      if (existing.docs.isEmpty) {
        await _db.collection('ai_discovered_workouts').add({
          ...workout,
          "title": title,
          "userId": userId,
          "discoveredAt": Timestamp.now(),
        });
      }
    } catch (e) {
      print("Error saving AI workout: $e");
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getAIDiscoveredWorkouts() {
    return SharedPreferences.getInstance().asStream().asyncExpand((prefs) {
      String? userId = prefs.getString('userId') ?? "anonymous";
      return _db
          .collection('ai_discovered_workouts')
          .where('userId', isEqualTo: userId)
          // Sort in memory to avoid mandatory Firestore composite index requirement
          .snapshots()
          .map((snapshot) {
        final data = snapshot.docs.map((doc) => doc.data()).toList();
        data.sort((a, b) {
          Timestamp t1 = a['discoveredAt'] ?? Timestamp.now();
          Timestamp t2 = b['discoveredAt'] ?? Timestamp.now();
          return t2.compareTo(t1); // Descending
        });
        return data;
      });
    });
  }

  Stream<QuerySnapshot> getWeightHistory() {
    return SharedPreferences.getInstance().asStream().asyncExpand((prefs) {
      String? userId = prefs.getString('userId') ?? "anonymous";
      return _db
          .collection('weight_history')
          .where('userId', isEqualTo: userId)
          // Removed orderBy to avoid index issues, can sort in UI or here
          .snapshots();
    });
  }
}

