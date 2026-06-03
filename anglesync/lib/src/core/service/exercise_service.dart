import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:anglesync/src/core/config/backend_config.dart';
import 'package:anglesync/src/features/scan/domain/exercise_item.dart';

class ExerciseService {
  static Future<List<ExerciseItem>> fetchExercises() async {
    final response = await http.get(
      Uri.parse('${BackendConfig.baseUrl}/exercises'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map<ExerciseItem>((json) {
        return ExerciseItem(
          id: json['reference_video_id'] ?? 0,
          title: json['exercise_name'] ?? '',
          gender: json['reference_gender'] ?? '',
          category: json['reference_gender'] ?? '',
          thumbnailUrl: BackendConfig.resolveUrl(json['thumbnail_url']),
          videoUrl: BackendConfig.resolveUrl(json['reference_video_url']),
          description: json['reference_gender'] ?? '',
        );
      }).toList();
    } else {
      throw Exception('Failed to load exercises');
    }
  }
}
