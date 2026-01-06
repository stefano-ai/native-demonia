import 'character.dart';

enum ItemType { weapon, armor, accessory, consumable, keyItem }

enum ItemRarity { common, uncommon, rare, epic, legendary }

class Item {
  final String id;
  final String name;
  final String description;
  final ItemType type;
  final ItemRarity rarity;
  final EquipmentSlot? slot;
  final int attackBonus;
  final int damageBonus;
  final int acBonus;
  final int hpBonus;
  final int spellSlotBonus;
  final String? damageDice;
  final int healAmount;
  final int manaRestore;
  final int buyPrice;
  final int sellPrice;
  final List<CharacterClass>? allowedClasses;
  final String? setName;
  final bool isStackable;
  final int quantity;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.rarity = ItemRarity.common,
    this.slot,
    this.attackBonus = 0,
    this.damageBonus = 0,
    this.acBonus = 0,
    this.hpBonus = 0,
    this.spellSlotBonus = 0,
    this.damageDice,
    this.healAmount = 0,
    this.manaRestore = 0,
    this.buyPrice = 0,
    this.sellPrice = 0,
    this.allowedClasses,
    this.setName,
    this.isStackable = false,
    this.quantity = 1,
  });

  String get rarityName {
    switch (rarity) {
      case ItemRarity.common:
        return 'Common';
      case ItemRarity.uncommon:
        return 'Uncommon';
      case ItemRarity.rare:
        return 'Rare';
      case ItemRarity.epic:
        return 'Epic';
      case ItemRarity.legendary:
        return 'Legendary';
    }
  }

  bool canEquip(CharacterClass characterClass) {
    if (allowedClasses == null || allowedClasses!.isEmpty) return true;
    return allowedClasses!.contains(characterClass);
  }

  Item copyWith({
    String? id,
    String? name,
    String? description,
    ItemType? type,
    ItemRarity? rarity,
    EquipmentSlot? slot,
    int? attackBonus,
    int? damageBonus,
    int? acBonus,
    int? hpBonus,
    int? spellSlotBonus,
    String? damageDice,
    int? healAmount,
    int? manaRestore,
    int? buyPrice,
    int? sellPrice,
    List<CharacterClass>? allowedClasses,
    String? setName,
    bool? isStackable,
    int? quantity,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      slot: slot ?? this.slot,
      attackBonus: attackBonus ?? this.attackBonus,
      damageBonus: damageBonus ?? this.damageBonus,
      acBonus: acBonus ?? this.acBonus,
      hpBonus: hpBonus ?? this.hpBonus,
      spellSlotBonus: spellSlotBonus ?? this.spellSlotBonus,
      damageDice: damageDice ?? this.damageDice,
      healAmount: healAmount ?? this.healAmount,
      manaRestore: manaRestore ?? this.manaRestore,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      allowedClasses: allowedClasses ?? this.allowedClasses,
      setName: setName ?? this.setName,
      isStackable: isStackable ?? this.isStackable,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.index,
        'rarity': rarity.index,
        'slot': slot?.index,
        'attackBonus': attackBonus,
        'damageBonus': damageBonus,
        'acBonus': acBonus,
        'hpBonus': hpBonus,
        'spellSlotBonus': spellSlotBonus,
        'damageDice': damageDice,
        'healAmount': healAmount,
        'manaRestore': manaRestore,
        'buyPrice': buyPrice,
        'sellPrice': sellPrice,
        'allowedClasses': allowedClasses?.map((c) => c.index).toList(),
        'setName': setName,
        'isStackable': isStackable,
        'quantity': quantity,
      };

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Item',
      description: json['description'] ?? '',
      type: ItemType.values[json['type'] ?? 0],
      rarity: ItemRarity.values[json['rarity'] ?? 0],
      slot: json['slot'] != null ? EquipmentSlot.values[json['slot']] : null,
      attackBonus: json['attackBonus'] ?? 0,
      damageBonus: json['damageBonus'] ?? 0,
      acBonus: json['acBonus'] ?? 0,
      hpBonus: json['hpBonus'] ?? 0,
      spellSlotBonus: json['spellSlotBonus'] ?? 0,
      damageDice: json['damageDice'],
      healAmount: json['healAmount'] ?? 0,
      manaRestore: json['manaRestore'] ?? 0,
      buyPrice: json['buyPrice'] ?? 0,
      sellPrice: json['sellPrice'] ?? 0,
      allowedClasses: json['allowedClasses'] != null
          ? (json['allowedClasses'] as List)
              .map((i) => CharacterClass.values[i])
              .toList()
          : null,
      setName: json['setName'],
      isStackable: json['isStackable'] ?? false,
      quantity: json['quantity'] ?? 1,
    );
  }
}

