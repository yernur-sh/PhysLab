import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../widgets/common.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({super.key, required this.physicsClass});
  final PhysicsClass physicsClass;

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen>
    with SingleTickerProviderStateMixin {
  late String className = widget.physicsClass.name;
  bool managingClass = false;
  late final TabController tabs = TabController(length: 3, vsync: this)
    ..addListener(() {
      if (mounted) setState(() {});
    });

  DocumentReference<Map<String, dynamic>> get classRef => FirebaseFirestore
      .instance
      .collection('classes')
      .doc(widget.physicsClass.code);

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppStateScope.of(context).profile;
    final isTeacher =
        profile?.role == UserRole.teacher &&
        profile?.uid == widget.physicsClass.teacherUid;
    return Scaffold(
      appBar: AppBar(
        title: Text(className),
        actions: [
          if (isTeacher)
            PopupMenuButton<String>(
              key: const Key('class-actions-menu'),
              tooltip: 'Класты басқару',
              enabled: !managingClass,
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (action) =>
                  action == 'rename' ? _renameClass() : _deleteClass(),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'rename',
                  child: ListTile(
                    leading: Icon(Icons.drive_file_rename_outline_rounded),
                    title: Text('Класс атын өзгерту'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline_rounded, color: coral),
                    title: Text('Класты өшіру', style: TextStyle(color: coral)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF213A78), Color(0xFF5A73D9)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0x33FFFFFF),
                        child: Icon(Icons.groups_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              className,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '${widget.physicsClass.grade}-сынып · ${widget.physicsClass.code}',
                              style: const TextStyle(color: Color(0xFFDCE5FF)),
                            ),
                          ],
                        ),
                      ),
                      if (isTeacher)
                        IconButton(
                          tooltip: 'Класс кодын көшіру',
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: widget.physicsClass.code),
                            );
                            if (context.mounted) {
                              showMessage(context, 'Класс коды көшірілді');
                            }
                          },
                          icon: const Icon(Icons.copy_rounded, color: primary),
                        ),
                    ],
                  ),
                ),
              ),
              TabBar(
                controller: tabs,
                labelColor: primary,
                unselectedLabelColor: muted,
                indicatorColor: primary,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Хабарламалар'),
                  Tab(text: 'Үй жұмысы'),
                  Tab(text: 'Оқушылар'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: tabs,
                  children: [
                    _ClassPosts(
                      classRef: classRef,
                      type: 'announcement',
                      profile: profile,
                      isTeacher: isTeacher,
                    ),
                    _ClassPosts(
                      classRef: classRef,
                      type: 'homework',
                      profile: profile,
                      isTeacher: isTeacher,
                    ),
                    _ClassStudents(classRef: classRef),
                  ],
                ),
              ),
            ],
          ),
          if (managingClass)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.white70,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Класс жаңартылып жатыр…'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: isTeacher && tabs.index != 2 && !managingClass
          ? FloatingActionButton.extended(
              onPressed: () => _editPost(
                context,
                classRef,
                profile!,
                tabs.index == 0 ? 'announcement' : 'homework',
              ),
              icon: const Icon(Icons.edit_square),
              label: Text(
                tabs.index == 0 ? 'Хабарлама жазу' : 'Үй жұмысын беру',
              ),
            )
          : null,
    );
  }

  Future<void> _renameClass() async {
    final appState = AppStateScope.read(context);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameClassDialog(initialName: className),
    );
    if (!mounted || name == null) return;
    if (name.isEmpty) {
      showMessage(context, 'Класс атауын енгізіңіз', error: true);
      return;
    }
    if (name == className) return;
    setState(() => managingClass = true);
    try {
      await appState.renameClass(widget.physicsClass.code, name);
      if (mounted) {
        setState(() => className = name);
        showMessage(context, 'Класс атауы өзгертілді');
      }
    } catch (error) {
      if (mounted) {
        showMessage(context, 'Өзгерту мүмкін болмады: $error', error: true);
      }
    } finally {
      if (mounted) setState(() => managingClass = false);
    }
  }

  Future<void> _deleteClass() async {
    final appState = AppStateScope.read(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Класты өшіру керек пе?'),
        content: Text(
          '«$className» класындағы хабарламалар, үй жұмыстары мен пікірлер де өшіріледі. Бұл әрекетті қайтару мүмкін емес.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Болдырмау'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: coral),
            child: const Text('Класты өшіру'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => managingClass = true);
    try {
      await appState.deleteClass(widget.physicsClass.code);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        showMessage(
          context,
          'Класты өшіру мүмкін болмады: $error',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => managingClass = false);
    }
  }
}

