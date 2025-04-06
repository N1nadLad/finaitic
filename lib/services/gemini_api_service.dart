import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiAPIService { // Replace with your actual API key
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyBjXMiILEBtZypxEoI9RhucuA_bri4w0Rs";

  static Future<String> getResponse(String prompt) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final candidates = data['candidates'];
      
      if (candidates != null && candidates.isNotEmpty) {
        return candidates[0]['content']['parts'][0]['text'] ?? "No response.";
      } else {
        return "No valid response from AI.";
      }
    } else {
      return "Error: ${response.statusCode} - ${response.body}";
    }
  }
}