import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easy_localization/easy_localization.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  Future<void> _changePin() async {
    final oldPin = _oldPinController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();
    final savedPin = await _storage.read(key: 'user_pin');

    if (oldPin != savedPin) {
      _showMessage(tr("old_pin_incorrect")); // "❌ Eski PIN noto‘g‘ri!"
      return;
    }

    if (newPin.length != 4 || confirmPin.length != 4) {
      _showMessage(tr("pin_length_error")); // "❗ PIN 4 xonali bo‘lishi kerak."
      return;
    }

    if (newPin != confirmPin) {
      _showMessage(tr("pin_mismatch")); // "❗ Yangi PINlar mos kelmayapti."
      return;
    }

    await _storage.write(key: 'user_pin', value: newPin);
    _showMessage(tr("pin_updated_success")); // "✅ PIN muvaffaqiyatli yangilandi!"
    Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f0f),
      appBar: AppBar(
        title: Text(tr("change_pin_title")), // "🔁 Parolni o‘zgartirish"
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildPinField(tr("old_pin_label"), _oldPinController),           // "Eski PIN"
            const SizedBox(height: 20),
            _buildPinField(tr("new_pin_label"), _newPinController),           // "Yangi PIN"
            const SizedBox(height: 20),
            _buildPinField(tr("confirm_new_pin_label"), _confirmPinController), // "Yangi PIN (qayta)"
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _changePin,
              icon: const Icon(Icons.check),
              label: Text(tr("update_button")), // "Yangilash"
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFAB),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      maxLength: 4,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, fontSize: 20),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[850],
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
