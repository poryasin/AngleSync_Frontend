class ScanHistoryItem {
  final int? id;
  final String title;
  final DateTime? analysisDate;
  final double? score;

  const ScanHistoryItem({
    required this.id,
    required this.title,
    required this.analysisDate,
    required this.score,
  });

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    final rawSessionId = json['session_id'] ?? json['id'];
    final rawScore = json['accuracy_score'];
    final score = rawScore is num
        ? rawScore.toDouble()
        : double.tryParse(rawScore?.toString() ?? '');
    final rawDate = json['analysis_date'] ?? json['saved_at'];

    return ScanHistoryItem(
      id: rawSessionId is num
          ? rawSessionId.toInt()
          : int.tryParse(rawSessionId?.toString() ?? ''),
      title: (json['session_name'] ?? 'Untitled session').toString(),
      analysisDate: rawDate == null
          ? null
          : DateTime.tryParse(rawDate.toString()),
      score: score,
    );
  }
}
