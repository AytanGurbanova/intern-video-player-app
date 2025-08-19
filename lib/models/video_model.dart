class VideoModel {
  final String id;
  final String title;
  final String? storagePath;
  final String? videoUrl;
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

  // Create VideoModel from Firestore data
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
