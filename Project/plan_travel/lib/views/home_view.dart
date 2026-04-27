import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/cupertino.dart';
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
  final GlobalKey _titleKey = GlobalKey(); // เพิ่ม Key สำหรับหาตำแหน่ง
  
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
        titleSpacing: 10,
        centerTitle: false,
        title: _selectedIndex == 0 
          ? InkWell(
              key: _titleKey, // ใส่ Key ตรงนี้ครับ
              onTap: () => _showMonthPicker(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getMonthName(_focusedDay.month) + " ${_focusedDay.year}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.black),
                ],
              ),
            )
          : const Text('ตั้งค่า', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: _selectedIndex == 0 ? [
          IconButton(
            icon: const Icon(Icons.today, color: Colors.blueAccent),
            onPressed: _goToToday,
            tooltip: "วันนี้",
          ),
          const SizedBox(width: 8),
        ] : null,
      ),
      body: _selectedIndex == 0 
          ? Column( // ใช้ Column เพื่อให้ Expanded ทำงานได้
              children: [
                Expanded(
                  child: _buildCalendarPage(context),
                ),
                const SizedBox(height: 10), 
              ],
            )
          : _pages[_selectedIndex],
      
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
      locale: 'th_TH',
      shouldFillViewport: true, // ทำให้ปฏิทินขยายเต็มพื้นที่
      daysOfWeekHeight: 50, // เพิ่มความสูงให้แถบชื่อวันเพื่อเว้นระยะจากขอบบน
      eventLoader: (day) => dailyVM.getEventsForDay(day),
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableGestures: AvailableGestures.all, 
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      headerVisible: false,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        dowTextFormatter: (date, locale) {
          return ["อา.", "จ.", "อ.", "พ.", "พฤ.", "ศ.", "ส."][date.weekday % 7];
        },
        weekdayStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.normal),
        weekendStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.normal),
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
      onPageChanged: (focusedDay) {
        // อัปเดตหัวข้อเดือน ปี เมื่อมีการปัดเปลี่ยนหน้าปฏิทิน
        setState(() {
          _focusedDay = focusedDay;
        });
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

  String _getMonthName(int month) {
    return [
      "มกราคม", "กุมภาพันธ์", "มีนาคม", "เมษายน", "พฤษภาคม", "มิถุนายน",
      "กรกฎาคม", "สิงหาคม", "กันยายน", "ตุลาคม", "พฤศจิกายน", "ธันวาคม"
    ][month - 1];
  }

  void _showMonthPicker(BuildContext context) {
    final RenderBox renderBox = _titleKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    // ใช้ตัวแปรชั่วคราวสำหรับเก็บค่าที่กำลังเลื่อน
    int tempMonth = _focusedDay.month;
    int tempYear = _focusedDay.year;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.transparent,
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder( // ใช้ StatefulBuilder เพื่อให้ UI ใน Popup อัปเดตลื่นไหล
          builder: (context, setPopupState) {
            return Stack(
              children: [
                Positioned(
                  top: offset.dy + renderBox.size.height,
                  left: offset.dx,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 320,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              height: 48,
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: CupertinoPicker(
                                    scrollController: FixedExtentScrollController(initialItem: tempMonth - 1),
                                    itemExtent: 48,
                                    selectionOverlay: const SizedBox(),
                                    onSelectedItemChanged: (index) {
                                      setPopupState(() => tempMonth = index + 1);
                                      setState(() {
                                        _focusedDay = DateTime(_focusedDay.year, tempMonth, 1);
                                      });
                                    },
                                    children: List.generate(12, (index) {
                                      bool isSelected = (index + 1) == tempMonth;
                                      return Center(
                                        child: Text(
                                          _getMonthName(index + 1),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected ? Colors.black : Colors.grey.shade400,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: CupertinoPicker(
                                    scrollController: FixedExtentScrollController(initialItem: tempYear - 2020),
                                    itemExtent: 48,
                                    selectionOverlay: const SizedBox(),
                                    onSelectedItemChanged: (index) {
                                      setPopupState(() => tempYear = 2020 + index);
                                      setState(() {
                                        _focusedDay = DateTime(tempYear, _focusedDay.month, 1);
                                      });
                                    },
                                    children: List.generate(31, (index) {
                                      bool isSelected = (2020 + index) == tempYear;
                                      return Center(
                                        child: Text(
                                          "${2020 + index}",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected ? Colors.black : Colors.grey.shade400,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        );
      },
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
        color: isSelected ? Colors.grey.shade100 : null, // ลงสีเทาจางๆ เต็มช่อง
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ส่วนตัวเลขวันที่ (ชิดบน ตรงกลาง พร้อมไฮไลท์วงกลมเฉพาะ "วันนี้")
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: isToday 
              ? const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                )
              : null,
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isToday 
                  ? Colors.white 
                  : (isOutside ? Colors.grey : Colors.black87),
                fontSize: 13,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
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
                  final double budgetVal = event.totalBudget;

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
                              '${event.totalSaved.toInt()} / ${budgetVal.toInt()} บ.',
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