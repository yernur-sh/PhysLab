part of 'main_shell.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key, this.responder});
  final PhysAiResponder? responder;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  late final responder = widget.responder ?? const GroqPhysAiResponder();
  final messages = <({bool user, String text})>[
    (
      user: false,
      text: 'Сәлем! Мен PhysAI көмекшісімін. Физикадан нені түсіндірейін?',
    ),
  ];
  String? pendingQuestion;
  String? errorMessage;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = pendingQuestion != null;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(18),
            itemCount: messages.length + (loading ? 2 : 0),
            itemBuilder: (context, index) {
              if (index == messages.length) {
                return _PhysAiBubble(user: true, text: pendingQuestion!);
              }
              if (index == messages.length + 1) {
                return const _PhysAiBubble(user: false, loading: true);
              }
              final item = messages[index];
              return _PhysAiBubble(user: item.user, text: item.text);
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: coral),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFB84747),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        enabled: !loading,
                        maxLength: 1200,
                        minLines: 1,
                        maxLines: 4,
                        onChanged: (_) => setState(() => errorMessage = null),
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Физикадан сұрағыңды жаз...',
                          isDense: true,
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      key: const Key('physai-send-button'),
                      onPressed: loading || controller.text.trim().isEmpty
                          ? null
                          : _send,
                      icon: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.arrow_upward_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: primary,
                        fixedSize: const Size(48, 48),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final question = controller.text.trim();
    if (question.isEmpty || pendingQuestion != null) return;
    final history = <PhysAiTurn>[
      for (final item in messages.skip(1))
        PhysAiTurn(role: item.user ? 'user' : 'assistant', content: item.text),
      PhysAiTurn(role: 'user', content: question),
    ];
    final recent = history.length > 11
        ? history.sublist(history.length - 11)
        : history;
    setState(() {
      pendingQuestion = question;
      errorMessage = null;
      controller.clear();
    });
    _scrollToBottom();
    try {
      final answer = await responder.reply(recent);
      if (!mounted) return;
      setState(() {
        messages
          ..add((user: true, text: question))
          ..add((user: false, text: answer));
        pendingQuestion = null;
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        pendingQuestion = null;
        controller.text = question;
        errorMessage = error is PhysAiException
            ? error.message
            : 'PhysAI жауап бере алмады. Қайта көріңіз.';
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }
}

class _PhysAiBubble extends StatelessWidget {
  const _PhysAiBubble({required this.user, this.text, this.loading = false});
  final bool user;
  final String? text;
  final bool loading;

  @override
  Widget build(BuildContext context) => Align(
    alignment: user ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 310),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: user ? primary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(user ? 20 : 4),
          bottomRight: Radius.circular(user ? 4 : 20),
        ),
        border: user ? null : Border.all(color: const Color(0xFFE8EAF2)),
      ),
      child: loading
          ? const SizedBox(
              width: 24,
              height: 15,
              child: Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primary,
                  ),
                ),
              ),
            )
          : Text(
              text ?? '',
              style: TextStyle(height: 1.4, color: user ? Colors.white : navy),
            ),
    ),
  );
}
