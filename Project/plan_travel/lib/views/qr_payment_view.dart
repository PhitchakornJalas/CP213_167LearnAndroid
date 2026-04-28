import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../viewmodels/daily_detail_viewmodel.dart';

class QRPaymentView extends StatefulWidget {
  final List<Map<String, dynamic>> savingBreakdown;
  final double totalAmount;
  final String promptPayId;
  final String accountName;
  final bool useSlipVerification;
  final DateTime targetDate;

  const QRPaymentView({
    super.key, 
    required this.savingBreakdown,
    required this.totalAmount, 
    required this.promptPayId,
    required this.accountName,
    required this.targetDate,
    this.useSlipVerification = false,
  });

  @override
  State<QRPaymentView> createState() => _QRPaymentViewState();
}

class _QRPaymentViewState extends State<QRPaymentView> {
  XFile? _slipImage;
  String? _scannedRefId;
  bool _isScanning = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _slipImage = image;
      _isScanning = true;
    });

    // พยายามดึง Ref ID มาเก็บไว้ประดับเฉยๆ ไม่ Block แล้ว
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final barcodeScanner = BarcodeScanner();
      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
      for (Barcode barcode in barcodes) {
        if (barcode.rawValue != null) {
          setState(() => _scannedRefId = barcode.rawValue);
          break;
        }
      }
      barcodeScanner.close();
    } catch (_) {}

    setState(() => _isScanning = false);
  }

  void _processConfirm(BuildContext context) async {
    final vm = Provider.of<DailyDetailViewModel>(context, listen: false);
    
    // บันทึกการออมเลย ไม่ต้องเช็คอะไรทั้งนั้น
    await vm.confirmSaving(widget.totalAmount, widget.savingBreakdown, referenceId: _scannedRefId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ยืนยันการออมสำเร็จ"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildQRSection() {
    return Column(
      children: [
        const SizedBox(height: 30),
        const Text("ยอดเงินที่ต้องออม", style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                  promptPayId: widget.promptPayId.replaceAll(RegExp(r'[^0-9]'), ''), 
                  amount: double.parse(widget.totalAmount.toStringAsFixed(2)),
                  width: 220,
                  height: 220,
                ),
                const SizedBox(height: 10),
                const Text("Scan QR เพื่อโอนเงิน", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text("ชื่อบัญชี: ${widget.accountName}", style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("พร้อมเพย์: ${widget.promptPayId}"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ยืนยันการโอม")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildQRSection(),
            const Divider(height: 40),
            
            if (_slipImage != null) ...[
              Image.file(File(_slipImage!.path), height: 250),
              const SizedBox(height: 10),
              if (_isScanning) const CircularProgressIndicator(),
              if (_scannedRefId != null) 
                Text("ตรวจพบรหัส: ${_scannedRefId!.length > 20 ? _scannedRefId!.substring(0, 20) + '...' : _scannedRefId}", 
                     style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
            
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("อัพโหลดรูปสลิป"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50, foregroundColor: Colors.blue),
            ),
            
            Padding(
              padding: const EdgeInsets.all(30),
              child: ElevatedButton(
                onPressed: _slipImage == null ? null : () => _processConfirm(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: Colors.green,
                ),
                child: const Text("ยืนยันและบันทึก", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
