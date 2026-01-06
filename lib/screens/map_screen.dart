import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../providers/game_provider.dart';
import '../models/tile.dart';
import '../models/character.dart';
import '../widgets/virtual_joystick.dart';
import '../widgets/game_hud.dart';
import '../widgets/action_button.dart';
import '../utils/asset_manager.dart';

class MapScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const MapScreen({super.key, this.onMenuPressed});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleJoystick(JoystickDirection direction) {
    final gameProvider = context.read<GameProvider>();

    switch (direction) {
      case JoystickDirection.up:
        gameProvider.movePlayer(0, -1);
        break;
      case JoystickDirection.down:
        gameProvider.movePlayer(0, 1);
        break;
      case JoystickDirection.left:
        gameProvider.movePlayer(-1, 0);
        break;
      case JoystickDirection.right:
        gameProvider.movePlayer(1, 0);
        break;
      case JoystickDirection.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, _) {
          final map = gameProvider.currentMap;
          final state = gameProvider.state;

          if (map == null || state.character == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.gold),
            );
          }

          return Stack(
            children: [
              // Map background based on theme
              _MapBackground(theme: map.theme),

              // Tilemap
              Positioned.fill(
                child: _TileMapRenderer(
                  map: map,
                  playerPosition: state.currentPosition,
                  pulseAnimation: _pulseController,
                  clearedTiles: state.clearedTiles,
                  openedChests: state.openedChests,
                ),
              ),

              // HUD overlay
              GameHUD(
                onMenuPressed: widget.onMenuPressed,
                onInventoryPressed: () => _showInventorySheet(context),
                onQuestsPressed: () => _showQuestsSheet(context),
              ),

              // Floor indicator
              Positioned(
                top: MediaQuery.paddingOf(context).top + 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.gold.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${map.name} - Floor ${state.currentFloor}',
                      style: GoogleFonts.cinzel(
                        color: AppTheme.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Virtual joystick
              Positioned(
                left: 24,
                bottom: 32 + MediaQuery.paddingOf(context).bottom,
                child: VirtualJoystick(
                  onDirectionChanged: _handleJoystick,
                  size: 130,
                ),
              ),

              // Action buttons
              Positioned(
                right: 24,
                bottom: 48 + MediaQuery.paddingOf(context).bottom,
                child: Column(
                  children: [
                    ActionButton(
                      icon: Icons.search,
                      label: 'Interact',
                      onPressed: () => _handleInteract(gameProvider),
                      color: AppTheme.gold,
                    ),
                    const SizedBox(height: 16),
                    ActionButton(
                      icon: Icons.location_city,
                      label: 'Village',
                      onPressed: () => gameProvider.enterVillage(),
                      color: AppTheme.poison,
                    ),
                  ],
                ),
              ),

              // Activity log
              Positioned(
                left: 8,
                right: 8,
                bottom: 180 + MediaQuery.paddingOf(context).bottom,
                child: _ActivityLog(log: state.activityLog.take(3).toList()),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleInteract(GameProvider gameProvider) {
    final state = gameProvider.state;
    final map = gameProvider.currentMap;
    if (map == null) return;

    final tile = map.getTile(state.currentPosition.x, state.currentPosition.y);

    if (tile.npcId != null) {
      _showNpcDialog(context, tile.npcId!);
    } else if (tile.type == TileType.stairsDown) {
      _showFloorTransition(context, 'Descending...', () {
        gameProvider.changeFloor(state.currentFloor + 1);
      });
    } else if (tile.type == TileType.stairsUp) {
      _showFloorTransition(context, 'Ascending...', () {
        gameProvider.changeFloor(state.currentFloor - 1);
      });
    } else if (tile.type == TileType.town) {
      gameProvider.enterVillage();
    } else if (tile.type == TileType.chest) {
      // Use the chestId from the tile itself if available, otherwise generate one
      final chestId = tile.chestId ?? '${map.id.split('_').last}_${state.currentPosition.x}_${state.currentPosition.y}';
      if (!state.openedChests.contains(chestId)) {
        _showChestLoot(context, gameProvider, chestId);
      }
    }
  }

  void _showFloorTransition(BuildContext context, String message, VoidCallback onTransition) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2A1A10),
                Color(0xFF1A0A05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.gold, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.gold),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.cinzel(
                  color: AppTheme.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.pop(context);
      onTransition();
    });
  }

  void _showChestLoot(BuildContext context, GameProvider gameProvider, String chestId) {
    final map = gameProvider.currentMap;
    if (map == null) return;

    // Find chest spawn data
    final chestSpawn = map.chestSpawns.firstWhere(
      (chest) => chest.chestId == chestId,
      orElse: () => ChestSpawn(
        x: 0,
        y: 0,
        chestId: chestId,
        loot: ['gold_50'],
      ),
    );

    gameProvider.openChest(chestId);

    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2A1A10),
                Color(0xFF1A0A05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.gold, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.card_giftcard,
                color: AppTheme.gold,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'TREASURE FOUND!',
                style: GoogleFonts.cinzel(
                  color: AppTheme.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              ...chestSpawn.loot.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _formatLootItem(item),
                      style: TextStyle(
                        color: AppTheme.boneWhite.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.stoneGray,
                  foregroundColor: AppTheme.gold,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLootItem(String item) {
    if (item.startsWith('gold_')) {
      final amount = item.split('_')[1];
      return '💰 $amount Gold';
    } else if (item.startsWith('potion_')) {
      final parts = item.split('_');
      final type = parts[1];
      final quality = parts.length > 2 ? parts[2] : 'minor';
      return '🧪 ${quality.toUpperCase()} ${type.toUpperCase()} Potion';
    }
    return '✨ $item';
  }

  void _showNpcDialog(BuildContext context, String npcId) {
    final npcData = _getNpcData(npcId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2A1A10),
              Color(0xFF1A0A05),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: AppTheme.gold.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.gold.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(color: AppTheme.gold, width: 2),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.gold,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  npcData['name'] ?? 'NPC',
                  style: GoogleFonts.cinzel(
                    color: AppTheme.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...((npcData['lines'] as List<String>?) ?? []).map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '"$line"',
                  style: TextStyle(
                    color: AppTheme.boneWhite.withOpacity(0.9),
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.stoneGray,
                foregroundColor: AppTheme.gold,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getNpcData(String npcId) {
    switch (npcId) {
      case 'herald':
        return {
          'name': 'The Herald',
          'lines': [
            'Greetings, brave adventurer!',
            'Dark forces stir in these dungeons...',
            'Venture forth and prove your worth!',
          ],
        };
      case 'eldric':
        return {
          'name': 'Eldric the Mage',
          'lines': [
            'You made it through the warrens!',
            'The Infernal Chapel lies below...',
            'But first, defeat the Orc Warlord!',
          ],
        };
      case 'mira':
        return {
          'name': 'Mira the Priestess',
          'lines': [
            'The Infernal Warden guards the portal!',
            'Defeat him to seal this dark gate!',
            'May the light protect you...',
          ],
        };
      default:
        return {
          'name': 'Stranger',
          'lines': ['...'],
        };
    }
  }

  void _showInventorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2A1A10),
                Color(0xFF1A0A05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppTheme.gold.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'INVENTORY',
                style: GoogleFonts.cinzel(
                  color: AppTheme.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: AppTheme.gold.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Full inventory coming soon!',
                        style: TextStyle(
                          color: AppTheme.boneWhite.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuestsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2A1A10),
                Color(0xFF1A0A05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppTheme.gold.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'QUESTS',
                style: GoogleFonts.cinzel(
                  color: AppTheme.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<GameProvider>(
                  builder: (context, provider, _) {
                    final quests = provider.state.quests;
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: quests.length,
                      itemBuilder: (context, index) {
                        final quest = quests[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.darkGold.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      quest.title,
                                      style: GoogleFonts.cinzel(
                                        color: AppTheme.gold,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(quest.status)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      quest.status.name.toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(quest.status),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                quest.description,
                                style: TextStyle(
                                  color: AppTheme.boneWhite.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(dynamic status) {
    switch (status.toString()) {
      case 'QuestStatus.completed':
        return AppTheme.poison;
      case 'QuestStatus.active':
        return AppTheme.gold;
      case 'QuestStatus.available':
        return AppTheme.mana;
      default:
        return AppTheme.ashGray;
    }
  }
}

class _MapBackground extends StatelessWidget {
  final String theme;

  const _MapBackground({required this.theme});

  @override
  Widget build(BuildContext context) {
    List<Color> colors;

    switch (theme) {
      case 'verdant':
        colors = [
          const Color(0xFF0A1A0A),
          const Color(0xFF050F05),
          const Color(0xFF020502),
        ];
        break;
      case 'molten':
        colors = [
          const Color(0xFF1A0A05),
          const Color(0xFF100505),
          const Color(0xFF050202),
        ];
        break;
      case 'infernal':
        colors = [
          const Color(0xFF1A0505),
          const Color(0xFF0F0303),
          const Color(0xFF050101),
        ];
        break;
      default:
        colors = [
          const Color(0xFF0A0A0A),
          const Color(0xFF050505),
          const Color(0xFF020202),
        ];
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
    );
  }
}

class _TileMapRenderer extends StatelessWidget {
  final GameMap map;
  final dynamic playerPosition;
  final AnimationController pulseAnimation;
  final Set<String> clearedTiles;
  final Set<String> openedChests;

  const _TileMapRenderer({
    required this.map,
    required this.playerPosition,
    required this.pulseAnimation,
    required this.clearedTiles,
    required this.openedChests,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final tileSize = (size.width / 16).clamp(20.0, 48.0);
    final viewportTilesX = (size.width / tileSize).ceil();
    final viewportTilesY = (size.height / tileSize).ceil();

    final maxStartX = (map.width - viewportTilesX).clamp(0, map.width);
    final maxStartY = (map.height - viewportTilesY).clamp(0, map.height);
    final startX = (playerPosition.x - viewportTilesX ~/ 2).clamp(0, maxStartX);
    final startY = (playerPosition.y - viewportTilesY ~/ 2).clamp(0, maxStartY);

    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final character = gameProvider.state.character;
        if (character == null) return const SizedBox.shrink();

        return AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, _) {
            return _ImageBasedMapRenderer(
              map: map,
              character: character,
              playerPosition: playerPosition,
              startX: startX,
              startY: startY,
              tileSize: tileSize,
              viewportWidth: viewportTilesX,
              viewportHeight: viewportTilesY,
              pulseValue: pulseAnimation.value,
              clearedTiles: clearedTiles,
              openedChests: openedChests,
            );
          },
        );
      },
    );
  }
}

class _ImageBasedMapRenderer extends StatelessWidget {
  final GameMap map;
  final Character character;
  final dynamic playerPosition;
  final int startX;
  final int startY;
  final double tileSize;
  final int viewportWidth;
  final int viewportHeight;
  final double pulseValue;
  final Set<String> clearedTiles;
  final Set<String> openedChests;

  const _ImageBasedMapRenderer({
    required this.map,
    required this.character,
    required this.playerPosition,
    required this.startX,
    required this.startY,
    required this.tileSize,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.pulseValue,
    required this.clearedTiles,
    required this.openedChests,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final offsetX = (size.width - viewportWidth * tileSize) / 2;
    final offsetY = (size.height - viewportHeight * tileSize) / 2;

    return Stack(
      children: [
        ...List.generate(viewportHeight, (y) {
          return List.generate(viewportWidth, (x) {
            final mapX = startX + x;
            final mapY = startY + y;
            
            if (mapX >= map.width || mapY >= map.height) {
              return const SizedBox.shrink();
            }

            final tile = map.getTile(mapX, mapY);
            final left = offsetX + x * tileSize;
            final top = offsetY + y * tileSize;

            return Positioned(
              left: left,
              top: top,
              width: tileSize,
              height: tileSize,
              child: _TileImage(
                tile: tile,
                mapX: mapX,
                mapY: mapY,
                mapId: map.id,
                openedChests: openedChests,
                pulseValue: pulseValue,
              ),
            );
          });
        }).expand((widgets) => widgets),

        // Render player sprite
        Positioned(
          left: offsetX + (playerPosition.x - startX) * tileSize,
          top: offsetY + (playerPosition.y - startY) * tileSize,
          width: tileSize,
          height: tileSize,
          child: Transform.scale(
            scale: 1.0 + (pulseValue * 0.05),
            child: Image.asset(
              AssetManager.getPlayerSprite(character.characterClass),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.mana,
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TileImage extends StatelessWidget {
  final MapTile tile;
  final int mapX;
  final int mapY;
  final String mapId;
  final Set<String> openedChests;
  final double pulseValue;

  const _TileImage({
    required this.tile,
    required this.mapX,
    required this.mapY,
    required this.mapId,
    required this.openedChests,
    required this.pulseValue,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AssetManager.getTileAsset(tile.type.toString().split('.').last, tile.isWalkable),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: tile.baseColor);
          },
        ),

        if (tile.type == TileType.chest)
          _ChestSprite(
            mapId: mapId,
            mapX: mapX,
            mapY: mapY,
            tileChestId: tile.chestId,
            openedChests: openedChests,
          )
        else if (tile.type == TileType.stairsDown || tile.type == TileType.stairsUp)
          _StairsSprite(isDown: tile.type == TileType.stairsDown)
        else if (tile.npcId != null)
          _NpcSprite(npcId: tile.npcId!, pulseValue: pulseValue)
        else if (tile.enemyType != null && !tile.isCleared)
          _EnemySprite(enemyType: tile.enemyType!, pulseValue: pulseValue),
      ],
    );
  }
}

class _ChestSprite extends StatelessWidget {
  final String mapId;
  final int mapX;
  final int mapY;
  final String? tileChestId;
  final Set<String> openedChests;

  const _ChestSprite({
    required this.mapId,
    required this.mapX,
    required this.mapY,
    this.tileChestId,
    required this.openedChests,
  });

  @override
  Widget build(BuildContext context) {
    final chestId = tileChestId ?? '${mapId.split('_').last}_${mapX}_$mapY';
    final isOpened = openedChests.contains(chestId);

    return Image.asset(
      AssetManager.getChestAsset(isOpened),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isOpened ? const Color(0xFF8B4513) : AppTheme.gold,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }
}

class _StairsSprite extends StatelessWidget {
  final bool isDown;

  const _StairsSprite({required this.isDown});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AssetManager.getStairsAsset(!isDown),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            isDown ? Icons.arrow_downward : Icons.arrow_upward,
            color: isDown ? AppTheme.voidPurple : AppTheme.mana,
            size: 24,
          ),
        );
      },
    );
  }
}

class _NpcSprite extends StatelessWidget {
  final String npcId;
  final double pulseValue;

  const _NpcSprite({
    required this.npcId,
    required this.pulseValue,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.0 + (pulseValue * 0.03),
      child: Image.asset(
        AssetManager.getNpcSprite(npcId),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: const BoxDecoration(
              color: AppTheme.stoneGray,
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}

class _EnemySprite extends StatelessWidget {
  final String enemyType;
  final double pulseValue;

  const _EnemySprite({
    required this.enemyType,
    required this.pulseValue,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.0 + (pulseValue * 0.05),
      child: Image.asset(
        AssetManager.getEnemySprite(enemyType),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: const BoxDecoration(
              color: AppTheme.crimson,
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}

class _ActivityLog extends StatelessWidget {
  final List<String> log;

  const _ActivityLog({required this.log});

  @override
  Widget build(BuildContext context) {
    if (log.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: log
            .map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    entry,
                    style: TextStyle(
                      color: AppTheme.boneWhite.withOpacity(0.8),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
      ),
    );
  }
}
