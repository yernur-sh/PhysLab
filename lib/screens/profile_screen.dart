part of 'main_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final profile =
        state.profile ??
        const UserProfile(name: 'Қолданушы', email: '', role: UserRole.student);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF182B50), Color(0xFF5068D5)],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white54, width: 1.5),
                ),
                child: UserAvatar(profile: profile, radius: 44),
              ),
              const SizedBox(height: 14),
              Text(
                profile.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email,
                style: const TextStyle(color: Color(0xFFDCE5FF)),
              ),
              const SizedBox(height: 11),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  profile.role == UserRole.teacher ? 'МҰҒАЛІМ' : 'ОҚУШЫ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _ProfileMetric(
              Icons.bolt_rounded,
              '${state.points}',
              'Ұпай',
              sunny,
            ),
            const SizedBox(width: 9),
            _ProfileMetric(
              Icons.school_rounded,
              '${state.masteredTopicCount}',
              'Тақырып',
              mint,
            ),
            const SizedBox(width: 9),
            _ProfileMetric(
              Icons.emoji_events_rounded,
              '${state.fullyCompletedQuizzes}',
              '100% тест',
              coral,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Практика нәтижесі',
          style: TextStyle(
            color: navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 11),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${state.fullyCompletedQuizzes} / ${quizSets.length} тест толық орындалды',
                style: const TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 11),
              LinearProgressIndicator(
                value: state.fullyCompletedQuizzes / quizSets.length,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: const Color(0xFFE9EDFF),
                color: primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Кластарым: ${state.classes.length} · Тест ұпайлары: ${state.points}',
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SoftCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MasteredTopicsScreen()),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 23,
                backgroundColor: Color(0xFFE6F7F2),
                foregroundColor: Color(0xFF279B7B),
                child: Icon(Icons.school_rounded),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Меңгерілген тақырыптар',
                      style: TextStyle(
                        color: navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${state.masteredTopicCount} тақырып меңгерілді',
                      style: const TextStyle(color: muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: primary,
                size: 18,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
          ),
          icon: const Icon(Icons.lock_reset_rounded),
          label: const Text('Құпиясөзді өзгерту'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signOut();
            } catch (_) {}
            if (!context.mounted) return;
            state.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const AuthScreen(initialLogin: true),
              ),
              (_) => false,
            );
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Аккаунттан шығу'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFE45757),
            minimumSize: const Size.fromHeight(54),
          ),
        ),
      ],
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric(this.icon, this.value, this.title, this.color);
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
    child: SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 15),
      child: Column(
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: muted, fontSize: 10),
          ),
        ],
      ),
    ),
  );
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.profile, required this.radius});
  final UserProfile? profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photo = profile?.isGoogleUser == true ? profile?.photoUrl : null;
    if (photo != null && photo.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photo,
          key: const Key('google-profile-photo'),
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _defaultAvatar(),
        ),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() => Container(
    key: const Key('default-profile-avatar'),
    width: radius * 2,
    height: radius * 2,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE6E9FF), Color(0xFFD6F5EC)],
      ),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.person_rounded, size: radius * 1.22, color: navy),
        Positioned(
          top: radius * .29,
          right: radius * .26,
          child: Icon(
            Icons.auto_awesome_rounded,
            size: radius * .36,
            color: primary,
          ),
        ),
      ],
    ),
  );
}
