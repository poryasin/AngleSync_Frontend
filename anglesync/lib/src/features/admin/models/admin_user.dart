class AdminUser {
  final int userId;
  final String username;
  final String userRole;
  final String userStatus;

  AdminUser({
    required this.userId,
    required this.username,
    required this.userRole,
    required this.userStatus,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      userId: json['user_id'] as int,
      username: json['username'] as String? ?? '',
      userRole: json['user_role'] as String? ?? '',
      userStatus: json['user_status'] as String? ?? 'Active',
    );
  }

  bool get isInactive => userStatus == 'Inactive';
}