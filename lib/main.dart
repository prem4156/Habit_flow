import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/status_screen.dart';
import 'services/system_state.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'theme/system_theme.dart';
import 'widgets/emergency_quest_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.initialize();
  await NotificationService.instance.initialize();
  runApp(const SoloLevelingHabitApp());
}

class SoloLevelingHabitApp extends StatefulWidget {
  final SystemState? state;
  const SoloLevelingHabitApp({super.key, this.state});

  @override
  State<SoloLevelingHabitApp> createState() => _SoloLevelingHabitAppState();
}

class _SoloLevelingHabitAppState extends State<SoloLevelingHabitApp> {
  late final SystemState _systemState;
  bool _ownsState = false;

  @override
  void initState() {
    super.initState();
    if (widget.state != null) {
      _systemState = widget.state!;
    } else {
      _systemState = SystemState();
      _ownsState = true;
    }
  }

  @override
  void dispose() {
    if (_ownsState) {
      _systemState.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _systemState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Habit Flow • The System',
          debugShowCheckedModeBanner: false,
          theme: SystemTheme.lightTheme,
          darkTheme: SystemTheme.darkTheme,
          themeMode: _systemState.themeMode,
          home: MainSystemScreen(systemState: _systemState),
        );
      },
    );
  }
}

class MainSystemScreen extends StatefulWidget {
  final SystemState? systemState;
  const MainSystemScreen({super.key, this.systemState});

  @override
  State<MainSystemScreen> createState() => _MainSystemScreenState();
}

class _MainSystemScreenState extends State<MainSystemScreen> {
  late final SystemState _systemState;
  bool _ownsState = false;
  int _currentIndex = 1; // Default to Quest Log, the core habit screen

  @override
  void initState() {
    super.initState();
    if (widget.systemState != null) {
      _systemState = widget.systemState!;
    } else {
      _systemState = SystemState();
      _ownsState = true;
    }
    _systemState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _systemState.removeListener(_onStateChange);
    if (_ownsState) {
      _systemState.dispose();
    }
    super.dispose();
  }

