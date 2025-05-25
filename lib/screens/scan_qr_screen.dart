import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../services/rsa_service.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedData = '';
  String decryptedMessage = '';

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      setState(() {
        scannedData = scanData.code ?? '';
      });

      try {
        final parsed = jsonDecode(scannedData);
        final encryptedText = parsed['encrypted'];
        final publicKeyPem = parsed['publicKey'];

        setState(() {
          decryptedMessage = '📥 JSON qabul qilindi! (Deshifrlash uchun RSA private key kerak)';
        });

        // Bu yerda siz deshifrlashni amalga oshirishingiz mumkin,
        // masalan RSAService.decrypt() bilan.

      } catch (e) {
        setState(() {
          decryptedMessage = '❗ JSON formatni o‘qib bo‘lmadi: $e';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kodni Skannerlash'),
        backgroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.greenAccent,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📥 Skannerlangan maʼlumot:',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  SelectableText(
                    scannedData,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  if (decryptedMessage.isNotEmpty)
                    Text(
                      decryptedMessage,
                      style: const TextStyle(color: Colors.greenAccent),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: scannedData));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('📋 Nusxalandi!')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Kopiyalash'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
