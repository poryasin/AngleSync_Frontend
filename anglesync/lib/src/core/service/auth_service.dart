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
  final bool needsGender;
  AuthResult({required this.accessToken, required this.userId, required this.needsGender});
}

class AuthService {
  // 👈 ใส่ clientId สำหรับ iOS ตรงนี้เพื่อป้องกันปัญหา SIGABRT / Crash บน iOS
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
    await _storage.write(key: 'access_token', value: accessToken);

    return AuthResult(
      accessToken: accessToken,
      userId: data['user_id'] as int,
      needsGender: data['needs_gender'] as bool,
    );
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
  }

  Future<String?> getToken() => _storage.read(key: 'access_token');

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _storage.delete(key: 'access_token');
  }
}