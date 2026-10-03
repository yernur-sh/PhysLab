import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import 'auth_screen.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

/// Firebase keeps the login on device; this restores its PhysLab profile.
class SessionGate extends StatefulWidget {
  const SessionGate({super.key, required this.appState});

  final AppState appState;

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late Future<_StartDestination> destination = _restoreSession();

  Future<_StartDestination> _restoreSession() async {
    final user = await FirebaseAuth.instance.authStateChanges().first.timeout(
      const Duration(seconds: 12),
    );
    if (user == null) return _StartDestination.registration;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .timeout(const Duration(seconds: 12));
    if (!snapshot.exists) {
      return user.providerData.any(
            (provider) => provider.providerId == 'google.com',
          )
          ? _StartDestination.registration
          : _StartDestination.login;
    }

    final data = snapshot.data() ?? <String, dynamic>{};
    final providerIsGoogle = user.providerData.any(
      (provider) => provider.providerId == 'google.com',
    );
    final isGoogleUser = data['isGoogleUser'] == true || providerIsGoogle;
    final storedName = (data['name'] as String?)?.trim();
    final displayName = user.displayName?.trim();
    final photo = data['photoUrl'] as String?;
    widget.appState.signIn(
      UserProfile(
        uid: user.uid,
        name: storedName?.isNotEmpty == true
            ? storedName!
            : displayName?.isNotEmpty == true
            ? displayName!
            : 'PhysLab қолданушысы',
        email: user.email ?? (data['email'] as String? ?? ''),
        role: data['role'] == 'teacher' ? UserRole.teacher : UserRole.student,
        isGoogleUser: isGoogleUser,
        photoUrl: isGoogleUser ? (user.photoURL ?? photo) : null,
      ),
    );
    return _StartDestination.home;
  }

  Future<void> _continueAfterOnboarding(BuildContext context) async {
    _StartDestination next;
    try {
      next = await destination;
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Аккаунтты тексеру мүмкін болмады. Қайта көріңіз.'),
        ),
      );
      destination = _restoreSession();
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => switch (next) {
          _StartDestination.registration => const AuthScreen(),
          _StartDestination.login => const AuthScreen(initialLogin: true),
          _StartDestination.home => const MainShell(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      OnboardingScreen(onContinue: _continueAfterOnboarding);
}

enum _StartDestination { registration, login, home }
