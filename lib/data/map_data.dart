import '../models/tile.dart';

class MapData {
  static GameMap getFloor(int floor) {
    switch (floor) {
      case 1:
        return _floor1GoblinWarrens;
      case 2:
        return _floor2MoltenCaldera;
      case 3:
        return _floor3InfernalChapel;
      default:
        return _floor1GoblinWarrens;
    }
  }

  static List<List<MapTile>> _parseMapString(String mapString) {
    final lines = mapString.trim().split('\n');
    final tiles = <List<MapTile>>[];

    for (final line in lines) {
      final row = <MapTile>[];
      for (int i = 0; i < line.length; i++) {
        row.add(_charToTile(line[i]));
      }
      while (row.length < 32) {
        row.add(const MapTile(type: TileType.wall, isWalkable: false));
      }
      tiles.add(row);
    }

    while (tiles.length < 24) {
      tiles.add(List.generate(
          32, (_) => const MapTile(type: TileType.wall, isWalkable: false)));
    }

    return tiles;
  }

  static MapTile _charToTile(String char) {
    switch (char) {
      case '#':
        return const MapTile(type: TileType.wall, isWalkable: false);
      case '.':
        return const MapTile(type: TileType.floor);
      case ',':
        return const MapTile(type: TileType.grass);
      case 'T':
        return const MapTile(type: TileType.tree, isWalkable: false);
      case '~':
        return const MapTile(type: TileType.water, isWalkable: false);
      case '^':
        return const MapTile(type: TileType.mountain, isWalkable: false);
      case 'H':
        return const MapTile(type: TileType.town, isInteractable: true);
      case 'C':
        return MapTile(
          type: TileType.chest,
          isInteractable: true,
          chestId: 'chest_${DateTime.now().millisecondsSinceEpoch}',
        );
      case '=':
        return const MapTile(type: TileType.bridge);
      case '>':
        return const MapTile(
          type: TileType.stairsDown,
          isInteractable: true,
          targetFloor: '2',
          targetX: 5,
          targetY: 3,
        );
      case '<':
        return const MapTile(
          type: TileType.stairsUp,
          isInteractable: true,
          targetFloor: '1',
          targetX: 26,
          targetY: 20,
        );
      case 'L':
        return const MapTile(type: TileType.lava, isWalkable: false);
      case 'I':
        return const MapTile(type: TileType.ice);
      case 'R':
        return const MapTile(type: TileType.ruins);
      case '+':
        return const MapTile(type: TileType.door, isInteractable: true);
      case 'P':
        return const MapTile(type: TileType.path);
      case 'E':
        return const MapTile(
          type: TileType.floor,
          enemyType: 'goblin',
        );
      case 'B':
        return const MapTile(
          type: TileType.floor,
          enemyType: 'boss',
          isInteractable: true,
        );
      case 'N':
        return const MapTile(
          type: TileType.floor,
          isInteractable: true,
          npcId: 'herald',
        );
      default:
        return const MapTile(type: TileType.floor);
    }
  }

