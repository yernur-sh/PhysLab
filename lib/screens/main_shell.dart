import 'dart:math';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../physics_data.dart';
import '../widgets/common.dart';
import 'auth_flow.dart';
import 'physics_games.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int index = 0;
  late final AnimationController tabTransition = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );

  @override
  void dispose() {
    tabTransition.dispose();
    super.dispose();
  }

  static const labels = ['Зертхана', 'Тақырыптар', 'Практика', 'PhysAI'];
  static const descriptions = [
    'Бүгінгі оқу кеңістігі',
    'Физиканы қадамдап меңгер',
    'Біліміңді байқап көр',
    'Сұрағыңды бірге шешейік',
  ];

  void _selectTab(int value) {
    if (index == value) return;
    HapticFeedback.selectionClick();
    setState(() => index = value);
    tabTransition.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _LabHeader(
              title: labels[index],
              description: descriptions[index],
              profile: state.profile,
              onProfile: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
              onNotifications: () => showMessage(context, 'Жаңа хабарлама жоқ'),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: tabTransition,
                builder: (context, child) {
                  final value = Curves.easeOutCubic.transform(
                    tabTransition.value,
                  );
                  return Opacity(
                    opacity: MediaQuery.disableAnimationsOf(context)
                        ? 1
                        : value,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        MediaQuery.disableAnimationsOf(context)
                            ? 0
                            : 8 * (1 - value),
                      ),
                      child: child,
                    ),
                  );
                },
                child: IndexedStack(
                  index: index,
                  children: [
                    HomePage(onOpenTopics: () => _selectTab(1)),
                    const TopicsPage(),
                    const PracticePage(),
                    const AssistantPage(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _FloatingTabBar(
        selectedIndex: index,
        onSelected: _selectTab,
      ),
    );
  }
}

class _LabHeader extends StatelessWidget {
  const _LabHeader({
    required this.title,
    required this.description,
    required this.profile,
    required this.onProfile,
    required this.onNotifications,
  });

