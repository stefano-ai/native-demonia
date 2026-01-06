import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../providers/game_provider.dart';

class VillageScreen extends StatelessWidget {
  final VoidCallback onExit;

  const VillageScreen({super.key, required this.onExit});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2A1A),
              Color(0xFF0A150A),
              Color(0xFF050A05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onExit,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.darkGold.withOpacity(0.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppTheme.gold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'SANCTUARY VILLAGE',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          color: AppTheme.gold,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Village illustration
              Container(
                height: size.height * 0.25,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.poison.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Fountain
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.mana.withOpacity(0.4),
                                AppTheme.mana.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: AppTheme.mana.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.mana.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.water_drop,
                            color: AppTheme.mana,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Healing Fountain',
                          style: GoogleFonts.cinzel(
                            color: AppTheme.mana,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Buildings in corners
                    Positioned(
                      left: 16,
                      top: 16,
                      child: _VillageBuilding(
                        icon: Icons.gavel,
                        label: 'Blacksmith',
                        color: AppTheme.ember,
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: _VillageBuilding(
                        icon: Icons.shield,
                        label: 'Armorer',
                        color: AppTheme.stoneGray,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: _VillageBuilding(
                        icon: Icons.science,
                        label: 'Alchemist',
                        color: AppTheme.poison,
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: _VillageBuilding(
                        icon: Icons.mail,
                        label: 'Mailbox',
                        color: AppTheme.gold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _VillageButton(
                        icon: Icons.water_drop,
                        label: 'REST AT\nFOUNTAIN',
                        description: 'Restore HP & Mana',
                        color: AppTheme.mana,
                        onTap: () => _restAtFountain(context),
                      ),
                      _VillageButton(
                        icon: Icons.gavel,
                        label: 'BLACKSMITH',
                        description: 'Buy Weapons',
                        color: AppTheme.ember,
                        onTap: () => _showShop(context, 'Blacksmith'),
                      ),
                      _VillageButton(
                        icon: Icons.shield,
                        label: 'ARMORER',
                        description: 'Buy Armor',
                        color: AppTheme.stoneGray,
                        onTap: () => _showShop(context, 'Armorer'),
                      ),
                      _VillageButton(
                        icon: Icons.science,
                        label: 'ALCHEMIST',
                        description: 'Buy Potions',
                        color: AppTheme.poison,
                        onTap: () => _showShop(context, 'Alchemist'),
                      ),
                      _VillageButton(
                        icon: Icons.mail,
                        label: 'MAILBOX',
                        description: 'Claim Items',
                        color: AppTheme.gold,
                        onTap: () => _showMailbox(context),
                      ),
                      _VillageButton(
                        icon: Icons.exit_to_app,
                        label: 'LEAVE\nVILLAGE',
                        description: 'Return to Dungeon',
                        color: AppTheme.crimson,
                        onTap: onExit,
                      ),
                    ],
                  ),
                ),
              ),

              // Gold display
              Consumer<GameProvider>(
                builder: (context, provider, _) {
                  final gold = provider.state.character?.gold ?? 0;
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.gold.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: AppTheme.gold,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$gold Gold',
                          style: GoogleFonts.cinzel(
                            color: AppTheme.gold,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _restAtFountain(BuildContext context) {
    final provider = context.read<GameProvider>();
    provider.restAtFountain();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.mana.withOpacity(0.9),
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'HP and spell slots restored!',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showShop(BuildContext context, String shopName) {
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
                shopName.toUpperCase(),
                style: GoogleFonts.cinzel(
                  color: AppTheme.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getShopDescription(shopName),
                style: TextStyle(
                  color: AppTheme.boneWhite.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getShopIcon(shopName),
                        size: 64,
                        color: AppTheme.gold.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Shop inventory coming soon!',
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

  void _showMailbox(BuildContext context) {
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
            const Icon(
              Icons.mail_outline,
              color: AppTheme.gold,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'MAILBOX',
              style: GoogleFonts.cinzel(
                color: AppTheme.gold,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 24),
            Consumer<GameProvider>(
              builder: (context, provider, _) {
                final mailbox = provider.state.mailbox;
                if (mailbox.isEmpty) {
                  return Column(
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 48,
                        color: AppTheme.ashGray.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No items waiting',
                        style: TextStyle(
                          color: AppTheme.boneWhite.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    Text(
                      '${mailbox.length} items waiting',
                      style: TextStyle(
                        color: AppTheme.boneWhite.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement claim all
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('CLAIM ALL'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getShopDescription(String shopName) {
    switch (shopName) {
      case 'Blacksmith':
        return 'Fine weapons for the discerning adventurer';
      case 'Armorer':
        return 'Protection against the dark forces';
      case 'Alchemist':
        return 'Potions and elixirs for your journey';
      default:
        return '';
    }
  }

  IconData _getShopIcon(String shopName) {
    switch (shopName) {
      case 'Blacksmith':
        return Icons.gavel;
      case 'Armorer':
        return Icons.shield;
      case 'Alchemist':
        return Icons.science;
      default:
        return Icons.store;
    }
  }
}

class _VillageBuilding extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _VillageBuilding({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.5),
            ),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VillageButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _VillageButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.boneWhite.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