  // Floor 1: Goblin Warrens - Verdant Forest theme
  static final GameMap _floor1GoblinWarrens = GameMap(
    id: 'floor_1',
    name: 'Goblin Warrens',
    theme: 'verdant',
    startX: 5,
    startY: 12,
    tiles: _parseMapString('''
################################
#,,,,,,T,,,,,,,,,,,,,T,,,,,,,,T#
#,,,T,,,,,,,,T,,,,,,,,,T,,,,,,,#
#,,,,,,,,T,,,,,,,,,T,,,,,,,T,,,#
#,T,,,,,,,,,,,,,,,,,,,,,,,,,,,T#
#,,,,,,########+########,,,,,,,#
#,,,T,,#......N........#,,T,,,,#
#,,,,,,#...............#,,,,,,,#
#,,,,,,#.....E....E....#,,,,,,,#
#,T,,,,+...............+,,,,,T,#
#,,,,,,#.......E.......#,,,,,,,#
#,,,,,,#...............#,,,,,,,#
#,,,,N,#..E........E...#,,,,,,,#
#,,,,,,########+########,,,,,,,#
#,,,T,,,,,,,,,P,,,,,,,,,,,,T,,,#
#,,,,,,,,,,,,,P,,,T,,,,,,,,,,,,#
#,,T,,,,,,,,,,P,,,,,,,,,,T,,,,,#
#,,,,,T,,,,,,,P,,,,,,,,,,,,,T,,#
#,,,,,,,,,,,,,P,,,,T,,,,,,,,,,,#
#,,T,,,,C,,,,,P,,,,,,,,,,,,,>,,#
#,,,,,,,,,,,,,P,,,,,,,,,,,,,,,,#
#,,,T,,,,,,,,,P,,,,,T,,,,T,,,,,#
#,,,,,,T,,,~~~~~~~,,,,,,,,,,,,,#
################################
'''),
    enemySpawns: const [
      EnemySpawn(x: 13, y: 8, enemyType: 'goblin'),
      EnemySpawn(x: 18, y: 8, enemyType: 'goblin'),
      EnemySpawn(x: 15, y: 10, enemyType: 'goblin'),
      EnemySpawn(x: 10, y: 12, enemyType: 'goblin'),
      EnemySpawn(x: 19, y: 12, enemyType: 'goblin'),
    ],
    chestSpawns: const [
      ChestSpawn(
        x: 8,
        y: 19,
        chestId: 'chest_floor1_1',
        loot: ['potion_health_minor', 'potion_health_minor'],
      ),
    ],
    npcSpawns: const [
      NpcSpawn(
        x: 14,
        y: 6,
        npcId: 'herald',
        name: 'The Herald',
        dialogueLines: [
          'Greetings, brave adventurer!',
          'Dark forces stir in these dungeons...',
          'Venture forth and prove your worth!',
        ],
      ),
      NpcSpawn(
        x: 5,
        y: 12,
        npcId: 'merchant',
        name: 'Wandering Merchant',
        dialogueLines: [
          'Looking to buy or sell?',
          'I have potions and supplies!',
        ],
      ),
    ],
  );

  // Floor 2: Molten Caldera
  static final GameMap _floor2MoltenCaldera = GameMap(
    id: 'floor_2',
    name: 'Molten Caldera',
    theme: 'molten',
    startX: 5,
    startY: 3,
    tiles: _parseMapString('''
################################
#LLLLLLLLLLLLLLLLLLLLLLLLLLLLLL#
#L.....<.......LLLLLLLLLLLLLLL#
#L..........LLLLLLLLLLLLLLLLLL#
#L.....E....LLLLLLLLLL...LLLLL#
#L..........LLLLLLL......LLLLL#
#L....E.....LLLLLL...E...LLLLL#
#L==========LLLLL........LLLLL#
#LLLLLLLLLL=LLLL....E....LLLLL#
#LLLLLLLLL.=LLL..........LLLLL#
#LLLLLLLL..=LL...........LLLLL#
#LLLLLLL...=L....E...E...LLLLL#
#LLLLLL....=.............LLLLL#
#LLLLL...N.=.............LLLLL#
#LLLL......============..LLLLL#
#LLL.......LLLLLLLLLLL=..LLLLL#
#LL...E....LLLLLLLLLL.=..LLLLL#
#L.........LLLLLLLLL..=..LLLLL#
#L....E....LLLLLLLL...=..LLLLL#
#L.........LLLLLLL....=.>LLLLL#
#L...B.....LLLLLL.....=..LLLLL#
#L.........LLLLL......===LLLLL#
#LLLLLLLLLLLLLLLLLLLLLLLLLLLL#
################################
'''),
    enemySpawns: const [
      EnemySpawn(x: 9, y: 4, enemyType: 'fire_imp'),
      EnemySpawn(x: 8, y: 6, enemyType: 'fire_imp'),
      EnemySpawn(x: 21, y: 6, enemyType: 'orc_warrior'),
      EnemySpawn(x: 17, y: 8, enemyType: 'orc_warrior'),
      EnemySpawn(x: 15, y: 11, enemyType: 'orc_warrior'),
      EnemySpawn(x: 20, y: 11, enemyType: 'fire_imp'),
      EnemySpawn(x: 7, y: 16, enemyType: 'orc_warrior'),
      EnemySpawn(x: 6, y: 18, enemyType: 'fire_imp'),
      EnemySpawn(x: 5, y: 20, enemyType: 'orc_warlord'),
    ],
    npcSpawns: const [
      NpcSpawn(
        x: 8,
        y: 13,
        npcId: 'eldric',
        name: 'Eldric the Mage',
        dialogueLines: [
          'You made it through the warrens!',
          'The Infernal Chapel lies below...',
          'But first, defeat the Orc Warlord!',
        ],
      ),
    ],
  );

