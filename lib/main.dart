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
        title: 'PhysLab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: primary),
          scaffoldBackgroundColor: canvas,
          appBarTheme: const AppBarTheme(
            backgroundColor: canvas,
            foregroundColor: navy,
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: navy,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -.4,
            ),
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            },
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: canvas,
            surfaceTintColor: Colors.transparent,
            showDragHandle: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Colors.white,
            selectedColor: primary.withValues(alpha: .12),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(color: Color(0xFFE6EAF2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(color: primary, width: 1.5),
            ),
          ),
        ),
        home: const OnboardingScreen(),
      ),
    );
  }
}
