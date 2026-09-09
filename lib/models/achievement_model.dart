enum AchievementTier { bronze, silver, gold, legendary }

class Achievement {
  final String id;
  final String title;
  final String badge;
  final String description;
  final String rewardDescription;
  bool isUnlocked;
  DateTime? unlockedAt;
  int currentProgress;
  final int maxProgress;
  final int expReward;
  final int goldReward;
  final String? titleReward;
  final AchievementTier tier;

  Achievement({
    required this.id,
    required this.title,
    required this.badge,
    required this.description,
    required this.rewardDescription,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
    required this.maxProgress,
    this.expReward = 100,
    this.goldReward = 200,
    this.titleReward,
    this.tier = AchievementTier.silver,
  });

  double get progress =>
      maxProgress > 0 ? (currentProgress / maxProgress).clamp(0.0, 1.0) : 0.0;

  Achievement copyWith({
    String? id,
    String? title,
    String? badge,
    String? description,
    String? rewardDescription,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
    int? maxProgress,
    int? expReward,
    int? goldReward,
    String? titleReward,
    AchievementTier? tier,
  }) =>
      Achievement(
        id: id ?? this.id,
        title: title ?? this.title,
        badge: badge ?? this.badge,
        description: description ?? this.description,
        rewardDescription: rewardDescription ?? this.rewardDescription,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedAt: unlockedAt ?? this.unlockedAt,
        currentProgress: currentProgress ?? this.currentProgress,
        maxProgress: maxProgress ?? this.maxProgress,
        expReward: expReward ?? this.expReward,
        goldReward: goldReward ?? this.goldReward,
        titleReward: titleReward ?? this.titleReward,
        tier: tier ?? this.tier,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'badge': badge,
    'description': description,
    'rewardDescription': rewardDescription,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'currentProgress': currentProgress,
    'maxProgress': maxProgress,
    'expReward': expReward,
    'goldReward': goldReward,
    'titleReward': titleReward,
    'tier': tier.name,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    badge: json['badge'] ?? '🏅',
    description: json['description'] ?? '',
    rewardDescription: json['rewardDescription'] ?? '',
    isUnlocked: json['isUnlocked'] ?? false,
    unlockedAt: json['unlockedAt'] != null
        ? DateTime.tryParse(json['unlockedAt'])
        : null,
    currentProgress: json['currentProgress'] ?? 0,
    maxProgress: json['maxProgress'] ?? 1,
    expReward: json['expReward'] ?? 100,
    goldReward: json['goldReward'] ?? 200,
    titleReward: json['titleReward'],
    tier: AchievementTier.values.firstWhere(
      (t) => t.name == (json['tier'] ?? 'silver'),
      orElse: () => AchievementTier.silver,
    ),
  );

  static List<Achievement> defaultAchievements() => [
    Achievement(
      id: 'first_awakening',
      title: 'FIRST AWAKENING',
      badge: '⚡',
      description: 'Complete your very first quest and awaken as a Hunter.',
      rewardDescription: '+150 EXP, +100 Gold',
      maxProgress: 1,
      expReward: 150,
      goldReward: 100,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'iron_discipline',
      title: 'IRON DISCIPLINE',
      badge: '⚔️',
      description: 'Complete 10 total daily quests across any number of days.',
      rewardDescription: '+200 EXP, +250 Gold',
      maxProgress: 10,
      expReward: 200,
      goldReward: 250,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'perfect_regimen',
      title: 'PERFECT REGIMEN',
      badge: '🛡️',
      description: 'Complete 100% of daily quests in a single day.',
      rewardDescription: '+250 EXP, +300 Gold',
      maxProgress: 1,
      expReward: 250,
      goldReward: 300,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'the_unbroken',
      title: 'THE UNBROKEN',
      badge: '🏆',
      description: 'Complete all daily quests for 7 consecutive days.',
      rewardDescription: '+500 EXP, +500 Gold, Title: The Unbroken',
      maxProgress: 7,
      expReward: 500,
      goldReward: 500,
      titleReward: 'The Unbroken',
      tier: AchievementTier.legendary,
    ),
    Achievement(
      id: 'deadly_monarch',
      title: 'DEADLY EXECUTIONER',
      badge: '⚔️',
      description: 'Execute 25 tasks with flawless deadly precision.',
      rewardDescription: '+350 EXP, +300 Gold, Title: Executioner',
      maxProgress: 25,
      expReward: 350,
      goldReward: 300,
      titleReward: 'Executioner',
      tier: AchievementTier.gold,
    ),
    Achievement(
      id: 'monarch_will',
      title: "MONARCH'S WILL",
      badge: '👑',
      description: 'Reach Hunter Level 5 through sheer determination.',
      rewardDescription: "+300 EXP, +400 Gold, Title: Monarch's Will",
      maxProgress: 5,
      expReward: 300,
      goldReward: 400,
      titleReward: "Monarch's Will",
      tier: AchievementTier.gold,
    ),
    Achievement(
      id: 'eleventh_hour',
      title: 'ELEVENTH HOUR',
      badge: '⏳',
      description: 'Complete an Emergency Quest before the 23:59 deadline.',
      rewardDescription: '+300 EXP',
      maxProgress: 1,
      expReward: 300,
      goldReward: 0,
      tier: AchievementTier.gold,
    ),
    Achievement(
      id: 'disciplined',
      title: 'DISCIPLINED',
      badge: '🔥',
      description: 'Maintain a 14-day consecutive perfect streak.',
      rewardDescription: '+600 EXP, Title: The Disciplined',
      maxProgress: 14,
      expReward: 600,
      goldReward: 0,
      titleReward: 'The Disciplined',
      tier: AchievementTier.legendary,
    ),
    Achievement(
      id: 'first_ascension',
      title: 'FIRST ASCENSION',
      badge: '🌟',
      description: 'Reach Hunter Level 10 and prove your ascension.',
      rewardDescription: '+400 EXP, Title: Ascended',
      maxProgress: 10,
      expReward: 400,
      goldReward: 0,
      titleReward: 'Ascended',
      tier: AchievementTier.gold,
    ),
    Achievement(
      id: 'system_user',
      title: 'SYSTEM USER',
      badge: '⚙️',
      description: 'Complete 100 total quests across all time.',
      rewardDescription: '+500 EXP, Title: System Veteran',
      maxProgress: 100,
      expReward: 500,
      goldReward: 0,
      titleReward: 'System Veteran',
      tier: AchievementTier.legendary,
    ),
  ];
}
