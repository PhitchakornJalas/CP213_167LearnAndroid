import 'package:flutter/material.dart';
import '../models/daily_detail_model.dart';

class DailyDetailViewModel extends ChangeNotifier {
  // เปลี่ยนเป็น List เพื่อให้ 1 วันมีหลาย Event
  final Map<DateTime, List<DailyDetailModel>> _dailyDetails = {};
  Map<DateTime, List<DailyDetailModel>> get dailyDetails => _dailyDetails;

  List<DailyDetailModel> getEventsForDay(DateTime date) {
    final dayOnly = DateTime(date.year, date.month, date.day);
    final events = _dailyDetails[dayOnly] ?? [];
    // เรียงลำดับจากเช้าไปเย็น (All Day ขึ้นก่อน)
    events.sort((a, b) {
      if (a.isAllDay) return -1;
      if (b.isAllDay) return 1;
      return a.startTime.compareTo(b.startTime);
    });
    return events;
  }

  // เช็คว่าเวลาทับกันหรือไม่
  String? checkTimeOverlap(DateTime date, DateTime start, DateTime end, bool isAllDay, {String? excludeId}) {
    final events = getEventsForDay(date);
    
    for (var event in events) {
      if (event.id == excludeId) continue;
      
      // ถ้ามีกิจกรรม "ตลอดวัน" อยู่แล้ว หรือกำลังจะเพิ่ม "ตลอดวัน"
      if (event.isAllDay || isAllDay) return "ไม่สามารถเพิ่มกิจกรรมได้เนื่องจากมีกิจกรรมตลอดวันครอบคลุมอยู่";

      // เช็คช่วงเวลาทับกัน
      if (start.isBefore(event.endTime) && end.isAfter(event.startTime)) {
        return "ช่วงเวลาทับกับกิจกรรม: ${event.title}";
      }
    }
    return null;
  }

  void addOrUpdateEvent(DateTime date, DailyDetailModel newEvent) {
    final dayOnly = DateTime(date.year, date.month, date.day);
    if (!_dailyDetails.containsKey(dayOnly)) _dailyDetails[dayOnly] = [];
    
    final index = _dailyDetails[dayOnly]!.indexWhere((e) => e.id == newEvent.id);
    if (index != -1) {
      _dailyDetails[dayOnly]![index] = newEvent;
    } else {
      _dailyDetails[dayOnly]!.add(newEvent);
    }
    notifyListeners();
  }

  // คำนวณยอดออมรวม (วนลูปทุก Event ในทุกวัน)
  double getTotalSavingAmount(DateTime date) {
    double total = 0;
    final calendarDay = DateTime(date.year, date.month, date.day);

    _dailyDetails.forEach((targetDate, events) {
      for (var detail in events) {
        if (detail.savingStartDate != null && detail.budget.isNotEmpty) {
          final start = DateTime(detail.savingStartDate!.year, detail.savingStartDate!.month, detail.savingStartDate!.day);
          if ((calendarDay.isAtSameMomentAs(start) || calendarDay.isAfter(start)) && calendarDay.isBefore(targetDate)) {
            double budgetVal = double.tryParse(detail.budget) ?? 0;
            int totalDays = targetDate.difference(start).inDays;
            if (totalDays > 0) total += budgetVal / totalDays;
          }
        }
      }
    });
    return total;
  }
}