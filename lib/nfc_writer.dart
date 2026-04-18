import 'dart:convert';
import 'dart:typed_data';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:vcard_dart/vcard_dart.dart';

class NFCWriter {
  Future<void> writeVCard() async {
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

    // ✅ FIX: correct conversion for your version
    final vcardString = vcard.toString();

    final payload = Uint8List.fromList(utf8.encode(vcardString));

    final record = NdefRecord(
      typeNameFormat: NdefTypeNameFormat.media,
      type: Uint8List.fromList(utf8.encode("text/vcard")),
      identifier: Uint8List(0),
      payload: payload,
    );

    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      throw Exception("NFC not available");
    }

    NfcManager.instance.startSession(
      onDiscovered: (tag) async {
        try {
          final ndef = Ndef.from(tag);

          if (ndef == null || !ndef.isWritable) {
            throw Exception("Tag not writable");
          }

          await ndef.write(NdefMessage([record]));

          NfcManager.instance.stopSession(
            alertMessage: "Contact written successfully",
          );
        } catch (e) {
          NfcManager.instance.stopSession(
            errorMessage: "Write failed: $e",
          );
        }
      },
    );
  }
}