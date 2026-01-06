import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../providers/game_provider.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, _) {
          final character = gameProvider.state.character;
          final enemy = gameProvider.currentEnemy;

          if (character == null || enemy == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.gold),
            );
          }

          return Stack(
            children: [
              // Animated battle background
              AnimatedBuilder(
                animation: _bgController,
                builder: (context, _) {
                  return CustomPaint(
                    size: size,
                    painter: _BattleBackgroundPainter(
                      animationValue: _bgController.value,
                    ),
                  );
                },
              ),

              // Battle content
              SafeArea(
                child: Column(
                  children: [
                    // Enemy section
                    Expanded(
                      flex: 3,
                      child: _EnemySection(
                        enemy: enemy,
                        shakeAnimation: _shakeAnimation,
                      ),
                    ),

                    // Battle log
                    _BattleLog(log: gameProvider.battleLog),

                    // Player section
                    Expanded(
                      flex: 2,
                      child: _PlayerSection(
                        character: character,
                        isPlayerTurn: gameProvider.isPlayerTurn,
                      ),
                    ),

                    // Action buttons
                    _ActionBar(
                      onAttack: () {
                        _triggerShake();
                        gameProvider.playerAttack();
                      },
                      onDefend: () => gameProvider.playerDefend(),
                      onAbility: (ability) {
                        _triggerShake();
                        gameProvider.useAbility(ability);
                      },
                      character: character,
                      isPlayerTurn: gameProvider.isPlayerTurn,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Turn indicator
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gameProvider.isPlayerTurn
                            ? [
                                AppTheme.gold.withValues(alpha: 0.8),
                                AppTheme.darkGold.withValues(alpha: 0.8),
                              ]
                            : [
                                AppTheme.crimson.withValues(alpha: 0.8),
                                AppTheme.darkCrimson.withValues(alpha: 0.8),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (gameProvider.isPlayerTurn
                                  ? AppTheme.gold
                                  : AppTheme.crimson)
                              .withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      gameProvider.isPlayerTurn ? 'YOUR TURN' : 'ENEMY TURN',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BattleBackgroundPainter extends CustomPainter {
  final double animationValue;

  _BattleBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Dark gradient background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A0505),
          Color(0xFF0A0A0A),
          Color(0xFF050505),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Animated fire particles
    final random = math.Random(42);
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = size.height * (0.6 + random.nextDouble() * 0.4);
      final phase = random.nextDouble() * math.pi * 2;
      final speed = 0.5 + random.nextDouble() * 0.5;

      final y = baseY - (animationValue * speed * 100 + phase) % (size.height * 0.5);
      final alpha = (1 - (baseY - y) / (size.height * 0.5)).clamp(0.0, 1.0);

      final particlePaint = Paint()
        ..color = AppTheme.hellfire.withValues(alpha: alpha * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(
        Offset(x, y),
        2 + random.nextDouble() * 4,
        particlePaint,
      );
    }

    // Vignette
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.7),
        ],
        stops: const [0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _BattleBackgroundPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}

class _EnemySection extends StatelessWidget {
  final dynamic enemy;
  final Animation<double> shakeAnimation;

  const _EnemySection({
    required this.enemy,
    required this.shakeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) {
        final shakeOffset = math.sin(shakeAnimation.value * math.pi * 4) * 5;
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Enemy name and level
          Text(
            enemy.name,
            style: GoogleFonts.cinzel(
              color: AppTheme.crimson,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          if (enemy.isBoss)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.rarityLegendary.withValues(alpha: 0.8),
                    AppTheme.hellfire.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'BOSS',
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Enemy sprite representation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.crimson.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Icon(
                _getEnemyIcon(),
                size: 80,
                color: AppTheme.crimson,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Enemy HP bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: _HPBar(
              current: enemy.hp,
              max: enemy.maxHp,
              color: AppTheme.crimson,
              height: 16,
            ),
          ),

          const SizedBox(height: 8),

          // Enemy stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(
                icon: Icons.shield,
                value: '${enemy.ac}',
                label: 'AC',
              ),
              const SizedBox(width: 16),
              _StatChip(
                icon: Icons.flash_on,
                value: '+${enemy.attackBonus}',
                label: 'ATK',
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getEnemyIcon() {
    final name = enemy.name.toLowerCase();
    if (name.contains('goblin')) return Icons.pest_control;
    if (name.contains('skeleton')) return Icons.cruelty_free;
    if (name.contains('orc')) return Icons.sports_mma;
    if (name.contains('warlord')) return Icons.military_tech;
    if (name.contains('shadow')) return Icons.dark_mode;
    if (name.contains('imp') || name.contains('fire')) return Icons.local_fire_department;
    if (name.contains('warden') || name.contains('infernal')) return Icons.whatshot;
    if (name.contains('wraith') || name.contains('frost')) return Icons.ac_unit;
    if (name.contains('titan')) return Icons.landscape;
    if (name.contains('void') || name.contains('abyss')) return Icons.blur_on;
    return Icons.pest_control;
  }
}

class _PlayerSection extends StatelessWidget {
  final dynamic character;
  final bool isPlayerTurn;

  const _PlayerSection({
    required this.character,
    required this.isPlayerTurn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.black.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlayerTurn
              ? AppTheme.gold.withValues(alpha: 0.5)
              : AppTheme.stoneGray.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Character icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.getClassColor(character.className).withValues(alpha: 0.3),
                  Colors.transparent,
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
                  color: AppTheme.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${character.name} - Lvl ${character.level}',
                  style: GoogleFonts.cinzel(
                    color: AppTheme.gold,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _HPBar(
                  current: character.hp,
                  max: character.totalMaxHp,
                  color: AppTheme.poison,
                  height: 14,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.shield,
                      value: '${character.totalAC}',
                      label: 'AC',
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.flash_on,
                      value: '+${character.attackBonus}',
                      label: 'ATK',
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.fitness_center,
                      value: '+${character.damageBonus}',
                      label: 'DMG',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HPBar extends StatelessWidget {
  final int current;
  final int max;
  final Color color;
  final double height;

  const _HPBar({
    required this.current,
    required this.max,
    required this.color,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

    return Stack(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 300),
          widthFactor: percentage,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              '$current / $max',
              style: TextStyle(
                color: Colors.white,
                fontSize: height * 0.65,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 2),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.gold, size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.boneWhite,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BattleLog extends StatelessWidget {
  final List<String> log;

  const _BattleLog({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.stoneGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListView.builder(
        reverse: true,
        itemCount: log.length,
        itemBuilder: (context, index) {
          final entry = log[log.length - 1 - index];
          final isCrit = entry.toUpperCase().contains('CRITICAL') ||
              entry.toUpperCase().contains('CRIT');
          final isMiss = entry.toLowerCase().contains('miss');

          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              entry,
              style: TextStyle(
                color: isCrit
                    ? AppTheme.rarityLegendary
                    : isMiss
                        ? AppTheme.ashGray
                        : AppTheme.boneWhite,
                fontSize: 11,
                fontWeight: isCrit ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final VoidCallback onAttack;
  final VoidCallback onDefend;
  final void Function(String) onAbility;
  final dynamic character;
  final bool isPlayerTurn;

  const _ActionBar({
    required this.onAttack,
    required this.onDefend,
    required this.onAbility,
    required this.character,
    required this.isPlayerTurn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Main action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'ATTACK',
                  icon: Icons.gavel,
                  color: AppTheme.hellfire,
                  onPressed: isPlayerTurn ? onAttack : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'DEFEND',
                  icon: Icons.shield,
                  color: AppTheme.mana,
                  onPressed: isPlayerTurn ? onDefend : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Ability buttons based on class
          Row(
            children: _getAbilityButtons(),
          ),
        ],
      ),
    );
  }

  List<Widget> _getAbilityButtons() {
    final abilities = <Widget>[];
    final className = character.className.toLowerCase();

    if (className == 'wizard') {
      abilities.addAll([
        Expanded(
          child: _ActionButton(
            label: 'FIREBALL',
            icon: Icons.local_fire_department,
            color: AppTheme.ember,
            onPressed: isPlayerTurn && character.spellSlots.level1 > 0
                ? () => onAbility('fireball')
                : null,
            small: true,
          ),
        ),
        const SizedBox(width: 8),
      ]);
    }

    if (className == 'cleric') {
      abilities.addAll([
        Expanded(
          child: _ActionButton(
            label: 'HEAL',
            icon: Icons.healing,
            color: AppTheme.poison,
            onPressed: isPlayerTurn && character.spellSlots.level1 > 0
                ? () => onAbility('heal')
                : null,
            small: true,
          ),
        ),
        const SizedBox(width: 8),
      ]);
    }

    if (className == 'fighter') {
      abilities.addAll([
        Expanded(
          child: _ActionButton(
            label: 'POWER ATTACK',
            icon: Icons.flash_on,
            color: AppTheme.darkGold,
            onPressed: isPlayerTurn ? () => onAbility('power attack') : null,
            small: true,
          ),
        ),
        const SizedBox(width: 8),
      ]);
    }

    if (className == 'rogue') {
      abilities.addAll([
        Expanded(
          child: _ActionButton(
            label: 'SNEAK ATTACK',
            icon: Icons.visibility_off,
            color: AppTheme.voidPurple,
            onPressed: isPlayerTurn ? () => onAbility('sneak attack') : null,
            small: true,
          ),
        ),
        const SizedBox(width: 8),
      ]);
    }

    // Fill remaining space
    while (abilities.length < 3) {
      abilities.add(const Expanded(child: SizedBox()));
      if (abilities.length < 3) abilities.add(const SizedBox(width: 8));
    }

    return abilities;
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool small;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: small ? 10 : 14,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDisabled
                ? [
                    AppTheme.stoneGray.withValues(alpha: 0.3),
                    AppTheme.stoneGray.withValues(alpha: 0.2),
                  ]
                : [
                    color.withValues(alpha: 0.8),
                    color.withValues(alpha: 0.5),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? AppTheme.stoneGray.withValues(alpha: 0.3)
                : color.withValues(alpha: 0.8),
            width: 2,
          ),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDisabled
                  ? AppTheme.ashGray
                  : Colors.white,
              size: small ? 16 : 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.cinzel(
                  color: isDisabled
                      ? AppTheme.ashGray
                      : Colors.white,
                  fontSize: small ? 11 : 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
