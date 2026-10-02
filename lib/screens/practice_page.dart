part of 'main_shell.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});
  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  bool games = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: IosSegmentedControl(
            labels: const ['Викторина', 'Ойындар'],
            selectedIndex: games ? 1 : 0,
            onChanged: (value) => setState(() => games = value == 1),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(
              milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 220,
            ),
            child: games ? const _GamesList() : const _QuizList(),
          ),
        ),
      ],
    );
  }
}

class _QuizList extends StatelessWidget {
  const _QuizList();
  @override
  Widget build(BuildContext context) {
    final colors = [primary, coral, mint, sunny, const Color(0xFF9B6BDF)];
    return ListView.separated(
      key: const ValueKey('quiz-list'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      itemCount: quizSets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => SoftCard(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => QuizScreen(quizIndex: index))),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colors[index % colors.length].withValues(
                alpha: .13,
              ),
              foregroundColor: colors[index % colors.length],
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quizSets[index].title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${quizSets[index].questions.length} сұрақ • әр дұрыс жауап 10 ұпай',
                    style: const TextStyle(color: Color(0xFF777E92)),
                  ),
                ],
              ),
            ),
            Container(
              key: const Key('quiz-start-affordance'),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EDFF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: primary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamesList extends StatelessWidget {
  const _GamesList();
  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('games-list'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      children: [
        _GameCard(
          color: const Color(0xFFE9ECFF),
          icon: Icons.my_location_rounded,
          title: 'Баллистика шебері',
          text: 'Бұрыш пен жылдамдықты таңдап, нысанаға тигіз',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const BallisticsGame())),
        ),
        const SizedBox(height: 14),
        _GameCard(
          color: const Color(0xFFFFF3E1),
          icon: Icons.flare_rounded,
          title: 'Оптикалық фокус',
          text: 'Линзаның нақты кескінін экранға түсір',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const OpticsGame())),
        ),
        const SizedBox(height: 14),
        _GameCard(
          color: const Color(0xFFFFE9E7),
          icon: Icons.sports_baseball_rounded,
          title: 'Энергия трансформері',
          text: 'Потенциалдық энергиямен шарды мәреге жеткіз',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const EnergyGame())),
        ),
        const SizedBox(height: 14),
        _GameCard(
          color: const Color(0xFFE9ECFF),
          icon: Icons.calculate_rounded,
          title: 'Формула конструкторы',
          text: 'Белгілерді дұрыс ретпен орналастыр',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const FormulaBuilderGame())),
        ),
        const SizedBox(height: 14),
        _GameCard(
          color: const Color(0xFFE6FAF4),
          icon: Icons.compare_arrows_rounded,
          title: 'Шаманы сәйкестендір',
          text: 'Физикалық шама мен өлшем бірлігін тап',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const MatchGame())),
        ),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.text,
    required this.onTap,
  });
  final Color color;
  final IconData icon;
  final String title;
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SoftCard(
    color: color,
    onTap: onTap,
    padding: const EdgeInsets.all(22),
    child: Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .68),
            borderRadius: BorderRadius.circular(19),
          ),
          child: Icon(icon, color: primary, size: 29),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(text, style: const TextStyle(color: Color(0xFF60677A))),
            ],
          ),
        ),
        const Icon(Icons.arrow_outward_rounded, color: navy, size: 20),
      ],
    ),
  );
}
