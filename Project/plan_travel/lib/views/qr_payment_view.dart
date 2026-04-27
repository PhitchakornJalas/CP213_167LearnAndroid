import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';

class QRPaymentView extends StatefulWidget {
  final String eventId;
  final double amount;
  final String title;
  final String promptPayId;
  final String accountName;
  final bool useSlipVerification;
  final DateTime currentDay;

  const QRPaymentView({
    super.key, 
    required this.eventId,
    required this.amount, 
    required this.title, 
    required this.promptPayId,
    required this.accountName,
    required this.currentDay,
    this.useSlipVerification = false, // Default เป็นแบบกดยืนยันได้เลย
  });

  @override
  State<QRPaymentView> createState() => _QRPaymentViewState();
}

class _QRPaymentViewState extends State<QRPaymentView> {
  XFile? _slipImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() { _slipImage = image; });
  }

  void _processConfirm(BuildContext context) {
    final vm = Provider.of<DailyDetailViewModel>(context, listen: false);
    
    // อัปเดตสถานะใน ViewModel (ย้ายไป Firestore)
    vm.confirmSaving(widget.eventId, widget.amount);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ออมเงินสำเร็จ!"), backgroundColor: Colors.green),
    );
    Navigator.pop(context); // กลับไปหน้า List
  }

  Widget _buildQRSection() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Text(widget.title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        Text("${widget.amount.toInt()} ฿", 
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        const SizedBox(height: 20),
        
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
                QRCodeGenerate(
                  promptPayId: widget.promptPayId, 
                  amount: widget.amount,
                  width: 220,
                  height: 220,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Scan QR เพื่อโอนเงินเข้าบัญชี",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              _buildInfoRow("ชื่อบัญชีรับเงิน", widget.accountName),
              _buildInfoRow("พร้อมเพย์", _formatPhoneNumber(widget.promptPayId)),
            ],
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.useSlipVerification ? "ยืนยันด้วยสลิป" : "ยืนยันการโอม")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ส่วนแสดง QR และยอดเงิน (เหมือนเดิมที่ทำไว้)
            _buildQRSection(),

            const SizedBox(height: 20),

            // --- Version 2: ถ้าต้องส่งสลิป ---
            if (widget.useSlipVerification) ...[
              const Divider(),
              if (_slipImage != null) 
                Image.network(_slipImage!.path, height: 200) // ตัวอย่างโชว์รูปที่เลือก
              else
                const Text("ยังไม่ได้เลือกสลิป"),
              
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("เลือกรูปสลิปจากเครื่อง"),
              ),
              const SizedBox(height: 10),
            ],

            // --- ปุ่มกดยืนยัน (ใช้ได้ทั้ง 2 Version) ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: (widget.useSlipVerification && _slipImage == null) 
                    ? null // ถ้าต้องใช้สลิปแต่ยังไม่เลือก ให้กดไม่ได้
                    : () => _processConfirm(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: Colors.green,
                ),
                child: Text(widget.useSlipVerification ? "ส่งสลิปเพื่อตรวจสอบ" : "ยืนยันว่าโอนแล้ว (Demo)"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
