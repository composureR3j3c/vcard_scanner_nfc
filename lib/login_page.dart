import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLogin});

  final Future<void> Function(String email, String password) onLogin;

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
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
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
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.08),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A0F172A),
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
                                                color: const Color(0xFF111827),
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
                                'Enter your email and password to continue on this phone.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xB8111827),
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _FieldLabel(
                                label: 'Email',
                                child: _DecoratedField(
                                  leading: const Icon(
                                    Icons.mail_outline_rounded,
                                    color: Color(0x8C111827),
                                    size: 20,
                                  ),
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your email',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    validator: (value) {
                                      final email = value?.trim() ?? '';
                                      if (email.isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!email.contains('@')) {
                                        return 'Enter a valid email';
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
                                  leading: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0x8C111827),
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
                                      color: const Color(0x8C111827),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xB8111827),
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
    final children = <Widget?>[
      leading,
      const SizedBox(width: 10),
      Expanded(child: child),
      trailing,
    ].whereType<Widget>().toList();

    return Container(
      decoration: BoxDecoration(
        color: _LoginPageState._fieldFill.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(children: children),
    );
  }
}
