// lib/core/services/analysis_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

//
// MODELS
//

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
      frame: json['frame'],
      time: (json['time'] as num).toDouble(),
      risk: (json['risk'] as num).toDouble(),
    );
  }
}

class AnalysisFeedback {
  final String formSummary;
  final String injuryRisk;
  final String correctiveCues;
  final String practicePlan;
  final String? error;

  const AnalysisFeedback({
    required this.formSummary,
    required this.injuryRisk,
    required this.correctiveCues,
    required this.practicePlan,
    this.error,
  });

  bool get hasError => error != null && error!.isNotEmpty;

  factory AnalysisFeedback.fromJson(Map<String, dynamic> json) {
    return AnalysisFeedback(
      formSummary: json['form_summary'] ?? '',
      injuryRisk: json['injury_risk'] ?? '',
      correctiveCues: json['corrective_cues'] ?? '',
      practicePlan: json['practice_plan'] ?? '',
      error: json['error'],
    );
  }
}

class AnalysisResult {
  final double score;
  final String riskLevel;
  final SelectedFrame selectedFrame;
  final AnalysisFeedback feedback;
  final String exerciseName;

  const AnalysisResult({
    required this.score,
    required this.riskLevel,
    required this.selectedFrame,
    required this.feedback,
    required this.exerciseName,
  });

  factory AnalysisResult.fromJson(
    Map<String, dynamic> json,
    String exerciseName,
  ) {
    return AnalysisResult(
      score: (json['score'] as num).toDouble(),
      riskLevel: json['risk_level'],
      selectedFrame: SelectedFrame.fromJson(json['selected_frame']),
      feedback: AnalysisFeedback.fromJson(json['feedback']),
      exerciseName: exerciseName,
    );
  }
}

//
// EVENTS
//

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

//
// SERVICE
//

class AnalysisService {
  static const String _baseUrl = 'http://192.168.1.163:8000';

  Stream<AnalysisEvent> analyzeVideo({
    required File videoFile,
    required String exerciseName,
  }) async* {
    final uri = Uri.parse('$_baseUrl/analyze/stream');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath(
          'file', // ต้องตรงกับ FastAPI
          videoFile.path,
        ),
      );

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
          final event = _parseEvent(
            currentEvent,
            currentData,
            exerciseName,
          );

          if (event != null) {
            yield event;
          }

          currentEvent = '';
          currentData = '';
        }
      }
    }
  }

  AnalysisEvent? _parseEvent(
    String type,
    String data,
    String exerciseName,
  ) {
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
          return ResultEvent(
            AnalysisResult.fromJson(json, exerciseName),
          );

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
          .get(Uri.parse(_baseUrl))
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