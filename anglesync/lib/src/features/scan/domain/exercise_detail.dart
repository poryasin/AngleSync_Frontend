class ExerciseDetail {
  final String title;
  final String category;
  final String description;
  final String? referenceVideoUrl;

  const ExerciseDetail({
    required this.title,
    required this.category,
    required this.description,
    this.referenceVideoUrl,
  });
}