import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'auth_service.dart';
import 'digital_card_page.dart';
import 'login_page.dart';
import 'session_store.dart';
import 'session_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HardwareKeyboard.instance.syncKeyboardState();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final SessionStore _sessionStore = SessionStore();
  final AuthService _authService = AuthService();
  bool? _isLoggedIn;
  SessionUser? _sessionUser;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(HardwareKeyboard.instance.syncKeyboardState());
    }
  }

  Future<void> _loadSession() async {
    final isLoggedIn = await _sessionStore.isLoggedIn();
    final user = await _sessionStore.getUser();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoggedIn = isLoggedIn && user != null;
      _sessionUser = user;
    });
  }

  Future<void> _login(String username, String password) async {
    if (password.trim().length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    final user = await _authService.login(
      username: username.trim(),
      password: password,
    );
    await _sessionStore.saveLogin(user: user);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoggedIn = true;
      _sessionUser = user;
    });
  }

  Future<void> _logout() async {
    await _sessionStore.clearLogin();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoggedIn = false;
      _sessionUser = null;
    });
  }

  Future<void> _updateSessionUser(SessionUser user) async {
    await _sessionStore.saveLogin(user: user);

    if (!mounted) {
      return;
    }

    setState(() {
      _sessionUser = user;
    });
  }

  void _toggleThemeMode() {
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDarkNow = _themeMode == ThemeMode.system
        ? platformBrightness == Brightness.dark
        : _themeMode == ThemeMode.dark;

    setState(() {
      _themeMode = isDarkNow ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget home;

    if (_isLoggedIn == null) {
      home = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (_isLoggedIn == true) {
      home = DigitalCardPage(
        sessionUser: _sessionUser!,
        onSessionUserChanged: _updateSessionUser,
        onLogout: _logout,
        onToggleTheme: _toggleThemeMode,
      );
    } else {
      home = LoginPage(onLogin: _login, onToggleTheme: _toggleThemeMode);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: home,
    );
  }
}
