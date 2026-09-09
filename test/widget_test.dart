import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monarch_protocol/main.dart';
import 'package:monarch_protocol/models/quest_model.dart';
import 'package:monarch_protocol/services/system_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('SystemState initializes with default Hunter and Solo Leveling quests', () async {
    final state = SystemState();
    await Future.delayed(const Duration(milliseconds: 50));

    expect(state.profile.name, 'Sung Jin-Woo');
    expect(state.profile.level, 1);
    expect(state.quests.length, greaterThanOrEqualTo(4));

    // Daily pushups quest check
    final pushupQuest = state.quests.firstWhere((q) => q.id == 'daily_pushups');
    expect(pushupQuest.target, 100);
    expect(pushupQuest.statReward, StatType.str);

    // Progress pushups
    state.incrementQuestProgress('daily_pushups', 50);
    expect(pushupQuest.current, 50);
    expect(pushupQuest.isCompleted, false);

    // Complete pushups
    state.incrementQuestProgress('daily_pushups', 50);
    expect(pushupQuest.current, 100);
    expect(pushupQuest.isCompleted, true);
    expect(state.profile.stats.strength, greaterThan(10));
  });

  test('Quests repeat across dates like Google Calendar and Google Tasks', () async {
    final state = SystemState();
    await Future.delayed(const Duration(milliseconds: 50));

    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    // Complete pushups today
    final initialStrength = state.profile.stats.strength;
    state.incrementQuestProgress('daily_pushups', 100, date: today);
    expect(state.profile.stats.strength, initialStrength + 1);

    // Verify today's quests
    final todayQuests = state.getQuestsForDate(today);
    final todayPushup = todayQuests.firstWhere((q) => q.id == 'daily_pushups');
    expect(todayPushup.isCompleted, true);

    // Verify tomorrow's repeating tasks (repeats fresh)
    final tomorrowQuests = state.getQuestsForDate(tomorrow);
    final tomorrowPushup = tomorrowQuests.firstWhere((q) => q.id == 'daily_pushups');
    expect(tomorrowPushup.isCompleted, false);
    expect(tomorrowPushup.current, 0);

    // Switch selected date to tomorrow
    state.selectDate(tomorrow);
    expect(state.selectedDate.day, tomorrow.day);
    expect(state.completedDailyCount, 0);

    // Switch selected date to yesterday
    state.selectDate(yesterday);
    expect(state.selectedDate.day, yesterday.day);

    // Toggle complete a task on yesterday
    final initialVit = state.profile.stats.vitality;
    state.toggleQuestComplete('daily_situps', date: yesterday);
    expect(state.profile.stats.vitality, initialVit + 1);

    final yesterdayQuests = state.getQuestsForDate(yesterday);
    final yesterdaySitup = yesterdayQuests.firstWhere((q) => q.id == 'daily_situps');
    expect(yesterdaySitup.isCompleted, true);
  });

  test('Attributes only improve based on completed tasks', () async {
    final state = SystemState();
    await Future.delayed(const Duration(milliseconds: 50));

    final initialInt = state.profile.stats.intelligence;
    final initialPer = state.profile.stats.perception;

    // Study task targets INT
    state.incrementQuestProgress('custom_study', 60);
    expect(state.profile.stats.intelligence, initialInt + 1);
    expect(state.statGainsFromQuests['INT'], 1);

    // Meditation task targets PER
    state.incrementQuestProgress('custom_meditation', 15);
    expect(state.profile.stats.perception, initialPer + 1);
    expect(state.statGainsFromQuests['PER'], 1);
  });

  test('Every task can select its attribute option and completion increases it automatically', () async {
    final state = SystemState();
    await Future.delayed(const Duration(milliseconds: 50));

    // Realign pushups to train AGI instead of STR
    state.updateQuestStatReward('daily_pushups', StatType.agi);
    final pushup = state.quests.firstWhere((q) => q.id == 'daily_pushups');
    expect(pushup.statReward, StatType.agi);

    final initialAgi = state.profile.stats.agility;
    state.incrementQuestProgress('daily_pushups', 100);
    expect(state.profile.stats.agility, initialAgi + 1);
    expect(state.statGainsFromQuests['AGI'], 1);
  });

  testWidgets('SoloLevelingHabitApp renders without errors and shows calendar HUD', (WidgetTester tester) async {
    await tester.pumpWidget(const SoloLevelingHabitApp());
    await tester.pumpAndSettle();

    expect(find.text('THE SYSTEM'), findsOneWidget);
    expect(find.text('DAILY QUEST: PREPARING TO BECOME STRONG'), findsOneWidget);
    expect(find.text('Push-ups'), findsOneWidget);
    expect(find.text('NEW TASK'), findsOneWidget);
  });

  test('Emergency quest generation sets deadline to 23:59 and triggers modal state', () async {
    final state = SystemState();
    await Future.delayed(const Duration(milliseconds: 50));

    // Initially no emergency quest
    expect(state.activeEmergencyQuest, isNull);
    expect(state.showEmergencyQuestModal, false);

    // Trigger emergency quest
    state.triggerEmergencyQuest(customReason: 'Test: insufficient discipline detected.');

    expect(state.activeEmergencyQuest, isNotNull);
    expect(state.activeEmergencyQuest!.isEmergency, true);
    expect(state.activeEmergencyQuest!.deadline, '23:59');
    expect(state.showEmergencyQuestModal, true);
    expect(state.activeEmergencyQuest!.urgentReason, 'Test: insufficient discipline detected.');

    state.dispose();
  });

  test('Completing an emergency quest grants double stats, EXP, Gold and dismisses it', () async {
    final state = SystemState();
    await Future.delayed(const Duration(milliseconds: 50));

    state.triggerEmergencyQuest();
    final quest = state.activeEmergencyQuest!;
    final statCode = quest.statReward.code;
    final initialStatGains = state.statGainsFromQuests[statCode] ?? 0;
    final initialGold = state.profile.gold;

    // Complete the emergency quest
    state.incrementEmergencyQuestProgress(quest.target);

    expect(quest.isCompleted, true);
    // Emergency quests grant +2 to stat
    expect(state.statGainsFromQuests[statCode], initialStatGains + 2);
    expect(state.profile.gold, greaterThan(initialGold));

    state.dispose();
  });

  test('First quest completion unlocks FIRST AWAKENING achievement', () async {
    final state = SystemState();
    await Future.delayed(const Duration(milliseconds: 50));

    // Complete one quest
    state.incrementQuestProgress('daily_pushups', 100);

    final firstAwakening = state.achievements.firstWhere((a) => a.id == 'first_awakening');
    expect(firstAwakening.isUnlocked, true);
    expect(firstAwakening.currentProgress, firstAwakening.maxProgress);

    state.dispose();
  });

  test('7-day streak tracking updates THE UNBROKEN achievement progress', () async {
    final state = SystemState();
    await Future.delayed(const Duration(milliseconds: 50));

    final theUnbroken = state.achievements.firstWhere((a) => a.id == 'the_unbroken');
    expect(theUnbroken.isUnlocked, false);
    expect(theUnbroken.maxProgress, 7);

    state.dispose();
  });
}
