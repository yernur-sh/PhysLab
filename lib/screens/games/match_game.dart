part of '../main_shell.dart';

class MatchGame extends StatefulWidget {
  const MatchGame({super.key});
  @override
  State<MatchGame> createState() => _MatchGameState();
}

class _MatchGameState extends State<MatchGame> {
  String? picked;
  final done = <String>{};
  int round = 0;
  static const groups = [
    {'Күш': 'Ньютон', 'Қуат': 'Ватт', 'Қысым': 'Паскаль'},
    {'Энергия': 'Джоуль', 'Жиілік': 'Герц', 'Кернеу': 'Вольт'},
    {'Ток күші': 'Ампер', 'Кедергі': 'Ом', 'Уақыт': 'Секунд'},
  ];
  Map<String, String> get pairs => groups[round % groups.length];
  @override
  Widget build(BuildContext context) {
    final values = pairs.values.toList()..shuffle(Random(round + 8));
    return Scaffold(
      appBar: AppBar(title: const Text('Шаманы сәйкестендір')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF2FF), canvas, Color(0xFFF8FAFF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF17294D), Color(0xFF4F65CB)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Сол жақтан шаманы, оң жақтан оған сәйкес өлшем бірлігін таңда.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Топтама ${round + 1} · Табылды: ${done.length}/${pairs.length}',
                style: const TextStyle(color: muted),
              ),
              const SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: pairs.keys
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ChoiceChip(
                                label: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    item,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                selected: picked == item,
                                onSelected: done.contains(item)
                                    ? null
                                    : (_) => setState(() => picked = item),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: values
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ActionChip(
                                label: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    item,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                onPressed:
                                    picked == null ||
                                        pairs.entries.any(
                                          (entry) =>
                                              entry.value == item &&
                                              done.contains(entry.key),
                                        )
                                    ? null
                                    : () {
                                        final ok = pairs[picked] == item;
                                        showMessage(
                                          context,
                                          ok
                                              ? 'Дұрыс жұп!'
                                              : 'Бұл жұп сәйкес емес',
                                          error: !ok,
                                        );
                                        if (ok) {
                                          setState(() {
                                            done.add(picked!);
                                            picked = null;
                                          });
                                        }
                                      },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              if (done.length == pairs.length)
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.celebration_rounded,
                        color: sunny,
                        size: 55,
                      ),
                      const Text(
                        'Барлық жұп табылды!',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => setState(() {
                          round++;
                          done.clear();
                          picked = null;
                        }),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Келесі топтама'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
