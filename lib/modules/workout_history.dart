import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutHistory {
  final String workoutTitle;
  final int calories;
  final int minutes;
  final DateTime date;

  WorkoutHistory({
    required this.workoutTitle,
    required this.calories,
    required this.minutes,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      "workoutTitle": workoutTitle,
      "calories": calories,
      "minutes": minutes,
      "date": Timestamp.fromDate(date),
    };
  }
}
