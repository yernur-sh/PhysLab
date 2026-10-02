part of 'main_shell.dart';

class TopicCheckScreen extends StatefulWidget {
  const TopicCheckScreen({super.key, required this.topic});
  final TopicData topic;

  @override
  State<TopicCheckScreen> createState() => _TopicCheckScreenState();
}

class _TopicCheckScreenState extends State<TopicCheckScreen> {
  late final questions = topicCheckQuestions(widget.topic);
  int current = 0;
  int correct = 0;
  int? selected;
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    final question = questions[current];
    return Scaffold(
      appBar: AppBar(title: const Text('Тақырыпты тексеру')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF17294D), Color(0xFF4F65CB)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.topic.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${current + 1} / 5 сұрақ · өту үшін кемінде 4 дұрыс жауап',
                  style: const TextStyle(color: Color(0xFFDCE4FF)),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (current + 1) / questions.length,
                  backgroundColor: Colors.white24,
                  color: mint,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text(
            question.question,
            style: const TextStyle(
              color: navy,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(question.answers.length, (index) {
            final chosen = selected == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () => setState(() => selected = index),
                tileColor: chosen ? const Color(0xFFE9EDFF) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: chosen ? primary : const Color(0xFFE5E7F0),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: chosen ? primary : canvas,
                  foregroundColor: chosen ? Colors.white : navy,
                  child: Text(String.fromCharCode(65 + index)),
                ),
                title: Text(question.answers[index]),
              ),
            );
          }),
          const SizedBox(height: 15),
          PrimaryButton(
            label: current == 4 ? 'Нәтижені көру' : 'Келесі сұрақ',
            loading: saving,
            onPressed: selected == null || saving ? null : _next,
          ),
        ],
      ),
    );
  }

  Future<void> _next() async {
    if (selected == questions[current].correct) correct++;
    if (current < questions.length - 1) {
      setState(() {
        current++;
        selected = null;
      });
      return;
    }
    setState(() => saving = true);
    int best;
    try {
      best = await AppStateScope.of(
        context,
      ).saveTopicResult(widget.topic.title, correct);
    } catch (error) {
      if (mounted) {
        setState(() => saving = false);
        showMessage(context, 'Нәтиже сақталмады: $error', error: true);
      }
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TopicCheckResultScreen(
          topic: widget.topic,
          correct: correct,
          bestPercent: best,
        ),
      ),
    );
  }
}
