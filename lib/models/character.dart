import 'dart:math' as math;

enum CharacterClass { fighter, wizard, rogue, cleric }

enum EquipmentSlot {
  weapon,
  head,
  shoulders,
  chest,
  legs,
  necklace,
  gloves,
  belt,
  ring1,
  ring2,
  bracers,
  cloak,
}

class AbilityScores {
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  const AbilityScores({
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
  });

  int getModifier(int score) => (score - 10) ~/ 2;

  int get strMod => getModifier(strength);
  int get dexMod => getModifier(dexterity);
  int get conMod => getModifier(constitution);
  int get intMod => getModifier(intelligence);
  int get wisMod => getModifier(wisdom);
  int get chaMod => getModifier(charisma);

  AbilityScores copyWith({
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
  }) {
    return AbilityScores(
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
    );
  }

  Map<String, dynamic> toJson() => {
        'strength': strength,
        'dexterity': dexterity,
        'constitution': constitution,
        'intelligence': intelligence,
        'wisdom': wisdom,
        'charisma': charisma,
      };

  factory AbilityScores.fromJson(Map<String, dynamic> json) => AbilityScores(
        strength: json['strength'] ?? 10,
        dexterity: json['dexterity'] ?? 10,
        constitution: json['constitution'] ?? 10,
        intelligence: json['intelligence'] ?? 10,
        wisdom: json['wisdom'] ?? 10,
        charisma: json['charisma'] ?? 10,
      );
}

class SpellSlots {
  final int level1;
  final int level2;
  final int level3;
  final int level1Max;
  final int level2Max;
  final int level3Max;

  const SpellSlots({
    this.level1 = 0,
    this.level2 = 0,
    this.level3 = 0,
    this.level1Max = 0,
    this.level2Max = 0,
    this.level3Max = 0,
  });

  SpellSlots copyWith({
    int? level1,
    int? level2,
    int? level3,
    int? level1Max,
    int? level2Max,
    int? level3Max,
  }) {
    return SpellSlots(
      level1: level1 ?? this.level1,
      level2: level2 ?? this.level2,
      level3: level3 ?? this.level3,
      level1Max: level1Max ?? this.level1Max,
      level2Max: level2Max ?? this.level2Max,
      level3Max: level3Max ?? this.level3Max,
    );
  }

  bool get hasSlots => level1 > 0 || level2 > 0 || level3 > 0;

  SpellSlots restoreAll() => SpellSlots(
        level1: level1Max,
        level2: level2Max,
        level3: level3Max,
        level1Max: level1Max,
        level2Max: level2Max,
        level3Max: level3Max,
      );

  Map<String, dynamic> toJson() => {
        'level1': level1,
        'level2': level2,
        'level3': level3,
        'level1Max': level1Max,
        'level2Max': level2Max,
        'level3Max': level3Max,
      };

  factory SpellSlots.fromJson(Map<String, dynamic> json) => SpellSlots(
        level1: json['level1'] ?? 0,
        level2: json['level2'] ?? 0,
        level3: json['level3'] ?? 0,
        level1Max: json['level1Max'] ?? 0,
        level2Max: json['level2Max'] ?? 0,
        level3Max: json['level3Max'] ?? 0,
      );
}

class TalentTree {
  final int attackBonus;
  final int acBonus;
  final int damageBonus;
  final int spellSlotBonus;
  final int hpBonus;
  final int pointsSpent;
  final int pointsAvailable;

  const TalentTree({
    this.attackBonus = 0,
    this.acBonus = 0,
    this.damageBonus = 0,
    this.spellSlotBonus = 0,
    this.hpBonus = 0,
    this.pointsSpent = 0,
    this.pointsAvailable = 0,
  });

