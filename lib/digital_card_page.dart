import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'employee_profile.dart';
import 'employee_profile_service.dart';
import 'nfc_writer.dart';
import 'session_user.dart';
import 'utils/vcard_generator.dart';

class DigitalCardPage extends StatefulWidget {
  const DigitalCardPage({
    super.key,
    required this.sessionUser,
    required this.onLogout,
  });

  static const _backgroundTop = Color(0xFFFCFAF4);
  static const _backgroundBottom = Color(0xFFF2EEE5);
  static const _cardGreenDeep = Color(0xFFD8A328);
  static const _cardGold = Color(0xFFD8A328);
  static const _textPrimary = Color(0xFF111827);
  static const _panelFill = Color(0xCCFFFFFF);
  static const _detailFill = Color(0xCCF8F7F2);
  final SessionUser sessionUser;
  final Future<void> Function() onLogout;

  @override
  State<DigitalCardPage> createState() => _DigitalCardPageState();
}

class _DigitalCardPageState extends State<DigitalCardPage> {
  final EmployeeProfileService _profileService = EmployeeProfileService();
  late Future<EmployeeProfile> _profileFuture;
  String? _copiedValue;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<EmployeeProfile> _loadProfile() {
    return _profileService.fetchProfile(employeeId: widget.sessionUser.id);
  }

  void _retry() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  Future<void> _copyToClipboard(String value) async {
    if (value.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: value));

    if (!mounted) {
      return;
    }

