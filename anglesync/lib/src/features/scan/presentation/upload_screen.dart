import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/service/analysis_service.dart';
import '../../results/presentation/analysis_result_screen.dart';
import '../domain/exercise_detail.dart';

class UploadScreen extends StatefulWidget {
  final ExerciseDetail exercise;

  const UploadScreen({super.key, required this.exercise});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  static const String _sampleVideoAsset = 'assets/videos/IMG_2117.MOV';
  static const String _sampleVideoName = 'IMG_2117.MOV';

  File? _selectedVideo;
  String? _selectedVideoName;
  bool _isLoading = false;

  final AnalysisService _analysisService = AnalysisService();

  bool get _hasVideo => _selectedVideo != null;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedVideo = File(picked.path);
        _selectedVideoName = picked.name;
      });
    }
  }

  // Future<void> _useSampleVideo() async {
  //   final data = await rootBundle.load(_sampleVideoAsset);
  //   final file = File('${Directory.systemTemp.path}/$_sampleVideoName');
  //   await file.writeAsBytes(
  //     data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  //     flush: true,
  //   );

  //   if (!mounted) return;
  //   setState(() {
  //     _selectedVideo = file;
  //     _selectedVideoName = _sampleVideoName;
  //   });
  // }

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
          const SnackBar(content: Text('Backend server is not running')),
        );
      }
      return;
    }

    final stream = _analysisService.analyzeVideo(
      videoFile: _selectedVideo!,
      exerciseName: widget.exercise.title,
      referenceVideoId: widget.exercise.referenceVideoId,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(analysisStream: stream),
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
                      selectedVideo: _selectedVideo,
                      selectedVideoName: _selectedVideoName,
                      onUploadTap: _pickVideo,
                      // onSampleTap: _useSampleVideo,
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

  const _UploadAppBar({required this.title});

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

  const _ReferenceSection({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final referenceVideoUrl =
        exercise.referenceVideoUrl ?? exercise.description;
    final description = exercise.description == referenceVideoUrl
        ? exercise.category
        : exercise.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _InlineReferenceVideoPlayer(
          title: exercise.title,
          videoUrl: referenceVideoUrl,
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(color: Colors.grey.shade600, height: 1.5),
        ),
      ],
    );
  }
}

class _InlineReferenceVideoPlayer extends StatefulWidget {
  final String title;
  final String videoUrl;

  const _InlineReferenceVideoPlayer({
    required this.title,
    required this.videoUrl,
  });

  @override
  State<_InlineReferenceVideoPlayer> createState() =>
      _InlineReferenceVideoPlayerState();
}

class _InlineReferenceVideoPlayerState
    extends State<_InlineReferenceVideoPlayer> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(_InlineReferenceVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _hasError = false;
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.videoUrl.isEmpty) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _controller = controller;

    try {
      await controller.initialize();

      if (!mounted || _controller != controller) {
        await controller.dispose();
        return;
      }

      final duration = controller.value.duration;
      final previewPosition = duration > const Duration(seconds: 2)
          ? const Duration(seconds: 1)
          : Duration.zero;

      await controller.seekTo(previewPosition);
      await controller.pause();

      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      await controller.dispose();

      if (mounted) {
        setState(() {
          _controller = null;
          _hasError = true;
        });
      }
    }
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return GestureDetector(
      onTap: _togglePlayback,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(child: _buildVideoContent(controller)),
              if (controller != null && controller.value.isInitialized)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: AppTheme.green,
                      bufferedColor: Colors.white38,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ),
              Center(child: _buildPlayOverlay(controller)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayOverlay(VideoPlayerController? controller) {
    if (_hasError) {
      return const SizedBox.shrink();
    }

    if (controller == null || !controller.value.isInitialized) {
      return const _PlayButtonOverlay(isVisible: true);
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return _PlayButtonOverlay(isVisible: !value.isPlaying);
      },
    );
  }

  Widget _buildVideoContent(VideoPlayerController? controller) {
    if (_hasError) {
      return _InlineVideoPlaceholder(title: widget.title);
    }

    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final size = controller.value.size;

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class _PlayButtonOverlay extends StatelessWidget {
  final bool isVisible;

  const _PlayButtonOverlay({required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 180),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          CupertinoIcons.play_fill,
          color: AppTheme.green,
          size: 28,
        ),
      ),
    );
  }
}

