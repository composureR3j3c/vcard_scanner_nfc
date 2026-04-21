import 'dart:convert';
import 'dart:typed_data';

class EmployeeProfile {
  const EmployeeProfile({
    required this.id,
    required this.title,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.jobTitle,
    required this.department,
    required this.employer,
    required this.office,
    required this.city,
    required this.country,
    required this.phoneNumbers,
    this.photoBytes,
  });

  final String id;
  final String title;
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String jobTitle;
  final String department;
  final String employer;
  final String office;
  final String city;
  final String country;
  final List<String> phoneNumbers;
  final Uint8List? photoBytes;

  String get fullName => [
    firstName.trim(),
    middleName.trim(),
    lastName.trim(),
  ].where((part) => part.isNotEmpty).join(' ');

  String get givenName => [
    firstName.trim(),
    middleName.trim(),
  ].where((part) => part.isNotEmpty).join(' ');

  String get familyName => lastName.trim();

  String get publicProfileSlug {
    final parts = [firstName, middleName]
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .map(
          (value) => value
              .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
              .replaceAll(RegExp(r'^-+|-+$'), ''),
        )
        .where((value) => value.isNotEmpty);

    return [...parts, id.trim()].where((value) => value.isNotEmpty).join('-');
  }

  String get primaryPhone => phoneNumbers.isEmpty ? '' : phoneNumbers.first;

  String get initials {
    final parts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    final photo = (json['Photo'] as String? ?? '').trim();

    return EmployeeProfile(
      id: (json['iD'] as String? ?? '').trim(),
      title: (json['Title'] as String? ?? '').trim(),
      firstName: (json['firstName'] as String? ?? '').trim(),
      middleName: (json['middleName'] as String? ?? '').trim(),
      lastName: (json['lastName'] as String? ?? '').trim(),
      email: (json['Email'] as String? ?? '').trim().toLowerCase(),
      jobTitle: (json['jobTitle'] as String? ?? '').trim(),
      department: (json['Department'] as String? ?? '').trim(),
      employer: (json['Employer'] as String? ?? '').trim(),
      office: (json['Office'] as String? ?? '').trim(),
      city: (json['City'] as String? ?? '').trim(),
      country: (json['Country'] as String? ?? '').trim(),
      phoneNumbers: ((json['phoneNumber'] as List<dynamic>? ?? const [])
          .map((value) => value.toString().trim())
          .where((value) => value.isNotEmpty)
          .map(_normalizePhone)
          .toList()),
      photoBytes: photo.isEmpty ? null : base64Decode(photo),
    );
  }

  static String _normalizePhone(String phone) {
    return phone.startsWith('+') ? phone : '+$phone';
  }
}
