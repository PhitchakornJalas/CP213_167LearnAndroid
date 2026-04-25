import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';
import 'daily_detail_view.dart';

class EventListView extends StatelessWidget {
  final DateTime selectedDay;
  const EventListView({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DailyDetailViewModel>(context);
    final events = vm.getEventsForDay(selectedDay);
    final savings = vm.getSavingsBreakdownForDay(selectedDay);

    return Scaffold(
      appBar: AppBar(title: Text("วันที่ ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ส่วนแสดงรายการออม ---
            if (savings.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("รายการออมเงินวันนี้", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: savings.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = savings[index];
                    
                    // สร้างข้อความเวลา
                    String timeInfo = item['isAllDay'] 
                        ? "ทั้งวัน" 
                        : "${item['startTime'].hour}:00 - ${item['endTime'].hour}:00";

                    return ListTile(
                      leading: const Icon(Icons.savings, color: Colors.orange),
                      title: Text("ออมเพื่อ: ${item['title']}"),
                      // แก้ไข subtitle ให้โชว์วันที่เป้าหมาย + เวลา/ทั้งวัน
                      subtitle: Text("เป้าหมาย: ${item['targetDate'].day}/${item['targetDate'].month} ($timeInfo)"),
                      trailing: Text("${item['amount'].toInt()} ฿", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    );
                  },
                ),
              ),
            ],

            // --- ส่วนแสดงกิจกรรมที่จะเกิดขึ้นวันนี้ ---
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("กิจกรรมวันนี้", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ),
            if (events.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("ไม่มีกิจกรรมในวันนี้")))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final e = events[index];
                  return ListTile(
                    leading: Icon(e.isAllDay ? Icons.wb_sunny : Icons.access_time, color: Colors.blue),
                    title: Text(e.title),
                    subtitle: Text(e.isAllDay ? "ตลอดวัน" : "${e.startTime.hour}:00 - ${e.endTime.hour}:00"),
                    trailing: e.budget.isNotEmpty ? Text("${e.budget} ฿") : null,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DailyDetailView(selectedDay: selectedDay, existingEvent: e)
                    )),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // เช็คก่อนว่ามีกิจกรรม All Day ไหม
          final error = vm.checkTimeOverlap(selectedDay, DateTime.now(), DateTime.now(), true);
          if (error != null && events.isNotEmpty && events.any((e) => e.isAllDay)) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
          } else {
             Navigator.push(context, MaterialPageRoute(
               builder: (context) => DailyDetailView(selectedDay: selectedDay)
             ));
          }
        },
      ),
    );
  }
}
