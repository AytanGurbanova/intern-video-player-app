// Handles fetching videos and their URLs from Firestore and Storage
// Written by: Aytan (Intern)

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/video_model.dart';

class VideoService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetch all videos then pick N random items.
  Future<List<VideoModel>> fetchRandomVideos({int count = 3}) async {
    final snap = await _fire.collection('videos').get();
    final docs = snap.docs;
    if (docs.isEmpty) return [];

    docs.shuffle(Random());
    final selection = docs.take(min(count, docs.length)).toList();

    List<VideoModel> videos = [];
    for (final d in selection) {
      final vm = VideoModel.fromFirestore(d.id, d.data());
      videos.add(vm);
    }
    return videos;
  }

  // Get downloadable video URL (from Firestore or Storage)
  Future<String> getVideoDownloadUrl(VideoModel v) async {
    if (v.videoUrl != null && v.videoUrl!.isNotEmpty) {
      return v.videoUrl!;
    }
    if (v.storagePath != null && v.storagePath!.isNotEmpty) {
      final ref = _storage.ref().child(v.storagePath!);
      return await ref.getDownloadURL();
    }
    throw Exception('No video URL/path present');
  }

  // Get thumbnail URL (from Firestore or Storage)
  Future<String> getThumbnailDownloadUrl(VideoModel v) async {
    if (v.thumbnailUrl != null && v.thumbnailUrl!.isNotEmpty) {
      return v.thumbnailUrl!;
    }
    if (v.thumbnailPath != null && v.thumbnailPath!.isNotEmpty) {
      final ref = _storage.ref().child(v.thumbnailPath!);
      return await ref.getDownloadURL();
    }
    throw Exception('No thumbnail URL/path present');
  }
}
