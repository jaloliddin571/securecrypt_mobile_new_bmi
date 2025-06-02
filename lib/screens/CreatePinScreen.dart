import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easy_localization/easy_localization.dart';

import 'PinCodeScreen.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final _pinController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    if (pin.length == 4) {
      await _storage.write(key: 'user_pin', value: pin);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PinCodeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('enter_4_digit_pin'))), // "❗ 4 xonali PIN kiriting."
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
              const Icon(Icons.lock_outline, size: 60, color: Color(0xFF00FFAB)),
              const SizedBox(height: 20),
              Text(
                tr('enter_new_pin'), // "Yangi PIN kiriting"
                style: const TextStyle(color: Colors.white, fontSize: 18),
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
                onPressed: _savePin,
                child: Text(tr('save')), // "Saqlash"
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFAB),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
