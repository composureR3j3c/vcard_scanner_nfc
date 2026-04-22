import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_user.dart';

class AuthService {
  static const String _loginUrl =
      'https://businesscard.bankofabyssinia.com/api/login';

  Future<SessionUser> login({
    required String username,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse(_loginUrl),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username.trim(), 'password': password}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Login failed ');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected login response format');
    }

    final userJson = decoded['user'];
    if (userJson is! Map<String, dynamic>) {
      throw Exception('Login response did not include user data');
    }

    final user = SessionUser.fromJson(userJson);
    if (user.id.isEmpty || user.username.isEmpty) {
      throw Exception('Login response is missing user id or username');
    }
  
    return user;
  }
}
