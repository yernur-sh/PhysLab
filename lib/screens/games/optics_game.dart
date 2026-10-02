part of '../physics_games.dart';

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
                'Зат пен линза аралығын, фокусты және экран орнын ретте. Сәулелер түйіскен жерде айқын кескін пайда болады.',
          ),
          const SizedBox(height: 12),
          const _GameSteps([
            'Заттың линзаға дейінгі қашықтығын және фокусын таңда.',
            'Экранды сәулелер түйіскен жерге жылжыт: b = af/(a−f).',
            'Фокусты тексер. Қате болса экранды қайта жылжытып көр.',
          ]),
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
                  label: 'Зат қашықтығы a',
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
    final scene = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(scene, const Radius.circular(22)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE7EDFF), Color(0xFFF9F4FF), Color(0xFFE8FAF6)],
        ).createShader(scene),
    );
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
    for (var step = 1; step < 5; step++) {
      final x = size.width * step / 5;
      canvas.drawLine(
        Offset(x, 16),
        Offset(x, size.height - 16),
        Paint()..color = primary.withValues(alpha: .07),
      );
    }
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
        ..color = primary.withValues(alpha: .13)
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round,
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
    canvas.drawCircle(
      imageTip,
      focused ? 14 : 9,
      Paint()..color = (focused ? mint : sunny).withValues(alpha: .20),
    );
    final style = TextStyle(
      fontFamily: 'Montserrat',
      color: navy,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );
    for (final item in <(String, Offset)>[
      ('Зат', Offset(objectX - 10, axis + 12)),
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
