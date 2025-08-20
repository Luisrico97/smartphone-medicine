import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/blood_pressure.dart';

class QuickStatsWidget extends StatelessWidget {
  final List<BloodPressure> measurements;

  const QuickStatsWidget({
    Key? key,
    required this.measurements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return const SizedBox.shrink();
    }

    final stats = _calculateStats();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Estadísticas de la Semana',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Promedio',
                  '${stats.avgSystolic}/${stats.avgDiastolic}',
                  'mmHg',
                  Icons.analytics,
                  Colors.blue,
                  context,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Última',
                  '${measurements.first.systolic}/${measurements.first.diastolic}',
                  'mmHg',
                  Icons.timeline,
                  measurements.first.categoryColor,
                  context,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pulso Prom.',
                  '${stats.avgPulse}',
                  'bpm',
                  Icons.favorite,
                  Colors.red,
                  context,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Mediciones',
                  '${measurements.length}',
                  'esta semana',
                  Icons.monitor_heart,
                  Colors.green,
                  context,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms);
  }

  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Container(
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
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            unit,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    ).animate().scale(
          delay: Duration(milliseconds: 100),
          duration: 300.ms,
        );
  }

  QuickStats _calculateStats() {
    // Filtrar mediciones de la última semana
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekMeasurements = measurements
        .where((m) => m.timestamp?.isAfter(weekAgo) ?? false)
        .toList();

    if (weekMeasurements.isEmpty) {
      return QuickStats(
        avgSystolic: 0,
        avgDiastolic: 0,
        avgPulse: 0,
        count: 0,
      );
    }

    final avgSystolic =
        (weekMeasurements.map((m) => m.systolic).reduce((a, b) => a + b) /
                weekMeasurements.length)
            .round();

    final avgDiastolic =
        (weekMeasurements.map((m) => m.diastolic).reduce((a, b) => a + b) /
                weekMeasurements.length)
            .round();

    final avgPulse =
        (weekMeasurements.map((m) => m.pulse).reduce((a, b) => a + b) /
                weekMeasurements.length)
            .round();

    return QuickStats(
      avgSystolic: avgSystolic,
      avgDiastolic: avgDiastolic,
      avgPulse: avgPulse,
      count: weekMeasurements.length,
    );
  }
}

class QuickStats {
  final int avgSystolic;
  final int avgDiastolic;
  final int avgPulse;
  final int count;

  QuickStats({
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.avgPulse,
    required this.count,
  });
}
