import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../providers/game_provider.dart';
import '../models/tile.dart';
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
      final chestId = '${map.id.split('_').last}_${state.currentPosition.x}_${state.currentPosition.y}';
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
      orElse: () => const ChestSpawn(
        x: 0,
        y: 0,
        chestId: '',
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
    final tileSize = (size.width / 16).clamp(20.0, 48.0); // Larger for HD assets
    final viewportTilesX = (size.width / tileSize).ceil();
    final viewportTilesY = (size.height / tileSize).ceil();

    // Center viewport on player
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

/// Renders the map using HD image assets instead of procedural drawing
class _ImageBasedMapRenderer extends StatelessWidget {
  final GameMap map;
  final dynamic character;
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
        // Render all tiles
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
                // Fallback to simple colored circle for player
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

/// Renders a single tile with its image asset (with fallback for missing assets)
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
        // Base tile image with fallback to colored container
        Image.asset(
          AssetManager.getTileAsset(tile.type.toString().split('.').last, tile.isWalkable),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to colored container if image not found
            return Container(color: tile.baseColor);
          },
        ),

        // Overlay sprites (chests, stairs, NPCs, enemies)
        if (tile.type == TileType.chest)
          _ChestSprite(
            mapId: mapId,
            mapX: mapX,
            mapY: mapY,
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

/// Chest sprite that changes based on open state
class _ChestSprite extends StatelessWidget {
  final String mapId;
  final int mapX;
  final int mapY;
  final Set<String> openedChests;

  const _ChestSprite({
    required this.mapId,
    required this.mapX,
    required this.mapY,
    required this.openedChests,
  });

  @override
  Widget build(BuildContext context) {
    final chestId = '${mapId.split('_').last}_${mapX}_$mapY';
    final isOpened = openedChests.contains(chestId);

    return Image.asset(
      AssetManager.getChestAsset(isOpened),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to colored square for chest
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

/// Stairs sprite
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
        // Fallback to colored triangle for stairs
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

/// NPC sprite with pulse animation
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
          // Fallback to colored circle for NPC
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

/// Enemy sprite with pulse animation
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
          // Fallback to colored circle for enemy
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

class _MapPainter extends CustomPainter {
  final GameMap map;
  final int playerX;
  final int playerY;
  final int startX;
  final int startY;
  final double tileSize;
  final int viewportWidth;
  final int viewportHeight;
  final double pulseValue;
  final Set<String> clearedTiles;
  final Set<String> openedChests;

  _MapPainter({
    required this.map,
    required this.playerX,
    required this.playerY,
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
  void paint(Canvas canvas, Size size) {
    // Safety check: prevent rendering with invalid dimensions
    if (size.width <= 0 || size.height <= 0 || tileSize <= 0) {
      return;
    }
    
    final offsetX = (size.width - viewportWidth * tileSize) / 2;
    final offsetY = (size.height - viewportHeight * tileSize) / 2;

    // Draw tiles with enhanced textures
    for (int y = 0; y < viewportHeight && startY + y < map.height; y++) {
      for (int x = 0; x < viewportWidth && startX + x < map.width; x++) {
        final mapX = startX + x;
        final mapY = startY + y;
        final tile = map.getTile(mapX, mapY);

        final rect = Rect.fromLTWH(
          offsetX + x * tileSize,
          offsetY + y * tileSize,
          tileSize,
          tileSize,
        );

        // Draw enhanced tile with textures
        _drawEnhancedTile(canvas, tile, rect, mapX, mapY);

        // Draw special tile markers
        if (tile.type == TileType.chest) {
          final chestId = '${map.id.split('_').last}_${mapX}_$mapY';
          final isOpened = openedChests.contains(chestId);
          _drawChest(canvas, rect, isOpened);
        } else if (tile.type == TileType.stairsDown) {
          _drawStairs(canvas, rect, true);
        } else if (tile.type == TileType.stairsUp) {
          _drawStairs(canvas, rect, false);
        } else if (tile.npcId != null) {
          _drawNpcSprite(canvas, rect);
        }

        // Draw enemy spawn markers
        if (tile.enemyType != null && !tile.isCleared) {
          _drawEnemySprite(canvas, rect, tile.enemyType!);
        }
      }
    }

    // Draw player sprite
    final playerScreenX = (playerX - startX) * tileSize + offsetX;
    final playerScreenY = (playerY - startY) * tileSize + offsetY;

    final playerRect = Rect.fromLTWH(
      playerScreenX,
      playerScreenY,
      tileSize,
      tileSize,
    );

    _drawPlayerSprite(canvas, playerRect);
  }

  void _drawEnhancedTile(Canvas canvas, MapTile tile, Rect rect, int x, int y) {
    // Skip invalid tiles
    if (rect.width <= 0 || rect.height <= 0 || tileSize < 2) return;
    
    final paint = Paint()..color = tile.baseColor;
    
    // Base tile - always draw this
    canvas.drawRect(rect, paint);

    // Add texture details based on tile type - only if tile is large enough
    if (tileSize >= 8) {
      switch (tile.type) {
        case TileType.grass:
          _drawGrassTexture(canvas, rect, x, y);
          break;
        case TileType.floor:
          _drawFloorTexture(canvas, rect, x, y);
          break;
        case TileType.wall:
          _drawWallTexture(canvas, rect, x, y);
          break;
        case TileType.water:
          _drawWaterTexture(canvas, rect);
          break;
        case TileType.lava:
          _drawLavaTexture(canvas, rect);
          break;
        case TileType.tree:
          _drawTreeSprite(canvas, rect);
          break;
        case TileType.mountain:
          _drawMountainTexture(canvas, rect);
          break;
        case TileType.bridge:
          _drawBridgeTexture(canvas, rect);
          break;
        case TileType.ruins:
          _drawRuinsTexture(canvas, rect, x, y);
          break;
        case TileType.ice:
          _drawIceTexture(canvas, rect);
          break;
        case TileType.door:
          _drawDoorSprite(canvas, rect);
          break;
        case TileType.path:
          _drawPathTexture(canvas, rect, x, y);
          break;
        default:
          break;
      }
    }

    // Tile border for depth
    if (tileSize > 4) {
      final borderPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawRect(rect, borderPaint);
    }
  }

  void _drawGrassTexture(Canvas canvas, Rect rect, int x, int y) {
    final paint = Paint()..color = const Color(0xFF1A5C1A).withOpacity(0.5);
    final seed = (x * 7 + y * 13) % 5;
    
    for (int i = 0; i < 3; i++) {
      final offsetX = ((seed + i * 3) % 7 - 3) * rect.width / 10;
      final offsetY = ((seed * 2 + i * 5) % 7 - 3) * rect.height / 10;
      final radius = (rect.width * 0.08).clamp(0.5, double.infinity);
      
      canvas.drawCircle(
        rect.center + Offset(offsetX, offsetY),
        radius,
        paint,
      );
    }
  }

  void _drawFloorTexture(Canvas canvas, Rect rect, int x, int y) {
    final darkPaint = Paint()..color = const Color(0xFF3D2A1A).withOpacity(0.3);
    final seed = (x * 11 + y * 17) % 10;
    
    // Stone tiles pattern
    final tileW = rect.width / 2;
    final tileH = rect.height / 2;
    
    for (int ty = 0; ty < 2; ty++) {
      for (int tx = 0; tx < 2; tx++) {
        if ((seed + tx + ty) % 3 == 0) {
          final tileRect = Rect.fromLTWH(
            rect.left + tx * tileW,
            rect.top + ty * tileH,
            tileW,
            tileH,
          );
          canvas.drawRect(tileRect, darkPaint);
        }
      }
    }
  }

  void _drawWallTexture(Canvas canvas, Rect rect, int x, int y) {
    final basePaint = Paint()..color = const Color(0xFF2A2A2A);
    canvas.drawRect(rect, basePaint);
    
    // Stone blocks
    final blockPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final midY = rect.top + rect.height / 2;
    canvas.drawLine(
      Offset(rect.left, midY),
      Offset(rect.right, midY),
      blockPaint,
    );
    
    // Vertical line offset
    final midX = rect.left + (y % 2 == 0 ? rect.width / 2 : 0);
    if (midX > rect.left) {
      canvas.drawLine(
        Offset(midX, rect.top),
        Offset(midX, rect.bottom),
        blockPaint,
      );
    }
    
    // Highlights
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.05);
    if (rect.width > 2 && rect.height > 2) {
      canvas.drawRect(
        Rect.fromLTWH(rect.left + 1, rect.top + 1, rect.width - 2, 2),
        highlightPaint,
      );
    }
  }

  void _drawWaterTexture(Canvas canvas, Rect rect) {
    final waterPaint1 = Paint()..color = const Color(0xFF1565C0).withOpacity(0.6);
    final waterPaint2 = Paint()..color = const Color(0xFF0D47A1).withOpacity(0.3);
    
    canvas.drawRect(rect, waterPaint1);
    
    // Waves
    final waveOffset = (pulseValue * rect.height * 0.5).toInt();
    for (int i = 0; i < 3; i++) {
      final y = rect.top + (i * rect.height / 3 + waveOffset) % rect.height;
      final radius = (rect.width * 0.15).clamp(0.5, double.infinity);
      
      canvas.drawCircle(
        Offset(rect.center.dx, y),
        radius,
        waterPaint2,
      );
    }
  }

  void _drawLavaTexture(Canvas canvas, Rect rect) {
    // Animated lava
    final lava1 = Paint()..color = AppTheme.hellfire;
    final lava2 = Paint()..color = const Color(0xFFFF6600);
    final lava3 = Paint()..color = const Color(0xFF990000);
    
    canvas.drawRect(rect, lava3);
    
    // Bubbles
    final bubbleOffset = (pulseValue * rect.height).toInt();
    for (int i = 0; i < 4; i++) {
      final x = rect.left + (i * rect.width / 4);
      final y = rect.top + (i * rect.height / 4 + bubbleOffset) % rect.height;
      final radius = (rect.width * 0.12).clamp(0.5, double.infinity);
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        i % 2 == 0 ? lava1 : lava2,
      );
    }
    
    // Glow
    final glowPaint = Paint()
      ..color = AppTheme.hellfire.withOpacity(0.3 + pulseValue * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRect(rect, glowPaint);
  }

  void _drawTreeSprite(Canvas canvas, Rect rect) {
    // Tree trunk
    final trunkPaint = Paint()..color = const Color(0xFF3D2817);
    final trunkWidth = (rect.width * 0.25).clamp(1.0, double.infinity);
    final trunkHeight = (rect.height * 0.5).clamp(1.0, double.infinity);
    
    final trunkRect = Rect.fromCenter(
      center: rect.center + Offset(0, rect.height * 0.15),
      width: trunkWidth,
      height: trunkHeight,
    );
    final cornerRadius = (rect.width * 0.05).clamp(0.0, trunkWidth / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(trunkRect, Radius.circular(cornerRadius)),
      trunkPaint,
    );
    
    // Tree foliage
    final foliagePaint = Paint()..color = const Color(0xFF0B5345);
    final foliageRadius = (rect.width * 0.3).clamp(0.5, double.infinity);
    
    // Three circles for bushy top
    for (int i = 0; i < 3; i++) {
      final offsetY = i * rect.height * 0.12 - rect.height * 0.2;
      canvas.drawCircle(
        rect.center + Offset(0, offsetY),
        foliageRadius,
        foliagePaint,
      );
    }
    
    // Highlight
    final highlightPaint = Paint()..color = const Color(0xFF0E7C5E).withOpacity(0.6);
    final highlightRadius = (foliageRadius / 1.5).clamp(0.3, double.infinity);
    canvas.drawCircle(
      rect.center + Offset(-rect.width * 0.1, -rect.height * 0.25),
      highlightRadius,
      highlightPaint,
    );
  }

  void _drawMountainTexture(Canvas canvas, Rect rect) {
    final mountainPaint = Paint()..color = const Color(0xFF696969);
    final path = Path();
    
    // Mountain shape
    path.moveTo(rect.left, rect.bottom);
    path.lineTo(rect.center.dx, rect.top + rect.height * 0.2);
    path.lineTo(rect.right, rect.bottom);
    path.close();
    
    canvas.drawPath(path, mountainPaint);
    
    // Snow cap
    final snowPaint = Paint()..color = Colors.white.withOpacity(0.7);
    final snowPath = Path();
    snowPath.moveTo(rect.center.dx - rect.width * 0.2, rect.top + rect.height * 0.35);
    snowPath.lineTo(rect.center.dx, rect.top + rect.height * 0.2);
    snowPath.lineTo(rect.center.dx + rect.width * 0.2, rect.top + rect.height * 0.35);
    snowPath.close();
    canvas.drawPath(snowPath, snowPaint);
    
    // Shadow
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.3);
    final shadowPath = Path();
    shadowPath.moveTo(rect.center.dx, rect.top + rect.height * 0.2);
    shadowPath.lineTo(rect.right, rect.bottom);
    shadowPath.lineTo(rect.center.dx, rect.bottom);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);
  }

  void _drawBridgeTexture(Canvas canvas, Rect rect) {
    final woodPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawRect(rect, woodPaint);
    
    // Planks
    final plankPaint = Paint()
      ..color = const Color(0xFF654321)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    for (int i = 0; i < 4; i++) {
      final y = rect.top + (i * rect.height / 4);
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        plankPaint,
      );
    }
  }

  void _drawRuinsTexture(Canvas canvas, Rect rect, int x, int y) {
    final ruinPaint = Paint()..color = const Color(0xFF483D8B);
    canvas.drawRect(rect, ruinPaint);
    
    // Broken pillars/stones
    final stonePaint = Paint()..color = const Color(0xFF6A5ACD);
    final seed = (x * 3 + y * 7) % 4;
    
    if (seed > 0) {
      final stoneRect = Rect.fromCenter(
        center: rect.center,
        width: rect.width * 0.6,
        height: rect.height * 0.6,
      );
      canvas.drawRect(stoneRect, stonePaint);
      
      // Cracks
      final crackPaint = Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..strokeWidth = 1.0;
      canvas.drawLine(
        stoneRect.topCenter,
        stoneRect.bottomCenter + Offset(rect.width * 0.1, 0),
        crackPaint,
      );
    }
  }

  void _drawIceTexture(Canvas canvas, Rect rect) {
    final icePaint = Paint()..color = AppTheme.ice;
    canvas.drawRect(rect, icePaint);
    
    // Ice crystals
    final crystalPaint = Paint()..color = Colors.white.withOpacity(0.4);
    final crystalRadius = (rect.width * 0.1).clamp(0.5, double.infinity);
    
    for (int i = 0; i < 2; i++) {
      final offset = Offset(
        rect.width * (0.25 + i * 0.5),
        rect.height * (0.25 + i * 0.5),
      );
      canvas.drawCircle(rect.topLeft + offset, crystalRadius, crystalPaint);
    }
    
    // Shine effect
    final shinePaint = Paint()..color = Colors.white.withOpacity(0.2 + pulseValue * 0.1);
    final shineRadius = (rect.width * 0.25).clamp(0.5, double.infinity);
    
    canvas.drawCircle(
      rect.center + Offset(-rect.width * 0.2, -rect.height * 0.2),
      shineRadius,
      shinePaint,
    );
  }

  void _drawDoorSprite(Canvas canvas, Rect rect) {
    final doorPaint = Paint()..color = const Color(0xFF8B4513);
    final doorWidth = (rect.width * 0.8).clamp(1.0, double.infinity);
    final doorHeight = (rect.height * 0.9).clamp(1.0, double.infinity);
    
    final doorRect = Rect.fromCenter(
      center: rect.center,
      width: doorWidth,
      height: doorHeight,
    );
    
    final cornerRadius = (rect.width * 0.1).clamp(0.0, doorWidth / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(doorRect, Radius.circular(cornerRadius)),
      doorPaint,
    );
    
    // Door planks
    final plankPaint = Paint()
      ..color = const Color(0xFF654321)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawLine(
      Offset(doorRect.left, doorRect.center.dy),
      Offset(doorRect.right, doorRect.center.dy),
      plankPaint,
    );
    
    canvas.drawLine(
      Offset(doorRect.center.dx, doorRect.top),
      Offset(doorRect.center.dx, doorRect.bottom),
      plankPaint,
    );
    
    // Door handle
    final handlePaint = Paint()..color = AppTheme.gold;
    final handleRadius = (rect.width * 0.08).clamp(0.5, double.infinity);
    
    canvas.drawCircle(
      Offset(doorRect.right - rect.width * 0.2, doorRect.center.dy),
      handleRadius,
      handlePaint,
    );
  }

  void _drawPathTexture(Canvas canvas, Rect rect, int x, int y) {
    final pathPaint = Paint()..color = const Color(0xFF8B7355);
    canvas.drawRect(rect, pathPaint);
    
    // Pebbles
    final pebblePaint = Paint()..color = const Color(0xFF6B5A45);
    final seed = (x * 5 + y * 11) % 8;
    final pebbleRadius = (rect.width * 0.06).clamp(0.5, double.infinity);
    
    for (int i = 0; i < 2; i++) {
      final offsetX = ((seed + i * 4) % 5 - 2) * rect.width / 8;
      final offsetY = ((seed * 3 + i * 6) % 5 - 2) * rect.height / 8;
      canvas.drawCircle(
        rect.center + Offset(offsetX, offsetY),
        pebbleRadius,
        pebblePaint,
      );
    }
  }

  void _drawPlayerSprite(Canvas canvas, Rect rect) {
    // Player shadow
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.3);
    final shadowWidth = (rect.width * 0.6).clamp(1.0, double.infinity);
    final shadowHeight = (rect.height * 0.15).clamp(0.5, double.infinity);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: rect.center + Offset(0, rect.height * 0.35),
        width: shadowWidth,
        height: shadowHeight,
      ),
      shadowPaint,
    );
    
    // Player glow aura
    final glowPaint = Paint()
      ..color = AppTheme.gold.withOpacity(0.3 + pulseValue * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final glowRadius = (rect.width * 0.5).clamp(0.5, double.infinity);
    
    canvas.drawCircle(rect.center, glowRadius, glowPaint);

    // Player body (humanoid figure)
    final bodyPaint = Paint()..color = AppTheme.gold;
    final headSize = (rect.width * 0.25).clamp(0.5, double.infinity);
    final bodyWidth = (rect.width * 0.35).clamp(1.0, double.infinity);
    final bodyHeight = (rect.height * 0.35).clamp(1.0, double.infinity);
    
    // Head
    canvas.drawCircle(
      rect.center - Offset(0, rect.height * 0.15),
      headSize,
      bodyPaint,
    );
    
    // Body
    final bodyRect = Rect.fromCenter(
      center: rect.center + Offset(0, rect.height * 0.1),
      width: bodyWidth,
      height: bodyHeight,
    );
    final cornerRadius = (rect.width * 0.05).clamp(0.0, bodyWidth / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(cornerRadius)),
      bodyPaint,
    );

    // Arms
    final armStrokeWidth = (rect.width * 0.12).clamp(0.5, double.infinity);
    final armPaint = Paint()
      ..color = AppTheme.gold
      ..strokeWidth = armStrokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Left arm
    canvas.drawLine(
      Offset(bodyRect.left, bodyRect.top + bodyHeight * 0.2),
      Offset(bodyRect.left - rect.width * 0.15, bodyRect.center.dy),
      armPaint,
    );
    
    // Right arm
    canvas.drawLine(
      Offset(bodyRect.right, bodyRect.top + bodyHeight * 0.2),
      Offset(bodyRect.right + rect.width * 0.15, bodyRect.center.dy),
      armPaint,
    );
    
    // Legs
    final legStrokeWidth = (rect.width * 0.12).clamp(0.5, double.infinity);
    final legPaint = Paint()
      ..color = AppTheme.gold
      ..strokeWidth = legStrokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Left leg
    canvas.drawLine(
      Offset(bodyRect.center.dx - bodyWidth * 0.2, bodyRect.bottom),
      Offset(bodyRect.center.dx - bodyWidth * 0.2, rect.bottom - rect.height * 0.1),
      legPaint,
    );
    
    // Right leg
    canvas.drawLine(
      Offset(bodyRect.center.dx + bodyWidth * 0.2, bodyRect.bottom),
      Offset(bodyRect.center.dx + bodyWidth * 0.2, rect.bottom - rect.height * 0.1),
      legPaint,
    );

    // Face details
    final eyePaint = Paint()..color = Colors.white;
    final eyeSize = (rect.width * 0.05).clamp(0.3, double.infinity);
    
    canvas.drawCircle(
      rect.center - Offset(headSize * 0.4, rect.height * 0.18),
      eyeSize,
      eyePaint,
    );
    canvas.drawCircle(
      rect.center - Offset(-headSize * 0.4, rect.height * 0.18),
      eyeSize,
      eyePaint,
    );
    
    // Highlight on head
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.4);
    final highlightRadius = (headSize * 0.4).clamp(0.3, double.infinity);
    canvas.drawCircle(
      rect.center - Offset(headSize * 0.3, rect.height * 0.25),
      highlightRadius,
      highlightPaint,
    );
  }

  void _drawNpcSprite(Canvas canvas, Rect rect) {
    // NPC figure (similar to player but blue)
    const npcColor = AppTheme.mana;
    
    // NPC shadow
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.3);
    final shadowWidth = (rect.width * 0.6).clamp(1.0, double.infinity);
    final shadowHeight = (rect.height * 0.15).clamp(0.5, double.infinity);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: rect.center + Offset(0, rect.height * 0.35),
        width: shadowWidth,
        height: shadowHeight,
      ),
      shadowPaint,
    );
    
    // NPC glow
    final glowPaint = Paint()
      ..color = npcColor.withOpacity(0.4 + pulseValue * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final glowRadius = (rect.width * 0.5).clamp(0.5, double.infinity);
    
    canvas.drawCircle(rect.center, glowRadius, glowPaint);

    // NPC body
    final bodyPaint = Paint()..color = npcColor;
    final headSize = (rect.width * 0.25).clamp(0.5, double.infinity);
    final bodyWidth = (rect.width * 0.35).clamp(1.0, double.infinity);
    
    // Head
    canvas.drawCircle(
      rect.center - Offset(0, rect.height * 0.15),
      headSize,
      bodyPaint,
    );
    
    // Body (robe-like)
    final bodyPath = Path();
    final bodyTop = rect.center - Offset(0, rect.height * 0.05);
    bodyPath.moveTo(bodyTop.dx - bodyWidth / 2, bodyTop.dy);
    bodyPath.lineTo(bodyTop.dx + bodyWidth / 2, bodyTop.dy);
    bodyPath.lineTo(rect.center.dx + bodyWidth * 0.7, rect.bottom - rect.height * 0.1);
    bodyPath.lineTo(rect.center.dx - bodyWidth * 0.7, rect.bottom - rect.height * 0.1);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);
    
    // Staff
    final staffStrokeWidth = (rect.width * 0.08).clamp(0.5, double.infinity);
    final staffPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..strokeWidth = staffStrokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(rect.right - rect.width * 0.15, rect.center.dy),
      Offset(rect.right - rect.width * 0.15, rect.top + rect.height * 0.1),
      staffPaint,
    );
    
    // Orb on staff
    final orbPaint = Paint()..color = AppTheme.gold;
    final orbRadius = (rect.width * 0.1).clamp(0.5, double.infinity);
    
    canvas.drawCircle(
      Offset(rect.right - rect.width * 0.15, rect.top + rect.height * 0.1),
      orbRadius,
      orbPaint,
    );
    
    // Exclamation marker
    final markerPaint = Paint()..color = AppTheme.gold;
    final markerSize = rect.width * 0.15;
    final markerWidth = (markerSize * 0.4).clamp(0.5, double.infinity);
    final markerHeight = (markerSize * 1.2).clamp(1.0, double.infinity);
    
    // Exclamation body
    final cornerRadius = (markerSize * 0.1).clamp(0.0, markerWidth / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: rect.topCenter + Offset(0, markerSize * 0.8),
          width: markerWidth,
          height: markerHeight,
        ),
        Radius.circular(cornerRadius),
      ),
      markerPaint,
    );
    
    // Exclamation dot
    final dotRadius = (markerSize * 0.2).clamp(0.3, double.infinity);
    canvas.drawCircle(
      rect.topCenter + Offset(0, markerSize * 1.8),
      dotRadius,
      markerPaint,
    );
  }

  void _drawEnemySprite(Canvas canvas, Rect rect, String enemyType) {
    Color enemyColor;
    
    switch (enemyType) {
      case 'goblin':
        enemyColor = const Color(0xFF228B22);
        break;
      case 'fire_imp':
        enemyColor = AppTheme.hellfire;
        break;
      case 'orc_warrior':
      case 'orc_warlord':
        enemyColor = const Color(0xFF8B4513);
        break;
      case 'skeleton':
        enemyColor = const Color(0xFFE0E0E0);
        break;
      case 'dark_acolyte':
        enemyColor = const Color(0xFF4B0082);
        break;
      case 'infernal_warden':
        enemyColor = AppTheme.crimson;
        break;
      default:
        enemyColor = AppTheme.crimson;
    }
    
    // Enemy shadow
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.4);
    final shadowWidth = (rect.width * 0.6).clamp(1.0, double.infinity);
    final shadowHeight = (rect.height * 0.15).clamp(0.5, double.infinity);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: rect.center + Offset(0, rect.height * 0.35),
        width: shadowWidth,
        height: shadowHeight,
      ),
      shadowPaint,
    );
    
    // Enemy glow (pulsing)
    final glowPaint = Paint()
      ..color = enemyColor.withOpacity(0.3 + pulseValue * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final glowRadius = (rect.width * 0.5).clamp(0.5, double.infinity);
    
    canvas.drawCircle(rect.center, glowRadius, glowPaint);

    // Enemy body (menacing figure)
    final bodyPaint = Paint()..color = enemyColor;
    final headSize = (rect.width * 0.28).clamp(0.5, double.infinity);
    final bodyWidth = (rect.width * 0.4).clamp(1.0, double.infinity);
    final bodyHeight = (rect.height * 0.4).clamp(1.0, double.infinity);
    
    // Head (slightly larger and more menacing)
    canvas.drawCircle(
      rect.center - Offset(0, rect.height * 0.15),
      headSize,
      bodyPaint,
    );
    
    // Horns or spikes
    final hornPaint = Paint()..color = enemyColor.withOpacity(0.8);
    final hornPath = Path();
    
    // Left horn
    hornPath.moveTo(rect.center.dx - headSize * 0.7, rect.center.dy - rect.height * 0.15);
    hornPath.lineTo(rect.center.dx - headSize * 1.1, rect.top);
    hornPath.lineTo(rect.center.dx - headSize * 0.5, rect.center.dy - rect.height * 0.15);
    hornPath.close();
    canvas.drawPath(hornPath, hornPaint);
    
    // Right horn
    final hornPath2 = Path();
    hornPath2.moveTo(rect.center.dx + headSize * 0.7, rect.center.dy - rect.height * 0.15);
    hornPath2.lineTo(rect.center.dx + headSize * 1.1, rect.top);
    hornPath2.lineTo(rect.center.dx + headSize * 0.5, rect.center.dy - rect.height * 0.15);
    hornPath2.close();
    canvas.drawPath(hornPath2, hornPaint);
    
    // Body (bulkier than player)
    final bodyRect = Rect.fromCenter(
      center: rect.center + Offset(0, rect.height * 0.12),
      width: bodyWidth,
      height: bodyHeight,
    );
    final cornerRadius = (rect.width * 0.05).clamp(0.0, bodyWidth / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(cornerRadius)),
      bodyPaint,
    );
    
    // Menacing eyes
    final eyePaint = Paint()..color = AppTheme.crimson;
    final eyeSize = (rect.width * 0.06).clamp(0.3, double.infinity);
    
    canvas.drawCircle(
      rect.center - Offset(headSize * 0.4, rect.height * 0.18),
      eyeSize,
      eyePaint,
    );
    canvas.drawCircle(
      rect.center - Offset(-headSize * 0.4, rect.height * 0.18),
      eyeSize,
      eyePaint,
    );
    
    // Weapon indicator (skull icon overlay)
    final dangerPaint = Paint()..color = Colors.red.withOpacity(0.7);
    final dangerRadius = (rect.width * 0.12).clamp(0.5, double.infinity);
    
    canvas.drawCircle(
      rect.topRight - Offset(rect.width * 0.2, -rect.height * 0.2),
      dangerRadius,
      dangerPaint,
    );
  }

  void _drawChest(Canvas canvas, Rect rect, bool isOpened) {
    if (tileSize < 2) return;
    
    final paint = Paint()
      ..color = isOpened
          ? const Color(0xFF8B4513)
          : const Color(0xFFFFD700);

    final chestWidth = (tileSize * 0.6).clamp(1.0, double.infinity);
    final chestHeight = (tileSize * 0.5).clamp(1.0, double.infinity);

    final chestRect = Rect.fromCenter(
      center: rect.center,
      width: chestWidth,
      height: chestHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(chestRect, const Radius.circular(2)),
      paint,
    );

    if (!isOpened) {
      // Draw glow for unopened chest
      final glowPaint = Paint()
        ..color = AppTheme.gold.withOpacity(0.3 + pulseValue * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      final glowRadius = (tileSize * 0.4).clamp(0.5, double.infinity);
      
      canvas.drawCircle(rect.center, glowRadius, glowPaint);
    }
  }

  void _drawStairs(Canvas canvas, Rect rect, bool isDown) {
    if (tileSize < 2) return;
    
    final paint = Paint()
      ..color = isDown ? AppTheme.voidPurple : AppTheme.mana;

    final center = rect.center;
    final size = (tileSize * 0.3).clamp(1.0, double.infinity);

    final path = Path();
    if (isDown) {
      path.moveTo(center.dx, center.dy + size);
      path.lineTo(center.dx - size, center.dy - size);
      path.lineTo(center.dx + size, center.dy - size);
    } else {
      path.moveTo(center.dx, center.dy - size);
      path.lineTo(center.dx - size, center.dy + size);
      path.lineTo(center.dx + size, center.dy + size);
    }
    path.close();

    canvas.drawPath(path, paint);

    // Glow
    final glowPaint = Paint()
      ..color = paint.color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return playerX != oldDelegate.playerX ||
        playerY != oldDelegate.playerY ||
        pulseValue != oldDelegate.pulseValue ||
        startX != oldDelegate.startX ||
        startY != oldDelegate.startY ||
        tileSize != oldDelegate.tileSize ||
        clearedTiles != oldDelegate.clearedTiles ||
        openedChests != oldDelegate.openedChests;
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
