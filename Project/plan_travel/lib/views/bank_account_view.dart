import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BankAccountView extends StatefulWidget {
  const BankAccountView({super.key});

  @override
  State<BankAccountView> createState() => _BankAccountViewState();
}

class _BankAccountViewState extends State<BankAccountView> {
  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _promptPayController = TextEditingController();
  
  bool _isEditing = true; // สถานะว่ากำลังแก้ไขอยู่หรือไม่ (Default เป็น true สำหรับครั้งแรก)

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  String _getFormattedPreview(String phone) {
    if (phone.isEmpty) return "xxx-xxx-xxxx";
    String formatted = phone;
    if (phone.length > 3 && phone.length <= 6) {
      formatted = "${phone.substring(0, 3)}-${phone.substring(3)}";
    } else if (phone.length > 6) {
      formatted = "${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}";
    }
    return formatted;
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAlias = prefs.getString('bank_alias') ?? "";
    final savedPP = prefs.getString('promptpay_id') ?? "";

    if (savedAlias.isNotEmpty && savedPP.isNotEmpty) {
      setState(() {
        _aliasController.text = savedAlias;
        _promptPayController.text = savedPP;
        _isEditing = false; // ถ้ามีข้อมูลอยู่แล้ว ให้ล็อกไว้ก่อน
      });
    }
  }

  Future<void> _saveData() async {
    final alias = _aliasController.text.trim();
    final ppId = _promptPayController.text.trim();

    if (alias.isEmpty || ppId.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบ 10 หลัก"), backgroundColor: Colors.orange),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bank_alias', alias);
    await prefs.setString('promptpay_id', ppId);

    setState(() {
      _isEditing = false; // บันทึกเสร็จแล้วให้ล็อก
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("บันทึกข้อมูลเรียบร้อยแล้ว"), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("จัดการบัญชีธนาคาร")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. กล่องสีน้ำเงิน (แสดงผลตลอดเวลา)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("พร้อมเพย์สำหรับรับเงินออม", 
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    // แสดงปุ่มปากกาเฉพาะตอนที่ "ไม่ได้แก้ไขอยู่"
                    if (!_isEditing)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 22),
                        onPressed: () => setState(() => _isEditing = true),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _getFormattedPreview(_promptPayController.text),
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 32, // ปรับให้ใหญ่ขึ้นเพราะพื้นที่เยอะขึ้น
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.5
                  )
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _aliasController.text.isEmpty ? "ชื่อบัญชี" : _aliasController.text, 
                      style: const TextStyle(color: Colors.white, fontSize: 18)
                    ),
                    const Icon(Icons.qr_code_2, color: Colors.white, size: 30),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 2. ส่วนช่องกรอก (จะแสดงเฉพาะตอน _isEditing == true เท่านั้น)
          if (_isEditing) ...[
            const Text("แก้ไขข้อมูลบัญชี", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 15),
            TextField(
              controller: _aliasController,
              onChanged: (v) => setState(() {}),
              decoration: const InputDecoration(
                labelText: "ชื่อเรียกบัญชี",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_important_outline),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _promptPayController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (v) => setState(() {}),
              decoration: InputDecoration(
                labelText: "เบอร์โทรศัพท์พร้อมเพย์",
                hintText: "0812345678",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone_android),
                counterText: "${_promptPayController.text.length}/10",
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _saveData,
              icon: const Icon(Icons.check_circle),
              label: const Text("ยืนยันการบันทึก"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            // เพิ่มปุ่มยกเลิก (ในกรณีที่ไม่อยากแก้แล้ว)
            TextButton(
              onPressed: () {
                _loadSavedData(); // โหลดค่าเดิมกลับมา
                setState(() => _isEditing = false);
              }, 
              child: const Text("ยกเลิกการแก้ไข", style: TextStyle(color: Colors.grey))
            ),
          ],
          
          // ถ้าบันทึกแล้ว อาจจะโชว์คำแนะนำเล็กๆ แทน
          if (!_isEditing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "ข้อมูลพร้อมเพย์นี้จะถูกใช้เพื่อสร้าง QR Code ออมเงินของคุณ",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
