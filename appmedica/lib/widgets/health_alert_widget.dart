import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/blood_pressure.dart';

class HealthAlertWidget extends StatelessWidget {
  final BloodPressure? latestMeasurement;

  const HealthAlertWidget({
    Key? key,
    this.latestMeasurement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (latestMeasurement == null) {
      return const SizedBox.shrink();
    }

    final alert = _getHealthAlert(latestMeasurement!);
    if (alert == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alert.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: alert.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              alert.icon,
              color: alert.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: alert.color,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                ),
                if (alert.recommendation != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: alert.color.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: alert.color,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alert.recommendation!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: alert.color,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0);
  }

  HealthAlert? _getHealthAlert(BloodPressure measurement) {
    final systolic = measurement.systolic;
    final diastolic = measurement.diastolic;
    final pulse = measurement.pulse;

    // Crisis hipertensiva - Alerta crítica
    if (systolic >= 180 || diastolic >= 120) {
      return HealthAlert(
        title: '🚨 Crisis Hipertensiva',
        message:
            'Tu presión arterial está en niveles críticos. Busca atención médica inmediata.',
        icon: Icons.emergency,
        color: Colors.red[700]!,
        severity: AlertSeverity.critical,
        recommendation:
            'Contacta a emergencias o acude al hospital más cercano',
      );
    }

    // Hipertensión Etapa 2 - Alerta alta
    if ((systolic >= 140 && systolic < 180) ||
        (diastolic >= 90 && diastolic < 120)) {
      return HealthAlert(
        title: '⚠️ Hipertensión Etapa 2',
        message:
            'Tu presión arterial está elevada. Es importante consultar con un médico.',
        icon: Icons.warning,
        color: Colors.red[600]!,
        severity: AlertSeverity.high,
        recommendation:
            'Programa una cita médica y considera cambios en el estilo de vida',
      );
    }

    // Hipertensión Etapa 1 - Alerta moderada
    if ((systolic >= 130 && systolic < 140) ||
        (diastolic >= 80 && diastolic < 90)) {
      return HealthAlert(
        title: '📊 Hipertensión Etapa 1',
        message: 'Tu presión arterial está ligeramente elevada.',
        icon: Icons.info,
        color: Colors.orange[600]!,
        severity: AlertSeverity.moderate,
        recommendation:
            'Monitorea regularmente y considera cambios en dieta y ejercicio',
      );
    }

    // Presión elevada - Alerta leve
    if (systolic >= 120 && systolic < 130 && diastolic < 80) {
      return HealthAlert(
        title: '📈 Presión Elevada',
        message: 'Tu presión sistólica está ligeramente alta.',
        icon: Icons.trending_up,
        color: Colors.amber[700]!,
        severity: AlertSeverity.low,
        recommendation:
            'Mantén hábitos saludables para prevenir la hipertensión',
      );
    }

    // Pulso anormal
    if (pulse < 60 || pulse > 100) {
      String pulseType = pulse < 60 ? 'Bradicardia' : 'Taquicardia';
      String pulseMessage = pulse < 60
          ? 'Tu pulso está por debajo del rango normal'
          : 'Tu pulso está por encima del rango normal';

      return HealthAlert(
        title: '💓 $pulseType',
        message: '$pulseMessage ($pulse bpm).',
        icon: Icons.favorite,
        color: Colors.blue[600]!,
        severity: AlertSeverity.moderate,
        recommendation: 'Si persiste, consulta con un médico para evaluación',
      );
    }

    // Presión muy baja - Hipotensión
    if (systolic < 90 || diastolic < 60) {
      return HealthAlert(
        title: '📉 Presión Baja',
        message: 'Tu presión arterial está por debajo del rango normal.',
        icon: Icons.trending_down,
        color: Colors.blue[700]!,
        severity: AlertSeverity.moderate,
        recommendation: 'Mantente hidratado y levántate lentamente',
      );
    }

    // Sin alertas para presión normal
    return null;
  }
}

class HealthAlert {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final AlertSeverity severity;
  final String? recommendation;

  HealthAlert({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.severity,
    this.recommendation,
  });
}

enum AlertSeverity {
  low,
  moderate,
  high,
  critical,
}
