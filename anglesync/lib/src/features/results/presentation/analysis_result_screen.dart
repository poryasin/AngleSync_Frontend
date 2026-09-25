import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../core/service/analysis_service.dart';
import '../../../core/service/auth_service.dart';
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
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false, 
        titleSpacing: 8,    
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.chevron_left,
                size: 20,
                color: AppTheme.textDark, 
              ),
              SizedBox(width: 4),
              Text(
                'Upload',
                style: TextStyle(
                  fontSize: 17,
                  color: AppTheme.textDark, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            StreamBuilder<AnalysisEvent>(
              stream: widget.analysisStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _buildProgress(context, 'Uploading video...', 10);
                }

                final event = snapshot.data!;

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

                if (event is ErrorEvent) {
                  if (_isDetectionFailureMessage(event.message)) {
                    return _buildDetectionFailure(context);
                  }

                  return _buildError(context, event.message);
                }

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

            if (_isDeleting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 22,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppTheme.green),
                          SizedBox(width: 18),
                          Text(
                            'Deleting result...',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
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

  Widget _buildProgress(BuildContext context, String message, int percent) {
    return Center(
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
              backgroundColor: AppTheme.green.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            '$percent%',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, AnalysisResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
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
          _buildFeedbackCard(
            title: 'Form Summary',
            items: const [],
            icon: Icons.assignment_outlined,
            customContent: Text(
              result.feedback?.formSummary ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeedbackCard(
            title: 'Injury Risk',
            items: result.feedback?.injuryRisk ?? [],
            icon: Icons.shield_outlined,
            iconColor: Colors.red.shade600,
            iconBg: Colors.red.withValues(alpha: 0.1),
            useBullet: true,
          ),
          const SizedBox(height: 16),
          _buildFeedbackCard(
            title: 'Corrective Cues',
            items: result.feedback?.correctiveCues ?? [],
            icon: Icons.track_changes_outlined,
          ),
          const SizedBox(height: 16),
          _buildFeedbackCard(
            title: 'Practice Plan',
            items: result.feedback?.practicePlan ?? [],
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 24),
          _buildResultActionButton(context, result),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildResultActionButton(BuildContext context, AnalysisResult result) {
    if (widget.isSavedSession) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: _isDeleting ? null : () => _handleDeleteResult(context),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          label: const Text(
            "Delete Result",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: () async {
          final sessionName = await SaveSessionDialog.show(context);
          if (sessionName == null || !context.mounted) return;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(color: AppTheme.green),
            ),
          );

          try {
            final authService = AuthService();
            final currentUserId =
                await authService.getCurrentUserId() ?? widget.userId;

            await saveAnalysisResult(
              sessionName: sessionName,
              result: result,
              userId: currentUserId,
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
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.message)));
          }
        },
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.save_rounded, color: Colors.white),
        label: const Text(
          "Save Result",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
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
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Delete result?',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This analysis session will be permanently deleted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textDark,
                        side: BorderSide(color: Colors.grey.shade300),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await deleteAnalysisSession(id);
      if (!mounted) return;

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

  Widget _buildScoreCard(AnalysisResult result) {
    final scale = result.scoreScale <= 0 ? 100 : result.scoreScale;
    final score = result.score.clamp(0, scale).toDouble();
    final progress = score / scale;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: AppTheme.green,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "POSTURE SCORE",
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 1.2,
                      color: Color(0xFF667085),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  result.riskLevel.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: score.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 68,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.green,
                    height: 1,
                    letterSpacing: -2,
                  ),
                ),
                const TextSpan(
                  text: "/100",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xFFEAEAEA),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.green),
            ),
          ),
        ],
      ),
    );
  }

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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg ?? AppTheme.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon ?? Icons.info_outline,
                  color: iconColor ?? AppTheme.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 14),
          if (customContent != null)
            customContent
          else if (items.isEmpty)
            Text(
              'No feedback provided.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
                          padding: const EdgeInsets.only(top: 7),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: iconColor ?? AppTheme.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: iconBg ?? AppTheme.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: iconColor ?? AppTheme.green,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    widget.onMismatch?.call();
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Choose another video',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            error,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}