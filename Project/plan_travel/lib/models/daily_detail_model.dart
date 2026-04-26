class BudgetItem {
  String label; // เช่น "ค่าข้าว"
  double amount; // เช่น 100.0

  BudgetItem({required this.label, required this.amount});
}

class DailyDetailModel {
  final String id; // เพิ่ม ID เพื่อใช้อ้างอิงการแก้ไข/ลบ
  final String title;
  final List<BudgetItem> budgetItems; // เปลี่ยนจาก String budget เป็น List
  final DateTime? savingStartDate;
  final bool isAllDay;
  final DateTime startTime;
  final DateTime endTime;
  double amountSaved;

  DailyDetailModel({
    required this.id,
    required this.title,
    required this.budgetItems,
    this.savingStartDate,
    required this.isAllDay,
    required this.startTime,
    required this.endTime,
    this.amountSaved = 0.0,
  });

  // สร้าง Getter เพื่อหาผลรวมยอดทั้งหมดไปใช้งานต่อ
  double get totalBudget => budgetItems.fold(0.0, (sum, item) => sum + item.amount);
}