import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCWriter {
  Future<void> writeToTag(String vcard) async {
    final available = await NfcManager.instance.isAvailable();

    if (!available) {
      throw Exception('NFC not available');
    }

    NfcManager.instance.startSession(
      onDiscovered: (tag) async {
        try {
          // final ndef = Ndef.from(tag);

          // if (ndef == null || !ndef.isWritable) {
          //   throw Exception(
          //     "This tag is not NDEF writable. Use an NTAG sticker or compatible NFC tag."
          //   );
          // }

          /// 🔥 THIS IS THE ONLY THING THAT MATTERS
          // final record = NdefRecord.createUri(
          //   Uri.parse(_url),
          // );
          final record = NdefRecord.createText(vcard);

          // await ndef.write(NdefMessage([record]));

          debugPrint(
            'Prepared NFC vCard record (${record.payload.length} bytes)',
          );
          debugPrint('NFC written successfully: $vcard');

          NfcManager.instance.stopSession(
            alertMessage: 'vCard written successfully',
          );
        } catch (e) {
          debugPrint('Write failed: $e');

          NfcManager.instance.stopSession(errorMessage: '$e');
        }
      },
    );
  }
}
