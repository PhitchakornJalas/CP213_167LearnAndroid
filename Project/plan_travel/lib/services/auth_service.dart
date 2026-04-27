import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS ? dotenv.env['GOOGLE_CLIENT_ID_IOS'] : null,
    serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
    scopes: ['email', 'profile'],
  );

  // สังเกตสถานะการเข้าสู่ระบบ
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ฟังก์ชัน Login (Google + Firebase)
  static Future<User?> login() async {
    try {
      // 1. เริ่มต้นการเข้าสู่ระบบด้วย Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // 2. ดึง Authentication credentials จาก Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. สร้าง Credential สำหรับ Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. เข้าสู่ระบบ Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 5. เช็คและสร้างเอกสารเริ่มต้นใน Firestore
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'nickname': user.displayName ?? 'นักเดินทาง',
            'email': user.email,
            'photoUrl': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return user;
    } catch (error) {
      print('Firebase Google Sign In Error: $error');
      return null;
    }
  }

  // ฟังก์ชัน Logout
  static Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
