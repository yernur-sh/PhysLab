import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../app_state.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

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
                      'PhysLab',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 56),
                Text(
                  isLogin ? 'Қайта оралғаныңа қуаныштымыз!' : 'Аккаунт құру',
                  style: const TextStyle(
                    fontSize: 28,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.8,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isLogin
                      ? 'Оқуды жалғастыру үшін жүйеге кір.'
                      : 'Өзіңе сәйкес рөлді таңдап, PhysLab-қа қосыл.',
                  style: const TextStyle(color: muted, fontSize: 14),
                ),
                const SizedBox(height: 26),
                if (!isLogin) ...[
                  IosSegmentedControl(
                    labels: const ['Оқушы', 'Мұғалім'],
                    selectedIndex: role == UserRole.student ? 0 : 1,
                    onChanged: (value) => setState(
                      () => role = value == 0
                          ? UserRole.student
                          : UserRole.teacher,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    onChanged: (_) => setState(() {}),
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
                if (!isLogin && role == UserRole.teacher) ...[
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
                      onPressed: _resetPassword,
                      child: const Text('Құпиясөзді ұмыттың ба?'),
                    ),
                  )
                else
                  const SizedBox(height: 22),
                PrimaryButton(
                  label: isLogin ? 'Кіру' : 'Тіркелу',
                  loading: loading,
                  onPressed: isLogin || teacherCodeValid ? _submit : null,
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
                    onPressed: loading || (!isLogin && !teacherCodeValid)
                        ? null
                        : _googleSignIn,
                    icon: Image.asset(
                      'assets/branding/google_g.png',
                      key: const Key('google-brand-icon'),
                      width: 22,
                      height: 22,
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
      final user = result.user;
      if (user == null) throw StateError('Қолданушы табылмады');
      final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final existing = await doc.get();
      if (isLogin && !existing.exists) {
        await auth.signOut();
        throw StateError(
          'Бұл аккаунттың профилі табылмады. Тіркелуді таңдаңыз.',
        );
      }
      if (!isLogin && existing.exists) {
        throw StateError('Бұл аккаунт бұрын тіркелген. Кіруді таңдаңыз.');
      }
      if (!existing.exists) {
        await doc.set({
          'name': isLogin
              ? (user.displayName ?? 'PhysLab қолданушысы')
              : nameController.text.trim(),
          'email': user.email ?? emailController.text.trim(),
          'role': role.name,
          'isGoogleUser': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      final data = (await doc.get()).data() ?? {};
      if (!mounted) return;
      _complete(
        UserProfile(
          uid: user.uid,
          name:
              data['name'] as String? ??
              user.displayName ??
              'PhysLab қолданушысы',
          email: user.email ?? emailController.text.trim(),
          role: data['role'] == 'teacher' ? UserRole.teacher : UserRole.student,
          photoUrl: null,
          isGoogleUser: false,
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
    } catch (error) {
      if (mounted) {
        showMessage(
          context,
          error is StateError
              ? error.message
              : 'Firebase-ке қосылу мүмкін болмады: $error',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    if (!isLogin && !teacherCodeValid) return;
    setState(() => loading = true);
    try {
      UserCredential result;
      String? selectedPhoto;
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        result = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final google = GoogleSignIn(scopes: ['email', 'profile']);
        await google.signOut();
        final selected = await google.signIn();
        if (selected == null) return;
        selectedPhoto = selected.photoUrl;
        final tokens = await selected.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: tokens.accessToken,
          idToken: tokens.idToken,
        );
        result = await FirebaseAuth.instance.signInWithCredential(credential);
      }
      if (!mounted) return;
      final user = result.user;
      if (user == null) throw StateError('Google аккаунты табылмады');
      UserInfo? googleInfo;
      for (final info in user.providerData) {
        if (info.providerId == 'google.com') {
          googleInfo = info;
          break;
        }
      }
      final displayName = user.displayName?.trim();
      final providerName = googleInfo?.displayName?.trim();
      final googleName = displayName?.isNotEmpty == true
          ? displayName!
          : providerName?.isNotEmpty == true
          ? providerName!
          : (user.email ?? googleInfo?.email ?? 'PhysLab қолданушысы')
                .split('@')
                .first;
      final googlePhoto = user.photoURL?.isNotEmpty == true
          ? user.photoURL
          : (googleInfo?.photoURL ?? selectedPhoto);
      final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final existing = await doc.get();
      if (!existing.exists) {
        if (isLogin) {
          await FirebaseAuth.instance.signOut();
          throw StateError(
            'Бұл Google аккаунты тіркелмеген. Алдымен тіркеліңіз.',
          );
        }
        await doc.set({
          'name': googleName,
          'email': user.email ?? googleInfo?.email ?? '',
          'role': role.name,
          'photoUrl': googlePhoto,
          'isGoogleUser': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else if (!isLogin) {
        await FirebaseAuth.instance.signOut();
        throw StateError('Бұл Google аккаунты тіркелген. Кіруді таңдаңыз.');
      } else if (existing.data()?['isGoogleUser'] == true) {
        await doc.update({
          'name': googleName,
          if (googlePhoto != null) 'photoUrl': googlePhoto,
        });
      }
      final data = (await doc.get()).data() ?? {};
      _complete(
        UserProfile(
          uid: user.uid,
          name: data['name'] as String? ?? googleName,
          email: user.email ?? googleInfo?.email ?? '',
          role: data['role'] == 'teacher' ? UserRole.teacher : UserRole.student,
          photoUrl: googlePhoto ?? data['photoUrl'] as String?,
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
    } catch (error) {
      if (mounted) {
        showMessage(
          context,
          error is StateError
              ? error.message
              : 'Google арқылы кіру мүмкін болмады: $error',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();
    if (!email.contains('@')) {
      showMessage(context, 'Алдымен email енгізіңіз', error: true);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        showMessage(context, 'Құпиясөзді қалпына келтіру хаты жіберілді');
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        showMessage(
          context,
          'Хатты жіберу мүмкін болмады: ${error.message ?? error.code}',
          error: true,
        );
      }
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
