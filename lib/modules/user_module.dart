class UserModel {
  String? userId;
  String? name;
  int? age;
  String? gender;
  String? goal;
  String? focusArea;
  int? weeklyGoal;
  double? weight; // in lbs or kg
  double? height; // in cm
  String? pushupsLevel;
  String? profileImageUrl;

  // Singleton pattern to access user data anywhere
  static final UserModel _instance = UserModel._internal();
  
  factory UserModel() {
    return _instance;
  }

  UserModel._internal();

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "name": name,
      "age": age,
      "gender": gender,
      "goal": goal,
      "focusArea": focusArea,
      "weeklyGoal": weeklyGoal,
      "weight": weight,
      "height": height,
      "pushupsLevel": pushupsLevel,
      "profileImageUrl": profileImageUrl,
    };
  }

  void fromMap(Map<String, dynamic> map) {
    userId = map['userId'];
    name = map['name'];
    age = map['age'];
    gender = map['gender'];
    goal = map['goal'];
    focusArea = map['focusArea'];
    weeklyGoal = map['weeklyGoal'];
    weight = (map['weight'] as num?)?.toDouble();
    height = (map['height'] as num?)?.toDouble();
    pushupsLevel = map['pushupsLevel'];
    profileImageUrl = map['profileImageUrl'];
  }
}
