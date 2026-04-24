import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';
import '../models/daily_detail_model.dart';

class DailyDetailView extends StatefulWidget {
  final DateTime selectedDay;
  final DailyDetailModel? existingEvent; // เพิ่ม Optional parameter 

  const DailyDetailView({super.key, required this.selectedDay, this.existingEvent});

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

    final detail = widget.existingEvent;
    
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

  // ฟังก์ชันสำหรับเรียก Modal เลือกวันที่/เวลา กลางจอ
  void _showCustomDatePicker(bool isStart) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Center( // จัดให้อยู่กลางจอ
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8, // กำหนดความกว้าง 80% ของจอ
            height: 300,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Expanded(
                  child: CupertinoDatePicker(
                    // ถ้า All Day โชว์แค่เดือน/วัน/ปี ถ้าไม่ใช่โชว์เวลาด้วย
                    mode: _isAllDay 
                        ? CupertinoDatePickerMode.date 
                        : CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: isStart ? _startDateTime : _endDateTime,
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        if (isStart) {
                          _startDateTime = newDateTime;
                        } else {
                          _endDateTime = newDateTime;
                        }
                      });
                    },
                  ),
                ),
                CupertinoButton(
                  child: const Text('ตกลง', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              trailing: Text(_isAllDay 
                  ? "${_startDateTime.day}/${_startDateTime.month}/${_startDateTime.year}" 
                  : "${_startDateTime.day}/${_startDateTime.month}/${_startDateTime.year}  ${_startDateTime.hour}:${_startDateTime.minute.toString().padLeft(2, '0')}"),
              onTap: isLocked ? null : () => _showCustomDatePicker(true),
            ),
            ListTile(
              title: const Text("ถึง"),
              trailing: Text(_isAllDay 
                  ? "${_endDateTime.day}/${_endDateTime.month}/${_endDateTime.year}" 
                  : "${_endDateTime.day}/${_endDateTime.month}/${_endDateTime.year}  ${_endDateTime.hour}:${_endDateTime.minute.toString().padLeft(2, '0')}"),
              onTap: isLocked ? null : () => _showCustomDatePicker(false),
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

                    final vm = context.read<DailyDetailViewModel>();
                    
                    // ตรวจสอบเวลาทับกัน
                    String? errorMsg = vm.checkTimeOverlap(
                      widget.selectedDay,
                      _startDateTime,
                      _endDateTime,
                      _isAllDay,
                      excludeId: widget.existingEvent?.id,
                    );
                    
                    if (errorMsg != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red, duration: const Duration(seconds: 3))
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

                    String eventId = widget.existingEvent?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

                    vm.addOrUpdateEvent(
                      selectedDayOnly, 
                      DailyDetailModel(
                        id: eventId,
                        title: _titleController.text,
                        budget: _budgetController.text,
                        savingStartDate: savingStart,
                        isAllDay: _isAllDay,
                        startTime: _startDateTime,
                        endTime: _endDateTime,
                      )
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