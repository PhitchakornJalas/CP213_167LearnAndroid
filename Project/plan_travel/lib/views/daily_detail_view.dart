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

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<DailyDetailViewModel>(context, listen: false);
    final detail = vm.getDetail(widget.selectedDay);
    _titleController = TextEditingController(text: detail?.title ?? '');
    _budgetController = TextEditingController(text: detail?.budget ?? '');
  }

  @override
  Widget build(BuildContext context) {
    // --- ส่วนที่เพิ่มเพื่อเช็คว่าเป็นวันย้อนหลังหรือไม่ ---
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectDayOnly = DateTime(widget.selectedDay.year, widget.selectedDay.month, widget.selectedDay.day);
    final isPast = selectDayOnly.isBefore(today);
    // -------------------------------------------

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดรายวัน')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "วันที่เลือก: ${widget.selectedDay.toString().split(' ')[0]}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              enabled: !isPast, // ถ้าเป็นอดีต ห้ามพิมพ์เพิ่ม
              decoration: const InputDecoration(
                  labelText: 'ชื่อกิจกรรม/เป้าหมาย',
                  border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _budgetController,
              enabled: !isPast, // ถ้าเป็นอดีต ห้ามพิมพ์เพิ่ม
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: 'งบประมาณที่วางไว้',
                  border: OutlineInputBorder(),
                  suffixText: 'บาท'
              ),
            ),
            const SizedBox(height: 30),
            // แสดงปุ่มบันทึกเฉพาะวันที่ไม่ใช่ย้อนหลัง
            if (!isPast)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<DailyDetailViewModel>().updateDailyDetail(
                        widget.selectedDay,
                        _titleController.text,
                        _budgetController.text
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('บันทึกรายละเอียด'),
                ),
              ),
            // ถ้าเป็นวันย้อนหลัง อาจจะแสดงข้อความบอก User นิดหน่อย (เลือกใส่หรือไม่ใส่ก็ได้)
            if (isPast)
              const Text(
                "* ไม่สามารถแก้ไขข้อมูลย้อนหลังได้",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}