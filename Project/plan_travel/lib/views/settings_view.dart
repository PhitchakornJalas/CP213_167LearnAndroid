import 'package:flutter/material.dart';
import 'bank_account_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // ส่วนหัว: บัญชีผู้ใช้
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 20),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("User Name", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("user@example.com", style: TextStyle(color: Colors.grey)),
                ],
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
        // ... เมนูอื่นๆ ...
      ],
    );
  }
}
