import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;

  static const pages = [
    (
      icon: Icons.rocket_launch_rounded,
      title: 'Физиканы сезініп үйрен',
      text:
          '7–11 сынып тақырыптары, түсінікті формулалар және қадамдық мысалдар бір жерде.',
      color: primary,
    ),
    (
      icon: Icons.extension_rounded,
      title: 'Ойын арқылы жаттық',
      text:
          'Тесттер, формула құрастыру және сәйкестендіру ойындары білімді бекітеді.',
      color: coral,
    ),
    (
      icon: Icons.groups_rounded,
      title: 'Сыныппен бірге дамы',
      text:
          'Мұғалім класс құрады, оқушы кодпен қосылады. Нәтиже әрдайым көрініп тұрады.',
      color: mint,
    ),
    (
      icon: Icons.school_rounded,
      title: 'Ғылыми жоба жетекшісі',
      text: 'Жұмабаева Қарашаш Бұхарбекқызы',
      color: primary,
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = pages[page];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            children: [
              Row(
                children: [
                  const BrandMark(size: 42),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'PhysLab',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.5,
                        color: navy,
                      ),
                    ),
                  ),
                  TextButton(onPressed: _openAuth, child: const Text('Өткізу')),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: pages.length,
                  onPageChanged: (value) => setState(() => page = value),
                  itemBuilder: (context, index) {
                    final item = pages[index];
                    if (index == pages.length - 1) {
                      return const _ProjectMentorPage();
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        child: SingleChildScrollView(
                          key: ValueKey(index),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: .94, end: 1),
                                  duration: Duration(
                                    milliseconds:
                                        MediaQuery.disableAnimationsOf(context)
                                        ? 0
                                        : 450,
                                  ),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) =>
                                      Transform.scale(
                                        scale: value,
                                        child: child,
                                      ),
                                  child: Container(
                                    width: 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          item.color.withValues(alpha: .9),
                                          navy,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(60),
                                      boxShadow: [
                                        BoxShadow(
                                          color: item.color.withValues(
                                            alpha: .23,
                                          ),
                                          blurRadius: 40,
                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 184,
                                          height: 184,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: .26,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 132,
                                          height: 132,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withValues(
                                              alpha: .12,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          item.icon,
                                          size: 90,
                                          color: Colors.white,
                                        ),
                                        const Positioned(
                                          left: 22,
                                          top: 32,
                                          child: Icon(
                                            Icons.auto_awesome,
                                            color: sunny,
                                            size: 30,
                                          ),
                                        ),
                                        Positioned(
                                          right: 25,
                                          bottom: 35,
                                          child: Icon(
                                            Icons.bubble_chart_rounded,
                                            color: Colors.white70,
                                            size: 34,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 48),
                                Text(
                                  item.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 31,
                                    height: 1.15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -.8,
                                    color: navy,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  item.text,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.55,
                                    color: Color(0xFF6C738A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: Duration(
                      milliseconds: MediaQuery.disableAnimationsOf(context)
                          ? 0
                          : 250,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: page == index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: page == index
                          ? current.color
                          : const Color(0xFFD9DDEA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: page == pages.length - 1 ? 'Бастау' : 'Жалғастыру',
                onPressed: () {
                  if (page == pages.length - 1) {
                    _openAuth();
                  } else {
                    controller.nextPage(
                      duration: Duration(
                        milliseconds: MediaQuery.disableAnimationsOf(context)
                            ? 0
                            : 300,
                      ),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAuth() => Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
}

class _ProjectMentorPage extends StatelessWidget {
  const _ProjectMentorPage();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: .12,
              child: Image.asset(
                'assets/people/qarashash_zhumabayeva.jpeg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 14),
                const Text(
                  'ЖОБАНЫҢ ҒЫЛЫМИ ЖЕТЕКШІСІ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 250,
                  height: 250,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(44),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: .16),
                        blurRadius: 34,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(39),
                    child: Image.asset(
                      'assets/people/qarashash_zhumabayeva.jpeg',
                      key: const Key('project-mentor-photo'),
                      semanticLabel: 'Жұмабаева Қарашаш Бұхарбекқызының суреті',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Жұмабаева Қарашаш\nБұхарбекқызы',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.18,
                    fontWeight: FontWeight.w900,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 11),
                const Text(
                  'Физика пәні мұғалімі',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 16),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
