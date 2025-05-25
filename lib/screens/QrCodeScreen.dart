// QrCodeScreen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeScreen extends StatelessWidget {
  final String encryptedText;
  final String publicKey;

  const QrCodeScreen({super.key, required this.encryptedText, required this.publicKey});

  @override
  Widget build(BuildContext context) {
    // JSON ko'rinishida QRga beramiz
    final String combinedData = jsonEncode({
      'encrypted': encryptedText,
      'publicKey': publicKey,
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 RSA QR KOD'),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '📦 QRga kodlangan JSON maʼlumot:',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            SelectableText(
              combinedData,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 24),
            QrImageView(
              data: combinedData,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: combinedData));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📋 QR maʼlumot nusxalandi!')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('QR JSON ni nusxalash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade700,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
