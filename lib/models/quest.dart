enum QuestStatus { locked, available, active, completed, rewardClaimed }

class Quest {
  final String id;
  final String title;
  final String description;
  final int chapter;
  final List<QuestObjective> objectives;
  final QuestReward reward;
  final QuestStatus status;
  final String? prerequisiteQuestId;
  final String? storyFlag;
  final bool hasCutscene;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.chapter,
    required this.objectives,
    required this.reward,
    this.status = QuestStatus.locked,
    this.prerequisiteQuestId,
    this.storyFlag,
    this.hasCutscene = false,
  });

  bool get isComplete =>
      objectives.every((obj) => obj.currentCount >= obj.requiredCount);

  double get progress {
    if (objectives.isEmpty) return 0;
    int totalRequired = 0;
    int totalCurrent = 0;
    for (final obj in objectives) {
      totalRequired += obj.requiredCount;
      totalCurrent += obj.currentCount.clamp(0, obj.requiredCount);
    }
    return totalRequired > 0 ? totalCurrent / totalRequired : 0;
  }

  Quest copyWith({
    String? id,
    String? title,
    String? description,
    int? chapter,
    List<QuestObjective>? objectives,
    QuestReward? reward,
    QuestStatus? status,
    String? prerequisiteQuestId,
    String? storyFlag,
    bool? hasCutscene,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      chapter: chapter ?? this.chapter,
      objectives: objectives ?? this.objectives,
      reward: reward ?? this.reward,
      status: status ?? this.status,
      prerequisiteQuestId: prerequisiteQuestId ?? this.prerequisiteQuestId,
      storyFlag: storyFlag ?? this.storyFlag,
      hasCutscene: hasCutscene ?? this.hasCutscene,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'chapter': chapter,
        'objectives': objectives.map((o) => o.toJson()).toList(),
        'reward': reward.toJson(),
        'status': status.index,
        'prerequisiteQuestId': prerequisiteQuestId,
        'storyFlag': storyFlag,
        'hasCutscene': hasCutscene,
      };

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      chapter: json['chapter'] ?? 1,
      objectives: (json['objectives'] as List?)
              ?.map((o) => QuestObjective.fromJson(o))
              .toList() ??
          [],
      reward: QuestReward.fromJson(json['reward'] ?? {}),
      status: QuestStatus.values[json['status'] ?? 0],
      prerequisiteQuestId: json['prerequisiteQuestId'],
      storyFlag: json['storyFlag'],
      hasCutscene: json['hasCutscene'] ?? false,
    );
  }
}

class QuestObjective {
  final String description;
  final int requiredCount;
  final int currentCount;
  final String type;
  final String? targetId;

  const QuestObjective({
    required this.description,
    required this.requiredCount,
    this.currentCount = 0,
    required this.type,
    this.targetId,
  });

  bool get isComplete => currentCount >= requiredCount;

  QuestObjective copyWith({
    String? description,
    int? requiredCount,
    int? currentCount,
    String? type,
    String? targetId,
  }) {
    return QuestObjective(
      description: description ?? this.description,
      requiredCount: requiredCount ?? this.requiredCount,
      currentCount: currentCount ?? this.currentCount,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'requiredCount': requiredCount,
        'currentCount': currentCount,
        'type': type,
        'targetId': targetId,
      };

  factory QuestObjective.fromJson(Map<String, dynamic> json) {
    return QuestObjective(
      description: json['description'] ?? '',
      requiredCount: json['requiredCount'] ?? 1,
      currentCount: json['currentCount'] ?? 0,
      type: json['type'] ?? '',
      targetId: json['targetId'],
    );
  }
}

class QuestReward {
  final int gold;
  final int xp;
  final List<String> items;
  final int talentPoints;
  final int rankingPoints;

  const QuestReward({
    this.gold = 0,
    this.xp = 0,
    this.items = const [],
    this.talentPoints = 0,
    this.rankingPoints = 0,
  });

  Map<String, dynamic> toJson() => {
        'gold': gold,
        'xp': xp,
        'items': items,
        'talentPoints': talentPoints,
        'rankingPoints': rankingPoints,
      };

  factory QuestReward.fromJson(Map<String, dynamic> json) {
    return QuestReward(
      gold: json['gold'] ?? 0,
      xp: json['xp'] ?? 0,
      items: List<String>.from(json['items'] ?? []),
      talentPoints: json['talentPoints'] ?? 0,
      rankingPoints: json['rankingPoints'] ?? 0,
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementReward reward;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    this.isUnlocked = false,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    AchievementReward? reward,
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reward: reward ?? this.reward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'reward': reward.toJson(),
        'isUnlocked': isUnlocked,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      reward: AchievementReward.fromJson(json['reward'] ?? {}),
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }
}

class AchievementReward {
  final int gold;
  final List<String> items;
  final int talentPoints;

  const AchievementReward({
    this.gold = 0,
    this.items = const [],
    this.talentPoints = 0,
  });

  Map<String, dynamic> toJson() => {
        'gold': gold,
        'items': items,
        'talentPoints': talentPoints,
      };

