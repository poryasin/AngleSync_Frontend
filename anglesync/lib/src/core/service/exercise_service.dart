import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:anglesync/src/features/scan/domain/exercise_item.dart';

class ExerciseService {
  static const String baseUrl = 'http://192.168.1.163:8000';

  static Future<List<ExerciseItem>> fetchExercises() async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map<ExerciseItem>((json) {
        return ExerciseItem(
          id: json['id'] ?? 0,
          title: json['exercise_name'] ?? '',
          gender: json['reference_gender'] ?? '',
          category: json['reference_gender'] ?? '',
          thumbnailUrl: json['thumbnail_url'] ?? '',
          videoUrl: json['reference_video_url'] ?? '',
          description: json['reference_video_url'] ?? '',
        );
      }).toList();
    } else {
      throw Exception('Failed to load exercises');
    }
  }
}