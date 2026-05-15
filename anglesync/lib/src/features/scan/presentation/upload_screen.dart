import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/exercise_detail.dart';

class UploadScreen extends StatefulWidget {
  final ExerciseDetail exercise;

  const UploadScreen({super.key, required this.exercise});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _hasVideo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _UploadAppBar(title: widget.exercise.title),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reference section
                    _ReferenceSection(exercise: widget.exercise),
                    const SizedBox(height: 28),

                    // Your Video section
                    _YourVideoSection(
                      hasVideo: _hasVideo,
                      onUploadTap: () {
                        // TODO: implement file picker
                        setState(() => _hasVideo = true);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Analyze card
                    _AnalyzeCard(hasVideo: _hasVideo),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// App Bar
class _UploadAppBar extends StatelessWidget {
  final String title;

  const _UploadAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.arrow_left,
                size: 18,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// Reference Section
class _ReferenceSection extends StatelessWidget {
  final ExerciseDetail exercise;

  const _ReferenceSection({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + category badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'REFERENCE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 1.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                exercise.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Video player placeholder
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              // Play button
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.play_fill,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              // Bottom bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.play_fill,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '0:00',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      const Spacer(),
                      Icon(
                        CupertinoIcons.speaker_slash_fill,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        CupertinoIcons.fullscreen,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        CupertinoIcons.ellipsis_vertical,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              // Progress bar
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: 0,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          exercise.description,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// Your Video Section
class _YourVideoSection extends StatelessWidget {
  final bool hasVideo;
  final VoidCallback onUploadTap;

  const _YourVideoSection({
    required this.hasVideo,
    required this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR VIDEO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),

        // Upload area
        GestureDetector(
          onTap: onUploadTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                // Upload icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    CupertinoIcons.arrow_up_to_line,
                    color: AppTheme.green,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload your workout video',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Drop a clip here, or click to browse. MP4 /\nMOV, not exceed 60 seconds.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.videocam,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Processed locally on your device',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Analyze Card
class _AnalyzeCard extends StatelessWidget {
  final bool hasVideo;

  const _AnalyzeCard({required this.hasVideo});

 @override
Widget build(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: hasVideo ? () {} : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: hasVideo
            ? AppTheme.green
            : AppTheme.green.withOpacity(0.4),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'Analyze posture',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
}
