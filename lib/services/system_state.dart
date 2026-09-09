import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user_model.dart';
import '../models/hunter_model.dart';
import '../models/quest_model.dart';
import '../models/achievement_model.dart';

class SystemState extends ChangeNotifier {
  static const String _prefCurrentAuthUserKey = 'sl_auth_current_user_id';
  static const String _prefAccountsKey = 'sl_auth_accounts_list';
  static const String _prefPasswordsKey = 'sl_auth_passwords_map';

  static const String _prefProfileKey = 'sl_hunter_profile';
  static const String _prefQuestsKey = 'sl_hunter_quests';
  static const String _prefDailyProgressKey = 'sl_daily_progress';
  static const String _prefDailyCompletedKey = 'sl_daily_completed';
  static const String _prefStatGainsKey = 'sl_stat_gains';
  static const String _prefAchievementsKey = 'sl_achievements';
  static const String _prefEmergencyQuestKey = 'sl_emergency_quest';
  static const String _prefConsecutiveDaysKey = 'sl_consecutive_days';
  static const String _prefTotalClearsKey = 'sl_total_clears';
  static const String _prefLastPerfectDayKey = 'sl_last_perfect_day';
  static const String _prefBestStreakKey = 'sl_best_streak';

  // --- Real-time Auth State ---
  AuthUser? _currentUser;
  List<AuthUser> _accounts = [];
  Map<String, String> _passwords = {};

  HunterProfile _profile = HunterProfile.defaultProfile();
  List<Quest> _quests = Quest.defaultSoloQuests();
  List<Achievement> _achievements = Achievement.defaultAchievements();

  DateTime _selectedDate = DateTime.now();

  // Daily records:
  // key: dateKey (YYYY-MM-DD) -> { questId: progress }
  Map<String, Map<String, int>> _dailyProgress = {};
  // key: dateKey (YYYY-MM-DD) -> [ questIds completed ]
  Map<String, List<String>> _dailyCompleted = {};
  // Map of stat code (STR, AGI, etc.) -> total gains earned directly through quest completions
  Map<String, int> _statGainsFromQuests = {
    'STR': 0,
    'AGI': 0,
    'VIT': 0,
    'INT': 0,
    'PER': 0,
  };

  bool _isInitialized = false;
  String? _lastSystemMessage;
  bool _showLevelUpModal = false;
  int _latestLevelAchieved = 1;

  // --- Autonomous System State ---
  Quest? _activeEmergencyQuest;
  bool _showEmergencyQuestModal = false;
  Achievement? _latestUnlockedAchievement;
  bool _showAchievementModal = false;
  int _consecutivePerfectDays = 0;
  int _totalQuestClears = 0;
  String? _lastPerfectDay;
  int _bestStreak = 0;
  Timer? _autonomousTimer;
  Timer? _initialDelayTimer;

  // Cryptic system monologues the system can emit
  static const List<String> _crypticObservations = [
    '[SYSTEM] ... Observing.',
    '[SYSTEM] The System is always watching.',
    '[SYSTEM] Your discipline has been noted.',
    '[SYSTEM] Designation: Hunter. Status: Under Evaluation.',
    '[SYSTEM] "Weakness is a choice." — The System',
    '[SYSTEM] Shadow extraction protocols... dormant.',
    '[SYSTEM] Anomalous willpower detected. Monitoring...',
    '[SYSTEM] The gates between worlds grow thinner.',
    '[SYSTEM] Every rep brings you closer to the Monarch\'s throne.',
    '[SYSTEM] Current threat level: Manageable. For now.',
  ];

  static const List<String> _warningMessages = [
    '[WARNING] Insufficient daily progress detected. System intervention imminent.',
    '[WARNING] The System does not tolerate complacency.',
    '[WARNING] The Shadows demand strict daily discipline.',
    '[WARNING] Hunter performance below acceptable threshold.',
    '[WARNING] "Those who do not train... do not survive." — System Alert',
  ];

  // Emergency quest templates
  static const List<Map<String, dynamic>> _emergencyQuestTemplates = [
    {
      'title': 'Emergency Sprint Protocol',
      'description': 'The System has detected insufficient discipline. Complete 50 push-ups immediately.',
      'target': 50,
      'unit': 'reps',
      'stat': 'STR',
    },
    {
      'title': 'Shadow Endurance Trial',
      'description': 'Prove your worth or face consequences. Run 2km before midnight.',
      'target': 2,
      'unit': 'km',
      'stat': 'VIT',
    },
    {
      'title': 'Mental Fortitude Exam',
      'description': 'The System demands cognitive proof. 20 minutes of focused study.',
      'target': 20,
      'unit': 'mins',
      'stat': 'INT',
    },
    {
      'title': 'Perception Calibration',
      'description': 'Your senses are dulling. 10 minutes of meditation. Now.',
      'target': 10,
      'unit': 'mins',
      'stat': 'PER',
    },
    {
      'title': 'Core Stability Override',
      'description': 'System integrity compromised. 30 sit-ups required for stabilization.',
      'target': 30,
      'unit': 'reps',
      'stat': 'VIT',
    },
  ];

  // Helpers for user-scoped storage
  String _userPref(String base) => _currentUser != null ? 'u_${_currentUser!.id}_$base' : base;

