import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physlab/app_state.dart';
import 'package:physlab/physics_data.dart';
import 'package:physlab/screens/main_shell.dart';
import 'package:physlab/widgets/common.dart';

void main() {
  testWidgets('home layout stays within a phone viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    final state = AppState()
      ..signIn(
        const UserProfile(
          name: 'Айдана Қ.',
          email: 'aidana@example.com',
          role: UserRole.student,
        ),
      );
    await tester.pumpWidget(
      AppStateScope(
        notifier: state,
        child: const MaterialApp(home: MainShell()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Зертхана'), findsOneWidget);
    expect(find.byKey(const Key('profile-button')), findsOneWidget);

    await tester.tap(find.text('Тақырып'));
    await tester.pumpAndSettle();
    expect(
      physicsTopics.map((topic) => topic.grade),
      orderedEquals([7, 7, 8, 8, 9, 9, 10, 10, 11, 11]),
    );
    expect(
      tester.getTopLeft(find.byType(IosSegmentedControl)).dy,
      lessThan(230),
    );
    expect(find.text('Формулалар'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('profile-button')));
    await tester.pumpAndSettle();
    expect(find.text('Профиль'), findsOneWidget);
  });

  testWidgets('safe header and distinct topic/formula lessons', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    final state = AppState()
      ..signIn(
        const UserProfile(
          name: 'Айдана',
          email: 'aidana@example.com',
          role: UserRole.student,
        ),
      );
    await tester.pumpWidget(
      AppStateScope(
        notifier: state,
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(430, 900),
              padding: EdgeInsets.only(top: 44, bottom: 24),
            ),
            child: MainShell(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('PhysLab')).dy,
      greaterThanOrEqualTo(44),
    );

    await tester.tap(find.text('Тақырып'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byType(IosSegmentedControl)).dy,
      lessThan(230),
    );
    expect(find.text('7–11 сынып тақырыптары оқу ретімен'), findsOneWidget);
    expect(find.text('Механикалық қозғалыс'), findsOneWidget);
    await tester.tap(find.text('Механикалық қозғалыс'));
    await tester.pumpAndSettle();
    expect(find.text('Негізгі ұғымдар'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Мысал есеп'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Мысал есеп'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Формулалар'));
    await tester.pumpAndSettle();
    expect(find.text('Формулалар жинағы'), findsOneWidget);
    await tester.tap(find.text('v = s / t'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Формула қалай шығады?'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Формула қалай шығады?'), findsOneWidget);
    expect(find.text('Таңбалар мен өлшемдер'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
