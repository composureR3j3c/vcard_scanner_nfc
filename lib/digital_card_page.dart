import 'package:flutter/material.dart';

import 'nfc_writer.dart';

class DigitalCardPage extends StatelessWidget {
  const DigitalCardPage({
    super.key,
    required this.sessionEmail,
    required this.onLogout,
  });

  static const _backgroundTop = Color(0xFFFCFAF4);
  static const _backgroundBottom = Color(0xFFF2EEE5);
  static const _cardGreenDeep = Color(0xFF0F5A43);
  static const _cardGold = Color(0xFFD8A328);
  static const _textPrimary = Color(0xFF111827);
  static const _panelFill = Color(0xCCFFFFFF);
  static const _detailFill = Color(0xCCF8F7F2);

  final String sessionEmail;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,

        title: const Text('Employee Profile'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await onLogout();
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
            colors: [_backgroundTop, _backgroundBottom],
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
                        _cardGold.withValues(alpha: 0.16),
                        _cardGold.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
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
                            _buildCardAndDetails(isWide: isWide),
                            const SizedBox(height: 20),
                            _buildNfcButton(context),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardAndDetails({required bool isWide}) {
    final cardPanel = _SurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business card',
            style: TextStyle(
              color: _cardGreenDeep,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Flip the card to review both sides before printing.',
            style: TextStyle(
              color: Color(0xA6111827),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: const _EmployeeCard(),
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
              color: _cardGreenDeep,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.2,
            ),
          ),
          const SizedBox(height: 16),
          _DetailTile(label: 'Email', value: sessionEmail, breakValue: true),
          const SizedBox(height: 12),
          const _DetailTile(label: 'Phone', value: '+251912356845'),
          const SizedBox(height: 12),
          const _DetailTile(
            label: 'Public card',
            value: 'bankofabyssinia.com/staff/bereket-axum',
            breakValue: true,
          ),
        ],
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: cardPanel),
          const SizedBox(width: 24),
          Expanded(flex: 2, child: detailsPanel),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [cardPanel, const SizedBox(height: 16), detailsPanel],
    );
  }

  Widget _buildNfcButton(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: _panelFill,
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
                color: _textPrimary,
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
                  final vcard = await NFCWriter().writeVCard();

                  messenger.showSnackBar(
                    const SnackBar(content: Text('NFC written successfully ✅')),
                  );

                  if (!context.mounted) {
                    return;
                  }

                  await showDialog<void>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('Generated vCard'),
                        content: SingleChildScrollView(
                          child: SelectableText(vcard),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
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
                backgroundColor: _cardGold,
                foregroundColor: _cardGreenDeep,
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
            Text(
              label,
              style: const TextStyle(
                color: Color(0x73111827),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
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

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.42,

      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F5A43), Color(0xFF083B2D)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2B0F5A43),
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -18,
              right: -10,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -36,
              left: -22,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DigitalCardPage._cardGold.withValues(alpha: 0.18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Image.asset(
                          'asset/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'BANK OF ABYSSINIA',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xD9FFFFFF),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bereket Axum Gezahegne',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'System Administrator',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: DigitalCardPage._cardGold.withValues(
                              alpha: 0.95,
                            ),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _MiniCardMeta(
                              icon: Icons.call_outlined,
                              text: '+251912356845',
                            ),
                            _MiniCardMeta(
                              icon: Icons.mail_outline_rounded,
                              text: 'BEREKET.AXUM@bankofabyssinia.com',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCardMeta extends StatelessWidget {
  const _MiniCardMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.92)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