  AuthUser? get currentUser => _currentUser;
  List<AuthUser> get accounts => _accounts;
  bool get isAuthenticated => _currentUser != null;

  HunterProfile get profile => _profile;
  List<Quest> get quests => getQuestsForDate(_selectedDate);
  List<Quest> get allTemplateQuests => _quests;

  List<Achievement> get achievements => _achievements;
  bool get isInitialized => _isInitialized;
  String? get lastSystemMessage => _lastSystemMessage;
  bool get showLevelUpModal => _showLevelUpModal;
  int get latestLevelAchieved => _latestLevelAchieved;
  DateTime get selectedDate => _selectedDate;
  Map<String, int> get statGainsFromQuests => _statGainsFromQuests;

  // Autonomous system getters
  Quest? get activeEmergencyQuest => _activeEmergencyQuest;
  bool get showEmergencyQuestModal => _showEmergencyQuestModal;
  Achievement? get latestUnlockedAchievement => _latestUnlockedAchievement;
  bool get showAchievementModal => _showAchievementModal;
  int get consecutivePerfectDays => _consecutivePerfectDays;
  int get totalQuestClears => _totalQuestClears;
  int get bestStreak => _bestStreak;

  int get completedDailyCount => getDateCompletedCount(_selectedDate);
  int get totalDailyCount => getDateTotalCount(_selectedDate);
  double get dailyCompletionRatio => getDateCompletionRatio(_selectedDate);

  // Date formatting & comparison helpers
  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String get todayKey => dateKey(DateTime.now());
  String get selectedDateKey => dateKey(_selectedDate);

  bool isDateToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool isDatePast(DateTime d) {
    final now = DateTime.now();
    final dayOnly = DateTime(d.year, d.month, d.day);
    final todayOnly = DateTime(now.year, now.month, now.day);
    return dayOnly.isBefore(todayOnly);
  }

