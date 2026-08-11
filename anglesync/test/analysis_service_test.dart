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
