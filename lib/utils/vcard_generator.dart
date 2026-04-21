import 'package:vcard_dart/vcard_dart.dart';

import '../employee_profile.dart';

String generateEmployeeVCard(EmployeeProfile profile) {
  final vcard = VCard(version: VCardVersion.v40)
    ..formattedName = profile.fullName
    ..name = StructuredName(
      family: profile.familyName,
      given: profile.givenName,
    )
    ..title = profile.jobTitle
    ..organization = Organization(
      name: profile.employer,
      units: profile.department.isEmpty ? const [] : [profile.department],
    )
    ..emails.add(Email.work(profile.email, pref: 1));

  for (final phone in profile.phoneNumbers) {
    vcard.telephones.add(Telephone.cell(phone));
  }

  if (profile.office.isNotEmpty ||
      profile.city.isNotEmpty ||
      profile.country.isNotEmpty) {
    vcard.addresses.add(
      Address(
        street: profile.office,
        city: profile.city,
        country: profile.country,
        types: const ['work'],
      ),
    );
  }

  return const VCardGenerator(
    foldLines: false,
    useModernTypes: true,
  ).generate(vcard, version: VCardVersion.v40);
}
