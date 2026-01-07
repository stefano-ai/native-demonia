import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'providers/game_provider.dart';
import 'models/game_state.dart';
import 'screens/title_screen.dart';
import 'screens/character_select_screen.dart';
import 'screens/map_screen.dart';
import 'screens/battle_screen.dart';
import 'screens/village_screen.dart';
import 'screens/victory_defeat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.abyssBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DemoniaRPG());
}

class DemoniaRPG extends StatelessWidget {
  const DemoniaRPG({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Demonia RPG',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const GameShell(),
      ),
    );
  }
}

class GameShell extends StatelessWidget {
  const GameShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final currentScreen = gameProvider.state.currentScreen;

        return Stack(
          children: [
            // Main game screen based on state
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _buildScreen(context, gameProvider, currentScreen),
            ),

            // Victory overlay
            if (currentScreen == GameScreen.victory)
              VictoryScreen(
                xpGained: gameProvider.currentEnemy?.xpReward ?? 0,
                goldGained: gameProvider.currentEnemy?.rollGold() ?? 0,
                leveledUp: false,
                newLevel: gameProvider.state.character?.level ?? 1,
                onContinue: () => gameProvider.returnToMap(),
              ),

            // Defeat overlay
            if (currentScreen == GameScreen.defeat)
              DefeatScreen(
                onRetry: () => gameProvider.retryBattle(),
                onQuit: () => gameProvider.goToTitle(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildScreen(
    BuildContext context,
    GameProvider gameProvider,
    GameScreen screen,
  ) {
    switch (screen) {
      case GameScreen.title:
        return TitleScreen(
          key: const ValueKey('title'),
          onNewGame: () => gameProvider.goToScreen(GameScreen.characterSelect),
          onLoadGame: () => _showLoadGameDialog(context, gameProvider),
          onSettings: () => _showSettingsDialog(context, gameProvider),
        );

      case GameScreen.characterSelect:
        return CharacterSelectScreen(
          key: const ValueKey('character_select'),
          onCharacterSelected: (classDef, name) {
            gameProvider.selectCharacter(classDef, name);
          },
          onBack: () => gameProvider.goToScreen(GameScreen.title),
        );

      case GameScreen.map:
        return MapScreen(
          key: const ValueKey('map'),
          onMenuPressed: () => _showGameMenu(context, gameProvider),
        );

      case GameScreen.village:
        return VillageScreen(
          key: const ValueKey('village'),
          onExit: () => gameProvider.exitVillage(),
        );

      case GameScreen.battle:
      case GameScreen.victory:
      case GameScreen.defeat:
        return const BattleScreen(
          key: ValueKey('battle'),
        );
    }
  }

  void _showLoadGameDialog(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _LoadGameDialog(provider: provider),
    );
  }

  void _showSettingsDialog(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1410),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0x80FFD700),
            width: 2,
          ),
        ),
        title: Text(
          'SETTINGS',
          style: TextStyle(
            color: AppTheme.gold,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text(
                'Reduced Motion',
                style: TextStyle(color: AppTheme.boneWhite),
              ),
              subtitle: Text(
                'Disable battle animations',
                style: TextStyle(
                  color: AppTheme.ashGray,
                  fontSize: 12,
                ),
              ),
              value: provider.state.reducedMotion,
              onChanged: (_) => provider.toggleReducedMotion(),
              activeColor: AppTheme.gold,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: AppTheme.gold),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameMenu(BuildContext context, GameProvider provider) {
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
            color: const Color(0x80FFD700),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MENU',
              style: TextStyle(
                color: AppTheme.gold,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 24),
            _MenuOption(
              icon: Icons.save,
              label: 'Save Game',
              onTap: () {
                Navigator.pop(context);
                _showSaveGameDialog(context, provider);
              },
            ),
            _MenuOption(
              icon: Icons.folder_open,
              label: 'Load Game',
              onTap: () {
                Navigator.pop(context);
                _showLoadGameDialog(context, provider);
              },
            ),
            _MenuOption(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                _showSettingsDialog(context, provider);
              },
            ),
            _MenuOption(
              icon: Icons.home,
              label: 'Return to Title',
              onTap: () {
                Navigator.pop(context);
                provider.goToTitle();
              },
              isDestructive: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSaveGameDialog(BuildContext context, GameProvider provider) async {
    final slots = await provider.getSaveSlots();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1410),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0x80FFD700),
            width: 2,
          ),
        ),
        title: Text(
          'SAVE GAME',
          style: TextStyle(
            color: AppTheme.gold,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            GameProvider.maxSaveSlots,
            (index) => _SaveSlotTile(
              slot: index,
              saveData: slots.length > index ? slots[index] : null,
              onTap: () async {
                await provider.saveGame(index);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Game saved to slot ${index + 1}!'),
                      backgroundColor: AppTheme.poison,
                    ),
                  );
                }
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppTheme.ashGray),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadGameDialog extends StatefulWidget {
  final GameProvider provider;

  const _LoadGameDialog({required this.provider});

  @override
  State<_LoadGameDialog> createState() => _LoadGameDialogState();
}

