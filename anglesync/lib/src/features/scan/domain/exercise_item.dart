class ExerciseItem {
  final String title;
  final String description;
  final String category;

  const ExerciseItem({
    required this.title,
    required this.description,
    required this.category,
  });

  static const List<ExerciseItem> all = [
    ExerciseItem(
      title: 'Bodyweight Squat',
      description: 'Hip-width stance, sit back into hips, knees track over toes, chest tall.',
      category: 'LOWER BODY',
    ),
    ExerciseItem(
      title: 'Push Up',
      description: 'Hands shoulder-width apart, lower chest to floor, keep core tight.',
      category: 'UPPER BODY',
    ),
    ExerciseItem(
      title: 'Romanian Deadlift',
      description: 'Hinge at hips, soft knee bend, bar stays close to legs throughout.',
      category: 'LOWER BODY',
    ),
    ExerciseItem(
      title: 'Overhead Press',
      description: 'Bar at collarbone, press straight up, lock out at top with ears forward.',
      category: 'UPPER BODY',
    ),
    ExerciseItem(
      title: 'Plank',
      description: 'Forearms flat, hips level, brace core and glutes, breathe steadily.',
      category: 'CORE',
    ),
  ];
}