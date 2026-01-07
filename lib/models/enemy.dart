import 'dart:math' as math;

enum EnemyType {
  goblin,
  skeleton,
  orcWarrior,
  orcWarlord,
  darkAcolyte,
  shadowLord,
  fireImp,
  infernalWarden,
  frostWraith,
  glacialTitan,
  voidSpawn,
  abyssalOverlord,
}

class Enemy {
  final String id;
  final EnemyType type;
  final String name;
  final int level;
  final int hp;
  final int maxHp;
  final int ac;
  final int attackBonus;
  final String damageDice;
  final int xpReward;
  final int goldMin;
  final int goldMax;
  final bool isBoss;
  final List<String> abilities;
  final List<LootDrop> lootTable;
  final String? guaranteedDrop;

  Enemy({
    required this.id,
    required this.type,
    required this.name,
    required this.level,
    required this.hp,
    required this.maxHp,
    required this.ac,
    required this.attackBonus,
    required this.damageDice,
    required this.xpReward,
    this.goldMin = 5,
    this.goldMax = 20,
    this.isBoss = false,
    this.abilities = const ['Attack'],
    this.lootTable = const [],
    this.guaranteedDrop,
  });

  double get hpPercentage => hp / maxHp;

  int rollDamage() {
    final regex = RegExp(r'(\d+)d(\d+)(?:\+(\d+))?');
    final match = regex.firstMatch(damageDice);
    if (match == null) return 1;

    final numDice = int.parse(match.group(1)!);
    final dieSize = int.parse(match.group(2)!);
    final bonus = match.group(3) != null ? int.parse(match.group(3)!) : 0;

    final random = math.Random();
    int total = bonus;
    for (int i = 0; i < numDice; i++) {
      total += random.nextInt(dieSize) + 1;
    }
    return total;
  }

  int rollGold() {
    final random = math.Random();
    return goldMin + random.nextInt(goldMax - goldMin + 1);
  }

  Enemy copyWith({
    String? id,
    EnemyType? type,
    String? name,
    int? level,
    int? hp,
    int? maxHp,
    int? ac,
    int? attackBonus,
    String? damageDice,
    int? xpReward,
    int? goldMin,
    int? goldMax,
    bool? isBoss,
    List<String>? abilities,
    List<LootDrop>? lootTable,
    String? guaranteedDrop,
  }) {
    return Enemy(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      level: level ?? this.level,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      ac: ac ?? this.ac,
      attackBonus: attackBonus ?? this.attackBonus,
      damageDice: damageDice ?? this.damageDice,
      xpReward: xpReward ?? this.xpReward,
      goldMin: goldMin ?? this.goldMin,
      goldMax: goldMax ?? this.goldMax,
      isBoss: isBoss ?? this.isBoss,
      abilities: abilities ?? this.abilities,
      lootTable: lootTable ?? this.lootTable,
      guaranteedDrop: guaranteedDrop ?? this.guaranteedDrop,
    );
  }

