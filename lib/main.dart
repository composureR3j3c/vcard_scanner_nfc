import 'package:flutter/material.dart';
import 'digital_card_page.dart';
import 'login_page.dart';
import 'session_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SessionStore _sessionStore = SessionStore();
  bool? _isLoggedIn;
  String? _sessionEmail;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final isLoggedIn = await _sessionStore.isLoggedIn();
    final email = await _sessionStore.getEmail();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoggedIn = isLoggedIn;
      _sessionEmail = email;
    });
  }

  Future<void> _login(String email, String password) async {
    if (password.trim().length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    await _sessionStore.saveLogin(email: email);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoggedIn = true;
      _sessionEmail = email;
    });
  }

  Future<void> _logout() async {
    await _sessionStore.clearLogin();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoggedIn = false;
      _sessionEmail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget home;

    if (_isLoggedIn == null) {
      home = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (_isLoggedIn == true) {
      home = DigitalCardPage(
        sessionEmail: _sessionEmail ?? '',
        onLogout: _logout,
      );
    } else {
      home = LoginPage(onLogin: _login);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade700),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF7F7F7),
        ),
      ),
      home: home,
    );
  }
}
