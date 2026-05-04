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
    final photo = _readString(json, const ['image', 'Photo']);

    return EmployeeProfile(
      id: _readString(json, const ['centralId', 'localId', 'iD', 'id']),
      title: _readString(json, const ['title', 'Title']),
      firstName: _readString(json, const ['firstName']),
      middleName: _readString(json, const ['middleName']),
      lastName: _readString(json, const ['lastName']),
      email: _readString(json, const ['email', 'Email']).toLowerCase(),
      jobTitle: _readString(json, const ['jobTitle']),
      department: _readString(json, const ['department', 'Department']),
      employer: _readString(json, const ['employer', 'Employer']),
      office: _readString(json, const ['office', 'Office']),
      city: _readString(json, const ['city', 'City']),
      country: _readString(json, const ['country', 'Country']),
      phoneNumbers: ((_readList(json, const ['phone', 'phoneNumber']))
          .map((value) => value.toString().trim())
          .where((value) => value.isNotEmpty)
          .map(_normalizePhone)
          .toList()),
      photoBytes: _decodePhoto(photo),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iD': id,
      'Title': title,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'Email': email,
      'jobTitle': jobTitle,
      'Department': department,
      'Employer': employer,
      'Office': office,
      'City': city,
      'Country': country,
      'phoneNumber': phoneNumbers,
      'Photo': photoBytes == null ? '' : base64Encode(photoBytes!),
    };
  }

  static String _normalizePhone(String phone) {
    return phone.startsWith('+') ? phone : '+$phone';
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
  }

  static List<dynamic> _readList(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is List<dynamic>) {
        return value;
      }
    }

    return const [];
  }

  static Uint8List? _decodePhoto(String photo) {
    if (photo.isEmpty) {
      return null;
    }

    final base64Photo = photo.contains(',') ? photo.split(',').last : photo;
    return base64Decode(base64Photo);
  }
}
