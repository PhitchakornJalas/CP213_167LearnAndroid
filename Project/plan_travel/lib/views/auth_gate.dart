import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_view.dart';
import 'login_view.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ขณะกำลังโหลดสถานะเริ่มต้น
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ถ้ามีข้อมูล User แสดงว่า Login แล้ว -> พาไปหน้า Home
        if (snapshot.hasData) {
          return const HomeView();
        }

        // ถ้าไม่มีข้อมูล User -> พาไปหน้า Login
        return const LoginView();
      },
    );
  }
}
