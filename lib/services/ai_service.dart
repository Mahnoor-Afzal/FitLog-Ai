import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modules/user_module.dart';

class AIService {
  // IMPORTANT: Do not hardcode API keys in public repositories.
  // Set your OpenRouter API key here or use environment variables.
  static const String _apiKey = 'YOUR_OPENROUTER_API_KEY_HERE';

  // 2. URL must be exact
  static const String _url = 'https://openrouter.ai/api/v1/chat/completions';

  static Future<Map<String, dynamic>> getAIResponse(String userMessage) async {
    final user = UserModel();

    String systemPrompt = """
    You are an expert AI Fitness Coach. 
    User Profile: 
    - Gender: ${user.gender ?? 'Not set'}
    - Goal: ${user.goal ?? 'General Fitness'}
    - Focus: ${user.focusArea ?? 'Full Body'}
    - Current Weight: ${user.weight ?? 'Not set'} lbs
    - Current Height: ${user.height ?? 'Not set'} cm
    - Experience: ${user.pushupsLevel ?? 'Beginner'}
    - Weekly Goal: ${user.weeklyGoal ?? 3} workouts/week

    Personalize your advice and plans based on the user's current weight, goal, and experience level.
    If they want to lose weight, focus on cardio and high-calorie burn. 
    If they want muscle, focus on strength training and protein-rich diet advice.

    Response MUST be a valid JSON object. 
    If the user asks for a workout plan or general fitness advice, include a 'plan' object.
    If the user asks about food or nutrition, include a 'diet' object.

    JSON structure:
    {
      "message": "Your text advice here",
      "plan": {
        "title": "Workout Name",
        "duration": "20 mins",
        "exercises_count": "10 Exercises",
        "intensity": 2,
        "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=300",
        "exercises": [
          {
            "name": "Exercise Name", 
            "seconds": 30, 
            "image": "https://images.unsplash.com/photo-1594882645126-14020914d58d?q=80&w=600",
            "description": "Short clear instructions."
          }
        ]
      },
      "diet": {
        "title": "Diet Plan Name", 
        "desc": "Summary of the diet recommendation", 
        "calories": "Estimated daily calories"
      }
    }

    Important Guidelines:
    1. Return ONLY raw JSON. No markdown, no "```json" blocks.
    2. Ensure the 'plan' has a realistic list of exercises if requested.
    3. 'exercises_count' should be a string like "10 Exercises".
    4. Image URLs should be valid Unsplash URLs with parameters (e.g., ?q=80&w=600).
    5. If 'plan' or 'diet' is not applicable to the user's request, set them to null.
    """;

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'http://localhost', // Web testing ke liye zarori hai
          'X-Title': 'FitLog AI',
        },
        body: jsonEncode({
          // 3. 'openrouter/auto' automatically best available free model select kar leta hai
          'model': 'openrouter/auto',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
        }),
      );

      print("Response Status: ${response.statusCode}"); // Debugging ke liye

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];

        // Cleaning logic
        if (content.contains("```")) {
          content = content.replaceAll(RegExp(r'```json|```'), '').trim();
        }

        try {
          return jsonDecode(content);
        } catch (e) {
          return {"message": content, "plan": null, "diet": null};
        }
      } else {
        // Detailed Error message
        var errorData = jsonDecode(response.body);
        return {
          "message": "AI Error (${response.statusCode}): ${errorData['error']['message'] ?? 'Unknown Error'}"
        };
      }
    } catch (e) {
      return {
        "message": "Connection Error: Please check your internet or CORS settings."
      };
    }
  }
}