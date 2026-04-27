import 'dart:io';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';

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
                    backgroundImage: _buildImageProvider(profile.photoUrl),
                    child: profile.photoUrl == null
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
          _buildInfoCard("ชื่อเล่น", profile.nickname),
          const SizedBox(height: 16),
          // _buildInfoCard("อีเมล", profile.email ?? "ไม่ได้ระบุ"),
          
          const SizedBox(height: 40),
          const Text(
            "ข้อมูลนี้ซิงค์กับระบบ Cloud เรียบร้อยแล้ว",
            style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  ImageProvider? _buildImageProvider(String? path) {
    if (path == null) return null;
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
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
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
