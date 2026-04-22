import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../employee_profile.dart';

const _cardGreenDeep = Color(0xFFD8A328);
const _cardGold = Color(0xFFD8A328);
const _textPrimary = Color(0xFF111827);

class EmployeeIdBack extends StatelessWidget {
  const EmployeeIdBack({
    super.key,
    required this.profile,
    required this.qrData,
  });

  final EmployeeProfile profile;
  final String qrData;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AspectRatio(
      aspectRatio: 1.8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final cardHeight = constraints.maxHeight;
          final isCompact = cardWidth < 340;
          final padding = math.min(
            (cardWidth * 0.055).clamp(12.0, 22.0),
            cardHeight * 0.08,
          );
          final reservedHeight = padding * 2 + 7 + 6 + 12;
          final availablePanelHeight = math.max(
            100.0,
            cardHeight - reservedHeight,

          );
          final qrSize = math.min(cardWidth * 0.6, availablePanelHeight);

          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: isDark ? const Color(0xFF111827) : const Color(0xFFF8F5EC),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0x140F172A),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0x47000000)
                      : const Color(0x120F172A),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
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
                      color: _cardGold.withValues(alpha: 0.08),
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
                          color: _cardGreenDeep.withValues(alpha: 0.06),
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
                            _cardGreenDeep.withValues(alpha: 0.08),
                            _cardGreenDeep.withValues(alpha: 0.0),
                          ],
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
                      // const SizedBox(height: 14),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: _BackQrPanel(
                              qrData: qrData,
                              qrSize: qrSize,
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 6),
                      Text(
                        'This card is the property of Bank of Abyssinia. If found, please return it to the nearest branch or mail to P.O. Box 12947, Addis Ababa, Ethiopia.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xD1F3F4F6)
                              : const Color(0xB3111827),
                          fontSize: isCompact ? 5 : 5.8,
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

class _BackQrPanel extends StatelessWidget {
  const _BackQrPanel({
    required this.qrData,
    required this.qrSize,
    required this.isDark,
  });

  final String qrData;
  final double qrSize;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: qrSize,
      backgroundColor: Colors.white,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: _textPrimary,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: _textPrimary,
      ),
    );
  }
}
