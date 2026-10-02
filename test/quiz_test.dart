import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physlab/app_state.dart';
import 'package:physlab/physics_data.dart';
import 'package:physlab/screens/main_shell.dart';

void main() {
  test('ten distinct quizzes each contain fifteen valid questions', () {
    expect(quizSets.length, 10);
    for (final quiz in quizSets) {
      expect(quiz.questions.length, 15, reason: quiz.title);
      for (final question in quiz.questions) {
        expect(question.answers.length, 4);
        expect(question.correct, inInclusiveRange(0, 3));
      }
    }
  });

  test('quiz points increase only when a personal best improves', () async {
    final state = AppState();
    state.signIn(
      const UserProfile(
        name: 'Оқушы',
        email: 'student@example.com',
        role: UserRole.student,
      ),
    );
    expect(await state.saveQuizResult(0, 12), 120);
    expect(await state.saveQuizResult(0, 8), 0);
    expect(await state.saveQuizResult(0, 15), 30);
    expect(await state.saveQuizResult(1, 10), 100);
    expect(state.points, 250);
    expect(state.fullyCompletedQuizzes, 1);
    expect(await state.saveQuizResult(1, 99), 50);
    expect(state.quizBestScores[1], 15);
    expect(state.fullyCompletedQuizzes, 2);
    state.dispose();
  });

  test(
    'every topic has five checks and mastery is saved at 80 percent',
    () async {
      for (final topic in physicsTopics) {
        final questions = topicCheckQuestions(topic);
        expect(questions.length, 5, reason: topic.title);
        for (final question in questions) {
          expect(question.answers.length, 4);
          expect(question.answers.toSet().length, 4);
          expect(question.correct, inInclusiveRange(0, 3));
          expect(
            question.answers.every(
              (answer) => !answer.trimLeft().startsWith('Жауабы:'),
            ),
            isTrue,
          );
        }
      }
      final state = AppState()
        ..signIn(
          const UserProfile(
            name: 'Оқушы',
            email: 'student@example.com',
            role: UserRole.student,
          ),
        );
      expect(await state.saveTopicResult(physicsTopics.first.title, 3), 60);
      expect(state.masteredTopicCount, 0);
      expect(await state.saveTopicResult(physicsTopics.first.title, 4), 80);
      expect(state.masteredTopicCount, 1);
      state.dispose();
    },
  );

  testWidgets('quiz remains usable on a small phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    final state = AppState()
      ..signIn(
        const UserProfile(
          name: 'Оқушы',
          email: 'student@example.com',
          role: UserRole.student,
        ),
      );
    await tester.pumpWidget(
      AppStateScope(
        notifier: state,
        child: const MaterialApp(home: QuizScreen(quizIndex: 0)),
      ),
    );
    expect(find.text('СҰРАҚ 1 / 15'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(ListTile).first);
    await tester.pump();
    await tester.ensureVisible(find.text('Келесі сұрақ'));
    await tester.tap(find.text('Келесі сұрақ'));
    await tester.pumpAndSettle();
    expect(find.text('СҰРАҚ 2 / 15'), findsOneWidget);
    expect(tester.takeException(), isNull);
    state.dispose();
  });
}
