import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onLogin,
    required this.onToggleTheme,
  });

  final Future<void> Function(String username, String password) onLogin;
  final VoidCallback onToggleTheme;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _backgroundTop = Color(0xFFFCFAF4);
  static const _backgroundBottom = Color(0xFFF2EEE5);
  static const _cardGreenDeep = Color(0xFF0F5A43);
  static const _cardGold = Color(0xFFD8A328);
  static const _cardGoldBright = Color(0xFFF1B11F);
  static const _cardRed = Color(0xFFB94A39);
  static const _fieldFill = Color(0xFFF8F7F2);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      await widget.onLogin(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _safeLoginErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _safeLoginErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    const allowedMessages = {
      'Password must be at least 6 characters',
      'Login failed. Please check your network connection and try again.',
      'Login failed. Please check your credentials and try again.',
      'Login failed. Please try again.',
    };
    if (allowedMessages.contains(message)) {
      return message;
    }

    return 'Login failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundTop = isDark ? const Color(0xFF0B0F14) : _backgroundTop;
    final backgroundBottom = isDark
        ? const Color(0xFF121922)
        : _backgroundBottom;
    final panelColor = isDark
        ? const Color(0xE6111827)
        : Colors.white.withValues(alpha: 0.9);
    final bodyTextColor = isDark
        ? const Color(0xFFE5E7EB)
        : const Color(0xB8111827);
    final headingColor = isDark
        ? const Color(0xFFF9FAFB)
        : const Color(0xFF111827);
    final fieldIconColor = isDark
        ? const Color(0xB3F3F4F6)
        : const Color(0x8C111827);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
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
              right: 12,
              top: 12,
              child: SafeArea(
                child: IconButton(
                  tooltip: isDark
                      ? 'Switch to light theme'
                      : 'Switch to dark theme',
                  onPressed: widget.onToggleTheme,
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -120,
              left: -40,
              right: -40,
              child: IgnorePointer(
                child: Container(
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _cardGold.withValues(alpha: 0.18),
                        _cardGold.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 28, 20, 24 + bottomInset),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      decoration: BoxDecoration(
                        color: panelColor,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0x59000000)
                                : const Color(0x1A0F172A),
                            blurRadius: 70,
                            offset: Offset(0, 24),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _cardGold.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Image.asset(
                                      'asset/logo.png',
                                      width: 34,
                                      height: 34,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sign in',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: _cardGreenDeep,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 3.6,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Welcome back',
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                color: headingColor,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Enter your work email or username and password to continue on this phone.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: bodyTextColor,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _FieldLabel(
                                label: 'Email or Username',
                                child: _DecoratedField(
                                  leading: Icon(
                                    Icons.mail_outline_rounded,
                                    color: fieldIconColor,
                                    size: 20,
                                  ),
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your Email or Username',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFF9FAFB)
                                          : const Color(0xFF111827),
                                    ),
                                    validator: (value) {
                                      final identifier = value?.trim() ?? '';
                                      if (identifier.isEmpty) {
                                        return 'Email or username is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _FieldLabel(
                                label: 'Password',
                                child: _DecoratedField(
                                  leading: Icon(
                                    Icons.lock_outline_rounded,
                                    color: fieldIconColor,
                                    size: 20,
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    splashRadius: 20,
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: fieldIconColor,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your password',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFF9FAFB)
                                          : const Color(0xFF111827),
                                    ),
                                    validator: (value) {
                                      if ((value ?? '').isEmpty) {
                                        return 'Password is required';
                                      }
                                      if ((value ?? '').length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              if (_errorMessage case final errorMessage?) ...[
                                const SizedBox(height: 18),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _cardRed.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: _cardRed.withValues(alpha: 0.18),
                                    ),
                                  ),
                                  child: Text(
                                    errorMessage,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _cardRed,
                                      fontWeight: FontWeight.w600,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 22),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: const LinearGradient(
                                    colors: [_cardGold, _cardGoldBright],
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x47D8A328),
                                      blurRadius: 30,
                                      offset: Offset(0, 16),
                                    ),
                                  ],
                                ),
                                child: FilledButton(
                                  onPressed: _isSubmitting ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    foregroundColor: _cardGreenDeep,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  _cardGreenDeep,
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          'Sign in',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? const Color(0xCCF3F4F6) : const Color(0xB8111827),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DecoratedField extends StatelessWidget {
  const _DecoratedField({
    required this.leading,
    required this.child,
    this.trailing,
  });

  final Widget leading;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final children = <Widget?>[
      leading,
      const SizedBox(width: 10),
      Expanded(child: child),
      trailing,
    ].whereType<Widget>().toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xCC1F2937)
            : _LoginPageState._fieldFill.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(children: children),
    );
  }
}
