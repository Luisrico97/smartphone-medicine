class HealthGoal {
  final int? id;
  final String goalType;
  final int targetValue;
  final int currentValue;
  final DateTime? targetDate;
  final bool isActive;
  final DateTime? achievedAt;

  HealthGoal({
    this.id,
    required this.goalType,
    required this.targetValue,
    this.currentValue = 0,
    this.targetDate,
    this.isActive = true,
    this.achievedAt,
  });

  factory HealthGoal.fromMap(Map<String, dynamic> map) {
    return HealthGoal(
      id: map['id'],
      goalType: map['goal_type'],
      targetValue: map['target_value'],
      currentValue: map['current_value'] ?? 0,
      targetDate: map['target_date'] != null
          ? DateTime.parse(map['target_date'])
          : null,
      isActive: map['is_active'] == 1 || map['is_active'] == true,
      achievedAt: map['achieved_at'] != null
          ? DateTime.parse(map['achieved_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_type': goalType,
      'target_value': targetValue,
      'current_value': currentValue,
      'target_date': targetDate?.toIso8601String(),
      'is_active': isActive,
      'achieved_at': achievedAt?.toIso8601String(),
    };
  }
}
