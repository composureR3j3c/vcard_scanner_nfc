import 'dart:convert';

import 'package:http/http.dart' as http;

import 'employee_profile.dart';

class EmployeeProfileService {
  static const String _baseUrl =
      'https://businesscard.bankofabyssinia.com/apiMule/information';

  Future<EmployeeProfile> fetchProfile({required String employeeId}) async {
    final uri = Uri.parse(
      _baseUrl,
    ).replace(queryParameters: {'empID': employeeId});
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Could not load employee data (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected employee response format');
    }

    return EmployeeProfile.fromJson(decoded);
  }
}
