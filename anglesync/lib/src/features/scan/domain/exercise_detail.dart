class ExerciseDetail {
  final String title;
  final String category;
  final String description;
  final String? referenceVideoUrl;
  final int referenceVideoId;

  const ExerciseDetail({
    required this.title,
    required this.category,
    required this.description,
    required this.referenceVideoId,
    this.referenceVideoUrl,
  });
}