import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';
import '../models/daily_detail_model.dart';
import 'daily_detail_info_view.dart';

class DailyDetailView extends StatefulWidget {
  final DateTime selectedDay;
  final DailyDetailModel? existingEvent; // เพิ่ม Optional parameter 

  const DailyDetailView({super.key, required this.selectedDay, this.existingEvent});

  @override
  State<DailyDetailView> createState() => _DailyDetailViewState();
}

class _DailyDetailViewState extends State<DailyDetailView> {
  bool _isSaved = false;
  late TextEditingController _titleController;
  List<BudgetItem> _budgetList = [BudgetItem(label: '', amount: 0)];
  DailyDetailModel? _currentEvent;
  
  // แยก Controller ของใครของมันเพื่อให้เลขไม่ทับกัน
  final TextEditingController _dayController = TextEditingController(text: '1');
  final TextEditingController _weekController = TextEditingController(text: '1');
  final TextEditingController _monthController = TextEditingController(text: '1');
  final TextEditingController _yearController = TextEditingController(text: '1');

  String _selectedType = '';
  int _customValue = 1;
  bool _isAllDay = true;
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    
    // 1. ตั้งค่าสำหรับกรณี "กำหนดเวลา" (Default: ชั่วโมงถัดไป)
    _startDateTime = DateTime(
      widget.selectedDay.year, 
      widget.selectedDay.month, 
      widget.selectedDay.day, 
      now.hour + 1, 
      0
    );
    _endDateTime = _startDateTime.add(const Duration(hours: 1));

    final detail = widget.existingEvent;
    
    _titleController = TextEditingController(text: detail?.title ?? '');
    
    if (detail != null) {
      _budgetList = List<BudgetItem>.from(detail.budgetItems.map((e) => BudgetItem(label: e.label, amount: e.amount)));
    } else {
      _budgetList = [BudgetItem(label: '', amount: 0)];
    }