  // Floor 3: Infernal Chapel
  static final GameMap _floor3InfernalChapel = GameMap(
    id: 'floor_3',
    name: 'Infernal Chapel',
    theme: 'infernal',
    startX: 5,
    startY: 3,
    tiles: _parseMapString('''
################################
#RRRRRRRRRRRRRRRRRRRRRRRRRRRRRR#
#R.....<.....RRRRRRRRRRRRRRRRRR#
#R...........RRRRRRRRRRRRRRRRRR#
#R...E...E...RRRRRRR......RRRR#
#R...........RRRRRR........RRR#
#R...........RRRRR...E......RR#
#R#####+#####RRRR............R#
#R#.........#RRR..............#
#R#..E...E..#RR...............#
#R#.........+R................#
#R#....N....#R.......E........#
#R#.........#R................#
#R#####+#####R....E......E....#
#RRRRRPRRRRRRR................#
#RRRRR.RRRRRRR......B.........#
#RRRR..RRRRRRRR...............#
#RRR...E..RRRRRR.............R#
#RR........RRRRRR...........RR#
#R...E......RRRRRR.........RRR#
#R...........RRRRRRR......RRRR#
#R....C......RRRRRRRRRRRRRRRR#
#RRRRRRRRRRRRRRRRRRRRRRRRRRRRRR#
################################
'''),
    enemySpawns: const [
      EnemySpawn(x: 5, y: 4, enemyType: 'dark_acolyte'),
      EnemySpawn(x: 10, y: 4, enemyType: 'dark_acolyte'),
      EnemySpawn(x: 22, y: 6, enemyType: 'fire_imp'),
      EnemySpawn(x: 6, y: 9, enemyType: 'skeleton'),
      EnemySpawn(x: 11, y: 9, enemyType: 'skeleton'),
      EnemySpawn(x: 21, y: 11, enemyType: 'dark_acolyte'),
      EnemySpawn(x: 18, y: 13, enemyType: 'fire_imp'),
      EnemySpawn(x: 24, y: 13, enemyType: 'fire_imp'),
      EnemySpawn(x: 20, y: 15, enemyType: 'infernal_warden'),
      EnemySpawn(x: 8, y: 17, enemyType: 'dark_acolyte'),
      EnemySpawn(x: 5, y: 19, enemyType: 'skeleton'),
    ],
    npcSpawns: const [
      NpcSpawn(
        x: 8,
        y: 11,
        npcId: 'mira',
        name: 'Mira the Priestess',
        dialogueLines: [
          'The Infernal Warden guards the portal!',
          'Defeat him to seal this dark gate!',
          'May the light protect you...',
        ],
      ),
    ],
    chestSpawns: const [
      ChestSpawn(
        x: 6,
        y: 21,
        chestId: 'chest_floor3_1',
        loot: ['potion_health_greater', 'potion_mana'],
      ),
    ],
  );
}
