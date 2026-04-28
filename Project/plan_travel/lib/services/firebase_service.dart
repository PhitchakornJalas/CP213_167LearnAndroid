import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart';
import '../models/daily_detail_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Future<void> saveUserProfile(ProfileModel profile) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).set(
      profile.toMap(),
      SetOptions(merge: true),
    );
  }

  Stream<ProfileModel?> get profileStream {
    if (uid == null) return Stream.value(null);
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return ProfileModel.fromMap(snapshot.data()!);
    });
  }

  Future<void> checkAndCreateInitialProfile(User user) async {
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      final initialProfile = ProfileModel(
        nickname: user.displayName ?? user.email ?? 'นักเดินทาง',
        email: user.email,
        photoUrl: user.photoURL,
      );
      await _db.collection('users').doc(user.uid).set(initialProfile.toMap());
    }
  }

  Future<String> saveEvent(DailyDetailModel event) async {
    if (uid == null) return '';
    final eventCollection = _db.collection('users').doc(uid).collection('events');
    if (event.id.isEmpty) {
      final docRef = await eventCollection.add(event.toMap());
      return docRef.id;
    } else {
      await eventCollection.doc(event.id).set(event.toMap(), SetOptions(merge: true));
      return event.id;
    }
  }

  // แก้เป็นฟังก์ชันตามที่ ViewModel เรียกใช้
  Stream<List<DailyDetailModel>> getEventsStream(String userUid) {
    return _db
        .collection('users')
        .doc(userUid)
        .collection('events')
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DailyDetailModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> deleteEvent(String eventId) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).collection('events').doc(eventId).delete();
  }

  // --- ระบบตรวจสอบสลิปซ้ำ (Global) ---
  
  /// ตรวจสอบว่า Reference ID นี้เคยถูกใช้ไปแล้วหรือยังในระบบทั้งหมด
  Future<bool> isSlipUsed(String referenceId) async {
    final doc = await _db.collection('global_transactions').doc(referenceId).get();
    return doc.exists;
  }

  /// บันทึกการใช้งานสลิปลงในคอลเลกชันกลาง
  Future<void> registerSlip(String referenceId, String userUid) async {
    await _db.collection('global_transactions').doc(referenceId).set({
      'user_uid': userUid,
      'used_at': FieldValue.serverTimestamp(),
      'reference_id': referenceId,
    });
  }
}
