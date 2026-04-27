import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';

class BankAccountView extends StatefulWidget {
  const BankAccountView({super.key});

  @override
  State<BankAccountView> createState() => _BankAccountViewState();
}

class _BankAccountViewState extends State<BankAccountView> {
  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _promptPayController = TextEditingController();
  
  bool _isEditing = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _aliasController.dispose();
    _promptPayController.dispose();
    super.dispose();
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

  Future<void> _saveData(ProfileViewModel vm) async {
    final alias = _aliasController.text.trim();
    final ppId = _promptPayController.text.trim();

    if (alias.isEmpty || ppId.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบ 10 หลัก"), backgroundColor: Colors.orange),
      );
      return;
    }

    await vm.saveProfile(
      nickname: vm.profile?.nickname ?? 'นักเดินทาง',
      accountName: alias,
      promptPay: ppId,
    );

    setState(() => _isEditing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("บันทึกข้อมูลเรียบร้อยแล้ว"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("จัดการบัญชีธนาคาร")),
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, child) {
          final profile = vm.profile;

          // กำหนดค่าเริ่มต้นครั้งแรกที่โหลดข้อมูลมาได้
          if (!_isInitialized && profile != null) {
            _aliasController.text = profile.accountName ?? "";
            _promptPayController.text = profile.promptPay ?? "";
            if (_aliasController.text.isEmpty) _isEditing = true;
            _isInitialized = true;
          }

          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. กล่องแสดงผล (Card)
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
                        if (!_isEditing)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 22),
                            onPressed: () => setState(() => _isEditing = true),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _getFormattedPreview(_promptPayController.text),
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 32, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1.5
                      )
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _aliasController.text.isEmpty ? "ยังไม่ได้กำหนดชื่อ" : _aliasController.text, 
                          style: const TextStyle(color: Colors.white, fontSize: 18)
                        ),
                        const Icon(Icons.qr_code_2, color: Colors.white, size: 30),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2. ส่วนแก้ไขข้อมูล
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
                  onPressed: () => _saveData(vm),
                  label: const Text("บันทึก"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                if (profile.accountName != null)
                  TextButton(
                    onPressed: () => setState(() => _isEditing = false), 
                    child: const Text("ยกเลิก", style: TextStyle(color: Colors.grey))
                  ),
              ],
              
              if (!_isEditing)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
