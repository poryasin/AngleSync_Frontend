import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../core/service/analysis_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/risk_graph.dart';
import '../widgets/save_session_dialog.dart';

class AnalysisResultScreen extends StatefulWidget {
  final Stream<AnalysisEvent> analysisStream;
  final VoidCallback? onMismatch;
  final int userId;
  final int referenceVideoId;
  final String videoUserUrl;
  final bool isSavedSession;
  final int? sessionId;

  const AnalysisResultScreen({
    super.key,
    required this.analysisStream,
    required this.userId,
    required this.referenceVideoId,
    required this.videoUserUrl,
    this.onMismatch,
    this.isSavedSession = false,
    this.sessionId,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  // true ระหว่างกำลังลบ session -> โชว์ overlay ทับหน้าจอเดิม แทนการ push dialog แยก route
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      body: SafeArea(
        child: Stack(
          children: [
            StreamBuilder<AnalysisEvent>(
              stream: widget.analysisStream,
              builder: (context, snapshot) {
                //
                // LOADING
                //
                if (!snapshot.hasData) {
                  return _buildProgress(context, 'Uploading video...', 10);
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
                  if (_isDetectionFailureMessage(event.message)) {
                    return _buildDetectionFailure(context);
                  }

                  return _buildError(context, event.message);
                }

                //
                // RESULT
                //
                if (event is ResultEvent) {
                  if (event.result.isExerciseMismatch) {
                    return _buildExerciseMismatch(context, event.result);
                  }

                  if (event.result.isDetectionFailure) {
                    return _buildDetectionFailure(context);
                  }

                  if (event.result.hasFeedbackError) {
                    return _buildError(
                      context,
                      'Analysis failed. Please try again later.',
                    );
                  }

                  return _buildResult(context, event.result);
                }

                return _buildProgress(context, 'Analyzing posture...', 0);
              },
            ),

            // Overlay ตอนกำลังลบ (แทนการ push dialog แยก route)
            if (_isDeleting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 22,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppTheme.green),
                          SizedBox(width: 18),
                          Text('Deleting result...'),
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
  // PROGRESS
  //
  Widget _buildProgress(BuildContext context, String message, int percent) {
    return Column(
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
    );
  }

  //
  // RESULT
  //
  Widget _buildResult(BuildContext context, AnalysisResult result) {
    return Column(
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

                if (result.riskScores.isNotEmpty) const SizedBox(height: 20),

                // Form Summary
                _buildFeedbackCard(
                  title: 'Form Summary',
                  items: const [],
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

                _buildResultActionButton(context, result),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultActionButton(BuildContext context, AnalysisResult result) {
    if (widget.isSavedSession) {
      return SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton.icon(
          onPressed: _isDeleting ? null : () => _handleDeleteResult(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53935),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          label: const Text(
            "Delete Result",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: () async {
          final sessionName = await SaveSessionDialog.show(context);
          if (sessionName == null || !context.mounted) return;

          // แสดง loading ระหว่างรอ
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            await saveAnalysisResult(
              sessionName: sessionName,
              result: result,
              userId: widget.userId,
              referenceVideoId: widget.referenceVideoId,
              videoUserUrl: widget.videoUserUrl,
            );

            if (!context.mounted) return;
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Saved as "$sessionName"'),
                duration: const Duration(seconds: 2),
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
          } on AnalysisException catch (e) {
            if (!context.mounted) return;
            Navigator.pop(context); // ปิด loading dialog
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.message)));
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
    );
  }

  Future<void> _handleDeleteResult(BuildContext context) async {
    final id = widget.sessionId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete: session ID is missing.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete result?'),
        content: const Text(
          'This analysis session will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // เปิด overlay ในหน้าเดิม แทนการ push dialog เป็น route ใหม่
    setState(() => _isDeleting = true);

    try {
      await deleteAnalysisSession(id);
      if (!mounted) return;

      // ปิด overlay ก่อน แล้วรอ 1 เฟรมให้หน้าจอ render กลับมาปกติ
      // ก่อนค่อย pop กันปัญหา compositor เจอ overlay ซ้อนกับ transition
      setState(() => _isDeleting = false);
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on AnalysisException catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: ${error.message}')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $error')));
    }
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

  bool _isDetectionFailureMessage(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('detection failed') ||
        normalized.contains('keypoint not found');
  }

  Widget _buildExerciseMismatch(BuildContext context, AnalysisResult result) {
    return _buildRetryCard(
      context: context,
      title: 'Exercise mismatch',
      message:
          'This video does not match ${result.exerciseName}. Please upload a video for the selected exercise.',
    );
  }

  Widget _buildDetectionFailure(BuildContext context) {
    return _buildRetryCard(
      context: context,
      title: 'Keypoint not found',
      message: 'Please ensure that the person is visible.',
    );
  }

  Widget _buildRetryCard({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return Column(
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
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
                          widget.onMismatch?.call(); // clear video in UploadScreen
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
    );
  }

  //
  // ERROR
  //
  Widget _buildError(BuildContext context, String error) {
    return Column(
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