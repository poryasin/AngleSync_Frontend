import 'package:anglesync/src/core/service/analysis_service.dart';
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

    test('keeps detection failures as exercise mismatches', () {
      final result = AnalysisResult.fromJson({
        'can_analyze': false,
        'status': 'exercise_mismatch',
      }, 'Push up_men');

      expect(result.isExerciseMismatch, isTrue);
      expect(result.hasFeedbackError, isFalse);
    });
  });
}
