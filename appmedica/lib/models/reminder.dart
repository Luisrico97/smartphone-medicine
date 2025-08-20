class Reminder {
  final int? id;
  final String title;
  final String? message;
  final String reminderTime;
  final String frequency;
  final String? daysOfWeek;
  final bool isActive;
  final DateTime? lastTriggered;

  Reminder({
    this.id,
    required this.title,
    this.message,
    required this.reminderTime,
    this.frequency = 'daily',
    this.daysOfWeek,
    this.isActive = true,
    this.lastTriggered,
  });

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      reminderTime: map['reminder_time'],
      frequency: map['frequency'] ?? 'daily',
      daysOfWeek: map['days_of_week'],
      isActive: map['is_active'] == 1 || map['is_active'] == true,
      lastTriggered: map['last_triggered'] != null
          ? DateTime.parse(map['last_triggered'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'reminder_time': reminderTime,
      'frequency': frequency,
      'days_of_week': daysOfWeek,
      'is_active': isActive,
      'last_triggered': lastTriggered?.toIso8601String(),
    };
  }
}