  bool isDateFuture(DateTime d) {
    final now = DateTime.now();
    final dayOnly = DateTime(d.year, d.month, d.day);
    final todayOnly = DateTime(now.year, now.month, now.day);
    return dayOnly.isAfter(todayOnly);
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  SystemState() {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Load Accounts & Passwords
      final accountsJson = prefs.getString(_prefAccountsKey);
      if (accountsJson != null) {
        final List list = jsonDecode(accountsJson);
        _accounts = list.map((a) => AuthUser.fromJson(a)).toList();
      }

      final passwordsJson = prefs.getString(_prefPasswordsKey);
      if (passwordsJson != null) {
        final Map map = jsonDecode(passwordsJson);
        _passwords = map.map((k, v) => MapEntry(k.toString(), v.toString()));
      }

      // Pre-seed sample Hunter account if no accounts exist yet
      if (_accounts.isEmpty) {
        final sampleUser = AuthUser(
          id: 'user_default',
          email: 'monarch@hunter.system',
          displayName: 'Sung Jin-Woo',
          provider: AuthProviderType.email,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        _accounts.add(sampleUser);
        _passwords['monarch@hunter.system'] = 'shadow123';
        await prefs.setString(_prefAccountsKey, jsonEncode(_accounts.map((a) => a.toJson()).toList()));
        await prefs.setString(_prefPasswordsKey, jsonEncode(_passwords));
      }

      // 2. Identify Current Active User Session
      final currentUserId = prefs.getString(_prefCurrentAuthUserKey);
      if (currentUserId != null && _accounts.any((a) => a.id == currentUserId)) {
        _currentUser = _accounts.firstWhere((a) => a.id == currentUserId);
        await _loadUserData(prefs);
      } else {
        // App starts on the Login screen if not signed in
        _currentUser = null;
      }
    } catch (e) {
      debugPrint('Error loading system state: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
      _startAutonomousSystem();
    }
  }

  Future<void> _loadUserData(SharedPreferences prefs) async {
    if (_currentUser == null) return;

    final profileStr = prefs.getString(_userPref(_prefProfileKey));
    if (profileStr != null) {
      _profile = HunterProfile.fromJson(jsonDecode(profileStr));
    } else {
      _profile = HunterProfile(name: _currentUser?.displayName ?? 'Sung Jin-Woo');
    }

    final questsStr = prefs.getString(_userPref(_prefQuestsKey));
    if (questsStr != null) {
      final List list = jsonDecode(questsStr);
      _quests = list.map((q) => Quest.fromJson(q)).toList();
    } else {
      _quests = Quest.defaultSoloQuests();
    }

    final progressStr = prefs.getString(_userPref(_prefDailyProgressKey));
    if (progressStr != null) {
      final Map decoded = jsonDecode(progressStr);
      _dailyProgress = decoded.map((k, v) => MapEntry(k.toString(), Map<String, int>.from(v)));
    } else {
      _dailyProgress = {};
    }

    final completedStr = prefs.getString(_userPref(_prefDailyCompletedKey));
    if (completedStr != null) {
      final Map decoded = jsonDecode(completedStr);
      _dailyCompleted = decoded.map((k, v) => MapEntry(k.toString(), List<String>.from(v)));
    } else {
      _dailyCompleted = {};
    }

    final statGainsStr = prefs.getString(_userPref(_prefStatGainsKey));
    if (statGainsStr != null) {
      final Map decoded = jsonDecode(statGainsStr);
      _statGainsFromQuests = decoded.map((k, v) => MapEntry(k.toString(), v is int ? v : 0));
    } else {
      _statGainsFromQuests = {'STR': 0, 'AGI': 0, 'VIT': 0, 'INT': 0, 'PER': 0};
    }

    final achievementsStr = prefs.getString(_userPref(_prefAchievementsKey));
    if (achievementsStr != null) {
      final List list = jsonDecode(achievementsStr);
      _achievements = list.map((a) => Achievement.fromJson(a)).toList();
    } else {
      _achievements = Achievement.defaultAchievements();
    }

    final emergencyStr = prefs.getString(_userPref(_prefEmergencyQuestKey));
    if (emergencyStr != null) {
      _activeEmergencyQuest = Quest.fromJson(jsonDecode(emergencyStr));
    } else {
      _activeEmergencyQuest = null;
    }

    _consecutivePerfectDays = prefs.getInt(_userPref(_prefConsecutiveDaysKey)) ?? 0;
    _totalQuestClears = prefs.getInt(_userPref(_prefTotalClearsKey)) ?? 0;
    _lastPerfectDay = prefs.getString(_userPref(_prefLastPerfectDayKey));
    _bestStreak = prefs.getInt(_userPref(_prefBestStreakKey)) ?? 0;

    // Synchronize today's active progress into _quests
    final todayProg = _dailyProgress[todayKey] ?? {};
    final todayDone = _dailyCompleted[todayKey] ?? [];
    for (var q in _quests) {
      if (todayProg.containsKey(q.id)) {
        q.current = todayProg[q.id]!;
      }
      if (todayDone.contains(q.id) || q.current >= q.target) {
        q.isCompleted = true;
        q.current = q.target;
      }
    }
  }

  Future<void> _saveAuthAccounts(SharedPreferences prefs) async {
    await prefs.setString(_prefAccountsKey, jsonEncode(_accounts.map((a) => a.toJson()).toList()));
    await prefs.setString(_prefPasswordsKey, jsonEncode(_passwords));
    if (_currentUser != null) {
      await prefs.setString(_prefCurrentAuthUserKey, _currentUser!.id);
    } else {
      await prefs.remove(_prefCurrentAuthUserKey);
    }
  }

  Future<void> saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _saveAuthAccounts(prefs);

      await prefs.setString(_userPref(_prefProfileKey), jsonEncode(_profile.toJson()));
      await prefs.setString(_userPref(_prefQuestsKey), jsonEncode(_quests.map((q) => q.toJson()).toList()));

      await prefs.setString(_userPref(_prefDailyProgressKey), jsonEncode(_dailyProgress));
      await prefs.setString(_userPref(_prefDailyCompletedKey), jsonEncode(_dailyCompleted));
      await prefs.setString(_userPref(_prefStatGainsKey), jsonEncode(_statGainsFromQuests));
      await prefs.setString(_userPref(_prefAchievementsKey), jsonEncode(_achievements.map((a) => a.toJson()).toList()));
      if (_activeEmergencyQuest != null) {
        await prefs.setString(_userPref(_prefEmergencyQuestKey), jsonEncode(_activeEmergencyQuest!.toJson()));
      } else {
        await prefs.remove(_userPref(_prefEmergencyQuestKey));
      }
      await prefs.setInt(_userPref(_prefConsecutiveDaysKey), _consecutivePerfectDays);
      await prefs.setInt(_userPref(_prefTotalClearsKey), _totalQuestClears);
      if (_lastPerfectDay != null) {
        await prefs.setString(_userPref(_prefLastPerfectDayKey), _lastPerfectDay!);
      }
      await prefs.setInt(_userPref(_prefBestStreakKey), _bestStreak);
    } catch (e) {
      debugPrint('Error saving system state: $e');
    }
  }

  // =============================================
  // --- REAL-TIME AUTHENTICATION API ---
  // =============================================

  Future<bool> signInWithEmail(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    final user = _accounts.firstWhere(
      (a) => a.email.toLowerCase() == cleanEmail,
      orElse: () => AuthUser(
        id: '',
        email: '',
        displayName: '',
        provider: AuthProviderType.email,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      ),
    );

    if (user.id.isEmpty) {
      postSystemMessage('❌ [AUTH ERROR] No Hunter registered with $cleanEmail.');
      return false;
    }

    final storedPassword = _passwords[cleanEmail];
    if (storedPassword != null && storedPassword != cleanPass) {
      postSystemMessage('❌ [AUTH ERROR] Invalid Hunter security passcode.');
      return false;
    }

    _currentUser = user.copyWith(lastLoginAt: DateTime.now());
    final index = _accounts.indexWhere((a) => a.id == user.id);
    if (index != -1) _accounts[index] = _currentUser!;

    final prefs = await SharedPreferences.getInstance();
    await _saveAuthAccounts(prefs);
    await _loadUserData(prefs);

    postSystemMessage('⚡ [SYSTEM] Welcome back, Hunter ${_currentUser!.displayName}! Data synchronized.');
    notifyListeners();
    return true;
  }

