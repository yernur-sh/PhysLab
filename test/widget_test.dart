import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physlab/main.dart';

void main() {
  testWidgets('onboarding opens registration', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    await tester.pumpWidget(const PhysLabApp());

    expect(find.text('PhysLab'), findsOneWidget);
    expect(find.text('Физиканы сезініп үйрен'), findsOneWidget);

    await tester.tap(find.text('Өткізу'));
    await tester.pumpAndSettle();

    expect(find.text('Аккаунт құру'), findsOneWidget);
    expect(find.text('Кіру'), findsOneWidget);
  });

  testWidgets('teacher Google sign-in requires secret code', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    await tester.pumpWidget(const PhysLabApp());
    await tester.tap(find.text('Өткізу'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Мұғалім'));
    await tester.pumpAndSettle();

    final googleButton = tester.widget<OutlinedButton>(
      find.byKey(const Key('google-auth-button')),
    );
    expect(googleButton.onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('teacher-secret-field')),
      'pslm',
    );
    await tester.pump();

    final enabledGoogleButton = tester.widget<OutlinedButton>(
      find.byKey(const Key('google-auth-button')),
    );
    expect(enabledGoogleButton.onPressed, isNotNull);
  });
}