class ItemDatabase {
  static const Map<String, Item> items = {
    // Consumables
    'potion_health_minor': Item(
      id: 'potion_health_minor',
      name: 'Minor Health Potion',
      description: 'Restores 10 HP.',
      type: ItemType.consumable,
      rarity: ItemRarity.common,
      healAmount: 10,
      buyPrice: 25,
      sellPrice: 10,
      isStackable: true,
    ),
    'potion_health': Item(
      id: 'potion_health',
      name: 'Health Potion',
      description: 'Restores 25 HP.',
      type: ItemType.consumable,
      rarity: ItemRarity.uncommon,
      healAmount: 25,
      buyPrice: 50,
      sellPrice: 20,
      isStackable: true,
    ),
    'potion_health_greater': Item(
      id: 'potion_health_greater',
      name: 'Greater Health Potion',
      description: 'Restores 50 HP.',
      type: ItemType.consumable,
      rarity: ItemRarity.rare,
      healAmount: 50,
      buyPrice: 100,
      sellPrice: 40,
      isStackable: true,
    ),
    'potion_mana': Item(
      id: 'potion_mana',
      name: 'Mana Potion',
      description: 'Restores 1 spell slot.',
      type: ItemType.consumable,
      rarity: ItemRarity.uncommon,
      manaRestore: 1,
      buyPrice: 75,
      sellPrice: 30,
      isStackable: true,
    ),

    // Weapons - Common
    'dagger_rusty': Item(
      id: 'dagger_rusty',
      name: 'Rusty Dagger',
      description: 'A worn blade that has seen better days.',
      type: ItemType.weapon,
      rarity: ItemRarity.common,
      slot: EquipmentSlot.weapon,
      attackBonus: 1,
      damageDice: '1d4',
      buyPrice: 15,
      sellPrice: 5,
    ),
    'sword_iron': Item(
      id: 'sword_iron',
      name: 'Iron Sword',
      description: 'A reliable iron blade.',
      type: ItemType.weapon,
      rarity: ItemRarity.common,
      slot: EquipmentSlot.weapon,
      attackBonus: 1,
      damageBonus: 1,
      damageDice: '1d8',
      buyPrice: 50,
      sellPrice: 20,
      allowedClasses: [CharacterClass.fighter, CharacterClass.cleric],
    ),
    'staff_wooden': Item(
      id: 'staff_wooden',
      name: 'Wooden Staff',
      description: 'A simple staff for channeling magic.',
      type: ItemType.weapon,
      rarity: ItemRarity.common,
      slot: EquipmentSlot.weapon,
      attackBonus: 1,
      spellSlotBonus: 1,
      damageDice: '1d6',
      buyPrice: 40,
      sellPrice: 15,
      allowedClasses: [CharacterClass.wizard, CharacterClass.cleric],
    ),

    // Weapons - Uncommon
    'axe_orcish': Item(
      id: 'axe_orcish',
      name: 'Orcish Battleaxe',
      description: 'A brutal axe forged by orc smiths.',
      type: ItemType.weapon,
      rarity: ItemRarity.uncommon,
      slot: EquipmentSlot.weapon,
      attackBonus: 2,
      damageBonus: 2,
      damageDice: '1d12',
      buyPrice: 150,
      sellPrice: 60,
      allowedClasses: [CharacterClass.fighter],
    ),
    'staff_dark': Item(
      id: 'staff_dark',
      name: 'Staff of Shadows',
      description: 'A staff imbued with dark magic.',
      type: ItemType.weapon,
      rarity: ItemRarity.rare,
      slot: EquipmentSlot.weapon,
      attackBonus: 2,
      damageBonus: 2,
      spellSlotBonus: 1,
      damageDice: '1d8',
      buyPrice: 300,
      sellPrice: 120,
      allowedClasses: [CharacterClass.wizard],
    ),

    // Armor - Common
    'armor_leather': Item(
      id: 'armor_leather',
      name: 'Leather Armor',
      description: 'Basic protection for adventurers.',
      type: ItemType.armor,
      rarity: ItemRarity.common,
      slot: EquipmentSlot.chest,
      acBonus: 2,
      buyPrice: 40,
      sellPrice: 15,
    ),
    'helm_iron': Item(
      id: 'helm_iron',
      name: 'Iron Helm',
      description: 'A sturdy iron helmet.',
      type: ItemType.armor,
      rarity: ItemRarity.common,
      slot: EquipmentSlot.head,
      acBonus: 1,
      buyPrice: 30,
      sellPrice: 12,
    ),

    // Accessories
    'ring_power': Item(
      id: 'ring_power',
      name: 'Ring of Power',
      description: 'Grants increased attack damage.',
      type: ItemType.accessory,
      rarity: ItemRarity.rare,
      slot: EquipmentSlot.ring1,
      attackBonus: 1,
      damageBonus: 2,
      buyPrice: 200,
      sellPrice: 80,
    ),
    'cloak_shadows': Item(
      id: 'cloak_shadows',
      name: 'Cloak of Shadows',
      description: 'A cloak woven from living darkness.',
      type: ItemType.accessory,
      rarity: ItemRarity.epic,
      slot: EquipmentSlot.cloak,
      acBonus: 2,
      attackBonus: 1,
      buyPrice: 500,
      sellPrice: 200,
      setName: 'Shadow Stalker',
    ),

    // Key Items
    'caldera_key': Item(
      id: 'caldera_key',
      name: 'Caldera Key',
      description: 'Opens the passage to the Molten Caldera.',
      type: ItemType.keyItem,
      rarity: ItemRarity.legendary,
    ),
    'chapel_key': Item(
      id: 'chapel_key',
      name: 'Chapel Key',
      description: 'Opens the sealed Infernal Chapel.',
      type: ItemType.keyItem,
      rarity: ItemRarity.legendary,
    ),
    'sigil_fragment_shadow': Item(
      id: 'sigil_fragment_shadow',
      name: 'Sigil Fragment (Shadow)',
      description: 'A piece of an ancient sigil, pulsing with shadow energy.',
      type: ItemType.keyItem,
      rarity: ItemRarity.legendary,
    ),
    'sigil_fragment_ice': Item(
      id: 'sigil_fragment_ice',
      name: 'Sigil Fragment (Ice)',
      description: 'A piece of an ancient sigil, radiating cold.',
      type: ItemType.keyItem,
      rarity: ItemRarity.legendary,
    ),
    'sigil_fragment_void': Item(
      id: 'sigil_fragment_void',
      name: 'Sigil Fragment (Void)',
      description: 'A piece of an ancient sigil, warping reality around it.',
      type: ItemType.keyItem,
      rarity: ItemRarity.legendary,
    ),

    // Boss drops
    'infernal_core': Item(
      id: 'infernal_core',
      name: 'Infernal Core',
      description: 'The burning heart of the Infernal Warden.',
      type: ItemType.accessory,
      rarity: ItemRarity.legendary,
      slot: EquipmentSlot.necklace,
      attackBonus: 3,
      damageBonus: 3,
      hpBonus: 10,
      buyPrice: 0,
      sellPrice: 500,
    ),
    'glacial_heart': Item(
      id: 'glacial_heart',
      name: 'Glacial Heart',
      description: 'The frozen essence of a Glacial Titan.',
      type: ItemType.accessory,
      rarity: ItemRarity.legendary,
      slot: EquipmentSlot.necklace,
      acBonus: 3,
      hpBonus: 15,
      buyPrice: 0,
      sellPrice: 600,
    ),
    'abyssal_crown': Item(
      id: 'abyssal_crown',
      name: 'Abyssal Crown',
      description: 'The crown of the Abyssal Overlord, radiating dark power.',
      type: ItemType.armor,
      rarity: ItemRarity.legendary,
      slot: EquipmentSlot.head,
      acBonus: 4,
      attackBonus: 3,
      damageBonus: 3,
      spellSlotBonus: 2,
      buyPrice: 0,
      sellPrice: 1000,
    ),

    // Crafting materials
    'bone_dust': Item(
      id: 'bone_dust',
      name: 'Bone Dust',
      description: 'Dust from skeletal remains.',
      type: ItemType.consumable,
      rarity: ItemRarity.common,
      buyPrice: 5,
      sellPrice: 2,
      isStackable: true,
    ),
    'ember_shard': Item(
      id: 'ember_shard',
      name: 'Ember Shard',
      description: 'A shard of crystallized fire.',
      type: ItemType.consumable,
      rarity: ItemRarity.uncommon,
      buyPrice: 20,
      sellPrice: 8,
      isStackable: true,
    ),
    'frost_essence': Item(
      id: 'frost_essence',
      name: 'Frost Essence',
      description: 'Concentrated cold energy.',
      type: ItemType.consumable,
      rarity: ItemRarity.uncommon,
      buyPrice: 25,
      sellPrice: 10,
      isStackable: true,
    ),
    'void_shard': Item(
      id: 'void_shard',
      name: 'Void Shard',
      description: 'A fragment of pure void energy.',
      type: ItemType.consumable,
      rarity: ItemRarity.rare,
      buyPrice: 50,
      sellPrice: 20,
      isStackable: true,
    ),
  };

  static Item? getItem(String id) => items[id];
}
