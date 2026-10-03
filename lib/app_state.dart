import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'physics_data.dart';

enum UserRole { student, teacher }

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.isGoogleUser = false,
    this.uid = '',
  });

  final String name;
  final String email;
  final UserRole role;
  final String? photoUrl;
  final bool isGoogleUser;
  final String uid;
}

class PhysicsClass {
  const PhysicsClass({
    required this.name,
    required this.code,
    required this.grade,
    this.memberCount = 1,
    this.teacherUid = '',
  });

  final String name;
  final String code;
  final int grade;
  final int memberCount;
  final String teacherUid;
}

class AppState extends ChangeNotifier {
  UserProfile? profile;
  final List<PhysicsClass> classes = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _classSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _scoreSubscription;
  String? classSyncError;
  int completedTasks = 18;
  int streak = 4;
  final Map<int, int> quizBestScores = {};
  final Map<String, int> topicMastery = {};
  int get points =>
      quizBestScores.values.fold(0, (total, score) => total + score * 10);
  int get fullyCompletedQuizzes => quizBestScores.entries
      .where(
        (entry) =>
            entry.key >= 0 &&
            entry.key < quizSets.length &&
            entry.value >= quizSets[entry.key].questions.length,
      )
      .length;
  int get masteredTopicCount =>
      topicMastery.values.where((percent) => percent >= 80).length;

  void signIn(UserProfile value) {
    _classSubscription?.cancel();
    _scoreSubscription?.cancel();
    profile = value;
    classes.clear();
    quizBestScores.clear();
    topicMastery.clear();
    classSyncError = null;
    notifyListeners();
    if (value.uid.isNotEmpty && Firebase.apps.isNotEmpty) {
      _scoreSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(value.uid)
          .snapshots()
          .listen(
            (snapshot) {
              final raw = snapshot.data()?['quizScores'];
              quizBestScores.clear();
              if (raw is Map) {
                for (final entry in raw.entries) {
                  final index = int.tryParse(entry.key.toString());
                  final score = entry.value;
                  if (index != null &&
                      index >= 0 &&
                      index < quizSets.length &&
                      score is num) {
                    quizBestScores[index] = score.toInt().clamp(
                      0,
                      quizSets[index].questions.length,
                    );
                  }
                }
              }
              final topics = snapshot.data()?['topicMastery'];
              topicMastery.clear();
              if (topics is Map) {
                for (final entry in topics.entries) {
                  final percent = entry.value;
                  if (percent is num) {
                    topicMastery[entry.key.toString()] = percent.toInt().clamp(
                      0,
                      100,
                    );
                  }
                }
              }
              notifyListeners();
            },
            onError: (Object error) {
              classSyncError = 'Ұпайды жүктеу мүмкін болмады: $error';
              notifyListeners();
            },
          );
      _classSubscription = FirebaseFirestore.instance
          .collection('classes')
          .where('memberIds', arrayContains: value.uid)
          .snapshots()
          .listen(
            (snapshot) {
              classes
                ..clear()
                ..addAll(
                  snapshot.docs.map((doc) {
                    final data = doc.data();
                    return PhysicsClass(
                      name: data['name'] as String? ?? 'Физика класы',
                      code: doc.id,
                      grade: (data['grade'] as num?)?.toInt() ?? 7,
                      memberCount: (data['memberIds'] as List?)?.length ?? 1,
                      teacherUid: data['teacherUid'] as String? ?? '',
                    );
                  }),
                );
              classSyncError = null;
              notifyListeners();
            },
            onError: (Object error) {
              classSyncError = 'Кластарды жүктеу мүмкін болмады: $error';
              notifyListeners();
            },
          );
    }
  }

  void signOut() {
    _classSubscription?.cancel();
    _scoreSubscription?.cancel();
    _classSubscription = null;
    _scoreSubscription = null;
    profile = null;
    classes.clear();
    quizBestScores.clear();
    topicMastery.clear();
    notifyListeners();
  }

  Future<int> saveQuizResult(int quizIndex, int correctCount) async {
    if (quizIndex < 0 || quizIndex >= quizSets.length) {
      throw RangeError.index(quizIndex, quizSets, 'quizIndex');
    }
    final safeScore = correctCount.clamp(
      0,
      quizSets[quizIndex].questions.length,
    );
    final previous = quizBestScores[quizIndex] ?? 0;
    if (safeScore <= previous) return 0;
    final current = profile;
    if (current?.uid.isNotEmpty == true && Firebase.apps.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(current!.uid)
          .update({'quizScores.$quizIndex': safeScore});
    }
    quizBestScores[quizIndex] = safeScore;
    notifyListeners();
    return (safeScore - previous) * 10;
  }

  Future<int> saveTopicResult(String title, int correctCount) async {
    final percent = (correctCount.clamp(0, 5) * 20);
    final previous = topicMastery[title] ?? 0;
    if (percent <= previous) return previous;
    final current = profile;
    if (current?.uid.isNotEmpty == true && Firebase.apps.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(current!.uid)
          .update({'topicMastery.$title': percent});
    }
    topicMastery[title] = percent;
    notifyListeners();
    return percent;
  }

