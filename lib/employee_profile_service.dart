import 'dart:convert';

import 'package:http/http.dart' as http;

import 'employee_profile.dart';

class EmployeeProfileException implements Exception {
  const EmployeeProfileException(
    this.message, {
    this.needsTokenRefresh = false,
  });

  final String message;
  final bool needsTokenRefresh;

  @override
  String toString() => message;
}

class EmployeeProfileService {
  static const String _profileUrl =
      'https://businesscard.bankofabyssinia.com/api/me';

  Future<EmployeeProfile> fetchProfile({required String accessToken}) async {
    if (accessToken.trim().isEmpty) {
      throw const EmployeeProfileException(
        'Please sign in again.',
        needsTokenRefresh: true,
      );
    }

    late final http.Response response;
    try {
      response = await http
          .get(
            Uri.parse(_profileUrl),
            headers: {'Authorization': 'Bearer ${accessToken.trim()}'},
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const EmployeeProfileException(
        'Unable to load employee data. Please check your connection and try again.',
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const EmployeeProfileException(
        'Please sign in again.',
        needsTokenRefresh: true,
      );
    }

    if (response.statusCode != 200) {
      throw const EmployeeProfileException(
        'Unable to load employee data. Please try again.',
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw const EmployeeProfileException(
        'Unable to load employee data. Please try again.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const EmployeeProfileException(
        'Unable to load employee data. Please try again.',
      );
    }

    final userJson = decoded['user'];
    if (userJson is! Map<String, dynamic>) {
      throw const EmployeeProfileException(
        'Unable to load employee data. Please try again.',
      );
    }

    return EmployeeProfile.fromJson(userJson);
  }
}
