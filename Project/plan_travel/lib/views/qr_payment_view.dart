import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/slip_parser.dart';
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
  final ScreenshotController _screenshotController = ScreenshotController();

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _downloadQR() async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/qr_code.png').create();
      await imagePath.writeAsBytes(image);

      await Gal.putImage(imagePath.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("บันทึก QR Code ลงเครื่องสำเร็จ!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาด: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _slipImage = image;
      _isScanning = true;
    });

    // ตรวจสอบเบื้องต้นว่าเป็น QR ธนาคารไทยหรือไม่
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final barcodeScanner = BarcodeScanner();
      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
      
      String? rawValue;
      for (Barcode barcode in barcodes) {
        if (barcode.rawValue != null) {
          rawValue = barcode.rawValue;
          break;
        }
      }

      if (rawValue != null) {
        final slipData = SlipParser.parseEslip(rawValue);
        // ตรวจสอบแค่ว่าเป็นรูปแบบสลิปไทยหรือไม่ (ไม่สนวันที่/ยอดเงินตามคำขอ)
        // isBankSlip ในตัวแกะรหัสจะเช็ค 000201 หรือ 00XX ให้เราอยู่แล้ว
        if (slipData.rawPayload != null && 
           (slipData.rawPayload!.contains("000201") || slipData.rawPayload!.startsWith("00"))) {
          setState(() {
            _scannedRefId = slipData.referenceId ?? "BANK_SLIP_DETECTED";
          });
        } else {
          _showError("รูปภาพนี้ไม่มี QR Code ของสลิปธนาคารไทย");
          setState(() => _slipImage = null);
        }
      } else {
        _showError("ไม่พบ QR Code ในรูปภาพ");
        setState(() => _slipImage = null);
      }
      barcodeScanner.close();
    } catch (e) {
      _showError("เกิดข้อผิดพลาดในการสแกน: $e");
      setState(() => _slipImage = null);
    }

    setState(() => _isScanning = false);
  }

  void _processConfirm(BuildContext context) async {
    final vm = Provider.of<DailyDetailViewModel>(context, listen: false);
    
    // บันทึกการออมเลย ไม่ต้องเช็คอะไรทั้งนั้น
    await vm.confirmSaving(widget.totalAmount, widget.savingBreakdown, 
        referenceId: _scannedRefId, 
        targetDate: widget.targetDate); // ส่งวันที่เป้าหมายไปด้วย
    
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
          child: Screenshot(
            controller: _screenshotController,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QRCodeGenerate(
                    promptPayId: widget.promptPayId.replaceAll(RegExp(r'[^0-9]'), ''), 
                    amount: double.parse(widget.totalAmount.toStringAsFixed(2)),
                    width: 220,
                    height: 220,
                  ),
                  const SizedBox(height: 10),
                  const Text("Scan QR เพื่อโอนเงิน", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  Text("ชื่อบัญชี: ${widget.accountName}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text("พร้อมเพย์: ${widget.promptPayId}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextButton.icon(
          onPressed: _downloadQR,
          icon: const Icon(Icons.download),
          label: const Text("ดาวน์โหลด QR Code"),
          style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
        ),
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
