import 'dart:io';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileInfoView extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onEdit;

  const ProfileInfoView({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // รูปโปรไฟล์
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.withOpacity(0.2), width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: profile.profileImagePath != null
                        ? FileImage(File(profile.profileImagePath!))
                        : null,
                    child: profile.profileImagePath == null
                        ? Icon(Icons.person, size: 80, color: Colors.grey.shade400)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: FloatingActionButton.small(
                    onPressed: onEdit,
                    child: const Icon(Icons.edit),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          // ข้อมูลชื่อเล่น
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ชื่อเล่น",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    String displayName = profile.nickname;
                    // ถ้ายังเป็นค่าเริ่มต้น ให้ลองดึงจาก Firebase
                    if (displayName == 'นักเดินทาง') {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user?.displayName != null && user!.displayName!.isNotEmpty) {
                        displayName = user.displayName!;
                      }
                    }
                    return Text(
                      displayName.isEmpty ? "ยังไม่ได้ตั้งชื่อ" : displayName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          const Text(
            "ข้อมูลนี้จะถูกแสดงในหน้าตั้งค่าและกิจกรรมของคุณ",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
