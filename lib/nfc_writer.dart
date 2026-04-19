import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:path_provider/path_provider.dart';

class NFCWriter {
  Future<void> writeVCard() async {
    final vcardString = _buildVCard21(
      family: 'HR',
      given: 'Abay',
      additional: 'Bank',
      formattedName: 'Abay Bank HR',
      cellPhone: '+251115571674',
    );
    final isValidVCard = _isValidVCard(vcardString);

    _log('NFCWriter: generated vCard:\n$vcardString');
    _log('NFCWriter: vCard valid = $isValidVCard');

    if (!isValidVCard) {
      throw Exception('Generated vCard is invalid');
    }

    final savedFile = await _saveVCardToFile(vcardString);
    _log('NFCWriter: vCard saved to ${savedFile.path}');

    final payload = Uint8List.fromList(utf8.encode(vcardString));
    _log('NFCWriter: payload length = ${payload.length} bytes');

    final record = NdefRecord(
      typeNameFormat: NdefTypeNameFormat.media,
      type: Uint8List.fromList(utf8.encode('text/vcard')),
      identifier: Uint8List(0),
      payload: payload,
    );

    final isAvailable = await NfcManager.instance.isAvailable();
    _log('NFCWriter: NFC available = $isAvailable');
    if (!isAvailable) {
      throw Exception('NFC not available');
    }

    _log('NFCWriter: waiting for NFC tag...');
    NfcManager.instance.startSession(
      onDiscovered: (tag) async {
        try {
          _log('NFCWriter: tag discovered = ${tag.data}');
          final ndef = Ndef.from(tag);

          if (ndef == null || !ndef.isWritable) {
            _log(
              'NFCWriter: NDEF unavailable or tag not writable. '
              'ndef == null: ${ndef == null}, '
              'isWritable: ${ndef?.isWritable}',
            );
            throw Exception('Tag not writable');
          }

          _log(
            'NFCWriter: writing message with 1 record of type text/vcard',
          );
          await ndef.write(NdefMessage([record]));
          _log('NFCWriter: write completed successfully');
          _log('NFCWriter: card content written:\n$vcardString');

          NfcManager.instance.stopSession(
            alertMessage: 'Contact written successfully',
          );
        } catch (e) {
          _log('NFCWriter: write failed: $e');
          NfcManager.instance.stopSession(
            errorMessage: 'Write failed: $e',
          );
        }
      },
    );
  }

  bool _isValidVCard(String value) {
    final normalized = value.trim().replaceAll('\r\n', '\n');
    return normalized.startsWith('BEGIN:VCARD') &&
        normalized.contains('\nVERSION:2.1') &&
        normalized.contains('\nN:') &&
        normalized.contains('\nFN:') &&
        normalized.contains('\nTEL;CELL:') &&
        normalized.endsWith('END:VCARD');
  }

  String _buildVCard21({
    required String family,
    required String given,
    String additional = '',
    String prefix = '',
    String suffix = '',
    required String formattedName,
    required String cellPhone,
  }) {
    final lines = [
      'BEGIN:VCARD',
      'VERSION:2.1',
      'N:$family;$given;$additional;$prefix;$suffix',
      'FN:$formattedName',
      'TEL;CELL:$cellPhone',
      'END:VCARD',
    ];
    return lines.join('\r\n');
  }

  Future<File> _saveVCardToFile(String vcardContent) async {
    final directory = await getApplicationDocumentsDirectory();
    _log('NFCWriter: vCard directory = ${directory.path}');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/contact_$timestamp.vcf');
    return file.writeAsString(vcardContent);
  }

  void _log(String message) {
    debugPrint(message);
    print(message);
  }
}
