import 'package:flutter/material.dart';

/// Manages all game assets including tiles, sprites, and UI elements
class AssetManager {
  // Tile asset paths
  static const String stoneFloor = 'assets/tiles/stone_floor.png';
  static const String grass = 'assets/tiles/grass.png';
  static const String water = 'assets/tiles/water.png';
  static const String woodFloor = 'assets/tiles/wood_floor.png';
  static const String wallStone = 'assets/tiles/wall_stone.png';
  static const String wallWood = 'assets/tiles/wall_wood.png';
  static const String doorClosed = 'assets/tiles/door_closed.png';
  static const String doorOpen = 'assets/tiles/door_open.png';
  static const String chestClosed = 'assets/tiles/chest_closed.png';
  static const String chestOpen = 'assets/tiles/chest_open.png';
  static const String stairsDown = 'assets/tiles/stairs_down.png';
  static const String stairsUp = 'assets/tiles/stairs_up.png';

  // Player sprites
  static const String playerWarrior = 'assets/sprites/player_warrior.png';
  static const String playerMage = 'assets/sprites/player_mage.png';
  static const String playerRogue = 'assets/sprites/player_rogue.png';

  // Enemy sprites
  static const String goblin = 'assets/sprites/goblin.png';
  static const String orc = 'assets/sprites/orc.png';
  static const String troll = 'assets/sprites/troll.png';
  static const String skeleton = 'assets/sprites/skeleton.png';
  static const String ghost = 'assets/sprites/ghost.png';
  static const String demon = 'assets/sprites/demon.png';
  static const String dragon = 'assets/sprites/dragon.png';

  // NPC sprites
  static const String npcMerchant = 'assets/sprites/npc_merchant.png';
  static const String npcGuard = 'assets/sprites/npc_guard.png';
  static const String npcHealer = 'assets/sprites/npc_healer.png';
  static const String npcQuestgiver = 'assets/sprites/npc_questgiver.png';

  /// Get tile asset path based on tile type and walkability
  static String getTileAsset(String type, bool isWalkable) {
    switch (type.toLowerCase()) {
      case 'stone':
      case 'floor':
        return isWalkable ? stoneFloor : wallStone;
      case 'grass':
        return grass;
      case 'water':
        return water;
      case 'wood':
        return isWalkable ? woodFloor : wallWood;
      case 'door':
        return isWalkable ? doorOpen : doorClosed;
      case 'wall':
        return wallStone;
      default:
        return stoneFloor;
    }
  }

  /// Get player sprite based on character class
  static String getPlayerSprite(String characterClass) {
    switch (characterClass.toLowerCase()) {
      case 'warrior':
        return playerWarrior;
      case 'mage':
        return playerMage;
      case 'rogue':
        return playerRogue;
      default:
        return playerWarrior;
    }
  }

  /// Get enemy sprite based on enemy name
  static String getEnemySprite(String enemyName) {
    final name = enemyName.toLowerCase();
    if (name.contains('goblin')) return goblin;
    if (name.contains('orc')) return orc;
    if (name.contains('troll')) return troll;
    if (name.contains('skeleton')) return skeleton;
    if (name.contains('ghost') || name.contains('spirit')) return ghost;
    if (name.contains('demon')) return demon;
    if (name.contains('dragon')) return dragon;
    return goblin; // Default
  }

  /// Get NPC sprite based on NPC name or role
  static String getNpcSprite(String npcName) {
    final name = npcName.toLowerCase();
    if (name.contains('merchant') || name.contains('shop')) return npcMerchant;
    if (name.contains('guard') || name.contains('soldier')) return npcGuard;
    if (name.contains('healer') || name.contains('priest')) return npcHealer;
    if (name.contains('quest')) return npcQuestgiver;
    return npcMerchant; // Default
  }

  /// Get chest asset based on open state
  static String getChestAsset(bool isOpen) {
    return isOpen ? chestOpen : chestClosed;
  }

  /// Get stairs asset based on direction
  static String getStairsAsset(bool isUp) {
    return isUp ? stairsUp : stairsDown;
  }

  /// Preload all game assets for smooth performance
  static Future<void> preloadAssets(BuildContext context) async {
    final imagesToLoad = [
      // Tiles
      stoneFloor, grass, water, woodFloor,
      wallStone, wallWood, doorClosed, doorOpen,
      chestClosed, chestOpen, stairsDown, stairsUp,
      
      // Players
      playerWarrior, playerMage, playerRogue,
      
      // Enemies
      goblin, orc, troll, skeleton, ghost, demon, dragon,
      
      // NPCs
      npcMerchant, npcGuard, npcHealer, npcQuestgiver,
    ];

    // Precache all images
    for (final imagePath in imagesToLoad) {
      await precacheImage(AssetImage(imagePath), context);
    }
  }
}
