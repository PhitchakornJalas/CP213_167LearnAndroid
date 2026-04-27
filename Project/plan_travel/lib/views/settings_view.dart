import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import 'bank_account_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  GoogleSignInAccount? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ตรวจสอบว่าเคย Login ไว้หรือไม่
    AuthService.getCurrentUser().then((user) {
      if (mounted) {
        setState(() => _currentUser = user);
      }
    });
  }

  Widget _buildGoogleSignInButton() {
    if (_isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return _currentUser == null
        ? TextButton.icon(
            onPressed: () async {
              setState(() => _isLoading = true);
              print('Attempting to login...');
              try {
                final user = await AuthService.login();
                if (user != null) {
                  print('Login successful: ${user.displayName}');
                  setState(() => _currentUser = user);
                } else {
                  print('Login failed or cancelled');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("เข้าสู่ระบบล้มเหลว กรุณาตรวจสอบการตั้งค่า (SHA-1)")),
                    );
                  }
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            icon: const Icon(Icons.login, color: Colors.blue),
            label: const Text("เข้าสู่ระบบด้วย Google", style: TextStyle(color: Colors.blue)),
          )
        : TextButton.icon(
            onPressed: () async {
              await AuthService.logout();
              setState(() => _currentUser = null);
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text("ออกจากระบบ", style: TextStyle(color: Colors.red)),
          );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // ส่วนหัว: บัญชีผู้ใช้
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blueAccent,
                backgroundImage: _currentUser?.photoUrl != null 
                    ? NetworkImage(_currentUser!.photoUrl!) 
                    : null,
                child: _currentUser?.photoUrl == null 
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?.displayName ?? "ยังไม่ได้เข้าสู่ระบบ", 
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                    Text(
                      _currentUser?.email ?? "คลิกเพื่อ Login", 
                      style: const TextStyle(color: Colors.grey)
                    ),
                    const SizedBox(height: 8),
                    _buildGoogleSignInButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.manage_accounts, color: Colors.blueAccent),
          title: const Text("จัดการบัญชีผู้ใช้"),
          subtitle: const Text("แก้ไขข้อมูลส่วนตัว และรหัสผ่าน"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
             // Logic ไปหน้าจัดการบัญชี
          },
        ),
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
  }
}
