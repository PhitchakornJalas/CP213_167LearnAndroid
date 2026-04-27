import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart';
import '../models/daily_detail_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ดึง UID ของผู้ใช้ปัจจุบัน
  String? get uid => _auth.currentUser?.uid;

  // --- ระบบโปรไฟล์ (User Profile) ---

  // บันทึกหรืออัปเดตโปรไฟล์ผู้ใช้
  Future<void> saveUserProfile(ProfileModel profile) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).set(
      profile.toMap(),
      SetOptions(merge: true),
    );
  }

  // ดึงข้อมูลโปรไฟล์แบบ Stream (Real-time)
  Stream<ProfileModel?> get profileStream {
    if (uid == null) return Stream.value(null);
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return ProfileModel.fromMap(snapshot.data()!);
    });
  }

  // เช็คและสร้างโปรไฟล์เริ่มต้น
  Future<void> checkAndCreateInitialProfile(User user) async {
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      final initialProfile = ProfileModel(
        nickname: user.displayName ?? 'นักเดินทาง',
        email: user.email,
        photoUrl: user.photoURL,
      );
      await _db.collection('users').doc(user.uid).set(initialProfile.toMap());
    }
  }

  // --- ระบบกิจกรรม (Events) ---

  // บันทึกหรือแก้ไขกิจกรรม
  Future<void> saveEvent(DailyDetailModel event) async {
    if (uid == null) return;

    final eventCollection = _db.collection('users').doc(uid).collection('events');
    
    if (event.id.isEmpty) {
      // สร้างใหม่
      await eventCollection.add(event.toMap());
    } else {
      // แก้ไข
      await eventCollection.doc(event.id).set(event.toMap(), SetOptions(merge: true));
    }
  }

  // ดึงรายการกิจกรรมแบบ Stream (Real-time)
  Stream<List<DailyDetailModel>> get eventsStream {
    if (uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(uid)
        .collection('events')
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DailyDetailModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // ลบกิจกรรม
  Future<void> deleteEvent(String eventId) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).collection('events').doc(eventId).delete();
  }
}
