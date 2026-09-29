import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'firebase_options.dart';
import 'screens/auth_flow.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // The UI remains usable in preview/test environments without Firebase.
  }
  runApp(const PhysLabApp());
}

class PhysLabApp extends StatefulWidget {
  const PhysLabApp({super.key});

  @override
  State<PhysLabApp> createState() => _PhysLabAppState();
}

class _PhysLabAppState extends State<PhysLabApp> {
  late final AppState appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: appState,
      child: MaterialApp(
        title: 'PhysLabv',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5267F7)),
          scaffoldBackgroundColor: const Color(0xFFF7F8FD),
          fontFamily: 'SF Pro Display',
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE8EAF4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFF5267F7),
                width: 1.5,
              ),
            ),
          ),
        ),
        home: const OnboardingScreen(),
      ),
    );
  }
}
