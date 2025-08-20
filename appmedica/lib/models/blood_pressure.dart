import 'package:flutter/material.dart';

class BloodPressure {
  final int? id;
  final int systolic;
  final int diastolic;
  final int pulse;
  final DateTime? timestamp;
  final String? notes;
  final String source; // 'manual' o 'bluetooth'
  final String? category;

  BloodPressure({
    this.id,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    this.timestamp,
    this.notes,
    this.source = 'manual',
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'timestamp': timestamp?.toIso8601String(),
      'notes': notes,
      'source': source,
      'category': category,
    };
  }

  factory BloodPressure.fromMap(Map<String, dynamic> map) {
    return BloodPressure(
      id: map['id'],
      systolic: map['systolic'],
      diastolic: map['diastolic'],
      pulse: map['pulse'],
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString())
          : null,
      notes: map['notes'],
      source: map['source'] ?? 'manual',
      category: map['category'],
    );
  }

  // Si category es nulo, puedes calcularlo aquí si lo necesitas
  String get calculatedCategory {
    if (systolic < 120 && diastolic < 80) {
      return 'Normal';
    } else if (systolic < 130 && diastolic < 80) {
      return 'Elevada';
    } else if ((systolic >= 130 && systolic < 140) ||
        (diastolic >= 80 && diastolic < 90)) {
      return 'Hipertensión Etapa 1';
    } else if ((systolic >= 140 && systolic < 180) ||
        (diastolic >= 90 && diastolic < 120)) {
      return 'Hipertensión Etapa 2';
    } else {
      return 'Crisis Hipertensiva';
    }
  }

  Color get categoryColor {
    final cat = category ?? calculatedCategory;
    switch (cat) {
      case 'Normal':
        return const Color(0xFF4CAF50);
      case 'Elevada':
        return const Color(0xFFFF9800);
      case 'Hipertensión Etapa 1':
        return const Color(0xFFFF5722);
      case 'Hipertensión Etapa 2':
        return const Color(0xFFF44336);
      case 'Crisis Hipertensiva':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF757575);
    }
  }
}