  Future<PhysicsClass> createClass(String name, int grade) async {
    final current = profile;
    if (current?.role != UserRole.teacher) {
      throw StateError('Класты тек мұғалім құра алады');
    }
    if (current!.uid.isEmpty || Firebase.apps.isEmpty) {
      throw StateError('Класс үшін Firebase жүйесіне кіру қажет');
    }
    final db = FirebaseFirestore.instance;
    final random = Random.secure();
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    for (var attempt = 0; attempt < 8; attempt++) {
      final code =
          'PHY-${List.generate(6, (_) => alphabet[random.nextInt(alphabet.length)]).join()}';
      final ref = db.collection('classes').doc(code);
      final created = await db.runTransaction<bool>((transaction) async {
        final existing = await transaction.get(ref);
        if (existing.exists) return false;
        transaction.set(ref, {
          'name': name,
          'grade': grade,
          'teacherUid': current.uid,
          'memberIds': [current.uid],
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.set(ref.collection('members').doc(current.uid), {
          'name': current.name,
          'email': current.email,
          'role': 'teacher',
          'joinedAt': FieldValue.serverTimestamp(),
        });
        return true;
      });
      if (created) {
        final item = PhysicsClass(
          name: name,
          code: code,
          grade: grade,
          teacherUid: current.uid,
        );
        if (!classes.any((existing) => existing.code == code)) {
          classes.add(item);
        }
        notifyListeners();
        return item;
      }
    }
    throw StateError('Класс кодын құру мүмкін болмады');
  }

  Future<bool> joinClass(String code) async {
    final normalized = code.trim().toUpperCase();
    if (!RegExp(r'^PHY-[A-HJ-NP-Z2-9]{6}$').hasMatch(normalized)) return false;
    if (classes.any((item) => item.code == normalized)) return true;
    final current = profile;
    if (current?.role != UserRole.student ||
        current!.uid.isEmpty ||
        Firebase.apps.isEmpty) {
      return false;
    }
    final ref = FirebaseFirestore.instance
        .collection('classes')
        .doc(normalized);
    final snapshot = await ref.get();
    if (!snapshot.exists) return false;
    final existingMembers = (snapshot.data()?['memberIds'] as List?) ?? [];
    if (existingMembers.contains(current.uid)) {
      final data = snapshot.data()!;
      if (!classes.any((item) => item.code == normalized)) {
        classes.add(
          PhysicsClass(
            name: data['name'] as String? ?? 'Физика класы',
            code: normalized,
            grade: (data['grade'] as num?)?.toInt() ?? 7,
            memberCount: existingMembers.length,
            teacherUid: data['teacherUid'] as String? ?? '',
          ),
        );
      }
      notifyListeners();
      return true;
    }
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final latest = await transaction.get(ref);
      if (!latest.exists) throw StateError('Класс табылмады');
      transaction.update(ref, {
        'memberIds': FieldValue.arrayUnion([current.uid]),
      });
      transaction.set(ref.collection('members').doc(current.uid), {
        'name': current.name,
        'email': current.email,
        'role': 'student',
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });
    final data = snapshot.data()!;
    if (!classes.any((item) => item.code == normalized)) {
      classes.add(
        PhysicsClass(
          name: data['name'] as String? ?? 'Физика класы',
          code: normalized,
          grade: (data['grade'] as num?)?.toInt() ?? 7,
          memberCount: ((data['memberIds'] as List?)?.length ?? 0) + 1,
          teacherUid: data['teacherUid'] as String? ?? '',
        ),
      );
    }
    notifyListeners();
    return true;
  }

  Future<void> renameClass(String code, String newName) async {
    final current = profile;
    final trimmed = newName.trim();
    if (current?.role != UserRole.teacher ||
        current!.uid.isEmpty ||
        Firebase.apps.isEmpty) {
      throw StateError('Класс атауын тек мұғалім өзгерте алады');
    }
    if (trimmed.isEmpty || trimmed.length > 80) {
      throw ArgumentError('Класс атауы 1–80 таңба болуы керек');
    }
    final original = classes.where((item) => item.code == code).firstOrNull;
    if (original == null || original.teacherUid != current.uid) {
      throw StateError('Класс табылмады');
    }
    await FirebaseFirestore.instance.collection('classes').doc(code).update({
      'name': trimmed,
    });
    // The active class snapshot updates the shared list; no second notify is needed.
  }

  Future<void> deleteClass(String code) async {
    final current = profile;
    if (current?.role != UserRole.teacher ||
        current!.uid.isEmpty ||
        Firebase.apps.isEmpty) {
      throw StateError('Класты тек мұғалім өшіре алады');
    }
    if (!classes.any(
      (item) => item.code == code && item.teacherUid == current.uid,
    )) {
      throw StateError('Класс табылмады');
    }
    final db = FirebaseFirestore.instance;
    final classRef = db.collection('classes').doc(code);
    final posts = await classRef.collection('posts').get();
    for (final post in posts.docs) {
      await _deleteCollection(db, post.reference.collection('comments'));
      await post.reference.delete();
    }
    await _deleteCollection(db, classRef.collection('members'));
    await classRef.delete();
    classes.removeWhere((item) => item.code == code);
    notifyListeners();
  }

  Future<void> _deleteCollection(
    FirebaseFirestore db,
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    while (true) {
      final page = await collection.limit(300).get();
      if (page.docs.isEmpty) return;
      final batch = db.batch();
      for (final doc in page.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  @override
  void dispose() {
    _classSubscription?.cancel();
    _scoreSubscription?.cancel();
    super.dispose();
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

  static AppState read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<AppStateScope>();
    assert(element != null, 'AppStateScope not found');
    return (element!.widget as AppStateScope).notifier!;
  }
}

const primary = Color(0xFF435BFA);
const navy = Color(0xFF132340);
const coral = Color(0xFFFF7F78);
const mint = Color(0xFF55CFAF);
const sunny = Color(0xFFFFBF5B);
const canvas = Color(0xFFF1F3FF);
const muted = Color(0xFF79849A);
