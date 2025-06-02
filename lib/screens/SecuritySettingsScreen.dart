import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _auth = LocalAuthentication();

  bool _requireBiometric = false;
  bool _showPinResetOption = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricSetting();
  }

  Future<void> _loadBiometricSetting() async {
    final storedValue = await _storage.read(key: 'biometric_auth');
    setState(() {
      _requireBiometric = storedValue == 'true';
    });
  }

  Future<void> _updateBiometricSetting(bool value) async {
    setState(() => _requireBiometric = value);
    await _storage.write(key: 'biometric_auth', value: value.toString());
  }

  Future<void> _resetPin() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _auth.authenticate(
        localizedReason: tr('biometric_auth_reason'),
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('auth_failed'))),
      );
      return;
    }

    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('pin_reset_denied'))),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr('pin_reset_title')),
        content: Text(tr('pin_reset_question')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('yes')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final newPin = await _showPinInputDialog();
      if (newPin != null && newPin.length == 4) {
        await _storage.write(key: 'user_pin', value: newPin);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('pin_saved'))),
        );
      }
    }
  }

  Future<String?> _showPinInputDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr('new_pin_title')),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: InputDecoration(hintText: tr('new_pin_hint')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(tr('save')),
          ),
        ],
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("security_settings_title")),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00FFAB), Color(0xFF009688)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0f0f), Color(0xFF1a1a1a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: Text(
                tr("require_biometric_auth"),
                style: const TextStyle(color: Colors.white),
              ),
              value: _requireBiometric,
              onChanged: _updateBiometricSetting,
              activeColor: const Color(0xFF00FFAB),
            ),
            const Divider(color: Colors.white24),
            if (_showPinResetOption)
              ListTile(
                leading: const Icon(Icons.refresh, color: Color(0xFF00FFAB)),
                title: Text(
                  tr("reset_pin"),
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  tr("forgot_pin_subtitle"),
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: _resetPin,
              ),
          ],
        ),
      ),
    );
  }
}
