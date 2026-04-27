import 'dart:async';
import 'package:flutter/material.dart';
import '../models/daily_detail_model.dart';
import '../services/firebase_service.dart';

class DailyDetailViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService;
  List<DailyDetailModel> _allEvents = [];
  StreamSubscription? _eventsSubscription;
  bool _isLoading = true; // เพิ่มสถานะ Loading
  String? _errorMessage; // เพิ่มตัวแปรเก็บ Error

  DailyDetailViewModel(this._firebaseService) {
    _listenToEvents();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ดึงข้อมูล Real-time จาก Firestore
  void _listenToEvents() {
    _eventsSubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _eventsSubscription = _firebaseService.eventsStream.listen(
      (events) {
        _allEvents = events;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint("Firestore Stream Error: $error");
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      }
    );
  }

  // --- Helpers สำหรับ UI ---

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
      if (event.totalBudget == 0) continue;

      final effectiveStart = event.savingStartDate ?? event.createdAt;
      final start = DateTime(effectiveStart.year, effectiveStart.month, effectiveStart.day);
      final eventDay = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);

      if ((calendarDay.isAtSameMomentAs(start) || calendarDay.isAfter(start)) && calendarDay.isBefore(eventDay)) {
        int totalSavingDays = eventDay.difference(start).inDays;
        if (totalSavingDays > 0) {
          double amountPerEvent = (event.totalBudget / totalSavingDays).ceilToDouble();
          breakdown.add({
            'id': event.id,
            'title': event.title,
            'amount': amountPerEvent,
            'event': event,
          });
        }
      }
    }
    return breakdown;
  }

  double getTotalSavingAmount(DateTime date) {
    return getSavingsBreakdownForDay(date).fold(0.0, (sum, item) => sum + item['amount']);
  }

  // --- CRUD Operations ---

  Future<void> addOrUpdateEvent(DailyDetailModel event) async {
    try {
      await _firebaseService.saveEvent(event);
    } catch (e) {
      debugPrint("Save Event Error: $e");
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firebaseService.deleteEvent(eventId);
    } catch (e) {
      debugPrint("Delete Event Error: $e");
    }
  }

  Future<void> confirmSaving(String eventId, double amount) async {
    final eventIndex = _allEvents.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      final event = _allEvents[eventIndex];
      
      double remainingAmount = amount;
      for (var item in event.budgetItems) {
        double needed = item.targetAmount - item.savedAmount;
        if (needed > 0) {
          double toAdd = remainingAmount > needed ? needed : remainingAmount;
          item.savedAmount += toAdd;
          remainingAmount -= toAdd;
        }
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
    super.dispose();
  }
}