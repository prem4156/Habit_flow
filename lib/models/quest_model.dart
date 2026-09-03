enum StatType {
  str('STR', 'Strength'),
  agi('AGI', 'Agility'),
  vit('VIT', 'Vitality'),
  intl('INT', 'Intelligence'),
  per('PER', 'Perception');

  final String code;
  final String label;
  const StatType(this.code, this.label);

  static StatType fromCode(String code) {
    return StatType.values.firstWhere(
      (e) => e.code.toUpperCase() == code.toUpperCase(),
      orElse: () => StatType.str,
    );
  }
}

class Quest {
  final String id;
  String title;
  String description;
  int current;
  int target;
  String unit;
  StatType statReward;
  int expReward;
  int goldReward;
  bool isDaily;
  bool isCompleted;
  int streak;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    this.current = 0,
    required this.target,
    this.unit = 'reps',
    this.statReward = StatType.str,
    this.expReward = 50,
    this.goldReward = 50,
    this.isDaily = true,
    this.isCompleted = false,
    this.streak = 0,
  });

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'current': current,
    'target': target,
    'unit': unit,
    'statReward': statReward.code,
    'expReward': expReward,
    'goldReward': goldReward,
    'isDaily': isDaily,
    'isCompleted': isCompleted,
    'streak': streak,
  };

  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    current: json['current'] ?? 0,
    target: json['target'] ?? 1,
    unit: json['unit'] ?? 'reps',
    statReward: StatType.fromCode(json['statReward'] ?? 'STR'),
    expReward: json['expReward'] ?? 50,
    goldReward: json['goldReward'] ?? 50,
    isDaily: json['isDaily'] ?? true,
    isCompleted: json['isCompleted'] ?? false,
    streak: json['streak'] ?? 0,
  );

  static List<Quest> defaultSoloQuests() => [
    Quest(
      id: 'daily_pushups',
      title: 'Push-ups',
      description: 'Strengthen chest, arms and core to endure dungeon battles.',
      current: 0,
      target: 100,
      unit: 'reps',
      statReward: StatType.str,
      expReward: 60,
      goldReward: 50,
      isDaily: true,
    ),
    Quest(
      id: 'daily_situps',
      title: 'Curl-ups / Sit-ups',
      description: 'Solidify abdominal defense against monster impact.',
      current: 0,
      target: 100,
      unit: 'reps',
      statReward: StatType.vit,
      expReward: 60,
      goldReward: 50,
      isDaily: true,
    ),
    Quest(
      id: 'daily_squats',
      title: 'Squats',
      description: 'Build lower body explosiveness for high-speed dashes.',
      current: 0,
      target: 100,
      unit: 'reps',
      statReward: StatType.agi,
      expReward: 60,
      goldReward: 50,
      isDaily: true,
    ),
    Quest(
      id: 'daily_running',
      title: '10km Running',
      description: 'Expand lung capacity and limitless stamina.',
      current: 0,
      target: 10,
      unit: 'km',
      statReward: StatType.vit,
      expReward: 100,
      goldReward: 100,
      isDaily: true,
    ),
    Quest(
      id: 'custom_study',
      title: 'Focused Study / Coding',
      description: 'Sharpen cognitive faculties and master new techniques.',
      current: 0,
      target: 60,
      unit: 'mins',
      statReward: StatType.intl,
      expReward: 80,
      goldReward: 80,
      isDaily: true,
    ),
    Quest(
      id: 'custom_meditation',
      title: 'Meditation & Perception',
      description: 'Calm the mind to detect unseen murderous intent.',
      current: 0,
      target: 15,
      unit: 'mins',
      statReward: StatType.per,
      expReward: 50,
      goldReward: 40,
      isDaily: true,
    ),
  ];
}
