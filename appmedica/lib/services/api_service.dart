import '../models/bluetooth_device.dart';
import '../models/user_setting.dart';
import '../models/reminder.dart';
import '../models/health_goal.dart';
import '../models/medical_note.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/blood_pressure.dart';

class ApiService {
  // Obtener todos los dispositivos Bluetooth
  static Future<List<BluetoothDeviceModel>> fetchBluetoothDevices() async {
    final response = await http.get(Uri.parse('$baseUrl/bluetooth-devices'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => BluetoothDeviceModel.fromMap(e)).toList();
    } else {
      throw Exception('Error al obtener dispositivos Bluetooth');
    }
  }

  // Obtener configuraciones de usuario
  static Future<List<UserSetting>> fetchUserSettings() async {
    final response = await http.get(Uri.parse('$baseUrl/user-settings'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => UserSetting.fromMap(e)).toList();
    } else {
      throw Exception('Error al obtener configuraciones de usuario');
    }
  }

  // Obtener recordatorios
  static Future<List<Reminder>> fetchReminders() async {
    final response = await http.get(Uri.parse('$baseUrl/reminders'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Reminder.fromMap(e)).toList();
    } else {
      throw Exception('Error al obtener recordatorios');
    }
  }

  // Obtener metas de salud
  static Future<List<HealthGoal>> fetchHealthGoals() async {
    final response = await http.get(Uri.parse('$baseUrl/health-goals'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => HealthGoal.fromMap(e)).toList();
    } else {
      throw Exception('Error al obtener metas de salud');
    }
  }

  // Obtener notas médicas
  static Future<List<MedicalNote>> fetchMedicalNotes() async {
    final response = await http.get(Uri.parse('$baseUrl/medical-notes'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => MedicalNote.fromMap(e)).toList();
    } else {
      throw Exception('Error al obtener notas médicas');
    }
  }

  static const String baseUrl = 'http://localhost:8000/api';

  // Obtener todas las mediciones
  static Future<List<BloodPressure>> fetchBloodPressures() async {
    final response = await http.get(Uri.parse('$baseUrl/blood-pressures'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => BloodPressure.fromMap(e)).toList();
    } else {
      throw Exception('Error al obtener mediciones');
    }
  }

  // Crear una nueva medición
  static Future<BloodPressure> createBloodPressure(BloodPressure bp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/blood-pressures'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bp.toMap()),
    );
    if (response.statusCode == 201) {
      return BloodPressure.fromMap(json.decode(response.body));
    } else {
      throw Exception('Error al crear medición');
    }
  }

  // Actualizar una medición
  static Future<BloodPressure> updateBloodPressure(BloodPressure bp) async {
    final response = await http.put(
      Uri.parse('$baseUrl/blood-pressures/${bp.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bp.toMap()),
    );
    if (response.statusCode == 200) {
      return BloodPressure.fromMap(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar medición');
    }
  }

  // Eliminar una medición
  static Future<void> deleteBloodPressure(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/blood-pressures/$id'),
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar medición');
    }
  }
}
