import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:securecrypt_mobile_new_bmi/screens/report_bug.dart';
import 'ChangePinScreen.dart';
import 'SecuritySettingsScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late Map<String, bool> _toggles;

  @override
  void initState() {
    super.initState();
    _toggles = {
      'auto_update': false,
      'biometric_auth': false,
    };
    _loadToggles();
  }

  Future<void> _loadToggles() async {
    final autoUpdate = await _storage.read(key: 'auto_update');
    final biometric = await _storage.read(key: 'biometric_auth');

    setState(() {
      _toggles['auto_update'] = autoUpdate == 'true';
      _toggles['biometric_auth'] = biometric == 'true';
    });
  }

  Future<void> _saveToggle(String key, bool value) async {
    setState(() {
      _toggles[key] = value;
    });

    if (key == 'auto_update') {
      await _storage.write(key: 'auto_update', value: value.toString());
    } else if (key == 'biometric_auth') {
      await _storage.write(key: 'biometric_auth', value: value.toString());
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('logout'.tr()),
        content: Text('logout_confirm'.tr()),
        actions: [
          TextButton(
            child: Text('cancel'.tr()),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text('logout'.tr()),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr()),
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
            Text(
              "general_settings".tr(),
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 10),
            ..._toggles.entries.map((entry) => Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: ListTile(
                title: Text(entry.key.tr(), style: const TextStyle(color: Colors.white, fontSize: 15)),
                trailing: Switch(
                  value: entry.value,
                  activeColor: const Color(0xFF00FFAB),
                  inactiveTrackColor: Colors.grey,
                  onChanged: (val) => _saveToggle(entry.key, val),
                ),
              ),
            )),
            const Divider(color: Colors.white24, height: 32),
            Text(
              "app_settings".tr(),
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 10),
            ...[
              _buildTile(
                Icons.lock,
                'change_password'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePinScreen()),
                  );
                },
              ),
              _buildTile(
                Icons.security,
                'security'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
                  );
                },
              ),
              _buildTile(
                Icons.bug_report,
                'report_bug'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BugReportScreen()),
                  );
                },
              ),
              _buildTile(
                Icons.logout,
                'logout'.tr(),
                onTap: _confirmLogout,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
      IconData icon,
      String title, {
        String? subtitle,
        VoidCallback? onTap,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00FFAB)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(color: Colors.white54))
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
        onTap: onTap,
      ),
    );
  }
}
