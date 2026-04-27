import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';

class QRPaymentView extends StatefulWidget {
  final List<Map<String, dynamic>> savingBreakdown; // เปลี่ยนมาใช้ Breakdown แทน
  final double totalAmount;
  final String promptPayId;
  final String accountName;
  final bool useSlipVerification;

  const QRPaymentView({
    super.key, 
    required this.savingBreakdown,
    required this.totalAmount, 
    required this.promptPayId,
    required this.accountName,
    this.useSlipVerification = false,
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
    
    // อัปเดตสถานะใน Firestore ผ่าน ViewModel
    vm.confirmSaving(widget.totalAmount, widget.savingBreakdown);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ออมเงินสำเร็จ!"), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  Widget _buildQRSection() {
    String title = widget.savingBreakdown.length == 1 
        ? "ออมเพื่อ ${widget.savingBreakdown[0]['title']}" 
        : "ออมเงินรวมสำหรับวันนี้";

    return Column(
      children: [
        const SizedBox(height: 30),
        Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        Text("${widget.totalAmount.toInt()} ฿", 
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
                  amount: widget.totalAmount,
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
      appBar: AppBar(title: Text(widget.useSlipVerification ? "ยืนยันด้วยสลิป" : "ยืนยันการโอน")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildQRSection(),
            const SizedBox(height: 20),
            if (widget.useSlipVerification) ...[
              const Divider(),
              if (_slipImage != null) 
                Image.network(_slipImage!.path, height: 200)
              else
                const Text("ยังไม่ได้เลือกสลิป"),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("เลือกรูปสลิปจากเครื่อง"),
              ),
              const SizedBox(height: 10),
            ],
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: (widget.useSlipVerification && _slipImage == null) 
                    ? null 
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
