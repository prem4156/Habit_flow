import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/status_screen.dart';
import 'services/system_state.dart';
import 'services/auth_service.dart';
import 'theme/system_theme.dart';
import 'widgets/emergency_quest_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.initialize();
  runApp(const SoloLevelingHabitApp());
}

class SoloLevelingHabitApp extends StatelessWidget {
  const SoloLevelingHabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Flow • The System',
      debugShowCheckedModeBanner: false,
      theme: SystemTheme.darkTheme,
      home: const MainSystemScreen(),
    );
  }
}

class MainSystemScreen extends StatefulWidget {
  const MainSystemScreen({super.key});

  @override
  State<MainSystemScreen> createState() => _MainSystemScreenState();
}

class _MainSystemScreenState extends State<MainSystemScreen> {
  final SystemState _systemState = SystemState();
  int _currentIndex = 1; // Default to Quest Log, the core habit screen

  @override
  void initState() {
    super.initState();
    _systemState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _systemState.removeListener(_onStateChange);
    _systemState.dispose();
    super.dispose();
  }

  void _onStateChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_systemState.isInitialized) {
      return Scaffold(
        backgroundColor: SystemColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: SystemColors.cyanGlow, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: SystemColors.cyanGlow.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(SystemColors.cyanGlow),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'SYNCHRONIZING WITH THE SYSTEM...',
                style: GoogleFonts.orbitron(
                  color: SystemColors.cyanGlow,
                  fontSize: 14,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If not logged in, render the AuthScreen
    if (!_systemState.isAuthenticated) {
      return AuthScreen(state: _systemState);
    }

    final screens = [
      StatusScreen(state: _systemState),
      QuestScreen(state: _systemState),
      ProgressScreen(state: _systemState),
    ];

    return Scaffold(
      backgroundColor: SystemColors.background,
      appBar: _buildSystemAppBar(),
      body: Stack(
        children: [
          // Background ambient grid texture
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: _GridBackgroundPainter(),
              ),
            ),
          ),

          // Main Screen Body
          screens[_currentIndex],

          // Floating Non-Blocking System Message Toast / Banner
          if (_systemState.lastSystemMessage != null)
            Positioned(
              top: 10,
              left: 14,
              right: 14,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, val, child) {
                  return Transform.translate(
                    offset: Offset(0, (1.0 - val) * -20),
                    child: Opacity(
                      opacity: val,
                      child: child,
                    ),
                  );
                },
                child: InkWell(
                  onTap: () => _systemState.clearSystemMessage(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: SystemColors.shadowBlack.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _systemState.lastSystemMessage!.contains('EXECUTED')
                            ? SystemColors.crimsonGlow
                            : _systemState.lastSystemMessage!.contains('LEVEL UP') || _systemState.lastSystemMessage!.contains('ACHIEVEMENT')
                                ? SystemColors.monarchViolet
                                : SystemColors.cyanGlow,
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _systemState.lastSystemMessage!.contains('EXECUTED')
                              ? SystemColors.crimsonGlow.withValues(alpha: 0.35)
                              : SystemColors.cyanGlow.withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _systemState.lastSystemMessage!.contains('EXECUTED')
                              ? Icons.flash_on
                              : _systemState.lastSystemMessage!.contains('LEVEL UP')
                                  ? Icons.military_tech
                                  : Icons.notifications_active,
                          color: _systemState.lastSystemMessage!.contains('EXECUTED')
                              ? SystemColors.crimsonGlow
                              : _systemState.lastSystemMessage!.contains('LEVEL UP')
                                  ? SystemColors.monarchViolet
                                  : SystemColors.cyanGlow,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _systemState.lastSystemMessage!,
                            style: GoogleFonts.rajdhani(
                              color: SystemColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.close, color: Colors.white38, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Emergency Quest Modal Overlay (if autonomous trigger explicitly activated)
          if (_systemState.showEmergencyQuestModal && _systemState.activeEmergencyQuest != null)
            Positioned.fill(
              child: EmergencyQuestDialog(
                emergencyQuest: _systemState.activeEmergencyQuest!,
                onDismiss: () => _systemState.dismissEmergencyQuestModal(),
                onAccept: () => _systemState.dismissEmergencyQuestModal(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildSystemBottomNav(),
    );
  }

  PreferredSizeWidget _buildSystemAppBar() {
    final profile = _systemState.profile;

    return AppBar(
      backgroundColor: SystemColors.panelBg,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: SystemColors.cyanGlow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: SystemColors.cyanGlow, width: 1),
            ),
            child: Text(
              'THE SYSTEM',
              style: GoogleFonts.orbitron(
                color: SystemColors.cyanGlow,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'HABIT FLOW',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        // Level & Rank badge
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: SystemColors.cyanGlow.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LV.${profile.level}',
                  style: GoogleFonts.orbitron(
                    color: SystemColors.cyanGlow,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '[${profile.rank.label.split('-')[0]}]',
                  style: GoogleFonts.orbitron(
                    color: SystemColors.goldAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Hunter Account Dropdown Menu
        if (_systemState.currentUser != null)
          PopupMenuButton<String>(
            color: SystemColors.panelBg,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: SystemColors.cyanGlow, width: 1.2),
              borderRadius: BorderRadius.circular(8),
            ),
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _systemState.currentUser!.isGoogle
                      ? Colors.blueAccent
                      : _systemState.currentUser!.isGuest
                          ? SystemColors.hpGreen
                          : SystemColors.monarchViolet,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  _systemState.currentUser!.displayName.isNotEmpty
                      ? _systemState.currentUser!.displayName[0].toUpperCase()
                      : 'H',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            onSelected: (value) {
              if (value == 'sign_out') {
                _systemState.signOut();
              } else if (value.startsWith('switch_')) {
                final uid = value.replaceFirst('switch_', '');
                _systemState.switchAccount(uid);
              }
            },
            itemBuilder: (ctx) {
              final user = _systemState.currentUser!;
              return [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(user.provider.icon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              user.displayName,
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.rajdhani(
                          color: SystemColors.textSecondary,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Provider: ${user.provider.label}',
                        style: GoogleFonts.rajdhani(
                          color: SystemColors.cyanGlow,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(color: Colors.white24),
                    ],
                  ),
                ),
                if (_systemState.accounts.length > 1) ...[
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      'SWITCH IDENTITIES:',
                      style: GoogleFonts.orbitron(color: SystemColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ..._systemState.accounts.where((a) => a.id != user.id).map(
                        (acc) => PopupMenuItem<String>(
                          value: 'switch_${acc.id}',
                          child: Row(
                            children: [
                              Text(acc.provider.icon, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  acc.displayName,
                                  style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  const PopupMenuItem<String>(
                    enabled: false,
                    height: 8,
                    child: Divider(color: Colors.white12),
                  ),
                ],
                PopupMenuItem<String>(
                  value: 'sign_out',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: SystemColors.crimsonGlow, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'DISCONNECT / SIGN OUT',
                        style: GoogleFonts.orbitron(
                          color: SystemColors.crimsonGlow,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        const SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.5),
        child: Container(
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SystemColors.cyanGlow.withValues(alpha: 0.8),
                SystemColors.blueGlow.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: SystemColors.panelBg,
        border: Border(
          top: BorderSide(color: SystemColors.cyanGlow.withValues(alpha: 0.4), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: SystemColors.cyanGlow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: SystemColors.cyanGlow,
        unselectedItemColor: SystemColors.textSecondary,
        selectedLabelStyle: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.orbitron(fontSize: 9),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person, color: SystemColors.cyanGlow),
            label: 'STATUS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            activeIcon: Icon(Icons.assignment, color: SystemColors.cyanGlow),
            label: 'QUESTS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            activeIcon: Icon(Icons.trending_up, color: SystemColors.cyanGlow),
            label: 'PROGRESS',
          ),
        ],
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SystemColors.cyanGlow
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
