import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../app_state.dart';
import 'auth_screen.dart';

Future<void> showDeleteAccountDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => _DeleteAccountDialog(
    onDeleted: () {
      if (!context.mounted) return;
      AppStateScope.of(context).signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (_) => false,
      );
    },
  ),
);

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.onDeleted});

  final VoidCallback onDeleted;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final password = TextEditingController();
  bool busy = false;
  String? errorText;

  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || busy) return;
    final hasPassword = user.providerData.any(
      (provider) => provider.providerId == 'password',
    );
    if (hasPassword && password.text.isEmpty) {
      setState(() => errorText = 'Құпиясөзді енгізіңіз');
      return;
    }
    setState(() {
      busy = true;
      errorText = null;
    });
    try {
      if (hasPassword) {
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: user.email!,
            password: password.text,
          ),
        );
      } else if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        await user.reauthenticateWithPopup(provider);
      } else {
        final google = GoogleSignIn(scopes: ['email', 'profile']);
        await google.signOut();
        final account = await google.signIn();
        if (account == null) return;
        if (account.email.toLowerCase() != user.email?.toLowerCase()) {
          throw StateError(
            'Осы аккаунтқа байланысқан Google поштасын таңдаңыз',
          );
        }
        final tokens = await account.authentication;
        await user.reauthenticateWithCredential(
          GoogleAuthProvider.credential(
            accessToken: tokens.accessToken,
            idToken: tokens.idToken,
          ),
        );
      }
      if (!mounted) return;
      await AppStateScope.of(context).deleteAccountData();
      await user.delete();
      if (!mounted) return;
      widget.onDeleted();
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(
          () => errorText = switch (error.code) {
            'wrong-password' || 'invalid-credential' => 'Құпиясөз қате',
            'requires-recent-login' => 'Қайта кіріп, әрекетті қайталаңыз',
            _ => 'Өшіру мүмкін болмады: ${error.message ?? error.code}',
          },
        );
      }
    } catch (error) {
      if (mounted) setState(() => errorText = 'Өшіру аяқталмады: $error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final hasPassword =
        user?.providerData.any(
          (provider) => provider.providerId == 'password',
        ) ??
        false;
    return AlertDialog(
      title: const Text('Аккаунтты өшіру'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasPassword
                ? 'Растау үшін құпиясөзіңізді енгізіңіз. Бұл әрекетті қайтару мүмкін емес.'
                : 'Бұл аккаунтта PhysLab құпиясөзі жоқ. Google арқылы қайта растаңыз.',
          ),
          if (hasPassword) ...[
            const SizedBox(height: 16),
            TextField(
              controller: password,
              obscureText: true,
              autofocus: true,
              enabled: !busy,
              onSubmitted: (_) => _delete(),
              decoration: const InputDecoration(labelText: 'Құпиясөз'),
            ),
          ],
          if (errorText != null) ...[
            const SizedBox(height: 10),
            Text(errorText!, style: const TextStyle(color: Color(0xFFE45757))),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Болдырмау'),
        ),
        FilledButton(
          onPressed: busy ? null : _delete,
          child: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(hasPassword ? 'Өшіру' : 'Google-мен растау'),
        ),
      ],
    );
  }
}
