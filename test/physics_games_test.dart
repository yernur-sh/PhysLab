import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physlab/physics_game_models.dart';
import 'package:physlab/physics_data.dart';
import 'package:physlab/screens/physics_games.dart';
import 'package:physlab/screens/main_shell.dart';

void main() {
  test('lesson formulas avoid unsupported subscript letters', () {
    final unsupported = RegExp(r'[ₐ-₟⁻ⁿ]');
    for (final topic in physicsTopics) {
      final texts = <String>[
        topic.formula,
        topic.explanation,
        ...topic.keyIdeas,
        topic.topicQuestion,
        ...topic.topicSteps,
        topic.topicAnswer,
        ...topic.symbols,
        ...topic.derivation,
        topic.formulaQuestion,
        ...topic.formulaSteps,
        topic.formulaAnswer,
      ];
      for (final value in texts) {
        expect(
          unsupported.hasMatch(value),
          isFalse,
          reason: '${topic.title}: $value',
        );
      }
    }
  });

  testWidgets('formula builder shows readable potential energy notation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(const MaterialApp(home: FormulaBuilderGame()));
    expect(find.text('E_p = '), findsOneWidget);
    expect(find.textContaining('ₚ'), findsNothing);
  });

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
    (const OpticsGame(), 'Оптикалық фокус'),
    (const EnergyGame(), 'Энергия трансформері'),
  ]) {
    testWidgets('${game.$2} screen opens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 900));
      await tester.pumpWidget(MaterialApp(home: game.$1));
      expect(find.text(game.$2), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ballistics target can be placed repeatedly without stages', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    await tester.pumpWidget(const MaterialApp(home: BallisticsGame()));
    expect(find.textContaining('КЕЗЕҢ'), findsNothing);
    final area = find.byKey(const Key('ballistics-target-area'));
    await tester.tapAt(tester.getTopLeft(area) + const Offset(90, 80));
    await tester.pump();
    final firstTarget = tester.widget<Text>(find.textContaining('x = ')).data;
    await tester.tapAt(tester.getTopLeft(area) + const Offset(160, 100));
    await tester.pump();
    final secondTarget = tester.widget<Text>(find.textContaining('x = ')).data;
    expect(secondTarget, isNot(firstTarget));
  });

  for (final game in <Widget>[const FormulaBuilderGame(), const MatchGame()]) {
    testWidgets('${game.runtimeType} stays usable with Montserrat', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'Montserrat'),
          home: game,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
