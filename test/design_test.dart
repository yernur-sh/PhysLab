import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physlab/app_state.dart';
import 'package:physlab/physics_data.dart';
import 'package:physlab/screens/main_shell.dart';
import 'package:physlab/widgets/common.dart';

void main() {
  testWidgets('quiz cards use an arrow instead of a play icon', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PracticePage())),
    );
    expect(find.byKey(const Key('quiz-start-affordance')), findsWidgets);
    expect(find.byIcon(Icons.play_circle_fill_rounded), findsNothing);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsWidgets);
  });

  testWidgets('PhysAI opens without the redundant greeting banner', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AssistantPage())),
    );
    expect(find.text('Сәлем, мен PhysAI'), findsNothing);
    expect(
      find.textContaining('Сәлем! Мен PhysAI көмекшісімін'),
      findsOneWidget,
    );
  });

  testWidgets('profile uses Google photo and email default avatar', (
    tester,
  ) async {
    const google = UserProfile(
      name: 'Google Оқушы',
      email: 'google@example.com',
      role: UserRole.student,
      isGoogleUser: true,
      photoUrl: 'https://example.com/avatar.png',
    );
    const email = UserProfile(
      name: 'Email Оқушы',
      email: 'email@example.com',
      role: UserRole.student,
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              UserAvatar(profile: google, radius: 20),
              UserAvatar(profile: email, radius: 20),
            ],
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('google-profile-photo')), findsOneWidget);
    expect(find.byKey(const Key('default-profile-avatar')), findsOneWidget);
  });

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
    expect(find.byKey(const Key('profile-button')), findsNothing);

    await tester.tap(find.text('Тақырып').last);
    await tester.pumpAndSettle();
    expect(physicsTopics.length, greaterThan(20));
    expect(
      physicsTopics.map((topic) => topic.grade).toList(),
      orderedEquals(physicsTopics.map((topic) => topic.grade).toList()..sort()),
    );
    expect(
      tester.getTopLeft(find.byType(IosSegmentedControl)).dy,
      lessThan(230),
    );
    expect(find.text('Формулалар'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    expect(find.text('Профиль'), findsNWidgets(2));
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

    await tester.tap(find.text('Тақырып').last);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byType(IosSegmentedControl)).dy,
      lessThan(230),
    );
    expect(
      find.text('Мектеп физикасының тақырыптары оқу ретімен'),
      findsOneWidget,
    );
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

  testWidgets('teacher can start another class after creating one', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    final state = AppState()
      ..signIn(
        const UserProfile(
          name: 'Мұғалім',
          email: 'teacher@example.com',
          role: UserRole.teacher,
        ),
      );
    state.classes.add(
      const PhysicsClass(name: 'Физика клубы', code: 'PHY-ABC234', grade: 8),
    );
    await tester.pumpWidget(
      AppStateScope(
        notifier: state,
        child: const MaterialApp(home: MainShell()),
      ),
    );
    expect(find.byKey(const Key('create-another-class')), findsOneWidget);
    expect(find.text('Физика клубы'), findsOneWidget);
    expect(tester.takeException(), isNull);
    state.dispose();
  });

  testWidgets('profile and quiz result show progress on a small phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    final state = AppState()
      ..signIn(
        const UserProfile(
          name: 'Айдана',
          email: 'aidana@example.com',
          role: UserRole.student,
        ),
      );
    await state.saveQuizResult(0, 15);
    await state.saveTopicResult(physicsTopics.first.title, 4);
    await tester.pumpWidget(
      AppStateScope(
        notifier: state,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    expect(find.text('150'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Меңгерілген тақырыптар'),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Меңгерілген тақырыптар'), findsOneWidget);
    expect(find.text(physicsTopics.first.title), findsNothing);
    await tester.tap(find.text('Меңгерілген тақырыптар'));
    await tester.pumpAndSettle();
    expect(find.byType(MasteredTopicsScreen), findsOneWidget);
    expect(find.text(physicsTopics.first.title), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      AppStateScope(
        notifier: state,
        child: const MaterialApp(
          home: QuizResultScreen(quizIndex: 0, correct: 15, earnedPoints: 150),
        ),
      ),
    );
    expect(find.text('Керемет нәтиже!'), findsOneWidget);
    expect(tester.takeException(), isNull);
    state.dispose();
  });
}
