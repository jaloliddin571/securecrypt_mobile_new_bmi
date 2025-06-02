import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- Clipboard uchun
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';

class FileEncryptScreen extends StatefulWidget {
  const FileEncryptScreen({super.key});

  @override
  State<FileEncryptScreen> createState() => _FileEncryptScreenState();
}

class _FileEncryptScreenState extends State<FileEncryptScreen> {
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
    return Uint8List.fromList(digest.bytes); // AES-256 uchun 32 bayt kalit
  }

  Future<void> _pickAndEncryptFile() async {
    try {
      if (_userKey.isEmpty || _userKey.length < 4) {
        setState(() => _status = 'error_key_length'.tr());
        return;
      }

      final file = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(label: 'Files', extensions: ['pdf', 'docx', 'jpg', 'png', 'mp4', 'mp3']),
        ],
      );

      if (file == null) {
        setState(() => _status = 'error_no_file'.tr());
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

      final keyBytes = _generateKey(_userKey);
      final iv = encrypt.IV.fromSecureRandom(16);
      final key = encrypt.Key(keyBytes);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
      final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
      final keyHash = sha256.convert(keyBytes).bytes;

      final encryptedData = Uint8List.fromList(iv.bytes + encrypted.bytes + extensionBytes + keyHash);

      final directory = Directory('/storage/emulated/0/Download');
      final encryptedPath = path.join(directory.path, '$fileName.enc');
      final outFile = File(encryptedPath);
      await outFile.writeAsBytes(encryptedData);

      setState(() {
        _status = 'success_file_saved'.tr(args: [encryptedPath]);
        _fileName = fileName;
        _savedPath = encryptedPath;
      });
    } catch (e) {
      setState(() => _status = 'error_encryption_failed'.tr(args: [e.toString()]));
    }
  }

  Future<void> _shareEncryptedFile() async {
    if (_savedPath != null) {
      try {
        await Share.shareXFiles([XFile(_savedPath!)], text: 'share_encrypted_file_text'.tr());
      } catch (e) {
        setState(() => _status = 'error_share_failed'.tr(args: [e.toString()]));
      }
    }
  }

  Future<void> _copyFilePathToClipboard() async {
    if (_savedPath != null) {
      await Clipboard.setData(ClipboardData(text: _savedPath!));
      setState(() {
        _status = 'clipboard_file_path_copied'.tr();
      });
    }
  }

  Future<void> _copyKeyToClipboard() async {
    if (_userKey.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _userKey));
      setState(() {
        _status = 'clipboard_key_copied'.tr();
      });
    } else {
      setState(() {
        _status = 'error_key_empty'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('title_file_encrypt'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                  onPressed: () => setState(() => _obscureKey = !_obscureKey),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _copyKeyToClipboard,
              icon: const Icon(Icons.vpn_key),
              label: Text('btn_copy_key'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickAndEncryptFile,
              icon: const Icon(Icons.lock),
              label: Text('btn_encrypt_file'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFAB),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),
            if (_fileName != null)
              Card(
                color: const Color(0xFF2E2E2E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.insert_drive_file, color: Colors.tealAccent),
                  title: Text(
                    _fileName!,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            if (_savedPath != null) ...[
              ElevatedButton.icon(
                onPressed: _shareEncryptedFile,
                icon: const Icon(Icons.share),
                label: Text('btn_share'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent[700],
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _copyFilePathToClipboard,
                icon: const Icon(Icons.copy),
                label: Text('btn_copy_path'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            if (_status != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _status!,
                  style: TextStyle(
                    color: _status!.startsWith('✅') || _status!.startsWith('📋')
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
