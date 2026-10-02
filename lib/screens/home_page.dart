part of 'main_shell.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenTopics});

  final VoidCallback onOpenTopics;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile =
        state.profile ??
        const UserProfile(name: 'Оқушы', email: '', role: UserRole.student);
    final firstName = profile.name.trim().split(' ').first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 222,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF142747),
                  Color(0xFF304C91),
                  Color(0xFF536BDE),
                ],
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Positioned(
                    right: -38,
                    top: -28,
                    child: SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(painter: _OrbitPainter()),
                    ),
                  ),
                  Positioned(
                    right: 29,
                    top: 78,
                    child: Container(
                      width: 63,
                      height: 63,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB7C3FF), Color(0xFF728CF6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFACC1FF,
                            ).withValues(alpha: .42),
                            blurRadius: 38,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 31,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(23),
                    child: SizedBox(
                      width: constraints.maxWidth * .73,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .13),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'БҮГІНГІ МИССИЯ',
                              style: TextStyle(
                                color: Color(0xFFD9E3FF),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Сәлем, $firstName!',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              letterSpacing: -.6,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Әр жаңалық бір сұрақтан басталады.',
                            maxLines: 2,
                            style: TextStyle(
                              color: Color(0xFFD6E1FF),
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: onOpenTopics,
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 17,
                            ),
                            label: const Text('Зерттеуді бастау'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: navy,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              minimumSize: const Size(0, 42),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            _StatCard(
              '${physicsTopics.length}',
              'Тақырып',
              Icons.menu_book_rounded,
              coral,
            ),
            const SizedBox(width: 10),
            _StatCard('${state.points}', 'Ұпай', Icons.bolt_rounded, sunny),
            const SizedBox(width: 10),
            _StatCard(
              '${state.classes.length}',
              'Класс',
              Icons.groups_rounded,
              mint,
            ),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Менің кластарым',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: navy,
                  fontSize: 20,
                  letterSpacing: -.4,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (profile.role == UserRole.teacher)
              TextButton.icon(
                key: const Key('create-another-class'),
                onPressed: () => _showCreateClass(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Класс құру'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.classSyncError != null) ...[
          SoftCard(
            color: const Color(0xFFFFEEEE),
            child: Text(
              state.classSyncError!,
              style: const TextStyle(color: coral),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (state.classes.isEmpty)
          SoftCard(
            color: const Color(0xFFE9EDFF),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.groups_2_rounded,
                    size: 30,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  profile.role == UserRole.teacher
                      ? 'Алғашқы класыңызды құрыңыз'
                      : 'Мұғалім берген кодпен классқа қосылыңыз',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  key: const Key('class-action-button'),
                  onPressed: () => profile.role == UserRole.teacher
                      ? _showCreateClass(context)
                      : _showJoinClass(context),
                  icon: Icon(
                    profile.role == UserRole.teacher
                        ? Icons.add_rounded
                        : Icons.login_rounded,
                  ),
                  label: Text(
                    profile.role == UserRole.teacher
                        ? 'Класс құру'
                        : 'Кодпен қосылу',
                  ),
                ),
              ],
            ),
          )
        else
          ...state.classes.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SoftCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ClassroomScreen(physicsClass: item),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.groups_rounded, color: primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${item.grade}-сынып • ${item.memberCount} қатысушы • ${item.code}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF777E92),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (profile.role == UserRole.teacher)
                      IconButton(
                        tooltip: 'Кодты көшіру',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item.code));
                          showMessage(context, 'Класс коды көшірілді');
                        },
                        icon: const Icon(Icons.copy_rounded, size: 19),
                      ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 25),
        const _SectionTitle(title: 'Оқу прогресі', action: ''),
        const SizedBox(height: 12),
        SoftCard(
          onTap: onOpenTopics,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_stories_rounded, color: primary),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      '${state.masteredTopicCount} / ${physicsTopics.length} тақырып меңгерілді',
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: primary,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: state.masteredTopicCount / physicsTopics.length,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: const Color(0xFFE9EDFF),
                color: primary,
              ),
              const SizedBox(height: 10),
              const Text(
                'Тақырыпты оқып, 5 сұрақтық тексеруден өт.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateClass(BuildContext homeContext) {
    final name = TextEditingController();
    int grade = 7;
    showModalBottomSheet<void>(
      context: homeContext,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Жаңа класс',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Класс атауы'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: grade,
                decoration: const InputDecoration(labelText: 'Сынып'),
                items: List.generate(5, (i) => i + 7)
                    .map(
                      (v) =>
                          DropdownMenuItem(value: v, child: Text('$v-сынып')),
                    )
                    .toList(),
                onChanged: (value) => setSheetState(() => grade = value ?? 7),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Класс құру',
                onPressed: () async {
                  if (name.text.trim().isEmpty) return;
                  try {
                    final item = await AppStateScope.of(
                      homeContext,
                    ).createClass(name.text.trim(), grade);
                    if (!homeContext.mounted) return;
                    Navigator.pop(sheetContext);
                    Navigator.of(homeContext).push(
                      MaterialPageRoute(
                        builder: (_) => ClassroomScreen(physicsClass: item),
                      ),
                    );
                  } catch (error) {
                    if (homeContext.mounted) {
                      showMessage(
                        homeContext,
                        'Класс құрылмады: $error',
                        error: true,
                      );
                    }
                  }
                },
                icon: Icons.add_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinClass(BuildContext homeContext) {
    final code = TextEditingController();
    showModalBottomSheet<void>(
      context: homeContext,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Классқа қосылу',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('Мұғалім жіберген PHY-XXXXXX форматындағы кодты енгіз.'),
            const SizedBox(height: 18),
            TextField(
              controller: code,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Класс коды',
                prefixIcon: Icon(Icons.key_rounded),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Қосылу',
              onPressed: () async {
                try {
                  final ok = await AppStateScope.of(
                    homeContext,
                  ).joinClass(code.text);
                  if (!homeContext.mounted) return;
                  if (ok) {
                    Navigator.pop(sheetContext);
                    final item = AppStateScope.of(homeContext).classes
                        .firstWhere(
                          (item) => item.code == code.text.trim().toUpperCase(),
                        );
                    Navigator.of(homeContext).push(
                      MaterialPageRoute(
                        builder: (_) => ClassroomScreen(physicsClass: item),
                      ),
                    );
                  } else {
                    showMessage(
                      homeContext,
                      'Код қате немесе класс табылмады',
                      error: true,
                    );
                  }
                } catch (error) {
                  if (homeContext.mounted) {
                    showMessage(
                      homeContext,
                      'Классқа қосылу мүмкін болмады: $error',
                      error: true,
                    );
                  }
                }
              },
              icon: Icons.login_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .5);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, size.width * .31, line);
    canvas.drawCircle(center, size.width * .45, line);
    canvas.drawCircle(center, size.width * .59, line);
    final dot = Paint()..color = const Color(0xFFFFD18B);
    canvas.drawCircle(Offset(size.width * .77, size.height * .32), 4, dot);
    canvas.drawCircle(
      Offset(size.width * .19, size.height * .82),
      2.5,
      Paint()..color = Colors.white.withValues(alpha: .6),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.value, this.label, this.icon, this.color);
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C273968),
              blurRadius: 20,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(height: 9),
            Text(
              value,
              style: const TextStyle(
                color: navy,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF7B8295)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action});
  final String title;
  final String action;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(
          color: navy,
          fontSize: 20,
          letterSpacing: -.4,
          fontWeight: FontWeight.w900,
        ),
      ),
      const Spacer(),
      Text(action, style: const TextStyle(color: primary, fontSize: 13)),
    ],
  );
}
