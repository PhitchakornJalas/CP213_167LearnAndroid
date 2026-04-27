import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';
import '../models/daily_detail_model.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'daily_detail_view.dart';
import 'qr_payment_view.dart';

class EventListView extends StatelessWidget {
  final DateTime selectedDay;
  const EventListView({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DailyDetailViewModel>(context);
    final profileVM = Provider.of<ProfileViewModel>(context);
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
                  final DailyDetailModel event = item['event'];
                  
                  String timeInfo = event.isAllDay 
                      ? "ทั้งวัน" 
                      : "${event.startTime.hour}:00 - ${event.endTime.hour}:00";

                  // เช็คว่าวันนี้ออมไปหรือยัง (ใน Firestore เราจะดูจากยอดรวมออม หรือเก็บประวัติแยกก็ได้)
                  // เบื้องต้นให้กดออมได้เรื่อยๆ จนกว่าจะครบยอด
                  bool isFull = event.totalSaved >= event.totalBudget;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (context) => DailyDetailView(selectedDay: event.startTime, existingEvent: event)
                        )),
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
                                      Text("ออมเพื่อ: ${event.title}", 
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text("เป้าหมาย: ${event.startTime.day}/${event.startTime.month} ($timeInfo)",
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
                                      onPressed: isFull 
                                          ? null 
                                          : () {
                                              if (profileVM.profile?.promptPay == null || profileVM.profile!.promptPay!.isEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text("กรุณาตั้งค่าบัญชีธนาคารในหน้า Profile ก่อนครับ"))
                                                );
                                                return;
                                              }
                                              Navigator.push(context, MaterialPageRoute(
                                                builder: (context) => QRPaymentView(
                                                  eventId: event.id,
                                                  amount: item['amount'],
                                                  title: "ออมเพื่อ ${event.title}",
                                                  promptPayId: profileVM.profile!.promptPay!,
                                                  accountName: profileVM.profile!.accountName ?? "ออมเงิน",
                                                  currentDay: selectedDay,
                                                  useSlipVerification: false,
                                                )
                                              ));
                                            }, 
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isFull ? Colors.grey.shade300 : Colors.orange.shade100,
                                        foregroundColor: isFull ? Colors.grey : Colors.orange.shade900,
                                        elevation: isFull ? 0 : 2,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: Text(isFull ? "ครบแล้ว" : "ออมเลย"),
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
                    trailing: e.totalBudget > 0 ? Text("${e.totalBudget.toInt()} ฿") : null,
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
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => DailyDetailView(selectedDay: selectedDay)
          ));
        },
      ),
    );
  }
}