class _LoadGameDialogState extends State<_LoadGameDialog> {
  List<GameState?>? _slots;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final slots = await widget.provider.getSaveSlots();
    setState(() => _slots = slots);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1410),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0x80FFD700),
          width: 2,
        ),
      ),
      title: Text(
        'LOAD GAME',
        style: TextStyle(
          color: AppTheme.gold,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      content: _slots == null
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.gold),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                GameProvider.maxSaveSlots,
                (index) => _SaveSlotTile(
                  slot: index,
                  saveData: _slots!.length > index ? _slots![index] : null,
                  onTap: _slots!.length > index && _slots![index] != null
                      ? () async {
                          final success = await widget.provider.loadGame(index);
                          if (context.mounted) {
                            Navigator.pop(context);
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to load save'),
                                  backgroundColor: AppTheme.crimson,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  isLoadMode: true,
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'CANCEL',
            style: TextStyle(color: AppTheme.ashGray),
          ),
        ),
      ],
    );
  }
}

class _SaveSlotTile extends StatelessWidget {
  final int slot;
  final GameState? saveData;
  final VoidCallback? onTap;
  final bool isLoadMode;

  const _SaveSlotTile({
    required this.slot,
    this.saveData,
    this.onTap,
    this.isLoadMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = saveData == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEmpty
              ? Colors.black.withOpacity(0.3)
              : AppTheme.stoneGray.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEmpty
                ? const Color(0x4D3D3D3D)
                : const Color(0x80FFD700),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isEmpty
                    ? AppTheme.stoneGray.withOpacity(0.3)
                    : AppTheme.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${slot + 1}',
                  style: TextStyle(
                    color: isEmpty ? AppTheme.ashGray : AppTheme.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isEmpty
                  ? Text(
                      isLoadMode ? 'Empty Slot' : 'New Save',
                      style: TextStyle(
                        color: AppTheme.ashGray,
                        fontSize: 14,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          saveData!.character?.name ?? 'Unknown',
                          style: const TextStyle(
                            color: AppTheme.boneWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Lvl ${saveData!.character?.level ?? 1} ${saveData!.character?.className ?? ''} • ${saveData!.timeSinceLastSave}',
                          style: TextStyle(
                            color: AppTheme.ashGray,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
            ),
            if (!isEmpty)
              Icon(
                isLoadMode ? Icons.play_arrow : Icons.save,
                color: AppTheme.gold,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppTheme.crimson.withOpacity(0.1)
              : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? const Color(0x80DC143C)
                : const Color(0x4D3D3D3D),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppTheme.crimson : AppTheme.gold,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isDestructive ? AppTheme.crimson : AppTheme.boneWhite,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: isDestructive
                  ? AppTheme.crimson.withOpacity(0.5)
                  : AppTheme.ashGray,
            ),
          ],
        ),
      ),
    );
  }
}