    if (detail != null) {
      _isAllDay = detail.isAllDay;
      _startDateTime = detail.startTime;
      _endDateTime = detail.endTime;
    } else {
      // 2. ถ้าเป็นการสร้างใหม่ และเลือก "ตลอดวัน" (Default)
      // ให้ Start และ End เป็นวันที่เดียวกัน (00:00 - 23:59 หรือแค่วันเดียวกัน)
      if (_isAllDay) {
        _startDateTime = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
        _endDateTime = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
      }
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

    if (widget.existingEvent != null) {
      _currentEvent = widget.existingEvent;
      _isSaved = true;
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
                    // กำหนด Minimum Date สำหรับช่อง "สิ้นสุด" ให้เริ่มได้ไม่ก่อน "เวลาเริ่ม"
                    minimumDate: isStart ? null : _startDateTime, 
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        if (isStart) {
                          _startDateTime = newDateTime;
                          // LOGIC: ถ้าเปลี่ยนเวลาเริ่มแล้วดันไป "หลัง" เวลาสิ้นสุดที่มีอยู่
                          // ให้ดีดเวลาสิ้นสุดตามมาเป็น +1 ชั่วโมงอัตโนมัติ
                          if (_startDateTime.isAfter(_endDateTime) || 
                              _startDateTime.isAtSameMomentAs(_endDateTime)) {
                            _endDateTime = _startDateTime.add(const Duration(hours: 1));
                          }
                        } else {
                          // สำหรับช่องสิ้นสุด CupertinoDatePicker จะล็อคที่ minimumDate ให้อยู่แล้ว
                          // แต่ใส่กันเหนียวไว้อีกชั้น
                          if (newDateTime.isBefore(_startDateTime)) {
                            _endDateTime = _startDateTime;
                          } else {
                            _endDateTime = newDateTime;
                          }
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
    double totalBudget = _budgetList.fold(0.0, (sum, item) => sum + item.amount);
    bool hasBudget = totalBudget > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSaved ? 'รายละเอียดกิจกรรม' : 'รายละเอียดรายวัน'),
        actions: [
          if (_isSaved && !isLocked)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isSaved = false),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _isSaved && _currentEvent != null
          ? DailyDetailInfoView(event: _currentEvent!)
          : Column(
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
              onChanged: isLocked ? null : (v) {
                setState(() {
                  _isAllDay = v;
                  if (_isAllDay) {
                    // ถ้าเปิด "ตลอดวัน" ให้รีเซ็ต Start/End กลับมาเป็นวันเดียวกันที่เลือกจากปฏิทิน
                    _startDateTime = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
                    _endDateTime = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
                  } else {
                    // ถ้าปิด "ตลอดวัน" ค่อยกลับไปใช้ Logic ชั่วโมงปัจจุบัน + 1
                    final now = DateTime.now();
                    _startDateTime = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day, now.hour + 1, 0);
                    _endDateTime = _startDateTime.add(const Duration(hours: 1));
                  }
                });
              },
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
            _buildBudgetSection(isLocked),
            
            // ถ้ามีงบประมาณ ถึงจะโชว์ส่วนเลือกแผนการออมเงิน
            if (hasBudget) ...[
              const SizedBox(height: 20),
              
              if (widget.existingEvent == null || widget.existingEvent!.savingStartDate == null) ...[
                const Align(
                  alignment: Alignment.centerLeft, 
                  child: Text("แผนการออมเงิน", style: TextStyle(fontWeight: FontWeight.bold))
                ),
                RadioListTile<String>(
                  title: Row(
                    children: [
                      const Text("ตั้งแต่วันนี้"),
                      if (_selectedType == 'today')
                        Text(_formatDurationText(_calculateTotalDays()), 
                             style: const TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  value: 'today', 
                  groupValue: _selectedType,
                  onChanged: isLocked ? null : (v) => setState(() => _selectedType = v!),
                ),
                _buildPlanRadio("วัน", 'day', 1, _dayController, isLocked),
                _buildPlanRadio("สัปดาห์", 'week', 7, _weekController, isLocked),
                _buildPlanRadio("เดือน", 'month', 30, _monthController, isLocked),
                _buildPlanRadio("ปี", 'year', 365, _yearController, isLocked),
              ] else ...[
                _buildEditModeCountdown(),
              ],
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
                    if (widget.existingEvent != null && widget.existingEvent!.savingStartDate != null) {
                      // ถ้าเป็นการแก้ไขและมีวันเริ่มออมเดิมอยู่แล้ว ให้ใช้ค่าเดิม (เพื่อไม่ให้ยอดออมต่อวันเปลี่ยน)
                      savingStart = widget.existingEvent!.savingStartDate;
                    } else if (hasBudget) {
                      // ถ้าสร้างใหม่ หรือเป็นการแก้ไขกิจกรรมที่เคยไม่มีงบ/ไม่มีแผนออมมาก่อน ให้คำนวณใหม่ตามแผนที่เลือก
                      savingStart = _calculateSavingStartDate();
                    }

                    String eventId = widget.existingEvent?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

                    final newEvent = DailyDetailModel(
                      id: eventId,
                      title: _titleController.text,
                      budgetItems: _budgetList,
                      savingStartDate: savingStart,
                      isAllDay: _isAllDay,
                      startTime: _startDateTime,
                      endTime: _endDateTime,
                      amountSaved: widget.existingEvent?.amountSaved ?? 0,
                    );

                    vm.addOrUpdateEvent(newEvent);

                    setState(() {
                      _currentEvent = newEvent;
                      _isSaved = true;
                    });
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

  Widget _buildBudgetSection(bool isLocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("รายละเอียดงบประมาณ", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._budgetList.asMap().entries.map((entry) {
          int index = entry.key;
          BudgetItem item = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: TextEditingController(text: item.label)..selection = TextSelection.collapsed(offset: item.label.length),
                    enabled: !isLocked,
                    decoration: const InputDecoration(hintText: "เช่น ค่าข้าว", border: OutlineInputBorder()),
                    onChanged: (val) => item.label = val,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: TextEditingController(text: item.amount == 0 ? '' : item.amount.toInt().toString())..selection = TextSelection.collapsed(offset: (item.amount == 0 ? '' : item.amount.toInt().toString()).length),
                    enabled: !isLocked,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(hintText: "บาท", border: OutlineInputBorder()),
                    onChanged: (val) {
                      setState(() {
                        item.amount = double.tryParse(val) ?? 0;
                        
                        // 1. ถ้าลบตัวเลขจนว่าง ให้ Reset แผนการออม (เช็คจากยอดรวม)
                        double total = _budgetList.fold(0, (sum, b) => sum + b.amount);
                        if (total == 0) {
                          _selectedType = ''; 
                          _customValue = 1;
                          _dayController.text = '1';
                          _weekController.text = '1';
                          _monthController.text = '1';
                          _yearController.text = '1';
                        } else {
                          // 2. ถ้าเริ่มพิมพ์ตัวเลข และยังไม่มีการเลือกแผน ให้ตั้งเป็น 'today' เป็นค่าเริ่มต้น
                          if (_selectedType.isEmpty) {
                            _selectedType = 'today';
                          }
                        }
                      });
                    },
                  ),
                ),
                if (!isLocked)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        if (_budgetList.length > 1) _budgetList.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
          );
        }).toList(),
        if (!isLocked)
          TextButton.icon(
            onPressed: () => setState(() => _budgetList.add(BudgetItem(label: '', amount: 0))),
            icon: const Icon(Icons.add),
            label: const Text("เพิ่มรายการ"),
          ),
        const Divider(),
        Text(
          "รวมยอดทั้งหมด: ${_budgetList.fold(0.0, (sum, item) => sum + item.amount).toInt()} บาท",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
        ),
      ],
    );
  }


  int _calculateTotalDays() {
    final eventDate = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return eventDate.difference(today).inDays;
  }

  DateTime _calculateSavingStartDate() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final selectedDayOnly = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
    
    if (_selectedType == 'today') {
      return today;
    } else {
      int mult = _selectedType == 'year' ? 365 : (_selectedType == 'week' ? 7 : (_selectedType == 'month' ? 30 : 1));
      return selectedDayOnly.subtract(Duration(days: _customValue * mult));
    }
  }

  Widget _buildEditModeCountdown() {
    int daysLeft = _calculateTotalDays();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Text("สถานะกิจกรรมตอนนี้", style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              children: [
                const TextSpan(text: "เหลือเวลาอีก "),
                TextSpan(
                  text: "$daysLeft วัน ",
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const TextSpan(text: "จะถึงวันกิจกรรม"),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "(คุณสามารถแก้ไขงบประมาณได้ ระบบจะคำนวณยอดออมใหม่ตามวันที่เหลือ)",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
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

  String _formatDurationText(int totalDays) {
    if (totalDays <= 0) return " (1 วัน)"; 
    
    int years = totalDays ~/ 365;
    int remainingAfterYears = totalDays % 365;
    
    int months = remainingAfterYears ~/ 30;
    int remainingAfterMonths = remainingAfterYears % 30;
    
    int weeks = remainingAfterMonths ~/ 7;
    int days = remainingAfterMonths % 7;

    List<String> parts = [];
    if (years > 0) parts.add("$years ปี");
    if (months > 0) parts.add("$months เดือน");
    if (weeks > 0) parts.add("$weeks สัปดาห์");
    if (days > 0) parts.add("$days วัน");
    
    if (parts.isEmpty && totalDays > 0) return " ($totalDays วัน)";

    return " (${parts.join(' ')})";
  }
}