  TalentTree copyWith({
    int? attackBonus,
    int? acBonus,
    int? damageBonus,
    int? spellSlotBonus,
    int? hpBonus,
    int? pointsSpent,
    int? pointsAvailable,
  }) {
    return TalentTree(
      attackBonus: attackBonus ?? this.attackBonus,
      acBonus: acBonus ?? this.acBonus,
      damageBonus: damageBonus ?? this.damageBonus,
      spellSlotBonus: spellSlotBonus ?? this.spellSlotBonus,
      hpBonus: hpBonus ?? this.hpBonus,
      pointsSpent: pointsSpent ?? this.pointsSpent,
      pointsAvailable: pointsAvailable ?? this.pointsAvailable,
    );
  }

  Map<String, dynamic> toJson() => {
        'attackBonus': attackBonus,
        'acBonus': acBonus,
        'damageBonus': damageBonus,
        'spellSlotBonus': spellSlotBonus,
        'hpBonus': hpBonus,
        'pointsSpent': pointsSpent,
        'pointsAvailable': pointsAvailable,
      };

  factory TalentTree.fromJson(Map<String, dynamic> json) => TalentTree(
        attackBonus: json['attackBonus'] ?? 0,
        acBonus: json['acBonus'] ?? 0,
        damageBonus: json['damageBonus'] ?? 0,
        spellSlotBonus: json['spellSlotBonus'] ?? 0,
        hpBonus: json['hpBonus'] ?? 0,
        pointsSpent: json['pointsSpent'] ?? 0,
        pointsAvailable: json['pointsAvailable'] ?? 0,
      );
}

class ClassDefinition {
  final CharacterClass characterClass;
  final String name;
  final String description;
  final String hitDie;
  final int baseAC;
  final int baseHP;
  final AbilityScores baseStats;
  final SpellSlots startingSpellSlots;
  final bool isCaster;
  final String primaryStat;
  final List<String> startingAbilities;

  const ClassDefinition({
    required this.characterClass,
    required this.name,
    required this.description,
    required this.hitDie,
    required this.baseAC,
    required this.baseHP,
    required this.baseStats,
    required this.startingSpellSlots,
    required this.isCaster,
    required this.primaryStat,
    required this.startingAbilities,
  });

  static const List<ClassDefinition> allClasses = [
    ClassDefinition(
      characterClass: CharacterClass.fighter,
      name: 'Fighter',
      description:
          'Masters of martial combat, skilled with a variety of weapons and armor. Fighters excel at dealing and taking damage.',
      hitDie: '1d10',
      baseAC: 16,
      baseHP: 12,
      baseStats: AbilityScores(
        strength: 16,
        dexterity: 14,
        constitution: 15,
        intelligence: 10,
        wisdom: 12,
        charisma: 8,
      ),
      startingSpellSlots: SpellSlots(),
      isCaster: false,
      primaryStat: 'Strength',
      startingAbilities: ['Strike', 'Power Attack', 'Defend'],
    ),
    ClassDefinition(
      characterClass: CharacterClass.wizard,
      name: 'Wizard',
      description:
          'Scholarly magic-users capable of manipulating the structures of reality. Wizards wield devastating arcane power.',
      hitDie: '1d6',
      baseAC: 11,
      baseHP: 8,
      baseStats: AbilityScores(
        strength: 8,
        dexterity: 14,
        constitution: 12,
        intelligence: 17,
        wisdom: 13,
        charisma: 10,
      ),
      startingSpellSlots: SpellSlots(
        level1: 3,
        level1Max: 3,
        level2: 1,
        level2Max: 1,
      ),
      isCaster: true,
      primaryStat: 'Intelligence',
      startingAbilities: ['Staff Strike', 'Fireball', 'Frost Ray', 'Shield'],
    ),
    ClassDefinition(
      characterClass: CharacterClass.rogue,
      name: 'Rogue',
      description:
          'Skilled tricksters who use stealth and cunning to overcome obstacles. Rogues excel at precision strikes.',
      hitDie: '1d8',
      baseAC: 14,
      baseHP: 10,
      baseStats: AbilityScores(
        strength: 10,
        dexterity: 17,
        constitution: 12,
        intelligence: 14,
        wisdom: 10,
        charisma: 13,
      ),
      startingSpellSlots: SpellSlots(),
      isCaster: false,
      primaryStat: 'Dexterity',
      startingAbilities: ['Stab', 'Sneak Attack', 'Evade', 'Poison Blade'],
    ),
    ClassDefinition(
      characterClass: CharacterClass.cleric,
      name: 'Cleric',
      description:
          'Divine spellcasters who channel the power of their deity. Clerics can heal allies and smite foes.',
      hitDie: '1d8',
      baseAC: 15,
      baseHP: 10,
      baseStats: AbilityScores(
        strength: 14,
        dexterity: 10,
        constitution: 14,
        intelligence: 10,
        wisdom: 16,
        charisma: 12,
      ),
      startingSpellSlots: SpellSlots(
        level1: 2,
        level1Max: 2,
        level2: 1,
        level2Max: 1,
      ),
      isCaster: true,
      primaryStat: 'Wisdom',
      startingAbilities: ['Mace Strike', 'Heal', 'Holy Smite', 'Bless'],
    ),
  ];
}

