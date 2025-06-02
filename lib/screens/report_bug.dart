import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:easy_localization/easy_localization.dart';

class BugReportScreen extends StatefulWidget {
  const BugReportScreen({super.key});

  @override
  State<BugReportScreen> createState() => _BugReportScreenState();
}

class _BugReportScreenState extends State<BugReportScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _sendReport() async {
    final messageText = _controller.text.trim();

    if (messageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_enter_message'.tr())),
      );
      return;
    }

    setState(() => _isSending = true);

    const String username = 'j.b.dev.uz@gmail.com';
    const String password = 'nlcj hsuk quvy onel'; // App password

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'SecureCrypt Mobile')
      ..recipients.add(username)
      ..subject = 'bug_report_subject'.tr()
      ..text = messageText;

    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('message_sent_success'.tr())),
      );
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_occurred'.tr(args: [e.toString()]))),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bug_report_title'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00FFAB), Color(0xFF009688)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0f0f), Color(0xFF1a1a1a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'bug_report_instruction'.tr(),
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'bug_report_hint'.tr(),
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.black12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: _isSending
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.send),
              label: Text(_isSending ? "sending".tr() : "send".tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFAB),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _isSending ? null : _sendReport,
            ),
          ],
        ),
      ),
    );
  }
}
