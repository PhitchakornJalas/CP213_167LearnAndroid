import 'package:flutter/material.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart'; // import library ใหม่

class QRPaymentView extends StatelessWidget {
  final double amount;
  final String title;
  final String promptPayId;
  final String accountName;

  const QRPaymentView({
    super.key, 
    required this.amount, 
    required this.title,
    required this.promptPayId,
    required this.accountName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("สแกนเพื่อออมเงิน")),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          Text("${amount.toInt()} ฿", 
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          const SizedBox(height: 20),
          
          // --- ส่วนแสดง QR Code ของจริง ---
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  // ใช้ Widget จาก Library เพื่อเจน QR
                  QRCodeGenerate(
                    promptPayId: promptPayId, 
                    amount: amount,
                    width: 220,
                    height: 220,
                  ),
                  const SizedBox(height: 10),
                  const Text("Scan QR เพื่อโอนเงินเข้าบัญชี", 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
            ),
          ),
          // -----------------------------
          
          const SizedBox(height: 30),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                _buildInfoRow("ชื่อบัญชีรับเงิน", accountName),
                _buildInfoRow("พร้อมเพย์", _formatPhoneNumber(promptPayId)),
              ],
            ),
          ),
          
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("โอนเงินเรียบร้อยแล้ว", style: TextStyle(fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }

  String _formatPhoneNumber(String phone) {
    if (phone.length != 10) return phone;
    return "${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}";
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
