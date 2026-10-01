import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physlab/physics_game_models.dart';
import 'package:physlab/screens/physics_games.dart';

void main() {
  test('projectile trajectory and hit test follow kinematics', () {
    expect(projectileRange(20, 45), closeTo(40.82, .02));
    expect(projectileHeightAt(20, 20, 45), closeTo(10.2, .02));
    expect(
      projectileHits(distance: 20, height: 10.2, speed: 20, angle: 45),
      isTrue,
    );
    expect(
      projectileHits(distance: 50, height: 10, speed: 20, angle: 45),
      isFalse,
    );
  });

  test('series circuit requires all components and safe current', () {
    const parts = CircuitPart.values;
    expect(
      evaluateCircuit(
        parts: [null, ...parts.skip(1)],
        switchClosed: true,
        voltage: 9,
        resistance: 5,
      ),
      CircuitState.incomplete,
    );
    expect(
      evaluateCircuit(
        parts: parts,
        switchClosed: false,
        voltage: 9,
        resistance: 5,
      ),
      CircuitState.openSwitch,
    );
    expect(
      evaluateCircuit(
        parts: parts,
        switchClosed: true,
        voltage: 9,
        resistance: 5,
      ),
      CircuitState.lit,
    );
    expect(
      evaluateCircuit(
        parts: parts,
        switchClosed: true,
        voltage: 15,
        resistance: 1,
      ),
      CircuitState.overload,
    );
    expect(
      evaluateCircuit(
        parts: parts,
        switchClosed: true,
        voltage: 3,
        resistance: 20,
      ),
      CircuitState.tooDim,
    );
  });

  test('lens and energy calculations have expected results', () {
    expect(lensImageDistance(60, 20), closeTo(30, .001));
    expect(
      finishSpeed(mass: 1, height: 3, springCompression: 0, friction: 0),
      closeTo(7.67, .02),
    );
    expect(
      finishSpeed(mass: 1, height: 1, springCompression: 0, friction: .5),
      0,
    );
  });

  for (final game in <(Widget, String)>[
    (const BallisticsGame(), 'Баллистика шебері'),
    (const CircuitGame(), 'Электрлік лабиринт'),
    (const OpticsGame(), 'Оптикалық фокус'),
    (const EnergyGame(), 'Энергия трансформері'),
    (const FormulaRaceGame(), 'Жылдам формула'),
  ]) {
    testWidgets('${game.$2} screen opens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 900));
      await tester.pumpWidget(MaterialApp(home: game.$1));
      expect(find.text(game.$2), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('race answers move the player', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    await tester.pumpWidget(const MaterialApp(home: FormulaRaceGame()));
    await tester.tap(find.text('Жарысты бастау'));
    await tester.pump();
    expect(find.text('120 м жолды 10 с-та жүрді. Жылдамдық?'), findsOneWidget);
    await tester.tap(find.text('12 м/с'));
    await tester.pump();
    expect(find.text('m = 2 кг, a = 3 м/с². Күш?'), findsOneWidget);
    expect(find.textContaining('Дұрыс!'), findsOneWidget);
  });
}
