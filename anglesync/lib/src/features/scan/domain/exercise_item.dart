class ExerciseItem {
  final int id;
  final String title;
  final String category;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String gender;

  const ExerciseItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.gender,
  });

  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    return ExerciseItem(
      id: json['id'],
      title: json['exercise_name'],
      category: json['category'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      videoUrl: json['video_url'],
      gender: json['gender'],
    );
  }
}