    setState(() {
      _copiedValue = value;
    });

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted || _copiedValue != value) {
        return;
      }

      setState(() {
        _copiedValue = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 84,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DigitalCardPage._cardGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Image.asset(
                'asset/logo.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employee Workspace',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: DigitalCardPage._cardGreenDeep,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.6,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'My Profile',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: DigitalCardPage._textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await widget.onLogout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DigitalCardPage._backgroundTop,
              DigitalCardPage._backgroundBottom,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -50,
              right: -50,
              child: IgnorePointer(
                child: Container(
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        DigitalCardPage._cardGold.withValues(alpha: 0.16),
                        DigitalCardPage._cardGold.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: FutureBuilder<EmployeeProfile>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const _CenteredStatus(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return _CenteredStatus(
                      child: _SurfacePanel(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 42,
                              color: DigitalCardPage._cardGreenDeep,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Unable to load employee data.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: DigitalCardPage._textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error ?? 'Please try again.'}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xA6111827),
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 18),
                            FilledButton(
                              onPressed: _retry,
                              style: FilledButton.styleFrom(
                                backgroundColor: DigitalCardPage._cardGold,
                                foregroundColor: DigitalCardPage._cardGreenDeep,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final profile = snapshot.data!;
                  final vcard = generateEmployeeVCard(profile);

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 760;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 980),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildCardAndDetails(
                                  isWide: isWide,
                                  profile: profile,
                                  vcard: vcard,
                                ),
                                // const SizedBox(height: 20),
                                // _buildNfcButton(context, vcard),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardAndDetails({
    required bool isWide,
    required EmployeeProfile profile,
    required String vcard,
  }) {
    final publicCardUrl =
        'https://businesscard.bankofabyssinia.com/u/${widget.sessionUser.username}';

    final cardPanel = _SurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Digital ID Card',
            style: TextStyle(
              color: DigitalCardPage._cardGreenDeep,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Review both sides of your official identification below.',
            style: TextStyle(
              color: Color(0xA6111827),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _EmployeeIdDeck(
                profile: profile,
                qrData: publicCardUrl,
                employeeId: widget.sessionUser.id,
              ),
            ),
          ),
        ],
      ),
    );

    final detailsPanel = _SurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: TextStyle(
              color: DigitalCardPage._cardGreenDeep,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.2,
            ),
          ),
          const SizedBox(height: 16),
          _DetailTile(label: 'Email', value: profile.email, breakValue: true),
          const SizedBox(height: 12),
          if (profile.primaryPhone.isNotEmpty) ...[
            _DetailTile(label: 'Phone', value: profile.primaryPhone),
            const SizedBox(height: 12),
          ],
          _DetailTile(label: 'Department', value: profile.department),
          const SizedBox(height: 12),
          _DetailTile(label: 'Office', value: profile.office),
          const SizedBox(height: 12),
          _PublicQrTile(
            url: publicCardUrl,
            copied: _copiedValue == publicCardUrl,
            onCopy: () => _copyToClipboard(publicCardUrl),
          ),
          const SizedBox(height: 12),
          _DetailTile(
            label: 'Location',
            value: [
              profile.city,
              profile.country,
            ].where((value) => value.isNotEmpty).join(', '),
          ),
        ],
      ),
    );

    final topSection = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cardPanel),
              const SizedBox(width: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 256),
                child: detailsPanel,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [cardPanel, const SizedBox(height: 16), detailsPanel],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        topSection,
        const SizedBox(height: 0),
        // _QrSection(vcard: vcard, publicCardUrl: publicCardUrl),
      ],
    );
  }

  Widget _buildNfcButton(BuildContext context, String vcard) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: DigitalCardPage._panelFill,
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 36,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Write to NFC',
              style: TextStyle(
                color: DigitalCardPage._textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap below, then hold your phone near the NFC tag to save this contact card.',
              style: TextStyle(
                color: Color(0xA6111827),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);

                messenger.showSnackBar(
                  const SnackBar(content: Text('Hold phone near NFC tag...')),
                );

                try {
                  await NFCWriter().writeToTag(vcard);

                  messenger.showSnackBar(
                    const SnackBar(content: Text('NFC written successfully ✅')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to write NFC : ${e.toString()}'),
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: DigitalCardPage._cardGold,
                foregroundColor: DigitalCardPage._cardGreenDeep,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Tap to Write NFC'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredStatus extends StatelessWidget {
  const _CenteredStatus({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: child,
        ),
      ),
    );
  }
}

class _SurfacePanel extends StatelessWidget {
  const _SurfacePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DigitalCardPage._panelFill,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 60,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.label,
    required this.value,
    this.breakValue = false,
  });

  final String label;
  final String value;
  final bool breakValue;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DigitalCardPage._detailFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0x73111827),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value.isEmpty ? 'Unavailable' : value,
              softWrap: breakValue,
              overflow: breakValue
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xCC111827),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicQrTile extends StatelessWidget {
  const _PublicQrTile({
    required this.url,
    required this.copied,
    required this.onCopy,
  });

  final String url;
  final bool copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final qrBox = (tileWidth * 0.58).clamp(112.0, 140.0);
        final qrPadding = (qrBox * 0.055).clamp(6.0, 8.0);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Public QR',
                        style: TextStyle(
                          color: Color(0x73111827),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onCopy,
                      tooltip: 'Copy public URL',
                      splashRadius: 18,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        copied ? Icons.check_rounded : Icons.copy_rounded,
                        size: 16,
                        color: copied
                            ? DigitalCardPage._cardGreenDeep
                            : const Color(0x66111827),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: qrBox,
                        height: qrBox,
                        padding: EdgeInsets.all(qrPadding),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.05),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x120F172A),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: url,
                          version: QrVersions.auto,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: DigitalCardPage._textPrimary,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: DigitalCardPage._textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Scan to open public profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        url,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.28),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({
    required this.title,
    required this.description,
    required this.data,
  });

  final String title;
  final String description;
  final String data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final qrSize = (cardWidth * 0.62).clamp(132.0, 190.0);
        final qrPadding = (cardWidth * 0.045).clamp(10.0, 14.0);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: DigitalCardPage._textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xA6111827),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x140F172A),
                          blurRadius: 28,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(qrPadding),
                      child: QrImageView(
                        data: data,
                        version: QrVersions.auto,
                        size: qrSize,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: DigitalCardPage._cardGreenDeep,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: DigitalCardPage._textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmployeeIdDeck extends StatelessWidget {
  const _EmployeeIdDeck({
    required this.profile,
    required this.qrData,
    required this.employeeId,
  });

  final EmployeeProfile profile;
  final String qrData;
  final String employeeId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EmployeeIdFront(profile: profile, employeeId: employeeId),
        const SizedBox(height: 18),
        _EmployeeIdBack(profile: profile, qrData: qrData),
      ],
    );
  }
}

class _EmployeeIdFront extends StatelessWidget {
  const _EmployeeIdFront({required this.profile, required this.employeeId});

