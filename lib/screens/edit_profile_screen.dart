import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import '../services/user_profile.dart';
import '../services/user_storage.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  final ValueChanged<UserProfile> onSave;

  const EditProfileScreen({
    super.key,
    required this.userProfile,
    required this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _phoneController = TextEditingController(text: widget.userProfile.phone);
    _addressController = TextEditingController(text: widget.userProfile.address);
    _imagePath = widget.userProfile.imagePath;
  }

  Future<void> _pickImage() async {
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(label: 'Images', extensions: ['jpg', 'jpeg', 'png']),
      ],
    );

    if (file != null) {
      setState(() {
        _imagePath = file.path;
      });
    }
  }

  void _saveProfile() async {
    final updatedProfile = UserProfile(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      imagePath: _imagePath,
    );

    await UserStorage.saveUser(updatedProfile); // 👈 doimiy saqlash
    widget.onSave(updatedProfile);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('✏️ Profilni tahrirlash'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFF64DD17)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 30),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                  child: _imagePath == null
                      ? const Icon(Icons.camera_alt, color: Colors.white70)
                      : null,
                  backgroundColor: Colors.white10,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(_nameController, 'Ism', 'Ismingiz'),
              _buildTextField(_emailController, 'Email', 'email@misol.com'),
              _buildTextField(_phoneController, 'Telefon raqam', '+998 90 123 45 67'),
              _buildTextField(_addressController, 'Manzil', 'Toshkent shahri'),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Saqlash'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white10,
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white38),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
