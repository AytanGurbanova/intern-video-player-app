// Plays a selected video using Chewie and video_player
// Written by: Aytan (Intern)

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  const VideoPlayerScreen({
    required this.videoUrl,
    required this.title,
    super.key,
  });
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Initialize video player
    _videoController = VideoPlayerController.network(widget.videoUrl)
      ..initialize()
          .then((_) {
            _chewieController = ChewieController(
              videoPlayerController: _videoController!,
              autoPlay: true,
              looping: false,
              showControls: true,
            );
            setState(() {
              _loading = false;
            });
          })
          .catchError((e) {
            setState(() {
              _loading = false;
            });
            // handle error (show message)
          });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? Center(child: SpinKitCircle(size: 48.0, color: Colors.blue))
          : _chewieController != null
          ? Chewie(controller: _chewieController!)
          : const Center(child: Text('Failed to load video')),
    );
  }
}