  factory AchievementReward.fromJson(Map<String, dynamic> json) {
    return AchievementReward(
      gold: json['gold'] ?? 0,
      items: List<String>.from(json['items'] ?? []),
      talentPoints: json['talentPoints'] ?? 0,
    );
  }
}

class QuestDatabase {
  static const List<Quest> defaultQuests = [
    // Chapter 1
    Quest(
      id: 'quest_awakening',
      title: 'The Awakening',
      description:
          'Speak with the Herald to learn about the darkness threatening the realm.',
      chapter: 1,
      objectives: [
        QuestObjective(
          description: 'Talk to the Herald',
          requiredCount: 1,
          type: 'talk',
          targetId: 'herald',
        ),
      ],
      reward: QuestReward(gold: 25, xp: 50),
      status: QuestStatus.available,
      storyFlag: 'metHerald',
    ),
    Quest(
      id: 'quest_proving_ground',
      title: 'Proving Ground',
      description: 'Defeat enemies to prove your worth as an adventurer.',
      chapter: 1,
      objectives: [
        QuestObjective(
          description: 'Defeat 5 enemies',
          requiredCount: 5,
          type: 'kill',
        ),
      ],
      reward: QuestReward(gold: 50, xp: 100, items: ['potion_health']),
      status: QuestStatus.available,
    ),

    // Chapter 2
    Quest(
      id: 'quest_dark_secrets',
      title: 'Dark Secrets',
      description: 'Search the dungeons for hidden treasures.',
      chapter: 2,
      objectives: [
        QuestObjective(
          description: 'Open 2 chests',
          requiredCount: 2,
          type: 'open_chest',
        ),
      ],
      reward: QuestReward(gold: 75, xp: 150),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'quest_proving_ground',
    ),
    Quest(
      id: 'quest_warlord_threat',
      title: "The Warlord's Threat",
      description: 'The Orc Warlord threatens the realm. Defeat him!',
      chapter: 2,
      objectives: [
        QuestObjective(
          description: 'Defeat the Orc Warlord',
          requiredCount: 1,
          type: 'kill_boss',
          targetId: 'orc_warlord',
        ),
      ],
      reward: QuestReward(
        gold: 200,
        xp: 500,
        items: ['ring_power'],
        rankingPoints: 100,
      ),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'quest_dark_secrets',
      hasCutscene: true,
    ),

    // Chapter 3
    Quest(
      id: 'quest_into_abyss',
      title: 'Into the Abyss',
      description: 'Venture deeper into the dungeon to floor 3.',
      chapter: 3,
      objectives: [
        QuestObjective(
          description: 'Reach Floor 3',
          requiredCount: 1,
          type: 'reach_floor',
          targetId: 'floor_3',
        ),
      ],
      reward: QuestReward(gold: 150, xp: 300, rankingPoints: 150),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'quest_warlord_threat',
      storyFlag: 'acceptedChapelQuest',
    ),
    Quest(
      id: 'quest_infernal_gate',
      title: 'The Infernal Gate',
      description: 'Defeat the Infernal Warden to seal the demonic portal.',
      chapter: 3,
      objectives: [
        QuestObjective(
          description: 'Defeat the Infernal Warden',
          requiredCount: 1,
          type: 'kill_boss',
          targetId: 'infernal_warden',
        ),
      ],
      reward: QuestReward(
        gold: 500,
        xp: 1000,
        items: ['infernal_core'],
        talentPoints: 1,
        rankingPoints: 300,
      ),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'quest_into_abyss',
      hasCutscene: true,
      storyFlag: 'defeatedWarden',
    ),
  ];

  static const List<Achievement> defaultAchievements = [
    Achievement(
      id: 'cleared_floor_1',
      title: 'Dungeon Delver',
      description: 'Clear all enemies on Floor 1.',
      reward: AchievementReward(gold: 100),
    ),
    Achievement(
      id: 'cleared_floor_2',
      title: 'Deep Explorer',
      description: 'Clear all enemies on Floor 2.',
      reward: AchievementReward(gold: 250),
    ),
    Achievement(
      id: 'shadow_lord_defeated',
      title: 'Shadow Slayer',
      description: 'Defeat the Shadow Lord.',
      reward: AchievementReward(gold: 500, items: ['potion_health_greater']),
    ),
    Achievement(
      id: 'crypt_key_obtained',
      title: 'Key Master',
      description: 'Obtain the Caldera Key.',
      reward: AchievementReward(gold: 150),
    ),
    Achievement(
      id: 'ruins_unlock',
      title: 'Archaeologist',
      description: 'Unlock the Arcane Ruins.',
      reward: AchievementReward(gold: 200, talentPoints: 1),
    ),
    Achievement(
      id: 'lore_goblin_orders',
      title: 'Lorekeeper: Goblin Orders',
      description: 'Discover the goblin battle plans.',
      reward: AchievementReward(gold: 50),
    ),
    Achievement(
      id: 'first_boss_kill',
      title: 'Boss Hunter',
      description: 'Defeat your first boss enemy.',
      reward: AchievementReward(gold: 100, items: ['potion_health']),
    ),
    Achievement(
      id: 'max_level',
      title: 'Legendary Hero',
      description: 'Reach maximum level.',
      reward: AchievementReward(talentPoints: 3),
    ),
  ];
}
