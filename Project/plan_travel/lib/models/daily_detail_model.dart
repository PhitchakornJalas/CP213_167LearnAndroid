class DailyDetailModel {
  final String id; // เพิ่ม ID เพื่อใช้อ้างอิงการแก้ไข/ลบ
  final String title;
  final String budget;
  final DateTime? savingStartDate;
  final bool isAllDay;
  final DateTime startTime;
  final DateTime endTime;

  DailyDetailModel({
    required this.id,
    required this.title,
    required this.budget,
    this.savingStartDate,
    required this.isAllDay,
    required this.startTime,
    required this.endTime,
  });
}