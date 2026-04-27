import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'bank_account_view.dart';
import 'profile_main_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isLoggingIn = false;

  // Widget สำหรับปุ่ม Login แบบ Minimal White
  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: ElevatedButton(
        onPressed: _isLoggingIn ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: _isLoggingIn
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                mainAxisSize: MainAxisSize.min, // จำกัดขนาด Row ไม่ให้ขยายเกินจำเป็น
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://w7.pngwing.com/pngs/326/85/png-transparent-google-logo-google-text-trademark-logo-thumbnail.png',
                    height: 20,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, size: 20, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  const Flexible(
                    child: Text(
                      "เข้าสู่ระบบด้วย Google",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Widget สำหรับแสดงข้อมูลโปรไฟล์เมื่อ Login แล้ว
  Widget _buildProfileHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Consumer<ProfileViewModel>(
            builder: (context, profileVM, child) {
              final localImage = profileVM.profile?.photoUrl;
              
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileMainView())),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: _buildImageProvider(localImage ?? user.photoURL),
                  child: (localImage == null && user.photoURL == null) 
                      ? const Icon(Icons.person, size: 40, color: Colors.blue) 
                      : null,
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<ProfileViewModel>(
                  builder: (context, profileVM, child) {
                    String displayName = user.displayName ?? "ผู้ใช้งาน";
                    final localNickname = profileVM.profile?.nickname;
                    
                    // ถ้ามีชื่อเล่นในเครื่อง และไม่ใช่ค่าเริ่มต้น ให้ใช้ชื่อเล่นแทน
                    if (localNickname != null && localNickname != 'นักเดินทาง') {
                      displayName = localNickname;
                    }
                    
                    return Text(
                      displayName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                Text(
                  user.email ?? "",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => AuthService.logout(),
                  child: const Text(
                    "ออกจากระบบ",
                    style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileMainView())),
            icon: const Icon(Icons.edit_note, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoggingIn = true);
    try {
      final user = await AuthService.login();
      if (user == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("เข้าสู่ระบบล้มเหลว")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        final User? user = snapshot.data;

        return ListView(
          children: [
            // ส่วนหัว (Header) ตามสถานะ Login
            Container(
              constraints: const BoxConstraints(minHeight: 140),
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: user == null ? _buildLoginButton() : _buildProfileHeader(user),
            ),
            const Divider(),
            
            // รายการเมนูที่เหลืออยู่
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.green),
              title: const Text("จัดการบัญชีธนาคาร"),
              subtitle: const Text("สำหรับรับเงินออมและสร้าง QR Code"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BankAccountView()));
              },
            ),
          ],
        );
      },
    );
  }

  ImageProvider? _buildImageProvider(String? path) {
    if (path == null) return null;
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else {
      return FileImage(File(path));
    }
  }
}
