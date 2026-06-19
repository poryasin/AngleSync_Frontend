import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:anglesync/src/core/config/backend_config.dart';

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

  const SelectedFrame({
    required this.frame,
    required this.time,
    required this.risk,
  });

  factory SelectedFrame.fromJson(Map<String, dynamic> json) {
    return SelectedFrame(
      frame: json['frame'] ?? 0,
      time: (json['time'] as num?)?.toDouble() ?? 0,
      risk: (json['risk'] as num?)?.toDouble() ?? 0,
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
      // ลบ [ ] และ '
      final cleaned = value
          .replaceAll(RegExp(r'^\[|\]$'), '')
          .replaceAll("'", '')
          .trim();

      // ถ้ามี comma ให้ split ด้วย comma ก่อน
      if (cleaned.contains(',')) {
        return cleaned
            .split(RegExp(r',\s*'))
            .map((s) => s.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      // ถ้าเป็น numbered list เช่น "1. xxx 2. xxx"
      if (RegExp(r'\d+\.').hasMatch(cleaned)) {
        return cleaned
            .split(RegExp(r'(?=\d+\.\s)'))
            .map((s) => s.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      // ถ้าเป็น sentence หลายประโยคคั่นด้วย '. '
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

    final rawScores = graphData['risk_scores'];
    final riskScores = rawScores is List
        ? rawScores.map((e) => (e as num).toDouble()).toList()
        : <double>[];

    final rawTimes = graphData['frame_times'];
    final frameTimes = rawTimes is List
        ? rawTimes.map((e) => (e as num).toDouble()).toList()
        : <double>[];

    return AnalysisResult(
      score: (json['score'] as num?)?.toDouble() ?? 0,
      scoreScale: (json['score_scale'] as num?)?.toInt() ?? 10,
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
      highestRiskFrameIndex:
          (graphData['highest_risk_frame_index'] as num?)?.toInt() ?? 0,
      highestRiskImageUrl: graphData['highest_risk_image_url'] as String?,
    );
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
