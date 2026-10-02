import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../app_state.dart';
import '../widgets/common.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final repeatPassword = TextEditingController();
  bool saving = false;

  @override
  void dispose() {
    currentPassword.dispose();
    newPassword.dispose();
    repeatPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      showMessage(context, 'Алдымен аккаунтқа кіріңіз', error: true);
      return;
    }
    final hasPassword = user.providerData.any(
      (item) => item.providerId == 'password',
    );
    setState(() => saving = true);
    try {
      if (hasPassword) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword.text,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword.text);
      } else {
        // Google-only accounts have no PhysLab password yet. Reauthenticate
        // with Google, then link an email/password sign-in to the same UID.
        if (kIsWeb) {
          final provider = GoogleAuthProvider()
            ..setCustomParameters({'prompt': 'select_account'});
          await user.reauthenticateWithPopup(provider);
        } else {
          final google = GoogleSignIn(scopes: ['email', 'profile']);
          await google.signOut();
          final account = await google.signIn();
          if (account == null) return;
          if (account.email.toLowerCase() != user.email!.toLowerCase()) {
            throw StateError(
              'Осы аккаунтқа байланысқан Google поштасын таңдаңыз',
            );
          }
          final token = await account.authentication;
          await user.reauthenticateWithCredential(
            GoogleAuthProvider.credential(
              accessToken: token.accessToken,
              idToken: token.idToken,
            ),
          );
        }
        await user.linkWithCredential(
          EmailAuthProvider.credential(
            email: user.email!,
            password: newPassword.text,
          ),
        );
      }
      if (!mounted) return;
      showMessage(
        context,
        hasPassword ? 'Құпиясөз өзгертілді' : 'PhysLab құпиясөзі орнатылды',
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'wrong-password' || 'invalid-credential' => 'Ағымдағы құпиясөз қате',
        'weak-password' => 'Жаңа құпиясөз тым әлсіз',
        'requires-recent-login' => 'Қайта кіріп, әрекетті қайталаңыз',
        'provider-already-linked' => 'Бұл аккаунтта PhysLab құпиясөзі бар',
        _ => 'Құпиясөз өзгермеді: ${error.message ?? error.code}',
      };
      showMessage(context, message, error: true);
    } catch (error) {
      if (mounted) showMessage(context, '$error', error: true);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final hasPassword =
        user?.providerData.any((item) => item.providerId == 'password') ??
        false;
    return Scaffold(
      appBar: AppBar(
        title: Text(hasPassword ? 'Құпиясөзді өзгерту' : 'Құпиясөз орнату'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SoftCard(
              color: const Color(0xFFE9EDFF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lock_reset_rounded,
                    color: primary,
                    size: 34,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hasPassword
                        ? 'Аккаунтыңызды қорғау үшін алдымен қазіргі құпиясөзді растаңыз.'
                        : 'Google аккаунтының құпиясөзі өзгермейді. PhysLab үшін бөлек құпиясөз орнатып, email арқылы да кіре аласыз.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Form(
              key: formKey,
              child: Column(
                children: [
                  if (hasPassword) ...[
                    TextFormField(
                      controller: currentPassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Қазіргі құпиясөз',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Қазіргі құпиясөзді енгізіңіз'
                          : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: newPassword,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Жаңа құпиясөз',
                    ),
                    validator: (value) => value == null || value.length < 8
                        ? 'Кемінде 8 таңба болуы керек'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: repeatPassword,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Жаңа құпиясөзді қайталау',
                    ),
                    validator: (value) => value != newPassword.text
                        ? 'Құпиясөздер сәйкес емес'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: hasPassword ? 'Өзгерту' : 'Орнату',
                    loading: saving,
                    onPressed: _save,
                    icon: Icons.check_circle_rounded,
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
