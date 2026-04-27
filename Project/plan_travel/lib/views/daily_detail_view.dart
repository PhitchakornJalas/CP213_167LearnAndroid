import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';
import '../models/daily_detail_model.dart';
import 'daily_detail_info_view.dart';

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
  
  // Controllers สำหรับแผนการออม
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
      _isAllDay = detail.isAllDay;
      _startDateTime = detail.startTime;
      _endDateTime = detail.endTime;
      _isSaved = true;
      _currentEvent = detail;

      if (detail.savingStartDate != null) {
        final eventDay = DateTime(detail.startTime.year, detail.startTime.month, detail.startTime.day);
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
                        : CupertinoDatePickerMode.dateAndTime,
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
    
    if (_selectedType == 'today') {
      return today;
    } else if (_selectedType.isEmpty) {
      return today;
    } else {
      int mult = _selectedType == 'year' ? 365 : (_selectedType == 'week' ? 7 : (_selectedType == 'month' ? 30 : 1));
      return eventDate.subtract(Duration(days: _customValue * mult));
    }
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
            _buildBudgetSection(isLocked),
            
            if (totalBudget > 0 && !isLocked) ...[
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft, 
                child: Text("แผนการออมเงิน", style: TextStyle(fontWeight: FontWeight.bold))
              ),
              RadioListTile<String>(
                title: const Text("ตั้งแต่วันนี้"),
                value: 'today', 
                groupValue: _selectedType,
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              _buildPlanRadio("วัน", 'day', 1, _dayController),
              _buildPlanRadio("สัปดาห์", 'week', 7, _weekController),
              _buildPlanRadio("เดือน", 'month', 30, _monthController),
              _buildPlanRadio("ปี", 'year', 365, _yearController),
            ],

            const SizedBox(height: 30),
            if (!isLocked)
              SizedBox(
                width: double.infinity, 
                child: ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('บันทึกลง Cloud'),
                ),
              )
            else
              const Text("* วันนี้หรือย้อนหลังไม่สามารถลงกิจกรรมได้", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่อกิจกรรม'), backgroundColor: Colors.red)
      );
      return;
    }

    final vm = context.read<DailyDetailViewModel>();
    
    final newEvent = DailyDetailModel(
      id: _currentEvent?.id ?? '',
      title: _titleController.text,
      budgetItems: _budgetList,
      isAllDay: _isAllDay,
      startTime: _startDateTime,
      endTime: _endDateTime,
      createdAt: _currentEvent?.createdAt ?? DateTime.now(),
      savingStartDate: _calculateSavingStartDate(),
    );

    await vm.addOrUpdateEvent(newEvent);

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

  Widget _buildPlanRadio(String label, String type, int multiplier, TextEditingController controller) {
    return RadioListTile<String>(
      value: type,
      groupValue: _selectedType,
      onChanged: (v) => setState(() {
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
              decoration: const InputDecoration(isDense: true),
              onChanged: (v) {
                setState(() {
                  _customValue = int.tryParse(v) ?? 1;
                  _selectedType = type;
                });
              },
            ),
          ),
          Text(" $label ก่อนเริ่ม"),
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
                    controller: TextEditingController(text: item.targetAmount == 0 ? '' : item.targetAmount.toInt().toString())..selection = TextSelection.collapsed(offset: (item.targetAmount == 0 ? '' : item.targetAmount.toInt().toString()).length),
                    enabled: !isLocked,
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