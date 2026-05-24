import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../core/service/analysis_service.dart';
import '../../../core/theme/app_theme.dart';

class AnalysisResultScreen extends StatelessWidget {
  final Stream<AnalysisEvent> analysisStream;

  const AnalysisResultScreen({
    super.key,
    required this.analysisStream,
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
              return _buildError(
                context,
                event.message,
              );
            }

            //
            // RESULT
            //
            if (event is ResultEvent) {
              return _buildResult(
                context,
                event.result,
              );
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
      child: CircularProgressIndicator(
        color: AppTheme.green,
      ),
    );
  }

  //
  // PROGRESS
  //
  Widget _buildProgress(
    BuildContext context,
    String message,
    int percent,
  ) {
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
  Widget _buildResult(
    BuildContext context,
    AnalysisResult result,
  ) {
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
                padding: const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreCard(result),

                    const SizedBox(height: 20),

                    _buildFeedbackCard(
                      title: "Form Summary",
                      content: result.feedback.formSummary,
                    ),

                    const SizedBox(height: 20),

                    _buildFeedbackCard(
                      title: "Injury Risk",
                      content: result.feedback.injuryRisk,
                    ),

                    const SizedBox(height: 20),

                    _buildFeedbackCard(
                      title: "Corrective Cues",
                      content: result.feedback.correctiveCues,
                    ),

                    const SizedBox(height: 20),

                    _buildFeedbackCard(
                      title: "Practice Plan",
                      content: result.feedback.practicePlan,
                    ),

                    const SizedBox(height: 32),

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
                        icon: const Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
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
    final score = result.score.clamp(0, 100);

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

                const TextSpan(
                  text: "/10",
                  style: TextStyle(
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
              value: score / 10,
              minHeight: 14,
              backgroundColor: const Color(0xFFEAEAEA),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.green,
              ),
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
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  //
  // ERROR
  //
  Widget _buildError(
    BuildContext context,
    String error,
  ) {
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
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
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

  //
  // APP BAR
  //
  Widget _appBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12,
      ),
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