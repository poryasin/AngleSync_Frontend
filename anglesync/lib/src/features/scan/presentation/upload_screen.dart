import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/service/analysis_service.dart';
import '../../results/presentation/analysis_result_screen.dart';
import '../domain/exercise_detail.dart';

class UploadScreen extends StatefulWidget {
  final ExerciseDetail exercise;

  const UploadScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedVideo;
  bool _isLoading = false;

  final AnalysisService _analysisService = AnalysisService();

  bool get _hasVideo => _selectedVideo != null;

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
      });
    }
  }

  Future<void> _analyzeVideo() async {
    if (_selectedVideo == null) return;

    setState(() {
      _isLoading = true;
    });

    final isOnline = await _analysisService.isServerOnline();

    if (!isOnline) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backend server is not running'),
          ),
        );
      }
      return;
    }

    final stream = _analysisService.analyzeVideo(
      videoFile: _selectedVideo!,
      exerciseName: widget.exercise.title,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(
            analysisStream: stream,
          ),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _UploadAppBar(title: widget.exercise.title),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReferenceSection(exercise: widget.exercise),
                    const SizedBox(height: 28),
                    _YourVideoSection(
                      hasVideo: _hasVideo,
                      onUploadTap: _pickVideo,
                    ),
                    const SizedBox(height: 20),
                    _AnalyzeCard(
                      hasVideo: _hasVideo,
                      isLoading: _isLoading,
                      onAnalyze: _analyzeVideo,
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
}

class _UploadAppBar extends StatelessWidget {
  final String title;

  const _UploadAppBar({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(
                  CupertinoIcons.chevron_left,
                  color: CupertinoColors.activeBlue,
                ),
                SizedBox(width: 4),
                Text(
                  'Categories',
                  style: TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceSection extends StatelessWidget {
  final ExerciseDetail exercise;

  const _ReferenceSection({
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              CupertinoIcons.play_fill,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          exercise.description,
          style: TextStyle(
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _YourVideoSection extends StatelessWidget {
  final bool hasVideo;
  final VoidCallback onUploadTap;

  const _YourVideoSection({
    required this.hasVideo,
    required this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUploadTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 36,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasVideo
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.arrow_up_to_line,
              size: 48,
              color: AppTheme.green,
            ),
            const SizedBox(height: 16),
            Text(
              hasVideo
                  ? 'Video Selected'
                  : 'Upload your workout video',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyzeCard extends StatelessWidget {
  final bool hasVideo;
  final bool isLoading;
  final VoidCallback onAnalyze;

  const _AnalyzeCard({
    required this.hasVideo,
    required this.isLoading,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: hasVideo && !isLoading ? onAnalyze : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasVideo
              ? AppTheme.green
              : AppTheme.green.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Text(
                'Analyze posture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}