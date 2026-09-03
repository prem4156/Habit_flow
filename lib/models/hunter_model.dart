enum HunterRank {
  rankE('E-Rank', 'Weakest Hunter of All Mankind'),
  rankD('D-Rank', 'Novice Dungeon Delver'),
  rankC('C-Rank', 'Competent Hunter'),
  rankB('B-Rank', 'Elite Vanguard'),
  rankA('A-Rank', 'High-Tier Specialist'),
  rankS('S-Rank', 'Apex Hunter'),
  rankNational('National Level', 'One Man Army');

  final String label;
  final String description;
  const HunterRank(this.label, this.description);

  static HunterRank fromLevel(int level) {
    if (level < 5) return HunterRank.rankE;
    if (level < 15) return HunterRank.rankD;
    if (level < 30) return HunterRank.rankC;
    if (level < 50) return HunterRank.rankB;
    if (level < 75) return HunterRank.rankA;
    if (level < 100) return HunterRank.rankS;
    return HunterRank.rankNational;
  }
}

class HunterStats {
  int strength;
  int agility;
  int vitality;
  int intelligence;
  int perception;

  HunterStats({
    this.strength = 10,
    this.agility = 10,
    this.vitality = 10,
    this.intelligence = 10,
    this.perception = 10,
  });

  Map<String, dynamic> toJson() => {
    'strength': strength,
    'agility': agility,
    'vitality': vitality,
    'intelligence': intelligence,
    'perception': perception,
  };

  factory HunterStats.fromJson(Map<String, dynamic> json) => HunterStats(
    strength: json['strength'] ?? 10,
    agility: json['agility'] ?? 10,
    vitality: json['vitality'] ?? 10,
    intelligence: json['intelligence'] ?? 10,
    perception: json['perception'] ?? 10,
  );
}

class HunterProfile {
  String name;
  String title;
  String job;
  int level;
  int exp;
  int fatigue;
  int gold;
  int statPoints;
  HunterStats stats;
  List<String> titles;

  HunterProfile({
    this.name = 'Sung Jin-Woo',
    this.title = 'The Re-Awakened',
    this.job = 'None',
    this.level = 1,
    this.exp = 0,
    this.fatigue = 0,
    this.gold = 500,
    this.statPoints = 5,
    HunterStats? stats,
    List<String>? titles,
  })  : stats = stats ?? HunterStats(),
        titles = titles ?? ['The Re-Awakened', 'Wolf Slayer', 'Shadow Monarch Candidate'];

  HunterRank get rank => HunterRank.fromLevel(level);

  int get maxExp => 100 + (level - 1) * 75;
  int get maxHp => 100 + (stats.vitality * 15);
  int get currentHp => (maxHp * (1.0 - (fatigue / 120))).clamp(10, maxHp).toInt();
  int get maxMp => 50 + (stats.intelligence * 12);
  int get currentMp => (maxMp * 0.95).toInt();

  Map<String, dynamic> toJson() => {
    'name': name,
    'title': title,
    'job': job,
    'level': level,
    'exp': exp,
    'fatigue': fatigue,
    'gold': gold,
    'statPoints': statPoints,
    'stats': stats.toJson(),
    'titles': titles,
  };

  factory HunterProfile.fromJson(Map<String, dynamic> json) => HunterProfile(
    name: json['name'] ?? 'Sung Jin-Woo',
    title: json['title'] ?? 'The Re-Awakened',
    job: json['job'] ?? 'None',
    level: json['level'] ?? 1,
    exp: json['exp'] ?? 0,
    fatigue: json['fatigue'] ?? 0,
    gold: json['gold'] ?? 500,
    statPoints: json['statPoints'] ?? 5,
    stats: json['stats'] != null ? HunterStats.fromJson(json['stats']) : HunterStats(),
    titles: json['titles'] != null ? List<String>.from(json['titles']) : null,
  );

  static HunterProfile defaultProfile() => HunterProfile();
}
