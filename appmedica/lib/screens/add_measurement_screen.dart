import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/blood_pressure.dart';
import '../services/api_service.dart';
import '../widgets/animated_widgets.dart';

class AddMeasurementScreen extends StatefulWidget {
  const AddMeasurementScreen({Key? key}) : super(key: key);

  @override
  State<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _pulseController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  DateTime _selectedDateTime = DateTime.now();

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final bloodPressure = BloodPressure(
        systolic: int.parse(_systolicController.text),
        diastolic: int.parse(_diastolicController.text),
        pulse: int.parse(_pulseController.text),
        timestamp: _selectedDateTime,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        source: 'manual',
      );

      await ApiService.createBloodPressure(bloodPressure);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medición guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String? _validatePressure(String? value, String type) {
    if (value == null || value.isEmpty) {
      return 'Ingresa la presión $type';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Ingresa un número válido';
    }

    if (type == 'sistólica') {
      if (number < 70 || number > 250) {
        return 'Presión sistólica debe estar entre 70-250 mmHg';
      }
    } else if (type == 'diastólica') {
      if (number < 40 || number > 150) {
        return 'Presión diastólica debe estar entre 40-150 mmHg';
      }
    }

    return null;
  }

  String? _validatePulse(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa el pulso';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Ingresa un número válido';
    }

    if (number < 30 || number > 220) {
      return 'El pulso debe estar entre 30-220 bpm';
    }

    return null;
  }

  Widget _buildPreview() {
    if (_systolicController.text.isEmpty || _diastolicController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final systolic = int.tryParse(_systolicController.text);
    final diastolic = int.tryParse(_diastolicController.text);

    if (systolic == null || diastolic == null) {
      return const SizedBox.shrink();
    }

    final tempBP = BloodPressure(
      systolic: systolic,
      diastolic: diastolic,
      pulse: int.tryParse(_pulseController.text) ?? 70,
      timestamp: DateTime.now(),
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tempBP.categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tempBP.categoryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Vista previa',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'systolic/diastolic',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: tempBP.categoryColor,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                'mmHg',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tempBP.categoryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tempBP.category ?? 'Sin categoría',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Nueva Medición',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Icono animado
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: HeartBeatAnimation(
                  size: 60,
                  color: Colors.blue[600]!,
                ),
              ).animate().scale(delay: 200.ms, duration: 600.ms),

              const SizedBox(height: 24),

              // Campos de entrada
              _buildInputCard(),

              const SizedBox(height: 20),

              // Vista previa
              _buildPreview(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _saveMeasurement,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save),
        label: Text(_isLoading ? 'Guardando...' : 'Guardar'),
        backgroundColor: Colors.blue[600],
      ).animate().scale(delay: 400.ms, duration: 400.ms),
    );
  }

  Widget _buildInputCard() {
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
        children: [
          // Presión arterial
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _systolicController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Sistólica',
                    hintText: '120',
                    suffixText: 'mmHg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) => _validatePressure(value, 'sistólica'),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _diastolicController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Diastólica',
                    hintText: '80',
                    suffixText: 'mmHg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) => _validatePressure(value, 'diastólica'),
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Pulso
          TextFormField(
            controller: _pulseController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Pulso',
              hintText: '70',
              suffixText: 'bpm',
              prefixIcon: const Icon(Icons.favorite, color: Colors.red),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: _validatePulse,
            onChanged: (value) => setState(() {}),
          ),

          const SizedBox(height: 20),

          // Fecha y hora
          InkWell(
            onTap: _selectDateTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha y hora',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        Text(
                          '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} '
                          '${_selectedDateTime.hour.toString().padLeft(2, '0')}:'
                          '${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Notas
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notas (opcional)',
              hintText: 'Ej: Después del ejercicio, con estrés, etc.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, end: 0, duration: 400.ms);
  }
}
