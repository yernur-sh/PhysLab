import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/common.dart';

class HomeworkSubmissionsScreen extends StatefulWidget {
  const HomeworkSubmissionsScreen({
    super.key,
    required this.postRef,
    required this.profile,
    required this.isTeacher,
  });

  final DocumentReference<Map<String, dynamic>> postRef;
  final UserProfile profile;
  final bool isTeacher;

  @override
  State<HomeworkSubmissionsScreen> createState() =>
      _HomeworkSubmissionsScreenState();
}

class _HomeworkSubmissionsScreenState extends State<HomeworkSubmissionsScreen> {
  final solution = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    solution.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final body = solution.text.trim();
    if (body.isEmpty || busy) return;
    setState(() => busy = true);
    try {
      await widget.postRef
          .collection('submissions')
          .doc(widget.profile.uid)
          .set({
            'studentUid': widget.profile.uid,
            'studentName': widget.profile.name,
            'body': body,
            'status': 'submitted',
            'submittedAt': FieldValue.serverTimestamp(),
          });
      if (mounted) showMessage(context, 'Шешім мұғалімге жіберілді');
    } catch (error) {
      if (mounted) {
        showMessage(context, 'Шешім жіберілмеді: $error', error: true);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _accept(DocumentReference<Map<String, dynamic>> ref) async {
    setState(() => busy = true);
    try {
      await ref.update({
        'status': 'accepted',
        'reviewedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      if (mounted) {
        showMessage(context, 'Қабылдау мүмкін болмады: $error', error: true);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissions = widget.postRef.collection('submissions');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isTeacher ? 'Үй жұмысының жауаптары' : 'Менің шешімім',
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: widget.isTeacher
            ? submissions.snapshots()
            : submissions
                  .where('studentUid', isEqualTo: widget.profile.uid)
                  .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Жауаптарды жүктеу мүмкін болмады'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (!widget.isTeacher) ...[
                const Text(
                  'Есептің шығару жолын жазыңыз',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: solution,
                  maxLines: 8,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Шешіміңіз, формула және жауабыңыз...',
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: docs.isEmpty
                      ? 'Шешімді жіберу'
                      : 'Шешімді қайта жіберу',
                  loading: busy,
                  onPressed: solution.text.trim().isEmpty ? null : _submit,
                ),
                const SizedBox(height: 20),
              ],
              if (docs.isEmpty)
                const SoftCard(
                  child: Text(
                    'Әзірге жауап жоқ',
                    style: TextStyle(color: muted),
                  ),
                ),
              for (final doc in docs) ...[
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.data()['studentName'] as String? ?? 'Оқушы',
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(doc.data()['body'] as String? ?? ''),
                      const SizedBox(height: 12),
                      Text(
                        doc.data()['status'] == 'accepted'
                            ? 'Қабылданды'
                            : 'Тексерілуде',
                        style: TextStyle(
                          color: doc.data()['status'] == 'accepted'
                              ? mint
                              : primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (widget.isTeacher &&
                          doc.data()['status'] != 'accepted') ...[
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: busy ? null : () => _accept(doc.reference),
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: const Text('Қабылдау'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}
