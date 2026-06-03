import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:anglesync/src/core/config/backend_config.dart';
import 'package:anglesync/src/features/scan/domain/exercise_item.dart';

class ReferenceVideoService {
  Future<List<ExerciseItem>> fetchMaleVideos() async {
    final response = await http.get(
      Uri.parse('${BackendConfig.baseUrl}/reference-videos?gender=male'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load reference videos');
    }

    final List data = jsonDecode(response.body);

    return data.map((e) => ExerciseItem.fromJson(e)).toList();
  }
}
