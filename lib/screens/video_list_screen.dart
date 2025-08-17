// Shows a grid of 3 random videos and lets user go to live stream or logout
// Written by: Aytan (Intern)

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
      body: FutureBuilder<List<VideoModel>>(
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
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
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
                      builder: (_) =>
                          VideoPlayerScreen(videoUrl: url, title: video.title),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: FutureBuilder<String>(
                          future: _service.getThumbnailDownloadUrl(video),
                          builder: (context, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            if (snap.hasError || !snap.hasData) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 40),
                              );
                            }
                            return CachedNetworkImage(
                              imageUrl: snap.data!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