  void _onStateChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_systemState.isInitialized) {
      return Scaffold(
        backgroundColor: SystemTheme.getBackground(context),
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
                  color: SystemTheme.getPrimaryAccent(context),
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
      backgroundColor: SystemTheme.getBackground(context),
      appBar: _buildSystemAppBar(),
      body: Stack(
        children: [
          // Background ambient grid texture
          Positioned.fill(
            child: Opacity(
              opacity: SystemTheme.isDark(context) ? 0.05 : 0.03,
              child: CustomPaint(
                painter: _GridBackgroundPainter(isDark: SystemTheme.isDark(context)),
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
                      color: SystemTheme.isDark(context) ? SystemColors.shadowBlack.withValues(alpha: 0.96) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _systemState.lastSystemMessage!.contains('EXECUTED')
                            ? (SystemTheme.isDark(context) ? SystemColors.crimsonGlow : SystemColors.lightCrimson)
                            : _systemState.lastSystemMessage!.contains('LEVEL UP') || _systemState.lastSystemMessage!.contains('ACHIEVEMENT')
                                ? (SystemTheme.isDark(context) ? SystemColors.monarchViolet : SystemColors.lightMonarchViolet)
                                : (SystemTheme.isDark(context) ? SystemColors.cyanGlow : SystemColors.lightCyanGlow),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _systemState.lastSystemMessage!.contains('EXECUTED')
                              ? (SystemTheme.isDark(context) ? SystemColors.crimsonGlow : SystemColors.lightCrimson).withValues(alpha: SystemTheme.isDark(context) ? 0.35 : 0.2)
                              : (SystemTheme.isDark(context) ? SystemColors.cyanGlow : SystemColors.lightCyanGlow).withValues(alpha: SystemTheme.isDark(context) ? 0.35 : 0.2),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                        if (!SystemTheme.isDark(context))
                          BoxShadow(
                            color: const Color(0x120F172A),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
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
                              ? (SystemTheme.isDark(context) ? SystemColors.crimsonGlow : SystemColors.lightCrimson)
                              : _systemState.lastSystemMessage!.contains('LEVEL UP')
                                  ? (SystemTheme.isDark(context) ? SystemColors.monarchViolet : SystemColors.lightMonarchViolet)
                                  : (SystemTheme.isDark(context) ? SystemColors.cyanGlow : SystemColors.lightCyanGlow),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _systemState.lastSystemMessage!,
                            style: GoogleFonts.rajdhani(
                              color: SystemTheme.getTextPrimary(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.close,
                          color: SystemTheme.isDark(context) ? Colors.white38 : SystemTheme.getTextMuted(context),
                          size: 16,
                        ),
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

    final isDark = SystemTheme.isDark(context);
    return AppBar(
      backgroundColor: SystemTheme.getPanelBg(context),
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? SystemColors.cyanGlow.withValues(alpha: 0.2)
                  : SystemColors.lightCyanGlow.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isDark ? SystemColors.cyanGlow : SystemColors.lightCyanGlow,
                width: 1,
              ),
            ),
            child: Text(
              'THE SYSTEM',
              style: GoogleFonts.orbitron(
                color: isDark ? SystemColors.cyanGlow : SystemColors.lightCyanGlow,
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
              color: SystemTheme.getTextPrimary(context),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        // Theme Switcher Toggle Button (Dark / Light / Solar Adaptive)
        IconButton(
          icon: Icon(
            _systemState.isAdaptiveThemeEnabled
                ? Icons.brightness_auto
                : (_systemState.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            color: _systemState.isAdaptiveThemeEnabled
                ? (_systemState.isDaytimeNow ? SystemColors.goldAccent : (isDark ? SystemColors.monarchPurple : SystemColors.lightMonarchPurple))
                : (_systemState.isDarkMode ? SystemColors.goldAccent : SystemColors.lightCyanGlow),
            size: 20,
          ),
          tooltip: _systemState.isAdaptiveThemeEnabled
              ? 'Solar Adaptive Theme (${_systemState.isDaytimeNow ? "Day/Light" : "Night/Dark"}) - Tap to cycle'
              : (_systemState.isDarkMode
                  ? 'Switch to Radiant System (Light Theme)'
                  : 'Switch to Solar Adaptive (Auto Theme)'),
          onPressed: () => _systemState.cycleThemeMode(),
        ),

        // Level & Rank badge
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.black45 : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isDark
                    ? SystemColors.cyanGlow.withValues(alpha: 0.4)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LV.${profile.level}',
                  style: GoogleFonts.orbitron(
                    color: isDark ? SystemColors.cyanGlow : SystemColors.lightCyanGlow,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '[${profile.rank.label.split('-')[0]}]',
                  style: GoogleFonts.orbitron(
                    color: SystemTheme.getGoldAccent(context),
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
            color: SystemTheme.getPanelBg(context),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isDark ? SystemColors.cyanGlow : SystemColors.lightCyanGlow,
                width: 1.2,
              ),
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
                          ? SystemTheme.getGreenAccent(context)
                          : SystemTheme.getPurpleAccent(context),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  _systemState.currentUser!.displayName.isNotEmpty
                      ? _systemState.currentUser!.displayName[0].toUpperCase()
                      : 'H',
                  style: GoogleFonts.orbitron(
                    color: SystemTheme.getTextPrimary(context),
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
                                color: SystemTheme.getTextPrimary(context),
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
                          color: SystemTheme.getTextSecondary(context),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Provider: ${user.provider.label}',
                        style: GoogleFonts.rajdhani(
                          color: isDark ? SystemColors.cyanGlow : SystemColors.lightCyanGlow,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(color: SystemTheme.getPanelBorder(context)),
                    ],
                  ),
                ),
                if (_systemState.accounts.length > 1) ...[
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      'SWITCH IDENTITIES:',
                      style: GoogleFonts.orbitron(
                        color: SystemTheme.getTextMuted(context),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
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
                                  style: GoogleFonts.rajdhani(
                                    color: SystemTheme.getTextPrimary(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  PopupMenuItem<String>(
                    enabled: false,
                    height: 8,
                    child: Divider(color: SystemTheme.getPanelBorder(context)),
                  ),
                ],
                PopupMenuItem<String>(
                  value: 'sign_out',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: SystemTheme.getCrimsonAccent(context), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'DISCONNECT / SIGN OUT',
                        style: GoogleFonts.orbitron(
                          color: SystemTheme.getCrimsonAccent(context),
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
                (isDark ? SystemColors.cyanGlow : SystemColors.lightCyanGlow).withValues(alpha: 0.8),
                (isDark ? SystemColors.blueGlow : const Color(0xFF0284C7)).withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemBottomNav() {
    final isDark = SystemTheme.isDark(context);
    final accent = isDark ? SystemColors.cyanGlow : SystemColors.lightCyanGlow;

    return Container(
      decoration: BoxDecoration(
        color: SystemTheme.getPanelBg(context),
        border: Border(
          top: BorderSide(
            color: isDark
                ? SystemColors.cyanGlow.withValues(alpha: 0.4)
                : SystemColors.lightPanelBorder,
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? SystemColors.cyanGlow.withValues(alpha: 0.1)
                : const Color(0x0C0F172A),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: accent,
        unselectedItemColor: SystemTheme.getTextMuted(context),
        selectedLabelStyle: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.orbitron(fontSize: 9),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person, color: accent, size: 22),
            ),
            label: 'STATUS',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_outlined),
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.assignment, color: accent, size: 22),
            ),
            label: 'TASKS',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up),
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.trending_up, color: accent, size: 22),
            ),
            label: 'PROGRESS',
          ),
        ],
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  final bool isDark;
  _GridBackgroundPainter({this.isDark = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? SystemColors.cyanGlow : SystemColors.lightCyanGlow
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
  bool shouldRepaint(covariant _GridBackgroundPainter oldDelegate) => oldDelegate.isDark != isDark;
}
