import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';
import '../models/daily_detail_model.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'daily_detail_view.dart';
import 'qr_payment_view.dart';
import 'package:intl/intl.dart';

class EventListView extends StatelessWidget {
  final DateTime selectedDay;
  const EventListView({super.key, required this.selectedDay});

  String _formatThaiDate(DateTime date) {
    String weekday = DateFormat('EEEE', 'th_TH').format(date);
    String day = date.day.toString();
    String month = DateFormat('MMMM', 'th_TH').format(date);
    String year = date.year.toString();
    return "$weekday $day $month $year";
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DailyDetailViewModel>(context);
    final profileVM = Provider.of<ProfileViewModel>(context);
    final events = vm.getEventsForDay(selectedDay);
    final savings = vm.getSavingsBreakdownForDay(selectedDay);

    return Scaffold(
      appBar: AppBar(title: Text(_formatThaiDate(selectedDay))),
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
                      ? "ตลอดวัน" 
                      : "${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}";

                  // เช็คสถานะการออมจาก ViewModel
                  bool isPaid = item['isPaid'] ?? false;
                  bool isFull = item['isFull'] ?? false;

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
                                Icon(Icons.savings, color: isPaid ? Colors.green : Colors.orange, size: 35),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // ชื่อกิจกรรม
                                      Text("ออมเพื่อ: ${event.title}", 
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      // วันที่เป้าหมาย
                                      Text(
                                        "เป้าหมาย: ${DateFormat('d MMMM yyyy', 'th_TH').format(event.startTime)}",
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                      const SizedBox(height: 2),
                                      // ช่วงเวลา
                                      Text(
                                        "ช่วงเวลา: $timeInfo",
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("${item['amount'].toInt()} ฿", 
                                        style: TextStyle(
                                          fontSize: 18, 
                                          fontWeight: FontWeight.bold,
                                          color: isPaid ? Colors.green : Colors.black,
                                        )),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: (isPaid || isFull) 
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
                                                  savingBreakdown: [item],
                                                  totalAmount: item['amount'],
                                                  promptPayId: profileVM.profile!.promptPay!,
                                                  accountName: profileVM.profile!.accountName ?? "ออมเงิน",
                                                  targetDate: selectedDay,
                                                  useSlipVerification: true,
                                                )
                                              ));
                                            }, 
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: (isPaid || isFull) ? Colors.green.shade100 : Colors.orange.shade100,
                                        foregroundColor: (isPaid || isFull) ? Colors.green.shade900 : Colors.orange.shade900,
                                        elevation: (isPaid || isFull) ? 0 : 2,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: Text(isFull ? "ครบแล้ว" : (isPaid ? "ออมแล้ว" : "ออมเลย")),
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
