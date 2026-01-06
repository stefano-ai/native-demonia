import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum TileType {
  grass,
  path,
  tree,
  water,
  mountain,
  town,
  cave,
  chest,
  bridge,
  desert,
  castle,
  stairsUp,
  stairsDown,
  lava,
  ice,
  ruins,
  wall,
  floor,
  door,
  npc,
  enemy,
  player,
}

class MapTile {
  final TileType type;
  final bool isWalkable;
  final bool isInteractable;
  final String? targetFloor;
  final int? targetX;
  final int? targetY;
  final String? npcId;
  final String? enemyType;
  final String? chestId;
  final bool isCleared;
  final bool isOpened;

  const MapTile({
    required this.type,
    this.isWalkable = true,
    this.isInteractable = false,
    this.targetFloor,
    this.targetX,
    this.targetY,
    this.npcId,
    this.enemyType,
    this.chestId,
    this.isCleared = false,
    this.isOpened = false,
  });

  Color get baseColor {
    switch (type) {
      case TileType.grass:
        return const Color(0xFF228B22);
      case TileType.path:
        return const Color(0xFF8B7355);
      case TileType.tree:
        return const Color(0xFF0B5345);
      case TileType.water:
        return const Color(0xFF1E90FF);
      case TileType.mountain:
        return const Color(0xFF696969);
      case TileType.town:
        return const Color(0xFFDAA520);
      case TileType.cave:
        return const Color(0xFF2F2F2F);
      case TileType.chest:
        return isOpened ? const Color(0xFF8B4513) : const Color(0xFFFFD700);
      case TileType.bridge:
        return const Color(0xFF8B4513);
      case TileType.desert:
        return const Color(0xFFEDC9AF);
      case TileType.castle:
        return const Color(0xFF4A4A4A);
      case TileType.stairsUp:
        return const Color(0xFF9370DB);
      case TileType.stairsDown:
        return const Color(0xFF6A5ACD);
      case TileType.lava:
        return AppTheme.hellfire;
      case TileType.ice:
        return AppTheme.ice;
      case TileType.ruins:
        return const Color(0xFF483D8B);
      case TileType.wall:
        return const Color(0xFF3D3D3D);
      case TileType.floor:
        return const Color(0xFF5C4033);
      case TileType.door:
        return const Color(0xFF8B4513);
      case TileType.npc:
        return const Color(0xFF32CD32);
      case TileType.enemy:
        return AppTheme.crimson;
      case TileType.player:
        return AppTheme.gold;
    }
  }

  String get symbol {
    switch (type) {
      case TileType.grass:
        return '.';
      case TileType.path:
        return '·';
      case TileType.tree:
        return '♠';
      case TileType.water:
        return '≈';
      case TileType.mountain:
        return '▲';
      case TileType.town:
        return '⌂';
      case TileType.cave:
        return '◙';
      case TileType.chest:
        return isOpened ? '□' : '■';
      case TileType.bridge:
        return '═';
      case TileType.desert:
        return '~';
      case TileType.castle:
        return '♜';
      case TileType.stairsUp:
        return '↑';
      case TileType.stairsDown:
        return '↓';
      case TileType.lava:
        return '▓';
      case TileType.ice:
        return '░';
      case TileType.ruins:
        return '▒';
      case TileType.wall:
        return '#';
      case TileType.floor:
        return '.';
      case TileType.door:
        return '+';
      case TileType.npc:
        return '!';
      case TileType.enemy:
        return '☠';
      case TileType.player:
        return '@';
    }
  }

  MapTile copyWith({
    TileType? type,
    bool? isWalkable,
    bool? isInteractable,
    String? targetFloor,
    int? targetX,
    int? targetY,
    String? npcId,
    String? enemyType,
    String? chestId,
    bool? isCleared,
    bool? isOpened,
  }) {
    return MapTile(
      type: type ?? this.type,
      isWalkable: isWalkable ?? this.isWalkable,
      isInteractable: isInteractable ?? this.isInteractable,
      targetFloor: targetFloor ?? this.targetFloor,
      targetX: targetX ?? this.targetX,
      targetY: targetY ?? this.targetY,
      npcId: npcId ?? this.npcId,
      enemyType: enemyType ?? this.enemyType,
      chestId: chestId ?? this.chestId,
      isCleared: isCleared ?? this.isCleared,
      isOpened: isOpened ?? this.isOpened,
    );
  }
}

class GameMap {
  final String id;
  final String name;
  final String theme;
  final int width;
  final int height;
  final List<List<MapTile>> tiles;
  final int startX;
  final int startY;
  final List<EnemySpawn> enemySpawns;
  final List<ChestSpawn> chestSpawns;
  final List<NpcSpawn> npcSpawns;

  const GameMap({
    required this.id,
    required this.name,
    required this.theme,
    this.width = 32,
    this.height = 24,
    required this.tiles,
    this.startX = 1,
    this.startY = 1,
    this.enemySpawns = const [],
    this.chestSpawns = const [],
    this.npcSpawns = const [],
  });

  MapTile getTile(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return const MapTile(type: TileType.wall, isWalkable: false);
    }
    return tiles[y][x];
  }

  bool canMoveTo(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) return false;
    return tiles[y][x].isWalkable;
  }
}

class EnemySpawn {
  final int x;
  final int y;
  final String enemyType;
  final bool respawns;

  const EnemySpawn({
    required this.x,
    required this.y,
    required this.enemyType,
    this.respawns = false,
  });
}

class ChestSpawn {
  final int x;
  final int y;
  final String chestId;
  final List<String> loot;

  const ChestSpawn({
    required this.x,
    required this.y,
    required this.chestId,
    required this.loot,
  });
}

class NpcSpawn {
  final int x;
  final int y;
  final String npcId;
  final String name;
  final List<String> dialogueLines;

  const NpcSpawn({
    required this.x,
    required this.y,
    required this.npcId,
    required this.name,
    this.dialogueLines = const [],
  });
}
