part of '../physics_games.dart';

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
          const SizedBox(height: 12),
          const _GameSteps([
            'Биіктік, серіппе, масса және үйкеліс мәндерін слайдермен таңда.',
            'Бастапқы энергия үйкеліс шығынынан артық болсын.',
            'Шарды жібер. Мәреде кемінде 6 м/с болса, жеңесің; қайта өзгертіп көре аласың.',
          ]),
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
    final scene = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(scene, const Radius.circular(22)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6ECFF), Color(0xFFF3F5FF), Color(0xFFE4F8F3)],
        ).createShader(scene),
    );
    final start = Offset(25, 35 + (5 - height) * 14);
    final bend = Offset(size.width * .55, size.height - 28);
    final end = Offset(size.width - 20, size.height - 28);
    final road = Paint()
      ..color = const Color(0xFFCDD7ED)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      start.translate(0, 4),
      bend.translate(0, 4),
      Paint()
        ..color = primary.withValues(alpha: .10)
        ..strokeWidth = 23
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(start, bend, road);
    canvas.drawLine(bend, end, road);
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: .75)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start.translate(0, -3), bend.translate(0, -3), highlight);
    canvas.drawLine(bend.translate(0, -3), end.translate(0, -3), highlight);
    final traveled = progress * maximumProgress;
    final ball = traveled < .65
        ? Offset.lerp(start, bend, traveled / .65)!
        : Offset.lerp(bend, end, (traveled - .65) / .35)!;
    final center = ball.translate(0, -14);
    canvas.drawCircle(
      center,
      20,
      Paint()..color = primary.withValues(alpha: .13),
    );
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF91A7FF), primary],
        ).createShader(Rect.fromCircle(center: center, radius: 12)),
    );
    canvas.drawCircle(
      center.translate(-3, -4),
      3,
      Paint()..color = Colors.white,
    );
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
