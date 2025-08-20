import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/blood_pressure.dart';
import '../services/api_service.dart';
import '../widgets/blood_pressure_card.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/health_tips_widget.dart';
import '../widgets/quick_stats_widget.dart';
import '../widgets/health_alert_widget.dart';
import 'add_measurement_screen.dart';
import 'bluetooth_screen.dart';
import 'charts_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<BloodPressure> _measurements = [];
  bool _isLoading = true;
  BloodPressure? _latestMeasurement;

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    setState(() => _isLoading = true);
    try {
      final measurements = await ApiService.fetchBloodPressures();
      setState(() {
        _measurements = measurements;
        _latestMeasurement =
            measurements.isNotEmpty ? measurements.first : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando mediciones: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Presión Arterial',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BluetoothScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChartsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMeasurements,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Resumen principal
                    _buildMainSummary(),

                    // Alerta de salud (si es necesaria)
                    HealthAlertWidget(latestMeasurement: _latestMeasurement),
                    const SizedBox(height: 20),

                    // Acciones rápidas
                    _buildQuickActions(),
                    const SizedBox(height: 20),

                    // Consejos de salud
                    const HealthTipsWidget(),
                    const SizedBox(height: 20),

                    // Estadísticas rápidas
                    QuickStatsWidget(measurements: _measurements),
                    const SizedBox(height: 20),

                    // Lista de mediciones
                    _buildMeasurementsList(),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddMeasurementScreen()),
          );
          if (result == true) {
            _loadMeasurements();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
        backgroundColor: Colors.blue[600],
      ).animate().scale(delay: 300.ms, duration: 400.ms),
    );
  }

  Widget _buildMainSummary() {
    if (_latestMeasurement == null) {
      return Container(
        margin: const EdgeInsets.all(16),
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
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay mediciones',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tu primera medición de presión arterial',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0);
    }

    return Container(
      margin: const EdgeInsets.all(16),
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
          Text(
            'Última medición',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 20),
          BloodPressureMeter(
            systolic: _latestMeasurement!.systolic,
            diastolic: _latestMeasurement!.diastolic,
            category: _latestMeasurement!.category ?? 'Sin categoría',
            color: _latestMeasurement!.categoryColor,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  HeartBeatAnimation(
                    size: 40,
                    color: Colors.red[400]!,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_latestMeasurement!.pulse} bpm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[400],
                        ),
                  ),
                  Text(
                    'Pulso',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(
                    _latestMeasurement!.source == 'bluetooth'
                        ? Icons.bluetooth_connected
                        : Icons.edit,
                    size: 40,
                    color: Colors.blue[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _latestMeasurement!.source == 'bluetooth'
                        ? 'Smartwatch'
                        : 'Manual',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[400],
                        ),
                  ),
                  Text(
                    'Origen',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              'Bluetooth',
              'Conectar smartwatch',
              Icons.bluetooth,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BluetoothScreen()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              'Gráficos',
              'Ver tendencias',
              Icons.show_chart,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChartsScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().scale(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildMeasurementsList() {
    if (_measurements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Historial reciente',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _measurements.length > 5 ? 5 : _measurements.length,
          itemBuilder: (context, index) {
            return BloodPressureCard(
              bloodPressure: _measurements[index],
              onTap: () {
                // Aquí puedes agregar navegación a detalles
              },
            );
          },
        ),
        if (_measurements.length > 5)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton(
                onPressed: () {
                  // Navegar a lista completa
                },
                child: const Text('Ver todas las mediciones'),
              ),
            ),
          ),
      ],
    );
  }
}
