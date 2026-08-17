import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:anglesync/src/core/config/backend_config.dart';
import 'package:anglesync/src/features/history/domain/scan_history_item.dart';

// MODELS
class AnalysisStep {
  final String step;
  final String message;
  final int percent;

  const AnalysisStep({
    required this.step,
    required this.message,
    required this.percent,
  });

  factory AnalysisStep.fromJson(Map<String, dynamic> json) {
    return AnalysisStep(
      step: json['step'] ?? '',
      message: json['message'] ?? '',
      percent: json['percent'] ?? 0,
    );
  }
}

class AnalysisPartial {
  final double score;
  final String riskLevel;
  final int percent;

  const AnalysisPartial({
    required this.score,
    required this.riskLevel,
    required this.percent,
  });

  factory AnalysisPartial.fromJson(Map<String, dynamic> json) {
    return AnalysisPartial(
      score: (json['score'] as num).toDouble(),
      riskLevel: json['risk_level'] ?? '',
      percent: json['percent'] ?? 0,
    );
  }
}

class SelectedFrame {
  final int frame;
  final double time;
  final double risk;
  final String image;

  const SelectedFrame({
    required this.frame,
    required this.time,
    required this.risk,
    required this.image,
  });

  factory SelectedFrame.fromJson(Map<String, dynamic> json) {
    return SelectedFrame(
      frame: json['frame'] ?? 0,
      time: (json['time'] as num?)?.toDouble() ?? 0,
      risk: (json['risk'] as num?)?.toDouble() ?? 0,
      image: json['image'] as String? ?? '',
    );
  }
}

class AnalysisFeedback {
  final String formSummary;
  final List<String> injuryRisk;
  final List<String> correctiveCues;
  final List<String> practicePlan;
  final String? error;

  const AnalysisFeedback({
    required this.formSummary,
    required this.injuryRisk,
    required this.correctiveCues,
    required this.practicePlan,
    this.error,
  });

  bool get hasError => error != null && error!.isNotEmpty;

