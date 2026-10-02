import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physlab/main.dart';

void main() {
  testWidgets('onboarding opens registration', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    await tester.pumpWidget(const PhysLabApp());

    expect(find.text('PhysLab'), findsOneWidget);
    expect(find.text('Физиканы сезініп үйрен'), findsOneWidget);
    final mark = tester.widget<Image>(
      find.byKey(const Key('physlab-inner-icon')),
    );
    expect(
      (mark.image as AssetImage).assetName,
      'assets/branding/physlab_icon.png',
    );

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
    expect(find.text('СЕНІҢ ФИЗИКА ЗЕРТХАНАҢ'), findsNothing);
  });

  testWidgets('student Google registration needs no typed name', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    await tester.pumpWidget(const PhysLabApp());
    await tester.tap(find.text('Өткізу'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Аты-жөні'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('google-auth-button')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('login needs no role or teacher code and allows Google', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    await tester.pumpWidget(const PhysLabApp());
    await tester.tap(find.text('Өткізу'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Мұғалім'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('auth-mode-toggle')));
    await tester.pump();

    expect(find.text('Оқушы'), findsNothing);
    expect(find.text('Мұғалім'), findsNothing);
    expect(find.byKey(const Key('teacher-secret-field')), findsNothing);
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('google-auth-button')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('Google button uses official image and app uses Montserrat', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    await tester.pumpWidget(const PhysLabApp());
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.textTheme.bodyMedium?.fontFamily, 'Montserrat');
    await tester.tap(find.text('Өткізу'));
    await tester.pumpAndSettle();
    final icon = tester.widget<Image>(
      find.byKey(const Key('google-brand-icon')),
    );
    expect(
      (icon.image as AssetImage).assetName,
      'assets/branding/google_g.png',
    );
  });

  testWidgets('onboarding introduces the scientific project mentor', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    await tester.pumpWidget(const PhysLabApp());

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.text('Жалғастыру'));
      await tester.pumpAndSettle();
    }

    expect(find.text('ЖОБАНЫҢ ҒЫЛЫМИ ЖЕТЕКШІСІ'), findsOneWidget);
    expect(find.text('Жұмабаева Қарашаш\nБұхарбекқызы'), findsOneWidget);
    expect(find.text('Физика пәні мұғалімі'), findsOneWidget);
    expect(find.byKey(const Key('project-mentor-photo')), findsOneWidget);
    final mentorPhoto = tester.widget<Image>(
      find.byKey(const Key('project-mentor-photo')),
    );
    expect(mentorPhoto.fit, BoxFit.cover);
    expect(tester.takeException(), isNull);
  });
}
