import 'package:flutter/material.dart';
import '../models/daily_detail_model.dart';

class DailyDetailViewModel extends ChangeNotifier {
  // เปลี่ยนชื่อ Map ให้สื่อถึงรายละเอียดรายวัน
  final Map<DateTime, DailyDetailModel> _dailyDetails = {};

  Map<DateTime, DailyDetailModel> get dailyDetails => _dailyDetails;

  DailyDetailModel? getDetail(DateTime date) {
    // สร้าง DateTime ใหม่ที่เวลาเป็น 00:00:00.000 เสมอ
    final dayOnly = DateTime(date.year, date.month, date.day);
    return _dailyDetails[dayOnly];
  }

  void updateDailyDetail(DateTime date, String title, String budget) {
    DateTime dayOnly = DateTime(date.year, date.month, date.day);
    _dailyDetails[dayOnly] = DailyDetailModel(title: title, budget: budget);
    notifyListeners();
  }
}