  static List<String> _toList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String && value.isNotEmpty) {
      final cleaned = value
          .replaceAll(RegExp(r'^\[|\]$'), '')
          .replaceAll("'", '')
          .trim();

      if (cleaned.contains(',')) {
        return cleaned
            .split(RegExp(r',\s*'))
            .map((s) => s.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      if (RegExp(r'\d+\.').hasMatch(cleaned)) {
        return cleaned
            .split(RegExp(r'(?=\d+\.\s)'))
            .map((s) => s.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      return cleaned
          .split(RegExp(r'\.\s+(?=[A-Z])'))
          .map((s) => s.endsWith('.') ? s : '$s.')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  factory AnalysisFeedback.fromJson(Map<String, dynamic> json) {
    return AnalysisFeedback(
      formSummary: json['form_summary'] ?? '',
      injuryRisk: _toList(json['injury_risk']),
      correctiveCues: _toList(json['corrective_cues']),
      practicePlan: _toList(json['practice_plan']),
      error: json['error'],
    );
  }
}

class JointCoordinate {
  final String? jointName;
  final double? x;
  final double? y;

  const JointCoordinate({this.jointName, this.x, this.y});

  factory JointCoordinate.fromJson(Map<String, dynamic> json) {
    return JointCoordinate(
      jointName: json['joint_name'] as String?,
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
    );
  }
}

class RiskFrame {
  final int frameId;
  final int sessionId;
  final int frameNumber;
  final double riskPercentage;
  final String? skeletonOverlayUrl;
  final List<JointCoordinate>? jointCoordinates;

  const RiskFrame({
    required this.frameId,
    required this.sessionId,
    required this.frameNumber,
    required this.riskPercentage,
    this.skeletonOverlayUrl,
    this.jointCoordinates,
  });

  factory RiskFrame.fromJson(Map<String, dynamic> json) {
    final jointsJson = json['joint_coordinates'];
    return RiskFrame(
      frameId: (json['frame_id'] as num?)?.toInt() ?? 0,
      sessionId: (json['session_id'] as num?)?.toInt() ?? 0,
      frameNumber: (json['frame_number'] as num?)?.toInt() ?? 0,
      riskPercentage: (json['risk_percentage'] as num?)?.toDouble() ?? 0,
      skeletonOverlayUrl: json['skeleton_overlay_url'] as String?,
      jointCoordinates: jointsJson is List
          ? jointsJson
                .whereType<Map>()
                .map(
                  (e) => JointCoordinate.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : null,
    );
  }
}

class AnalysisResult {
  final double score;
  final int scoreScale;
  final bool canAnalyze;
  final String status;
  final String riskLevel;
  final SelectedFrame? selectedFrame;
  final AnalysisFeedback? feedback;
  final String exerciseName;
  final List<double> riskScores;
  final List<double> frameTimes;
  final int highestRiskFrameIndex;
  final String? highestRiskImageUrl;
  final List<RiskFrame> riskFrames;

  const AnalysisResult({
    required this.score,
    required this.scoreScale,
    required this.canAnalyze,
    required this.status,
    required this.riskLevel,
    required this.selectedFrame,
    required this.feedback,
    required this.exerciseName,
    this.riskScores = const [],
    this.frameTimes = const [],
    this.riskFrames = const [],
    this.highestRiskFrameIndex = 0,
    this.highestRiskImageUrl,
  });

  bool get isExerciseMismatch => status == 'exercise_mismatch';
  bool get isDetectionFailure => !canAnalyze && !isExerciseMismatch;
  bool get hasFeedbackError => feedback?.hasError ?? false;
  factory AnalysisResult.fromJson(
    Map<String, dynamic> json,
    String exerciseName,
  ) {
    final selectedFrameJson = json['selected_frame'];
    final feedbackJson = json['feedback'];

    final graphData = json['graph_data'] is Map<String, dynamic>
        ? json['graph_data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final rawRiskFrames = json['risk_frames'] is List
        ? json['risk_frames'] as List
        : const [];
    final riskFrames = rawRiskFrames
        .whereType<Map>()
        .map((e) => RiskFrame.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final rawScores =
        graphData['risk_scores'] ??
        riskFrames.map((f) => f.riskPercentage).toList();
    final riskScores = rawScores is List
        ? rawScores.map((e) => (e as num).toDouble()).toList()
        : <double>[];

    final rawTimes =
        graphData['frame_times'] ??
        riskFrames.map((f) => f.frameNumber).toList();
    final frameTimes = rawTimes is List
        ? rawTimes.map((e) => (e as num).toDouble()).toList()
        : <double>[];

    final highestIndex =
        (graphData['highest_risk_frame_index'] as num?)?.toInt() ??
        _highestRiskIndex(riskScores);
    final fallbackImageUrl =
        riskFrames.isNotEmpty && highestIndex < riskFrames.length
        ? riskFrames[highestIndex].skeletonOverlayUrl
        : null;

    return AnalysisResult(
      score:
          (json['score'] as num?)?.toDouble() ??
          (json['accuracy_score'] as num?)?.toDouble() ??
          0,
      scoreScale:
          (json['score_scale'] as num?)?.toInt() ??
          (json.containsKey('accuracy_score') ? 100 : 10),
      canAnalyze: json['can_analyze'] as bool? ?? true,
      status: json['status'] as String? ?? 'completed',
      riskLevel: json['risk_level'] as String? ?? '',
      selectedFrame: selectedFrameJson is Map<String, dynamic>
          ? SelectedFrame.fromJson(selectedFrameJson)
          : null,
      feedback: feedbackJson is Map<String, dynamic>
          ? AnalysisFeedback.fromJson(feedbackJson)
          : null,
      exerciseName: exerciseName,
      riskScores: riskScores,
      frameTimes: frameTimes,
      highestRiskFrameIndex: highestIndex,
      highestRiskImageUrl:
          graphData['highest_risk_image_url'] as String? ?? fallbackImageUrl,
      riskFrames: riskFrames,
    );
  }

  static int _highestRiskIndex(List<double> riskScores) {
    if (riskScores.isEmpty) return 0;
    var highestIndex = 0;
    for (var index = 1; index < riskScores.length; index++) {
      if (riskScores[index] > riskScores[highestIndex]) highestIndex = index;
    }
    return highestIndex;
  }
}

// EVENTS
abstract class AnalysisEvent {}

class StepEvent extends AnalysisEvent {
  final AnalysisStep step;
  StepEvent(this.step);
}

class ProgressEvent extends AnalysisEvent {
  final AnalysisStep step;
  ProgressEvent(this.step);
}

class PartialEvent extends AnalysisEvent {
  final AnalysisPartial partial;
  PartialEvent(this.partial);
}

class ResultEvent extends AnalysisEvent {
  final AnalysisResult result;
  ResultEvent(this.result);
}

class ErrorEvent extends AnalysisEvent {
  final String message;
  ErrorEvent(this.message);
}

// SERVICE
class AnalysisService {
  Stream<AnalysisEvent> analyzeVideo({
    required File videoFile,
    required String exerciseName,
    required int referenceVideoId,
  }) async* {
    final uri = Uri.parse('${BackendConfig.baseUrl}/analyze/stream');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', videoFile.path))
      ..fields['reference_video_id'] = referenceVideoId.toString();

    http.StreamedResponse response;

    try {
      response = await request.send();
    } on SocketException {
      yield ErrorEvent(
        'Cannot connect to backend.\nMake sure FastAPI server is running.',
      );
      return;
    } catch (e) {
      yield ErrorEvent('Connection error: $e');
      return;
    }

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      yield ErrorEvent('Server error ${response.statusCode}: $body');
      return;
    }

    String currentEvent = '';
    String currentData = '';

    await for (final chunk in response.stream.transform(utf8.decoder)) {
      final lines = chunk.split('\n');

      for (final rawLine in lines) {
        final line = rawLine.trim();

        if (line.startsWith('event:')) {
          currentEvent = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          currentData += line.substring(5).trim();
        } else if (line.isEmpty &&
            currentEvent.isNotEmpty &&
            currentData.isNotEmpty) {
          final event = _parseEvent(currentEvent, currentData, exerciseName);

          if (event != null) {
            yield event;
          }

          currentEvent = '';
          currentData = '';
        }
      }
    }
  }

  AnalysisEvent? _parseEvent(String type, String data, String exerciseName) {
    try {
      final json = jsonDecode(data);

      switch (type) {
        case 'step':
          return StepEvent(AnalysisStep.fromJson(json));

        case 'progress':
          return ProgressEvent(AnalysisStep.fromJson(json));

        case 'partial':
          return PartialEvent(AnalysisPartial.fromJson(json));

        case 'result':
          return ResultEvent(AnalysisResult.fromJson(json, exerciseName));

        case 'error':
          return ErrorEvent(json['message'] ?? 'Unknown error');

        default:
          return null;
      }
    } catch (e) {
      return ErrorEvent('Parse error: $e');
    }
  }

  Future<bool> isServerOnline() async {
    try {
      final response = await http
          .get(Uri.parse(BackendConfig.baseUrl))
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class AnalysisException implements Exception {
  final String message;

  const AnalysisException(this.message);

  @override
  String toString() => message;
}

// BACKEND API FUNCTIONS FOR HISTORY
Future<Map<String, dynamic>> saveAnalysisResult({
  required String sessionName,
  required AnalysisResult result,
  required int userId,
  required int referenceVideoId,
  required String videoUserUrl,
}) async {
  final uri = Uri.parse('${BackendConfig.baseUrl}/save-analyze');
  try {
    final riskFramesPayload = buildRiskFramesPayload(result);
    final feedbackPayload = {
      'form_summary': result.feedback?.formSummary ?? '',
      'injury_risk': result.feedback?.injuryRisk ?? const <String>[],
      'corrective_cues': result.feedback?.correctiveCues ?? const <String>[],
      'practice_plan': result.feedback?.practicePlan ?? const <String>[],
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_name': sessionName,
        'user_id': userId,
        'reference_video_id': referenceVideoId,
        'video_user_url': videoUserUrl,
        'accuracy_score': result.score,
        'risk_level': result.riskLevel,
        'risk_frames': riskFramesPayload,
        'feedback': feedbackPayload,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw AnalysisException('Failed to save session: ${response.body}');
    }
  } catch (e) {
    throw AnalysisException('Network error while saving: $e');
  }
}

List<Map<String, dynamic>> buildRiskFramesPayload(AnalysisResult result) {
  // เลือกแหล่งข้อมูลที่มีจำนวนเฟรมเยอะกว่า แทนที่จะเช็คตามลำดับเดิม
  if (result.riskScores.length > result.riskFrames.length &&
      result.riskScores.isNotEmpty) {
    return List.generate(result.riskScores.length, (i) {
      final time =
          i < result.frameTimes.length ? result.frameTimes[i] : i.toDouble();
      return {
        'frame_number': time.toInt(),
        'risk_percentage': result.riskScores[i],
        'highest_risk_image_url': i == result.highestRiskFrameIndex
            ? (result.highestRiskImageUrl ?? result.selectedFrame?.image ?? '')
            : '',
        'joint_coordinates': <String, dynamic>{},
      };
    });
  }

  if (result.riskFrames.isNotEmpty) {
    return result.riskFrames.map((frame) {
      return {
        'frame_number': frame.frameNumber,
        'risk_percentage': frame.riskPercentage,
        'highest_risk_image_url': frame.skeletonOverlayUrl ?? '',
        'joint_coordinates': frame.jointCoordinates
            ?.map((j) => {'joint_name': j.jointName, 'x': j.x, 'y': j.y})
            .toList(),
      };
    }).toList();
  }

  final selectedFrame = result.selectedFrame;
  if (selectedFrame != null) {
    return [
      {
        'frame_number': selectedFrame.frame,
        'risk_percentage': selectedFrame.risk,
        'highest_risk_image_url':
            result.highestRiskImageUrl ?? selectedFrame.image,
        'joint_coordinates': <String, dynamic>{},
      },
    ];
  }

  return [];
}

Future<List<ScanHistoryItem>> fetchAnalysisHistory() async {
  final uri = Uri.parse('${BackendConfig.baseUrl}/history');
  try {
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      List<dynamic> listData = [];

      // เช็คว่า response ส่งมาเป็น List ตรงๆ หรือห่ออยู่ใน Map
      if (decoded is List) {
        listData = decoded;
      } else if (decoded is Map<String, dynamic>) {
        // ลองดึง key ที่ Backend มักใช้ห่อข้อมูล
        if (decoded['data'] is List) {
          listData = decoded['data'];
        } else if (decoded['sessions'] is List) {
          listData = decoded['sessions'];
        } else if (decoded['history'] is List) {
          listData = decoded['history'];
        } else {
          // หากไม่มี key ข้างต้น และอาจเป็น error message ที่ส่งมากับ status 200
          throw AnalysisException(
            decoded['message'] ?? decoded['error'] ?? 'Invalid response format',
          );
        }
      }

      return listData.map((item) => ScanHistoryItem.fromJson(item)).toList();
    } else {
      throw AnalysisException(
        'Failed to fetch history (${response.statusCode})',
      );
    }
  } catch (e) {
    throw AnalysisException('Error loading history: $e');
  }
}

Future<AnalysisSessionDetail> fetchAnalysisSessionDetail(int sessionId) async {
  final uri = Uri.parse('${BackendConfig.baseUrl}/history/$sessionId');
  try {
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      final sessionDetail = AnalysisSessionDetail.fromJson(json);

      final analysisJson = json['analysis_result'] is Map
          ? Map<String, dynamic>.from(json['analysis_result'] as Map)
          : <String, dynamic>{};

      final analysisResult = AnalysisResult.fromJson(
        analysisJson,
        sessionDetail.title,
      );

      return AnalysisSessionDetail(
        sessionId: sessionDetail.sessionId,
        title: sessionDetail.title,
        referenceVideoId: sessionDetail.referenceVideoId,
        videoUserUrl: sessionDetail.videoUserUrl,
        result: {...json, 'analysis_obj': analysisResult},
      );
    } else {
      throw AnalysisException('Failed to fetch session detail.');
    }
  } catch (e) {
    throw AnalysisException('Error fetching detail: $e');
  }
}

Future<void> deleteAnalysisSession(int sessionId) async {
  final uri = Uri.parse('${BackendConfig.baseUrl}/history/$sessionId');
  try {
    final response = await http
        .delete(uri)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw AnalysisException(
        'Failed to delete scan session (${response.statusCode}).',
      );
    }
  } on TimeoutException {
    throw const AnalysisException(
      'Delete timed out. The server may still be processing — please check History and try again.',
    );
  } on AnalysisException {
    rethrow;
  } catch (e) {
    throw AnalysisException('Error deleting scan: $e');
  }
}

class AnalysisSessionDetail {
  final int sessionId;
  final String title;
  final int referenceVideoId;
  final String videoUserUrl;
  final Map<String, dynamic> result;

  const AnalysisSessionDetail({
    required this.sessionId,
    required this.title,
    required this.referenceVideoId,
    required this.videoUserUrl,
    required this.result,
  });

  factory AnalysisSessionDetail.fromJson(Map<String, dynamic> json) {
    return AnalysisSessionDetail(
      sessionId: (json['session_id'] as num?)?.toInt() ?? 0,
      title: json['session_name'] as String? ?? json['title'] as String? ?? '',
      referenceVideoId: (json['reference_video_id'] as num?)?.toInt() ?? 0,
      videoUserUrl: json['video_user_url'] as String? ?? '',
      result: json['result'] is Map<String, dynamic>
          ? json['result'] as Map<String, dynamic>
          : {},
    );
  }
}
