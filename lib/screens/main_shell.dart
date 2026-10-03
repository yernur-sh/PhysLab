import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../physics_data.dart';
import '../services/phys_ai_service.dart';
import '../widgets/common.dart';
import 'auth_flow.dart';
import 'classroom_screen.dart';
import 'change_password_screen.dart';
import 'physics_games.dart';

part 'home_page.dart';
part 'topics_page.dart';
part 'topic_detail_screen.dart';
part 'topic_check_screen.dart';
part 'formula_detail_screen.dart';
part 'practice_page.dart';
part 'quiz_screen.dart';
part 'quiz_result_screen.dart';
part 'games/formula_builder_game.dart';
part 'games/match_game.dart';
part 'assistant_page.dart';
part 'profile_screen.dart';
part 'mastered_topics_screen.dart';

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
    duration: const Duration(milliseconds: 290),
    value: 1,
  );

  @override
  void dispose() {
    tabTransition.dispose();
    super.dispose();
  }

  static const labels = [
    'Зертхана',
    'Тақырыптар',
    'Практика',
    'PhysAI',
    'Профиль',
  ];
  static const descriptions = [
    'Бүгінгі оқу кеңістігі',
    'Физиканы қадамдап меңгер',
    'Біліміңді байқап көр',
    'Сұрағыңды бірге шешейік',
    'Нәтижелерің мен аккаунтың',
  ];

  void _selectTab(int value) {
    if (index == value) return;
    HapticFeedback.selectionClick();
    setState(() => index = value);
    tabTransition.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _LabHeader(title: labels[index], description: descriptions[index]),
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
                    const ProfileScreen(),
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
  const _LabHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 10, 8, 17),
      color: canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BrandMark(size: 30),
              const SizedBox(width: 9),
              const Text(
                'PhysLab',
                style: TextStyle(
                  color: navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.4,
                ),
              ),
              const Spacer(),
              const Expanded(
                flex: 3,
                child: Text(
                  'Жоба жетекшісі: Жұмабаева Қарашаш\nБұхарбекқызы',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFF4C5E91),
                    fontSize: 10,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
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
                    fontSize: 27,
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
    (Icons.person_rounded, 'Профиль'),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE8EDF5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1024345C),
                    blurRadius: 20,
                    offset: Offset(0, 5),
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
                            milliseconds: reduceMotion ? 0 : 260,
                          ),
                          curve: Curves.easeInOutCubic,
                          height: 55,
                          decoration: BoxDecoration(
                            color: selected ? primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                items[index].$1,
                                color: selected ? Colors.white : muted,
                                size: 22,
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
    );
  }
}
