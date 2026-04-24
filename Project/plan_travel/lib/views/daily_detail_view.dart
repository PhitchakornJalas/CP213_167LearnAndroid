import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';

class DailyDetailView extends StatefulWidget {
  final DateTime selectedDay;
  const DailyDetailView({super.key, required this.selectedDay});

  @override
  State<DailyDetailView> createState() => _DailyDetailViewState();
}

class _DailyDetailViewState extends State<DailyDetailView> {
  late TextEditingController _titleController;
  late TextEditingController _budgetController;
  
  // แยก Controller ของใครของมันเพื่อให้เลขไม่ทับกัน
  final TextEditingController _dayController = TextEditingController(text: '1');
  final TextEditingController _weekController = TextEditingController(text: '1');
  final TextEditingController _monthController = TextEditingController(text: '1');
  final TextEditingController _yearController = TextEditingController(text: '1');

  String _selectedType = 'today';
  int _customValue = 1;
  bool _isAllDay = true;
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  @override
  void initState() {
    super.initState();
    // ตั้งค่าเวลาเริ่มต้น: ชั่วโมงถัดไป และ สิ้นสุดคืออีก 1 ชั่วโมงถัดไป
    final now = DateTime.now();
    _startDateTime = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day, now.hour + 1, 0);
    _endDateTime = _startDateTime.add(const Duration(hours: 1));

    final vm = Provider.of<DailyDetailViewModel>(context, listen: false);
    final detail = vm.getDetail(widget.selectedDay);
    
    _titleController = TextEditingController(text: detail?.title ?? '');
    _budgetController = TextEditingController(text: detail?.budget ?? '');

    if (detail != null) {
      _isAllDay = detail.isAllDay;
      _startDateTime = detail.startTime;
      _endDateTime = detail.endTime;
    }

