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

  Future<void> addOrUpdateEvent(DailyDetailModel event) async {
    await _firebaseService.saveEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _firebaseService.deleteEvent(eventId);
  }

  List<DailyDetailModel> getEventsForDay(DateTime date) {
    return _allEvents.where((e) => isSameDay(e.startTime, date)).toList()
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
    final calendarDay = DateTime(date.year, date.month, date.day);

    for (var event in _allEvents) {
      if (event.totalBudget <= 0) continue;

      final effectiveStart = event.savingStartDate ?? event.createdAt;
      final start = DateTime(effectiveStart.year, effectiveStart.month, effectiveStart.day);
      final eventDay = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);

      // แสดงรายการออมตั้งแต่วันเริ่มแผน จนถึง "ก่อน" วันเดินทาง
      if ((calendarDay.isAtSameMomentAs(start) || calendarDay.isAfter(start)) && 
          calendarDay.isBefore(eventDay)) {
        
        // 1. คำนวณยอดออมต่อวันแบบเฉลี่ย (Fixed Rate จากงบทั้งหมด)
        int totalDays = eventDay.difference(start).inDays;
        if (totalDays <= 0) continue;
        double amountPerDay = (event.totalBudget / totalDays).ceilToDouble();

        // 2. คำนวณว่า "จนถึงวันนี้" ควรจะออมไปแล้วเท่าไหร่
        int daysPassedIncludingToday = calendarDay.difference(start).inDays + 1;
        double expectedSavedSoFar = amountPerDay * daysPassedIncludingToday;
        if (expectedSavedSoFar > event.totalBudget) expectedSavedSoFar = event.totalBudget;

        // 3. เช็คสถานะ: ถ้าเป้าหมายของวันนี้คือ 100 บาท และยอดออมรวม (totalSaved) >= 100 แสดงว่าวันนี้ "ออมแล้ว"
        bool isPaidToday = event.totalSaved >= expectedSavedSoFar;

        // 4. ถ้าเป็นวันในอดีต และยังออมไม่ถึงเป้าหมายที่ควรจะเป็น -> ก็โชว์ค้างออม (แต่อาจจะจ่ายย้อนหลังได้)
        // ถ้าเป็นวันปัจจุบัน หรืออนาคต -> โชว์ยอดออมตามปกติ
        
        // กรองเฉพาะวันที่ "วันนี้" หรือ "ในอนาคต" เพื่อไม่ให้ปฏิทินย้อนหลังรก (หรือโชว์ทั้งหมดตาม User บอกว่า "ไม่ได้ให้หายไป")
        // ในที่นี้ผมโชว์ทั้งหมดตามความตั้งใจของ User ครับ
        breakdown.add({
          'id': event.id,
          'title': event.title,
          'amount': amountPerDay,
          'isPaid': isPaidToday, // สถานะว่าจ่ายของวันนี้หรือยัง
          'isFull': event.totalSaved >= event.totalBudget, // จ่ายครบทั้งโปรเจกต์หรือยัง
          'event': event,
        });
      }
    }
    return breakdown;
  }

  double getTotalSavingAmount(DateTime date) {
    // รวมเฉพาะยอดที่ "ยังไม่ได้จ่าย" ในวันนั้นๆ
    return getSavingsBreakdownForDay(date)
        .where((item) => !item['isPaid'])
        .fold(0.0, (sum, item) => sum + item['amount']);
  }

  Future<void> confirmSaving(double amount, List<Map<String, dynamic>> breakdown) async {
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

      await _firebaseService.saveEvent(event);
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}