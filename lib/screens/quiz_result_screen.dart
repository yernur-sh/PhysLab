part of 'main_shell.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.quizIndex,
    required this.correct,
    required this.earnedPoints,
    this.saveError,
  });
  final int quizIndex;
  final int correct;
  final int earnedPoints;
  final String? saveError;

  @override
  Widget build(BuildContext context) {
    final total = quizSets[quizIndex].questions.length;
    final best = AppStateScope.of(context).quizBestScores[quizIndex] ?? 0;
    return _ResultPage(
      title: '${quizSets[quizIndex].title} · нәтиже',
      headline: correct == total ? 'Керемет нәтиже!' : 'Тест аяқталды!',
      subtitle: 'Әр әрекетің біліміңді нығайтады.',
      correct: correct,
      total: total,
      details: [
        ('Жаңа ұпай', '+$earnedPoints', Icons.bolt_rounded),
        ('Ең жақсысы', '$best / $total', Icons.emoji_events_rounded),
      ],
      saveError: saveError,
      primaryLabel: 'Практикаға оралу',
      onPrimary: () => Navigator.of(context).pop(),
      onRetry: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => QuizScreen(quizIndex: quizIndex)),
      ),
    );
  }
}

class TopicCheckResultScreen extends StatelessWidget {
  const TopicCheckResultScreen({
    super.key,
    required this.topic,
    required this.correct,
    required this.bestPercent,
  });
  final TopicData topic;
  final int correct;
  final int bestPercent;

  @override
  Widget build(BuildContext context) => _ResultPage(
    title: 'Тақырып нәтижесі',
    headline: correct >= 4 ? 'Тақырып меңгерілді!' : 'Тағы бір қайталап көр',
    subtitle: topic.title,
    correct: correct,
    total: 5,
    details: [
      ('Меңгеру деңгейі', '$bestPercent%', Icons.school_rounded),
      ('Өту шегі', '80%', Icons.flag_rounded),
    ],
    primaryLabel: 'Тақырыпқа оралу',
    onPrimary: () => Navigator.of(context).pop(),
    onRetry: () => Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TopicCheckScreen(topic: topic)),
    ),
  );
}

class _ResultPage extends StatelessWidget {
  const _ResultPage({
    required this.title,
    required this.headline,
    required this.subtitle,
    required this.correct,
    required this.total,
    required this.details,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onRetry,
    this.saveError,
  });
  final String title;
  final String headline;
  final String subtitle;
  final int correct;
  final int total;
  final List<(String, String, IconData)> details;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onRetry;
  final String? saveError;

  @override
  Widget build(BuildContext context) {
    final percent = correct / total;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8EEFF), Color(0xFFF4F7FF)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFDDE6FA)),
            ),
            child: Column(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: sunny, size: 38),
                const SizedBox(height: 15),
                Text(
                  headline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: muted),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: 154,
                  height: 154,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: percent,
                          strokeWidth: 13,
                          backgroundColor: Colors.white,
                          color: primary,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(percent * 100).round()}%',
                            style: const TextStyle(
                              color: navy,
                              fontSize: 35,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '$correct / $total дұрыс',
                            style: const TextStyle(color: muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: details
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SoftCard(
                        child: Column(
                          children: [
                            Icon(item.$3, color: primary),
                            const SizedBox(height: 8),
                            Text(
                              item.$2,
                              style: const TextStyle(
                                color: navy,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              item.$1,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (saveError != null) ...[
            const SizedBox(height: 16),
            SoftCard(
              color: const Color(0xFFFFEEEE),
              child: Text(saveError!, style: const TextStyle(color: coral)),
            ),
          ],
          const SizedBox(height: 25),
          PrimaryButton(
            label: primaryLabel,
            onPressed: onPrimary,
            icon: Icons.arrow_back_rounded,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Қайта тапсыру'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}