  final String title;
  final String description;
  final UserProfile? profile;
  final VoidCallback onProfile;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BrandMark(size: 34),
              const SizedBox(width: 10),
              const Text(
                'PhysLab',
                style: TextStyle(
                  color: navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.4,
                ),
              ),
              const Spacer(),
              IconButton.filledTonal(
                tooltip: 'Хабарламалар',
                onPressed: onNotifications,
                icon: const Icon(Icons.notifications_none_rounded, size: 21),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: navy,
                ),
              ),
              const SizedBox(width: 7),
              GestureDetector(
                key: const Key('profile-button'),
                onTap: onProfile,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primary.withValues(alpha: .3)),
                  ),
                  child: UserAvatar(profile: profile, radius: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: Duration(
              milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 180,
            ),
            child: Column(
              key: ValueKey(title),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 30,
                    height: 1.08,
                    letterSpacing: -.9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingTabBar extends StatelessWidget {
  const _FloatingTabBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const items = [
    (Icons.home_rounded, 'Басты'),
    (Icons.menu_book_rounded, 'Тақырып'),
    (Icons.sports_esports_rounded, 'Практика'),
    (Icons.auto_awesome_rounded, 'PhysAI'),
  ];

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 9),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .87),
                    borderRadius: BorderRadius.circular(27),
                    border: Border.all(color: Colors.white),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F24345C),
                        blurRadius: 28,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(items.length, (index) {
                      final selected = index == selectedIndex;
                      return Expanded(
                        child: Semantics(
                          button: true,
                          selected: selected,
                          label: items[index].$2,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onSelected(index),
                            child: AnimatedContainer(
                              duration: Duration(
                                milliseconds: reduceMotion ? 0 : 220,
                              ),
                              curve: Curves.easeInOutCubic,
                              height: 57,
                              decoration: BoxDecoration(
                                color: selected ? primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(21),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    items[index].$1,
                                    color: selected ? Colors.white : muted,
                                    size: 23,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    items[index].$2,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: selected ? Colors.white : muted,
                                      fontSize: 10,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenTopics});

  final VoidCallback onOpenTopics;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile =
        state.profile ??
        const UserProfile(name: 'Оқушы', email: '', role: UserRole.student);
    final firstName = profile.name.trim().split(' ').first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 222,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF142747),
                  Color(0xFF304C91),
                  Color(0xFF536BDE),
                ],
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Positioned(
                    right: -38,
                    top: -28,
                    child: SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(painter: _OrbitPainter()),
                    ),
                  ),
                  Positioned(
                    right: 29,
                    top: 78,
                    child: Container(
                      width: 63,
                      height: 63,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB7C3FF), Color(0xFF728CF6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFACC1FF,
                            ).withValues(alpha: .42),
                            blurRadius: 38,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 31,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(23),
                    child: SizedBox(
                      width: constraints.maxWidth * .73,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .13),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'БҮГІНГІ МИССИЯ',
                              style: TextStyle(
                                color: Color(0xFFD9E3FF),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Сәлем, $firstName!',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              letterSpacing: -.6,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Әр жаңалық бір сұрақтан басталады.',
                            maxLines: 2,
                            style: TextStyle(
                              color: Color(0xFFD6E1FF),
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: onOpenTopics,
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 17,
                            ),
                            label: const Text('Зерттеуді бастау'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: navy,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              minimumSize: const Size(0, 42),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
            color: const Color(0xFFE9EDFF),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.groups_2_rounded,
                    size: 30,
                    color: primary,
                  ),
                ),
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

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .5);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, size.width * .31, line);
    canvas.drawCircle(center, size.width * .45, line);
    canvas.drawCircle(center, size.width * .59, line);
    final dot = Paint()..color = const Color(0xFFFFD18B);
    canvas.drawCircle(Offset(size.width * .77, size.height * .32), 4, dot);
    canvas.drawCircle(
      Offset(size.width * .19, size.height * .82),
      2.5,
      Paint()..color = Colors.white.withValues(alpha: .6),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C273968),
              blurRadius: 20,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(height: 9),
            Text(
              value,
              style: const TextStyle(
                color: navy,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
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
        style: const TextStyle(
          color: navy,
          fontSize: 20,
          letterSpacing: -.4,
          fontWeight: FontWeight.w900,
        ),
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
              milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 220,
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
                              ? '7–11 сынып формулалары, шығу жолы және қолданылуы'
                              : '7–11 сынып тақырыптары оқу ретімен',
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
                            : Text(
                                '${topic.grade}',
                                style: const TextStyle(
                                  color: primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
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
                              formulas
                                  ? '${topic.grade}-сынып · ${topic.title}'
                                  : topic.subtitle,
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
            padding: const EdgeInsets.all(27),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF17294D), Color(0xFF4F65CB)],
              ),
              borderRadius: BorderRadius.circular(29),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${topic.grade}-СЫНЫП · ТАҚЫРЫП',
                    style: const TextStyle(
                      color: Color(0xFFE3E8FF),
                      fontSize: 10,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 29),
                Text(
                  topic.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    letterSpacing: -.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  topic.subtitle,
                  style: const TextStyle(color: Color(0xFFDCE4FF)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Негізгі ұғымдар',
                  style: TextStyle(
                    color: navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ...topic.keyIdeas.map(
                  (idea) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: mint,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            idea,
                            style: const TextStyle(height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  topic.topicQuestion,
                  style: const TextStyle(
                    color: navy,
                    height: 1.5,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                ...List.generate(
                  topic.topicSteps.length,
                  (index) => _SolutionStep(
                    number: index + 1,
                    text: topic.topicSteps[index],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  topic.topicAnswer,
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w900,
                  ),
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

class FormulaDetailScreen extends StatelessWidget {
  const FormulaDetailScreen({super.key, required this.topic});

  final TopicData topic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Формула')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF17294D), Color(0xFF4F65CB)],
              ),
              borderRadius: BorderRadius.circular(29),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${topic.grade}-СЫНЫП · ${topic.title.toUpperCase()}',
                  style: const TextStyle(
                    color: Color(0xFFE3E8FF),
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  topic.formula,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  topic.subtitle,
                  style: const TextStyle(color: Color(0xFFDCE4FF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Таңбалар мен өлшемдер',
                  style: TextStyle(
                    color: navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 11),
                ...topic.symbols.map(
                  (symbol) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      symbol,
                      style: const TextStyle(height: 1.45, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Формула қалай шығады?',
                  style: TextStyle(
                    color: navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 15),
                ...List.generate(
                  topic.derivation.length,
                  (index) => _SolutionStep(
                    number: index + 1,
                    text: topic.derivation[index],
                  ),
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
                const Text(
                  'Формуланы қолдану',
                  style: TextStyle(
                    color: navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  topic.formulaQuestion,
                  style: const TextStyle(
                    color: navy,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                ...List.generate(
                  topic.formulaSteps.length,
                  (index) => _SolutionStep(
                    number: index + 1,
                    text: topic.formulaSteps[index],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  topic.formulaAnswer,
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SolutionStep extends StatelessWidget {
  const _SolutionStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: primary.withValues(alpha: .12),
          foregroundColor: primary,
          child: Text(
            '$number',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(height: 1.48, fontSize: 15)),
        ),
      ],
    ),
  );
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
          icon: Icons.my_location_rounded,
          title: 'Баллистика шебері',
          text: 'Бұрыш пен жылдамдықты таңдап, нысанаға тигіз',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const BallisticsGame())),
        ),
        const SizedBox(height: 14),
        _GameCard(
          color: const Color(0xFFE6FAF4),
          icon: Icons.electrical_services_rounded,
          title: 'Электрлік лабиринт',
          text: 'Тізбек құрып, шамды қауіпсіз жақ',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CircuitGame())),
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
          color: const Color(0xFFFFF3E1),
          icon: Icons.directions_car_filled_rounded,
          title: 'Жылдам формула',
          text: 'Есептерді шешіп, көлік жарысында озып шық',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const FormulaRaceGame())),
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
            SoftCard(
              color: const Color(0xFFE9EDFF),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'СҰРАҚ ${current + 1} / ${quizQuestions.length}',
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
                        '$score ұпай',
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (current + 1) / quizQuestions.length,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 7, 18, 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8EDFF), Color(0xFFF2ECFF)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  foregroundColor: primary,
                  child: Icon(Icons.auto_awesome_rounded),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Сәлем, мен PhysAI',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Күрделі есепті бірге бөлшектеп шешеміз',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
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
                style: IconButton.styleFrom(
                  backgroundColor: primary,
                  fixedSize: const Size(48, 48),
                ),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF182B50), Color(0xFF5068D5)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 1.5),
                  ),
                  child: UserAvatar(profile: profile, radius: 44),
                ),
                const SizedBox(height: 14),
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(color: Color(0xFFDCE5FF)),
                ),
                const SizedBox(height: 11),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    profile.role == UserRole.teacher ? 'МҰҒАЛІМ' : 'ОҚУШЫ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
              ],
            ),
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
