import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../models/character.dart';

class CharacterSelectScreen extends StatefulWidget {
  final void Function(ClassDefinition classDef, String name) onCharacterSelected;
  final VoidCallback onBack;

  const CharacterSelectScreen({
    super.key,
    required this.onCharacterSelected,
    required this.onBack,
  });

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _nameController =
      TextEditingController(text: 'Hero');
  late AnimationController _animController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0A0A),
              Color(0xFF0A0A0A),
              Color(0xFF050505),
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
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.gold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'CHOOSE YOUR CLASS',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Class cards carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: ClassDefinition.allClasses.length,
                  onPageChanged: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final classDef = ClassDefinition.allClasses[index];
                    final isSelected = index == _selectedIndex;

                    return AnimatedScale(
                      scale: isSelected ? 1.0 : 0.9,
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedOpacity(
                        opacity: isSelected ? 1.0 : 0.6,
                        duration: const Duration(milliseconds: 300),
                        child: _ClassCard(
                          classDef: classDef,
                          isSelected: isSelected,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    ClassDefinition.allClasses.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == _selectedIndex ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: index == _selectedIndex
                            ? AppTheme.gold
                            : AppTheme.stoneGray,
                      ),
                    ),
                  ),
                ),
              ),

              // Name input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.darkGold.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      color: AppTheme.boneWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(
                        color: AppTheme.ashGray.withOpacity(0.5),
                      ),
                      prefixIcon: const Icon(
                        Icons.edit,
                        color: AppTheme.gold,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Start button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GestureDetector(
                  onTap: () {
                    final name = _nameController.text.isNotEmpty
                        ? _nameController.text
                        : 'Hero';
                    widget.onCharacterSelected(
                      ClassDefinition.allClasses[_selectedIndex],
                      name,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4A2020),
                          Color(0xFF2A1010),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.gold,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.hellfire.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      'BEGIN ADVENTURE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.gold,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final ClassDefinition classDef;
  final bool isSelected;

  const _ClassCard({
    required this.classDef,
    required this.isSelected,
  });

  Color get classColor => AppTheme.getClassColor(classDef.name);

  IconData get classIcon {
    switch (classDef.characterClass) {
      case CharacterClass.fighter:
        return Icons.shield;
      case CharacterClass.wizard:
        return Icons.auto_fix_high;
      case CharacterClass.rogue:
        return Icons.visibility;
      case CharacterClass.cleric:
        return Icons.brightness_7;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            classColor.withOpacity(0.2),
            const Color(0xFF1A1010),
            const Color(0xFF0A0808),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? classColor.withOpacity(0.8)
              : AppTheme.stoneGray.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: classColor.withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Class icon with glow
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    classColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: classColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                classIcon,
                size: 40,
                color: classColor,
              ),
            ),

            const SizedBox(height: 16),

            // Class name
            Text(
              classDef.name.toUpperCase(),
              style: GoogleFonts.cinzel(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: classColor,
                letterSpacing: 3,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      classDef.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.boneWhite.withOpacity(0.8),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stats grid
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: classColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _StatRow(
                              'Primary', classDef.primaryStat, classColor),
                          const SizedBox(height: 8),
                          _StatRow('Hit Die', classDef.hitDie, classColor),
                          const SizedBox(height: 8),
                          _StatRow('Base HP', '${classDef.baseHP}', classColor),
                          const SizedBox(height: 8),
                          _StatRow('Base AC', '${classDef.baseAC}', classColor),
                          if (classDef.isCaster) ...[
                            const SizedBox(height: 8),
                            _StatRow(
                              'Spell Slots',
                              '${classDef.startingSpellSlots.level1Max}/${classDef.startingSpellSlots.level2Max}',
                              classColor,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Ability scores
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: classColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _AbilityChip(
                              'STR', classDef.baseStats.strength, classColor),
                          _AbilityChip(
                              'DEX', classDef.baseStats.dexterity, classColor),
                          _AbilityChip('CON', classDef.baseStats.constitution,
                              classColor),
                          _AbilityChip('INT', classDef.baseStats.intelligence,
                              classColor),
                          _AbilityChip(
                              'WIS', classDef.baseStats.wisdom, classColor),
                          _AbilityChip(
                              'CHA', classDef.baseStats.charisma, classColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Starting abilities
                    Text(
                      'Starting Abilities',
                      style: GoogleFonts.cinzel(
                        fontSize: 12,
                        color: classColor.withOpacity(0.8),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: classDef.startingAbilities
                          .map((ability) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: classColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: classColor.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  ability,
                                  style: TextStyle(
                                    color: classColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.ashGray,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AbilityChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _AbilityChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    final mod = (value - 10) ~/ 2;
    final modStr = mod >= 0 ? '+$mod' : '$mod';

    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            modStr,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
