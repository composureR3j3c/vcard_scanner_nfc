import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'session_user.dart';

class SessionStore {
  static const _isLoggedInKey = 'is_logged_in';
  static const _userKey = 'session_user';
  static const _profileKeyPrefix = 'employee_profile_';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<SessionUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(_userKey);
    if (rawUser == null || rawUser.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(rawUser);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return SessionUser.fromJson(decoded);
  }

  Future<void> saveLogin({required SessionUser user}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> clearLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final user = await getUser();

    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userKey);

    if (user != null) {
      await prefs.remove('$_profileKeyPrefix${user.id}');
    }
  }
}
