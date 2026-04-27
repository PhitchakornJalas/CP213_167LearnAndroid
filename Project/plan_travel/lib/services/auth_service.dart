import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class AuthService {
  // ตั้งค่า GoogleSignIn โดยแยกตาม Platform
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // สำหรับ Android บางครั้งไม่ต้องระบุ Client ID หากลงทะเบียน SHA-1 ถูกต้อง
    // serverClientId: Platform.isAndroid ? dotenv.env['GOOGLE_CLIENT_ID_ANDROID'] : null,
    clientId: Platform.isIOS ? dotenv.env['GOOGLE_CLIENT_ID_IOS'] : null,
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  // ฟังก์ชัน Login
  static Future<GoogleSignInAccount?> login() async {
    try {
      return await _googleSignIn.signIn();
    } catch (error) {
      print('Google Sign In Error: $error');
      return null;
    }
  }

  // ฟังก์ชัน Logout
  static Future<void> logout() => _googleSignIn.disconnect();

  // ตรวจสอบว่า Login อยู่หรือไม่
  static Future<GoogleSignInAccount?> getCurrentUser() => _googleSignIn.signInSilently();
}
