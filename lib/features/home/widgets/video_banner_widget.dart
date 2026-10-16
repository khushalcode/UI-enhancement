import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sixam_mart/util/dimensions.dart';

class VideoBannerWidget extends StatefulWidget {
  final String videoUrl;
  final String videoType; // 'upload'
  const VideoBannerWidget({super.key, required this.videoUrl, required this.videoType});

  @override
  State<VideoBannerWidget> createState() => _VideoBannerWidgetState();
}

class _VideoBannerWidgetState extends State<VideoBannerWidget> {
  VideoPlayerController? _videoPlayerController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoType == 'upload') {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
            _videoPlayerController!.setLooping(true);
            _videoPlayerController!.setVolume(0);
            _videoPlayerController!.play();
          }
        });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoType == 'upload' && _videoPlayerController != null) {
      return _isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoPlayerController!.value.size.width,
                  height: _videoPlayerController!.value.size.height,
                  child: VideoPlayer(_videoPlayerController!),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator());
    }
    return const SizedBox();
  }
}
