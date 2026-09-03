import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '/src/core/config/backend_config.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthResult {
  final String accessToken;
  final int userId;
  final String userRole;
  final String? gender;
  final bool needsGender;

  AuthResult({
    required this.accessToken,
    required this.userId,
    required this.userRole,
    this.gender,
    required this.needsGender,
  });
}

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '803562741567-rnv2omoq76njcj6s38t2apeskt5t29tv.apps.googleusercontent.com',
    serverClientId: '803562741567-c6v0tlm9m97qiv3vlhmem3gskr7quqd8.apps.googleusercontent.com',
    scopes: ['email'],
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<AuthResult> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw AuthException('Sign-in cancelled.');
    }

    final googleAuth = await account.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw AuthException('Failed to get Google ID token.');
    }

    final uri = Uri.parse('${BackendConfig.baseUrl}/auth/google');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );

    if (response.statusCode != 200) {
      throw AuthException('Login failed (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = data['access_token'] as String;
    final userId = data['user_id'] as int;
    final userRole = data['user_role'] as String;
    final gender = data['gender'] as String?;

    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'user_id', value: userId.toString()); // 👈 บันทึก user_id
    await _storage.write(key: 'user_role', value: userRole);
    if (gender != null) {
      await _storage.write(key: 'gender', value: gender);
    }

    return AuthResult(
      accessToken: accessToken,
      userId: userId,
      userRole: userRole,
      gender: gender,
      needsGender: data['needs_gender'] as bool,
    );
  }

  /// เช็ค session ที่ค้างอยู่ตอนเปิดแอป
  Future<AuthResult?> checkSession() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;

    try {
      final uri = Uri.parse('${BackendConfig.baseUrl}/auth/me');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        await signOut();
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final userId = data['user_id'] as int;
      final userRole = data['user_role'] as String;
      final gender = data['gender'] as String?;

      await _storage.write(key: 'user_id', value: userId.toString()); // 👈 บันทึก user_id
      await _storage.write(key: 'user_role', value: userRole);
      if (gender != null) {
        await _storage.write(key: 'gender', value: gender);
      } else {
        await _storage.delete(key: 'gender');
      }

      return AuthResult(
        accessToken: token,
        userId: userId,
        userRole: userRole,
        gender: gender,
        needsGender: data['needs_gender'] as bool,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> completeProfile(String gender) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) throw AuthException('Not signed in.');

    final uri = Uri.parse('${BackendConfig.baseUrl}/auth/complete-profile');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'gender': gender}),
    );

    if (response.statusCode != 200) {
      throw AuthException('Failed to save gender.');
    }

    await _storage.write(key: 'gender', value: gender);
  }

  Future<String?> getToken() => _storage.read(key: 'access_token');
  
  /// ดึง user_id ของคนที่กำลังล็อกอินอยู่
  Future<int?> getCurrentUserId() async {
    final userIdStr = await _storage.read(key: 'user_id');
    if (userIdStr != null) {
      return int.tryParse(userIdStr);
    }
    return null;
  }

  Future<String?> getGender() => _storage.read(key: 'gender');

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'user_id'); // 👈 ลบ user_id เมื่อ sign out
    await _storage.delete(key: 'user_role');
    await _storage.delete(key: 'gender');
  }
}