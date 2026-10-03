import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'firebase_options.dart';
import 'screens/auth_flow.dart';
import 'screens/session_gate.dart';

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
          fontFamily: 'Montserrat',
          fontFamilyFallback: const ['NotoSansMath'],
          colorScheme: ColorScheme.fromSeed(
            seedColor: primary,
            brightness: Brightness.light,
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: canvas,
          appBarTheme: const AppBarTheme(
            backgroundColor: canvas,
            foregroundColor: navy,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontFamily: 'Montserrat',
              color: navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -.4,
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: Color(0xFFE9EEF5),
            space: 1,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: Color(0xFFE8EDF5)),
            ),
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.iOS: _PhysLabPageTransitionsBuilder(),
              TargetPlatform.android: _PhysLabPageTransitionsBuilder(),
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
            fillColor: const Color(0xFFFDFEFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFE6EAF2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: primary, width: 1.5),
            ),
          ),
        ),
        home: Firebase.apps.isEmpty
            ? const OnboardingScreen()
            : SessionGate(appState: appState),
      ),
    );
  }
}

class _PhysLabPageTransitionsBuilder extends PageTransitionsBuilder {
  const _PhysLabPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context) || route.isFirst) {
      return child;
    }
    final entrance = animation.drive(CurveTween(curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: entrance,
      child: ScaleTransition(
        scale: entrance.drive(Tween<double>(begin: .97, end: 1)),
        child: child,
      ),
    );
  }
}
