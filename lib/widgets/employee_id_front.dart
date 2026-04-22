import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../employee_profile.dart';

const _cardGold = Color(0xFFD8A328);

class EmployeeIdFront extends StatelessWidget {
  const EmployeeIdFront({super.key, required this.profile});

  final EmployeeProfile profile;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final cardHeight = constraints.maxHeight;
          final isCompact = cardWidth < 380 || cardHeight < 250;
          final scale = math.min(
            (cardWidth / 380).clamp(0.72, 1.0),
            (cardHeight / 220).clamp(0.72, 1.0),
          );
          final tightLayout = cardHeight < 255;
          final padding = math.min(
            (cardWidth * 0.045).clamp(9.0, 18.0),
            cardHeight * 0.07,
          );
          final photoSize = math.min(
            (cardWidth * 0.26).clamp(60.0, 108.0),
            cardHeight * (isCompact ? 0.27 : 0.38),
          );
          final logoSize = (cardWidth * 0.3 * scale).clamp(22.0, 34.0);
          final nameSize = (cardWidth * 0.047 * scale).clamp(12.0, 17.0);
          final titleSize = (cardWidth * 0.026 * scale).clamp(8.4, 10.6);
          final metaSize = (cardWidth * 0.022 * scale).clamp(7.6, 9.4);
          final accentCircle = cardWidth * 0.42;

          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD8A328), Color(0xFFD8A328)],
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
                      color: _cardGold.withValues(alpha: 0.14),
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
                            _cardGold.withValues(alpha: 0.2),
                            _cardGold.withValues(alpha: 0.02),
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
                  child: IgnorePointer(
                    child: Center(
                      child: Opacity(
                        opacity: 0.14,
                        child: Image.asset(
                          'asset/logo.png',
                          width: cardWidth * 0.5,
                          fit: BoxFit.contain,
                          color: Colors.white,
                          colorBlendMode: BlendMode.srcIn,
                        ),
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isCompact)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_CardBrandHeader(logoSize: logoSize)],
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [const Expanded(child: _CardBrandHeader())],
                        ),
                      // const Spacer(),
                      SizedBox(height: (cardHeight * 0.9).clamp(6.0, 12.0)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 7,
                            child: _FrontIdentityBlock(
                              profile: profile,
                              cardWidth: cardWidth,
                              nameSize: nameSize,
                              titleSize: titleSize,
                              metaSize: metaSize,
                              scale: scale,
                              compact: isCompact,
                              tight: tightLayout,
                            ),
                          ),
                          // SizedBox(width: (cardWidth * 0.03).clamp(6.0, 12.0)),
                          Flexible(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _ProfileBadge(
                                profile: profile,
                                size: photoSize * (isCompact ? 0.92 : 1.0),
                                radius: (photoSize * 0.24).clamp(18.0, 30.0),
                                showBorder: true,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  250,
                                  189,
                                  46,
                                ).withValues(alpha: 0.16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: (cardHeight * 0.04).clamp(6.0, 12.0)),
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
    required this.scale,
    required this.compact,
    required this.tight,
  });

  final EmployeeProfile profile;
  final double cardWidth;
  final double nameSize;
  final double titleSize;
  final double metaSize;
  final double scale;
  final bool compact;
  final bool tight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: (cardWidth * 0.14).clamp(30.0, 52.0),
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        SizedBox(height: (compact ? 6 : 9) * scale),
        Text(
          [
            profile.title,
            profile.fullName,
          ].where((value) => value.isNotEmpty).join(' '),
          maxLines: tight ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: nameSize,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          [
            profile.jobTitle,
            profile.department,
          ].where((value) => value.isNotEmpty).join(' •  '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        SizedBox(height: (compact ? 10 : 12) * scale),
        if (profile.primaryPhone.isNotEmpty)
          _FrontMetaText(value: profile.primaryPhone, fontSize: metaSize),
        if (profile.primaryPhone.isNotEmpty && profile.email.isNotEmpty)
          const SizedBox(height: 4),
        if (profile.email.isNotEmpty)
          _FrontMetaText(
            value: profile.email.toUpperCase(),
            fontSize: metaSize,
          ),
      ],
    );
  }
}

class _CardBrandHeader extends StatelessWidget {
  const _CardBrandHeader({this.logoSize = 50});

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          padding: const EdgeInsets.all(4),

          child: Image.asset(
            'asset/logo.png',
            fit: BoxFit.contain,
            color: Colors.black,
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 5),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
              // SizedBox(height: 1),
              Text(
                'Bank of Abyssinia',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color.fromARGB(230, 247, 246, 246),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
