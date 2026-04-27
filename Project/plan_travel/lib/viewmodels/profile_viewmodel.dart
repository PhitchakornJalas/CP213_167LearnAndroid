import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart';
import '../services/firebase_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService;
  ProfileModel? _profile;
  StreamSubscription? _profileSubscription;
  StreamSubscription? _authSubscription;

  ProfileViewModel(this._firebaseService) {
    _listenToAuthChanges();
  }

  ProfileModel? get profile => _profile;

  // ติดตามการเปลี่ยนแปลงการ Login/Logout
  void _listenToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // ถ้า Logout ให้ล้างข้อมูลโปรไฟล์ทันที
        _profile = null;
        _profileSubscription?.cancel();
        notifyListeners();
      } else {
        // ถ้า Login ใหม่ให้เริ่มติดตามข้อมูลโปรไฟล์ของ User นั้น
        _listenToProfile();
      }
    });
  }

  void _listenToProfile() {
    _profileSubscription?.cancel();
    _profileSubscription = _firebaseService.profileStream.listen((profile) {
      _profile = profile;
      notifyListeners();
    });
  }

  Future<void> saveProfile({
    required String nickname, 
    String? photoUrl,
    String? accountName,
    String? promptPay,
  }) async {
    if (_profile == null) return;
    
    final updatedProfile = _profile!.copyWith(
      nickname: nickname,
      photoUrl: photoUrl ?? _profile!.photoUrl,
      accountName: accountName ?? _profile!.accountName,
      promptPay: promptPay ?? _profile!.promptPay,
    );
    
    await _firebaseService.saveUserProfile(updatedProfile);
  }

  Future<String?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    return pickedFile?.path;
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
