import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isLoggingIn = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoggingIn = true);
    try {
      final user = await AuthService.login();
      if (user == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('การเข้าสู่ระบบล้มเหลว หรือถูกยกเลิก')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.blue],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Section
            const Icon(Icons.calendar_month, size: 120, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Plan Travel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Text(
              'วางแผนการออม เพื่อทริปในฝันของคุณ',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            
            const SizedBox(height: 80),

            // Login Button Section
            if (_isLoggingIn)
              const CircularProgressIndicator(color: Colors.white)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: _handleGoogleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // ใช้พื้นที่เท่าที่จำเป็น
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ใช้ URL ที่ปลอดภัยกว่า หรือ Icon สำรองถ้าโหลดไม่ได้
                      Image.network(
                        'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                        height: 24,
                        width: 24,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, color: Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      const Flexible( // ป้องกันตัวหนังสือล้นจอ
                        child: Text(
                          'เข้าสู่ระบบด้วย Google',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            const Text(
              'ปลอดภัย มั่นใจ ข้อมูลซิงค์ผ่าน Cloud',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