class Character {
  final String id;
  final String name;
  final CharacterClass characterClass;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int hp;
  final int maxHp;
  final int ac;
  final int gold;
  final AbilityScores abilityScores;
  final SpellSlots spellSlots;
  final TalentTree talents;
  final Map<EquipmentSlot, String?> equipment;
  final List<String> inventory;
  final int inventoryMaxSlots;
  final int rankingPoints;
  final String rankTier;

  Character({
    required this.id,
    required this.name,
    required this.characterClass,
    this.level = 1,
    this.xp = 0,
    this.xpToNextLevel = 100,
    required this.hp,
    required this.maxHp,
    required this.ac,
    this.gold = 50,
    required this.abilityScores,
    required this.spellSlots,
    this.talents = const TalentTree(),
    Map<EquipmentSlot, String?>? equipment,
    List<String>? inventory,
    this.inventoryMaxSlots = 20,
    this.rankingPoints = 0,
    this.rankTier = 'Bronze',
  })  : equipment = equipment ?? {},
        inventory = inventory ?? [];

  factory Character.fromClass(ClassDefinition classDef, String name) {
    return Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      characterClass: classDef.characterClass,
      hp: classDef.baseHP,
      maxHp: classDef.baseHP,
      ac: classDef.baseAC,
      abilityScores: classDef.baseStats,
      spellSlots: classDef.startingSpellSlots,
    );
  }

  String get className {
    switch (characterClass) {
      case CharacterClass.fighter:
        return 'Fighter';
      case CharacterClass.wizard:
        return 'Wizard';
      case CharacterClass.rogue:
        return 'Rogue';
      case CharacterClass.cleric:
        return 'Cleric';
    }
  }

  int get attackBonus {
    int base = level;
    switch (characterClass) {
      case CharacterClass.fighter:
        base += abilityScores.strMod + 2;
        break;
      case CharacterClass.wizard:
        base += abilityScores.intMod;
        break;
      case CharacterClass.rogue:
        base += abilityScores.dexMod + 1;
        break;
      case CharacterClass.cleric:
        base += abilityScores.wisMod + 1;
        break;
    }
    return base + talents.attackBonus;
  }

  int get damageBonus {
    int base = 0;
    switch (characterClass) {
      case CharacterClass.fighter:
        base = abilityScores.strMod + 1;
        break;
      case CharacterClass.wizard:
        base = abilityScores.intMod;
        break;
      case CharacterClass.rogue:
        base = abilityScores.dexMod;
        break;
      case CharacterClass.cleric:
        base = abilityScores.wisMod;
        break;
    }
    return base + talents.damageBonus;
  }

  int get totalAC => ac + talents.acBonus;

  int get totalMaxHp => maxHp + talents.hpBonus + (abilityScores.conMod * level);

  double get hpPercentage => hp / totalMaxHp;

  double get xpPercentage => xp / xpToNextLevel;

  static String calculateRankTier(int points) {
    if (points >= 10000) return 'Mythic';
    if (points >= 5000) return 'Platinum';
    if (points >= 2000) return 'Gold';
    if (points >= 500) return 'Silver';
    return 'Bronze';
  }

  int rollDamage(String diceString) {
    final regex = RegExp(r'(\d+)d(\d+)(?:\+(\d+))?');
    final match = regex.firstMatch(diceString);
    if (match == null) return 1;

    final numDice = int.parse(match.group(1)!);
    final dieSize = int.parse(match.group(2)!);
    final bonus = match.group(3) != null ? int.parse(match.group(3)!) : 0;

    final random = math.Random();
    int total = bonus;
    for (int i = 0; i < numDice; i++) {
      total += random.nextInt(dieSize) + 1;
    }
    return total + damageBonus;
  }

  Character copyWith({
    String? id,
    String? name,
    CharacterClass? characterClass,
    int? level,
    int? xp,
    int? xpToNextLevel,
    int? hp,
    int? maxHp,
    int? ac,
    int? gold,
    AbilityScores? abilityScores,
    SpellSlots? spellSlots,
    TalentTree? talents,
    Map<EquipmentSlot, String?>? equipment,
    List<String>? inventory,
    int? inventoryMaxSlots,
    int? rankingPoints,
    String? rankTier,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      characterClass: characterClass ?? this.characterClass,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      ac: ac ?? this.ac,
      gold: gold ?? this.gold,
      abilityScores: abilityScores ?? this.abilityScores,
      spellSlots: spellSlots ?? this.spellSlots,
      talents: talents ?? this.talents,
      equipment: equipment ?? Map.from(this.equipment),
      inventory: inventory ?? List.from(this.inventory),
      inventoryMaxSlots: inventoryMaxSlots ?? this.inventoryMaxSlots,
      rankingPoints: rankingPoints ?? this.rankingPoints,
      rankTier: rankTier ?? this.rankTier,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'characterClass': characterClass.index,
        'level': level,
        'xp': xp,
        'xpToNextLevel': xpToNextLevel,
        'hp': hp,
        'maxHp': maxHp,
        'ac': ac,
        'gold': gold,
        'abilityScores': abilityScores.toJson(),
        'spellSlots': spellSlots.toJson(),
        'talents': talents.toJson(),
        'equipment': equipment.map((k, v) => MapEntry(k.index.toString(), v)),
        'inventory': inventory,
        'inventoryMaxSlots': inventoryMaxSlots,
        'rankingPoints': rankingPoints,
        'rankTier': rankTier,
      };

  factory Character.fromJson(Map<String, dynamic> json) {
    final equipMap = <EquipmentSlot, String?>{};
    if (json['equipment'] != null) {
      (json['equipment'] as Map<String, dynamic>).forEach((k, v) {
        equipMap[EquipmentSlot.values[int.parse(k)]] = v as String?;
      });
    }

    return Character(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Hero',
      characterClass: CharacterClass.values[json['characterClass'] ?? 0],
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      xpToNextLevel: json['xpToNextLevel'] ?? 100,
      hp: json['hp'] ?? 10,
      maxHp: json['maxHp'] ?? 10,
      ac: json['ac'] ?? 10,
      gold: json['gold'] ?? 0,
      abilityScores: AbilityScores.fromJson(json['abilityScores'] ?? {}),
      spellSlots: SpellSlots.fromJson(json['spellSlots'] ?? {}),
      talents: TalentTree.fromJson(json['talents'] ?? {}),
      equipment: equipMap,
      inventory: List<String>.from(json['inventory'] ?? []),
      inventoryMaxSlots: json['inventoryMaxSlots'] ?? 20,
      rankingPoints: json['rankingPoints'] ?? 0,
      rankTier: json['rankTier'] ?? 'Bronze',
    );
  }
}
