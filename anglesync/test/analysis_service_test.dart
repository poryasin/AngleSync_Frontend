import 'package:anglesync/src/core/service/analysis_service.dart';
import 'package:anglesync/src/features/history/domain/scan_history_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalysisResult', () {
    test('reports a feedback error without treating it as a mismatch', () {
      final result = AnalysisResult.fromJson({
        'can_analyze': true,
        'status': 'completed',
        'feedback': {
          'form_summary': 'AI feedback unavailable.',
          'injury_risk': ['name _generate_with_zai is not defined'],
          'corrective_cues': ['Please retry later.'],
          'practice_plan': ['Please retry later.'],
          'error': 'name _generate_with_zai is not defined',
        },
      }, 'Push up_men');

      expect(result.isExerciseMismatch, isFalse);
      expect(result.hasFeedbackError, isTrue);
    });

    test('keeps exercise mismatches separate from detection failures', () {
      final result = AnalysisResult.fromJson({
        'can_analyze': false,
        'status': 'exercise_mismatch',
      }, 'Push up_men');

      expect(result.isExerciseMismatch, isTrue);
      expect(result.isDetectionFailure, isFalse);
      expect(result.hasFeedbackError, isFalse);
    });

    test('reports non-mismatch canAnalyze failures as detection failures', () {
      final result = AnalysisResult.fromJson({
        'can_analyze': false,
        'status': 'keypoint_not_found',
      }, 'Push up_men');

      expect(result.isExerciseMismatch, isFalse);
      expect(result.isDetectionFailure, isTrue);
    });

    test('builds only the highest risk frame from graph data', () {
      final result = AnalysisResult.fromJson({
        'score': 84.4,
        'score_scale': 100,
        'graph_data': {
          'risk_scores': [12.5, 44.2, 31.8],
          'frame_times': [0.1, 0.2, 0.3],
          'highest_risk_frame_index': 1,
          'highest_risk_image_url': 'https://example.com/high-risk.jpg',
        },
      }, 'Push up_men');

      final payload = buildRiskFramesPayload(result);

      expect(payload, hasLength(1));
      expect(payload.first['frame_number'], 2);
      expect(payload.first['risk_percentage'], 44.2);
      expect(
        payload.first['highest_risk_image_url'],
        'https://example.com/high-risk.jpg',
      );
    });

    test('builds a savable risk frame from selected frame fallback', () {
      final result = AnalysisResult.fromJson({
        'score': 84.4,
        'score_scale': 100,
        'selected_frame': {
          'frame': 25,
          'time': 0.83,
          'risk': 72.1,
          'image': 'https://example.com/selected.jpg',
        },
      }, 'Push up_men');

      final payload = buildRiskFramesPayload(result);

      expect(payload, hasLength(1));
      expect(payload.first['frame_number'], 25);
      expect(payload.first['risk_percentage'], 72.1);
      expect(
        payload.first['highest_risk_image_url'],
        'https://example.com/selected.jpg',
      );
    });
  });

  test('uses session_id from a history response', () {
    final session = ScanHistoryItem.fromJson({
      'session_id': 42,
      'session_name': 'Squat form check',
      'accuracy_score': 88,
      'analysis_date': '2026-08-06T10:30:00Z',
    });

    expect(session.id, 42);
    expect(session.title, 'Squat form check');
    expect(session.score, 88);
  });
}
