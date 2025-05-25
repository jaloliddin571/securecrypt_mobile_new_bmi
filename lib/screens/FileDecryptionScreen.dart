import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../services/stats_service.dart'; // 📊 Statistika

class FileDecryptScreen extends StatefulWidget {
  const FileDecryptScreen({super.key});

  @override
  State<FileDecryptScreen> createState() => _FileDecryptScreenState();
}

class _FileDecryptScreenState extends State<FileDecryptScreen> {
  final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  String? _status;
  String? _fileName;
  String? _decryptedPath;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  Future<void> _pickAndDecryptFile() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(label: 'Encrypted Files', extensions: ['enc'])
        ],
      );

      if (file == null) {
        setState(() {
          _status = '❗ Fayl tanlanmadi.';
          _fileName = null;
          _decryptedPath = null;
        });
        return;
      }

      final allBytes = await file.readAsBytes();
      if (allBytes.length < 20) {
        setState(() => _status = '❌ Noto‘g‘ri fayl formati.');
        return;
      }

      final iv = encrypt.IV(allBytes.sublist(0, 16));
      final extensionBytes = allBytes.sublist(allBytes.length - 10);
      final encryptedData = allBytes.sublist(16, allBytes.length - 10);

      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final decryptedBytes = encrypter.decryptBytes(
        encrypt.Encrypted(encryptedData),
        iv: iv,
      );

      final extension = String.fromCharCodes(extensionBytes).replaceAll('\u0000', '').trim();
      final baseName = path.basenameWithoutExtension(file.path);
      final fileName = '$baseName.$extension';

      final directory = Directory('/storage/emulated/0/Download');
      final decryptedPath = path.join(directory.path, fileName);
      final outFile = File(decryptedPath);
      await outFile.writeAsBytes(decryptedBytes);

      // 📊 Statistikani oshirish
      await StatsService.increment('file_dec_count');

      setState(() {
        _status = '✅ Fayl saqlandi: $decryptedPath';
        _fileName = fileName;
        _decryptedPath = decryptedPath;
      });
    } catch (e) {
      setState(() => _status = '❌ Xatolik: $e');
    }
  }

  void _shareDecryptedFile() {
    if (_decryptedPath != null && File(_decryptedPath!).existsSync()) {
      Share.shareXFiles([XFile(_decryptedPath!)], text: '🔓 Deshifrlangan fayl: $_fileName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('🔓 Faylni deshifrlash'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
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
            colors: [Color(0xFF121212), Color(0xFF1F1F1F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _pickAndDecryptFile,
              icon: const Icon(Icons.lock_open),
              label: const Text('Faylni tanlash va deshifrlash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFAB),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 6,
              ),
            ),
            const SizedBox(height: 24),
            if (_fileName != null)
              Card(
                color: const Color(0xFF2E2E2E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file, color: Colors.tealAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _fileName!,
                          style: const TextStyle(color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.tealAccent),
                        onPressed: _shareDecryptedFile,
                        tooltip: 'Ulashish',
                      ),
                    ],
                  ),
                ),
              ),
            if (_status != null) ...[
              const SizedBox(height: 16),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _status!.startsWith('✅') ? Colors.green[600] : Colors.red[700],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(2, 4),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Text(
                  _status!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
