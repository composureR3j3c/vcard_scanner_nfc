import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'employee_profile.dart';
import 'employee_profile_service.dart';
import 'employee_profile_store.dart';
import 'session_user.dart';
import 'utils/vcard_generator.dart';
import 'widgets/employee_id_deck.dart';

class DigitalCardPage extends StatefulWidget {
  const DigitalCardPage({
    super.key,
    required this.sessionUser,
    required this.onLogout,
    required this.onToggleTheme,
  });

  static const _cardGreenDeep = Color(0xFFD8A328);
  static const _cardGold = Color(0xFFD8A328);
  static const _textPrimary = Color(0xFF111827);
  final SessionUser sessionUser;
  final Future<void> Function() onLogout;
  final VoidCallback onToggleTheme;

  @override
  State<DigitalCardPage> createState() => _DigitalCardPageState();
}

class _DigitalCardPageState extends State<DigitalCardPage> {
  final EmployeeProfileService _profileService = EmployeeProfileService();
  final EmployeeProfileStore _profileStore = EmployeeProfileStore();
  late Future<EmployeeProfile> _profileFuture;
  String? _copiedValue;
  bool _isRefreshing = false;
  bool _isUsingOfflineProfile = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<EmployeeProfile> _loadProfile({bool forceRefresh = false}) async {
    try {
      final profile = await _profileService.fetchProfile(
        employeeId: widget.sessionUser.id,
      );
      await _profileStore.saveProfile(profile);

      if (mounted && _isUsingOfflineProfile) {
        setState(() {
          _isUsingOfflineProfile = false;
        });
      } else {
        _isUsingOfflineProfile = false;
      }

      return profile;
    } catch (_) {
      final cachedProfile = await _profileStore.getProfile(
        widget.sessionUser.id,
      );
      if (cachedProfile != null) {
        if (mounted && !_isUsingOfflineProfile) {
          setState(() {
            _isUsingOfflineProfile = true;
          });
        } else {
          _isUsingOfflineProfile = true;
        }
        return cachedProfile;
      }

      rethrow;
    }
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

  Future<void> _refreshProfile() async {
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      final future = _loadProfile(forceRefresh: true);

      if (mounted) {
        setState(() {
          _profileFuture = future;
        });
      } else {
        _profileFuture = future;
      }

      await future;

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isUsingOfflineProfile
                ? 'Offline mode: showing saved card data.'
                : 'Card updated successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to refresh card data: $error')),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundTop = isDark
        ? const Color(0xFF0B0F14)
        : const Color(0xFFFCFAF4);
    final backgroundBottom = isDark
        ? const Color(0xFF121922)
        : const Color(0xFFF2EEE5);
    final textPrimary = isDark
        ? const Color(0xFFF3F4F6)
        : const Color(0xFF111827);

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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employee\nWorkspace',
                    maxLines: 2,
                    style: TextStyle(
                      color: DigitalCardPage._cardGreenDeep,
                      fontSize: 9,
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
                      color: textPrimary,
                      fontSize: 18,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _isRefreshing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : IconButton(
                    tooltip: 'Refresh',
                    onPressed: _refreshProfile,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
          ),
          IconButton(
            tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
            onPressed: widget.onToggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundTop, backgroundBottom],
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
                            Text(
                              'Unable to load employee data.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFF9FAFB)
                                    : const Color(0xFF111827),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xB3F3F4F6)
                                    : const Color(0xA6111827),
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
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
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
                        padding: const EdgeInsets.fromLTRB(10, 14, 10, 18),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 980),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_isUsingOfflineProfile) ...[
                                  const _OfflineNotice(),
                                  const SizedBox(height: 16),
                                ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? const Color(0xFFF3F4F6)
        : const Color(0xA6111827);
    final publicCardUrl =
        'https://businesscard.bankofabyssinia.com/u/${widget.sessionUser.username}';

    final cardPanel = _SurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Card',
            style: TextStyle(
              color: DigitalCardPage._cardGreenDeep,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review both sides of your official identification below.',
            style: TextStyle(color: titleColor, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 18),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: EmployeeIdDeck(profile: profile, qrData: vcard),
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
          _DetailTile(
            label: 'Location',
            value: [
              profile.city,
              profile.country,
            ].where((value) => value.isNotEmpty).join(', '),
          ),
          const SizedBox(height: 12),
          _PublicQrTile(
            url: publicCardUrl,
            copied: _copiedValue == publicCardUrl,
            onCopy: () => _copyToClipboard(publicCardUrl),
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
      children: [topSection],
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xCC3A2F12) : const Color(0xFFF8E8BD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DigitalCardPage._cardGold.withValues(alpha: 0.35),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.offline_bolt_rounded, color: Colors.black87, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Offline mode: showing the last saved card data on this device.',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xCC111827) : const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x40000000) : const Color(0x140F172A),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xCC1F2937) : const Color(0xCCF8F7F2),
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
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xB3F9FAFB)
                          : const Color(0x73111827),
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
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFF9FAFB)
                    : const Color(0xCC111827),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final qrBox = (tileWidth * 0.58).clamp(112.0, 140.0);
        final qrPadding = (qrBox * 0.055).clamp(6.0, 8.0);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xCC111827)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Public QR',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xB3F3F4F6)
                              : const Color(0x73111827),
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
                            : (isDark
                                  ? const Color(0x99E5E7EB)
                                  : const Color(0x66111827)),
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
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.black.withValues(alpha: 0.4),
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
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.58)
                              : Colors.black.withValues(alpha: 0.28),
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
