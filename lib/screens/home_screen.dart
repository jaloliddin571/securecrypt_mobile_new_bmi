import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:securecrypt_mobile_new_bmi/screens/FileDecryptionScreen.dart';
import 'package:securecrypt_mobile_new_bmi/screens/profile_screen.dart';
import 'package:securecrypt_mobile_new_bmi/screens/scan_qr_screen.dart';
import 'package:securecrypt_mobile_new_bmi/screens/settings_screen.dart';
import '../steganografiya/SteganographyScreen.dart';
import 'AboutScreen.dart';
import 'AppDrawer.dart';
import 'FileEncryptionScreen.dart';
import 'StatisticsScreen.dart';
import 'encrypt_screen.dart';
import 'decrypt_screen.dart';
import '../services/user_profile.dart';
import '../services/user_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile _userProfile = UserProfile(
    name: 'Foydalanuvchi',
    email: 'email@misol.com',
    phone: '',
    address: '',
  );

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final profile = await UserStorage.loadUser();
    if (profile != null) {
      setState(() {
        _userProfile = profile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(user: _userProfile),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '🔐 SecureCrypt',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0f0f), Color(0xFF1a1a1a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _HomeButton(icon: Icons.lock, label: 'Matnni\nShifrlash', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EncryptScreen()))),
            _HomeButton(icon: Icons.lock_open, label: 'Matnni\nDeshifrlash', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DecryptScreen()))),
            _HomeButton(icon: Icons.file_upload_outlined, label: 'Faylni\nShifrlash', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FileEncryptScreen()))),
            _HomeButton(icon: Icons.file_download_outlined, label: 'Faylni\nDeshifrlash', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FileDecryptScreen()))),
            _HomeButton(icon: Icons.image_search, label: 'Steganografiya', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SteganographyScreen()))),
            _HomeButton(icon: Icons.qr_code_2, label: 'QR Kod\nSkaner', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanQrScreen()))),
            _HomeButton(icon: Icons.person_outline, label: 'Profil\nMaʼlumot', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
            _HomeButton(icon: Icons.info_outline, label: 'Ilova\nHaqida', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
            _HomeButton(icon: Icons.settings, label: 'Sozlamalar', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()))),
            _HomeButton(icon: Icons.bar_chart, label: 'Statistika', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()))),
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<_HomeButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact(); // ✅ Tugma bosilganda vibratsiya
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1e1e1e), Color(0xFF2e2e2e)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF00FFAB), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                offset: const Offset(3, 6),
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 42, color: const Color(0xFF00FFAB)),
                const SizedBox(height: 12),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00FFAB),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
