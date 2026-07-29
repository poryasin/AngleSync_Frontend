import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _selectedVideo;
  String? _selectedVideoName;
  bool _selectedFileIsImage = false;
  bool _isLoading = false;

  final AnalysisService _analysisService = AnalysisService();

  bool get _hasVideo => _selectedVideo != null;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickMedia();

    if (picked == null) return;

    // check format
    final ext = picked.name.split('.').last.toLowerCase();
    final isVideo = ext == 'mp4' || ext == 'mov';
    final isImage =
        ext == 'jpg' ||
        ext == 'jpeg' ||
        ext == 'png' ||
        ext == 'heic' ||
        ext == 'heif' ||
        ext == 'webp';

    if (!isVideo && !isImage) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: const Icon(
              Icons.video_file_outlined,
              color: Colors.red,
              size: 48,
            ),
            title: const Text(
              'Unsupported Format',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            content: Text(
              'Invalid file format. Please upload a video or image file.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return;
    }

    // check duration
    if (isVideo) {
      final controller = VideoPlayerController.file(File(picked.path));
      await controller.initialize();
      final duration = controller.value.duration;
      await controller.dispose();

      if (duration.inSeconds > 60) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: const Icon(
                Icons.timer_off_rounded,
                color: Colors.red,
                size: 48,
              ),
              title: const Text(
                'Video exceeds \n60 seconds',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _selectedVideo = File(picked.path);
      _selectedVideoName = picked.name;
      _selectedFileIsImage = isImage;
    });
  }

  void _analyzeVideo() {
    if (_selectedVideo == null) return;

    if (_selectedFileIsImage) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ImageMismatchScreen(
            exerciseName: widget.exercise.title,
            onChooseAnother: (mismatchContext) {
              Navigator.pop(mismatchContext);
              setState(() {
                _selectedVideo = null;
                _selectedVideoName = null;
                _selectedFileIsImage = false;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _pickVideo();
                }
              });
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final stream = _analysisService.analyzeVideo(
      videoFile: _selectedVideo!,
      exerciseName: widget.exercise.title,
      referenceVideoId: widget.exercise.referenceVideoId,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(
            analysisStream: stream,
            onMismatch: () {
              setState(() {
                _selectedVideo = null;
                _selectedVideoName = null;
                _selectedFileIsImage = false;
              });
            },
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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
                      selectedFileIsImage: _selectedFileIsImage,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title + badge ──
        Row(
          children: [
            Expanded(
              child: Text(
                exercise.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                exercise.category,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.green,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── Video ──
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _InlineReferenceVideoPlayer(
            title: exercise.title,
            videoUrl: referenceVideoUrl,
          ),
        ),

        const SizedBox(height: 16),

        // ── Instruction label ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppTheme.green,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Watch the reference video, then upload yours below.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF667085),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
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
  final bool selectedFileIsImage;
  final VoidCallback onUploadTap;
  // final VoidCallback onSampleTap;

  const _YourVideoSection({
    required this.selectedVideo,
    required this.selectedVideoName,
    required this.selectedFileIsImage,
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
            if (selectedFileIsImage)
              _InlineLocalImagePreview(imageFile: video)
            else
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
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: AppTheme.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.green.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.arrow_up_to_line,
                        size: 28,
                        color: AppTheme.green,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Upload your workout video',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'MP4 or MOV · Max 60 seconds',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineLocalImagePreview extends StatelessWidget {
  final File imageFile;

  const _InlineLocalImagePreview({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            imageFile,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white,
                  size: 36,
                ),
              );
            },
          ),
        ),
      ),
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

class _ImageMismatchScreen extends StatelessWidget {
  final String exerciseName;
  final ValueChanged<BuildContext> onChooseAnother;

  const _ImageMismatchScreen({
    required this.exerciseName,
    required this.onChooseAnother,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const _MismatchAppBar(),
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
                          'Invalid file format',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Invalid file format. Please upload an MP4 or MOV file.',
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
                            onPressed: () => onChooseAnother(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.green,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Choose another file',
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
}

class _MismatchAppBar extends StatelessWidget {
  const _MismatchAppBar();

  @override
  Widget build(BuildContext context) {
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
