import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'employee_profile.dart';

class EmployeeProfileStore {
  static const _profileKeyPrefix = 'employee_profile_';

  Future<EmployeeProfile?> getProfile(String employeeId) async {
    final prefs = await SharedPreferences.getInstance();
    final rawProfile = prefs.getString(_profileKey(employeeId));
    if (rawProfile == null || rawProfile.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(rawProfile);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return EmployeeProfile.fromJson(decoded);
  }

  Future<void> saveProfile(
    EmployeeProfile profile, {
    List<String> cacheKeys = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedProfile = jsonEncode(profile.toJson());
    final keys = {
      profile.id,
      ...cacheKeys,
    }.map((value) => value.trim()).where((value) => value.isNotEmpty);

    for (final key in keys) {
      await prefs.setString(_profileKey(key), encodedProfile);
    }
  }

  Future<void> clearProfile(String employeeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey(employeeId));
  }

  String _profileKey(String employeeId) => '$_profileKeyPrefix$employeeId';
}
