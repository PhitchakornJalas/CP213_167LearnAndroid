import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';
import '../models/daily_detail_model.dart';
import 'daily_detail_info_view.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../viewmodels/settings_viewmodel.dart';

class DailyDetailView extends StatefulWidget {
  final DateTime selectedDay;
  final DailyDetailModel? existingEvent;

  const DailyDetailView({super.key, required this.selectedDay, this.existingEvent});

  @override
  State<DailyDetailView> createState() => _DailyDetailViewState();
}

class _DailyDetailViewState extends State<DailyDetailView> {
  bool _isSaved = false;
  late TextEditingController _titleController;
  List<BudgetItem> _budgetList = [BudgetItem(label: '', targetAmount: 0)];
  DailyDetailModel? _currentEvent;
  
  final TextEditingController _dayController = TextEditingController(text: '1');
  final TextEditingController _weekController = TextEditingController(text: '1');
  final TextEditingController _monthController = TextEditingController(text: '1');
  final TextEditingController _yearController = TextEditingController(text: '1');

  String _selectedType = '';
  int _customValue = 1;
  bool _isAllDay = true;
  late DateTime _startDateTime;
  late DateTime _endDateTime;
  int _initialBudgetCount = 0;
  List<double> _originalAmounts = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    
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
       _budgetList = List<BudgetItem>.from(detail.budgetItems.map((e) => BudgetItem(
        label: e.label, 
        targetAmount: e.targetAmount,
        savedAmount: e.savedAmount,
      )));
       _initialBudgetCount = detail.budgetItems.length;
      _originalAmounts = detail.budgetItems.map((e) => e.targetAmount).toList();
      _isAllDay = detail.isAllDay;
      _startDateTime = detail.startTime;
      _endDateTime = detail.endTime;
      _isSaved = true;
      _currentEvent = detail;

      if (detail.savingStartDate != null) {
        final eventDay = DateTime(detail.startTime.year, detail.startTime.month, detail.startTime.day);
        final startDay = DateTime(detail.savingStartDate!.year, detail.savingStartDate!.month, detail.savingStartDate!.day);
        int diff = eventDay.difference(startDay).inDays;
        
        if (diff <= 0) {
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
    } else {
      _budgetList = [BudgetItem(label: '', targetAmount: 0)];
      if (_isAllDay) {
        _startDateTime = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
        _endDateTime = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
      }
    }
  }

  void _showCustomDatePicker(bool isStart) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
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
                    mode: _isAllDay 
                        ? CupertinoDatePickerMode.date 
                        : CupertinoDatePickerMode.time,
                    initialDateTime: isStart ? _startDateTime : _endDateTime,
                    minimumDate: isStart ? null : _startDateTime, 
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        if (isStart) {
                          _startDateTime = newDateTime;
                          if (_startDateTime.isAfter(_endDateTime) || 
                              _startDateTime.isAtSameMomentAs(_endDateTime)) {
                            _endDateTime = _startDateTime.add(const Duration(hours: 1));
                          }
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

  DateTime _calculateSavingStartDate() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final eventDate = DateTime(_startDateTime.year, _startDateTime.month, _startDateTime.day);
    
    if (_selectedType == 'today' || _selectedType.isEmpty) {
      return today;
    } else {
      int mult = _selectedType == 'year' ? 365 : (_selectedType == 'week' ? 7 : (_selectedType == 'month' ? 30 : 1));
      return eventDate.subtract(Duration(days: _customValue * mult));
    }
  }

