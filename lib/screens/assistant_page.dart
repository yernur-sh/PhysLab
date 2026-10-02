part of 'main_shell.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final controller = TextEditingController();
  final messages = <({bool user, String text})>[
    (
      user: false,
      text: 'Сәлем! Мен PhysAI көмекшісімін. Физикадан нені түсіндірейін?',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final item = messages[index];
              return Align(
                alignment: item.user
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 310),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: item.user ? primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(item.user ? 20 : 4),
                      bottomRight: Radius.circular(item.user ? 4 : 20),
                    ),
                    border: item.user
                        ? null
                        : Border.all(color: const Color(0xFFE8EAF2)),
                  ),
                  child: Text(
                    item.text,
                    style: TextStyle(
                      height: 1.4,
                      color: item.user ? Colors.white : navy,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: 'Сұрағыңды жаз...',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: _send,
                icon: const Icon(Icons.arrow_upward_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: primary,
                  fixedSize: const Size(48, 48),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _send() {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    setState(() {
      messages.add((user: true, text: value));
      messages.add((
        user: false,
        text: value.contains('F = ma')
            ? 'F = ma — Ньютонның екінші заңы. Мұнда F — күш (Н), m — масса (кг), a — үдеу (м/с²). Мысалы, 2 кг денеге 6 Н күш әсер етсе, үдеу a = 6/2 = 3 м/с².'
            : 'Сұрағыңды түсіндім. Берілген шамаларды және нені табу керегін жазсаң, шешу жолын қадамдап көрсетемін.',
      ));
      controller.clear();
    });
  }
}
