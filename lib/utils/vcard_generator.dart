import 'package:vcard_dart/vcard_dart.dart';

// Create a vCard
final vcard = VCard()
  ..formattedName = 'JohnDoe'
  ..name = StructuredName(
    family: 'Doe',
    given: 'John',
  )
  ..emails.add(Email.work('john@example.com'))
  ..telephones.add(Telephone.cell('+15551234567'))
  ..addresses.add(Address(
    street: '123MainSt',
    city: 'Anytown',
    region: 'CA',
    postalCode: '12345',
    country: 'USA',
    types: ['work'],
  ));