  bool _isPlanInvalid(String type, int value) {
    if (value <= 0) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(_startDateTime.year, _startDateTime.month, _startDateTime.day);
    
    int mult = type == 'year' ? 365 : (type == 'week' ? 7 : (type == 'month' ? 30 : 1));
    final calculatedStart = eventDate.subtract(Duration(days: value * mult));
    
    return calculatedStart.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDayOnly = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
    final isLocked = selectedDayOnly.isBefore(today) || selectedDayOnly.isAtSameMomentAs(today);

    double totalBudget = _budgetList.fold(0.0, (sum, item) => sum + item.targetAmount);

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
            TextField(
              controller: _titleController,
              enabled: !isLocked,
              decoration: const InputDecoration(labelText: 'ชื่อกิจกรรม/เป้าหมาย', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text("ตลอดวัน"),
              value: _isAllDay,
              onChanged: isLocked ? null : (v) {
                setState(() {
                  _isAllDay = v;
                  if (_isAllDay) {
                    _startDateTime = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
                    _endDateTime = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
                  } else {
                    final now = DateTime.now();
                    _startDateTime = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day, now.hour + 1, 0);
                    _endDateTime = _startDateTime.add(const Duration(hours: 1));
                  }
                });
              },
            ),
            ListTile(
              title: const Text("เริ่ม"),
              trailing: Text(_isAllDay 
                  ? DateFormat('E d MMM yyyy', 'th_TH').format(_startDateTime)
                  : "${DateFormat('E d MMM yyyy', 'th_TH').format(_startDateTime)}  ${DateFormat('HH:mm').format(_startDateTime)}"),
              onTap: (isLocked || _isAllDay) ? null : () => _showCustomDatePicker(true),
            ),
            ListTile(
              title: const Text("ถึง"),
              trailing: Text(_isAllDay 
                  ? DateFormat('E d MMM yyyy', 'th_TH').format(_endDateTime)
                  : "${DateFormat('E d MMM yyyy', 'th_TH').format(_endDateTime)}  ${DateFormat('HH:mm').format(_endDateTime)}"),
              onTap: (isLocked || _isAllDay) ? null : () => _showCustomDatePicker(false),
            ),
            const SizedBox(height: 20),
            _buildBudgetSection(isLocked),
            
            if (totalBudget > 0 && !isLocked) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("แผนการออมเงิน", style: TextStyle(fontWeight: FontWeight.bold)),
                  if (widget.existingEvent != null && widget.existingEvent!.savingStartDate != null)
                    Text(
                      "ระยะเวลาออมทั้งหมด ${widget.existingEvent!.startTime.difference(widget.existingEvent!.savingStartDate!).inDays} วัน",
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                    )
                  else if (_startDateTime.isAfter(today))
                    Text(
                      "ระยะเวลาออม ${_startDateTime.difference(_calculateSavingStartDate()).inDays} วัน",
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                ],
              ),
              // ถ้ายังไม่เคยมีเป้าหมายการเงินจริงๆ (Target > 0) ให้เปิดให้วางแผนได้
              if (widget.existingEvent == null || 
                  widget.existingEvent!.budgetItems.every((item) => item.targetAmount == 0))
                Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text("ตั้งแต่วันนี้"),
                      value: 'today', 
                      groupValue: _selectedType,
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),
                    _buildPlanRadio("วัน", 'day', _dayController),
                    _buildPlanRadio("สัปดาห์", 'week', _weekController),
                    _buildPlanRadio("เดือน", 'month', _monthController),
                    _buildPlanRadio("ปี", 'year', _yearController),
                  ],
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  // child: Text("* แผนการออมถูกกำหนดแล้ว", 
                  //     style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                ),
            ],

            const SizedBox(height: 30),
            if (!isLocked)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity, 
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      child: const Text('บันทึก'),
                    ),
                  ),
                  if (_currentEvent != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _handleDelete,
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('ลบกิจกรรม'),
                      ),
                    ),
                  ],
                ],
              )
            else
              const Text("* วันนี้หรือย้อนหลังไม่สามารถลงกิจกรรมได้", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบกิจกรรมนี้?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('ลบ', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirmed == true && _currentEvent != null) {
      final vm = context.read<DailyDetailViewModel>();
      await vm.deleteEvent(_currentEvent!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่อกิจกรรม'), backgroundColor: Colors.red)
      );
      return;
    }

    final vm = context.read<DailyDetailViewModel>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final overlapError = vm.checkTimeOverlap(
      widget.selectedDay, 
      _startDateTime, 
      _endDateTime, 
      _isAllDay,
      excludeId: _currentEvent?.id
    );
    if (overlapError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(overlapError), backgroundColor: Colors.orange)
      );
      return;
    }

    final savingStart = _calculateSavingStartDate();
    if (savingStart.isBefore(today) && _currentEvent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('แผนการออมไม่สามารถเริ่มในอดีตได้ กรุณาปรับจำนวนวัน'), 
          backgroundColor: Colors.orange
        )
      );
      return;
    }
    
    final newEvent = DailyDetailModel(
      id: _currentEvent?.id ?? '',
      title: _titleController.text,
      budgetItems: _budgetList,
      isAllDay: _isAllDay,
      startTime: _startDateTime,
      endTime: _endDateTime,
      createdAt: _currentEvent?.createdAt ?? DateTime.now(),
      savingStartDate: savingStart,
    );

    await vm.addOrUpdateEvent(newEvent);

    // --- Schedule Notification if enabled ---
    final settingsVM = context.read<SettingsViewModel>();
    final notificationService = NotificationService();

    if (settingsVM.eventCountdownEnabled) {
      await notificationService.scheduleEventAlert(
        eventId: newEvent.id,
        eventTitle: newEvent.title,
        eventStartTime: newEvent.startTime,
        daysBefore: settingsVM.eventCountdownDays,
        hour: settingsVM.eventCountdownTime.hour,
        minute: settingsVM.eventCountdownTime.minute,
      );
    }

    if (settingsVM.eventReminderBeforeEnabled && !newEvent.isAllDay) {
      await notificationService.scheduleEventStartAlert(
        eventId: newEvent.id,
        eventTitle: newEvent.title,
        eventStartTime: newEvent.startTime,
        hoursBefore: settingsVM.eventReminderBeforeHours,
      );
    }

    // --- Schedule Immediate Saving Notification if starts today ---
    if (settingsVM.savingReminderEnabled && newEvent.savingStartDate != null && newEvent.totalBudget > 0) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startDate = newEvent.savingStartDate!;
      final savingStartDay = DateTime(startDate.year, startDate.month, startDate.day);
      
      if (savingStartDay.isAtSameMomentAs(today) || savingStartDay.isBefore(today)) {
        await notificationService.showImmediateSavingReminder();
      }
    }

    setState(() {
      _currentEvent = newEvent;
      _isSaved = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ'), backgroundColor: Colors.green)
      );
    }
  }

  Widget _buildPlanRadio(String label, String type, TextEditingController controller) {
    int value = int.tryParse(controller.text) ?? 1;
    bool isInvalid = _isPlanInvalid(type, value);
    bool isAlwaysInvalid = _isPlanInvalid(type, 1);

    return Opacity(
      opacity: isAlwaysInvalid ? 0.3 : (isInvalid ? 0.6 : 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RadioListTile<String>(
            value: type,
            groupValue: _selectedType,
            onChanged: (isAlwaysInvalid || isInvalid) ? null : (v) => setState(() {
              _selectedType = v!;
              _customValue = int.tryParse(controller.text) ?? 1;
            }),
            title: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: controller,
                    enabled: !isAlwaysInvalid,
                    decoration: const InputDecoration(isDense: true),
                    onChanged: (v) {
                      int newVal = int.tryParse(v) ?? 1;
                      if (newVal <= 0) {
                        controller.text = '1';
                        newVal = 1;
                      }
                      setState(() {
                        _customValue = newVal;
                        if (!_isPlanInvalid(type, _customValue)) {
                          _selectedType = type;
                        } else if (_selectedType == type) {
                          _selectedType = 'today';
                        }
                      });
                    },
                  ),
                ),
                Text(" $label ก่อนเริ่ม"),
              ],
            ),
          ),
          if (isAlwaysInvalid)
            const Padding(
              padding: EdgeInsets.only(left: 70),
              child: Text(
                "ระยะเวลาทริปสั้นเกินไปสำหรับแผนนี้",
                style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            )
          else if (isInvalid)
            const Padding(
              padding: EdgeInsets.only(left: 70),
              child: Text(
                "ย้อนอดีต! กรุณาลดตัวเลข",
                style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
        ],
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
          // ล็อคเฉพาะรายการที่ "เคย" มีมูลค่ามาก่อน (ดึงมาจาก DB แล้ว > 0)
          bool isItemLocked = (index < _originalAmounts.length && _originalAmounts[index] > 0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: TextEditingController(text: item.label)..selection = TextSelection.collapsed(offset: item.label.length),
                    enabled: !isLocked && !isItemLocked,
                    decoration: const InputDecoration(hintText: "เช่น ค่าข้าว", border: OutlineInputBorder()),
                    onChanged: (val) => item.label = val,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: TextEditingController(text: item.targetAmount == 0 ? '' : item.targetAmount.toInt().toString())..selection = TextSelection.collapsed(offset: (item.targetAmount == 0 ? '' : item.targetAmount.toInt().toString()).length),
                    enabled: !isLocked && !isItemLocked,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(hintText: "บาท", border: OutlineInputBorder()),
                    onChanged: (val) {
                      setState(() {
                        item.targetAmount = double.tryParse(val) ?? 0;
                        if (_selectedType.isEmpty && item.targetAmount > 0) {
                          _selectedType = 'today';
                        }
                      });
                    },
                  ),
                ),
                if (!isLocked)
                  IconButton(
                    icon: Icon(
                      isItemLocked ? Icons.lock : Icons.remove_circle,
                      color: isItemLocked ? Colors.grey : Colors.red,
                    ),
                    onPressed: isItemLocked ? null : () {
                      setState(() {
                        if (_budgetList.length > 1) {
                          _budgetList.removeAt(index);
                        } else {
                          // ถ้าเหลืออันสุดท้าย ให้ล้างข้อมูลแทนการลบ
                          _budgetList[index].label = '';
                          _budgetList[index].targetAmount = 0;
                        }
                      });
                    },
                  ),
              ],
            ),
          );
        }).toList(),
        if (!isLocked)
          TextButton.icon(
            onPressed: () => setState(() => _budgetList.add(BudgetItem(label: '', targetAmount: 0))),
            icon: const Icon(Icons.add),
            label: const Text("เพิ่มรายการ"),
          ),
        const Divider(),
        Text(
          "รวมงบประมาณ: ${_budgetList.fold(0.0, (sum, item) => sum + item.targetAmount).toInt()} บาท",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
        ),
      ],
    );
  }
}