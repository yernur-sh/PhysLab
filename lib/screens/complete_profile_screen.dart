import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

/// Google authentication is complete, but the PhysLab profile is not yet saved.
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({
    super.key,
    required this.user,
    required this.suggestedName,
    required this.initialRole,
    this.photoUrl,
  });

  final User user;
  final String suggestedName;
  final String? photoUrl;
  final UserRole initialRole;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late final name = TextEditingController(text: widget.suggestedName);
  final code = TextEditingController();
  late UserRole role = widget.initialRole;
  bool saving = false;

  bool get canSave =>
      name.text.trim().length >= 2 &&
      (role == UserRole.student || code.text.trim() == 'pslm');

  @override
  void dispose() {
    name.dispose();
    code.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!canSave || saving) return;
    setState(() => saving = true);
    try {
      final doc = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid);
      if ((await doc.get()).exists) {
        throw StateError(
          'Бұл Google аккаунты бұрын тіркелген. Кіруді таңдаңыз.',
        );
      }
      final displayName = name.text.trim();
      await doc.set({
        'name': displayName,
        'email': widget.user.email ?? '',
        'role': role.name,
        'photoUrl': widget.photoUrl,
        'isGoogleUser': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await widget.user.updateDisplayName(displayName);
      if (!mounted) return;
      AppStateScope.of(context).signIn(
        UserProfile(
          uid: widget.user.uid,
          name: displayName,
          email: widget.user.email ?? '',
          role: role,
          photoUrl: widget.photoUrl,
          isGoogleUser: true,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } catch (error) {
      if (mounted) {
        showMessage(context, 'Профиль сақталмады: $error', error: true);
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Профильді сақтау')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'PhysLab-та қалай көрінесіз?',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: navy,
            ),
          ),
          const SizedBox(height: 20),
          IosSegmentedControl(
            labels: const ['Оқушы', 'Мұғалім'],
            selectedIndex: role == UserRole.student ? 0 : 1,
            onChanged: (index) => setState(
              () => role = index == 0 ? UserRole.student : UserRole.teacher,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: name,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Профильдегі аты-жөні',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          if (role == UserRole.teacher) ...[
            const SizedBox(height: 14),
            TextField(
              controller: code,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Мұғалімнің құпия коды',
                prefixIcon: Icon(Icons.key_rounded),
              ),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Профильді сақтау',
            loading: saving,
            onPressed: canSave ? _save : null,
          ),
        ],
      ),
    ),
  );
}
