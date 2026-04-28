import 'package:flutter/material.dart';
import 'auth_gate.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    // หน่วงเวลา 2 วินาที (เพื่อให้ Splash Screen แสดงผล)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // ย้ายไปที่ AuthGate เพื่อเช็คสถานะ Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // เปลี่ยนเป็นสีขาวตามหน้า Login
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 120, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text(
              'Plan Travel',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'วางแผนการออม เพื่อทริปในฝันของคุณ',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(color: Colors.blueAccent), // สีน้ำเงินตามหน้า Login
          ],
        ),
      ),
    );
  }
}