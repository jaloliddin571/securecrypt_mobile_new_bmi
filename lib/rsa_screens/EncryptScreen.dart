import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/rsa_service.dart';

class EncryptScreenRSA extends StatefulWidget {
  const EncryptScreenRSA({super.key});

  @override
  State<EncryptScreenRSA> createState() => _EncryptScreenRSAState();
}

class _EncryptScreenRSAState extends State<EncryptScreenRSA> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _publicKeyController = TextEditingController();

  String _encryptedText = '';
  final GlobalKey _qrKey = GlobalKey();

  void _encryptText() {
    try {
      String plainText = _textController.text.trim();
      String publicKeyPem = _publicKeyController.text.trim();

      if (plainText.isEmpty || publicKeyPem.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('fill_text_and_public_key'))), // ❗ Matn va public keyni to‘ldiring
        );
        return;
      }

      RSAPublicKey publicKey = RSAService.decodePublicKey(publicKeyPem);
      String encrypted = RSAService.encrypt(plainText, publicKey);

      setState(() {
        _encryptedText = encrypted;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('error')}: ${e.toString()}')), // ⚠️ Xatolik:
      );
    }
  }

  void _copyEncryptedText() {
    if (_encryptedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _encryptedText));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('encrypted_text_copied'))), // ✅ Shifrlangan matn nusxalandi
      );
    }
  }

  Future<void> _saveAndShareQR() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/rsa_encrypted_qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await Share.shareFiles([file.path], text: tr('rsa_encrypted_qr_share_text')); // 📤 RSA Shifrlangan Matn QR kodi
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('qr_save_error')}: $e')), // ❌ QR kod saqlashda xatolik:
      );
    }
  }

  void _showQRDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tr('encrypted_text_qr_title'), style: const TextStyle(color: Colors.white)), // 📤 Shifrlangan Matn QR kodi
        content: SizedBox(
          width: 300,
          height: 300,
          child: Center(
            child: RepaintBoundary(
              key: _qrKey,
              child: QrImageView(
                data: _encryptedText,
                version: QrVersions.auto,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _saveAndShareQR();
            },
            icon: const Icon(Icons.share, color: Colors.tealAccent),
            label: Text(tr('share_save_button')), // Ulashish / Saqlash
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('close_button'), style: const TextStyle(color: Colors.tealAccent)), // Yopish
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(tr('rsa_encrypt_title'), style: const TextStyle(color: Colors.black)), // ✉️ RSA Shifrlash
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
                  controller: _textController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle(tr('enter_text_label')), // 🔤 Matn kiriting
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: TextField(
                  controller: _publicKeyController,
                  maxLines: 6,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle(tr('public_key_label')), // 🔑 Public key (PEM formatda)
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _encryptText,
                  icon: const Icon(Icons.lock, color: Colors.black),
                  label: Text(
                    tr('encrypt_button'), // Shifrlash
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

              if (_encryptedText.isNotEmpty)
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('encrypted_text_label'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), // 🔒 Shifrlangan matn:
                      const SizedBox(height: 8),
                      SelectableText(
                        _encryptedText,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF00FFAB)),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _copyEncryptedText,
                          icon: const Icon(Icons.copy, color: Colors.white),
                          label: Text(tr('copy_button')), // Nusxalash
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showQRDialog,
                          icon: const Icon(Icons.qr_code),
                          label: Text(tr('show_share_qr_button')), // QR kodi ko‘rsatish / ulashish
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14FFEC),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
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
