import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Map<String, bool> _toggles;

  @override
  void initState() {
    super.initState();
    _toggles = {
      'Avto yangilash': true,
      'Biometrik kirish': false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("⚙️ Sozlamalar"),
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
            const Text(
              "🔧 Umumiy sozlamalar",
              style: TextStyle(color: Colors.white70, fontSize: 15),
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
                title: Text(entry.key, style: const TextStyle(color: Colors.white, fontSize: 15)),
                trailing: Switch(
                  value: entry.value,
                  activeColor: const Color(0xFF00FFAB),
                  inactiveTrackColor: Colors.grey,
                  onChanged: (val) {
                    setState(() {
                      _toggles[entry.key] = val;
                    });
                  },
                ),
              ),
            )),
            const Divider(color: Colors.white24, height: 32),
            const Text(
              "📱 Ilova parametrlari",
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 10),
            ...[
              _buildTile(Icons.language, 'Til', 'O‘zbek tili'),
              _buildTile(Icons.lock, 'Parolni o‘zgartirish'),
              _buildTile(Icons.security, 'Xavfsizlik'),
              _buildTile(Icons.bug_report, 'Xatolik haqida xabar berish'),
              _buildTile(Icons.logout, 'Hisobdan chiqish'),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, [String? subtitle]) {
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
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.white54)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
        onTap: () {},
      ),
    );
  }
}
