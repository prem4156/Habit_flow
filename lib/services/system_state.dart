import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hunter_model.dart';
import '../models/quest_model.dart';
import '../models/item_model.dart';

class SystemState extends ChangeNotifier {
  static const String _prefProfileKey = 'sl_hunter_profile';
  static const String _prefQuestsKey = 'sl_hunter_quests';
  static const String _prefItemsKey = 'sl_hunter_items';

  HunterProfile _profile = HunterProfile.defaultProfile();
  List<Quest> _quests = Quest.defaultSoloQuests();
  List<InventoryItem> _items = InventoryItem.defaultItems();

  bool _isInitialized = false;
  String? _lastSystemMessage;
  bool _showLevelUpModal = false;
  int _latestLevelAchieved = 1;
  bool _isPenaltyActive = false;
  int _penaltyTimeRemainingSeconds = 600; // 10 minutes desert survival
  Timer? _penaltyTimer;

  HunterProfile get profile => _profile;
  List<Quest> get quests => _quests;
  List<InventoryItem> get items => _items;
  bool get isInitialized => _isInitialized;
  String? get lastSystemMessage => _lastSystemMessage;
  bool get showLevelUpModal => _showLevelUpModal;
  int get latestLevelAchieved => _latestLevelAchieved;
  bool get isPenaltyActive => _isPenaltyActive;
  int get penaltyTimeRemainingSeconds => _penaltyTimeRemainingSeconds;

  int get completedDailyCount => _quests.where((q) => q.isDaily && q.isCompleted).length;
  int get totalDailyCount => _quests.where((q) => q.isDaily).length;
  double get dailyCompletionRatio =>
      totalDailyCount > 0 ? (completedDailyCount / totalDailyCount) : 0.0;

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
    } catch (e) {
      debugPrint('Error loading system state: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefProfileKey, jsonEncode(_profile.toJson()));
      await prefs.setString(_prefQuestsKey, jsonEncode(_quests.map((q) => q.toJson()).toList()));
      await prefs.setString(_prefItemsKey, jsonEncode(_items.map((i) => i.toJson()).toList()));
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
      _profile.statPoints += 3;
      _profile.fatigue = max(0, _profile.fatigue - 20);
      _latestLevelAchieved = _profile.level;
      _showLevelUpModal = true;
      postSystemMessage('[SYSTEM] LEVEL UP! Hunter reached Level ${_profile.level}!');
    }
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

  // --- Quests & Habit Tracking ---

  void incrementQuestProgress(String questId, int amount) {
    final index = _quests.indexWhere((q) => q.id == questId);
    if (index == -1) return;

    final quest = _quests[index];
    if (quest.isCompleted) return;

    final previousCurrent = quest.current;
    quest.current = min(quest.target, quest.current + amount);
    _profile.fatigue = min(100, _profile.fatigue + 2);

    if (quest.current >= quest.target && !quest.isCompleted) {
      _completeQuest(quest);
    } else if (quest.current > previousCurrent) {
      postSystemMessage('[SYSTEM] ${quest.title}: [${quest.current} / ${quest.target} ${quest.unit}]');
    }

    saveState();
    notifyListeners();
  }

  void setQuestProgress(String questId, int progress) {
    final index = _quests.indexWhere((q) => q.id == questId);
    if (index == -1) return;

    final quest = _quests[index];
    quest.current = progress.clamp(0, quest.target);
    if (quest.current >= quest.target && !quest.isCompleted) {
      _completeQuest(quest);
    }
    saveState();
    notifyListeners();
  }

  void _completeQuest(Quest quest) {
    quest.isCompleted = true;
    quest.streak++;
    _profile.gold += quest.goldReward;

    // Direct stat bonus from completing quest!
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

    postSystemMessage(
      '[SYSTEM NOTIFICATION]\nQuest [${quest.title}] Cleared!\n'
      'Rewards: +${quest.expReward} EXP, +${quest.goldReward} Gold, +1 ${quest.statReward.code}',
    );

    gainExp(quest.expReward);
    _checkDailyCompletionBonus();
  }

  void _checkDailyCompletionBonus() {
    final allDailiesDone = _quests.where((q) => q.isDaily).every((q) => q.isCompleted);
    if (allDailiesDone) {
      _profile.gold += 300;
      _addItem('blessed_box', 1);
      _addItem('full_recovery', 1);
      postSystemMessage(
        '[SYSTEM: DAILY QUEST COMPLETED]\n'
        'You have finished all daily training!\n'
        'Rewards: +300 Gold, 1x Blessed Random Box, 1x Status Recovery Potion!',
      );
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
    postSystemMessage('[SYSTEM] New Hunter Quest Registered: [${newQuest.title}]');
    saveState();
    notifyListeners();
  }

  void deleteQuest(String id) {
    _quests.removeWhere((q) => q.id == id);
    saveState();
    notifyListeners();
  }

  void resetDailyQuests() {
    for (var q in _quests) {
      if (q.isDaily) {
        q.current = 0;
        q.isCompleted = false;
      }
    }
    _profile.fatigue = max(0, _profile.fatigue - 30);
    postSystemMessage('[SYSTEM] Daily Quests have been refreshed for the day.');
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
      // Free Stat Points
      final points = 2 + rand.nextInt(3);
      _profile.statPoints += points;
      outcome = 'System Blessing: Received +$points Stat Points!';
    } else if (roll < 90) {
      // Potion
      _addItem('full_recovery', 2);
      outcome = 'Found 2x Status Recovery Potions!';
    } else {
      // Legendary Title
      if (!_profile.titles.contains('Monarch Candidate')) {
        _profile.titles.add('Monarch Candidate');
        _profile.title = 'Monarch Candidate';
        outcome = 'LEGENDARY BLESSING! Bestowed Title: [Monarch Candidate]!';
      } else {
        _profile.statPoints += 5;
        outcome = 'Great Blessing: Received +5 Stat Points!';
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
    super.dispose();
  }
}
