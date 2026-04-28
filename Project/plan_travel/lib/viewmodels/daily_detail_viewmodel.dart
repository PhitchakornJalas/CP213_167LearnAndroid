import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_detail_model.dart';
import '../services/firebase_service.dart';

class DailyDetailViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService;
  List<DailyDetailModel> _allEvents = [];
  StreamSubscription? _eventsSubscription;
  StreamSubscription? _authSubscription;

  DailyDetailViewModel(this._firebaseService) {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listenToEvents(user.uid);
      } else {
        _eventsSubscription?.cancel();
        _allEvents = [];
        notifyListeners();
      }
    });
  }

  void _listenToEvents(String uid) {
    _eventsSubscription?.cancel();
    _eventsSubscription = _firebaseService.getEventsStream(uid).listen((events) {
      _allEvents = events;
      notifyListeners();
    });
  }

  List<DailyDetailModel> get allEvents => _allEvents;

  Future<String> addOrUpdateEvent(DailyDetailModel event) async {
    return await _firebaseService.saveEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _firebaseService.deleteEvent(eventId);
  }

  List<DailyDetailModel> getEventsForDay(DateTime date) {
    return _allEvents.where((e) => _isSameDay(e.startTime, date)).toList()
      ..sort((a, b) {
        if (a.isAllDay) return -1;
        if (b.isAllDay) return 1;
        return a.startTime.compareTo(b.startTime);
      });
  }

  String? checkTimeOverlap(DateTime date, DateTime start, DateTime end, bool isAllDay, {String? excludeId}) {
    final events = getEventsForDay(date);
    for (var event in events) {
      if (event.id == excludeId) continue;
      if (event.isAllDay || isAllDay) return "ไม่สามารถเพิ่มกิจกรรมได้เนื่องจากมีกิจกรรมตลอดวันครอบคลุมอยู่";
      if (start.isBefore(event.endTime) && end.isAfter(event.startTime)) {
        return "ช่วงเวลาทับกับกิจกรรม: ${event.title}";
      }
    }
    return null;
  }

  List<Map<String, dynamic>> getSavingsBreakdownForDay(DateTime date) {
    List<Map<String, dynamic>> breakdown = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final calendarDay = DateTime(date.year, date.month, date.day);

    for (var event in _allEvents) {
      if (event.totalBudget <= 0) continue;

      final effectiveStart = event.savingStartDate ?? event.createdAt;
      final start = DateTime(effectiveStart.year, effectiveStart.month, effectiveStart.day);
      final eventDay = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);

      if ((calendarDay.isAtSameMomentAs(start) || calendarDay.isAfter(start)) && 
          calendarDay.isBefore(eventDay)) {
        
        int totalDaysInPlan = eventDay.difference(start).inDays;
        if (totalDaysInPlan <= 0) continue;

        // --- 1. ใช้ยอดออมที่บันทึกไว้ใน Model (Daily Target) ---
        // จะไม่คำนวณใหม่ทุกวัน เพื่อป้องกันยอดออมลดลงเรื่อยๆ จากเศษที่ปัดขึ้น
        double amountToShow = event.dailyTarget > 0 ? event.dailyTarget : (event.totalBudget / totalDaysInPlan).ceilToDouble();

        // ยอดฐาน (ใช้สำหรับเช็คยอดสะสมเพื่อล็อคลำดับ)
        double baseAmountPerDay = (event.totalBudget / totalDaysInPlan).ceilToDouble();

        // --- 2. เช็คสถานะการจ่าย (Smart Historical Target) ---
        int remainingDaysFromToday = eventDay.difference(today).inDays;
        if (remainingDaysFromToday < 1) remainingDaysFromToday = 1;
        int daysPassedBeforeToday = totalDaysInPlan - remainingDaysFromToday;

        // คำนวณหา "ยอดออมต่อวันในอดีต" (ก่อนที่จะมีการแก้ Budget ล่าสุด)
        double historicalAmountPerDay = daysPassedBeforeToday > 0 
            ? (event.totalBudget - (amountToShow * remainingDaysFromToday)) / daysPassedBeforeToday
            : amountToShow;

        double targetCumulativeAtDate;
        int daysToCalendarDay = calendarDay.difference(start).inDays + 1;

        if (calendarDay.isBefore(today)) {
          // ถ้าเป็นวันในอดีต: ใช้ยอดออมเดิมคำนวณเป้าสะสม
          targetCumulativeAtDate = (historicalAmountPerDay * daysToCalendarDay).clamp(0.0, event.totalBudget);
        } else {
          // ถ้าเป็นวันนี้หรืออนาคต: ใช้ (ยอดออมในอดีตทั้งหมด) + (ยอดออมใหม่วันนี้ * จำนวนวันที่ผ่านมาจากวันนี้)
          int daysFromTodayToCalendarDay = calendarDay.difference(today).inDays + 1;
          targetCumulativeAtDate = ((historicalAmountPerDay * daysPassedBeforeToday) + (amountToShow * daysFromTodayToCalendarDay)).clamp(0.0, event.totalBudget);
        }
        
        bool isPaidAtDate = event.totalSaved >= (targetCumulativeAtDate - 0.1); // ลดหย่อนเศษทศนิยมเล็กน้อย
        
        if (event.lastSavingDate != null) {
          final lastSave = DateTime(event.lastSavingDate!.year, event.lastSavingDate!.month, event.lastSavingDate!.day);
          if (lastSave.isAtSameMomentAs(calendarDay) || lastSave.isAfter(calendarDay)) {
            isPaidAtDate = true;
          }
        }

        // --- 3. เช็คการ Lock ลำดับการออม ---
        bool isLocked = false;
        String? lockMessage;
        
        final dayBeforeSelected = calendarDay.subtract(const Duration(days: 1));
        if (dayBeforeSelected.isAfter(start) || dayBeforeSelected.isAtSameMomentAs(start)) {
           int daysToDayBefore = dayBeforeSelected.difference(start).inDays + 1;
           double targetAtDayBefore = (baseAmountPerDay * daysToDayBefore).clamp(0.0, event.totalBudget);
           
           bool isDayBeforePaid = event.totalSaved >= targetAtDayBefore;
           if (event.lastSavingDate != null) {
             final lastSave = DateTime(event.lastSavingDate!.year, event.lastSavingDate!.month, event.lastSavingDate!.day);
             if (lastSave.isAtSameMomentAs(dayBeforeSelected) || lastSave.isAfter(dayBeforeSelected)) {
               isDayBeforePaid = true;
             }
           }

           if (!isDayBeforePaid) {
             isLocked = true;
             lockMessage = "กรุณาออมของวันที่ ${_formatThaiDateShort(dayBeforeSelected)} ให้ครบก่อน";
           }
        }

        breakdown.add({
          'id': event.id,
          'title': event.title,
          'amount': amountToShow,
          'isPaid': isPaidAtDate,
          'isLocked': isLocked,
          'lockMessage': lockMessage,
          'isFull': event.totalSaved >= event.totalBudget,
          'event': event,
        });
      }
    }
    return breakdown;
  }

  double getTotalSavingAmount(DateTime date) {
    return getSavingsBreakdownForDay(date)
        .where((item) => !item['isPaid'])
        .fold(0.0, (sum, item) => sum + item['amount']);
  }

  Future<void> confirmSaving(double amount, List<Map<String, dynamic>> breakdown, {String? referenceId, DateTime? targetDate}) async {
    final now = DateTime.now();
    final effectiveTargetDate = targetDate ?? now;

    for (var item in breakdown) {
      DailyDetailModel event = item['event'];
      double amountToSaveForThisEvent = item['amount'];

      double remainingAmount = amountToSaveForThisEvent;
      for (var budgetItem in event.budgetItems) {
        double itemRemaining = budgetItem.targetAmount - budgetItem.savedAmount;
        if (itemRemaining <= 0) continue;

        double toSave = (remainingAmount > itemRemaining) ? itemRemaining : remainingAmount;
        budgetItem.savedAmount += toSave;
        remainingAmount -= toSave;

        if (remainingAmount <= 0) break;
      }

      if (remainingAmount > 0 && event.budgetItems.isNotEmpty) {
        event.budgetItems[0].savedAmount += remainingAmount;
      }

      final updatedEvent = event.copyWith(
        referenceId: referenceId,
        isSaved: true,
        lastSavingDate: effectiveTargetDate,
      );

      await _firebaseService.saveEvent(updatedEvent);
    }
  }

  Future<bool> isSlipUsed(String refId) => _firebaseService.isSlipUsed(refId);

  Future<void> registerSlip(String refId) {
    final uid = _firebaseService.uid;
    if (uid == null) return Future.value();
    return _firebaseService.registerSlip(refId, uid);
  }

  String _formatThaiDateShort(DateTime date) {
    final months = [
      "ม.ค.", "ก.พ.", "มี.ค.", "เม.ย.", "พ.ค.", "มิ.ย.",
      "ก.ค.", "ส.ค.", "ก.ย.", "ต.ค.", "พ.ย.", "ธ.ค."
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year + 543}";
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}