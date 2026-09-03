import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_flow/main.dart';
import 'package:habit_flow/models/quest_model.dart';
import 'package:habit_flow/services/system_state.dart';

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

  testWidgets('SoloLevelingHabitApp renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const SoloLevelingHabitApp());
    await tester.pumpAndSettle();

    expect(find.text('THE SYSTEM'), findsOneWidget);
    expect(find.text('DAILY QUEST: PREPARING TO BECOME STRONG'), findsOneWidget);
    expect(find.text('Push-ups'), findsOneWidget);
  });
}
