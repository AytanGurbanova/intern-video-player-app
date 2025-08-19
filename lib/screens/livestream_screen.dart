import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  YoutubePlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Stream')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFB3E0FF), Color(0xFFF6FBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('config')
              .doc('live')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>?;
            final youtubeID = data?['youtubeID'];

            if (youtubeID == null || youtubeID.isEmpty) {
              return const Center(
                child: Text(
                  'No live stream available.',
                  style: TextStyle(color: Color(0xFF1565C0)),
                ),
              );
            }

            // Only create controller if needed
            if (_controller == null ||
                _controller!.initialVideoId != youtubeID) {
              _controller?.dispose();
              _controller = YoutubePlayerController(
                initialVideoId: youtubeID,
                flags: const YoutubePlayerFlags(
                  isLive: true,
                  autoPlay: true,
                  mute: false,
                ),
              );
            }

            return YoutubePlayer(
              controller: _controller!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Color(0xFF1565C0),
            );
          },
        ),
      ),
    );
  }
}
