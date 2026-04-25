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
      eventLoader: (day) => dailyVM.getEventsForDay(day),
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
        markerBuilder: (context, date, events) => const SizedBox(),
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
    final totalSavingToday = vm.getTotalSavingAmount(day);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : (isToday ? Colors.orange.withOpacity(0.1) : null),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แทรกวันที่กลับมา (ปรับขนาดเล็กและชิดซ้ายบน)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 2),
            child: Text('${day.day}', style: TextStyle(color: isOutside ? Colors.grey : Colors.black87, fontSize: 11)),
          ),
          
          // 1. ยอดออมสีแดง (ดันให้ห่างจากตัวเลขวัน)
          if (totalSavingToday > 0)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'ออม: ${totalSavingToday.toInt()} บ.',
                style: const TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),

          const SizedBox(height: 2),

          // 2. ส่วนที่ Scroll ได้ (Tags + ยอดสะสม)
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false), // ซ่อนแถบ scroll ให้ดูคลีน
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final isEventDay = isSameDay(event.startTime, day);
                  final double budgetVal = double.tryParse(event.budget) ?? 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // แถบสีฟ้า (ชื่อกิจกรรม)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isOutside ? Colors.blue.shade300.withOpacity(0.5) : Colors.blue.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.title,
                          style: const TextStyle(fontSize: 9, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // ยอดสะสม (สีเขียว) - จะโชว์ติดกับ Tag ของตัวเองเพียงถ้ามีตั้งงบไว้
                      if (isEventDay && budgetVal > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 2, top: 1, bottom: 2),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${event.amountSaved.toInt()} / ${budgetVal.toInt()} บ.',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}