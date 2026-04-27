import 'package:flutter/material.dart';
import '../models/daily_detail_model.dart';
import 'package:intl/intl.dart';

class DailyDetailInfoView extends StatelessWidget {
  final DailyDetailModel event;

  const DailyDetailInfoView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoTile("ชื่อกิจกรรม/เป้าหมาย", event.title, Icons.label_important_outline),
        const Divider(),
        _buildInfoTile(
          "ช่วงเวลา", 
          event.isAllDay 
              ? "${DateFormat('dd/MM/yyyy').format(event.startTime)} (ตลอดวัน)"
              : "${DateFormat('dd/MM/yyyy').format(event.startTime)}  ${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}", 
          Icons.calendar_today_outlined
        ),
        const Divider(),
        _buildBudgetInfo(),
      ],
    );
  }

  Widget _buildBudgetInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("รายละเอียดงบประมาณและการออม", style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 15),
        ...event.budgetItems.where((item) => item.targetAmount > 0).map((item) {
          double progress = item.targetAmount > 0 ? item.savedAmount / item.targetAmount : 0;
          if (progress > 1.0) progress = 1.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.label.isEmpty ? "ไม่ได้ระบุชื่อ" : item.label, 
                         style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    Text("${item.targetAmount.toInt()} ฿", 
                         style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          );
        }).toList(),
        const Divider(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("รวมยอดออมทั้งหมด", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("${event.totalSaved.toInt()} / ${event.totalBudget.toInt()} ฿", 
                 style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 5),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
