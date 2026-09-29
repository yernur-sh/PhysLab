import 'package:flutter/material.dart';

enum UserRole { student, teacher }

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.isGoogleUser = false,
  });

  final String name;
  final String email;
  final UserRole role;
  final String? photoUrl;
  final bool isGoogleUser;
}

class PhysicsClass {
  const PhysicsClass({
    required this.name,
    required this.code,
    required this.grade,
    this.memberCount = 1,
  });

  final String name;
  final String code;
  final int grade;
  final int memberCount;
}

class AppState extends ChangeNotifier {
  UserProfile? profile;
  final List<PhysicsClass> classes = [];
  int completedTasks = 18;
  int streak = 4;
  int points = 1240;

  void signIn(UserProfile value) {
    profile = value;
    notifyListeners();
  }

  void signOut() {
    profile = null;
    classes.clear();
    notifyListeners();
  }

  PhysicsClass createClass(String name, int grade) {
    final seed = (DateTime.now().millisecondsSinceEpoch % 9000) + 1000;
    final item = PhysicsClass(name: name, code: 'PHY-$seed', grade: grade);
    classes.add(item);
    notifyListeners();
    return item;
  }

  bool joinClass(String code) {
    final normalized = code.trim().toUpperCase();
    if (!RegExp(r'^PHY-\d{4}$').hasMatch(normalized)) return false;
    if (classes.any((item) => item.code == normalized)) return true;
    classes.add(
      PhysicsClass(
        name: 'Физика зертханасы',
        code: normalized,
        grade: 9,
        memberCount: 18,
      ),
    );
    notifyListeners();
    return true;
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found');
    return scope!.notifier!;
  }
}

const primary = Color(0xFF5267F7);
const navy = Color(0xFF14213D);
const coral = Color(0xFFFF7A72);
const mint = Color(0xFF62D6B3);
const sunny = Color(0xFFFFC857);
