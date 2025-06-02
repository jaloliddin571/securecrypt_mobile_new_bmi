import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:securecrypt_mobile_new_bmi/services/biometric_service.dart';
import 'MainScreen.dart';
import 'PinCodeScreen.dart';
import 'CreatePinScreen.dart'; // PIN o‘rnatish sahifasi

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
    _handleAuthFlow();
  }

  Future<void> _handleAuthFlow() async {
    const storage = FlutterSecureStorage();
    final savedPin = await storage.read(key: 'user_pin');

    // Agar PIN o‘rnatilmagan bo‘lsa — yangi PIN o‘rnatish sahifasiga yo‘naltiramiz
    if (savedPin == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CreatePinScreen()),
      );
      return;
    }

    // PIN bor — biometrik autentifikatsiya qilishga urinib ko‘ramiz
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
        MaterialPageRoute(builder: (_) => const PinCodeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF00FFAB)),
      ),
    );
  }
}
