import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HealthTipsWidget extends StatefulWidget {
  const HealthTipsWidget({Key? key}) : super(key: key);

  @override
  State<HealthTipsWidget> createState() => _HealthTipsWidgetState();
}

class _HealthTipsWidgetState extends State<HealthTipsWidget> {
  int _currentTipIndex = 0;
  late PageController _pageController;

  final List<HealthTip> _tips = [
    HealthTip(
      title: 'Ejercicio Regular',
      content:
          'Realiza al menos 30 minutos de ejercicio moderado 5 días a la semana para mantener una presión arterial saludable.',
      icon: Icons.fitness_center,
      color: Colors.green,
    ),
    HealthTip(
      title: 'Alimentación Saludable',
      content:
          'Reduce el consumo de sodio y aumenta frutas y verduras en tu dieta diaria.',
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    HealthTip(
      title: 'Controla el Estrés',
      content:
          'Practica técnicas de relajación como meditación o respiración profunda.',
      icon: Icons.spa,
      color: Colors.purple,
    ),
    HealthTip(
      title: 'Duerme Bien',
      content: 'Mantén un horario de sueño regular de 7-8 horas por noche.',
      icon: Icons.bedtime,
      color: Colors.blue,
    ),
    HealthTip(
      title: 'Evita el Tabaco',
      content:
          'Dejar de fumar mejora significativamente la salud cardiovascular.',
      icon: Icons.smoke_free,
      color: Colors.red,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _autoRotateTips();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _autoRotateTips() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
        });
        _pageController.animateToPage(
          _currentTipIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _autoRotateTips();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.blue[50]!,
            Colors.blue[100]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Consejos de Salud',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentTipIndex + 1}/${_tips.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentTipIndex = index);
              },
              itemCount: _tips.length,
              itemBuilder: (context, index) {
                final tip = _tips[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tip.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: tip.color.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          tip.icon,
                          color: tip.color,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tip.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: tip.color,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tip.content,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[700],
                                    height: 1.3,
                                  ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
  }
}

class HealthTip {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  HealthTip({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });
}
