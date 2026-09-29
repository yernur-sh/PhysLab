import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

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
  ];

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
                  const Text(
                    'PhysLabv',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const Spacer(),
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
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      child: Column(
                        key: ValueKey(index),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: .86, end: 1),
                            duration: const Duration(milliseconds: 650),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) =>
                                Transform.scale(scale: value, child: child),
                            child: Container(
                              width: 230,
                              height: 230,
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: .12),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(item.icon, size: 105, color: item.color),
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
                                      color: item.color,
                                      size: 34,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 31,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
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
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
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
                      duration: const Duration(milliseconds: 380),
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

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialLogin = false});
  final bool initialLogin;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final secretController = TextEditingController();
  late bool isLogin = widget.initialLogin;
  UserRole role = UserRole.student;
  bool obscure = true;
  bool loading = false;

  bool get teacherCodeValid =>
      role == UserRole.student || secretController.text.trim() == 'pslm';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 36),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    BrandMark(size: 44),
                    SizedBox(width: 12),
                    Text(
                      'PhysLabv',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                Text(
                  isLogin ? 'Қайта оралғаныңа қуаныштымыз!' : 'Аккаунт құру',
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isLogin
                      ? 'Оқуды жалғастыру үшін жүйеге кір.'
                      : 'Өзіңе сәйкес рөлді таңдап, PhysLabv-ке қосыл.',
                  style: const TextStyle(
                    color: Color(0xFF747B90),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 26),
                SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(
                      value: UserRole.student,
                      label: Text('Оқушы'),
                      icon: Icon(Icons.school_rounded),
                    ),
                    ButtonSegment(
                      value: UserRole.teacher,
                      label: Text('Мұғалім'),
                      icon: Icon(Icons.cast_for_education_rounded),
                    ),
                  ],
                  selected: {role},
                  onSelectionChanged: (value) =>
                      setState(() => role = value.first),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.comfortable,
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (!isLogin) ...[
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Аты-жөні',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) =>
                        value == null || value.trim().length < 2
                        ? 'Аты-жөніңді енгіз'
                        : null,
                  ),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (value) => value != null && value.contains('@')
                      ? null
                      : 'Email дұрыс емес',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'Құпиясөз',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.length < 6
                      ? 'Кемінде 6 таңба енгіз'
                      : null,
                ),
                if (role == UserRole.teacher) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    key: const Key('teacher-secret-field'),
                    controller: secretController,
                    obscureText: true,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Мұғалімнің құпия коды',
                      helperText:
                          'Код расталғаннан кейін ғана жалғастыра аласыз',
                      prefixIcon: const Icon(Icons.key_rounded),
                      suffixIcon: teacherCodeValid
                          ? const Icon(Icons.check_circle_rounded, color: mint)
                          : null,
                    ),
                    validator: (_) =>
                        teacherCodeValid ? null : 'Құпия код қате',
                  ),
                ],
                if (isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => showMessage(
                        context,
                        'Құпиясөзді қалпына келтіру сілтемесі жіберіледі',
                      ),
                      child: const Text('Құпиясөзді ұмыттың ба?'),
                    ),
                  )
                else
                  const SizedBox(height: 22),
                PrimaryButton(
                  label: isLogin ? 'Кіру' : 'Тіркелу',
                  loading: loading,
                  onPressed: teacherCodeValid ? _submit : null,
                  icon: isLogin
                      ? Icons.login_rounded
                      : Icons.person_add_rounded,
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'немесе',
                        style: TextStyle(color: Color(0xFF9298AA)),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    key: const Key('google-auth-button'),
                    onPressed: loading || !teacherCodeValid
                        ? null
                        : _googleSignIn,
                    icon: const Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    label: const Text(
                      'Google-мен жалғастыру',
                      style: TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      side: const BorderSide(color: Color(0xFFDDE0EA)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isLogin ? 'Аккаунтың жоқ па?' : 'Аккаунтың бар ма?'),
                    TextButton(
                      key: const Key('auth-mode-toggle'),
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(isLogin ? 'Тіркелу' : 'Кіру'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => loading = true);
    try {
      final auth = FirebaseAuth.instance;
      UserCredential result;
      if (isLogin) {
        result = await auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      } else {
        result = await auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
        await result.user?.updateDisplayName(nameController.text.trim());
      }
      if (!mounted) return;
      _complete(
        UserProfile(
          name:
              result.user?.displayName ??
              (nameController.text.trim().isEmpty
                  ? 'PhysLab қолданушысы'
                  : nameController.text.trim()),
          email: result.user?.email ?? emailController.text.trim(),
          role: role,
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'email-already-in-use' => 'Бұл email бұрын тіркелген',
        'invalid-credential' => 'Email немесе құпиясөз қате',
        'weak-password' => 'Құпиясөз тым әлсіз',
        _ => 'Кіру мүмкін болмады: ${error.message ?? error.code}',
      };
      showMessage(context, message, error: true);
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Firebase-ке қосылу мүмкін болмады', error: true);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    if (!teacherCodeValid) return;
    setState(() => loading = true);
    try {
      final provider = GoogleAuthProvider();
      final result = await FirebaseAuth.instance.signInWithProvider(provider);
      if (!mounted) return;
      _complete(
        UserProfile(
          name: result.user?.displayName ?? 'PhysLab қолданушысы',
          email: result.user?.email ?? '',
          role: role,
          photoUrl: result.user?.photoURL,
          isGoogleUser: true,
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (mounted && error.code != 'web-context-canceled') {
        showMessage(
          context,
          'Google арқылы кіру мүмкін болмады: ${error.message ?? error.code}',
          error: true,
        );
      }
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Google арқылы кіру бапталмаған', error: true);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _complete(UserProfile profile) {
    AppStateScope.of(context).signIn(profile);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }
}
