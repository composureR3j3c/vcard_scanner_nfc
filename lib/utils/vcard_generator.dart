import 'package:flutter/foundation.dart';

import '../employee_profile.dart';

String generateEmployeeVCard(EmployeeProfile profile) {
  final slug = profile.publicProfileSlug;
  final publicUrl = 'https://businesscard.bankofabyssinia.com/u/$slug';

  final lines = <String>[
    'BEGIN:VCARD',
    'VERSION:3.0',
    'FN:${_escapeVCardValue(profile.fullName)}',
    'N:${_escapeVCardValue(profile.familyName)};${_escapeVCardValue(profile.givenName)};;;',
  ];

  if (profile.jobTitle.isNotEmpty) {
    lines.add('TITLE:${_escapeVCardValue(profile.jobTitle)}');
  }

  final orgParts = [
    profile.employer.trim(),
    profile.department.trim(),
  ].where((value) => value.isNotEmpty).toList();
  if (orgParts.isNotEmpty) {
    lines.add('ORG:${orgParts.map(_escapeVCardValue).join(';')}');
  }

  if (profile.email.isNotEmpty) {
    lines.add('EMAIL;TYPE=WORK:${_escapeVCardValue(profile.email)}');
  }

  for (final entry in profile.phoneNumbers.indexed) {
    final phone = entry.$2;
    final normalizedPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (normalizedPhone.isNotEmpty) {
      final phoneType = entry.$1 == 0 ? 'WORK,VOICE' : 'CELL';
      lines.add('TEL;TYPE=$phoneType:$normalizedPhone');
    }
  }

  if (profile.office.isNotEmpty ||
      profile.city.isNotEmpty ||
      profile.country.isNotEmpty) {
    lines.add(
      'ADR;TYPE=WORK:;;${_escapeVCardValue(profile.office)};${_escapeVCardValue(profile.city)};;;${_escapeVCardValue(profile.country)}',
    );
  }

  // lines.add('PHOTO;VALUE=uri:$photoUrl');
  lines.add('URL:$publicUrl');
  lines.add('END:VCARD');

  final vcard = lines.join('\r\n');
  debugPrint('Generated vCard:\n$vcard');
  return vcard;
}

String _escapeVCardValue(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,')
      .replaceAll('\n', r'\n');
}
