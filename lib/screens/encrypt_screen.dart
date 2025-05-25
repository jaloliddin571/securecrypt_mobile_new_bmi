import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/asymmetric/api.dart';

import '../services/aes_service.dart';
import '../services/caesar_service.dart';
import '../services/rsa_service.dart';
import '../services/vigenere_service.dart';
import '../services/stats_service.dart'; // 📊 Statistika servisini import qildik

class EncryptScreen extends StatefulWidget {
  const EncryptScreen({super.key});

  @override
  State<EncryptScreen> createState() => _EncryptScreenState();
}

class _EncryptScreenState extends State<EncryptScreen> {
  final _inputController = TextEditingController();
  final _keyController = TextEditingController();

  String? _selectedAlgorithm;
  String _resultText = '';
  String _publicKeyPEM = '';
  String _privateKeyPEM = '';

  final List<String> _algorithms = ['Caesar', 'Vigenère', 'AES', 'RSA'];

  void _encrypt() async {
    final text = _inputController.text.trim();
    final key = _keyController.text.trim();

    if (_selectedAlgorithm == null || text.isEmpty) {
      setState(() {
        _resultText = '❗ Iltimos, matn va algoritmni tanlang.';
        _publicKeyPEM = '';
        _privateKeyPEM = '';
      });
      return;
    }

    try {
      String output = '';
      String publicKey = '';
      String privateKey = '';

      switch (_selectedAlgorithm) {
        case 'Caesar':
          if (key.isEmpty || int.tryParse(key) == null) {
            output = '❗ Caesar uchun raqamli kalit kiriting.';
          } else {
            final shift = int.parse(key);
            output = CaesarCipher.encrypt(text, shift);
            await StatsService.increment('caesar_count'); // 📊
          }
          break;

        case 'Vigenère':
          if (key.isEmpty) {
            output = '❗ Vigenère uchun matnli kalit kiriting.';
          } else {
            output = VigenereCipher.encrypt(text, key);
            await StatsService.increment('vigenere_count'); // 📊
          }
          break;

        case 'AES':
          if (key.isEmpty) {
            output = '❗ AES uchun matnli kalit kiriting.';
          } else {
            output = AESCipher.encrypt(text, key);
            await StatsService.increment('aes_count'); // 📊
          }
          break;

        case 'RSA':
          RSAPublicKey publicKeyObj;
          if (key.isEmpty) {
            final keyPair = await RSAService.generateKeyPair();
            publicKeyObj = keyPair.publicKey;
            publicKey = RSAService.encodePublicKeyToPem(publicKeyObj);
            privateKey = RSAService.encodePrivateKeyToPem(keyPair.privateKey);
            output = RSAService.encrypt(text, publicKeyObj);
          } else {
            publicKeyObj = RSAService.parsePublicKeyFromPem(key);
            final keyPair = await RSAService.generateKeyPair();
            privateKey = RSAService.encodePrivateKeyToPem(keyPair.privateKey);
            publicKey = key;
            output = RSAService.encrypt(text, publicKeyObj);
          }
          await StatsService.increment('rsa_count'); // 📊
          setState(() {
            _publicKeyPEM = publicKey;
            _privateKeyPEM = privateKey;
          });
          break;

        default:
          output = '🔒 Bu algoritm hali qo‘llab-quvvatlanmaydi';
      }

      setState(() {
        _resultText = output;
      });
    } catch (e) {
      setState(() {
        _resultText = '⚠️ Xatolik: ${e.toString()}';
        _publicKeyPEM = '';
        _privateKeyPEM = '';
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ $label nusxalandi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '🔐 Matnni Shifrlash',
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
                  decoration: _inputStyle('💬 Shifrlanadigan matn'),
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
                    labelText: '📌 Shifrlash algoritmi',
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
                  onChanged: (value) => setState(() => _selectedAlgorithm = value),
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
                      decoration: _inputStyle(_selectedAlgorithm == 'RSA'
                          ? '🔑 RSA Public Key (PEM formatda)'
                          : '🗝 Kalit (key)'),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _encrypt,
                  icon: const Icon(Icons.lock, color: Colors.black),
                  label: const Text(
                    'Shifrlash',
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
              if (_resultText.isNotEmpty)
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📄 Shifrlangan matn:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SelectableText(_resultText,
                          style: const TextStyle(fontSize: 16, color: Color(0xFF00FFAB))),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _copyToClipboard(_resultText, 'Shifrlangan matn'),
                          icon: const Icon(Icons.copy, color: Colors.white),
                          label: const Text('Kopiyalash', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      if (_publicKeyPEM.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🔓 RSA Public Key:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
                            const SizedBox(height: 6),
                            SelectableText(_publicKeyPEM,
                                style: const TextStyle(fontSize: 14, color: Colors.white70)),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _copyToClipboard(_publicKeyPEM, 'RSA Public Key'),
                                icon: const Icon(Icons.copy, color: Colors.white),
                                label: const Text('Kopiyalash', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      if (_privateKeyPEM.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🔐 RSA Private Key:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                            const SizedBox(height: 6),
                            SelectableText(_privateKeyPEM,
                                style: const TextStyle(fontSize: 14, color: Colors.white70)),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _copyToClipboard(_privateKeyPEM, 'RSA Private Key'),
                                icon: const Icon(Icons.copy, color: Colors.white),
                                label: const Text('Kopiyalash', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
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
