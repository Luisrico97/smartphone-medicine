import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _bluetoothAutoConnect = false;
  String _reminderFrequency = 'Diario';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Notificaciones
            _buildSettingsCard(
              'Notificaciones',
              Icons.notifications,
              Colors.orange,
              [
                _buildSwitchTile(
                  'Recordatorios',
                  'Recibir recordatorios para medir presión',
                  _notificationsEnabled,
                  (value) => setState(() => _notificationsEnabled = value),
                ),
                if (_notificationsEnabled) ...[
                  const Divider(),
                  _buildListTile(
                    'Frecuencia',
                    _reminderFrequency,
                    Icons.schedule,
                    () => _showFrequencyDialog(),
                  ),
                  _buildListTile(
                    'Hora',
                    _reminderTime.format(context),
                    Icons.access_time,
                    () => _showTimePicker(),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Bluetooth
            _buildSettingsCard(
              'Bluetooth',
              Icons.bluetooth,
              Colors.blue,
              [
                _buildSwitchTile(
                  'Conexión automática',
                  'Conectar automáticamente al último dispositivo',
                  _bluetoothAutoConnect,
                  (value) => setState(() => _bluetoothAutoConnect = value),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Datos y privacidad
            _buildSettingsCard(
              'Datos y Privacidad',
              Icons.security,
              Colors.green,
              [
                _buildListTile(
                  'Exportar datos',
                  'Exportar historial en CSV',
                  Icons.file_download,
                  () => _exportData(),
                ),
                _buildListTile(
                  'Eliminar todos los datos',
                  'Borrar todo el historial',
                  Icons.delete_forever,
                  () => _showDeleteAllDialog(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Información de la app
            _buildSettingsCard(
              'Información',
              Icons.info,
              Colors.purple,
              [
                _buildListTile(
                  'Versión',
                  '1.0.0',
                  Icons.info_outline,
                  null,
                ),
                _buildListTile(
                  'Acerca de',
                  'Información de la aplicación',
                  Icons.help_outline,
                  () => _showAboutDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.3, end: 0);
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue[600],
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      leading: Icon(icon, color: Colors.grey[600]),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  Future<void> _showFrequencyDialog() async {
    final frequencies = ['Diario', 'Cada 2 días', 'Semanal', 'Personalizado'];

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frecuencia de recordatorios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: frequencies.map((frequency) {
            return RadioListTile<String>(
              title: Text(frequency),
              value: frequency,
              groupValue: _reminderFrequency,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
      ),
    );

    if (result != null) {
      setState(() => _reminderFrequency = result);
    }
  }

  Future<void> _showTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de exportación en desarrollo'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _showDeleteAllDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todos los datos'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar todo tu historial de presión arterial? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidad de eliminación en desarrollo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Presión Arterial',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.favorite,
          color: Colors.blue[600],
          size: 32,
        ),
      ),
      children: [
        const Text(
          'Una aplicación completa para el monitoreo de presión arterial con conectividad Bluetooth y análisis de tendencias.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Características principales:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Registro manual y automático vía Bluetooth'),
        const Text('• Gráficos y análisis de tendencias'),
        const Text('• Categorización automática de valores'),
        const Text('• Interfaz amigable con animaciones'),
      ],
    );
  }
}
