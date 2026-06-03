import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_theme.dart';

class VideoFrameThumbnail extends StatefulWidget {
  final String title;
  final String videoUrl;

  const VideoFrameThumbnail({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<VideoFrameThumbnail> createState() => _VideoFrameThumbnailState();
}

class _VideoFrameThumbnailState extends State<VideoFrameThumbnail> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPreviewFrame();
  }

  @override
  void didUpdateWidget(VideoFrameThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _hasError = false;
      _loadPreviewFrame();
    }
  }

  Future<void> _loadPreviewFrame() async {
    final videoUrl = widget.videoUrl;
    if (videoUrl.isEmpty) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (_hasError || controller == null || !controller.value.isInitialized) {
      return _VideoThumbnailPlaceholder(
        title: widget.title,
        showSpinner: !_hasError,
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

class _VideoThumbnailPlaceholder extends StatelessWidget {
  final String title;
  final bool showSpinner;

  const _VideoThumbnailPlaceholder({
    required this.title,
    this.showSpinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade300, Colors.grey.shade200],
        ),
      ),
      child: Center(
        child: showSpinner
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
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
