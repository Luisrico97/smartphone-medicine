class UserSetting {
  final int? id;
  final String settingKey;
  final String settingValue;
  final String settingType;
  final String? description;

  UserSetting({
    this.id,
    required this.settingKey,
    required this.settingValue,
    this.settingType = 'string',
    this.description,
  });

  factory UserSetting.fromMap(Map<String, dynamic> map) {
    return UserSetting(
      id: map['id'],
      settingKey: map['setting_key'],
      settingValue: map['setting_value'],
      settingType: map['setting_type'] ?? 'string',
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'setting_key': settingKey,
      'setting_value': settingValue,
      'setting_type': settingType,
      'description': description,
    };
  }
}
