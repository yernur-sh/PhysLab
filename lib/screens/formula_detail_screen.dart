part of 'main_shell.dart';

class FormulaDetailScreen extends StatelessWidget {
  const FormulaDetailScreen({super.key, required this.topic});

  final TopicData topic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Формула')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF17294D), Color(0xFF4F65CB)],
              ),
              borderRadius: BorderRadius.circular(29),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ФОРМУЛА · ${topic.title.toUpperCase()}',
                  style: const TextStyle(
                    color: Color(0xFFE3E8FF),
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  topic.formula,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  topic.subtitle,
                  style: const TextStyle(color: Color(0xFFDCE4FF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Таңбалар мен өлшемдер',
                  style: TextStyle(
                    color: navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 11),
                ...topic.symbols.map(
                  (symbol) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      symbol,
                      style: const TextStyle(height: 1.45, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Формула қалай шығады?',
                  style: TextStyle(
                    color: navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 15),
                ...List.generate(
                  topic.derivation.length,
                  (index) => _SolutionStep(
                    number: index + 1,
                    text: topic.derivation[index],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            color: const Color(0xFFFFF8E8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Формуланы қолдану',
                  style: TextStyle(
                    color: navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  topic.formulaQuestion,
                  style: const TextStyle(
                    color: navy,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                ...List.generate(
                  topic.formulaSteps.length,
                  (index) => _SolutionStep(
                    number: index + 1,
                    text: topic.formulaSteps[index],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  topic.formulaAnswer,
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SolutionStep extends StatelessWidget {
  const _SolutionStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: primary.withValues(alpha: .12),
          foregroundColor: primary,
          child: Text(
            '$number',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(height: 1.48, fontSize: 15)),
        ),
      ],
    ),
  );
}
