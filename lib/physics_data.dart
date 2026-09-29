class TopicData {
  const TopicData({
    required this.grade,
    required this.title,
    required this.subtitle,
    required this.formula,
    required this.explanation,
    required this.example,
  });

  final int grade;
  final String title;
  final String subtitle;
  final String formula;
  final String explanation;
  final String example;
}

const physicsTopics = <TopicData>[
  TopicData(
    grade: 7,
    title: 'Механикалық қозғалыс',
    subtitle: 'Жол, уақыт және жылдамдық',
    formula: 'v = s / t',
    explanation:
        'Жылдамдық — дененің бірлік уақыт ішінде жүріп өткен жолын көрсететін физикалық шама. Бірқалыпты қозғалыста жылдамдық тұрақты болады.',
    example: 'Велосипедші 120 м жолды 20 с-та жүрді. v = 120 / 20 = 6 м/с.',
  ),
  TopicData(
    grade: 8,
    title: 'Жылу құбылыстары',
    subtitle: 'Жылу мөлшері және температура',
    formula: 'Q = cmΔT',
    explanation:
        'Денені қыздыруға қажет жылу мөлшері оның массасына, температура өзгерісіне және меншікті жылу сыйымдылығына тәуелді.',
    example: '2 кг суды 5°C-қа қыздыру: Q = 4200 × 2 × 5 = 42 000 Дж.',
  ),
  TopicData(
    grade: 9,
    title: 'Ньютон заңдары',
    subtitle: 'Күш, масса және үдеу',
    formula: 'F = ma',
    explanation:
        'Ньютонның екінші заңы бойынша дененің үдеуі оған әсер ететін қорытқы күшке тура, ал массасына кері пропорционал.',
    example: 'Массасы 4 кг денеге 12 Н күш әсер етсе: a = F / m = 3 м/с².',
  ),
  TopicData(
    grade: 10,
    title: 'Молекулалық физика',
    subtitle: 'Идеал газ күйі',
    formula: 'pV = νRT',
    explanation:
        'Менделеев–Клапейрон теңдеуі идеал газдың қысымы, көлемі, зат мөлшері және температурасы арасындағы байланысты сипаттайды.',
    example:
        '1 моль газ 300 К температурада болса, pV = 1 × 8,31 × 300 = 2493 Дж.',
  ),
  TopicData(
    grade: 11,
    title: 'Электромагниттік индукция',
    subtitle: 'Магнит ағыны және ЭҚК',
    formula: 'ε = −ΔΦ / Δt',
    explanation:
        'Контур арқылы өтетін магнит ағыны өзгергенде индукциялық ток пайда болады. Минус таңбасы Ленц ережесінің бағытын білдіреді.',
    example: 'Ағын 0,6 Вб-ден 0,2 Вб-ге 0,1 с-та өзгерсе, |ε| = 4 В.',
  ),
];

class QuizQuestion {
  const QuizQuestion(this.question, this.answers, this.correct);
  final String question;
  final List<String> answers;
  final int correct;
}

const quizQuestions = <QuizQuestion>[
  QuizQuestion('Күштің SI жүйесіндегі өлшем бірлігі?', [
    'Паскаль',
    'Ньютон',
    'Джоуль',
    'Ватт',
  ], 1),
  QuizQuestion('Жылдамдықтың формуласы қайсы?', [
    'v = s/t',
    'v = st',
    'v = t/s',
    'v = ma',
  ], 0),
  QuizQuestion('Энергияның өлшем бірлігі?', [
    'Вольт',
    'Ампер',
    'Джоуль',
    'Ом',
  ], 2),
  QuizQuestion('Дененің инерттілігін сипаттайтын шама?', [
    'Көлем',
    'Тығыздық',
    'Масса',
    'Қысым',
  ], 2),
  QuizQuestion('Ток күшін өлшейтін құрал?', [
    'Вольтметр',
    'Амперметр',
    'Барометр',
    'Динамометр',
  ], 1),
];
