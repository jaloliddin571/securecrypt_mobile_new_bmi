import 'dart:io';
import 'package:flutter/material.dart';
import 'package:securecrypt_mobile_new_bmi/screens/AboutScreen.dart';
import 'package:securecrypt_mobile_new_bmi/screens/settings_screen.dart';
import 'package:securecrypt_mobile_new_bmi/services/user_profile.dart';

class AppDrawer extends StatelessWidget {
  final UserProfile user;

  const AppDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0f0f), Color(0xFF1a1a1a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Profil qismi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00FFAB), Color(0xFF00796B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundImage: user.imagePath != null
                        ? FileImage(File(user.imagePath!))
                        : const AssetImage('assets/images/avatar.png') as ImageProvider,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Menyu ro'yxati
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildTile(
                    context,
                    icon: Icons.language,
                    label: '🌐 Tilni tanlash',
                    onTap: () => _showLanguageSelector(context),
                  ),
                  _buildTile(
                    context,
                    icon: Icons.info_outline,
                    label: 'ℹ️ Ilova haqida',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                  ),
                  _buildTile(
                    context,
                    icon: Icons.settings,
                    label: '⚙️ Sozlamalar',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                    color: Colors.white24,
                    thickness: 0.8,
                    indent: 16,
                    endIndent: 16,
                  ),
                  const SizedBox(height: 8),
                  _buildTile(
                    context,
                    icon: Icons.logout,
                    label: '🚪 Hisobdan chiqish',
                    color: Colors.redAccent,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: const Color(0xFF121212),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.logout, size: 50, color: Colors.redAccent),
                                const SizedBox(height: 20),
                                const Text(
                                  'Hisobdan chiqish',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Rostdan ham hisobdan chiqmoqchimisiz? Ushbu amal sizni ilovadan chiqaradi.',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    height: 1.6,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.grey,
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      ),
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text(
                                        'YO‘Q',
                                        style: TextStyle(fontSize: 14.5),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // alert dialog
                                        Navigator.of(context).pop(); // drawer

                                        // TODO: logout logikasi:
                                        // Navigator.pushReplacementNamed(context, '/login');
                                      },
                                      child: const Text(
                                        'HA',
                                        style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 14, top: 8),
              child: Text(
                '© 2025 SecureCrypt',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Menyu tugmalari uchun tile builder
  Widget _buildTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        Color color = const Color(0xFF00FFB0),
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white10.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
          ],
        ),
      ),
    );
  }

  // ✅ TIL TANLASH funksiyasi
  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Tilni tanlang',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Text("🇺🇿", style: TextStyle(fontSize: 20)),
              title: const Text('O‘zbek tili', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Til o‘zgartirildi: O‘zbek tili")),
                );
              },
            ),
            ListTile(
              leading: const Text("🇬🇧", style: TextStyle(fontSize: 20)),
              title: const Text('English', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Language changed: English")),
                );
              },
            ),
            ListTile(
              leading: const Text("🇷🇺", style: TextStyle(fontSize: 20)),
              title: const Text('Русский', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Язык изменён: Русский")),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
