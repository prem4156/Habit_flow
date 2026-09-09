import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hunter_model.dart';
import '../models/quest_model.dart';
import '../models/item_model.dart';
import '../models/achievement_model.dart';

class SystemState extends ChangeNotifier {
  static const String _prefProfileKey = 'sl_hunter_profile';
  static const String _prefQuestsKey = 'sl_hunter_quests';
  static const String _prefItemsKey = 'sl_hunter_items';
  static const String _prefDailyProgressKey = 'sl_daily_progress';
  static const String _prefDailyCompletedKey = 'sl_daily_completed';
  static const String _prefStatGainsKey = 'sl_stat_gains';
  static const String _prefAchievementsKey = 'sl_achievements';
  static const String _prefEmergencyQuestKey = 'sl_emergency_quest';
  static const String _prefConsecutiveDaysKey = 'sl_consecutive_days';
  static const String _prefTotalClearsKey = 'sl_total_clears';
  static const String _prefLastPerfectDayKey = 'sl_last_perfect_day';

  HunterProfile _profile = HunterProfile.defaultProfile();
  List<Quest> _quests = Quest.defaultSoloQuests();
  List<InventoryItem> _items = InventoryItem.defaultItems();
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
  bool _isPenaltyActive = false;
  int _penaltyTimeRemainingSeconds = 600; // 10 minutes desert survival
  Timer? _penaltyTimer;

  // --- Autonomous System State ---
  Quest? _activeEmergencyQuest;
  bool _showEmergencyQuestModal = false;
  Achievement? _latestUnlockedAchievement;
  bool _showAchievementModal = false;
  int _consecutivePerfectDays = 0;
  int _totalQuestClears = 0;
  String? _lastPerfectDay;
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
    '[WARNING] Penalty Zone protocols on standby. Complete your tasks.',
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

  HunterProfile get profile => _profile;
  List<Quest> get quests => getQuestsForDate(_selectedDate);
  List<Quest> get allTemplateQuests => _quests;
  List<InventoryItem> get items => _items;
  List<Achievement> get achievements => _achievements;
  bool get isInitialized => _isInitialized;
  String? get lastSystemMessage => _lastSystemMessage;
  bool get showLevelUpModal => _showLevelUpModal;
  int get latestLevelAchieved => _latestLevelAchieved;
  bool get isPenaltyActive => _isPenaltyActive;
  int get penaltyTimeRemainingSeconds => _penaltyTimeRemainingSeconds;
  DateTime get selectedDate => _selectedDate;
  Map<String, int> get statGainsFromQuests => _statGainsFromQuests;

  // Autonomous system getters
  Quest? get activeEmergencyQuest => _activeEmergencyQuest;
  bool get showEmergencyQuestModal => _showEmergencyQuestModal;
  Achievement? get latestUnlockedAchievement => _latestUnlockedAchievement;
  bool get showAchievementModal => _showAchievementModal;
  int get consecutivePerfectDays => _consecutivePerfectDays;
  int get totalQuestClears => _totalQuestClears;

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

      final profileStr = prefs.getString(_prefProfileKey);
      if (profileStr != null) {
        _profile = HunterProfile.fromJson(jsonDecode(profileStr));
      }

      final questsStr = prefs.getString(_prefQuestsKey);
      if (questsStr != null) {
        final List list = jsonDecode(questsStr);
        _quests = list.map((q) => Quest.fromJson(q)).toList();
      }

      final itemsStr = prefs.getString(_prefItemsKey);
      if (itemsStr != null) {
        final List list = jsonDecode(itemsStr);
        _items = list.map((i) => InventoryItem.fromJson(i)).toList();
      }

      final progressStr = prefs.getString(_prefDailyProgressKey);
      if (progressStr != null) {
        final Map decoded = jsonDecode(progressStr);
        _dailyProgress = decoded.map((k, v) => MapEntry(k.toString(), Map<String, int>.from(v)));
      }

      final completedStr = prefs.getString(_prefDailyCompletedKey);
      if (completedStr != null) {
        final Map decoded = jsonDecode(completedStr);
        _dailyCompleted = decoded.map((k, v) => MapEntry(k.toString(), List<String>.from(v)));
      }

