import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/inventory_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/status_screen.dart';
import 'services/system_state.dart';
import 'theme/system_theme.dart';
import 'widgets/level_up_dialog.dart';
import 'widgets/penalty_dialog.dart';
import 'widgets/emergency_quest_dialog.dart';
import 'widgets/achievement_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SoloLevelingHabitApp());
}

class SoloLevelingHabitApp extends StatelessWidget {
  const SoloLevelingHabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monarch Protocol • The System',
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

    final screens = [
      StatusScreen(state: _systemState),
      QuestScreen(state: _systemState),
      InventoryScreen(state: _systemState),
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

          // Floating System Message Toast / Banner
          if (_systemState.lastSystemMessage != null)
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: InkWell(
                onTap: () => _systemState.clearSystemMessage(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: SystemColors.panelBg.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: SystemColors.cyanGlow, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: SystemColors.cyanGlow.withValues(alpha: 0.4),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active, color: SystemColors.cyanGlow, size: 20),
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
                      const Icon(Icons.close, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
            ),

          // Level Up Modal Overlay
          if (_systemState.showLevelUpModal)
            Positioned.fill(
              child: LevelUpDialog(
                newLevel: _systemState.latestLevelAchieved,
                onDismiss: () => _systemState.closeLevelUpModal(),
              ),
            ),

          // Penalty Survival Modal Overlay
          if (_systemState.isPenaltyActive)
            Positioned.fill(
              child: PenaltyDialog(
                timeRemainingSeconds: _systemState.penaltyTimeRemainingSeconds,
                onSurvive: () => _systemState.completePenaltyZone(),
                onEscape: () => _systemState.escapePenaltyZone(),
              ),
            ),

          // Emergency Quest Modal Overlay
          if (_systemState.showEmergencyQuestModal && _systemState.activeEmergencyQuest != null)
            Positioned.fill(
              child: EmergencyQuestDialog(
                emergencyQuest: _systemState.activeEmergencyQuest!,
                onDismiss: () => _systemState.dismissEmergencyQuestModal(),
                onAccept: () => _systemState.dismissEmergencyQuestModal(),
              ),
            ),

          // Achievement Unlocked Modal Overlay
          if (_systemState.showAchievementModal && _systemState.latestUnlockedAchievement != null)
            Positioned.fill(
              child: AchievementDialog(
                achievement: _systemState.latestUnlockedAchievement!,
                onDismiss: () => _systemState.dismissAchievementModal(),
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
            'MONARCH PROTOCOL',
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
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '[${profile.rank.label.split('-')[0]}]',
                  style: GoogleFonts.orbitron(
                    color: SystemColors.goldAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
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
            icon: Icon(Icons.inventory_2),
            activeIcon: Icon(Icons.inventory_2, color: SystemColors.cyanGlow),
            label: 'VAULT',
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
