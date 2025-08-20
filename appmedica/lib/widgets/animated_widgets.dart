import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class HeartBeatAnimation extends StatefulWidget {
  final double size;
  final Color color;
  final bool isBeating;

  const HeartBeatAnimation({
    Key? key,
    this.size = 100,
    this.color = Colors.red,
    this.isBeating = true,
  }) : super(key: key);

  @override
  State<HeartBeatAnimation> createState() => _HeartBeatAnimationState();
}

class _HeartBeatAnimationState extends State<HeartBeatAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isBeating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(HeartBeatAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBeating && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isBeating && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            Icons.favorite,
            size: widget.size,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class BloodPressureMeter extends StatelessWidget {
  final int systolic;
  final int diastolic;
  final String category;
  final Color color;

  const BloodPressureMeter({
    Key? key,
    required this.systolic,
    required this.diastolic,
    required this.category,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
            Colors.transparent,
          ],
          stops: const [0.3, 0.7, 1.0],
        ),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _getSystolicProgress(),
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: _getDiastolicProgress(),
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[100],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(color.withOpacity(0.6)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$systolic',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  Container(
                    height: 2,
                    width: 40,
                    color: Colors.grey[400],
                  ),
                  Text(
                    '$diastolic',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color.withOpacity(0.8),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'mmHg',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  double _getSystolicProgress() {
    // Normalizar la presión sistólica a un rango de 0-1
    // Rango típico: 90-180
    return math.max(0, math.min(1, (systolic - 90) / 90));
  }

  double _getDiastolicProgress() {
    // Normalizar la presión diastólica a un rango de 0-1
    // Rango típico: 60-120
    return math.max(0, math.min(1, (diastolic - 60) / 60));
  }
}

class PulseWaveAnimation extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final int pulse;

  const PulseWaveAnimation({
    Key? key,
    this.width = 300,
    this.height = 100,
    this.color = Colors.red,
    required this.pulse,
  }) : super(key: key);

  @override
  State<PulseWaveAnimation> createState() => _PulseWaveAnimationState();
}

class _PulseWaveAnimationState extends State<PulseWaveAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (60000 / widget.pulse).round()),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: PulseWavePainter(
              progress: _controller.value,
              color: widget.color,
            ),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

class PulseWavePainter extends CustomPainter {
  final double progress;
  final Color color;

  PulseWavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerY = size.height / 2;
    final stepX = size.width / 100;

    path.moveTo(0, centerY);

    for (int i = 0; i <= 100; i++) {
      final x = i * stepX;
      final waveProgress = (progress + i / 100) % 1;

      double y = centerY;
      if (waveProgress < 0.2) {
        // Pico del pulso
        y = centerY - 30 * math.sin(waveProgress * math.pi / 0.2);
      } else if (waveProgress < 0.4) {
        // Descenso
        y = centerY + 10 * math.sin((waveProgress - 0.2) * math.pi / 0.2);
      } else {
        // Línea base
        y = centerY +
            2 *
                math.sin(waveProgress * math.pi * 2) *
                math.exp(-(waveProgress - 0.4) * 5);
      }

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PulseWavePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
