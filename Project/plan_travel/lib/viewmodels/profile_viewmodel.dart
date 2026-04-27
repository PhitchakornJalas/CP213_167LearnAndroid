import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';
import '../services/firebase_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService;
  ProfileModel? _profile;
  StreamSubscription? _profileSubscription;
  final ImagePicker _picker = ImagePicker();

  ProfileModel? get profile => _profile;

  ProfileViewModel(this._firebaseService) {
    _listenToProfile();
  }

  // ฟังข้อมูลโปรไฟล์แบบ Real-time จาก Firestore
  void _listenToProfile() {
    _profileSubscription?.cancel();
    _profileSubscription = _firebaseService.profileStream.listen((profile) {
      _profile = profile;
      notifyListeners();
    });
  }

  // บันทึกข้อมูลลง Firestore
  Future<void> saveProfile({
    required String nickname,
    String? photoUrl,
    String? accountName,
    String? promptPay,
  }) async {
    final updatedProfile = ProfileModel(
      nickname: nickname,
      photoUrl: photoUrl ?? _profile?.photoUrl,
      accountName: accountName ?? _profile?.accountName,
      promptPay: promptPay ?? _profile?.promptPay,
      email: _profile?.email,
    );
    
    await _firebaseService.saveUserProfile(updatedProfile);
  }

  // ฟังก์ชันเลือกรูปภาพ
  Future<String?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );
    return image?.path;
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
