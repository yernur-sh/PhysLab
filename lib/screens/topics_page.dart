part of 'main_shell.dart';

class TopicsPage extends StatefulWidget {
  const TopicsPage({super.key});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  bool formulas = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: IosSegmentedControl(
            labels: const ['Тақырыптар', 'Формулалар'],
            selectedIndex: formulas ? 1 : 0,
            onChanged: (value) => setState(() => formulas = value == 1),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(
              milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 200,
            ),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: .985, end: 1).animate(animation),
                child: child,
              ),
            ),
            child: ListView.separated(
              key: ValueKey(formulas),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: physicsTopics.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 11),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formulas ? 'Формулалар жинағы' : 'Оқу жолы',
                          style: const TextStyle(
                            color: navy,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formulas
                              ? 'Мектеп физикасының формулалары, шығу жолы және қолданылуы'
                              : 'Мектеп физикасының тақырыптары оқу ретімен',
                          style: const TextStyle(color: muted, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }
                final topic = physicsTopics[index - 1];
                return SoftCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => formulas
                          ? FormulaDetailScreen(topic: topic)
                          : TopicDetailScreen(topic: topic),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: formulas ? 68 : 52,
                        height: 55,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: formulas
                            ? const Icon(
                                Icons.functions_rounded,
                                color: primary,
                                size: 29,
                              )
                            : const Icon(
                                Icons.auto_stories_rounded,
                                color: primary,
                                size: 27,
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formulas ? topic.formula : topic.title,
                              style: const TextStyle(
                                color: navy,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formulas ? topic.title : topic.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: muted,
                        size: 21,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
