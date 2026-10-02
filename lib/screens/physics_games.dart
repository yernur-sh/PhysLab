import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../physics_game_models.dart';
import '../widgets/common.dart';

part 'games/ballistics_game.dart';
part 'games/optics_game.dart';
part 'games/energy_game.dart';

class _GamePage extends StatelessWidget {
  const _GamePage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: primary.withValues(alpha: .65),
          ),
        ),
      ],
    ),
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEFF2FF), canvas, Color(0xFFF8FAFF)],
        ),
      ),
      child: SafeArea(top: false, child: child),
    ),
  );
}

class _GameIntro extends StatelessWidget {
  const _GameIntro({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF17294D), Color(0xFF4F65CB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(25),
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(color: Color(0xFFE1E8FF), height: 1.35),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _GameSteps extends StatelessWidget {
  const _GameSteps(this.steps);
  final List<String> steps;

  @override
  Widget build(BuildContext context) => SoftCard(
    color: const Color(0xFFF7F9FF),
    padding: const EdgeInsets.all(15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Қалай ойнайды?',
          style: TextStyle(color: navy, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 9),
        ...List.generate(
          steps.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ',
                  style: const TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Expanded(
                  child: Text(
                    steps[index],
                    style: const TextStyle(color: navy, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _GameSlider extends StatelessWidget {
  const _GameSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;
  final int? divisions;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: navy, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} $unit',
            style: const TextStyle(color: primary, fontWeight: FontWeight.w900),
          ),
        ],
      ),
      Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    ],
  );
}

class _GameFeedback extends StatelessWidget {
  const _GameFeedback({required this.text, required this.success});
  final String text;
  final bool success;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: success ? const Color(0xFFE2F8EF) : const Color(0xFFFFF0E7),
      borderRadius: BorderRadius.circular(17),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          success ? Icons.check_circle_rounded : Icons.info_rounded,
          color: success ? const Color(0xFF168562) : coral,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: navy,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
