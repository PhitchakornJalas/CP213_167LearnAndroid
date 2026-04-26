import 'package:flutter/material.dart';
import '../models/daily_detail_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyDetailViewModel extends ChangeNotifier {
  // เปลี่ยนเป็น List เพื่อให้ 1 วันมีหลาย Event
  final Map<DateTime, List<DailyDetailModel>> _dailyDetails = {};
  Map<DateTime, List<DailyDetailModel>> get dailyDetails => _dailyDetails;

  // เก็บประวัติ: วันไหน (DateTime) กิจกรรมไหน (String ID) ออมไปเท่าไหร่แล้ว
  Map<DateTime, Map<String, double>> _dailySavingsRecords = {};

  String savedPromptPay = "";
  String savedAlias = "";

  Future<void> loadBankInfo() async {
    final prefs = await SharedPreferences.getInstance();
    savedPromptPay = prefs.getString('promptpay_id') ?? "";
    savedAlias = prefs.getString('bank_alias') ?? "";
    notifyListeners();
  }

  // โชว์ทั้งหมดกลับมา
  List<DailyDetailModel> getEventsForDay(DateTime date) {
    final dayOnly = DateTime(date.year, date.month, date.day);
    final events = _dailyDetails[dayOnly] ?? [];
    
    final allEvents = List<DailyDetailModel>.from(events);
    allEvents.sort((a, b) {
      if (a.isAllDay) return -1;
      if (b.isAllDay) return 1;
      return a.startTime.compareTo(b.startTime);
    });
    return allEvents;
  }

  // โชว์เฉพาะอันที่ "ยังไม่ออมแบบเต็ม" บนปฏิทิน
  List<DailyDetailModel> getPendingEvents(DateTime day) {
    final dayOnly = DateTime(day.year, day.month, day.day);
    final events = _dailyDetails[dayOnly] ?? [];
    
    final incompleteEvents = events.where((e) {
      double budgetVal = double.tryParse(e.budget) ?? 0;
      return e.amountSaved < budgetVal;
    }).toList();

    incompleteEvents.sort((a, b) {
      if (a.isAllDay) return -1;
      if (b.isAllDay) return 1;
      return a.startTime.compareTo(b.startTime);
    });
    return incompleteEvents;
  }

  void confirmSaving(DateTime currentDay, String eventId, double amount) {
    final day = DateTime(currentDay.year, currentDay.month, currentDay.day);
    
    // 1. บันทึกว่าวันนี้กิจกรรมนี้ออมแล้ว
    if (!_dailySavingsRecords.containsKey(day)) _dailySavingsRecords[day] = {};
    _dailySavingsRecords[day]![eventId] = amount;

    // 2. อัปเดตยอดสะสมรวมของ Event นั้นๆ
    for (var list in _dailyDetails.values) {
      for (var event in list) {
        if (event.id == eventId) {
          event.amountSaved += amount;
        }
      }
    }
    notifyListeners();
  }

  bool isEventSavedToday(DateTime date, String eventId) {
    final day = DateTime(date.year, date.month, date.day);
    return _dailySavingsRecords[day]?.containsKey(eventId) ?? false;
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
        if (detail.savingStartDate == null || detail.budget.isEmpty) continue;

        final start = DateTime(detail.savingStartDate!.year, detail.savingStartDate!.month, detail.savingStartDate!.day);
        final eventDay = DateTime(targetDate.year, targetDate.month, targetDate.day);

        if ((calendarDay.isAtSameMomentAs(start) || calendarDay.isAfter(start)) && calendarDay.isBefore(eventDay)) {
          double budgetVal = double.tryParse(detail.budget) ?? 0;
          int totalDays = eventDay.difference(start).inDays;
          
          if (totalDays > 0) {
            double dailyAmount = (budgetVal / totalDays).ceilToDouble();
            // หักลบยอดที่กดออมไปแล้วในวันนี้
            double alreadySavedToday = _dailySavingsRecords[calendarDay]?[detail.id] ?? 0;
            total += (dailyAmount - alreadySavedToday);
          }
        }
      }
    });
    return total > 0 ? total : 0;
  }

  List<Map<String, dynamic>> getSavingsBreakdownForDay(DateTime date) {
    List<Map<String, dynamic>> breakdown = [];
    final calendarDay = DateTime(date.year, date.month, date.day);

    _dailyDetails.forEach((targetDate, events) {
      for (var detail in events) {
        if (detail.savingStartDate != null && detail.budget.isNotEmpty) {
          final start = DateTime(detail.savingStartDate!.year, detail.savingStartDate!.month, detail.savingStartDate!.day);
          final eventDay = DateTime(targetDate.year, targetDate.month, targetDate.day);

          // ตรวจสอบว่าเป็นช่วงวันที่ต้องออมของกิจกรรมนี้หรือไม่
          if ((calendarDay.isAtSameMomentAs(start) || calendarDay.isAfter(start)) &&
              calendarDay.isBefore(eventDay)) {
            
            double budgetVal = double.tryParse(detail.budget) ?? 0;
            int totalSavingDays = eventDay.difference(start).inDays;
            
            if (totalSavingDays > 0) {
              // ปัดเศษขึ้นตามที่ตกลงกันไว้
              double amountPerEvent = (budgetVal / totalSavingDays).ceilToDouble();
              
              breakdown.add({
                'id': detail.id,
                'title': detail.title,
                'amount': amountPerEvent,
                'targetDate': targetDate, // วันที่จะจัดกิจกรรมนี้
                'isAllDay': detail.isAllDay, 
                'startTime': detail.startTime, 
                'endTime': detail.endTime, 
                'amountSaved': detail.amountSaved,
                'budget': double.tryParse(detail.budget) ?? 0,
                'savingStartDate': detail.savingStartDate,
              });
            }
          }
        }
      }
    });
    return breakdown;
  }
}