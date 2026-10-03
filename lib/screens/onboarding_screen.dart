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
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: page == pages.length - 1 ? 1 : 0,
              duration: const Duration(milliseconds: 350),
              child: const _MentorBackdrop(),
            ),
          ),
          SafeArea(
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
                      TextButton(
                        onPressed: _openAuth,
                        child: const Text('Өткізу'),
                      ),
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
                                            MediaQuery.disableAnimationsOf(
                                              context,
                                            )
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
                                          borderRadius: BorderRadius.circular(
                                            60,
                                          ),
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
                                                  color: Colors.white
                                                      .withValues(alpha: .26),
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
                            milliseconds:
                                MediaQuery.disableAnimationsOf(context)
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
        ],
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
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text(
              'ЖОБАНЫҢ ҒЫЛЫМИ ЖЕТЕКШІСІ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Жұмабаева Қарашаш\nБұхарбекқызы',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                height: 1.18,
                fontWeight: FontWeight.w900,
                color: navy,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Физика пәні мұғалімі',
              textAlign: TextAlign.center,
              style: TextStyle(color: navy, fontSize: 16),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}

class _MentorBackdrop extends StatelessWidget {
  const _MentorBackdrop();

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(
        'assets/people/qarashash_zhumabayeva.jpeg',
        key: const Key('project-mentor-photo'),
        semanticLabel: 'Жұмабаева Қарашаш Бұхарбекқызының суреті',
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      ),
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              canvas.withValues(alpha: .08),
              canvas.withValues(alpha: .04),
              canvas.withValues(alpha: .28),
              canvas,
            ],
            stops: const [0, .38, .69, 1],
          ),
        ),
      ),
    ],
  );
}
