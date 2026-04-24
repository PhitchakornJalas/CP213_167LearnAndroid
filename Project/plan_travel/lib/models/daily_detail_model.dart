class DailyDetailModel {
  final String title;
  final String budget;
  final DateTime? savingStartDate;
  final bool isAllDay; // เพิ่มตัวนี้
  final DateTime startTime; // เริ่มต้น
  final DateTime endTime; // สิ้นสุด

  DailyDetailModel({
    required this.title,
    required this.budget,
    this.savingStartDate,
    required this.isAllDay,
    required this.startTime,
    required this.endTime,
  });
}