  Future<bool> signUpWithEmail(String email, String password, String hunterName) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();
    final cleanName = hunterName.trim().isEmpty ? 'Hunter' : hunterName.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      postSystemMessage('❌ [AUTH ERROR] Please enter a valid Gmail / Email address.');
      return false;
    }

    if (cleanPass.length < 4) {
      postSystemMessage('❌ [AUTH ERROR] Security passcode must be at least 4 characters.');
      return false;
    }

    if (_accounts.any((a) => a.email.toLowerCase() == cleanEmail)) {
      postSystemMessage('❌ [AUTH ERROR] Hunter account already exists with $cleanEmail. Please Sign In.');
      return false;
    }

    final newUser = AuthUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}',
      email: cleanEmail,
      displayName: cleanName,
      provider: AuthProviderType.email,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    _accounts.add(newUser);
    _passwords[cleanEmail] = cleanPass;
    _currentUser = newUser;

    _profile = HunterProfile(name: cleanName);
    _quests = Quest.defaultSoloQuests();
    _dailyProgress = {};
    _dailyCompleted = {};
    _statGainsFromQuests = {'STR': 0, 'AGI': 0, 'VIT': 0, 'INT': 0, 'PER': 0};
    _achievements = Achievement.defaultAchievements();
    _totalQuestClears = 0;
    _consecutivePerfectDays = 0;
    _bestStreak = 0;

    await saveState();
    postSystemMessage('👑 [AWAKENING] New Hunter Protocol Registered: $cleanName.');
    notifyListeners();
    return true;
  }

  Future<bool> signInWithGoogle({
    String? email,
    String? displayName,
    String? photoUrl,
    bool tryDeviceAuth = true,
  }) async {
    // 1. Try real device Google Sign-In (Phone Android / iOS native account selector)
    if (tryDeviceAuth && email == null) {
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
        final GoogleSignInAccount? account = await googleSignIn.signIn();
        if (account != null) {
          final realEmail = account.email.trim().toLowerCase();
          final realName = account.displayName?.trim().isNotEmpty == true
              ? account.displayName!.trim()
              : realEmail.split('@').first;
          final realPhoto = account.photoUrl;

          AuthUser user;
          final existingIndex = _accounts.indexWhere((a) => a.email.toLowerCase() == realEmail);
          if (existingIndex != -1) {
            user = _accounts[existingIndex].copyWith(
              displayName: realName,
              photoUrl: realPhoto ?? _accounts[existingIndex].photoUrl,
              lastLoginAt: DateTime.now(),
            );
            _accounts[existingIndex] = user;
          } else {
            user = AuthUser(
              id: account.id.isNotEmpty
                  ? 'goog_${account.id}'
                  : 'goog_${DateTime.now().millisecondsSinceEpoch}',
              email: realEmail,
              displayName: realName,
              photoUrl: realPhoto ?? 'https://lh3.googleusercontent.com/a/default-user',
              provider: AuthProviderType.google,
              createdAt: DateTime.now(),
              lastLoginAt: DateTime.now(),
            );
            _accounts.add(user);
          }

          _currentUser = user;
          final prefs = await SharedPreferences.getInstance();
          await _saveAuthAccounts(prefs);
          await _loadUserData(prefs);

          postSystemMessage('🌐 [GOOGLE SIGN-IN] Phone Account Connected: $realName ($realEmail).');
          notifyListeners();
          return true;
        } else {
          // User closed/cancelled Google account picker dialog
          return false;
        }
      } catch (e) {
        debugPrint('Device Google Sign-In error / fallback: $e');
        // Will continue to fallback if email was provided or prompt in UI
      }
    }

    // 2. Direct or Fallback Google Sign-In
    final randId = Random().nextInt(9000) + 1000;
    final googleEmail = email?.trim().toLowerCase() ?? 'hunter.$randId@gmail.com';
    final googleName = displayName?.trim().isNotEmpty == true ? displayName!.trim() : 'Hunter $randId';

    AuthUser user;
    final existingIndex = _accounts.indexWhere((a) => a.email.toLowerCase() == googleEmail);
    if (existingIndex != -1) {
      user = _accounts[existingIndex].copyWith(
        displayName: googleName,
        photoUrl: photoUrl ?? _accounts[existingIndex].photoUrl,
        lastLoginAt: DateTime.now(),
      );
      _accounts[existingIndex] = user;
    } else {
      user = AuthUser(
        id: 'goog_${DateTime.now().millisecondsSinceEpoch}_$randId',
        email: googleEmail,
        displayName: googleName,
        photoUrl: photoUrl ?? 'https://lh3.googleusercontent.com/a/default-user',
        provider: AuthProviderType.google,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      _accounts.add(user);
    }

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await _saveAuthAccounts(prefs);
    await _loadUserData(prefs);

    postSystemMessage('🌐 [GOOGLE SIGN-IN] Verified: $googleName ($googleEmail).');
    notifyListeners();
    return true;
  }

  Future<void> signInAsGuest() async {
    final randId = Random().nextInt(9000) + 1000;
    final guestUser = AuthUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest_$randId@monarch.system',
      displayName: 'Shadow Recruit #$randId',
      provider: AuthProviderType.guest,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    _accounts.add(guestUser);
    _currentUser = guestUser;

    _profile = HunterProfile(name: guestUser.displayName);
    _quests = Quest.defaultSoloQuests();
    _dailyProgress = {};
    _dailyCompleted = {};
    _statGainsFromQuests = {'STR': 0, 'AGI': 0, 'VIT': 0, 'INT': 0, 'PER': 0};
    _achievements = Achievement.defaultAchievements();

    await saveState();
    postSystemMessage('👤 [GUEST AWAKENING] Logged in as ${guestUser.displayName}.');
    notifyListeners();
  }

  Future<void> signOut() async {
    final oldName = _currentUser?.displayName ?? 'Hunter';
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefCurrentAuthUserKey);

    postSystemMessage('🔒 [SYSTEM] Disconnected session for $oldName.');
    notifyListeners();
  }

  Future<void> switchAccount(String userId) async {
    final target = _accounts.firstWhere((a) => a.id == userId, orElse: () => _accounts.first);
    _currentUser = target.copyWith(lastLoginAt: DateTime.now());

    final prefs = await SharedPreferences.getInstance();
    await _saveAuthAccounts(prefs);
    await _loadUserData(prefs);

    postSystemMessage('⚡ [SWITCH ACCOUNT] Switched to ${_currentUser!.displayName} (${_currentUser!.email}).');
    notifyListeners();
  }

  void postSystemMessage(String msg) {
    _lastSystemMessage = msg;
    notifyListeners();
  }

  void clearSystemMessage() {
    _lastSystemMessage = null;
    notifyListeners();
  }

  void closeLevelUpModal() {
    _showLevelUpModal = false;
    notifyListeners();
  }

  // =============================================
  // --- AUTONOMOUS MYSTERIOUS SYSTEM ENGINE ---
  // =============================================

  void _startAutonomousSystem() {
    _autonomousTimer?.cancel();
    _initialDelayTimer?.cancel();
    // Evaluate every 90 seconds
    _autonomousTimer = Timer.periodic(const Duration(seconds: 90), (_) {
      _autonomousEvaluation();
    });
    // Also run an initial evaluation after a short delay
    _initialDelayTimer = Timer(const Duration(seconds: 5), () {
      _autonomousEvaluation();
    });
  }

  void _autonomousEvaluation() {
    if (!_isInitialized || _currentUser == null) return;
    final now = DateTime.now();
    final hour = now.hour;
    final ratio = getDateCompletionRatio(DateTime.now());
    final rand = Random();

    // Late in the day with low completion -> system warns or generates emergency
    if (hour >= 18 && ratio < 0.5 && _activeEmergencyQuest == null) {
      if (rand.nextDouble() < 0.35) {
        triggerEmergencyQuest();
        return;
      } else {
        final warning = _warningMessages[rand.nextInt(_warningMessages.length)];
        postSystemMessage(warning);
        return;
      }
    }

    // Periodically emit cryptic observations (low probability)
    if (rand.nextDouble() < 0.15) {
      final observation = _crypticObservations[rand.nextInt(_crypticObservations.length)];
      postSystemMessage(observation);
    }

    // Check achievements passively
    _checkAchievements();
  }

  /// Manually trigger the autonomous system for testing/demonstration
  void simulateAutonomousIntervention() {
    final rand = Random();
    final roll = rand.nextInt(100);

    if (roll < 40) {
      // Generate an emergency quest
      triggerEmergencyQuest(
        customReason: 'The System has detected a critical lapse in training discipline.',
      );
    } else if (roll < 70) {
      // Emit a dramatic warning
      final warning = _warningMessages[rand.nextInt(_warningMessages.length)];
      postSystemMessage(warning);
    } else {
      // Emit a cryptic observation
      final observation = _crypticObservations[rand.nextInt(_crypticObservations.length)];
      postSystemMessage(observation);
    }
  }

  void triggerEmergencyQuest({String? customReason}) {
    if (_activeEmergencyQuest != null && !_activeEmergencyQuest!.isCompleted) {
      postSystemMessage('[SYSTEM] An Emergency Quest is already active. Complete it first.');
      return;
    }

    final rand = Random();
    final template = _emergencyQuestTemplates[rand.nextInt(_emergencyQuestTemplates.length)];

    _activeEmergencyQuest = Quest.createEmergencyQuest(
      title: template['title'] as String,
      description: template['description'] as String,
      target: template['target'] as int,
      unit: template['unit'] as String,
      statReward: StatType.fromCode(template['stat'] as String),
      urgentReason: customReason ?? 'Player has demonstrated insufficient discipline.',
    );

    _showEmergencyQuestModal = true;
    saveState();
    notifyListeners();
  }

  void dismissEmergencyQuestModal() {
    _showEmergencyQuestModal = false;
    notifyListeners();
  }

  void incrementEmergencyQuestProgress(int amount) {
    if (_activeEmergencyQuest == null || _activeEmergencyQuest!.isCompleted) return;

    _activeEmergencyQuest!.current =
        min(_activeEmergencyQuest!.target, _activeEmergencyQuest!.current + amount);

    if (_activeEmergencyQuest!.current >= _activeEmergencyQuest!.target) {
      _completeEmergencyQuest();
    } else {
      postSystemMessage(
        '[EMERGENCY] ${_activeEmergencyQuest!.title}: '
        '[${_activeEmergencyQuest!.current} / ${_activeEmergencyQuest!.target} ${_activeEmergencyQuest!.unit}]',
      );
    }

    saveState();
    notifyListeners();
  }

  void _completeEmergencyQuest() {
    if (_activeEmergencyQuest == null) return;

    final quest = _activeEmergencyQuest!;
    quest.isCompleted = true;

    // Apply stat reward
    switch (quest.statReward) {
      case StatType.str:
        _profile.stats.strength += 2;
        break;
      case StatType.agi:
        _profile.stats.agility += 2;
        break;
      case StatType.vit:
        _profile.stats.vitality += 2;
        break;
      case StatType.intl:
        _profile.stats.intelligence += 2;
        break;
      case StatType.per:
        _profile.stats.perception += 2;
        break;
    }
    _statGainsFromQuests[quest.statReward.code] =
        (_statGainsFromQuests[quest.statReward.code] ?? 0) + 2;

    _profile.gold += quest.goldReward;

    postSystemMessage(
      '[SYSTEM: EMERGENCY QUEST CLEARED]\n'
      'Quest [${quest.title}] completed before deadline!\n'
      'Rewards: +2 ${quest.statReward.code}, +${quest.expReward} EXP, +${quest.goldReward} Gold',
    );

    gainExp(quest.expReward);

    // Check the eleventh_hour achievement
    _unlockAchievement('eleventh_hour');

    saveState();
    notifyListeners();
  }

  void dismissEmergencyQuest() {
    _activeEmergencyQuest = null;
    _showEmergencyQuestModal = false;
    saveState();
    notifyListeners();
  }

  // --- Achievement System ---

  void _checkAchievements() {
    // First Awakening: complete 1 quest ever
    if (_totalQuestClears >= 1) {
      _unlockAchievement('first_awakening');
    }

    // Iron Discipline: 10 total quest clears
    _updateAchievementProgress('iron_discipline', _totalQuestClears);
    if (_totalQuestClears >= 10) {
      _unlockAchievement('iron_discipline');
    }

    // Perfect Regimen: 100% daily quests in a single day (checked at completion time)
    // (handled in _checkDailyCompletionBonus)

    // The Unbroken: 7 consecutive perfect days
    _updateAchievementProgress('the_unbroken', _consecutivePerfectDays);
    if (_consecutivePerfectDays >= 7) {
      _unlockAchievement('the_unbroken');
    }

    // Monarch's Will: reach level 5
    _updateAchievementProgress('monarch_will', _profile.level);
    if (_profile.level >= 5) {
      _unlockAchievement('monarch_will');
    }

    // Disciplined: 14-day streak
    _updateAchievementProgress('disciplined', _bestStreak);
    if (_bestStreak >= 14) {
      _unlockAchievement('disciplined');
    }

    // First Ascension: reach level 10
    _updateAchievementProgress('first_ascension', _profile.level);
    if (_profile.level >= 10) {
      _unlockAchievement('first_ascension');
    }

    // Deadly Monarch: 25 total quest clears
    _updateAchievementProgress('deadly_monarch', _totalQuestClears);
    if (_totalQuestClears >= 25) {
      _unlockAchievement('deadly_monarch');
    }

    // System User: 100 total quests
    _updateAchievementProgress('system_user', _totalQuestClears);
    if (_totalQuestClears >= 100) {
      _unlockAchievement('system_user');
    }

    saveState();
  }

  void _updateAchievementProgress(String achievementId, int progress) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;
    if (_achievements[index].isUnlocked) return;
    _achievements[index].currentProgress =
        min(_achievements[index].maxProgress, progress);
  }

  void _unlockAchievement(String achievementId) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1 || _achievements[index].isUnlocked) return;

    final achievement = _achievements[index];
    achievement.isUnlocked = true;
    achievement.unlockedAt = DateTime.now();
    achievement.currentProgress = achievement.maxProgress;

    // Grant rewards
    _profile.gold += achievement.goldReward;
    if (achievement.titleReward != null) {
      if (!_profile.titles.contains(achievement.titleReward)) {
        _profile.titles.add(achievement.titleReward!);
      }
    }

    _latestUnlockedAchievement = achievement;
    _showAchievementModal = false; // Popup-free: no blocking modal popup!

    postSystemMessage('🏆 [ACHIEVEMENT UNLOCKED] ${achievement.title} • ${achievement.rewardDescription}');

    // Grant EXP (calls gainExp which triggers notifyListeners)
    gainExp(achievement.expReward);

    saveState();
    notifyListeners();
  }

  void dismissAchievementModal() {
    _showAchievementModal = false;
    _latestUnlockedAchievement = null;
    notifyListeners();
  }

  // --- Hunter Progression & Stats ---

  void addStatPoint(StatType type) {
    if (_profile.statPoints <= 0) return;

    _profile.statPoints--;
    switch (type) {
      case StatType.str:
        _profile.stats.strength++;
        break;
      case StatType.agi:
        _profile.stats.agility++;
        break;
      case StatType.vit:
        _profile.stats.vitality++;
        break;
      case StatType.intl:
        _profile.stats.intelligence++;
        break;
      case StatType.per:
        _profile.stats.perception++;
        break;
    }
    _statGainsFromQuests[type.code] = (_statGainsFromQuests[type.code] ?? 0) + 1;
    postSystemMessage('[SYSTEM] Allocated +1 to ${type.code}.');
    saveState();
    notifyListeners();
  }

  void gainExp(int amount) {
    _profile.exp += amount;

    while (_profile.exp >= _profile.maxExp) {
      _profile.exp -= _profile.maxExp;
      _profile.level++;
      _profile.fatigue = max(0, _profile.fatigue - 20);
      _latestLevelAchieved = _profile.level;
      _showLevelUpModal = false; // Popup-free: no blocking modal dialog!
      postSystemMessage('👑 [LEVEL UP!] Hunter reached Level ${_profile.level}!');
    }
    _checkAchievements();
    saveState();
    notifyListeners();
  }

  void updateHunterDetails({String? name, String? title, String? job}) {
    if (name != null && name.trim().isNotEmpty) _profile.name = name.trim();
    if (title != null && title.trim().isNotEmpty) _profile.title = title.trim();
    if (job != null && job.trim().isNotEmpty) _profile.job = job.trim();
    saveState();
    notifyListeners();
  }

  // --- Date & Calendar Task Queries ---

  List<Quest> getQuestsForDate(DateTime date) {
    final key = dateKey(date);
    if (isDateToday(date)) {
      return _quests;
    }
    final progressMap = _dailyProgress[key] ?? {};
    final completedList = _dailyCompleted[key] ?? [];

    return _quests.map((q) {
      final current = progressMap[q.id] ?? (completedList.contains(q.id) ? q.target : 0);
      final isDone = completedList.contains(q.id) || current >= q.target;
      return q.copyWith(
        current: current,
        isCompleted: isDone,
      );
    }).toList();
  }

  int getDateCompletedCount(DateTime date) {
    final list = getQuestsForDate(date);
    return list.where((q) => q.isCompleted).length;
  }

  int getDateTotalCount(DateTime date) {
    return _quests.length;
  }

  double getDateCompletionRatio(DateTime date) {
    final total = getDateTotalCount(date);
    if (total == 0) return 0.0;
    return (getDateCompletedCount(date) / total).clamp(0.0, 1.0);
  }

  // --- Quests & Habit Tracking ---

  void incrementQuestProgress(String questId, int amount, {DateTime? date}) {
    final targetDate = date ?? _selectedDate;
    final dKey = dateKey(targetDate);

    final questIndex = _quests.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return;
    final templateQuest = _quests[questIndex];

    if (isDateToday(targetDate)) {
      final quest = _quests[questIndex];
      if (quest.isCompleted) return;

      final previousCurrent = quest.current;
      quest.current = min(quest.target, quest.current + amount);
      _profile.fatigue = min(100, _profile.fatigue + 2);

      _dailyProgress.putIfAbsent(dKey, () => {})[questId] = quest.current;

      if (quest.current >= quest.target && !quest.isCompleted) {
        _completeQuest(quest, targetDate);
      } else if (quest.current > previousCurrent) {
        postSystemMessage('[SYSTEM] ${quest.title}: [${quest.current} / ${quest.target} ${quest.unit}]');
      }
    } else {
      final progressMap = _dailyProgress.putIfAbsent(dKey, () => {});
      final completedList = _dailyCompleted.putIfAbsent(dKey, () => []);

      if (completedList.contains(questId)) return;

      final currentVal = progressMap[questId] ?? 0;
      final newVal = min(templateQuest.target, currentVal + amount);
      progressMap[questId] = newVal;

      if (newVal >= templateQuest.target) {
        final dateQuest = templateQuest.copyWith(current: newVal);
        _completeQuest(dateQuest, targetDate);
      } else {
        postSystemMessage('[SYSTEM] ${templateQuest.title}: [$newVal / ${templateQuest.target} ${templateQuest.unit}]');
      }
    }

    saveState();
    notifyListeners();
  }

  void toggleQuestComplete(String questId, {DateTime? date}) {
    final targetDate = date ?? _selectedDate;
    final dKey = dateKey(targetDate);
    final questIndex = _quests.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return;
    final template = _quests[questIndex];

    final isDone = isDateToday(targetDate)
        ? _quests[questIndex].isCompleted
        : (_dailyCompleted[dKey]?.contains(questId) ?? false);

    if (isDone) {
      // Reopen quest
      if (isDateToday(targetDate)) {
        _quests[questIndex].isCompleted = false;
        _quests[questIndex].current = 0;
      }
      _dailyCompleted[dKey]?.remove(questId);
      _dailyProgress[dKey]?[questId] = 0;
      postSystemMessage('[SYSTEM] Reopened [${template.title}] for ${targetDate.month}/${targetDate.day}.');
      saveState();
      notifyListeners();
    } else {
      // Complete quest
      incrementQuestProgress(questId, template.target, date: targetDate);
    }
  }

  void setQuestProgress(String questId, int progress, {DateTime? date}) {
    final targetDate = date ?? _selectedDate;
    final dKey = dateKey(targetDate);
    final questIndex = _quests.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return;
    final quest = _quests[questIndex];

    final clamped = progress.clamp(0, quest.target);
    if (isDateToday(targetDate)) {
      quest.current = clamped;
      _dailyProgress.putIfAbsent(dKey, () => {})[questId] = clamped;
      if (quest.current >= quest.target && !quest.isCompleted) {
        _completeQuest(quest, targetDate);
      }
    } else {
      _dailyProgress.putIfAbsent(dKey, () => {})[questId] = clamped;
      if (clamped >= quest.target && !(_dailyCompleted[dKey]?.contains(questId) ?? false)) {
        _completeQuest(quest.copyWith(current: clamped), targetDate);
      }
    }
    saveState();
    notifyListeners();
  }

  void _completeQuest(Quest quest, [DateTime? date]) {
    final targetDate = date ?? _selectedDate;
    final dKey = dateKey(targetDate);

    quest.isCompleted = true;
    quest.streak++;
    _profile.gold += quest.goldReward;
    _totalQuestClears++;

    final completedList = _dailyCompleted.putIfAbsent(dKey, () => []);
    if (!completedList.contains(quest.id)) {
      completedList.add(quest.id);
    }
    _dailyProgress.putIfAbsent(dKey, () => {})[quest.id] = quest.target;

    // DIRECT ATTRIBUTE IMPROVEMENT:
    // Attributes strictly improve based on the tasks completed!
    switch (quest.statReward) {
      case StatType.str:
        _profile.stats.strength += 1;
        break;
      case StatType.agi:
        _profile.stats.agility += 1;
        break;
      case StatType.vit:
        _profile.stats.vitality += 1;
        break;
      case StatType.intl:
        _profile.stats.intelligence += 1;
        break;
      case StatType.per:
        _profile.stats.perception += 1;
        break;
    }
    _statGainsFromQuests[quest.statReward.code] =
        (_statGainsFromQuests[quest.statReward.code] ?? 0) + 1;

    postSystemMessage(
      '⚔ [TASK EXECUTED] [${quest.title.toUpperCase()}]\n'
      '⚡ Boost: +1 ${quest.statReward.code} [${quest.statReward.label.toUpperCase()}] • +${quest.expReward} EXP • +${quest.goldReward}G',
    );

    gainExp(quest.expReward);
    _checkDailyCompletionBonus(targetDate);
    _checkAchievements();
  }

  void _checkDailyCompletionBonus([DateTime? date]) {
    final targetDate = date ?? _selectedDate;
    final dKey = dateKey(targetDate);
    final questsForDay = getQuestsForDate(targetDate);
    final allDone = questsForDay.isNotEmpty && questsForDay.every((q) => q.isCompleted);
    if (allDone) {
      postSystemMessage(
        '👑 [ALL DAILY TASKS CLEARED]\n'
        'Conquered all training for ${targetDate.month}/${targetDate.day}!\n'
        'Discipline Bonus: +200 EXP!',
      );

      // Track consecutive perfect days
      if (_lastPerfectDay == null || _lastPerfectDay != dKey) {
        // Check if this is consecutive to the previous perfect day
        final yesterday = targetDate.subtract(const Duration(days: 1));
        final yesterdayKey = dateKey(yesterday);
        if (_lastPerfectDay == yesterdayKey) {
          _consecutivePerfectDays++;
        } else {
          _consecutivePerfectDays = 1;
        }
        _lastPerfectDay = dKey;
        if (_consecutivePerfectDays > _bestStreak) {
          _bestStreak = _consecutivePerfectDays;
        }
      }

      // Unlock Perfect Regimen
      _unlockAchievement('perfect_regimen');
      _checkAchievements();
    }
  }

  void addCustomQuest({
    required String title,
    required String description,
    required int target,
    required String unit,
    required StatType statReward,
    required int expReward,
    required int goldReward,
  }) {
    final newQuest = Quest(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      target: target,
      unit: unit,
      statReward: statReward,
      expReward: expReward,
      goldReward: goldReward,
      isDaily: true,
    );
    _quests.add(newQuest);
    postSystemMessage('[SYSTEM] New Repeating Hunter Quest Registered: [${newQuest.title}]');
    saveState();
    notifyListeners();
  }

  void updateQuestStatReward(String questId, StatType newStat) {
    final index = _quests.indexWhere((q) => q.id == questId);
    if (index == -1) return;
    _quests[index].statReward = newStat;
    postSystemMessage('[SYSTEM] Task [${_quests[index].title}] attribute aligned to ${newStat.code}.');
    saveState();
    notifyListeners();
  }

  void deleteQuest(String id) {
    _quests.removeWhere((q) => q.id == id);
    for (var m in _dailyProgress.values) {
      m.remove(id);
    }
    for (var list in _dailyCompleted.values) {
      list.remove(id);
    }
    saveState();
    notifyListeners();
  }

  void resetDailyQuests([DateTime? date]) {
    final targetDate = date ?? _selectedDate;
    final dKey = dateKey(targetDate);

    if (isDateToday(targetDate)) {
      for (var q in _quests) {
        q.current = 0;
        q.isCompleted = false;
      }
      _profile.fatigue = max(0, _profile.fatigue - 30);
    }
    _dailyProgress[dKey] = {};
    _dailyCompleted[dKey] = [];

    postSystemMessage('[SYSTEM] Tasks have been refreshed for ${targetDate.month}/${targetDate.day}.');
    saveState();
    notifyListeners();
  }

  @override
  void dispose() {
    _autonomousTimer?.cancel();
    _initialDelayTimer?.cancel();
    super.dispose();
  }
}
