class ScanHistoryItem {
  final int? id;
  final String title;
  final DateTime? analysisDate;
  final double? score;
  final DateTime createdAt;

  const ScanHistoryItem({
    this.id,
    required this.title,
    this.analysisDate,
    this.score,
    required this.createdAt,
  });

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    final rawSessionId = json['session_id'] ?? json['id'];
    final rawScore = json['accuracy_score'] ?? json['score'];
    final rawDate = json['analysis_date'] ?? json['saved_at'] ?? json['created_at'];

    // Safe integer parsing
    final parsedId = rawSessionId is num
        ? rawSessionId.toInt()
        : int.tryParse(rawSessionId?.toString() ?? '');

    // Safe double parsing
    final parsedScore = rawScore is num
        ? rawScore.toDouble()
        : double.tryParse(rawScore?.toString() ?? '');

    // Safe DateTime parsing
    final parsedDate = rawDate != null
        ? DateTime.tryParse(rawDate.toString())
        : null;

    return ScanHistoryItem(
      id: parsedId,
      title: (json['session_name'] ?? json['title'] ?? 'Untitled session').toString(),
      analysisDate: parsedDate,
      score: parsedScore,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': id,
      'session_name': title,
      'analysis_date': analysisDate?.toIso8601String(),
      'accuracy_score': score,
    };
  }
}