import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';
import 'daily_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final dailyVM = Provider.of<DailyDetailViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Travel - ปฏิทิน'), backgroundColor: Colors.blueAccent),
      body: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        rowHeight: 85,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DailyDetailView(selectedDay: selectedDay)),
          );
        },
        calendarBuilders: CalendarBuilders(
          // 1. ช่องวันที่ในเดือนปัจจุบัน
          defaultBuilder: (context, day, focusedDay) => _buildCell(day, dailyVM),

          // 2. ช่องวันที่ "วันนี้"
          todayBuilder: (context, day, focusedDay) => _buildCell(day, dailyVM, isToday: true),

          // 3. ช่องวันที่ "ถูกเลือก"
          selectedBuilder: (context, day, focusedDay) => _buildCell(day, dailyVM, isSelected: true),

          // 4. ช่องวันที่ของ "เดือนอื่น" ที่โผล่มาในหน้านี้ (สำคัญมากสำหรับจุดที่คุณติด)
          outsideBuilder: (context, day, focusedDay) => _buildCell(day, dailyVM, isOutside: true),

          // 5. ช่องวันที่วันหยุด (ถ้ามี)
          holidayBuilder: (context, day, focusedDay) => _buildCell(day, dailyVM),
        ),
      ),
    );
  }

  Widget _buildCell(DateTime day, DailyDetailViewModel vm, {bool isToday = false, bool isSelected = false, bool isOutside = false}) {
    final detail = vm.getDetail(day);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
        color: isSelected
            ? Colors.blue.withOpacity(0.1)
            : (isToday ? Colors.orange.withOpacity(0.1) : null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isOutside ? Colors.grey : Colors.black87,
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
          if (detail != null) ...[
            // ส่วนแสดงชื่อกิจกรรม (Tag)
            if (detail.title.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(2),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isOutside ? Colors.blueAccent.withOpacity(0.5) : Colors.blueAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  detail.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),

            // ส่วนแสดงงบประมาณ Format: 0 / budget บาท
            if (detail.budget.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                child: Text(
                  '0 / ${detail.budget} บาท',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isOutside ? Colors.grey : Colors.green.shade700,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}