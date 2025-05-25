import 'package:flutter/material.dart';
import 'package:securecrypt_mobile_new_bmi/services/biometric_service.dart';
import 'MainScreen.dart';
import 'PinCodeScreen.dart'; // 👉 PIN sahifani import qiling

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _authenticating = true;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  void _authenticate() async {
    final biometricService = BiometricService();
    final isAuth = await biometricService.authenticate();

    if (isAuth) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PinCodeScreen()), // 👉 PIN sahifaga o‘tish
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0f0f), Color(0xFF1a1a1a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: _authenticating
              ? const CircularProgressIndicator(color: Color(0xFF00FFAB))
              : const SizedBox(), // bu holda user PIN ekraniga o'tadi
        ),
      ),
    );
  }
}
