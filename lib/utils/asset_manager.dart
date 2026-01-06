import 'package:flutter/material.dart';
import '../models/character.dart';

/// Manages all game assets including tiles, sprites, and UI elements
class AssetManager {
  // Tile asset paths
  static const String stoneFloor = 'assets/tiles/stone_floor.png';
  static const String grass = 'assets/tiles/grass.png'; // Note: Might be missing
  static const String water = 'assets/tiles/water.png'; // Note: Might be missing
  static const String woodFloor = 'assets/tiles/floor.png'; // Using floor.png as wood fallback
  static const String wallStone = 'assets/tiles/stone_floor.png'; // Using stone_floor for wall for now
  static const String wallWood = 'assets/tiles/floor.png';
  static const String doorClosed = 'assets/tiles/stone_floor.png';
  static const String doorOpen = 'assets/tiles/floor.png';
  static const String chestClosed = 'assets/tiles/stone_floor.png';
  static const String chestOpen = 'assets/tiles/floor.png';
  static const String stairsDown = 'assets/tiles/stone_floor.png';
  static const String stairsUp = 'assets/tiles/floor.png';

  // Player sprites
  static const String playerWarrior = 'assets/icons/app_icon.png'; // Fallback to app_icon
  static const String playerMage = 'assets/icons/app_icon.png';
  static const String playerRogue = 'assets/icons/app_icon.png';

  // Enemy sprites
  static const String goblin = 'assets/icons/app_icon.png';
  static const String orc = 'assets/icons/app_icon.png';
  static const String troll = 'assets/icons/app_icon.png';
  static const String skeleton = 'assets/icons/app_icon.png';
  static const String ghost = 'assets/icons/app_icon.png';
  static const String demon = 'assets/icons/app_icon.png';
  static const String dragon = 'assets/icons/app_icon.png';

  // NPC sprites
  static const String npcMerchant = 'assets/icons/app_icon.png';
  static const String npcGuard = 'assets/icons/app_icon.png';
  static const String npcHealer = 'assets/icons/app_icon.png';
  static const String npcQuestgiver = 'assets/icons/app_icon.png';

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

  /// Get player sprite based on character class enum
  static String getPlayerSprite(CharacterClass characterClass) {
    switch (characterClass) {
      case CharacterClass.fighter:
        return playerWarrior;
      case CharacterClass.wizard:
        return playerMage;
      case CharacterClass.rogue:
        return playerRogue;
      case CharacterClass.cleric:
        return playerWarrior; // Fallback for cleric
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
      stoneFloor, grass, water, woodFloor,
      wallStone, wallWood, doorClosed, doorOpen,
      chestClosed, chestOpen, stairsDown, stairsUp,
      playerWarrior, playerMage, playerRogue,
      goblin, orc, troll, skeleton, ghost, demon, dragon,
      npcMerchant, npcGuard, npcHealer, npcQuestgiver,
    ];

    for (final imagePath in imagesToLoad) {
      try {
        await precacheImage(AssetImage(imagePath), context);
      } catch (e) {
        // Ignore errors for missing assets
      }
    }
  }
}
