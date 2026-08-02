class AdminSession {
  final int sessionId;
  final String sessionName;
  final DateTime? analysisDate;

  AdminSession({
    required this.sessionId,
    required this.sessionName,
    this.analysisDate,
  });

  factory AdminSession.fromJson(Map<String, dynamic> json) {
    return AdminSession(
      sessionId: json['session_id'] as int,
      sessionName: json['session_name'] as String? ?? '',
      analysisDate: json['analysis_date'] != null
          ? DateTime.tryParse(json['analysis_date'].toString())
          : null,
    );
  }
}