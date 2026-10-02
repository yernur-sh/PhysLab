part of 'main_shell.dart';

class MasteredTopicsScreen extends StatelessWidget {
  const MasteredTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mastery = AppStateScope.of(context).topicMastery;
    final mastered =
        mastery.entries.where((entry) => entry.value >= 80).toList()
          ..sort((a, b) {
            final first = physicsTopics.indexWhere(
              (topic) => topic.title == a.key,
            );
            final second = physicsTopics.indexWhere(
              (topic) => topic.title == b.key,
            );
            return (first < 0 ? physicsTopics.length : first).compareTo(
              second < 0 ? physicsTopics.length : second,
            );
          });
    return Scaffold(
      appBar: AppBar(title: const Text('Меңгерілген тақырыптар')),
      body: mastered.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'Тақырыпты оқып, 5 сұрақтың кемінде 4-іне дұрыс жауап берсең, нәтиже осында көрінеді.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 15),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              itemCount: mastered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = mastered[index];
                return SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: mint),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                color: navy,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${entry.value}%',
                            style: const TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: entry.value / 100,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: const Color(0xFFE9EDFF),
                        color: mint,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