class _InlineVideoPlaceholder extends StatelessWidget {
  final String title;

  const _InlineVideoPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _YourVideoSection extends StatelessWidget {
  final File? selectedVideo;
  final String? selectedVideoName;
  final VoidCallback onUploadTap;
  // final VoidCallback onSampleTap;

  const _YourVideoSection({
    required this.selectedVideo,
    required this.selectedVideoName,
    required this.onUploadTap,
    // required this.onSampleTap,
  });

  @override
  Widget build(BuildContext context) {
    final video = selectedVideo;
    final hasVideo = video != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          if (hasVideo) ...[
            _InlineLocalVideoPlayer(
              title: selectedVideoName ?? 'Selected video',
              videoFile: video,
            ),
            const SizedBox(height: 14),
            Text(
              selectedVideoName ?? 'Selected video',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ] else ...[
            GestureDetector(
              onTap: onUploadTap,
              child: Column(
                children: [
                  const Icon(
                    CupertinoIcons.arrow_up_to_line,
                    size: 48,
                    color: AppTheme.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Upload your workout video',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Row(
          //   children: [
          //     Expanded(
          //       child: OutlinedButton.icon(
          //         onPressed: onUploadTap,
          //         icon: const Icon(CupertinoIcons.folder_open),
          //         label: Text(hasVideo ? 'Change video' : 'Pick video'),
          //       ),
          //     ),
          //     const SizedBox(width: 10),
              // Expanded(
              //   child: ElevatedButton.icon(
              //     onPressed: onSampleTap,
              //     icon: const Icon(CupertinoIcons.play_rectangle),
              //     label: const Text('Use sample'),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppTheme.green,
              //       foregroundColor: Colors.white,
              //     ),
              //   ),
              // ),
            ],
          ),
    //     ],
    //   ),
    );
  }
}

class _InlineLocalVideoPlayer extends StatefulWidget {
  final String title;
  final File videoFile;

  const _InlineLocalVideoPlayer({required this.title, required this.videoFile});

  @override
  State<_InlineLocalVideoPlayer> createState() =>
      _InlineLocalVideoPlayerState();
}

class _InlineLocalVideoPlayerState extends State<_InlineLocalVideoPlayer> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(_InlineLocalVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoFile.path != widget.videoFile.path) {
      _controller?.dispose();
      _controller = null;
      _hasError = false;
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    final controller = VideoPlayerController.file(widget.videoFile);
    _controller = controller;

    try {
      await controller.initialize();

      if (!mounted || _controller != controller) {
        await controller.dispose();
        return;
      }

      await controller.pause();

      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      await controller.dispose();

      if (mounted) {
        setState(() {
          _controller = null;
          _hasError = true;
        });
      }
    }
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return GestureDetector(
      onTap: _togglePlayback,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(child: _buildVideoContent(controller)),
                if (controller != null && controller.value.isInitialized)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppTheme.green,
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),
                Center(child: _buildPlayOverlay(controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayOverlay(VideoPlayerController? controller) {
    if (_hasError) {
      return const SizedBox.shrink();
    }

    if (controller == null || !controller.value.isInitialized) {
      return const _PlayButtonOverlay(isVisible: true);
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return _PlayButtonOverlay(isVisible: !value.isPlaying);
      },
    );
  }

  Widget _buildVideoContent(VideoPlayerController? controller) {
    if (_hasError) {
      return _InlineVideoPlaceholder(title: widget.title);
    }

    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final size = controller.value.size;

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(controller),
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
              : AppTheme.green.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
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
