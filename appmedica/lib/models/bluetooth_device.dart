class BluetoothDeviceModel {
  final int? id;
  final String deviceName;
  final String deviceAddress;
  final DateTime? lastConnected;
  final bool isFavorite;
  final String deviceType;

  BluetoothDeviceModel({
    this.id,
    required this.deviceName,
    required this.deviceAddress,
    this.lastConnected,
    this.isFavorite = false,
    this.deviceType = 'smartwatch',
  });

  factory BluetoothDeviceModel.fromMap(Map<String, dynamic> map) {
    return BluetoothDeviceModel(
      id: map['id'],
      deviceName: map['device_name'],
      deviceAddress: map['device_address'],
      lastConnected: map['last_connected'] != null
          ? DateTime.parse(map['last_connected'])
          : null,
      isFavorite: map['is_favorite'] == 1 || map['is_favorite'] == true,
      deviceType: map['device_type'] ?? 'smartwatch',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_name': deviceName,
      'device_address': deviceAddress,
      'last_connected': lastConnected?.toIso8601String(),
      'is_favorite': isFavorite,
      'device_type': deviceType,
    };
  }
}
