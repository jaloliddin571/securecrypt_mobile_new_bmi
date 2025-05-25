import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/caesar_service.dart';
import '../services/vigenere_service.dart';
import '../services/aes_service.dart';
import '../services/rsa_service.dart';
import '../services/stats_service.dart'; // 📊 Statistika servisini import qildik
import 'package:pointycastle/asymmetric/api.dart';

class DecryptScreen extends StatefulWidget {
  const DecryptScreen({super.key});

  @override
  State<DecryptScreen> createState() => _DecryptScreenState();
}

class _DecryptScreenState extends State<DecryptScreen> {
  final _inputController = TextEditingController();
  final _keyController = TextEditingController();

  String? _selectedAlgorithm;
  String _result = '';

  final List<String> _algorithms = ['Caesar', 'Vigenère', 'AES', 'RSA'];

  void _decrypt() async {
    final text = _inputController.text.trim();
    final key = _keyController.text.trim();

    if (_selectedAlgorithm == null || text.isEmpty) {
      setState(() {
        _result = '❗ Iltimos, matn va algoritmni tanlang.';
      });
      return;
    }

    try {
      String output = '';

      switch (_selectedAlgorithm) {
        case 'Caesar':
          if (key.isEmpty || int.tryParse(key) == null) {
            output = '❗ Caesar uchun raqamli kalit kiriting.';
          } else {
            final shift = int.parse(key);
            output = CaesarCipher.decrypt(text, shift);
            await StatsService.increment('caesar_count');// 📊 Statistikani yozish
          }
          break;

        case 'Vigenère':
          if (key.isEmpty) {
            output = '❗ Vigenère uchun matnli kalit kiriting.';
          } else {
            output = VigenereCipher.decrypt(text, key);
            await StatsService.increment('vigenere_count');

          }
          break;

        case 'AES':
          if (key.isEmpty) {
            output = '❗ AES uchun matnli kalit kiriting.';
          } else {
            output = AESCipher.decrypt(text, key);
            await StatsService.increment('aes_count');
          }
          break;

        case 'RSA':
          if (key.isEmpty) {
            output = '❗ RSA uchun private key (PEM formatda) kiriting.';
          } else {
            final privateKey = RSAService.parsePrivateKeyFromPem(key);
            output = RSAService.decrypt(text, privateKey);
            await StatsService.increment('rsa_count');
          }
          break;

        default:
          output = '🔒 Bu algoritm hali qo‘llab-quvvatlanmaydi';
      }

      setState(() {
        _result = output;
      });
    } catch (e) {
      setState(() {
        _result = '⚠️ Xatolik: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '🔓 Matnni Deshifrlash',
          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00FFAB), Color(0xFF14FFEC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1F1F1F), Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCard(
                child: TextField(
                  controller: _inputController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('📄 Shifrlangan matn'),
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: DropdownButtonFormField<String>(
                  value: _selectedAlgorithm,
                  dropdownColor: const Color(0xFF2E2E2E),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.tealAccent),
                  decoration: InputDecoration(
                    labelText: '📌 Deshifrlash algoritmi',
                    labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.tealAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2E2E2E),
                  ),
                  items: _algorithms.map((algo) {
                    IconData icon;
                    switch (algo) {
                      case 'Caesar':
                        icon = Icons.looks_one;
                        break;
                      case 'Vigenère':
                        icon = Icons.vpn_key;
                        break;
                      case 'AES':
                        icon = Icons.shield;
                        break;
                      case 'RSA':
                      default:
                        icon = Icons.lock_outline;
                    }
                    return DropdownMenuItem(
                      value: algo,
                      child: Row(
                        children: [
                          Icon(icon, color: Colors.tealAccent),
                          const SizedBox(width: 10),
                          Text(algo),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAlgorithm = value;
                    });
                  },
                ),
              ),
              if (_selectedAlgorithm != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildCard(
                    child: TextField(
                      controller: _keyController,
                      maxLines: _selectedAlgorithm == 'RSA' ? 8 : 1,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputStyle(
                        _selectedAlgorithm == 'RSA'
                            ? '🔑 RSA Private Key (PEM formatda)'
                            : '🗝 Kalit (key)',
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _decrypt,
                  icon: const Icon(Icons.lock_open, color: Colors.black),
                  label: const Text(
                    'Deshifrlash',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF00FFAB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_result.isNotEmpty)
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✅ Deshifrlangan matn:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _result,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF00FFAB)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
      border: InputBorder.none,
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      shadowColor: Colors.tealAccent.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: child,
      ),
    );
  }
}