  final EmployeeProfile profile;
  final String employeeId;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.58,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final cardHeight = constraints.maxHeight;
          final isCompact = cardWidth < 380 || cardHeight < 250;
          final padding = math.min(
            (cardWidth * 0.055).clamp(12.0, 22.0),
            cardHeight * 0.08,
          );
          final photoSize = math.min(
            (cardWidth * 0.31).clamp(74.0, 126.0),
            cardHeight * (isCompact ? 0.32 : 0.44),
          );
          final logoSize = (cardWidth * 0.1).clamp(28.0, 40.0);
          final nameSize = (cardWidth * 0.055).clamp(16.0, 22.0);
          final titleSize = (cardWidth * 0.032).clamp(10.5, 13.0);
          final metaSize = (cardWidth * 0.028).clamp(9.4, 11.2);
          final accentCircle = cardWidth * 0.42;

          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A4E3B), Color(0xFF073024)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26073024),
                  blurRadius: 34,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -cardWidth * 0.12,
                  right: -22,
                  child: Container(
                    width: accentCircle,
                    height: accentCircle,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -cardWidth * 0.11,
                  left: -cardWidth * 0.06,
                  child: Container(
                    width: cardWidth * 0.37,
                    height: cardWidth * 0.37,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DigitalCardPage._cardGold.withValues(alpha: 0.14),
                    ),
                  ),
                ),
                Positioned(
                  top: cardWidth * 0.14,
                  left: -cardWidth * 0.08,
                  child: Transform.rotate(
                    angle: -0.35,
                    child: Container(
                      width: cardWidth * 0.36,
                      height: cardWidth * 0.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            DigitalCardPage._cardGold.withValues(alpha: 0.2),
                            DigitalCardPage._cardGold.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -cardWidth * 0.07,
                  right: cardWidth * 0.11,
                  child: Transform.rotate(
                    angle: 0.72,
                    child: Container(
                      width: (cardWidth * 0.2).clamp(56.0, 84.0),
                      height: (cardWidth * 0.56).clamp(150.0, 220.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isCompact)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CardBrandHeader(logoSize: logoSize),
                            SizedBox(
                              height: (cardHeight * 0.035).clamp(6.0, 10.0),
                            ),
                            _CardIdPill(
                              id: profile.id.isEmpty ? employeeId : profile.id,
                            ),
                          ],
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(child: _CardBrandHeader()),
                            const SizedBox(width: 12),
                            _CardIdPill(
                              id: profile.id.isEmpty ? employeeId : profile.id,
                            ),
                          ],
                        ),
                      const Spacer(),
                      if (isCompact)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: _ProfileBadge(
                                profile: profile,
                                size: photoSize,
                                radius: (photoSize * 0.24).clamp(18.0, 28.0),
                                showBorder: true,
                                backgroundColor: DigitalCardPage._cardGold
                                    .withValues(alpha: 0.16),
                              ),
                            ),
                            SizedBox(
                              height: (cardHeight * 0.03).clamp(6.0, 10.0),
                            ),
                            _FrontIdentityBlock(
                              profile: profile,
                              cardWidth: cardWidth,
                              nameSize: nameSize,
                              titleSize: titleSize,
                              metaSize: metaSize,
                              compact: true,
                              tight: cardHeight < 235,
                            ),
                          ],
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: _FrontIdentityBlock(
                                profile: profile,
                                cardWidth: cardWidth,
                                nameSize: nameSize,
                                titleSize: titleSize,
                                metaSize: metaSize,
                                compact: false,
                                tight: false,
                              ),
                            ),
                            SizedBox(
                              width: (cardWidth * 0.04).clamp(10.0, 16.0),
                            ),
                            _ProfileBadge(
                              profile: profile,
                              size: photoSize,
                              radius: (photoSize * 0.24).clamp(20.0, 30.0),
                              showBorder: true,
                              backgroundColor: DigitalCardPage._cardGold
                                  .withValues(alpha: 0.16),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmployeeIdBack extends StatelessWidget {
  const _EmployeeIdBack({required this.profile, required this.qrData});

  final EmployeeProfile profile;
  final String qrData;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.58,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final cardHeight = constraints.maxHeight;
          final isCompact = cardWidth < 340;
          final padding = math.min(
            (cardWidth * 0.055).clamp(12.0, 22.0),
            cardHeight * 0.08,
          );
          final reservedHeight = padding * 2 + 14 + 12 + 44;
          final availablePanelHeight = math.max(
            72.0,
            cardHeight - reservedHeight,
          );
          final qrSize = math.min(
            (cardWidth * 0.34).clamp(88.0, 140.0),
            availablePanelHeight * 0.78,
          );

          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: const Color(0xFFF8F5EC),
              border: Border.all(color: const Color(0x140F172A)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120F172A),
                  blurRadius: 30,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -cardWidth * 0.05,
                  left: -cardWidth * 0.07,
                  child: Container(
                    width: cardWidth * 0.38,
                    height: cardWidth * 0.38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DigitalCardPage._cardGold.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  right: -cardWidth * 0.09,
                  top: cardWidth * 0.055,
                  child: Transform.rotate(
                    angle: 0.32,
                    child: Container(
                      width: cardWidth * 0.38,
                      height: cardWidth * 0.38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: DigitalCardPage._cardGreenDeep.withValues(
                            alpha: 0.06,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -cardWidth * 0.09,
                  right: -cardWidth * 0.03,
                  child: Transform.rotate(
                    angle: -0.48,
                    child: Container(
                      width: (cardWidth * 0.3).clamp(80.0, 120.0),
                      height: (cardWidth * 0.53).clamp(130.0, 210.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            DigitalCardPage._cardGreenDeep.withValues(
                              alpha: 0.08,
                            ),
                            DigitalCardPage._cardGreenDeep.withValues(
                              alpha: 0.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  top: 18,
                  child: Opacity(
                    opacity: 0.2,
                    child: Row(
                      children: List.generate(
                        5,
                        (index) => Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: index == 4 ? 0 : 8),
                            height: 1,
                            color: DigitalCardPage._cardGreenDeep,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _BackQrPanel(qrData: qrData, qrSize: qrSize),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This card is the property of Bank of Abyssinia. If found, please return it to the nearest branch or mail to P.O. Box 12947, Addis Ababa, Ethiopia.',
                        style: TextStyle(
                          color: const Color(0xB3111827),
                          fontSize: isCompact ? 10 : 10.8,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({
    required this.profile,
    required this.size,
    required this.radius,
    this.showBorder = false,
    this.backgroundColor,
  });

  final EmployeeProfile profile;
  final double size;
  final double radius;
  final bool showBorder;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final photoBytes = profile.photoBytes;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
        border: showBorder
            ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.8)
            : null,
        boxShadow: showBorder
            ? const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: photoBytes == null
          ? Center(
              child: Text(
                profile.initials,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.28,
                ),
              ),
            )
          : Image.memory(
              photoBytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    profile.initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: size * 0.28,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _FrontMetaText extends StatelessWidget {
  const _FrontMetaText({required this.value, required this.fontSize});

  final String value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.92),
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _FrontIdentityBlock extends StatelessWidget {
  const _FrontIdentityBlock({
    required this.profile,
    required this.cardWidth,
    required this.nameSize,
    required this.titleSize,
    required this.metaSize,
    required this.compact,
    required this.tight,
  });

  final EmployeeProfile profile;
  final double cardWidth;
  final double nameSize;
  final double titleSize;
  final double metaSize;
  final bool compact;
  final bool tight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: (cardWidth * 0.16).clamp(40.0, 64.0),
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        SizedBox(height: compact ? 8 : 12),
        Text(
          [
            profile.title,
            profile.fullName,
          ].where((value) => value.isNotEmpty).join(' '),
          maxLines: tight ? 1 : (compact ? 2 : 3),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: nameSize,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          [
            profile.jobTitle,
            profile.department,
          ].where((value) => value.isNotEmpty).join(' • '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        SizedBox(height: compact ? 10 : 14),
        if (profile.primaryPhone.isNotEmpty)
          _FrontMetaText(value: profile.primaryPhone, fontSize: metaSize),
        if (!tight &&
            profile.primaryPhone.isNotEmpty &&
            profile.email.isNotEmpty)
          const SizedBox(height: 4),
        if (!tight && profile.email.isNotEmpty)
          _FrontMetaText(
            value: profile.email.toUpperCase(),
            fontSize: metaSize,
          ),
      ],
    );
  }
}

class _CardBrandHeader extends StatelessWidget {
  const _CardBrandHeader({this.logoSize = 40});

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset('asset/logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'አቢሲኒያ ባንክ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Bank of Abyssinia',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardIdPill extends StatelessWidget {
  const _CardIdPill({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        'ID $id',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _BackQrPanel extends StatelessWidget {
  const _BackQrPanel({required this.qrData, required this.qrSize});

  final String qrData;
  final double qrSize;

  @override
  Widget build(BuildContext context) {
    final panelWidth = qrSize + (qrSize * 0.18);
    return Container(
      width: panelWidth,
      padding: EdgeInsets.all((qrSize * 0.08).clamp(8.0, 12.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1A0F172A), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: qrSize,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: DigitalCardPage._textPrimary,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: DigitalCardPage._textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackMetaRow extends StatelessWidget {
  const _BackMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0x73111827),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'Unavailable' : value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: DigitalCardPage._textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}