    if (detail != null && detail.savingStartDate != null) {
      final eventDay = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
      final startDay = DateTime(detail.savingStartDate!.year, detail.savingStartDate!.month, detail.savingStartDate!.day);
      int diff = eventDay.difference(startDay).inDays;
      
      if (diff == 0) {
        _selectedType = 'today';
      } else if (diff % 365 == 0) {
        _selectedType = 'year'; _customValue = diff ~/ 365;
        _yearController.text = _customValue.toString();
      } else if (diff % 30 == 0) {
        _selectedType = 'month'; _customValue = diff ~/ 30;
        _monthController.text = _customValue.toString();
      } else if (diff % 7 == 0) {
        _selectedType = 'week'; _customValue = diff ~/ 7;
        _weekController.text = _customValue.toString();
      } else {
        _selectedType = 'day'; _customValue = diff;
        _dayController.text = _customValue.toString();
      }
    }
  }

  // ฟังก์ชันเลือก วัน/เวลา
  Future<void> _pickDateTime(bool isStart) async {
    DateTime initial = isStart ? _startDateTime : _endDateTime;
    
    // เลือกวันที่
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    if (_isAllDay) {
      setState(() {
        if (isStart) _startDateTime = DateTime(date.year, date.month, date.day);
        else _endDateTime = DateTime(date.year, date.month, date.day);
      });
    } else {
      // เลือกเวลาต่อถ้าไม่ใช่ All Day
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (time == null) return;
      setState(() {
        final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        if (isStart) _startDateTime = dt;
        else _endDateTime = dt;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Normalize วันที่ปัจจุบัน
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDayOnly = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
    final isLocked = selectedDayOnly.isBefore(today) || selectedDayOnly.isAtSameMomentAs(today);

    // ตรวจสอบว่ามีการกรอกงบประมาณหรือไม่
    bool hasBudget = _budgetController.text.trim().isNotEmpty && 
                     (double.tryParse(_budgetController.text) ?? 0) > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดรายวัน')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. ชื่อกิจกรรม
            TextField(
              controller: _titleController,
              enabled: !isLocked,
              decoration: const InputDecoration(labelText: 'ชื่อกิจกรรม/เป้าหมาย', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            // 2. Toggle ตลอดวัน
            SwitchListTile(
              title: const Text("ตลอดวัน"),
              value: _isAllDay,
              onChanged: isLocked ? null : (v) => setState(() => _isAllDay = v),
            ),

            // 3. แสดงวัน/เวลา เริ่มต้น - สิ้นสุด
            ListTile(
              title: const Text("เริ่ม"),
              trailing: Text(_isAllDay ? "${_startDateTime.day}/${_startDateTime.month}/${_startDateTime.year}" : "${_startDateTime.day}/${_startDateTime.month}/${_startDateTime.year}  ${_startDateTime.hour}:00"),
              onTap: isLocked ? null : () => _pickDateTime(true),
            ),
            ListTile(
              title: const Text("ถึง"),
              trailing: Text(_isAllDay ? "${_endDateTime.day}/${_endDateTime.month}/${_endDateTime.year}" : "${_endDateTime.day}/${_endDateTime.month}/${_endDateTime.year}  ${_endDateTime.hour}:00"),
              onTap: isLocked ? null : () => _pickDateTime(false),
            ),

            const SizedBox(height: 20),
            
            // 4. งบประมาณ
            TextField(
              controller: _budgetController,
              enabled: !isLocked,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'งบประมาณ (บาท)', border: OutlineInputBorder()),
              onChanged: (v) => setState(() {}), // สั่งให้ UI rebuild เพื่อเช็ค hasBudget
            ),
            
            // ถ้ามีงบประมาณ ถึงจะโชว์ส่วนเลือกแผนการออมเงิน
            if (hasBudget) ...[
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft, 
                child: Text("แผนการออมเงิน", style: TextStyle(fontWeight: FontWeight.bold))
              ),
              RadioListTile<String>(
                title: const Text("ตั้งแต่วันนี้"),
                value: 'today', 
                groupValue: _selectedType,
                onChanged: isLocked ? null : (v) => setState(() => _selectedType = v!),
              ),
              _buildPlanRadio("วัน", 'day', 1, _dayController, isLocked),
              _buildPlanRadio("สัปดาห์", 'week', 7, _weekController, isLocked),
              _buildPlanRadio("เดือน", 'month', 30, _monthController, isLocked),
              _buildPlanRadio("ปี", 'year', 365, _yearController, isLocked),
            ],

            const SizedBox(height: 30),
            if (!isLocked)
              SizedBox(
                width: double.infinity, 
                child: ElevatedButton(
                  onPressed: () {
                    // บังคับชื่อห้ามว่าง
                    if (_titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณากรอกชื่อกิจกรรม'), backgroundColor: Colors.red)
                      );
                      return;
                    }

                    DateTime? savingStart;
                    // ถ้ามีงบ ถึงจะส่งค่าวันเริ่มออมไปคำนวณ
                    if (hasBudget) {
                      if (_selectedType == 'today') {
                        savingStart = today;
                      } else {
                        int mult = _selectedType == 'year' ? 365 : (_selectedType == 'week' ? 7 : (_selectedType == 'month' ? 30 : 1));
                        savingStart = selectedDayOnly.subtract(Duration(days: _customValue * mult));
                      }
                    }

                    context.read<DailyDetailViewModel>().updateDailyDetail(
                      selectedDayOnly, 
                      _titleController.text, 
                      _budgetController.text, 
                      savingStart,
                      _isAllDay,
                      _startDateTime,
                      _endDateTime,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('บันทึกรายละเอียด'),
                ),
              )
            else
              const Text("* วันนี้หรือย้อนหลังไม่สามารถลงกิจกรรมได้", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanRadio(String label, String type, int multiplier, TextEditingController controller, bool isLocked) {
    // คำนวณหาค่าปัจจุบันที่พิมพ์อยู่ในช่องนั้นๆ
    int currentInput = int.tryParse(controller.text) ?? 1;
    final startDate = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day)
        .subtract(Duration(days: currentInput * multiplier));
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    bool isValid = !startDate.isBefore(today) && !isLocked;

    return RadioListTile<String>(
      value: type,
      groupValue: _selectedType,
      onChanged: isValid ? (v) => setState(() {
        _selectedType = v!;
        _customValue = int.tryParse(controller.text) ?? 1;
      }) : null,
      title: Row(
        children: [
          SizedBox(
            width: 50,
            child: TextField(
              keyboardType: TextInputType.number,
              controller: controller, // ใช้ Controller ที่แยกกัน
              decoration: const InputDecoration(isDense: true),
              enabled: !isLocked,
              onChanged: (v) {
                setState(() {
                  _customValue = int.tryParse(v) ?? 1;
                });
              },
            ),
          ),
          Text(" $label ก่อนเริ่ม"),
        ],
      ),
      subtitle: !isValid && !isLocked ? const Text("ย้อนอดีตเกินไป", style: TextStyle(color: Colors.red, fontSize: 10)) : null,
    );
  }
}