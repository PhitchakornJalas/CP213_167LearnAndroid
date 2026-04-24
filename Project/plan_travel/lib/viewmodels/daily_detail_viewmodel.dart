import 'package:flutter/material.dart';
import '../models/daily_detail_model.dart';

class DailyDetailViewModel extends ChangeNotifier {
  final Map<DateTime, DailyDetailModel> _dailyDetails = {};
  Map<DateTime, DailyDetailModel> get dailyDetails => _dailyDetails;

  DailyDetailModel? getDetail(DateTime date) {
    return _dailyDetails[DateTime(date.year, date.month, date.day)];
  }

  double getTotalSavingAmount(DateTime date) {
    double total = 0;
    // ปรับวันที่บนปฏิทินให้เป็น 00:00:00
    final calendarDay = DateTime(date.year, date.month, date.day);

    _dailyDetails.forEach((targetDate, detail) {
      if (detail.savingStartDate != null && detail.budget.isNotEmpty) {
        // วันเริ่มออม และวันงาน (ต้องเป็น 00:00:00 ทั้งคู่)
        final start = DateTime(detail.savingStartDate!.year, detail.savingStartDate!.month, detail.savingStartDate!.day);
        final endEvent = DateTime(targetDate.year, targetDate.month, targetDate.day);

        // เงื่อนไข: วันที่บนปฏิทินต้อง >= วันเริ่มออม และ < วันงาน
        if ((calendarDay.isAtSameMomentAs(start) || calendarDay.isAfter(start)) &&
            calendarDay.isBefore(endEvent)) {
          
          double budgetVal = double.tryParse(detail.budget) ?? 0;
          // คำนวณจำนวนวันออม (เช่น 26 - 24 = 2 วัน)
          int totalSavingDays = endEvent.difference(start).inDays;
          
          if (totalSavingDays > 0) {
            total += budgetVal / totalSavingDays;
          }
        }
      }
    });
    return total;
  }

  void updateDailyDetail(DateTime date, String title, String budget, DateTime? savingStart) {
    _dailyDetails[DateTime(date.year, date.month, date.day)] = 
        DailyDetailModel(title: title, budget: budget, savingStartDate: savingStart);
    notifyListeners();
  }
}