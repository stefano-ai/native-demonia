import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/game_provider.dart';
import '../models/character.dart';

class GameHUD extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onInventoryPressed;
  final VoidCallback? onQuestsPressed;

  const GameHUD({
    super.key,
    this.onMenuPressed,
    this.onInventoryPressed,
    this.onQuestsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final character = gameProvider.state.character;
        if (character == null) return const SizedBox.shrink();

        return SafeArea(
          child: Column(
            children: [
              // Top bar with stats
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.darkGold.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Character info row
                    Row(
                      children: [
                        // Class icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.getClassColor(character.className),
                                AppTheme.getClassColor(character.className)
                                    .withValues(alpha: 0.5),
                              ],
                            ),
                            border: Border.all(
                              color: AppTheme.gold,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              character.className[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Name and level
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                character.name,
                                style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Lvl ${character.level} ${character.className}',
                                style: TextStyle(
                                  color: AppTheme.boneWhite.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Rank badge
                        _RankBadge(tier: character.rankTier),
                        const SizedBox(width: 8),
                        // Gold
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.monetization_on,
                                color: AppTheme.gold,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${character.gold}',
                                style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // HP Bar
                    _StatBar(
                      label: 'HP',
                      current: character.hp,
                      max: character.totalMaxHp,
                      color: AppTheme.crimson,
                      icon: Icons.favorite,
                    ),
                    const SizedBox(height: 4),
                    // XP Bar
                    _StatBar(
                      label: 'XP',
                      current: character.xp,
                      max: character.xpToNextLevel,
                      color: AppTheme.mana,
                      icon: Icons.star,
                    ),
                    // Spell slots for casters
                    if (character.spellSlots.hasSlots) ...[
                      const SizedBox(height: 4),
                      _SpellSlotsBar(spellSlots: character.spellSlots),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              // Bottom HUD buttons
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _HUDButton(
                      icon: Icons.backpack,
                      onPressed: onInventoryPressed ?? () {},
                    ),
                    const SizedBox(width: 8),
                    _HUDButton(
                      icon: Icons.assignment,
                      onPressed: onQuestsPressed ?? () {},
                    ),
                    const SizedBox(width: 8),
                    _HUDButton(
                      icon: Icons.menu,
                      onPressed: onMenuPressed ?? () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;
  final IconData icon;

  const _StatBar({
    required this.label,
    required this.current,
    required this.max,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Expanded(
          child: Stack(
            children: [
              // Background
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              // Fill
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              // Text
              Positioned.fill(
                child: Center(
                  child: Text(
                    '$current / $max',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpellSlotsBar extends StatelessWidget {
  final SpellSlots spellSlots;

  const _SpellSlotsBar({required this.spellSlots});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.auto_fix_high, color: AppTheme.mana, size: 14),
        const SizedBox(width: 4),
        Text(
          'Slots:',
          style: TextStyle(
            color: AppTheme.boneWhite.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 4),
        _SlotIndicator(
          current: spellSlots.level1,
          max: spellSlots.level1Max,
          label: '1st',
        ),
        if (spellSlots.level2Max > 0) ...[
          const SizedBox(width: 8),
          _SlotIndicator(
            current: spellSlots.level2,
            max: spellSlots.level2Max,
            label: '2nd',
          ),
        ],
        if (spellSlots.level3Max > 0) ...[
          const SizedBox(width: 8),
          _SlotIndicator(
            current: spellSlots.level3,
            max: spellSlots.level3Max,
            label: '3rd',
          ),
        ],
      ],
    );
  }
}

class _SlotIndicator extends StatelessWidget {
  final int current;
  final int max;
  final String label;

  const _SlotIndicator({
    required this.current,
    required this.max,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: AppTheme.boneWhite.withValues(alpha: 0.5),
            fontSize: 9,
          ),
        ),
        const SizedBox(width: 2),
        ...List.generate(max, (index) {
          final isFilled = index < current;
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(left: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? AppTheme.mana : Colors.black.withValues(alpha: 0.5),
              border: Border.all(
                color: AppTheme.mana.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: isFilled
                  ? [
                      BoxShadow(
                        color: AppTheme.mana.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  final String tier;

  const _RankBadge({required this.tier});

  Color get tierColor {
    switch (tier) {
      case 'Bronze':
        return const Color(0xFFCD7F32);
      case 'Silver':
        return const Color(0xFFC0C0C0);
      case 'Gold':
        return AppTheme.gold;
      case 'Platinum':
        return const Color(0xFFE5E4E2);
      case 'Mythic':
        return AppTheme.rarityLegendary;
      default:
        return const Color(0xFFCD7F32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tierColor,
            tierColor.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        tier,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 2),
          ],
        ),
      ),
    );
  }
}

class _HUDButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HUDButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3D3020),
              Color(0xFF1A1008),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.darkGold.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppTheme.gold,
          size: 22,
        ),
      ),
    );
  }
}
