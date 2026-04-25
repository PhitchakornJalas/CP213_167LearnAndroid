import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';
import 'event_list_view.dart';
import 'settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // 1. เพิ่มตัวแปรสำหรับเก็บ Index ของเมนูที่เลือก
  int _selectedIndex = 0;

  // 2. ฟังก์ชันสำหรับจัดการการกดเปลี่ยนเมนู
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildCalendarPage(context), 
      const Center(child: Text("หน้าสรุปรายการ")), 
      const Center(child: Text("หน้าวิเคราะห์ผล")), 
      const SettingsView(), // เรียกใช้จากไฟล์แยก สะอาดตามาก!
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Plan Travel' : 'ตั้งค่า'),
        backgroundColor: Colors.blueAccent,
        actions: _selectedIndex == 0 ? [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _goToToday,
              child: const Text(
                'วันนี้',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ] : null,
      ),
      body: _selectedIndex == 0 
          ? SingleChildScrollView( // ครอบเฉพาะหน้าปฏิทิน
              child: Column(
                children: [
                  _buildCalendarPage(context),
                  // ถ้ามีข้อมูลอื่นๆ ใต้ปฏิทินก็ใส่ต่อตรงนี้ได้
                  const SizedBox(height: 20), 
                ],
              ),
            )
          : _pages[_selectedIndex], // หน้าอื่นๆ ให้แสดงปกติ
      
      // 3. เพิ่ม Bottom Navigation Bar (โครง Dummy 4 เมนู)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // บังคับให้โชว์ Label ทุกอัน
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'ปฏิทิน',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'รายการ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'สรุปผล',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'ตั้งค่า',
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarPage(BuildContext context) {
    final dailyVM = Provider.of<DailyDetailViewModel>(context);
    
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      rowHeight: 120,
      availableGestures: AvailableGestures.all, // ให้เลื่อนปฏิทินได้ปกติ
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventListView(selectedDay: selectedDay)),
        );
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) => _buildCell(day, dailyVM),
        todayBuilder: (context, day, focusedDay) => _buildCell(day, dailyVM, isToday: true),
        selectedBuilder: (context, day, focusedDay) => _buildCell(day, dailyVM, isSelected: true),
        outsideBuilder: (context, day, focusedDay) => _buildCell(day, dailyVM, isOutside: true),
        holidayBuilder: (context, day, focusedDay) => _buildCell(day, dailyVM),
      ),
    );
  }

  void _goToToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    });
  }

  Widget _buildCell(DateTime day, DailyDetailViewModel vm, {bool isToday = false, bool isSelected = false, bool isOutside = false}) {
    final events = vm.getEventsForDay(day);
    final totalSaving = vm.getTotalSavingAmount(day);

    // ภายใน _buildCell ของ HomeView
    String formatAmount(double amount) {
      // แสดงเป็นเลขจำนวนเต็มได้เลยเพราะเรา Ceil มาจาก ViewModel แล้ว
      return amount.toInt().toString();
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
        color: isSelected ? Colors.blue.withOpacity(0.1) : (isToday ? Colors.orange.withOpacity(0.1) : null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text('${day.day}', style: TextStyle(color: isOutside ? Colors.grey : Colors.black87, fontSize: 12)),
          ),

          // 1. แสดงยอดออม (ถ้ามีเศษจะโชว์ทศนิยม เช่น 2.5 ฿)
          if (totalSaving > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                'ออม: ${formatAmount(totalSaving)} ฿',
                style: TextStyle(color: Colors.orange.shade900, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),

          // ส่วนที่ให้ Overflow Scroll ได้ในแนวตั้ง
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(), // ช่วยให้เลื่อนลื่นขึ้น
              child: Column(
                children: [
                  for (var event in events) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      padding: const EdgeInsets.all(2),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isOutside ? Colors.blueAccent.withOpacity(0.5) : Colors.blueAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        event.title,
                        style: const TextStyle(color: Colors.white, fontSize: 8),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // แสดง 0 / budget ถ้ามีงบประมาณ
                    if (event.budget.isNotEmpty && (double.tryParse(event.budget) ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '0 / ${event.budget} บ.',
                            style: TextStyle(
                              color: Colors.green.shade700, 
                              fontSize: 8, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}