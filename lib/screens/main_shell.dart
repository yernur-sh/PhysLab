import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../physics_data.dart';
import '../widgets/common.dart';
import 'auth_flow.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  static const labels = ['Басты бет', 'Тақырыптар', 'Практика', 'ЖИ-көмекші'];

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF7F8FD),
        title: Text(
          labels[index],
          style: const TextStyle(fontWeight: FontWeight.w800, color: navy),
        ),
        actions: [
          IconButton(
            tooltip: 'Хабарламалар',
            onPressed: () => showMessage(context, 'Жаңа хабарлама жоқ'),
            icon: const Badge(child: Icon(Icons.notifications_none_rounded)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              key: const Key('profile-button'),
              borderRadius: BorderRadius.circular(30),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: UserAvatar(profile: state.profile, radius: 20),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: index,
        children: const [
          HomePage(),
          TopicsPage(),
          PracticePage(),
          AssistantPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        backgroundColor: Colors.white,
        indicatorColor: primary.withValues(alpha: .14),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Басты',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Тақырыптар',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports_rounded),
            label: 'Практика',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'ЖИ',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile =
        state.profile ??
        const UserProfile(name: 'Оқушы', email: '', role: UserRole.student);
    final firstName = profile.name.trim().split(' ').first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5368F7), Color(0xFF8794FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Сәлем, $firstName! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Бүгін физикадан жаңа бір құбылысты ашайық.',
                      style: TextStyle(color: Color(0xFFE8EBFF), height: 1.4),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        foregroundColor: primary,
                        backgroundColor: Colors.white,
                      ),
                      child: const Text('Сабақты жалғастыру'),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.science_rounded,
                size: 90,
                color: Color(0x99FFFFFF),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            _StatCard(
              '${state.streak} күн',
              'Серия',
              Icons.local_fire_department,
              coral,
            ),
            const SizedBox(width: 10),
            _StatCard('${state.points}', 'Ұпай', Icons.bolt_rounded, sunny),
            const SizedBox(width: 10),
            _StatCard(
              '${state.completedTasks}',
              'Тапсырма',
              Icons.task_alt_rounded,
              mint,
            ),
          ],
        ),
        const SizedBox(height: 25),
        const _SectionTitle(title: 'Менің класым', action: 'Барлығы'),
        const SizedBox(height: 12),
        if (state.classes.isEmpty)
          SoftCard(
            color: const Color(0xFFF0F2FF),
            child: Column(
              children: [
                const Icon(Icons.groups_2_outlined, size: 50, color: primary),
                const SizedBox(height: 10),
                Text(
                  profile.role == UserRole.teacher
                      ? 'Алғашқы класыңызды құрыңыз'
                      : 'Мұғалім берген кодпен классқа қосылыңыз',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  key: const Key('class-action-button'),
                  onPressed: () => profile.role == UserRole.teacher
                      ? _showCreateClass(context)
                      : _showJoinClass(context),
                  icon: Icon(
                    profile.role == UserRole.teacher
                        ? Icons.add_rounded
                        : Icons.login_rounded,
                  ),
                  label: Text(
                    profile.role == UserRole.teacher
                        ? 'Класс құру'
                        : 'Кодпен қосылу',
                  ),
                ),
              ],
            ),
          )
        else
          ...state.classes.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SoftCard(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.groups_rounded, color: primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${item.grade}-сынып • ${item.memberCount} қатысушы',
                            style: const TextStyle(
                              color: Color(0xFF777E92),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.code,
                      style: const TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (profile.role == UserRole.teacher)
                      IconButton(
                        tooltip: 'Кодты көшіру',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item.code));
                          showMessage(context, 'Класс коды көшірілді');
                        },
                        icon: const Icon(Icons.copy_rounded, size: 19),
                      ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 25),
        const _SectionTitle(title: 'Бүгінгі ұсыныс', action: '5 минут'),
        const SizedBox(height: 12),
        SoftCard(
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.lightbulb_rounded, color: sunny),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ньютонның екінші заңы',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Қысқа түсіндірме + 3 есеп',
                      style: TextStyle(color: Color(0xFF777E92)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 17),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateClass(BuildContext context) {
    final name = TextEditingController();
    int grade = 7;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Жаңа класс',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Класс атауы'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: grade,
                decoration: const InputDecoration(labelText: 'Сынып'),
                items: List.generate(5, (i) => i + 7)
                    .map(
                      (v) =>
                          DropdownMenuItem(value: v, child: Text('$v-сынып')),
                    )
                    .toList(),
                onChanged: (value) => setSheetState(() => grade = value ?? 7),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Класс құру',
                onPressed: () {
                  if (name.text.trim().isEmpty) return;
                  final item = AppStateScope.of(
                    context,
                  ).createClass(name.text.trim(), grade);
                  Navigator.pop(sheetContext);
                  showMessage(context, 'Класс құрылды. Код: ${item.code}');
                },
                icon: Icons.add_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinClass(BuildContext context) {
    final code = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Классқа қосылу',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('Мұғалім жіберген PHY-0000 форматындағы кодты енгіз.'),
            const SizedBox(height: 18),
            TextField(
              controller: code,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Класс коды',
                prefixIcon: Icon(Icons.key_rounded),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Қосылу',
              onPressed: () {
                final ok = AppStateScope.of(context).joinClass(code.text);
                if (ok) Navigator.pop(sheetContext);
                showMessage(
                  context,
                  ok ? 'Классқа сәтті қосылдыңыз' : 'Код форматы қате',
                  error: !ok,
                );
              },
              icon: Icons.login_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.value, this.label, this.icon, this.color);
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAECF5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF7B8295)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action});
  final String title;
  final String action;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
      const Spacer(),
      Text(action, style: const TextStyle(color: primary, fontSize: 13)),
    ],
  );
}

