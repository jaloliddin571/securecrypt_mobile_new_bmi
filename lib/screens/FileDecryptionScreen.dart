import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- Clipboard uchun
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';

class FileDecryptScreen extends StatefulWidget {
  const FileDecryptScreen({super.key});

  @override
  State<FileDecryptScreen> createState() => _FileDecryptScreenState();
}

class _FileDecryptScreenState extends State<FileDecryptScreen> {
  String? _status;
  String? _fileName;
  String? _savedPath;
  String _userKey = '';
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  Uint8List _generateKey(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }

  Future<void> _pickAndDecryptFile() async {
    try {
      if (_userKey.isEmpty || _userKey.length < 4) {
        setState(() => _status = 'error_key_length'.tr());
        return;
      }

      final file = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(label: 'Encrypted files', extensions: ['enc']),
        ],
      );

      if (file == null) {
        setState(() {
          _status = 'error_no_file'.tr();
          _fileName = null;
        });
        return;
      }

      final fileBytes = await file.readAsBytes();
      final keyBytes = _generateKey(_userKey);

      final iv = encrypt.IV(fileBytes.sublist(0, 16));
      final encryptedContent = fileBytes.sublist(16, fileBytes.length - 10 - 32);
      final extensionBytes = fileBytes.sublist(fileBytes.length - 42, fileBytes.length - 32);
      final originalExtension = utf8.decode(extensionBytes.where((e) => e != 0).toList());

      final keyHash = fileBytes.sublist(fileBytes.length - 32);
      final providedKeyHash = sha256.convert(keyBytes).bytes;

      if (!const ListEquality().equals(keyHash, providedKeyHash)) {
        setState(() => _status = 'error_wrong_key'.tr());
        return;
      }

      final key = encrypt.Key(keyBytes);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decryptBytes(
        encrypt.Encrypted(encryptedContent),
        iv: iv,
      );

      final decryptedFileName = path.basenameWithoutExtension(file.name);
      final directory = Directory('/storage/emulated/0/Download');
      final decryptedPath = path.join(directory.path, '$decryptedFileName.$originalExtension');
      final outFile = File(decryptedPath);
      await outFile.writeAsBytes(decrypted);

      setState(() {
        _status = 'success_decrypted'.tr(args: [decryptedPath]);
        _fileName = '$decryptedFileName.$originalExtension';
        _savedPath = decryptedPath;
      });
    } catch (e) {
      setState(() => _status = 'error_decrypt_failed'.tr(args: [e.toString()]));
    }
  }

  Future<void> _shareDecryptedFile() async {
    if (_savedPath != null) {
      try {
        await Share.shareXFiles([XFile(_savedPath!)], text: 'share_decrypted_file_text'.tr());
      } catch (e) {
        setState(() => _status = 'error_share_failed'.tr(args: [e.toString()]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('title_file_decrypt'.tr()),
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
          children: [
            TextField(
              obscureText: _obscureKey,
              onChanged: (val) => _userKey = val,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'hint_enter_key'.tr(),
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureKey ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureKey = !_obscureKey;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickAndDecryptFile,
              icon: const Icon(Icons.lock_open, size: 24),
              label: Text('btn_decrypt_file'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFAB),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                      const Icon(Icons.insert_drive_file, color: Colors.amber),
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
                onPressed: _shareDecryptedFile,
                icon: const Icon(Icons.share),
                label: Text('btn_share'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
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
