import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../core/service/analysis_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/risk_graph.dart';
import '../widgets/analysis_details.dart';

class AnalysisResultScreen extends StatelessWidget {
  final Stream<AnalysisEvent> analysisStream;
  final VoidCallback? onMismatch;

  const AnalysisResultScreen({
    super.key,
    required this.analysisStream,
    this.onMismatch,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      body: SafeArea(
        child: StreamBuilder<AnalysisEvent>(
          stream: analysisStream,
          builder: (context, snapshot) {
            //
            // LOADING
            //
            if (!snapshot.hasData) {
              return _buildLoading(context);
            }

            final event = snapshot.data!;

            //
            // STEP / PROGRESS
            //
            if (event is StepEvent) {
              return _buildProgress(
                context,
                event.step.message,
                event.step.percent,
              );
            }

            if (event is ProgressEvent) {
              return _buildProgress(
                context,
                event.step.message,
                event.step.percent,
              );
            }

            //
            // ERROR
            //
            if (event is ErrorEvent) {
              return _buildError(context, event.message);
            }

            //
            // RESULT
            //
            if (event is ResultEvent) {
              if (event.result.isExerciseMismatch) {
                return _buildMismatch(context, event.result);
              }

              return _buildResult(context, event.result);
            }

            return _buildLoading(context);
          },
        ),
      ),
    );
  }

  //
  // LOADING
  //
  Widget _buildLoading(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.green),
    );
  }

  //
  // PROGRESS
  //
  Widget _buildProgress(BuildContext context, String message, int percent) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      body: SafeArea(
        child: Column(
          children: [
            _appBar(context),

            const Divider(height: 1),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: percent / 100,
                        strokeWidth: 7,
                        color: AppTheme.green,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //
  // RESULT
  //
  Widget _buildResult(BuildContext context, AnalysisResult result) {
    final feedback = result.feedback;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      body: SafeArea(
        child: Column(
          children: [
            // APP BAR
            _appBar(context),

            const Divider(height: 1, thickness: 1),

            // BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreCard(result),

                    const SizedBox(height: 20),
                    if (result.riskScores.isNotEmpty)
                      RiskGraph(
                        riskScores: result.riskScores,
                        frameTimes: result.frameTimes,
                        highestRiskFrameIndex: result.highestRiskFrameIndex,
                        highestRiskImageUrl: result.highestRiskImageUrl,
                      ),

                    if (result.riskScores.isNotEmpty)
                      const SizedBox(height: 20),

                    // Form Summary
                    _buildFeedbackCard(
                      title: 'Form Summary',
                      items: [],
                      icon: Icons.assignment_outlined,
                      customContent: Text(
                        result.feedback?.formSummary ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF444444),
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Injury Risk
                    _buildFeedbackCard(
                      title: 'Injury Risk',
                      items: result.feedback?.injuryRisk ?? [],
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFFE53935),
                      iconBg: const Color(0xFFFFECEC),
                      useBullet: true,
                    ),
                    const SizedBox(height: 12),

                    // Corrective Cues
                    _buildFeedbackCard(
                      title: 'Corrective Cues',
                      items: result.feedback?.correctiveCues ?? [],
                      icon: Icons.track_changes_outlined,
                    ),
                    const SizedBox(height: 12),

                    // Practice Plan
                    _buildFeedbackCard(
                      title: 'Practice Plan',
                      items: result.feedback?.practicePlan ?? [],
                      icon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Result Saved"),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          await Future.delayed(const Duration(seconds: 2));

                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRouter.home,
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.green,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          "Save Result",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //
  // SCORE CARD
  //
  Widget _buildScoreCard(AnalysisResult result) {
    final scale = result.scoreScale <= 0 ? 100 : result.scoreScale;
    final score = result.score.clamp(0, scale).toDouble();
    final progress = score / scale;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //
          // TOP ROW
          //
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: Colors.green,
                    size: 20,
                  ),

                  SizedBox(width: 8),

                  Text(
                    "POSTURE SCORE",
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 1.5,
                      color: Color(0xFF667085),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF5E5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  result.riskLevel.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          //
          // SCORE
          //
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: score.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Colors.green,
                    height: 1,
                    letterSpacing: -2,
                  ),
                ),

                TextSpan(
                  text: "/$scale",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          //
          // PROGRESS BAR
          //
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: const Color(0xFFEAEAEA),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  //
  // FEEDBACK CARD
  //
  Widget _buildFeedbackCard({
  required String title,
  required List<String> items,
  Widget? customContent,
  IconData? icon,
  Color? iconColor,
  Color? iconBg,
  bool useBullet = false,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg ?? const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon ?? Icons.info_outline,
                color: iconColor ?? Colors.green,
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(color: Color(0xFFF5F5F5), height: 1),
        const SizedBox(height: 14),

        // Content
        if (customContent != null)
          customContent
        else if (items.isEmpty)
          Text(
            'No feedback provided.',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (useBullet)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: iconColor ?? Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: iconBg ?? const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: iconColor ?? Colors.green,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    ),
  );
}

  Widget _buildMismatch(BuildContext context, AnalysisResult result) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      body: SafeArea(
        child: Column(
          children: [
            _appBar(context),
            const Divider(height: 1),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.orange,
                          size: 44,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Exercise mismatch',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This video does not match ${result.exerciseName}. Please upload a video for the selected exercise.',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              onMismatch?.call(); // clear video in UploadScreen
                              Navigator.pop(context); // back to UploadScreen
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.green,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Choose another video',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //
  // ERROR
  //
  Widget _buildError(BuildContext context, String error) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      body: SafeArea(
        child: Column(
          children: [
            _appBar(context),

            const Divider(height: 1),

            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.chevron_left,
                size: 20,
                color: CupertinoColors.activeBlue,
              ),

              SizedBox(width: 4),

              Text(
                'Upload',
                style: TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
