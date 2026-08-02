import 'dart:convert';
import 'package:http/http.dart' as http;

import '/src/features/admin/models/admin_session.dart';
import '/src/features/admin/models/admin_user.dart';
import '/src/core/config/backend_config.dart';

class AdminApiException implements Exception {
  final String message;
  AdminApiException(this.message);

  @override
  String toString() => message;
}

class AdminApiService {
  static const String baseUrl = BackendConfig.baseUrl;

  Future<Map<String, int>> fetchDashboardSummary({
    required int userId,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/dashboard-summary')
        .replace(queryParameters: {'user_id': userId.toString()});

    try {
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw AdminApiException('Unable to load data. Please try again.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'total_users': (data['total_users'] as num?)?.toInt() ?? 0,
        'total_analysis_sessions':
            (data['total_analysis_sessions'] as num?)?.toInt() ?? 0,
      };
    } on AdminApiException {
      rethrow;
    } catch (_) {
      throw AdminApiException('Unable to load data. Please try again.');
    }
  }

  Future<List<AdminSession>> fetchSessions({
    required int userId,
    required String sortOrder,
    DateTime? filterDate,
  }) async {
    final queryParameters = <String, String>{
      'user_id': userId.toString(),
      'sort_order': sortOrder,
    };

    if (filterDate != null) {
      queryParameters['filter_date'] =
          filterDate.toIso8601String().split('T').first;
    }

    final uri = Uri.parse('$baseUrl/admin/sessions')
        .replace(queryParameters: queryParameters);

    final response = await http.get(uri);

    if (response.statusCode == 404) {
      return [];
    }

    if (response.statusCode != 200) {
      throw AdminApiException('Unable to load sessions. Please try again.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final sessions = (data['sessions'] as List<dynamic>? ?? [])
        .map((item) => AdminSession.fromJson(item as Map<String, dynamic>))
        .toList();

    return sessions;
  }

  Future<List<AdminUser>> fetchUsers() async {
    final uri = Uri.parse('$baseUrl/admin/users');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw AdminApiException('Unable to load users. Please try again.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final users = (data['users'] as List<dynamic>? ?? [])
        .map((item) => AdminUser.fromJson(item as Map<String, dynamic>))
        .toList();

    return users;
  }

  Future<String> updateUserStatus({
    required int adminUserId,
    required int targetUserId,
    required String newStatus,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/update-user-status');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': adminUserId,
        'target_user_id': targetUserId,
        'new_status': newStatus,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final message = data['detail']?.toString() ??
          'Unable to update user status. Please try again.';
      throw AdminApiException(message);
    }

    return data['message']?.toString() ?? 'User status updated successfully.';
  }
}