      final statGainsStr = prefs.getString(_prefStatGainsKey);
      if (statGainsStr != null) {
        final Map decoded = jsonDecode(statGainsStr);
        _statGainsFromQuests = decoded.map((k, v) => MapEntry(k.toString(), v is int ? v : 0));
      }

      // Load achievements
      final achievementsStr = prefs.getString(_prefAchievementsKey);
      if (achievementsStr != null) {
        final List list = jsonDecode(achievementsStr);
        _achievements = list.map((a) => Achievement.fromJson(a)).toList();
      }

      // Load emergency quest
      final emergencyStr = prefs.getString(_prefEmergencyQuestKey);
      if (emergencyStr != null) {
        _activeEmergencyQuest = Quest.fromJson(jsonDecode(emergencyStr));
        // Check if emergency quest deadline has passed (it's a new day)
        if (_activeEmergencyQuest != null && !_activeEmergencyQuest!.isCompleted) {
          // Emergency quest persists until completed or a new day starts
        }
      }

      // Load streak tracking
      _consecutivePerfectDays = prefs.getInt(_prefConsecutiveDaysKey) ?? 0;
      _totalQuestClears = prefs.getInt(_prefTotalClearsKey) ?? 0;
      _lastPerfectDay = prefs.getString(_prefLastPerfectDayKey);

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
    } catch (e) {
      debugPrint('Error loading system state: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
      // Start the autonomous system evaluation loop
      _startAutonomousSystem();
    }
  }

  Future<void> saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefProfileKey, jsonEncode(_profile.toJson()));
      await prefs.setString(_prefQuestsKey, jsonEncode(_quests.map((q) => q.toJson()).toList()));
      await prefs.setString(_prefItemsKey, jsonEncode(_items.map((i) => i.toJson()).toList()));
      await prefs.setString(_prefDailyProgressKey, jsonEncode(_dailyProgress));
      await prefs.setString(_prefDailyCompletedKey, jsonEncode(_dailyCompleted));
      await prefs.setString(_prefStatGainsKey, jsonEncode(_statGainsFromQuests));
      await prefs.setString(_prefAchievementsKey, jsonEncode(_achievements.map((a) => a.toJson()).toList()));
      if (_activeEmergencyQuest != null) {
        await prefs.setString(_prefEmergencyQuestKey, jsonEncode(_activeEmergencyQuest!.toJson()));
      } else {
        await prefs.remove(_prefEmergencyQuestKey);
      }
      await prefs.setInt(_prefConsecutiveDaysKey, _consecutivePerfectDays);
      await prefs.setInt(_prefTotalClearsKey, _totalQuestClears);
      if (_lastPerfectDay != null) {
        await prefs.setString(_prefLastPerfectDayKey, _lastPerfectDay!);
      }
    } catch (e) {
      debugPrint('Error saving system state: $e');
    }
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
    if (!_isInitialized) return;
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
    _showAchievementModal = true;

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
    postSystemMessage('[SYSTEM] Gained +$amount EXP.');

    while (_profile.exp >= _profile.maxExp) {
      _profile.exp -= _profile.maxExp;
      _profile.level++;
      // Attributes only improve based on tasks completed, so statPoints are not added arbitrarily
      _profile.fatigue = max(0, _profile.fatigue - 20);
      _latestLevelAchieved = _profile.level;
      _showLevelUpModal = true;
      postSystemMessage('[SYSTEM] LEVEL UP! Hunter reached Level ${_profile.level}!');
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
      '[SYSTEM NOTIFICATION]\nQuest [${quest.title}] Cleared!\n'
      'Attribute Growth: +1 ${quest.statReward.code} | Rewards: +${quest.expReward} EXP, +${quest.goldReward} Gold',
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
      _profile.gold += 300;
      _addItem('blessed_box', 1);
      _addItem('full_recovery', 1);
      postSystemMessage(
        '[SYSTEM: ALL DAILY TASKS CLEARED]\n'
        'You have conquered all training for ${targetDate.month}/${targetDate.day}!\n'
        'Rewards: +300 Gold, 1x Blessed Random Box, 1x Status Recovery Potion!',
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

  // --- Inventory & Items ---

  void _addItem(String itemId, int qty) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index].quantity += qty;
    } else {
      final defaultList = InventoryItem.defaultItems();
      final found = defaultList.firstWhere(
        (i) => i.id == itemId,
        orElse: () => InventoryItem(
          id: itemId,
          name: 'Mysterious Item',
          description: 'An unidentified system item.',
          rarity: ItemRarity.rare,
          icon: 'box',
        ),
      );
      found.quantity = qty;
      _items.add(found);
    }
    saveState();
  }

  String openBlessedBox() {
    final index = _items.indexWhere((i) => i.id == 'blessed_box');
    if (index == -1 || _items[index].quantity <= 0) {
      return 'No Blessed Random Boxes available.';
    }

    _items[index].quantity--;
    if (_items[index].quantity <= 0) {
      _items.removeAt(index);
    }

    final rand = Random();
    final roll = rand.nextInt(100);
    String outcome;

    if (roll < 40) {
      // Gold reward
      final goldGain = 200 + rand.nextInt(300);
      _profile.gold += goldGain;
      outcome = 'Obtained $goldGain Gold from the Blessed Box!';
    } else if (roll < 75) {
      // Bonus Gold
      final goldBonus = 500 + rand.nextInt(500);
      _profile.gold += goldBonus;
      outcome = 'System Blessing: Received +$goldBonus Bonus Gold!';
    } else if (roll < 90) {
      // Potion
      _addItem('full_recovery', 2);
      outcome = 'Found 2x Status Recovery Potions!';
    } else {
      // Legendary Title or Bonus EXP
      if (!_profile.titles.contains('Monarch Candidate')) {
        _profile.titles.add('Monarch Candidate');
        _profile.title = 'Monarch Candidate';
        outcome = 'LEGENDARY BLESSING! Bestowed Title: [Monarch Candidate]!';
      } else {
        final expBonus = 300;
        gainExp(expBonus);
        outcome = 'Great Blessing: Received +$expBonus Bonus EXP!';
      }
    }

    postSystemMessage('[SYSTEM: BLESSED BOX OPENED]\n$outcome');
    saveState();
    notifyListeners();
    return outcome;
  }

  bool useRecoveryPotion() {
    final index = _items.indexWhere((i) => i.id == 'full_recovery');
    if (index == -1 || _items[index].quantity <= 0) {
      return false;
    }

    _items[index].quantity--;
    if (_items[index].quantity <= 0) {
      _items.removeAt(index);
    }

    _profile.fatigue = 0;
    postSystemMessage('[SYSTEM] Full Recovery applied! Fatigue cleared to 0%.');
    saveState();
    notifyListeners();
    return true;
  }

  bool buyItem(InventoryItem item) {
    if (_profile.gold < item.price) {
      postSystemMessage('[SYSTEM] Insufficient Gold to purchase ${item.name}.');
      return false;
    }

    _profile.gold -= item.price;
    _addItem(item.id, 1);
    postSystemMessage('[SYSTEM] Purchased 1x ${item.name} for ${item.price} Gold.');
    saveState();
    notifyListeners();
    return true;
  }

  // --- Penalty Zone Survival ---

  void triggerPenaltyZone() {
    _isPenaltyActive = true;
    _penaltyTimeRemainingSeconds = 300; // 5 min survival test
    _penaltyTimer?.cancel();
    _penaltyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_penaltyTimeRemainingSeconds > 0) {
        _penaltyTimeRemainingSeconds--;
        notifyListeners();
      } else {
        completePenaltyZone();
      }
    });
    postSystemMessage('[PENALTY QUEST ACTIVATED]\nFailure to complete daily tasks! Survive the Giant Centipedes!');
    notifyListeners();
  }

  void completePenaltyZone() {
    _penaltyTimer?.cancel();
    _penaltyTimer = null;
    _isPenaltyActive = false;
    _profile.fatigue = 85;
    gainExp(150);
    _unlockAchievement('abyss_survivor');
    postSystemMessage('[SYSTEM] Penalty Quest Survived! Survived the Desert Realm.');
    saveState();
    notifyListeners();
  }

  void escapePenaltyZone() {
    _penaltyTimer?.cancel();
    _penaltyTimer = null;
    _isPenaltyActive = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _penaltyTimer?.cancel();
    _autonomousTimer?.cancel();
    _initialDelayTimer?.cancel();
    super.dispose();
  }
}
