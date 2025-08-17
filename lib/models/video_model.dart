// Model for video data (used for both Firestore and Storage)
// Written by: Aytan (Intern)

class VideoModel {
  final String id;
  final String title;
  final String? storagePath; // e.g. videos/sample1.mp4
  final String? videoUrl; // optional: full download URL
  final String? thumbnailPath;
  final String? thumbnailUrl;

  VideoModel({
    required this.id,
    required this.title,
    this.storagePath,
    this.videoUrl,
    this.thumbnailPath,
    this.thumbnailUrl,
  });

  // Factory to create from Firestore document
  factory VideoModel.fromFirestore(String id, Map<String, dynamic> data) {
    return VideoModel(
      id: id,
      title: data['title'] ?? 'Untitled',
      storagePath: data['storagePath'],
      videoUrl: data['videoUrl'],
      thumbnailPath: data['thumbnailPath'],
      thumbnailUrl: data['thumbnailUrl'],
    );
  }
}
