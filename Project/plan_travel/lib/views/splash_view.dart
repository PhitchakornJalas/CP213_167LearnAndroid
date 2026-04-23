import 'package:flutter/material.dart';
import 'home.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // หน่วงเวลา 2 วินาที (Dummy)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // ย้ายไปหน้า Calendar และลบหน้า Splash ออกจาก Stack (ย้อนกลับไม่ได้)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blueAccent, // สีพื้นหลังชั่วคราว
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // เดี๋ยวค่อยมาใส่รูป Logo ตรงนี้
            Icon(Icons.calendar_month, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Plan Travel App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white), // ตัวหมุน Loading
          ],
        ),
      ),
    );
  }
}