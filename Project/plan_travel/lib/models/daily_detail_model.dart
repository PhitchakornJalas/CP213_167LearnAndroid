import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetItem {
  String label;
  double targetAmount;
  double savedAmount;

  BudgetItem({
    required this.label,
    required this.targetAmount,
    this.savedAmount = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
    };
  }

  factory BudgetItem.fromMap(Map<String, dynamic> map) {
    return BudgetItem(
      label: map['label'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      savedAmount: (map['savedAmount'] ?? 0.0).toDouble(),
    );
  }
}

class DailyDetailModel {
  final String id;
  final String title;
  final List<BudgetItem> budgetItems;
  final bool isAllDay;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  final DateTime? savingStartDate;
  final String? referenceId;
  final bool isSaved;

  DailyDetailModel({
    required this.id,
    required this.title,
    required this.budgetItems,
    required this.isAllDay,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.savingStartDate,
    this.referenceId,
    this.isSaved = false,
  });

  double get totalBudget => budgetItems.fold(0.0, (sum, item) => sum + item.targetAmount);
  double get totalSaved => budgetItems.fold(0.0, (sum, item) => sum + item.savedAmount);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isAllDay': isAllDay,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'createdAt': Timestamp.fromDate(createdAt),
      'savingStartDate': savingStartDate != null ? Timestamp.fromDate(savingStartDate!) : null,
      'budgetItems': budgetItems.map((item) => item.toMap()).toList(),
      'referenceId': referenceId,
      'isSaved': isSaved,
    };
  }

  factory DailyDetailModel.fromMap(Map<String, dynamic> map, String docId) {
    return DailyDetailModel(
      id: docId,
      title: map['title'] ?? '',
      isAllDay: map['isAllDay'] ?? false,
      startTime: map['startTime'] is Timestamp 
          ? (map['startTime'] as Timestamp).toDate() 
          : DateTime.now(),
      endTime: map['endTime'] is Timestamp 
          ? (map['endTime'] as Timestamp).toDate() 
          : DateTime.now(),
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      savingStartDate: map['savingStartDate'] is Timestamp 
          ? (map['savingStartDate'] as Timestamp).toDate() 
          : null,
      budgetItems: (map['budgetItems'] as List<dynamic>?)
              ?.map((item) => BudgetItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      referenceId: map['referenceId'],
      isSaved: map['isSaved'] ?? false,
    );
  }

  DailyDetailModel copyWith({
    String? id,
    String? title,
    List<BudgetItem>? budgetItems,
    bool? isAllDay,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? savingStartDate,
    String? referenceId,
    bool? isSaved,
  }) {
    return DailyDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      budgetItems: budgetItems ?? this.budgetItems,
      isAllDay: isAllDay ?? this.isAllDay,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      savingStartDate: savingStartDate ?? this.savingStartDate,
      referenceId: referenceId ?? this.referenceId,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}