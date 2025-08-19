import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import 'video_player_screen.dart';
import 'livestream_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});
  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final VideoService _service = VideoService();
  late Future<List<VideoModel>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = _service.fetchRandomVideos(count: 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.live_tv),
            tooltip: 'Live Stream',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LiveStreamScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFB3E0FF), Color(0xFFF6FBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FutureBuilder<List<VideoModel>>(
            future: _videosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading videos'));
              }
              final videos = snapshot.data ?? [];
              if (videos.isEmpty) {
                return const Center(child: Text('No videos available.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: videos.length,
                itemBuilder: (context, i) {
                  final video = videos[i];
                  return GestureDetector(
                    onTap: () async {
                      final url = await _service.getVideoDownloadUrl(video);
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(
                            videoUrl: url,
                            title: video.title,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: SizedBox(
                                width: 90,
                                height: 90,
                                child: FutureBuilder<String>(
                                  future: _service.getThumbnailDownloadUrl(
                                    video,
                                  ),
                                  builder: (context, snap) {
                                    if (snap.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container(
                                        color: Colors.blue[50],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    if (snap.hasError || !snap.hasData) {
                                      return Container(
                                        color: Colors.blue[50],
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                          color: Color(0xFF1565C0),
                                        ),
                                      );
                                    }
                                    return Image.network(
                                      snap.data!,
                                      fit: BoxFit.cover,
                                      width: 90,
                                      height: 90,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                video.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
