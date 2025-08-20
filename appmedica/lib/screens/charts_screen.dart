import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/blood_pressure.dart';
import '../services/api_service.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({Key? key}) : super(key: key);

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen>
    with TickerProviderStateMixin {
  List<BloodPressure> _measurements = [];
  bool _isLoading = true;
  String _selectedPeriod = '7 días';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMeasurements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMeasurements() async {
    setState(() => _isLoading = true);
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate;
      switch (_selectedPeriod) {
        case '7 días':
          startDate = endDate.subtract(const Duration(days: 7));
          break;
        case '30 días':
          startDate = endDate.subtract(const Duration(days: 30));
          break;
        case '3 meses':
          startDate = endDate.subtract(const Duration(days: 90));
          break;
        default:
          startDate = endDate.subtract(const Duration(days: 7));
      }
      final allMeasurements = await ApiService.fetchBloodPressures();
      final measurements = allMeasurements
          .where((bp) =>
              (bp.timestamp?.isAfter(
                      startDate.subtract(const Duration(seconds: 1))) ??
                  false) &&
              (bp.timestamp
                      ?.isBefore(endDate.add(const Duration(seconds: 1))) ??
                  false))
          .toList();
      setState(() {
        _measurements = measurements.reversed.toList(); // Orden cronológico
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando datos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Gráficos y Tendencias',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.show_chart), text: 'Presión'),
            Tab(icon: Icon(Icons.favorite), text: 'Pulso'),
            Tab(icon: Icon(Icons.analytics), text: 'Estadísticas'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Selector de período
          _buildPeriodSelector(),

          // Contenido de las pestañas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBloodPressureChart(),
                      _buildPulseChart(),
                      _buildStatistics(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: ['7 días', '30 días', '3 meses'].map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedPeriod = period);
                _loadMeasurements();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[600] : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().slideY(begin: -0.3, end: 0, duration: 400.ms);
  }

  Widget _buildBloodPressureChart() {
    if (_measurements.isEmpty) {
      return _buildEmptyState('No hay datos de presión arterial');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
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
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < _measurements.length) {
                          final measurement = _measurements[value.toInt()];
                          return Text(
                            '${measurement.timestamp?.day ?? ''}/${measurement.timestamp?.month ?? ''}',
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: (_measurements.length - 1).toDouble(),
                minY: 40,
                maxY: 200,
                lineBarsData: [
                  // Línea sistólica
                  LineChartBarData(
                    spots: _measurements.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(),
                          entry.value.systolic.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.red[400],
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red[400]!.withOpacity(0.1),
                    ),
                  ),
                  // Línea diastólica
                  LineChartBarData(
                    spots: _measurements.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(),
                          entry.value.diastolic.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue[400],
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue[400]!.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 16),

          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Sistólica', Colors.red[400]!),
              const SizedBox(width: 32),
              _buildLegendItem('Diastólica', Colors.blue[400]!),
            ],
          ),

          const SizedBox(height: 24),

          // Rangos de referencia
          _buildReferenceRanges(),
        ],
      ),
    );
  }

  Widget _buildPulseChart() {
    if (_measurements.isEmpty) {
      return _buildEmptyState('No hay datos de pulso');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
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
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < _measurements.length) {
                          final measurement = _measurements[value.toInt()];
                          return Text(
                            '${measurement.timestamp?.day ?? ''}/${measurement.timestamp?.month ?? ''}',
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: (_measurements.length - 1).toDouble(),
                minY: 40,
                maxY: 120,
                lineBarsData: [
                  LineChartBarData(
                    spots: _measurements.asMap().entries.map((entry) {
                      return FlSpot(
                          entry.key.toDouble(), entry.value.pulse.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.red[500],
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red[500]!.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 24),

          // Información sobre el pulso
          _buildPulseInfo(),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    if (_measurements.isEmpty) {
      return _buildEmptyState('No hay datos para estadísticas');
    }

    final sistolicValues = _measurements.map((m) => m.systolic).toList();
    final diastolicValues = _measurements.map((m) => m.diastolic).toList();
    final pulseValues = _measurements.map((m) => m.pulse).toList();

    final avgSistolic =
        (sistolicValues.reduce((a, b) => a + b) / sistolicValues.length)
            .round();
    final avgDiastolic =
        (diastolicValues.reduce((a, b) => a + b) / diastolicValues.length)
            .round();
    final avgPulse =
        (pulseValues.reduce((a, b) => a + b) / pulseValues.length).round();

    final maxSistolic = sistolicValues.reduce((a, b) => a > b ? a : b);
    final minSistolic = sistolicValues.reduce((a, b) => a < b ? a : b);
    final maxDiastolic = diastolicValues.reduce((a, b) => a > b ? a : b);
    final minDiastolic = diastolicValues.reduce((a, b) => a < b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Promedios
          _buildStatCard(
            'Promedios',
            [
              StatItem('Sistólica', '$avgSistolic mmHg', Colors.red[400]!),
              StatItem('Diastólica', '$avgDiastolic mmHg', Colors.blue[400]!),
              StatItem('Pulso', '$avgPulse bpm', Colors.red[500]!),
            ],
          ),

          const SizedBox(height: 16),

          // Rangos
          _buildStatCard(
            'Rangos',
            [
              StatItem('Sistólica', '$minSistolic - $maxSistolic mmHg',
                  Colors.red[400]!),
              StatItem('Diastólica', '$minDiastolic - $maxDiastolic mmHg',
                  Colors.blue[400]!),
              StatItem('Total mediciones', '${_measurements.length}',
                  Colors.grey[600]!),
            ],
          ),

          const SizedBox(height: 16),

          // Distribución por categorías
          _buildCategoryDistribution(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, List<StatItem> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      item.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: item.color,
                          ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.3, end: 0);
  }

  Widget _buildCategoryDistribution() {
    final categories = <String, int>{};
    for (final measurement in _measurements) {
      final cat = measurement.category ?? 'Sin categoría';
      categories[cat] = (categories[cat] ?? 0) + 1;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución por Categorías',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...categories.entries.map((entry) {
            final percentage =
                (entry.value / _measurements.length * 100).round();
            final tempBP = BloodPressure(
              systolic: 120,
              diastolic: 80,
              pulse: 70,
              timestamp: DateTime.now(),
            );

            // Obtener color basado en la categoría
            Color categoryColor;
            switch (entry.key) {
              case 'Normal':
                categoryColor = const Color(0xFF4CAF50);
                break;
              case 'Elevada':
                categoryColor = const Color(0xFFFF9800);
                break;
              case 'Hipertensión Etapa 1':
                categoryColor = const Color(0xFFFF5722);
                break;
              case 'Hipertensión Etapa 2':
                categoryColor = const Color(0xFFF44336);
                break;
              case 'Crisis Hipertensiva':
                categoryColor = const Color(0xFF9C27B0);
                break;
              default:
                categoryColor = const Color(0xFF757575);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${entry.value} ($percentage%)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildReferenceRanges() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rangos de Referencia',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
          ),
          const SizedBox(height: 12),
          _buildReferenceItem(
              'Normal', '< 120/80 mmHg', const Color(0xFF4CAF50)),
          _buildReferenceItem(
              'Elevada', '120-129/<80 mmHg', const Color(0xFFFF9800)),
          _buildReferenceItem(
              'Etapa 1', '130-139/80-89 mmHg', const Color(0xFFFF5722)),
          _buildReferenceItem(
              'Etapa 2', '≥140/≥90 mmHg', const Color(0xFFF44336)),
        ],
      ),
    );
  }

  Widget _buildReferenceItem(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            category,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            range,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rangos de Pulso',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
          ),
          const SizedBox(height: 12),
          _buildReferenceItem('Reposo normal', '60-100 bpm', Colors.green),
          _buildReferenceItem('Bradicardia', '< 60 bpm', Colors.blue),
          _buildReferenceItem('Taquicardia', '> 100 bpm', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega algunas mediciones para ver gráficos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

class StatItem {
  final String label;
  final String value;
  final Color color;

  StatItem(this.label, this.value, this.color);
}
