import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../services/rsa_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class KeyScreen extends StatefulWidget {
  const KeyScreen({super.key});

  @override
  State<KeyScreen> createState() => _KeyScreenState();
}

class _KeyScreenState extends State<KeyScreen> {
  String _publicKeyPem = '';
  String _privateKeyPem = '';
  bool _keysGenerated = false;
  final GlobalKey _qrKey = GlobalKey();

  int _selectedKeySize = 2048;
  final List<int> _keySizes = [2048, 3072, 4096];

  Future<void> _generateKeys() async {
    final keyPair = await RSAService.generateKeyPair(bitLength: _selectedKeySize);
    final publicKey = keyPair.publicKey;
    final privateKey = keyPair.privateKey;

    setState(() {
      _publicKeyPem = RSAService.encodePublicKey(publicKey);
      _privateKeyPem = RSAService.encodePrivateKey(privateKey);
      _keysGenerated = true;
    });

    await RSAService.saveKeysToPem(
      publicKeyPem: _publicKeyPem,
      privateKeyPem: _privateKeyPem,
      fileNamePrefix: 'rsa_${DateTime.now().millisecondsSinceEpoch}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('keys_saved_to_pem'))), // ✅ Kalitlar .pem fayllarga saqlandi
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${tr('copied')} $label')), // 📋 ... nusxalandi
    );
  }

  Future<void> _saveAndShareQR() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/rsa_public_qr.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await Share.shareFiles([file.path], text: tr('rsa_public_key_qr_share_text')); // 📤 RSA Public Key QR Code
    } catch (e) {
      print("QR saqlash/ulashishda xatolik: $e");
    }
  }

  void _showQRDialog(String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tr('public_key_qr'), style: const TextStyle(color: Colors.white)), // 📤 Public Key QR
        content: SizedBox(
          width: 300,
          height: 300,
          child: Center(
            child: RepaintBoundary(
              key: _qrKey,
              child: QrImageView(
                data: data,
                version: QrVersions.auto,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveAndShareQR,
            icon: const Icon(Icons.share, color: Colors.tealAccent),
            label: Text(tr('share_save'), style: const TextStyle(color: Colors.tealAccent)), // Ulashish / Saqlash
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('close'), style: const TextStyle(color: Colors.tealAccent)), // Yopish
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('rsa_keys_title')), // 🔐 RSA Kalitlar
        centerTitle: true,
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
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedKeySize,
                decoration: InputDecoration(
                  labelText: tr('key_size_label'), // Kalit o'lchami (bit)
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00FFAB), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.black26,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                items: _keySizes.map((size) {
                  return DropdownMenuItem<int>(
                    value: size,
                    child: Text('$size bit'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedKeySize = val!;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generateKeys,
                  icon: const Icon(Icons.vpn_key, color: Colors.black),
                  label: Text(
                    tr('generate_keys_button'), // Kalitlarni yaratish
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFAB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_keysGenerated) ...[
                _buildKeyCard(
                  title: tr('public_key_label'), // 🔓 Public Key:
                  content: _publicKeyPem,
                  onCopy: () => _copyToClipboard(_publicKeyPem, tr('public_key_label')),
                ),
                const SizedBox(height: 24),
                _buildKeyCard(
                  title: tr('private_key_label'), // 🔒 Private Key:
                  content: _privateKeyPem,
                  onCopy: () => _copyToClipboard(_privateKeyPem, tr('private_key_label')),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_publicKeyPem.isNotEmpty) {
                      _showQRDialog(_publicKeyPem);
                    }
                  },
                  icon: const Icon(Icons.qr_code),
                  label: Text(tr('share_via_qr')), // QR orqali ulashish
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14FFEC),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyCard({
    required String title,
    required String content,
    required VoidCallback onCopy,
  }) {
    return Card(
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      shadowColor: Colors.tealAccent.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            SelectableText(content, style: const TextStyle(fontSize: 12, color: Color(0xFF00FFAB))),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy, color: Colors.white),
                label: Text(tr('copy')), // Nusxalash
              ),
            )
          ],
        ),
      ),
    );
  }
}
