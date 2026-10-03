part of '../main_shell.dart';

class FormulaBuilderGame extends StatefulWidget {
  const FormulaBuilderGame({super.key});
  @override
  State<FormulaBuilderGame> createState() => _FormulaBuilderGameState();
}

typedef _FormulaChallenge = ({
  String name,
  String left,
  List<String> answer,
  List<String> options,
  String explanation,
});

class _FormulaBuilderGameState extends State<FormulaBuilderGame> {
  static const challenges = <_FormulaChallenge>[
    (
      name: 'Потенциалдық энергия',
      left: 'E_p',
      answer: ['m', 'g', 'h'],
      options: ['m', 'g', 'h', 'v', 't', 'F'],
      explanation: 'E_p = mgh: масса × еркін түсу үдеуі × биіктік.',
    ),
    (
      name: 'Ньютонның екінші заңы',
      left: 'F',
      answer: ['m', 'a'],
      options: ['m', 'a', 'v', 't', 's', 'g'],
      explanation: 'F = ma: күш масса мен үдеудің көбейтіндісі.',
    ),
    (
      name: 'Жылдамдық',
      left: 'v',
      answer: ['s', '/', 't'],
      options: ['s', '/', 't', 'm', 'a', 'F'],
      explanation: 'v = s/t: жүрілген жол уақытқа бөлінеді.',
    ),
    (
      name: 'Механикалық жұмыс',
      left: 'A',
      answer: ['F', 's'],
      options: ['F', 's', 'm', 't', 'v', 'g'],
      explanation: 'A = Fs: күш пен орын ауыстыру көбейтіледі.',
    ),
    (
      name: 'Қысым',
      left: 'p',
      answer: ['F', '/', 'S'],
      options: ['F', '/', 'S', 'm', 't', 'a'],
      explanation: 'p = F/S: күш әсер ететін ауданға бөлінеді.',
    ),
  ];
  final random = Random();
  final chosen = <String>[];
  int challengeIndex = 0;
  int solved = 0;

  void _check() {
    final challenge = challenges[challengeIndex];
    final correct = chosen.join() == challenge.answer.join();
    showMessage(
      context,
      correct
          ? challenge.explanation
          : 'Қате. ${challenge.left} формуласын қайта құрастыр.',
      error: !correct,
    );
    setState(() {
      chosen.clear();
      if (correct) {
        solved++;
        challengeIndex =
            (challengeIndex + 1 + random.nextInt(challenges.length - 1)) %
            challenges.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final challenge = challenges[challengeIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Формула конструкторы')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF2FF), canvas, Color(0xFFF8FAFF)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF17294D), Color(0xFF4F65CB)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calculate_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Формуланы өзің құрастыр',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              'Дұрыс жауап: $solved · Шексіз жаттығу',
                              style: const TextStyle(color: Color(0xFFE1E8FF)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Белгілерді ретімен түрт. Ұяшықты түртсең, белгіні алып тастайсың.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: SoftCard(
                    child: Column(
                      children: [
                        const Icon(Icons.bolt_rounded, color: sunny, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          challenge.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: challenge.options
                              .map(
                                (value) => ActionChip(
                                  label: Text(
                                    value,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFFE9EDFF),
                                  onPressed:
                                      chosen.length < challenge.answer.length
                                      ? () => setState(() => chosen.add(value))
                                      : null,
                                ),
                              )
                              .toList(),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${challenge.left} = ',
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            ...List.generate(
                              challenge.answer.length,
                              (index) => GestureDetector(
                                onTap: index < chosen.length
                                    ? () =>
                                          setState(() => chosen.removeAt(index))
                                    : null,
                                child: Container(
                                  width: 46,
                                  height: 52,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F7FC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: primary,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    index < chosen.length ? chosen[index] : '',
                                    style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Тексеру және жалғастыру',
                  onPressed: chosen.length == challenge.answer.length
                      ? _check
                      : null,
                  icon: Icons.check_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