class TopicsPage extends StatefulWidget {
  const TopicsPage({super.key});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  bool formulas = false;
  int grade = 7;

  @override
  Widget build(BuildContext context) {
    final topics = physicsTopics.where((item) => item.grade == grade).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Тақырыптар')),
              ButtonSegment(value: true, label: Text('Формулалар')),
            ],
            selected: {formulas},
            onSelectionChanged: (value) =>
                setState(() => formulas = value.first),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final value = index + 7;
              return ChoiceChip(
                label: Text('$value-сынып'),
                selected: grade == value,
                onSelected: (_) => setState(() => grade = value),
              );
            },
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ListView.builder(
              key: ValueKey('$formulas-$grade'),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SoftCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TopicDetailScreen(topic: topic),
                      ),
                    ),
                    child: formulas
                        ? Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  topic.formula,
                                  style: const TextStyle(
                                    color: primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: Text(topic.title)),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          )
                        : Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: primary.withValues(alpha: .1),
                                foregroundColor: primary,
                                child: Text('$grade'),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      topic.title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      topic.subtitle,
                                      style: const TextStyle(
                                        color: Color(0xFF777E92),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
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

class TopicDetailScreen extends StatelessWidget {
  const TopicDetailScreen({super.key, required this.topic});
  final TopicData topic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primary, Color(0xFF8794FF)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Text(
                  '${topic.grade}-сынып',
                  style: const TextStyle(color: Color(0xFFDDE2FF)),
                ),
                const SizedBox(height: 10),
                Text(
                  topic.formula,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Түсіндірме',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  topic.explanation,
                  style: const TextStyle(height: 1.55, fontSize: 16),
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
                const Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: sunny),
                    SizedBox(width: 8),
                    Text(
                      'Мысал есеп',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  topic.example,
                  style: const TextStyle(height: 1.55, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Тақырыпты меңгердім',
            onPressed: () => Navigator.pop(context),
            icon: Icons.check_rounded,
          ),
        ],
      ),
    );
  }
}

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
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Тест-викторина')),
              ButtonSegment(value: true, label: Text('Ойындар')),
            ],
            selected: {games},
            onSelectionChanged: (value) => setState(() => games = value.first),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
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
    final titles = ['Механика', 'Жылу', 'Электр', 'Оптика', 'Аралас физика'];
    final colors = [primary, coral, mint, sunny, const Color(0xFF9B6BDF)];
    return ListView.separated(
      key: const ValueKey('quiz-list'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => SoftCard(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const QuizScreen())),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colors[index].withValues(alpha: .13),
              foregroundColor: colors[index],
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
                    titles[index],
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '20 сұрақ • 15 минут',
                    style: TextStyle(color: Color(0xFF777E92)),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.play_circle_fill_rounded,
              color: primary,
              size: 34,
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
        const SizedBox(height: 14),
        _GameCard(
          color: const Color(0xFFFFF3E1),
          icon: Icons.flash_on_rounded,
          title: 'Жылдам формула',
          text: '60 секундта көп формула тап',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const FormulaBuilderGame())),
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
        Icon(icon, color: primary, size: 42),
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
        const Icon(Icons.chevron_right_rounded),
      ],
    ),
  );
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int current = 0;
  int score = 0;
  int? selected;

  @override
  Widget build(BuildContext context) {
    final question = quizQuestions[current];
    return Scaffold(
      appBar: AppBar(title: const Text('Аралас викторина')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${current + 1} / ${quizQuestions.length}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text('$score ұпай', style: const TextStyle(color: primary)),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (current + 1) / quizQuestions.length,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 38),
            Text(
              question.question,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            ...List.generate(question.answers.length, (index) {
              final isSelected = selected == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => setState(() => selected = index),
                  selected: isSelected,
                  selectedTileColor: primary.withValues(alpha: .1),
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isSelected ? primary : const Color(0xFFE5E7F0),
                    ),
                  ),
                  leading: CircleAvatar(
                    child: Text(String.fromCharCode(65 + index)),
                  ),
                  title: Text(question.answers[index]),
                ),
              );
            }),
            const Spacer(),
            PrimaryButton(
              label: current == quizQuestions.length - 1
                  ? 'Нәтижені көру'
                  : 'Келесі сұрақ',
              onPressed: selected == null ? null : _next,
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    if (selected == quizQuestions[current].correct) score++;
    if (current == quizQuestions.length - 1) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.emoji_events_rounded, color: sunny, size: 52),
          title: const Text('Тест аяқталды!'),
          content: Text('$score / ${quizQuestions.length} дұрыс жауап'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Дайын'),
            ),
          ],
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

