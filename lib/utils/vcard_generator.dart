import 'package:vcard_dart/vcard_dart.dart';

// Create a vCard
final vcard = VCard()
  ..formattedName = 'John Doe'
  ..name = StructuredName(
    family: 'Doe',
    given: 'John',
  )
  ..emails.add(Email.work('john@example.com'))
  ..telephones.add(Telephone.cell('+1-555-123-4567'))
  ..addresses.add(Address(
    street: '123 Main St',
    city: 'Anytown',
    region: 'CA',
    postalCode: '12345',
    country: 'USA',
    types: ['work'],
  ));