import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/profile_model.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileEditView extends StatefulWidget {
  final ProfileModel currentProfile;
  final Function(String, String?) onSave;
  final VoidCallback onCancel;

  const ProfileEditView({
    super.key,
    required this.currentProfile,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  late TextEditingController _nameController;
  String? _tempImagePath;

  @override
  void initState() {
    super.initState();
    
    String initialNickname = widget.currentProfile.nickname;
    
    // ถ้าชื่อเล่นเป็นค่าเริ่มต้น (นักเดินทาง) ให้ลองดึงชื่อจาก Gmail มาใส่ให้แทน
    if (initialNickname == 'นักเดินทาง') {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.displayName != null && user!.displayName!.isNotEmpty) {
        initialNickname = user.displayName!;
      }
    }

    _nameController = TextEditingController(text: initialNickname);
    _tempImagePath = widget.currentProfile.profileImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final vm = context.read<ProfileViewModel>();
    final path = await vm.pickImage(source);
    if (path != null) {
      setState(() => _tempImagePath = path);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('เลือกจากคลังภาพ'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('ถ่ายรูปใหม่'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // แก้ไขรูป
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _tempImagePath != null
                      ? FileImage(File(_tempImagePath!))
                      : null,
                  child: _tempImagePath == null
                      ? Icon(Icons.person, size: 80, color: Colors.grey.shade400)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: FloatingActionButton.small(
                    onPressed: _showImageSourceDialog,
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          // ช่องกรอกชื่อ
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "ชื่อเล่น",
              hintText: "กรอกชื่อเล่นของคุณ",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.face),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // ปุ่มบันทึก/ยกเลิก
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("ยกเลิก"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณากรอกชื่อเล่น')),
                      );
                      return;
                    }
                    widget.onSave(_nameController.text, _tempImagePath);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("บันทึก"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
