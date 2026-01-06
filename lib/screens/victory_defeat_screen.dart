import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

class VictoryScreen extends StatefulWidget {
  final int xpGained;
  final int goldGained;
  final List<String> loot;
  final bool leveledUp;
  final int newLevel;
  final VoidCallback onContinue;

  const VictoryScreen({
    super.key,
    required this.xpGained,
    required this.goldGained,
    this.loot = const [],
    this.leveledUp = false,
    this.newLevel = 1,
    required this.onContinue,
  });

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2A3A20),
                  Color(0xFF1A2A10),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.poison,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.poison.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Victory icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.poison.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: AppTheme.gold,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 16),

                // Victory text
                Text(
                  'VICTORY!',
                  style: GoogleFonts.cinzelDecorative(
                    color: AppTheme.gold,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: AppTheme.poison.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Level up notification
                if (widget.leveledUp)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.rarityLegendary.withValues(alpha: 0.8),
                          AppTheme.gold.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'LEVEL UP! → ${widget.newLevel}',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                // Rewards
                _RewardRow(
                  icon: Icons.star,
                  label: 'Experience',
                  value: '+${widget.xpGained} XP',
                  color: AppTheme.mana,
                ),
                const SizedBox(height: 12),
                _RewardRow(
                  icon: Icons.monetization_on,
                  label: 'Gold',
                  value: '+${widget.goldGained}',
                  color: AppTheme.gold,
                ),

                if (widget.loot.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.stoneGray),
                  const SizedBox(height: 8),
                  Text(
                    'LOOT',
                    style: GoogleFonts.cinzel(
                      color: AppTheme.gold,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.loot.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: AppTheme.boneWhite.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      )),
                ],

                const SizedBox(height: 24),

                // Continue button
                GestureDetector(
                  onTap: widget.onContinue,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF3A4A30),
                          Color(0xFF2A3A20),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.poison,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'CONTINUE',
                      style: GoogleFonts.cinzel(
                        color: AppTheme.boneWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DefeatScreen extends StatefulWidget {
  final VoidCallback onRetry;
  final VoidCallback onQuit;

  const DefeatScreen({
    super.key,
    required this.onRetry,
    required this.onQuit,
  });

  @override
  State<DefeatScreen> createState() => _DefeatScreenState();
}

class _DefeatScreenState extends State<DefeatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3A2020),
                  Color(0xFF2A1010),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.crimson,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.crimson.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Defeat icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.crimson.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.dangerous,
                    color: AppTheme.crimson,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 16),

                // Defeat text
                Text(
                  'DEFEATED',
                  style: GoogleFonts.cinzelDecorative(
                    color: AppTheme.crimson,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: AppTheme.darkCrimson.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Your hero has fallen in battle...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.boneWhite.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 32),

                // Retry button
                GestureDetector(
                  onTap: widget.onRetry,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4A3020),
                          Color(0xFF3A2010),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.gold,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'RETRY BATTLE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: AppTheme.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Quit button
                GestureDetector(
                  onTap: widget.onQuit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.stoneGray,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'RETURN TO TITLE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: AppTheme.ashGray,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RewardRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.boneWhite.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
