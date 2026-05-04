import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_user.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RefreshTokenExpiredException extends AuthException {
  const RefreshTokenExpiredException()
    : super('Your session has expired. Please sign in again.');
}

class AuthService {
  static const String _loginUrl =
      'https://businesscard.bankofabyssinia.com/api/login';
  static const String _refreshUrl =
      'https://businesscard.bankofabyssinia.com/api/refresh';
  static const String _loginSecret =
      'bA7wZpK3NfQ2tY9sVxL4mJ8rH6cD1eG5uT0kS9nP2yR7wX4z';

  Future<SessionUser> login({
    required String username,
    required String password,
  }) async {
    late final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_loginUrl),
            headers: const {
              'Content-Type': 'application/json',
              'x-api-login-secret': _loginSecret,
            },
            body: jsonEncode({
              'username': username.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw const AuthException(
        'Login failed. Please check your network connection and try again.',
      );
    }

    if (response.statusCode != 200) {
      throw const AuthException(
        'Login failed. Please check your credentials and try again.',
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw const AuthException('Login failed. Please try again.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const AuthException('Login failed. Please try again.');
    }

    final userJson = decoded['user'];
    if (userJson is! Map<String, dynamic>) {
      throw const AuthException('Login failed. Please try again.');
    }

    final user = SessionUser.fromJson({...userJson, ..._readTokens(decoded)});
    if (user.id.isEmpty || user.username.isEmpty) {
      throw const AuthException('Login failed. Please try again.');
    }

    return user;
  }

  Future<SessionUser> refreshSession(SessionUser user) async {
    final refreshToken = user.refreshToken.trim();
    if (refreshToken.isEmpty) {
      throw const RefreshTokenExpiredException();
    }

    late final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_refreshUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-refresh-token': refreshToken,
            },
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw const AuthException(
        'Could not refresh your session. Please check your connection and try again.',
      );
    }

    if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403) {
      throw const RefreshTokenExpiredException();
    }

    if (response.statusCode != 200) {
      throw const AuthException('Could not refresh your session.');
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw const AuthException('Could not refresh your session.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const AuthException('Could not refresh your session.');
    }

    final tokens = _readTokens(decoded);
    final accessToken = tokens['accessToken'] ?? '';
    final nextRefreshToken = tokens['refreshToken'] ?? '';
    if (accessToken.isEmpty || nextRefreshToken.isEmpty) {
      throw const AuthException('Could not refresh your session.');
    }

    return user.copyWith(
      accessToken: accessToken,
      refreshToken: nextRefreshToken,
    );
  }

  Map<String, String> _readTokens(Map<String, dynamic> json) {
    final tokenJson = json['token'];

    return {
      'accessToken':
          _readString(json, const [
            'accessToken',
            'access_token',
            'access',
          ]).ifEmpty(
            () => tokenJson is Map<String, dynamic>
                ? _readString(tokenJson, const [
                    'accessToken',
                    'access_token',
                    'access',
                  ])
                : '',
          ),
      'refreshToken':
          _readString(json, const [
            'refreshToken',
            'refresh_token',
            'refresh',
          ]).ifEmpty(
            () => tokenJson is Map<String, dynamic>
                ? _readString(tokenJson, const [
                    'refreshToken',
                    'refresh_token',
                    'refresh',
                  ])
                : '',
          ),
    };
  }

  String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
  }
}

extension on String {
  String ifEmpty(String Function() fallback) {
    return isEmpty ? fallback() : this;
  }
}
