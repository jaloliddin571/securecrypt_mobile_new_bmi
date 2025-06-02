import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/asymmetric/api.dart';
import '../services/rsa_service.dart';
import 'package:easy_localization/easy_localization.dart';

class DecryptScreenRSA extends StatefulWidget {
  const DecryptScreenRSA({super.key});

  @override
  State<DecryptScreenRSA> createState() => _DecryptScreenRSAState();
}

class _DecryptScreenRSAState extends State<DecryptScreenRSA> {
  final TextEditingController _cipherTextController = TextEditingController();
  final TextEditingController _privateKeyController = TextEditingController();

  String _decryptedText = '';

  void _decryptText() {
    try {
      String cipherText = _cipherTextController.text.trim();
      String privateKeyPem = _privateKeyController.text.trim();

      if (cipherText.isEmpty || privateKeyPem.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('fill_encrypted_text_and_private_key'))), // ❗ Shifrlangan matn va private keyni to‘ldiring
        );
        return;
      }

      RSAPrivateKey privateKey = RSAService.decodePrivateKey(privateKeyPem);
      String decrypted = RSAService.decrypt(cipherText, privateKey);

      setState(() {
        _decryptedText = decrypted;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('error')}: ${e.toString()}')), // ⚠️ Xatolik:
      );
    }
  }

  void _copyDecryptedText() {
    if (_decryptedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _decryptedText));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('decrypted_text_copied'))), // 📋 Ochilgan matn nusxalandi
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(tr('rsa_decrypt_title'), style: const TextStyle(color: Colors.black)), // 🔓 RSA Deshifrlash
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
                  controller: _cipherTextController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle(tr('encrypted_text_label')), // 🔒 Shifrlangan matn (Base64)
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: TextField(
                  controller: _privateKeyController,
                  maxLines: 6,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle(tr('private_key_label')), // 🔑 Private key (PEM formatda)
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _decryptText,
                  icon: const Icon(Icons.lock_open, color: Colors.black),
                  label: Text(
                    tr('decrypt_button'), // Ochish
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
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
              if (_decryptedText.isNotEmpty)
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('decrypted_text_label'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), // 📄 Ochilgan matn:
                      const SizedBox(height: 8),
                      SelectableText(
                        _decryptedText,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF00FFAB)),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _copyDecryptedText,
                          icon: const Icon(Icons.copy, color: Colors.white),
                          label: Text(tr('copy')), // Nusxalash
                        ),
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
