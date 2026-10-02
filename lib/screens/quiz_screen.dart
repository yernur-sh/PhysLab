part of 'main_shell.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.quizIndex});
  final int quizIndex;
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int current = 0;
  int score = 0;
  int? selected;
  bool finishing = false;

  QuizSet get quiz => quizSets[widget.quizIndex];

  @override
  Widget build(BuildContext context) {
    final question = quiz.questions[current];
    return Scaffold(
      appBar: AppBar(title: Text(quiz.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SoftCard(
            color: const Color(0xFFE9EDFF),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'СҰРАҚ ${current + 1} / ${quiz.questions.length}',
                      style: const TextStyle(
                        color: primary,
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.bolt_rounded, color: sunny, size: 18),
                    Text(
                      '${score * 10} ұпай',
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (current + 1) / quiz.questions.length,
                  minHeight: 7,
                  backgroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          Text(
            question.question,
            style: const TextStyle(
              color: navy,
              fontSize: 27,
              letterSpacing: -.7,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(question.answers.length, (index) {
            final isSelected = selected == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () => setState(() => selected = index),
                selected: isSelected,
                selectedTileColor: primary.withValues(alpha: .10),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? primary : const Color(0xFFE5E7F0),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: isSelected ? primary : canvas,
                  foregroundColor: isSelected ? Colors.white : navy,
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                title: Text(question.answers[index]),
              ),
            );
          }),
          const SizedBox(height: 20),
          PrimaryButton(
            label: current == quiz.questions.length - 1
                ? 'Нәтижені көру'
                : 'Келесі сұрақ',
            loading: finishing,
            onPressed: selected == null || finishing ? null : _next,
          ),
        ],
      ),
    );
  }

  Future<void> _next() async {
    if (selected == quiz.questions[current].correct) score++;
    if (current == quiz.questions.length - 1) {
      setState(() => finishing = true);
      int earned = 0;
      String? saveError;
      try {
        earned = await AppStateScope.of(
          context,
        ).saveQuizResult(widget.quizIndex, score);
      } catch (error) {
        saveError = 'Ұпай сақталмады: $error';
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            quizIndex: widget.quizIndex,
            correct: score,
            earnedPoints: earned,
            saveError: saveError,
          ),
        ),
      );
    } else {
      setState(() {
        current++;
        selected = null;
      });
    }
  }
}
