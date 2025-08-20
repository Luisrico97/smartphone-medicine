import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/blood_pressure.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _dataSubscription;
  final StreamController<BloodPressure> _bloodPressureController =
      StreamController<BloodPressure>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<BloodPressure> get bloodPressureStream =>
      _bloodPressureController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _connection?.isConnected ?? false;

  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      print('Error getting paired devices: $e');
      return [];
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      if (_connection?.isConnected == true) {
        await disconnect();
      }

      _connection = await BluetoothConnection.toAddress(device.address);
      _connectionController.add(true);

      _dataSubscription = _connection!.input!.listen(
        _onDataReceived,
        onError: (error) {
          print('Error receiving data: $error');
          _connectionController.add(false);
        },
        onDone: () {
          print('Connection closed');
          _connectionController.add(false);
        },
      );

      return true;
    } catch (e) {
      print('Error connecting to device: $e');
      _connectionController.add(false);
      return false;
    }
  }

  void _onDataReceived(Uint8List data) {
    try {
      String dataString = String.fromCharCodes(data);
      print('Received data: $dataString');

      // Parsear datos del smartwatch
      // Formato esperado: "SYS:120,DIA:80,PULSE:75"
      BloodPressure? bloodPressure = _parseBloodPressureData(dataString);
      if (bloodPressure != null) {
        _bloodPressureController.add(bloodPressure);
      }
    } catch (e) {
      print('Error parsing data: $e');
    }
  }

  BloodPressure? _parseBloodPressureData(String data) {
    try {
      final regex = RegExp(r'SYS:(\d+),DIA:(\d+),PULSE:(\d+)');
      final match = regex.firstMatch(data);

      if (match != null) {
        int systolic = int.parse(match.group(1)!);
        int diastolic = int.parse(match.group(2)!);
        int pulse = int.parse(match.group(3)!);

        return BloodPressure(
          systolic: systolic,
          diastolic: diastolic,
          pulse: pulse,
          timestamp: DateTime.now(),
          source: 'bluetooth',
        );
      }
    } catch (e) {
      print('Error parsing blood pressure data: $e');
    }
    return null;
  }

  Future<void> sendCommand(String command) async {
    if (_connection?.isConnected == true) {
      try {
        _connection!.output.add(Uint8List.fromList(utf8.encode(command)));
        await _connection!.output.allSent;
      } catch (e) {
        print('Error sending command: $e');
      }
    }
  }

  Future<void> requestMeasurement() async {
    await sendCommand('MEASURE');
  }

  Future<void> disconnect() async {
    try {
      await _dataSubscription?.cancel();
      await _connection?.close();
      _connection = null;
      _connectionController.add(false);
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  void dispose() {
    _bloodPressureController.close();
    _connectionController.close();
    disconnect();
  }
}
