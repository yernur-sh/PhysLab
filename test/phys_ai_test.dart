import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physlab/screens/main_shell.dart';
import 'package:physlab/services/phys_ai_service.dart';

class FakePhysAi implements PhysAiResponder {
  FakePhysAi(this.answer);
  final Future<String> Function(List<PhysAiTurn>) answer;
  List<PhysAiTurn>? lastConversation;

  @override
  Future<String> reply(List<PhysAiTurn> conversation) {
    lastConversation = conversation;
    return answer(conversation);
  }
}

void main() {
  testWidgets('PhysAI sends the question and displays a real service reply', (
    tester,
  ) async {
    final fake = FakePhysAi((_) async => 'Күш = масса × үдеу.');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AssistantPage(responder: fake)),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Күш деген не?');
    await tester.pump();
    await tester.tap(find.byKey(const Key('physai-send-button')));
    await tester.pumpAndSettle();

    expect(fake.lastConversation?.last.role, 'user');
    expect(fake.lastConversation?.last.content, 'Күш деген не?');
    expect(find.text('Күш = масса × үдеу.'), findsOneWidget);
    expect(find.text('Күш деген не?'), findsOneWidget);
  });

  testWidgets('PhysAI keeps the question for retry after service failure', (
    tester,
  ) async {
    final fake = FakePhysAi(
      (_) async => throw const PhysAiException('Қосылым уақытша жоқ.'),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AssistantPage(responder: fake)),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Энергия деген не?');
    await tester.pump();
    await tester.tap(find.byKey(const Key('physai-send-button')));
    await tester.pumpAndSettle();

    expect(find.text('Қосылым уақытша жоқ.'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Энергия деген не?',
    );
  });
}
