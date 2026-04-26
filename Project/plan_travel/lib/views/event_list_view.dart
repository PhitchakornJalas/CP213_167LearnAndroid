import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';
import '../models/daily_detail_model.dart';
import 'daily_detail_view.dart';
import 'qr_payment_view.dart';

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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text("รายการออมเงินวันนี้", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: savings.length,
                itemBuilder: (context, index) {
                  final item = savings[index];
                  final eventId = item['id'];
                  
                  String timeInfo = item['isAllDay'] 
                      ? "ทั้งวัน" 
                      : "${item['startTime'].hour}:00 - ${item['endTime'].hour}:00";

                  final bool isSavedToday = vm.isEventSavedToday(selectedDay, eventId);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        final eventModel = DailyDetailModel(
                          id: item['id'],
                          title: item['title'],
                          budget: item['budget'].toString(),
                          isAllDay: item['isAllDay'],
                          startTime: item['startTime'],
                          endTime: item['endTime'],
                          amountSaved: item['amountSaved'] ?? 0.0,
                          savingStartDate: item['savingStartDate'],
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DailyDetailView(
                              selectedDay: item['targetDate'], 
                              existingEvent: eventModel,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                const Icon(Icons.savings, color: Colors.orange, size: 35),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("ออมเพื่อ: ${item['title']}", 
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text("เป้าหมาย: ${item['targetDate'].day}/${item['targetDate'].month} ($timeInfo)",
                                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("${item['amount'].toInt()} ฿", 
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: isSavedToday 
                                          ? null 
                                          : () async {
                                              await vm.loadBankInfo(); 
                                              if (vm.savedPromptPay.isEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text("กรุณาตั้งค่าบัญชีธนาคารก่อนออมเงิน"))
                                                );
                                                return;
                                              }
                                              Navigator.push(context, MaterialPageRoute(
                                                builder: (context) => QRPaymentView(
                                                  eventId: item['id'],
                                                  amount: item['amount'],
                                                  title: "ออมเพื่อ ${item['title']}",
                                                  promptPayId: vm.savedPromptPay,
                                                  accountName: vm.savedAlias,
                                                  currentDay: selectedDay,
                                                  useSlipVerification: false,
                                                )
                                              ));
                                            }, 
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isSavedToday ? Colors.grey.shade300 : Colors.orange.shade100,
                                        foregroundColor: isSavedToday ? Colors.grey : Colors.orange.shade900,
                                        elevation: isSavedToday ? 0 : 2,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: Text(isSavedToday ? "ออมแล้ว" : "ออมเลย"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
