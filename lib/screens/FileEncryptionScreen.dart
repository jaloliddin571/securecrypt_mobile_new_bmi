import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../services/stats_service.dart';  // 📊 Statistika servisi

class FileEncryptScreen extends StatefulWidget {
  const FileEncryptScreen({super.key});

  @override
  State<FileEncryptScreen> createState() => _FileEncryptScreenState();
}

class _FileEncryptScreenState extends State<FileEncryptScreen> {
  final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  String? _status;
  String? _fileName;
  String? _savedPath;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  Future<void> _pickAndEncryptFile() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(label: 'Media Files', extensions: ['pdf', 'docx', 'jpg', 'png', 'mp4', 'mp3'])
        ],
      );

      if (file == null) {
        setState(() {
          _status = '❗ Fayl tanlanmadi.';
          _fileName = null;
        });
        return;
      }

      final fileBytes = await file.readAsBytes();
      final fileName = path.basename(file.path);
      final extension = path.extension(fileName).replaceFirst('.', '');

      final extensionBytes = Uint8List(10);
      final encodedExt = utf8.encode(extension);
      for (int i = 0; i < encodedExt.length && i < 10; i++) {
        extensionBytes[i] = encodedExt[i];
      }

      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
      final encryptedData = iv.bytes + encrypted.bytes + extensionBytes;

      final directory = Directory('/storage/emulated/0/Download');
      final encryptedPath = path.join(directory.path, '$fileName.enc');
      final outFile = File(encryptedPath);
      await outFile.writeAsBytes(encryptedData);

      // 📊 Statistikani oshirish
      await StatsService.increment('file_enc_count');

      setState(() {
        _status = '✅ Fayl saqlandi: $encryptedPath';
        _fileName = fileName;
        _savedPath = encryptedPath;
      });
    } catch (e) {
      setState(() => _status = '❌ Xatolik: $e');
    }
  }

  Future<void> _shareEncryptedFile() async {
    if (_savedPath != null) {
      try {
        await Share.shareXFiles([XFile(_savedPath!)], text: '🔐 Shifrlangan fayl');
      } catch (e) {
        setState(() => _status = '❗ Yuborishda xatolik: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('🛡 Faylni Shifrlash'),
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
              onPressed: _pickAndEncryptFile,
              icon: const Icon(Icons.lock, size: 24),
              label: const Text('Faylni tanlash va shifrlash', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFAB),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 6,
              ),
            ),
            const SizedBox(height: 20),
            if (_fileName != null)
              Card(
                color: const Color(0xFF2E2E2E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
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
                    ],
                  ),
                ),
              ),
            if (_savedPath != null)
              ElevatedButton.icon(
                onPressed: _shareEncryptedFile,
                icon: const Icon(Icons.share),
                label: const Text('Ulashish'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent[700],
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      color: Colors.black.withOpacity(0.25),
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
