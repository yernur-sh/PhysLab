part of '../physics_games.dart';

class BallisticsGame extends StatefulWidget {
  const BallisticsGame({super.key});

  @override
  State<BallisticsGame> createState() => _BallisticsGameState();
}

class _BallisticsGameState extends State<BallisticsGame>
    with SingleTickerProviderStateMixin {
  final random = math.Random();
  late final AnimationController flight =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 750),
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            hit = projectileHits(
              distance: distance,
              height: targetHeight,
              speed: speed,
              angle: angle,
            );
            checked = true;
          });
          HapticFeedback.selectionClick();
        }
      });

  double distance = 45;
  double targetHeight = 13;
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
      hit = false;
    });
  }

  void _newTarget() {
    for (var attempt = 0; attempt < 30; attempt++) {
      final nextDistance = 18.0 + random.nextInt(38);
      final possibleSpeed = 20.0 + random.nextInt(13);
      final possibleAngle = 30.0 + random.nextInt(36);
      final possibleHeight = projectileHeightAt(
        nextDistance,
        possibleSpeed,
        possibleAngle,
      );
      if (possibleHeight >= 4 && possibleHeight <= 29) {
        _changeAim(() {
          distance = nextDistance;
          targetHeight = possibleHeight.roundToDouble();
        });
        return;
      }
    }
    _changeAim(() {
      distance = 30;
      targetHeight = 10;
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
    final predictedHeight = projectileHeightAt(distance, speed, angle);
    return _GamePage(
      title: 'Баллистика шебері',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          const _GameIntro(
            icon: Icons.my_location_rounded,
            title: 'Нысанаға дәл тигіз',
            description:
                'Алаңды түртіп нысана қой. Бұрыш пен жылдамдықты реттеп, қалағаныңша атып көр.',
          ),
          const SizedBox(height: 12),
          const _GameSteps([
            'Алаңды түртіп нысана қой немесе «Кездейсоқ жаңа нысана» таңда.',
            'Бұрыш пен жылдамдық слайдерлерін өзгертіп, көк траекторияны бақыла.',
            '«Ату» батырмасын бас. Қате болса параметрлерді өзгертіп қайта ат.',
          ]),
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
                      'ЕРКІН ЖАТТЫҒУ',
                      style: const TextStyle(
                        color: primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'x = ${distance.toInt()} м · h = ${targetHeight.toInt()} м',
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
                  builder: (context, _) => LayoutBuilder(
                    builder: (context, constraints) => GestureDetector(
                      key: const Key('ballistics-target-area'),
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) {
                        final xScale = (constraints.maxWidth - 32) / 70;
                        _changeAim(() {
                          distance = ((details.localPosition.dx - 16) / xScale)
                              .clamp(12, 60)
                              .roundToDouble();
                          targetHeight = ((211 - details.localPosition.dy) / 5)
                              .clamp(3, 30)
                              .roundToDouble();
                        });
                      },
                      child: SizedBox(
                        height: 235,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _ProjectilePainter(
                            distance: distance,
                            targetHeight: targetHeight,
                            speed: speed,
                            angle: angle,
                            progress: flight.value,
                            hit: checked && hit,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Алаңды түрт — нысана сол жерге қойылады. y = x·tan(α) − gx² / (2v₀²cos²(α))',
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
                  ? 'Дәл тиді! Қашықтық ${distance.toInt()} м, биіктік '
                        '${targetHeight.toInt()} м шартын орындадың.'
                  : 'Мүлт кетті. Нысана биіктігі ${targetHeight.toInt()} м. '
                        'Жылдамдықты немесе бұрышты өзгертіп көр.',
            ),
          ],
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Ату',
            icon: Icons.sports_baseball_rounded,
            onPressed: _fire,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _newTarget,
            icon: const Icon(Icons.shuffle_rounded),
            label: const Text('Кездейсоқ жаңа нысана'),
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
    final xScale = (size.width - 32) / 70;
    const yScale = 5.0;
    final field = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );
    canvas.drawRRect(
      field,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFDDE7FF), Color(0xFFF9FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Offset.zero & size),
    );
    canvas.save();
    canvas.clipRRect(field);
    for (var i = 1; i < 7; i++) {
      final x = 16 + i * 10 * xScale;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, groundY),
        Paint()..color = primary.withValues(alpha: .06),
      );
    }
    for (var i = 1; i < 4; i++) {
      final y = groundY - i * 10 * yScale;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()..color = primary.withValues(alpha: .06),
      );
    }
    final hill = Path()
      ..moveTo(0, groundY)
      ..quadraticBezierTo(
        size.width * .23,
        groundY - 25,
        size.width * .48,
        groundY - 6,
      )
      ..quadraticBezierTo(
        size.width * .75,
        groundY - 35,
        size.width,
        groundY - 12,
      )
      ..lineTo(size.width, groundY)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFFD3DEF7));
    final baseline = Paint()
      ..color = const Color(0xFF849ACA)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, groundY), Offset(size.width, groundY), baseline);
    final target = Offset(
      16 + distance * xScale,
      groundY - targetHeight * yScale,
    );
    canvas.drawCircle(
      target,
      21,
      Paint()..color = (hit ? mint : coral).withValues(alpha: .16),
    );
    canvas.drawCircle(target, 14, Paint()..color = Colors.white);
    canvas.drawCircle(target, 11, Paint()..color = hit ? mint : coral);
    canvas.drawCircle(target, 6, Paint()..color = Colors.white);
    canvas.drawCircle(target, 3, Paint()..color = hit ? mint : coral);

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
        ..color = primary.withValues(alpha: .74)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      Offset(16, groundY - 5),
      15,
      Paint()..color = primary.withValues(alpha: .18),
    );
    canvas.drawCircle(Offset(16, groundY - 5), 9, Paint()..color = navy);
    if (progress > 0) {
      final x = maxX * progress;
      final y = projectileHeightAt(x, speed, angle);
      final point = Offset(16 + x * xScale, groundY - y * yScale);
      canvas.drawCircle(
        point,
        16,
        Paint()..color = sunny.withValues(alpha: .25),
      );
      canvas.drawCircle(point, 7, Paint()..color = sunny);
    }
    canvas.restore();
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
