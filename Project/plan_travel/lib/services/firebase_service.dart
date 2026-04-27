import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // ตัวแปรสำหรับเรียกใช้ Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  // ตรวจสอบสถานะ User ปัจจุบัน
  User? get currentUser => _auth.currentUser;

  // ตัวอย่างการเข้าถึง Collection (เตรียมไว้)
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get eventsCollection => _firestore.collection('events');
}
