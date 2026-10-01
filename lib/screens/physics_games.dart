import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../physics_game_models.dart';
import '../widgets/common.dart';

class _GamePage extends StatelessWidget {
  const _GamePage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(top: false, child: child),
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

class BallisticsGame extends StatefulWidget {
  const BallisticsGame({super.key});

  @override
  State<BallisticsGame> createState() => _BallisticsGameState();
}

class _BallisticsGameState extends State<BallisticsGame>
    with SingleTickerProviderStateMixin {
  static const targets = <(double, double)>[(45, 13), (38, 9), (50, 7)];
  late final AnimationController flight =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 750),
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          final target = targets[level];
          setState(() {
            hit = projectileHits(
              distance: target.$1,
              height: target.$2,
              speed: speed,
              angle: angle,
            );
            checked = true;
          });
          HapticFeedback.selectionClick();
        }
      });

  int level = 0;
  double speed = 23;
  double angle = 45;
  bool checked = false;
  bool hit = false;

  @override
  void dispose() {
    flight.dispose();
    super.dispose();
  }

  void _changeAim(VoidCallback action) {
    flight.stop();
    flight.reset();
    setState(() {
      action();
      checked = false;
    });
  }

  void _fire() {
    flight.reset();
    setState(() => checked = false);
    if (MediaQuery.disableAnimationsOf(context)) {
      flight.value = 1;
    } else {
      flight.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = targets[level];
    final predictedHeight = projectileHeightAt(target.$1, speed, angle);
    return _GamePage(
      title: 'Баллистика шебері',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          const _GameIntro(
            icon: Icons.my_location_rounded,
            title: 'Нысанаға дәл тигіз',
            description:
                'Бұрыш пен бастапқы жылдамдықты өзгертіп, парабола жолын тап.',
          ),
          const SizedBox(height: 16),
          SoftCard(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 8,
                  runSpacing: 5,
                  children: [
                    Text(
                      'КЕЗЕҢ ${level + 1} / ${targets.length}',
                      style: const TextStyle(
                        color: primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'x = ${target.$1.toInt()} м · h = ${target.$2.toInt()} м',
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: flight,
                  builder: (context, _) => SizedBox(
                    height: 235,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _ProjectilePainter(
                        distance: target.$1,
                        targetHeight: target.$2,
                        speed: speed,
                        angle: angle,
                        progress: flight.value,
                        hit: checked && hit,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'y = x·tan(α) − gx² / (2v₀²cos²(α))',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              children: [
                _GameSlider(
                  label: 'Бұрыш α',
                  value: angle,
                  min: 15,
                  max: 75,
                  unit: '°',
                  divisions: 60,
                  onChanged: (value) => _changeAim(() => angle = value),
                ),
                _GameSlider(
                  label: 'Бастапқы жылдамдық v₀',
                  value: speed,
                  min: 15,
                  max: 35,
                  unit: 'м/с',
                  divisions: 40,
                  onChanged: (value) => _changeAim(() => speed = value),
                ),
                Text(
                  'Нысана қашықтығындағы траектория биіктігі: '
                  '${predictedHeight.toStringAsFixed(1)} м',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          if (checked) ...[
            const SizedBox(height: 14),
            _GameFeedback(
              success: hit,
              text: hit
                  ? 'Дәл тиді! Қашықтық ${target.$1.toInt()} м, биіктік '
                        '${target.$2.toInt()} м шартын орындадың.'
                  : 'Мүлт кетті. Нысана биіктігі ${target.$2.toInt()} м. '
                        'Жылдамдықты немесе бұрышты өзгертіп көр.',
            ),
          ],
          const SizedBox(height: 16),
          PrimaryButton(
            label: hit && level < targets.length - 1 ? 'Келесі нысана' : 'Ату',
            icon: hit && level < targets.length - 1
                ? Icons.arrow_forward_rounded
                : Icons.sports_baseball_rounded,
            onPressed: () {
              if (hit && level < targets.length - 1) {
                _changeAim(() => level++);
              } else {
                _fire();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectilePainter extends CustomPainter {
  const _ProjectilePainter({
    required this.distance,
    required this.targetHeight,
    required this.speed,
    required this.angle,
    required this.progress,
    required this.hit,
  });

  final double distance;
  final double targetHeight;
  final double speed;
  final double angle;
  final double progress;
  final bool hit;

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height - 24;
    final xScale = (size.width - 32) / math.max(65, distance + 10);
    const yScale = 5.0;
    final baseline = Paint()
      ..color = const Color(0xFFD4DDF1)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, groundY), Offset(size.width, groundY), baseline);
    final target = Offset(
      16 + distance * xScale,
      groundY - targetHeight * yScale,
    );
    canvas.drawCircle(
      target,
      14,
      Paint()..color = (hit ? mint : coral).withValues(alpha: .22),
    );
    canvas.drawCircle(target, 8, Paint()..color = hit ? mint : coral);
    canvas.drawCircle(target, 3, Paint()..color = Colors.white);

    final path = Path()..moveTo(16, groundY);
    final maxX = math.min(
      projectileRange(speed, angle),
      (size.width - 32) / xScale,
    );
    for (var x = 1.0; x <= maxX; x += 1) {
      final y = projectileHeightAt(x, speed, angle);
      path.lineTo(16 + x * xScale, groundY - y * yScale);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = primary.withValues(alpha: .53)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(Offset(16, groundY - 6), 9, Paint()..color = navy);
    if (progress > 0) {
      final x = maxX * progress;
      final y = projectileHeightAt(x, speed, angle);
      canvas.drawCircle(
        Offset(16 + x * xScale, groundY - y * yScale),
        7,
        Paint()..color = sunny,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProjectilePainter oldDelegate) =>
      distance != oldDelegate.distance ||
      targetHeight != oldDelegate.targetHeight ||
      speed != oldDelegate.speed ||
      angle != oldDelegate.angle ||
      progress != oldDelegate.progress ||
      hit != oldDelegate.hit;
}

class CircuitGame extends StatefulWidget {
  const CircuitGame({super.key});

  @override
  State<CircuitGame> createState() => _CircuitGameState();
}

class _CircuitGameState extends State<CircuitGame> {
  final slots = List<CircuitPart?>.filled(4, null);
  bool switchClosed = false;
  double voltage = 9;
  double resistance = 5;
  CircuitState? result;

  String _name(CircuitPart part) => switch (part) {
    CircuitPart.battery => 'Батарея',
    CircuitPart.switchPart => 'Кілт',
    CircuitPart.resistor => 'Резистор',
    CircuitPart.lamp => 'Шам',
  };

  IconData _icon(CircuitPart part) => switch (part) {
    CircuitPart.battery => Icons.battery_full_rounded,
    CircuitPart.switchPart => Icons.toggle_on_rounded,
    CircuitPart.resistor => Icons.horizontal_rule_rounded,
    CircuitPart.lamp => Icons.lightbulb_rounded,
  };

  void _place(int index, CircuitPart part) {
    setState(() {
      final previous = slots.indexOf(part);
      if (previous >= 0) slots[previous] = null;
      slots[index] = part;
      result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = voltage / (resistance + 4);
    return _GamePage(
      title: 'Электрлік лабиринт',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          const _GameIntro(
            icon: Icons.electrical_services_rounded,
            title: 'Шамды жақ',
            description:
                'Төрт бөлшекті ұяшықтарға сүйре. Кілтті жауып, ток күшін қауіпсіз деңгейге келтір.',
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              children: [
                Text(
                  'Тізбектей жалғау',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 24) / 4;
                    return Row(
                      children: List.generate(4, (index) {
                        final part = slots[index];
                        return Padding(
                          padding: EdgeInsets.only(right: index == 3 ? 0 : 8),
                          child: DragTarget<CircuitPart>(
                            onAcceptWithDetails: (details) =>
                                _place(index, details.data),
                            builder: (context, candidates, rejected) => InkWell(
                              onTap: part == null
                                  ? null
                                  : () => setState(() {
                                      slots[index] = null;
                                      result = null;
                                    }),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: width,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: candidates.isNotEmpty
                                      ? const Color(0xFFE2F8EF)
                                      : const Color(0xFFEEF1FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFD6DDF5),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      part == null
                                          ? Icons.add_rounded
                                          : _icon(part),
                                      color: primary,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      part == null
                                          ? '${index + 1}'
                                          : _name(part),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: result == CircuitState.lit
                        ? const Color(0xFFFFF1C8)
                        : const Color(0xFFF4F6FC),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        color: result == CircuitState.lit ? sunny : muted,
                        size: 34,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        result == CircuitState.lit
                            ? 'Шам жанды!'
                            : 'Шам әлі жанған жоқ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Бөлшектерді сүйре',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CircuitPart.values.map((part) {
                    final used = slots.contains(part);
                    final chip = Chip(
                      avatar: Icon(_icon(part), size: 18, color: primary),
                      label: Text(_name(part)),
                      backgroundColor: used
                          ? const Color(0xFFE8EAF2)
                          : Colors.white,
                    );
                    return used
                        ? Opacity(opacity: .45, child: chip)
                        : Draggable<CircuitPart>(
                            data: part,
                            feedback: Material(
                              color: Colors.transparent,
                              child: chip,
                            ),
                            childWhenDragging: Opacity(
                              opacity: .35,
                              child: chip,
                            ),
                            child: chip,
                          );
                  }).toList(),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Кілт жабық'),
                  subtitle: const Text('Ток жүруі үшін кілтті жап'),
                  value: switchClosed,
                  onChanged: (value) => setState(() {
                    switchClosed = value;
                    result = null;
                  }),
                ),
                _GameSlider(
                  label: 'Кернеу U',
                  value: voltage,
                  min: 3,
                  max: 15,
                  unit: 'В',
                  divisions: 12,
                  onChanged: (value) => setState(() {
                    voltage = value;
                    result = null;
                  }),
                ),
                _GameSlider(
                  label: 'Резистор R',
                  value: resistance,
                  min: 1,
                  max: 20,
                  unit: 'Ω',
                  divisions: 19,
                  onChanged: (value) => setState(() {
                    resistance = value;
                    result = null;
                  }),
                ),
                Text(
                  'Ом заңы: I = U / (R + 4 Ω) = ${current.toStringAsFixed(2)} А',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 14),
            _GameFeedback(
              success: result == CircuitState.lit,
              text: switch (result!) {
                CircuitState.incomplete =>
                  'Төрт бөлшек те қажет. Бос ұяшықтарды толтыр.',
                CircuitState.openSwitch =>
                  'Кілт ашық: тізбек үзілген, ток жүрмейді.',
                CircuitState.tooDim =>
                  'Ток тым аз (${current.toStringAsFixed(2)} А). Кернеуді арттыр немесе кедергіні азайт.',
                CircuitState.lit =>
                  'Дұрыс! Тізбек тұйық, ток ${current.toStringAsFixed(2)} А — шам қауіпсіз жанып тұр.',
                CircuitState.overload =>
                  'Ток тым үлкен (${current.toStringAsFixed(2)} А). Кедергіні арттыр немесе кернеуді азайт.',
              },
            ),
          ],
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Тізбекті тексеру',
            icon: Icons.bolt_rounded,
            onPressed: () => setState(
              () => result = evaluateCircuit(
                parts: slots,
                switchClosed: switchClosed,
                voltage: voltage,
                resistance: resistance,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OpticsGame extends StatefulWidget {
  const OpticsGame({super.key});

  @override
  State<OpticsGame> createState() => _OpticsGameState();
}

class _OpticsGameState extends State<OpticsGame> {
  double objectDistance = 60;
  double focalLength = 20;
  double screenDistance = 50;
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    final imageDistance = lensImageDistance(objectDistance, focalLength);
    final focused = (screenDistance - imageDistance).abs() <= 3;
    return _GamePage(
      title: 'Оптикалық фокус',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          const _GameIntro(
            icon: Icons.flare_rounded,
            title: 'Кескінді экранға түсір',
            description:
                'Нәрсе, линза және экран арақашықтығын ретте. Нақты кескіннің фокусын тап.',
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              children: [
                const Text(
                  'Жинағыш линза',
                  style: TextStyle(color: navy, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 210,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _LensPainter(
                      objectDistance: objectDistance,
                      imageDistance: imageDistance,
                      screenDistance: screenDistance,
                      focused: checked && focused,
                    ),
                  ),
                ),
                const Text('1/f = 1/a + 1/b', style: TextStyle(color: muted)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              children: [
                _GameSlider(
                  label: 'Нәрсе қашықтығы a',
                  value: objectDistance,
                  min: 40,
                  max: 80,
                  unit: 'см',
                  divisions: 40,
                  onChanged: (v) => setState(() {
                    objectDistance = v;
                    checked = false;
                  }),
                ),
                _GameSlider(
                  label: 'Фокустық арақашықтық f',
                  value: focalLength,
                  min: 10,
                  max: 25,
                  unit: 'см',
                  divisions: 15,
                  onChanged: (v) => setState(() {
                    focalLength = v;
                    checked = false;
                  }),
                ),
                _GameSlider(
                  label: 'Экран қашықтығы b',
                  value: screenDistance,
                  min: 15,
                  max: 100,
                  unit: 'см',
                  divisions: 85,
                  onChanged: (v) => setState(() {
                    screenDistance = v;
                    checked = false;
                  }),
                ),
              ],
            ),
          ),
          if (checked) ...[
            const SizedBox(height: 14),
            _GameFeedback(
              success: focused,
              text: focused
                  ? 'Тамаша! b = af/(a−f) = ${imageDistance.toStringAsFixed(1)} см. Экран нақты кескін тұрған жерде.'
                  : 'Кескін бұлдырап тұр. Формула бойынша b ≈ ${imageDistance.toStringAsFixed(1)} см. Экранды соған жақындат.',
            ),
          ],
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Фокусты тексеру',
            icon: Icons.center_focus_strong_rounded,
            onPressed: () => setState(() => checked = true),
          ),
        ],
      ),
    );
  }
}

class _LensPainter extends CustomPainter {
  const _LensPainter({
    required this.objectDistance,
    required this.imageDistance,
    required this.screenDistance,
    required this.focused,
  });
  final double objectDistance, imageDistance, screenDistance;
  final bool focused;

  @override
  void paint(Canvas canvas, Size size) {
    final axis = size.height * .55;
    final lensX = size.width * .43;
    final scale = math.min((lensX - 22) / 85, (size.width - lensX - 15) / 110);
    final objectX = lensX - objectDistance * scale;
    final imageX = lensX + imageDistance * scale;
    final screenX = lensX + screenDistance * scale;
    final tip = Offset(objectX, axis - 48);
    final imageTip = Offset(imageX, axis + 48 * imageDistance / objectDistance);
    final line = Paint()
      ..color = const Color(0xFFCAD3EA)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(5, axis), Offset(size.width - 5, axis), line);
    final ray = Paint()
      ..color = sunny
      ..strokeWidth = 2;
    canvas.drawLine(tip, Offset(lensX, tip.dy), ray);
    canvas.drawLine(Offset(lensX, tip.dy), imageTip, ray);
    canvas.drawLine(
      tip,
      imageTip,
      Paint()
        ..color = primary.withValues(alpha: .55)
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(lensX, 25),
      Offset(lensX, size.height - 25),
      Paint()
        ..color = primary
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(screenX, 25),
      Offset(screenX, size.height - 25),
      Paint()
        ..color = focused ? mint : coral
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(objectX, axis),
      tip,
      Paint()
        ..color = navy
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(imageTip, 5, Paint()..color = sunny);
    final style = TextStyle(
      color: navy,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );
    for (final item in <(String, Offset)>[
      ('Нәрсе', Offset(objectX - 17, axis + 12)),
      ('Линза', Offset(lensX - 18, size.height - 18)),
      ('Экран', Offset(screenX - 18, size.height - 18)),
    ]) {
      final tp = TextPainter(
        text: TextSpan(text: item.$1, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, item.$2);
    }
  }

  @override
  bool shouldRepaint(covariant _LensPainter oldDelegate) =>
      objectDistance != oldDelegate.objectDistance ||
      imageDistance != oldDelegate.imageDistance ||
      screenDistance != oldDelegate.screenDistance ||
      focused != oldDelegate.focused;
}

class EnergyGame extends StatefulWidget {
  const EnergyGame({super.key});

  @override
  State<EnergyGame> createState() => _EnergyGameState();
}

class _EnergyGameState extends State<EnergyGame>
    with SingleTickerProviderStateMixin {
  late final AnimationController travel =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => checked = true);
        }
      });
  double height = 1;
  double compression = 0;
  double mass = 1;
  double friction = .2;
  bool checked = false;

  @override
  void dispose() {
    travel.dispose();
    super.dispose();
  }

  void _change(VoidCallback update) {
    travel.stop();
    travel.reset();
    setState(() {
      update();
      checked = false;
    });
  }

  void _run() {
    travel.reset();
    setState(() => checked = false);
    if (MediaQuery.disableAnimationsOf(context)) {
      travel.value = 1;
    } else {
      travel.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = mass * gravity * height + 20 * compression * compression;
    final loss = friction * mass * gravity * 5;
    final speed = finishSpeed(
      mass: mass,
      height: height,
      springCompression: compression,
      friction: friction,
    );
    final won = speed >= 6;
    return _GamePage(
      title: 'Энергия трансформері',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          const _GameIntro(
            icon: Icons.sports_baseball_rounded,
            title: 'Шарды мәреге жеткіз',
            description:
                'Биіктік пен серіппе энергиясын пайдалан. Үйкелісті жеңіп, мәреде 6 м/с жылдамдыққа жет.',
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              children: [
                const Text(
                  'Көлбеу жол · 5 м',
                  style: TextStyle(color: navy, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: travel,
                  builder: (context, _) => SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _EnergyPainter(
                        progress: travel.value,
                        won: checked && won,
                        height: height,
                        maximumProgress: math.min(1, speed / 6),
                      ),
                    ),
                  ),
                ),
                Text(
                  'E₀ = ${initial.toStringAsFixed(1)} Дж  ·  үйкеліс шығыны = ${loss.toStringAsFixed(1)} Дж',
                  style: const TextStyle(color: muted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              children: [
                _GameSlider(
                  label: 'Бастапқы биіктік h',
                  value: height,
                  min: .5,
                  max: 5,
                  unit: 'м',
                  divisions: 45,
                  onChanged: (v) => _change(() => height = v),
                ),
                _GameSlider(
                  label: 'Серіппе сығылуы x',
                  value: compression,
                  min: 0,
                  max: 1,
                  unit: 'м',
                  divisions: 10,
                  onChanged: (v) => _change(() => compression = v),
                ),
                _GameSlider(
                  label: 'Шар массасы m',
                  value: mass,
                  min: .5,
                  max: 2,
                  unit: 'кг',
                  divisions: 15,
                  onChanged: (v) => _change(() => mass = v),
                ),
                _GameSlider(
                  label: 'Үйкеліс μ',
                  value: friction,
                  min: 0,
                  max: .5,
                  unit: '',
                  divisions: 10,
                  onChanged: (v) => _change(() => friction = v),
                ),
              ],
            ),
          ),
          if (checked) ...[
            const SizedBox(height: 14),
            _GameFeedback(
              success: won,
              text: won
                  ? 'Мәре! Потенциалдық және серіппе энергиясы қозғалысқа айналды. v = ${speed.toStringAsFixed(1)} м/с.'
                  : 'Мәреде v = ${speed.toStringAsFixed(1)} м/с. 6 м/с керек. Биіктікті не серіппені арттыр, үйкелісті азайт.',
            ),
          ],
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Шарды жіберу',
            icon: Icons.play_arrow_rounded,
            onPressed: _run,
          ),
        ],
      ),
    );
  }
}

class _EnergyPainter extends CustomPainter {
  const _EnergyPainter({
    required this.progress,
    required this.won,
    required this.height,
    required this.maximumProgress,
  });
  final double progress, height;
  final double maximumProgress;
  final bool won;

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(25, 35 + (5 - height) * 14);
    final bend = Offset(size.width * .55, size.height - 28);
    final end = Offset(size.width - 20, size.height - 28);
    final road = Paint()
      ..color = const Color(0xFFCDD7ED)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, bend, road);
    canvas.drawLine(bend, end, road);
    final traveled = progress * maximumProgress;
    final ball = traveled < .65
        ? Offset.lerp(start, bend, traveled / .65)!
        : Offset.lerp(bend, end, (traveled - .65) / .35)!;
    canvas.drawCircle(ball.translate(0, -11), 11, Paint()..color = primary);
    canvas.drawLine(
      Offset(end.dx, end.dy - 36),
      end,
      Paint()
        ..color = won ? mint : coral
        ..strokeWidth = 3,
    );
    canvas.drawRect(
      Rect.fromLTWH(end.dx - 1, end.dy - 36, 18, 12),
      Paint()..color = won ? mint : coral,
    );
  }

  @override
  bool shouldRepaint(covariant _EnergyPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      won != oldDelegate.won ||
      height != oldDelegate.height ||
      maximumProgress != oldDelegate.maximumProgress;
}

class FormulaRaceGame extends StatefulWidget {
  const FormulaRaceGame({super.key});

  @override
  State<FormulaRaceGame> createState() => _FormulaRaceGameState();
}

typedef _RaceQuestion = ({
  String prompt,
  List<String> answers,
  int correct,
  String hint,
});

class _FormulaRaceGameState extends State<FormulaRaceGame> {
  static const questions = <_RaceQuestion>[
    (
      prompt: '120 м жолды 10 с-та жүрді. Жылдамдық?',
      answers: ['10 м/с', '12 м/с', '20 м/с'],
      correct: 1,
      hint: 'v = s/t = 120/10',
    ),
    (
      prompt: 'm = 2 кг, a = 3 м/с². Күш?',
      answers: ['5 Н', '6 Н', '9 Н'],
      correct: 1,
      hint: 'F = ma = 2·3',
    ),
    (
      prompt: 'I = 2 А, R = 5 Ω. Кернеу?',
      answers: ['2,5 В', '7 В', '10 В'],
      correct: 2,
      hint: 'U = IR = 2·5',
    ),
    (
      prompt: 'F = 20 Н, s = 3 м. Жұмыс?',
      answers: ['23 Дж', '60 Дж', '6 Дж'],
      correct: 1,
      hint: 'A = Fs = 20·3',
    ),
    (
      prompt: 'm = 4 кг, v = 3 м/с. Импульс?',
      answers: ['7 кг·м/с', '12 кг·м/с', '1,3 кг·м/с'],
      correct: 1,
      hint: 'p = mv = 4·3',
    ),
    (
      prompt: 'A = 100 Дж, t = 5 с. Қуат?',
      answers: ['20 Вт', '95 Вт', '500 Вт'],
      correct: 0,
      hint: 'P = A/t = 100/5',
    ),
  ];

  Timer? timer;
  int questionIndex = 0;
  int secondsLeft = 12;
  int correctCount = 0;
  int rivalProgress = 0;
  bool started = false;
  bool finished = false;
  String? feedback;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _start() {
    timer?.cancel();
    setState(() {
      questionIndex = 0;
      secondsLeft = 12;
      correctCount = 0;
      rivalProgress = 0;
      feedback = null;
      started = true;
      finished = false;
    });
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (secondsLeft <= 1) {
        _answer(null);
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  void _answer(int? choice) {
    timer?.cancel();
    final question = questions[questionIndex];
    final correct = choice == question.correct;
    setState(() {
      if (correct) correctCount++;
      rivalProgress++;
      feedback = correct
          ? 'Дұрыс! ${question.hint}'
          : '${choice == null ? 'Уақыт бітті.' : 'Қате.'} ${question.hint} = ${question.answers[question.correct]}';
      if (questionIndex == questions.length - 1) {
        finished = true;
      } else {
        questionIndex++;
        secondsLeft = 12;
      }
    });
    if (!finished) _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final lead = correctCount >= rivalProgress - 1;
    return _GamePage(
      title: 'Жылдам формула',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          const _GameIntro(
            icon: Icons.directions_car_filled_rounded,
            title: 'Формула жарысы',
            description:
                'Әр есепке 12 секунд. Дұрыс жауап көлігіңді алға жылжытады, қате жауап қарсыласты оздырады.',
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              children: [
                _RaceLane(
                  label: 'Сен',
                  icon: Icons.directions_car_rounded,
                  progress: correctCount / questions.length,
                  color: primary,
                ),
                const SizedBox(height: 14),
                _RaceLane(
                  label: 'Қарсылас',
                  icon: Icons.directions_car_rounded,
                  progress: rivalProgress * .7 / questions.length,
                  color: coral,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (!started) ...[
            const _GameFeedback(
              success: true,
              text:
                  '6 есеп, әрқайсысына 12 секунд. Дұрыс жауап беріп, қарсыласты басып оз!',
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Жарысты бастау',
              icon: Icons.play_arrow_rounded,
              onPressed: _start,
            ),
          ] else if (finished) ...[
            _GameFeedback(
              success: lead,
              text:
                  '${lead ? 'Жеңіс!' : 'Қарсылас озды.'} '
                  '$correctCount/${questions.length} дұрыс жауап. '
                  '${feedback ?? ''}',
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Қайта жарысу',
              icon: Icons.replay_rounded,
              onPressed: _start,
            ),
          ] else ...[
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'СҰРАҚ ${questionIndex + 1} / ${questions.length}',
                        style: const TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$secondsLeft с',
                        style: TextStyle(
                          color: secondsLeft <= 4 ? coral : navy,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: secondsLeft / 12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    questions[questionIndex].prompt,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: OutlinedButton(
                        onPressed: () => _answer(index),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(questions[questionIndex].answers[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (feedback != null) ...[
              const SizedBox(height: 14),
              _GameFeedback(success: true, text: feedback!),
            ],
          ],
        ],
      ),
    );
  }
}

class _RaceLane extends StatelessWidget {
  const _RaceLane({
    required this.label,
    required this.icon,
    required this.progress,
    required this.color,
  });
  final String label;
  final IconData icon;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: navy, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      const SizedBox(height: 6),
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, _) => LinearProgressIndicator(
          value: value,
          minHeight: 10,
          color: color,
          backgroundColor: const Color(0xFFE9EDF7),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ],
  );
}
