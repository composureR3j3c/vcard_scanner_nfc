import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:path_provider/path_provider.dart';

class NFCWriter {
  static const _vcardMimeType = 'text/x-vcard';

  Future<String> writeVCard() async {
    final completer = Completer<String>();
    final vcardString = _buildVCard21(
      family: 'Gezahegne',
      given: 'Bereket',
      additional: 'Axum',
      formattedName: 'Bereket Axum Gezahegne',
      organization: 'Bank of Abyssinia S.Co.',
      department: 'Auxiliary Infrastructure',
      title: 'System Administrator',
      email: 'BEREKET.AXUM@bankofabyssinia.com',
      office: 'Head Office',
      city: 'Addis Ababa',
      country: 'ET',
      cellPhones: const ['+251912356845', '+251713586845'],
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
      type: Uint8List.fromList(utf8.encode(_vcardMimeType)),
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
            'NFCWriter: writing message with 1 record of type $_vcardMimeType',
          );
          await ndef.write(NdefMessage([record]));
          _log('NFCWriter: write completed successfully');
          _log('NFCWriter: card content written:\n$vcardString');

          NfcManager.instance.stopSession(
            alertMessage: 'Contact written successfully',
          );
          if (!completer.isCompleted) {
            completer.complete(vcardString);
          }
        } catch (e) {
          _log('NFCWriter: write failed: $e');
          NfcManager.instance.stopSession(
            errorMessage: 'Write failed: $e',
          );
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      },
    );

    return completer.future;
  }

  bool _isValidVCard(String value) {
    final normalized = value.trim().replaceAll('\r\n', '\n');
    return normalized.startsWith('BEGIN:VCARD') &&
        normalized.contains('\nVERSION:2.1') &&
        normalized.contains('\nN:') &&
        normalized.contains('\nFN:') &&
        normalized.contains('\nORG:') &&
        normalized.contains('\nTITLE:') &&
        normalized.contains('\nEMAIL;INTERNET:') &&
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
    required String organization,
    required String department,
    required String title,
    required String email,
    required String office,
    required String city,
    required String country,
    required List<String> cellPhones,
  }) {
    final normalizedPhones = cellPhones
        .map(_normalizePhoneNumber)
        .where((phone) => phone.isNotEmpty)
        .toList();

    final lines = [
      'BEGIN:VCARD',
      'VERSION:2.1',
      'N:$family;$given;$additional;$prefix;$suffix',
      'FN:$formattedName',
      'ORG:$organization;$department',
      'TITLE:$title',
      'EMAIL;INTERNET:$email',
      'ADR;WORK:;;$office;$city;;;$country',
      ...normalizedPhones.map((phone) => 'TEL;CELL:$phone'),
      'END:VCARD',
    ];
    return lines.join('\r\n');
  }

  String _normalizePhoneNumber(String phoneNumber) {
    final trimmed = phoneNumber.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    return trimmed.startsWith('+') ? trimmed : '+$trimmed';
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
  }
}
