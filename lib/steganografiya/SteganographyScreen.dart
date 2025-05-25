import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:securecrypt_mobile_new_bmi/steganografiya/steganography_service.dart';
import 'package:file_selector/file_selector.dart';

class SteganographyScreen extends StatefulWidget {
  const SteganographyScreen({super.key});

  @override
  State<SteganographyScreen> createState() => _SteganographyScreenState();
}

class _SteganographyScreenState extends State<SteganographyScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _status;
  Uint8List? _previewBytes;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  Future<void> _pickImageAndHideText() async {
    final file = await openFile(
      acceptedTypeGroups: [XTypeGroup(label: 'Images', extensions: ['png', 'jpg', 'jpeg'])],
    );

    if (file == null || _textController.text.isEmpty) {
      setState(() => _status = "Rasm tanlang va matn kiriting!");
      return;
    }

    try {
      final imageBytes = await file.readAsBytes();
      final result = SteganographyService.hideTextInImage(imageBytes, _textController.text);

      setState(() {
        _previewBytes = result;
        _status = "✅ Matn muvaffaqiyatli yashirildi!";
      });
    } catch (e) {
      setState(() => _status = "❌ Xatolik: ${e.toString()}");
    }
  }

  Future<void> _pickImageAndExtractText() async {
    final file = await openFile(
      acceptedTypeGroups: [XTypeGroup(label: 'Images', extensions: ['png', 'jpg', 'jpeg'])],
    );

    if (file == null) return;

    try {
      final imageBytes = await file.readAsBytes();
      final message = SteganographyService.extractTextFromImage(imageBytes);

      setState(() {
        _textController.text = message;
        _status = "✅ Matn muvaffaqiyatli ajratildi!";
      });
    } catch (e) {
      setState(() => _status = "❌ Xatolik: ${e.toString()}");
    }
  }

  Future<void> _saveImageToDownloads() async {
    if (_previewBytes == null) return;

    final manageStatus = await Permission.manageExternalStorage.request();
    if (!manageStatus.isGranted) {
      setState(() => _status = "❌ Saqlash uchun ruxsat berilmadi. Sozlamalardan ruxsat bering.");
      return;
    }

    final downloadsDir = Directory('/storage/emulated/0/Download');
    if (!downloadsDir.existsSync()) {
      setState(() => _status = "❌ Download katalogi mavjud emas.");
      return;
    }

    final fileName = 'stego_image_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = '${downloadsDir.path}/$fileName';

    try {
      final file = File(filePath);
      await file.writeAsBytes(_previewBytes!);
      setState(() => _status = "✅ Rasm avtomatik saqlandi: $filePath");
    } catch (e) {
      setState(() => _status = "❌ Saqlashda xatolik: ${e.toString()}");
    }
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1e1e1e),
      foregroundColor: const Color(0xFF00FFAB),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF00FFAB), width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f0f),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00FFAB)),
        title: const Text('🖼 Steganografiya', style: TextStyle(color: Color(0xFF00FFAB))),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                labelText: "Yashiriladigan yoki chiqariladigan matn",
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white54),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF00FFAB), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_status != null)
              Text(
                _status!,
                style: TextStyle(
                  color: _status!.startsWith("✅") ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImageAndHideText,
                    icon: const Icon(Icons.lock, size: 24),
                    label: const Text("Matnni yashirish", style: TextStyle(fontSize: 14)),
                    style: _buttonStyle(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImageAndExtractText,
                    icon: const Icon(Icons.visibility, size: 24),
                    label: const Text("Matnni ajratish", style: TextStyle(fontSize: 14)),
                    style: _buttonStyle(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_previewBytes != null) ...[
              Expanded(child: Image.memory(_previewBytes!)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _saveImageToDownloads,
                icon: const Icon(Icons.save_alt, size: 24),
                label: const Text(
                  "Rasmni saqlash",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1e1e1e),
                  foregroundColor: const Color(0xFF00FFAB),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  minimumSize: const Size(0, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFF00FFAB), width: 1.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
