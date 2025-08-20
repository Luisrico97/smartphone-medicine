import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../services/bluetooth_service.dart';
import '../services/database_service.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({Key? key}) : super(key: key);

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  final DatabaseService _databaseService = DatabaseService();

  List<BluetoothDevice> _pairedDevices = [];
  bool _isLoading = true;
  bool _isConnected = false;
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
    _listenToConnections();
    _listenToBloodPressure();
  }

  @override
  void dispose() {
    _bluetoothService.dispose();
    super.dispose();
  }

  Future<void> _initializeBluetooth() async {
    setState(() => _isLoading = true);

    final hasPermissions = await _bluetoothService.requestPermissions();
    if (!hasPermissions) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permisos de Bluetooth requeridos'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    await _loadPairedDevices();
    setState(() => _isLoading = false);
  }

  Future<void> _loadPairedDevices() async {
    try {
      final devices = await _bluetoothService.getPairedDevices();
      setState(() => _pairedDevices = devices);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando dispositivos: $e')),
        );
      }
    }
  }

  void _listenToConnections() {
    _bluetoothService.connectionStream.listen((connected) {
      setState(() => _isConnected = connected);
      if (!connected) {
        setState(() => _connectedDevice = null);
      }
    });
  }

  void _listenToBloodPressure() {
    _bluetoothService.bloodPressureStream.listen((bloodPressure) async {
      try {
        await _databaseService.insertBloodPressure(bloodPressure);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Nueva medición: ${bloodPressure.systolic}/${bloodPressure.diastolic} mmHg',
              ),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Ver',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error guardando medición: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => _isScanning = true);

    final success = await _bluetoothService.connectToDevice(device);

    setState(() {
      _isScanning = false;
      if (success) {
        _connectedDevice = device;
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Conectado a ${device.name}'
                : 'Error conectando a ${device.name}',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _disconnect() async {
    await _bluetoothService.disconnect();
    setState(() {
      _isConnected = false;
      _connectedDevice = null;
    });
  }

  Future<void> _requestMeasurement() async {
    await _bluetoothService.requestMeasurement();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitando medición al smartwatch...'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Conexión Bluetooth',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.bluetooth_disabled),
              onPressed: _disconnect,
              tooltip: 'Desconectar',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Estado de conexión
                  _buildConnectionStatus(),

                  const SizedBox(height: 24),

                  // Dispositivos emparejados
                  _buildPairedDevicesList(),

                  const SizedBox(height: 24),

                  // Instrucciones
                  _buildInstructions(),
                ],
              ),
            ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green[50] : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isConnected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              size: 60,
              color: _isConnected ? Colors.green[600] : Colors.grey[600],
            ),
          ).animate().scale(duration: 600.ms),
          const SizedBox(height: 16),
          Text(
            _isConnected ? 'Conectado' : 'Desconectado',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isConnected ? Colors.green[600] : Colors.grey[600],
                ),
          ),
          if (_connectedDevice != null) ...[
            const SizedBox(height: 8),
            Text(
              _connectedDevice!.name ?? 'Dispositivo desconocido',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            Text(
              _connectedDevice!.address,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _requestMeasurement,
              icon: const Icon(Icons.monitor_heart),
              label: const Text('Solicitar Medición'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Selecciona un dispositivo para conectar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildPairedDevicesList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.devices, color: Colors.blue[600]),
              const SizedBox(width: 12),
              Text(
                'Dispositivos Emparejados',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadPairedDevices,
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_pairedDevices.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.bluetooth_searching,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No hay dispositivos emparejados',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Empareja tu smartwatch en la configuración de Bluetooth',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...List.generate(_pairedDevices.length, (index) {
              final device = _pairedDevices[index];
              final isConnected = _connectedDevice?.address == device.address;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green[50] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                      color: isConnected ? Colors.green[600] : Colors.blue[600],
                    ),
                  ),
                  title: Text(
                    device.name ?? 'Dispositivo desconocido',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(device.address),
                  trailing: _isScanning && !isConnected
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : isConnected
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Conectado',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: isConnected ? null : () => _connectToDevice(device),
                ),
              ).animate().slideX(
                    begin: 0.3,
                    end: 0,
                    delay: Duration(milliseconds: 100 * index),
                  );
            }),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600]),
              const SizedBox(width: 12),
              Text(
                'Instrucciones',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            '1.',
            'Empareja tu smartwatch en la configuración de Bluetooth del dispositivo',
          ),
          _buildInstructionStep(
            '2.',
            'Selecciona el dispositivo de la lista para conectar',
          ),
          _buildInstructionStep(
            '3.',
            'Una vez conectado, puedes solicitar mediciones automáticamente',
          ),
          _buildInstructionStep(
            '4.',
            'Las mediciones se guardarán automáticamente en tu historial',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue[800],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