  static Enemy createFromType(EnemyType type) {
    switch (type) {
      case EnemyType.goblin:
        return Enemy(
          id: 'goblin_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          name: 'Goblin',
          level: 1,
          hp: 8,
          maxHp: 8,
          ac: 12,
          attackBonus: 2,
          damageDice: '1d6',
          xpReward: 25,
          goldMin: 5,
          goldMax: 15,
          lootTable: [
            const LootDrop(itemId: 'potion_health_minor', dropChance: 0.2),
            const LootDrop(itemId: 'dagger_rusty', dropChance: 0.1),
          ],
        );

      case EnemyType.skeleton:
        return Enemy(
          id: 'skeleton_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          name: 'Skeleton Warrior',
          level: 2,
          hp: 12,
          maxHp: 12,
          ac: 13,
          attackBonus: 3,
          damageDice: '1d8',
          xpReward: 40,
          goldMin: 10,
          goldMax: 25,
          lootTable: [
            const LootDrop(itemId: 'bone_dust', dropChance: 0.3),
            const LootDrop(itemId: 'sword_iron', dropChance: 0.15),
          ],
        );

      case EnemyType.orcWarrior:
        return Enemy(
          id: 'orc_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          name: 'Orc Warrior',
          level: 3,
          hp: 18,
          maxHp: 18,
          ac: 14,
          attackBonus: 5,
          damageDice: '1d10+2',
          xpReward: 75,
          goldMin: 20,
          goldMax: 40,
          abilities: ['Attack', 'Rage'],
          lootTable: [
            const LootDrop(itemId: 'potion_health', dropChance: 0.25),
            const LootDrop(itemId: 'axe_orcish', dropChance: 0.1),
          ],
        );

      case EnemyType.orcWarlord:
        return Enemy(
          id: 'orc_warlord_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          name: 'Orc Warlord',
          level: 5,
          hp: 45,
          maxHp: 45,
          ac: 16,
          attackBonus: 7,
          damageDice: '2d8+4',
          xpReward: 250,
          goldMin: 100,
          goldMax: 200,
          isBoss: true,
          abilities: ['Attack', 'Cleave', 'War Cry'],
          lootTable: [
            const LootDrop(itemId: 'ring_power', dropChance: 1.0),
          ],
          guaranteedDrop: 'caldera_key',
        );

      case EnemyType.darkAcolyte:
        return Enemy(
          id: 'acolyte_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          name: 'Dark Acolyte',
          level: 4,
          hp: 14,
          maxHp: 14,
          ac: 12,
          attackBonus: 4,
          damageDice: '2d6',
          xpReward: 60,
          goldMin: 15,
          goldMax: 35,
          abilities: ['Shadow Bolt', 'Curse'],
          lootTable: [
            const LootDrop(itemId: 'potion_mana', dropChance: 0.3),
            const LootDrop(itemId: 'staff_dark', dropChance: 0.08),
          ],
        );

      case EnemyType.shadowLord:
        return Enemy(
          id: 'shadow_lord_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          name: 'Shadow Lord',
          level: 7,
          hp: 60,
          maxHp: 60,
          ac: 17,
          attackBonus: 8,
          damageDice: '2d10+3',
          xpReward: 400,
          goldMin: 150,
          goldMax: 300,
          isBoss: true,
          abilities: ['Shadow Strike', 'Void Blast', 'Summon Shadows'],
          lootTable: [
            const LootDrop(itemId: 'cloak_shadows', dropChance: 1.0),
          ],
          guaranteedDrop: 'sigil_fragment_shadow',
        );

      case EnemyType.fireImp:
        return Enemy(
          id: 'imp_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          name: 'Fire Imp',
          level: 4,
          hp: 10,
          maxHp: 10,
          ac: 14,
          attackBonus: 5,
          damageDice: '1d8+2',
          xpReward: 50,
          goldMin: 10,
          goldMax: 30,
          abilities: ['Fireball', 'Flame Touch'],
          lootTable: [
            const LootDrop(itemId: 'ember_shard', dropChance: 0.25),
          ],
        );

      case EnemyType.infernalWarden:
        return Enemy(
          id: 'warden_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          name: 'Infernal Warden',
          level: 8,
          hp: 75,
          maxHp: 75,
          ac: 18,
          attackBonus: 9,
          damageDice: '2d12+5',
          xpReward: 500,
          goldMin: 200,
          goldMax: 400,
          isBoss: true,
          abilities: ['Hellfire Cleave', 'Infernal Nova', 'Summon Imps'],
          lootTable: [
            const LootDrop(itemId: 'infernal_core', dropChance: 1.0),
          ],
          guaranteedDrop: 'chapel_key',
        );

      case EnemyType.frostWraith:
        return Enemy(
          id: 'wraith_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          name: 'Frost Wraith',
          level: 6,
          hp: 25,
          maxHp: 25,
          ac: 15,
          attackBonus: 6,
          damageDice: '2d6+2',
          xpReward: 100,
          goldMin: 30,
          goldMax: 60,
          abilities: ['Frost Touch', 'Chilling Wail'],
          lootTable: [
            const LootDrop(itemId: 'frost_essence', dropChance: 0.3),
          ],
        );

      case EnemyType.glacialTitan:
        return Enemy(
          id: 'titan_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          name: 'Glacial Titan',
          level: 10,
          hp: 100,
          maxHp: 100,
          ac: 19,
          attackBonus: 10,
          damageDice: '3d10+6',
          xpReward: 750,
          goldMin: 300,
          goldMax: 500,
          isBoss: true,
          abilities: ['Frozen Slam', 'Blizzard', 'Ice Prison'],
          lootTable: [
            const LootDrop(itemId: 'glacial_heart', dropChance: 1.0),
          ],
          guaranteedDrop: 'sigil_fragment_ice',
        );

      case EnemyType.voidSpawn:
        return Enemy(
          id: 'void_spawn_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          name: 'Void Spawn',
          level: 8,
          hp: 30,
          maxHp: 30,
          ac: 16,
          attackBonus: 7,
          damageDice: '2d8+3',
          xpReward: 150,
          goldMin: 50,
          goldMax: 100,
          abilities: ['Void Bolt', 'Phase Shift'],
          lootTable: [
            const LootDrop(itemId: 'void_shard', dropChance: 0.2),
          ],
        );

      case EnemyType.abyssalOverlord:
        return Enemy(
          id: 'overlord_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          name: 'Abyssal Overlord',
          level: 12,
          hp: 150,
          maxHp: 150,
          ac: 20,
          attackBonus: 12,
          damageDice: '4d10+8',
          xpReward: 1500,
          goldMin: 500,
          goldMax: 1000,
          isBoss: true,
          abilities: [
            'Abyssal Strike',
            'Void Eruption',
            'Summon Legion',
            'Dark Pact'
          ],
          lootTable: [
            const LootDrop(itemId: 'abyssal_crown', dropChance: 1.0),
          ],
          guaranteedDrop: 'sigil_fragment_void',
        );
    }
  }
}

class LootDrop {
  final String itemId;
  final double dropChance;

  const LootDrop({
    required this.itemId,
    required this.dropChance,
  });
}