class FormulaBuilderGame extends StatefulWidget {
  const FormulaBuilderGame({super.key});
  @override
  State<FormulaBuilderGame> createState() => _FormulaBuilderGameState();
}

class _FormulaBuilderGameState extends State<FormulaBuilderGame> {
  final options = ['m', 'g', 'h', 'v', 't', 'F'];
  final chosen = <String>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Формула конструкторы')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Дайын: 0/12'),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(
                    value: 0,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SoftCard(
                child: Column(
                  children: [
                    const Icon(Icons.bolt_rounded, color: sunny, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      'Потенциалдық энергия',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 11,
                      runSpacing: 11,
                      alignment: WrapAlignment.center,
                      children: options
                          .map(
                            (value) => ActionChip(
                              label: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              backgroundColor: [
                                const Color(0xFFF3DDF9),
                                const Color(0xFFDDEEFF),
                                const Color(0xFFFFF1D4),
                              ][options.indexOf(value) % 3],
                              onPressed: chosen.length < 3
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
                        const Text(
                          'Eₚ = ',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        ...List.generate(
                          3,
                          (index) => GestureDetector(
                            onTap: () {
                              if (index < chosen.length) {
                                setState(() => chosen.removeAt(index));
                              }
                            },
                            child: Container(
                              width: 58,
                              height: 58,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7FC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: primary, width: 2),
                              ),
                              child: Text(
                                index < chosen.length ? chosen[index] : '',
                                style: const TextStyle(
                                  fontSize: 23,
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
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Жауап беру',
              onPressed: chosen.length == 3
                  ? () {
                      final correct = chosen.join() == 'mgh';
                      showMessage(
                        context,
                        correct ? 'Дұрыс! Eₚ = mgh' : 'Қайта ойланып көр',
                        error: !correct,
                      );
                      if (!correct) setState(chosen.clear);
                    }
                  : null,
              icon: Icons.check_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class MatchGame extends StatefulWidget {
  const MatchGame({super.key});
  @override
  State<MatchGame> createState() => _MatchGameState();
}

class _MatchGameState extends State<MatchGame> {
  String? picked;
  final done = <String>{};
  final pairs = const {'Күш': 'Ньютон', 'Қуат': 'Ватт', 'Қысым': 'Паскаль'};
  @override
  Widget build(BuildContext context) {
    final values = pairs.values.toList()..shuffle(Random(8));
    return Scaffold(
      appBar: AppBar(title: const Text('Шаманы сәйкестендір')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Физикалық шамаға сәйкес өлшем бірлігін таңда',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                                child: Text(item, textAlign: TextAlign.center),
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
                                child: Text(item, textAlign: TextAlign.center),
                              ),
                              onPressed: picked == null
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
              const Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    Icon(Icons.celebration_rounded, color: sunny, size: 55),
                    Text(
                      'Барлық жұп табылды!',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final controller = TextEditingController();
  final messages = <({bool user, String text})>[
    (
      user: false,
      text: 'Сәлем! Мен PhysAI көмекшісімін. Физикадан нені түсіндірейін?',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children:
                ['F = ma түсіндір', 'Есеп шығаруға көмектес', 'Формула тап']
                    .map(
                      (text) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(text),
                          onPressed: () {
                            controller.text = text;
                            _send();
                          },
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final item = messages[index];
              return Align(
                alignment: item.user
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 310),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: item.user ? primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(item.user ? 20 : 4),
                      bottomRight: Radius.circular(item.user ? 4 : 20),
                    ),
                    border: item.user
                        ? null
                        : Border.all(color: const Color(0xFFE8EAF2)),
                  ),
                  child: Text(
                    item.text,
                    style: TextStyle(
                      height: 1.4,
                      color: item.user ? Colors.white : navy,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.paddingOf(context).bottom + 12,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: 'Сұрағыңды жаз...',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: _send,
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _send() {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    setState(() {
      messages.add((user: true, text: value));
      messages.add((
        user: false,
        text: value.contains('F = ma')
            ? 'F = ma — Ньютонның екінші заңы. Мұнда F — күш (Н), m — масса (кг), a — үдеу (м/с²). Мысалы, 2 кг денеге 6 Н күш әсер етсе, үдеу a = 6/2 = 3 м/с².'
            : 'Сұрағыңды түсіндім. Берілген шамаларды және нені табу керегін жазсаң, шешу жолын қадамдап көрсетемін.',
      ));
      controller.clear();
    });
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile =
        state.profile ??
        const UserProfile(name: 'Қолданушы', email: '', role: UserRole.student);
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Column(
            children: [
              UserAvatar(profile: profile, radius: 52),
              const SizedBox(height: 14),
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                profile.email,
                style: const TextStyle(color: Color(0xFF777E92)),
              ),
              const SizedBox(height: 8),
              Chip(
                avatar: Icon(
                  profile.role == UserRole.teacher
                      ? Icons.cast_for_education_rounded
                      : Icons.school_rounded,
                ),
                label: Text(
                  profile.role == UserRole.teacher ? 'Мұғалім' : 'Оқушы',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SoftCard(
            child: Column(
              children: [
                _ProfileTile(
                  Icons.bar_chart_rounded,
                  'Менің нәтижелерім',
                  '${state.points} ұпай',
                ),
                const Divider(),
                _ProfileTile(
                  Icons.groups_rounded,
                  'Кластарым',
                  '${state.classes.length} класс',
                ),
                const Divider(),
                const _ProfileTile(
                  Icons.settings_outlined,
                  'Баптаулар',
                  'Қазақша',
                ),
                const Divider(),
                const _ProfileTile(
                  Icons.help_outline_rounded,
                  'Көмек және қолдау',
                  '',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
              } catch (_) {}
              if (!context.mounted) return;
              state.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const AuthScreen(initialLogin: true),
                ),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Аккаунттан шығу'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE45757),
              minimumSize: const Size.fromHeight(54),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile(this.icon, this.title, this.value);
  final IconData icon;
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: primary),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(color: Color(0xFF777E92))),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right_rounded),
      ],
    ),
  );
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.profile, required this.radius});
  final UserProfile? profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photo = profile?.isGoogleUser == true ? profile?.photoUrl : null;
    if (photo != null && photo.isNotEmpty) {
      return CircleAvatar(radius: radius, backgroundImage: NetworkImage(photo));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: primary.withValues(alpha: .13),
      child: Icon(Icons.person_rounded, size: radius * 1.2, color: primary),
    );
  }
}