class _RenameClassDialog extends StatefulWidget {
  const _RenameClassDialog({required this.initialName});
  final String initialName;

  @override
  State<_RenameClassDialog> createState() => _RenameClassDialogState();
}

class _RenameClassDialogState extends State<_RenameClassDialog> {
  late final controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Класс атын өзгерту'),
    content: TextField(
      controller: controller,
      autofocus: true,
      maxLength: 80,
      decoration: const InputDecoration(labelText: 'Класс атауы'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Болдырмау'),
      ),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(controller.text.trim()),
        child: const Text('Сақтау'),
      ),
    ],
  );
}

class _ClassPosts extends StatelessWidget {
  const _ClassPosts({
    required this.classRef,
    required this.type,
    required this.profile,
    required this.isTeacher,
  });
  final DocumentReference<Map<String, dynamic>> classRef;
  final String type;
  final UserProfile? profile;
  final bool isTeacher;

  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: classRef
        .collection('posts')
        .where('type', isEqualTo: type)
        .snapshots(includeMetadataChanges: true),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return _classMessage('Жарияланымдарды жүктеу мүмкін болмады');
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final docs =
          snapshot.data!.docs
              .where((doc) => !doc.metadata.hasPendingWrites)
              .toList()
            ..sort(
              (a, b) =>
                  _createdMillis(b.data()).compareTo(_createdMillis(a.data())),
            );
      if (docs.isEmpty) {
        return _classMessage(
          type == 'announcement'
              ? 'Әзірге хабарлама жоқ'
              : 'Әзірге үй жұмысы жоқ',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          final data = doc.data();
          final date = (data['createdAt'] as Timestamp?)?.toDate();
          final due = (data['dueAt'] as Timestamp?)?.toDate();
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 16, 12, 8),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFE9EDFF),
                          foregroundColor: primary,
                          child: Icon(Icons.person_rounded),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['authorName'] as String? ?? 'Мұғалім',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                date == null ? 'Жаңа жарияланым' : _date(date),
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 7, 17, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] as String? ?? '',
                          style: const TextStyle(
                            color: navy,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          data['body'] as String? ?? '',
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(height: 1.45),
                        ),
                        if (due != null) ...[
                          const SizedBox(height: 9),
                          Text(
                            'Мерзімі: ${_date(due)}',
                            style: const TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (isTeacher) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _EditDeleteButtons(
                              onEdit: () => _editPost(
                                context,
                                classRef,
                                profile!,
                                type,
                                existing: doc,
                              ),
                              onDelete: () =>
                                  _deletePost(context, doc.reference),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClassPostScreen(
                          classRef: classRef,
                          postId: doc.id,
                          profile: profile,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Пікірлер мен сұрақтар'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _ClassStudents extends StatelessWidget {
  const _ClassStudents({required this.classRef});
  final DocumentReference<Map<String, dynamic>> classRef;

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: classRef.collection('members').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _classMessage('Оқушыларды жүктеу мүмкін болмады');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data!.docs
              .where((doc) => doc.data()['role'] == 'student')
              .toList();
          if (students.isEmpty) {
            return _classMessage('Бұл классқа оқушылар әлі қосылмады');
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
            itemCount: students.length,
            separatorBuilder: (_, _) => const SizedBox(height: 9),
            itemBuilder: (context, index) {
              final student = students[index].data();
              return SoftCard(
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFE9EDFF),
                      foregroundColor: primary,
                      child: Icon(Icons.person_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        student['name'] as String? ?? 'Оқушы',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
}

class ClassPostScreen extends StatefulWidget {
  const ClassPostScreen({
    super.key,
    required this.classRef,
    required this.postId,
    required this.profile,
  });
  final DocumentReference<Map<String, dynamic>> classRef;
  final String postId;
  final UserProfile? profile;

  @override
  State<ClassPostScreen> createState() => _ClassPostScreenState();
}

class _ClassPostScreenState extends State<ClassPostScreen> {
  final question = TextEditingController();
  bool sending = false;
  String? sendError;

  @override
  void dispose() {
    question.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postRef = widget.classRef.collection('posts').doc(widget.postId);
    return Scaffold(
      appBar: AppBar(title: const Text('Жарияланым')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: postRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _classMessage('Жарияланымды ашу мүмкін болмады');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data();
          if (data == null) return _classMessage('Жарияланым өшірілген');
          final isTeacher = widget.profile?.uid == data['authorUid'];
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    SoftCard(
                      color: const Color(0xFFE9EDFF),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['title'] as String? ?? '',
                                  style: const TextStyle(
                                    color: navy,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          Text(
                            data['body'] as String? ?? '',
                            style: const TextStyle(height: 1.5),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            data['authorName'] as String? ?? '',
                            style: const TextStyle(color: muted),
                          ),
                          if (isTeacher) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _EditDeleteButtons(
                                onEdit: () => _editPost(
                                  context,
                                  widget.classRef,
                                  widget.profile!,
                                  data['type'] as String? ?? 'announcement',
                                  existing: snapshot.data,
                                ),
                                onDelete: () async {
                                  final deleted = await _deletePost(
                                    context,
                                    postRef,
                                  );
                                  if (deleted && context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Пікірлер мен сұрақтар',
                      style: TextStyle(
                        color: navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: postRef
                          .collection('comments')
                          .orderBy('createdAt')
                          .snapshots(includeMetadataChanges: true),
                      builder: (context, comments) {
                        if (comments.hasError) {
                          return const Text('Пікірлерді жүктеу мүмкін болмады');
                        }
                        if (!comments.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final savedComments = comments.data!.docs
                            .where((doc) => !doc.metadata.hasPendingWrites)
                            .toList();
                        if (savedComments.isEmpty) {
                          return const Text(
                            'Әзірге пікір жоқ',
                            style: TextStyle(color: muted),
                          );
                        }
                        return Column(
                          children: savedComments.map((doc) {
                            final item = doc.data();
                            final own =
                                widget.profile?.uid == item['authorUid'];
                            return Align(
                              alignment: own
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 310,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 9),
                                  child: SoftCard(
                                    color: own
                                        ? const Color(0xFFE9EDFF)
                                        : Colors.white,
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      9,
                                      8,
                                      12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                item['authorName'] as String? ??
                                                    'Қатысушы',
                                                style: const TextStyle(
                                                  color: primary,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          item['body'] as String? ?? '',
                                          style: const TextStyle(height: 1.4),
                                        ),
                                        if (own || isTeacher) ...[
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: _EditDeleteButtons(
                                              onEdit: own
                                                  ? () => _editComment(
                                                      context,
                                                      doc.reference,
                                                      item['body'] as String? ??
                                                          '',
                                                    )
                                                  : null,
                                              onDelete: () => _deleteComment(
                                                context,
                                                doc.reference,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sendError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            sendError!,
                            style: const TextStyle(color: coral, fontSize: 12),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: question,
                              minLines: 1,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Пікір немесе сұрақ жаз...',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: sending
                                ? null
                                : () => _sendComment(postRef),
                            icon: const Icon(Icons.send_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _sendComment(
    DocumentReference<Map<String, dynamic>> postRef,
  ) async {
    final value = question.text.trim();
    if (value.isEmpty || widget.profile == null) return;
    setState(() {
      sending = true;
      sendError = null;
    });
    try {
      await postRef.collection('comments').add({
        'body': value,
        'authorUid': widget.profile!.uid,
        'authorName': widget.profile!.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      question.clear();
    } catch (error) {
      if (mounted) {
        setState(() => sendError = 'Пікір жіберілмеді: $error');
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }
}

Future<void> _editPost(
  BuildContext context,
  DocumentReference<Map<String, dynamic>> classRef,
  UserProfile profile,
  String type, {
  DocumentSnapshot<Map<String, dynamic>>? existing,
}) async {
  final initial = existing?.data() ?? {};
  final title = TextEditingController(text: initial['title'] as String? ?? '');
  final body = TextEditingController(text: initial['body'] as String? ?? '');
  DateTime? dueAt = (initial['dueAt'] as Timestamp?)?.toDate();
  var saving = false;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing != null
                    ? 'Жарияланымды өзгерту'
                    : type == 'homework'
                    ? 'Үй жұмысын жариялау'
                    : 'Хабарлама жариялау',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: title,
                maxLength: 80,
                decoration: const InputDecoration(labelText: 'Тақырып'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: body,
                maxLines: 4,
                maxLength: 2000,
                decoration: const InputDecoration(labelText: 'Мәтін'),
              ),
              if (type == 'homework')
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: sheetContext,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                      initialDate: dueAt ?? DateTime.now(),
                    );
                    if (picked != null) setSheetState(() => dueAt = picked);
                  },
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(
                    dueAt == null ? 'Тапсыру күнін таңдау' : _date(dueAt!),
                  ),
                ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: existing == null ? 'Жариялау' : 'Сақтау',
                loading: saving,
                onPressed: saving
                    ? null
                    : () async {
                        if (title.text.trim().isEmpty ||
                            body.text.trim().isEmpty) {
                          showMessage(
                            sheetContext,
                            'Тақырып пен мәтінді толтырыңыз',
                            error: true,
                          );
                          return;
                        }
                        setSheetState(() => saving = true);
                        try {
                          if (existing == null) {
                            await classRef.collection('posts').doc().set({
                              'type': type,
                              'title': title.text.trim(),
                              'body': body.text.trim(),
                              'authorUid': profile.uid,
                              'authorName': profile.name,
                              'createdAt': FieldValue.serverTimestamp(),
                              if (dueAt != null)
                                'dueAt': Timestamp.fromDate(dueAt!),
                            });
                          } else {
                            await existing.reference.update({
                              'title': title.text.trim(),
                              'body': body.text.trim(),
                              'editedAt': FieldValue.serverTimestamp(),
                              if (dueAt != null)
                                'dueAt': Timestamp.fromDate(dueAt!),
                            });
                          }
                        } catch (error) {
                          if (sheetContext.mounted) {
                            showMessage(
                              sheetContext,
                              'Жариялау мүмкін болмады: $error',
                              error: true,
                            );
                            setSheetState(() => saving = false);
                          }
                          return;
                        }
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                        if (context.mounted) {
                          showMessage(
                            context,
                            existing == null ? 'Жарияланды' : 'Өзгертілді',
                          );
                        }
                      },
                icon: Icons.send_rounded,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  // The sheet's exit animation briefly retains its TextFields after pop.
  await Future<void>.delayed(const Duration(milliseconds: 500));
  title.dispose();
  body.dispose();
}

Future<bool> _deletePost(
  BuildContext context,
  DocumentReference<Map<String, dynamic>> postRef,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Жарияланымды өшіру керек пе?'),
      content: const Text('Пікірлер мен сұрақтар да өшіріледі.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Болдырмау'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Өшіру'),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;
  try {
    while (true) {
      final comments = await postRef.collection('comments').limit(400).get();
      if (comments.docs.isEmpty) break;
      final batch = FirebaseFirestore.instance.batch();
      for (final comment in comments.docs) {
        batch.delete(comment.reference);
      }
      await batch.commit();
    }
    while (true) {
      final submissions = await postRef
          .collection('submissions')
          .limit(400)
          .get();
      if (submissions.docs.isEmpty) break;
      final batch = FirebaseFirestore.instance.batch();
      for (final submission in submissions.docs) {
        batch.delete(submission.reference);
      }
      await batch.commit();
    }
    await postRef.delete();
    if (context.mounted) showMessage(context, 'Жарияланым өшірілді');
    return true;
  } catch (error) {
    if (context.mounted) {
      showMessage(context, 'Өшіру мүмкін болмады: $error', error: true);
    }
    return false;
  }
}

Future<void> _editComment(
  BuildContext context,
  DocumentReference<Map<String, dynamic>> ref,
  String oldText,
) async {
  final controller = TextEditingController(text: oldText);
  final value = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Пікірді өзгерту'),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: 4,
        decoration: const InputDecoration(labelText: 'Пікір'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Болдырмау'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
          child: const Text('Сақтау'),
        ),
      ],
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 300));
  controller.dispose();
  if (value == null || value.isEmpty || value == oldText) return;
  try {
    await ref.update({'body': value, 'editedAt': FieldValue.serverTimestamp()});
  } catch (error) {
    if (context.mounted) {
      showMessage(context, 'Пікір өзгермеді: $error', error: true);
    }
  }
}

Future<void> _deleteComment(
  BuildContext context,
  DocumentReference<Map<String, dynamic>> ref,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Пікірді өшіру керек пе?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Болдырмау'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Өшіру'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await ref.delete();
  } catch (error) {
    if (context.mounted) {
      showMessage(context, 'Пікір өшірілмеді: $error', error: true);
    }
  }
}

Widget _classMessage(String text) => Center(
  child: Padding(
    padding: const EdgeInsets.all(25),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: muted),
    ),
  ),
);

class _EditDeleteButtons extends StatelessWidget {
  const _EditDeleteButtons({this.onEdit, required this.onDelete});
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .74),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFDDE4F5)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            IconButton(
              tooltip: 'Өзгерту',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded),
              iconSize: 16,
              color: primary,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            ),
          if (onEdit != null)
            const SizedBox(height: 17, child: VerticalDivider(width: 1)),
          IconButton(
            tooltip: 'Өшіру',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            iconSize: 16,
            color: coral,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
          ),
        ],
      ),
    ),
  );
}

int _createdMillis(Map<String, dynamic> data) =>
    (data['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;

String _date(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
