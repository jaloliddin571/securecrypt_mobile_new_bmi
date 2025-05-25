// pin_code_screen.dart
import 'package:flutter/material.dart';
import 'MainScreen.dart';

class PinCodeScreen extends StatefulWidget {
  const PinCodeScreen({super.key});

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final _pinController = TextEditingController();
  final String _correctPin = '1234'; // 🔐 Buni keyin local storage yoki secure storage bilan almashtiring

  void _verifyPin() {
    if (_pinController.text == _correctPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ PIN noto‘g‘ri!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 60, color: Color(0xFF00FFAB)),
              const SizedBox(height: 20),
              const Text(
                "PIN kodni kiriting",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pinController,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyPin,
                child: const Text("Kirish"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFAB),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
