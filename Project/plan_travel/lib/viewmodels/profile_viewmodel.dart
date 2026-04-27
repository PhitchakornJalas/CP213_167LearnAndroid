import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileModel? _profile;
  final ImagePicker _picker = ImagePicker();

  ProfileModel? get profile => _profile;

  ProfileViewModel() {
    loadProfile();
  }

  // โหลดข้อมูลจาก SharedPreferences
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('user_profile');
    
    if (profileJson != null) {
      _profile = ProfileModel.fromMap(jsonDecode(profileJson));
    } else {
      // ค่าเริ่มต้นถ้ายังไม่มีข้อมูล
      _profile = ProfileModel(nickname: 'นักเดินทาง');
    }
    notifyListeners();
  }

  // บันทึกข้อมูล
  Future<void> saveProfile(String nickname, String? imagePath) async {
    _profile = ProfileModel(nickname: nickname, profileImagePath: imagePath);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(_profile!.toMap()));
    
    notifyListeners();
  }

  // ฟังก์ชันเลือกรูปภาพ
  Future<String?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 50, // ลดขนาดไฟล์เพื่อประหยัดพื้นที่
    );
    return image?.path;
  }
}
