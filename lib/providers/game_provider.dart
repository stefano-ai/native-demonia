import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';
import '../models/enemy.dart';
import '../models/game_state.dart';
import '../models/quest.dart';
import '../models/tile.dart';
import '../data/map_data.dart';

class GameProvider extends ChangeNotifier {
  static const int maxSaveSlots = 3;
  static const String _saveKeyPrefix = 'demonia_save_';

  GameState _state = GameState(id: 'new_game');
  GameMap? _currentMap;
  Enemy? _currentEnemy;
  bool _isPlayerTurn = true;
  List<String> _battleLog = [];
  bool _isDefending = false;

  GameState get state => _state;
  GameMap? get currentMap => _currentMap;
  Enemy? get currentEnemy => _currentEnemy;
  bool get isPlayerTurn => _isPlayerTurn;
  List<String> get battleLog => _battleLog;
  bool get isDefending => _isDefending;

  GameProvider() {
    _loadCurrentMap();
  }

  void _loadCurrentMap() {
    if (_state.currentFloor > 0) {
      _currentMap = MapData.getFloor(_state.currentFloor);
    }
  }

  // Character Selection
  void selectCharacter(ClassDefinition classDef, String name) {
    final character = Character.fromClass(classDef, name);
    _state = _state.copyWith(
      character: character,
      currentScreen: GameScreen.map,
    );
    _loadCurrentMap();
    _addToLog('${character.name} the ${character.className} begins the adventure!');
    notifyListeners();
  }

  // Navigation
  void goToScreen(GameScreen screen) {
    _state = _state.copyWith(currentScreen: screen);
    notifyListeners();
  }

  void goToTitle() {
    _state = GameState(id: 'new_game');
    _currentMap = null;
    _currentEnemy = null;
    notifyListeners();
  }

  // Movement
  bool movePlayer(int dx, int dy) {
    if (_currentMap == null || _state.character == null) return false;

    final currentPos = _state.currentPosition;
    final newX = currentPos.x + dx;
    final newY = currentPos.y + dy;

    if (!_currentMap!.canMoveTo(newX, newY)) return false;

    final tile = _currentMap!.getTile(newX, newY);

    final newPositions = Map<int, Position>.from(_state.playerPositions);
    newPositions[_state.currentFloor] = Position(newX, newY);

    _state = _state.copyWith(playerPositions: newPositions);

    // Check for encounters
    if (tile.enemyType != null) {
      _triggerRandomEncounter();
    } else if (tile.type == TileType.chest && !tile.isOpened) {
      _openChest(newX, newY);
    } else if (tile.type == TileType.stairsDown || tile.type == TileType.stairsUp) {
      _handleStairs(tile);
    }

    notifyListeners();
    return true;
  }

  void _triggerRandomEncounter() {
    final random = math.Random();
    if (random.nextDouble() < 0.3) {
      // 30% encounter rate
      _startBattle(_getRandomEnemyForFloor());
    }
  }

  EnemyType _getRandomEnemyForFloor() {
    final random = math.Random();
    switch (_state.currentFloor) {
      case 1:
        return random.nextBool() ? EnemyType.goblin : EnemyType.skeleton;
      case 2:
        final roll = random.nextInt(3);
        if (roll == 0) return EnemyType.fireImp;
        if (roll == 1) return EnemyType.orcWarrior;
        return EnemyType.darkAcolyte;
      case 3:
        final roll = random.nextInt(3);
        if (roll == 0) return EnemyType.darkAcolyte;
        if (roll == 1) return EnemyType.fireImp;
        return EnemyType.skeleton;
      default:
        return EnemyType.goblin;
    }
  }

  void _openChest(int x, int y) {
    final chestId = '${_state.currentFloor}_${x}_$y';
    if (_state.openedChests.contains(chestId)) return;

    final random = math.Random();
    final goldFound = 20 + random.nextInt(50);
    final items = <String>[];

    if (random.nextDouble() < 0.5) {
      items.add('potion_health_minor');
    }
    if (random.nextDouble() < 0.2) {
      items.add('potion_health');
    }

    final character = _state.character!;
    final newGold = character.gold + goldFound;
    final newInventory = List<String>.from(character.inventory)..addAll(items);

    _state = _state.copyWith(
      character: character.copyWith(
        gold: newGold,
        inventory: newInventory,
      ),
      openedChests: Set.from(_state.openedChests)..add(chestId),
    );

    _addToLog('Found a chest! +$goldFound gold');
    for (final item in items) {
      _addToLog('Found: $item');
    }

    // Update quest progress
    _updateQuestProgress('open_chest', null, 1);
  }

  void _handleStairs(MapTile tile) {
    if (tile.targetFloor == null) return;

    final targetFloor = int.parse(tile.targetFloor!);

    // Check floor requirements
    if (targetFloor == 2 && !_state.character!.inventory.contains('caldera_key')) {
      _addToLog('The passage is locked. You need the Caldera Key!');
      return;
    }

    if (targetFloor == 3 && !_state.storyFlags.acceptedChapelQuest) {
      _addToLog('Eldric must guide you to this place first.');
      return;
    }

    final newPositions = Map<int, Position>.from(_state.playerPositions);
    newPositions[targetFloor] = Position(tile.targetX ?? 5, tile.targetY ?? 5);

    _state = _state.copyWith(
      currentFloor: targetFloor,
      playerPositions: newPositions,
    );

    _currentMap = MapData.getFloor(targetFloor);
    _addToLog('Descended to ${_currentMap!.name}...');

    // Update quest progress for reaching floor
    _updateQuestProgress('reach_floor', 'floor_$targetFloor', 1);
  }

  // Public method for floor changing
  void changeFloor(int newFloor) {
    if (newFloor < 1 || newFloor > 3) return;
    
    final targetMap = MapData.getFloor(newFloor);
    
    final newPositions = Map<int, Position>.from(_state.playerPositions);
    if (!newPositions.containsKey(newFloor)) {
      newPositions[newFloor] = Position(targetMap.startX, targetMap.startY);
    }

    _state = _state.copyWith(
      currentFloor: newFloor,
      playerPositions: newPositions,
    );

    _currentMap = targetMap;
    _addToLog('Traveled to ${_currentMap!.name}');

    notifyListeners();
  }

  void openChest(String chestId) {
    _state = _state.copyWith(
      openedChests: Set.from(_state.openedChests)..add(chestId),
    );
    notifyListeners();
  }

  // Battle System
  void _startBattle(EnemyType enemyType) {
    _currentEnemy = Enemy.createFromType(enemyType);
    _battleLog = ['A ${_currentEnemy!.name} appears!'];
    _isPlayerTurn = true;
    _isDefending = false;
    _state = _state.copyWith(currentScreen: GameScreen.battle);
    notifyListeners();
  }

  void startBossEncounter(String bossType) {
    EnemyType type;
    switch (bossType) {
      case 'orc_warlord':
        type = EnemyType.orcWarlord;
        break;
      case 'shadow_lord':
        type = EnemyType.shadowLord;
        break;
      case 'infernal_warden':
        type = EnemyType.infernalWarden;
        break;
      default:
        type = EnemyType.goblin;
    }
    _startBattle(type);
  }

  void playerAttack() {
    if (!_isPlayerTurn || _currentEnemy == null || _state.character == null) {
      return;
    }

    final character = _state.character!;
    final random = math.Random();

    // Roll d20 + attack bonus
    final attackRoll = random.nextInt(20) + 1;
    final totalAttack = attackRoll + character.attackBonus;

    String logEntry;
    if (attackRoll == 20) {
      // Critical hit!
      final damage = character.rollDamage('2d8') * 2;
      _currentEnemy = _currentEnemy!.copyWith(
        hp: (_currentEnemy!.hp - damage).clamp(0, _currentEnemy!.maxHp),
      );
      logEntry = 'CRITICAL HIT! ${character.name} deals $damage damage!';
    } else if (attackRoll == 1 || totalAttack < _currentEnemy!.ac) {
      logEntry = attackRoll == 1
          ? 'Critical miss! ${character.name} stumbles!'
          : '${character.name} misses! (Rolled $totalAttack vs AC ${_currentEnemy!.ac})';
    } else {
      final damage = character.rollDamage('1d8');
      _currentEnemy = _currentEnemy!.copyWith(
        hp: (_currentEnemy!.hp - damage).clamp(0, _currentEnemy!.maxHp),
      );
      logEntry =
          '${character.name} hits for $damage damage! (Rolled $totalAttack)';
    }

    _battleLog.add(logEntry);
    if (_battleLog.length > 8) _battleLog.removeAt(0);

    if (_currentEnemy!.hp <= 0) {
      _handleVictory();
    } else {
      _isPlayerTurn = false;
      _isDefending = false;
      notifyListeners();
      _enemyTurn();
    }
  }

  void playerDefend() {
    if (!_isPlayerTurn) return;

    _isDefending = true;
    _battleLog.add('${_state.character!.name} takes a defensive stance!');
    if (_battleLog.length > 8) _battleLog.removeAt(0);

    _isPlayerTurn = false;
    notifyListeners();
    _enemyTurn();
  }

  void useAbility(String abilityName) {
    if (!_isPlayerTurn || _state.character == null || _currentEnemy == null) {
      return;
    }

    final character = _state.character!;
    final random = math.Random();

    switch (abilityName.toLowerCase()) {
      case 'power attack':
        // -2 attack, +4 damage
        final attackRoll = random.nextInt(20) + 1;
        final totalAttack = attackRoll + character.attackBonus - 2;
        if (totalAttack >= _currentEnemy!.ac) {
          final damage = character.rollDamage('1d8') + 4;
          _currentEnemy = _currentEnemy!.copyWith(
            hp: (_currentEnemy!.hp - damage).clamp(0, _currentEnemy!.maxHp),
          );
          _battleLog.add('Power Attack hits for $damage damage!');
        } else {
          _battleLog.add('Power Attack misses!');
        }
        break;

      case 'fireball':
        if (character.spellSlots.level1 > 0) {
          final damage = 8 + random.nextInt(16); // 2d8 + int mod
          _currentEnemy = _currentEnemy!.copyWith(
            hp: (_currentEnemy!.hp - damage).clamp(0, _currentEnemy!.maxHp),
          );
          _state = _state.copyWith(
            character: character.copyWith(
              spellSlots: character.spellSlots.copyWith(
                level1: character.spellSlots.level1 - 1,
              ),
            ),
          );
          _battleLog.add('Fireball engulfs the enemy for $damage damage!');
        } else {
          _battleLog.add('No spell slots remaining!');
          notifyListeners();
          return;
        }
        break;

      case 'heal':
        if (character.spellSlots.level1 > 0) {
          final healAmount = 8 + random.nextInt(8);
          final newHp = (character.hp + healAmount).clamp(0, character.totalMaxHp);
          _state = _state.copyWith(
            character: character.copyWith(
              hp: newHp,
              spellSlots: character.spellSlots.copyWith(
                level1: character.spellSlots.level1 - 1,
              ),
            ),
          );
          _battleLog.add('${character.name} heals for $healAmount HP!');
        } else {
          _battleLog.add('No spell slots remaining!');
          notifyListeners();
          return;
        }
        break;

      case 'sneak attack':
        final attackRoll = random.nextInt(20) + 1;
        if (attackRoll >= 15) {
          // Higher threshold
          final damage = character.rollDamage('3d6');
          _currentEnemy = _currentEnemy!.copyWith(
            hp: (_currentEnemy!.hp - damage).clamp(0, _currentEnemy!.maxHp),
          );
          _battleLog.add('Sneak Attack! $damage damage!');
        } else {
          _battleLog.add('Sneak Attack fails to find an opening!');
        }
        break;

      default:
        playerAttack();
        return;
    }

    if (_battleLog.length > 8) _battleLog.removeAt(0);

    if (_currentEnemy!.hp <= 0) {
      _handleVictory();
    } else {
      _isPlayerTurn = false;
      notifyListeners();
      _enemyTurn();
    }
  }

  void _enemyTurn() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_currentEnemy == null || _state.character == null) return;

      final enemy = _currentEnemy!;
      final character = _state.character!;
      final random = math.Random();

      final attackRoll = random.nextInt(20) + 1;
      final totalAttack = attackRoll + enemy.attackBonus;
      final targetAC = _isDefending ? character.totalAC + 4 : character.totalAC;

      String logEntry;
      if (attackRoll == 1 || totalAttack < targetAC) {
        logEntry = _isDefending
            ? '${character.name} blocks the ${enemy.name}\'s attack!'
            : '${enemy.name} misses!';
      } else {
        var damage = enemy.rollDamage();
        if (_isDefending) {
          damage = (damage / 2).ceil();
        }
        if (attackRoll == 20) {
          damage *= 2;
          logEntry = '${enemy.name} CRITS for $damage damage!';
        } else {
          logEntry = '${enemy.name} hits for $damage damage!';
        }

        final newHp = (character.hp - damage).clamp(0, character.totalMaxHp);
        _state = _state.copyWith(
          character: character.copyWith(hp: newHp),
        );

        if (newHp <= 0) {
          _handleDefeat();
          return;
        }
      }

      _battleLog.add(logEntry);
      if (_battleLog.length > 8) _battleLog.removeAt(0);
      _isPlayerTurn = true;
      _isDefending = false;
      notifyListeners();
    });
  }

  void _handleVictory() {
    final enemy = _currentEnemy!;
    final character = _state.character!;

    // Award XP and gold
    final xpGained = enemy.xpReward;
    final goldGained = enemy.rollGold();
    int newXp = character.xp + xpGained;
    int newLevel = character.level;
    int newXpToNext = character.xpToNextLevel;
    int newMaxHp = character.maxHp;

    // Level up check
    while (newXp >= newXpToNext && newLevel < 20) {
      newXp -= newXpToNext;
      newLevel++;
      newXpToNext = (newXpToNext * 1.5).round();
      newMaxHp += 5 + character.abilityScores.conMod;
      _battleLog.add('LEVEL UP! Now level $newLevel!');
    }

    final rankingPoints = character.rankingPoints + (enemy.isBoss ? 100 : 10);
    final newRankTier = Character.calculateRankTier(rankingPoints);

    _state = _state.copyWith(
      character: character.copyWith(
        xp: newXp,
        level: newLevel,
        xpToNextLevel: newXpToNext,
        maxHp: newMaxHp,
        hp: newLevel > character.level ? newMaxHp : character.hp,
        gold: character.gold + goldGained,
        rankingPoints: rankingPoints,
        rankTier: newRankTier,
      ),
      currentScreen: GameScreen.victory,
    );

    _addToLog('Victory! Gained $xpGained XP and $goldGained gold!');

    // Update quest progress
    _updateQuestProgress('kill', null, 1);
    if (enemy.isBoss) {
      _updateQuestProgress('kill_boss', enemy.type.name, 1);
      
      // Handle guaranteed drops
      if (enemy.guaranteedDrop != null) {
        final inventory = List<String>.from(_state.character!.inventory);
        inventory.add(enemy.guaranteedDrop!);
        _state = _state.copyWith(
          character: _state.character!.copyWith(inventory: inventory),
        );
        _addToLog('Obtained: ${enemy.guaranteedDrop}!');
      }
    }

    notifyListeners();
  }

  void _handleDefeat() {
    _battleLog.add('${_state.character!.name} has fallen...');
    _state = _state.copyWith(currentScreen: GameScreen.defeat);
    notifyListeners();
  }

  void returnToMap() {
    _currentEnemy = null;
    _battleLog = [];
    _state = _state.copyWith(currentScreen: GameScreen.map);
    notifyListeners();
  }

  void retryBattle() {
    // Restore some HP and try again
    final character = _state.character!;
    _state = _state.copyWith(
      character: character.copyWith(
        hp: (character.totalMaxHp * 0.5).round(),
        spellSlots: character.spellSlots.restoreAll(),
      ),
      currentScreen: GameScreen.map,
    );
    _currentEnemy = null;
    _battleLog = [];
    notifyListeners();
  }

  // Quest System
  void _updateQuestProgress(String type, String? targetId, int amount) {
    final quests = List<Quest>.from(_state.quests);
    bool updated = false;

    for (int i = 0; i < quests.length; i++) {
      final quest = quests[i];
      if (quest.status != QuestStatus.active) continue;

      final objectives = List<QuestObjective>.from(quest.objectives);
      for (int j = 0; j < objectives.length; j++) {
        final obj = objectives[j];
        if (obj.type == type && (targetId == null || obj.targetId == targetId)) {
          objectives[j] = obj.copyWith(
            currentCount: (obj.currentCount + amount).clamp(0, obj.requiredCount),
          );
          updated = true;
        }
      }

      if (updated) {
        var newStatus = quest.status;
        if (objectives.every((o) => o.currentCount >= o.requiredCount)) {
          newStatus = QuestStatus.completed;
          _addToLog('Quest completed: ${quest.title}!');
        }
        quests[i] = quest.copyWith(objectives: objectives, status: newStatus);
      }
    }

    if (updated) {
      _state = _state.copyWith(quests: quests);
    }
  }

  void acceptQuest(String questId) {
    final quests = List<Quest>.from(_state.quests);
    final index = quests.indexWhere((q) => q.id == questId);
    if (index >= 0 && quests[index].status == QuestStatus.available) {
      quests[index] = quests[index].copyWith(status: QuestStatus.active);
      _state = _state.copyWith(quests: quests);
      _addToLog('Quest accepted: ${quests[index].title}');
      notifyListeners();
    }
  }

  void claimQuestReward(String questId) {
    final quests = List<Quest>.from(_state.quests);
    final index = quests.indexWhere((q) => q.id == questId);
    if (index >= 0 && quests[index].status == QuestStatus.completed) {
      final quest = quests[index];
      final character = _state.character!;

      // Apply rewards
      var newGold = character.gold + quest.reward.gold;
      var newXp = character.xp + quest.reward.xp;
      final newInventory = List<String>.from(character.inventory)
        ..addAll(quest.reward.items);
      var newPoints = character.rankingPoints + quest.reward.rankingPoints;
      var newTalents = character.talents.copyWith(
        pointsAvailable:
            character.talents.pointsAvailable + quest.reward.talentPoints,
      );

      quests[index] = quest.copyWith(status: QuestStatus.rewardClaimed);

      // Unlock next quest
      for (int i = 0; i < quests.length; i++) {
        if (quests[i].prerequisiteQuestId == questId &&
            quests[i].status == QuestStatus.locked) {
          quests[i] = quests[i].copyWith(status: QuestStatus.available);
        }
      }

      _state = _state.copyWith(
        character: character.copyWith(
          gold: newGold,
          xp: newXp,
          inventory: newInventory,
          rankingPoints: newPoints,
          talents: newTalents,
        ),
        quests: quests,
      );

      _addToLog('Claimed rewards for: ${quest.title}!');
      notifyListeners();
    }
  }

  // Village/Town
  void enterVillage() {
    _state = _state.copyWith(currentScreen: GameScreen.village);
    notifyListeners();
  }

  void exitVillage() {
    _state = _state.copyWith(currentScreen: GameScreen.map);
    notifyListeners();
  }

  void restAtFountain() {
    final character = _state.character!;
    _state = _state.copyWith(
      character: character.copyWith(
        hp: character.totalMaxHp,
        spellSlots: character.spellSlots.restoreAll(),
      ),
    );
    _addToLog('Rested at the fountain. HP and spell slots restored!');
    notifyListeners();
  }

  // Activity Log
  void _addToLog(String message) {
    final log = List<String>.from(_state.activityLog);
    log.insert(0, message);
    if (log.length > 50) log.removeLast();
    _state = _state.copyWith(activityLog: log);
  }

  // Settings
  void toggleReducedMotion() {
    _state = _state.copyWith(reducedMotion: !_state.reducedMotion);
    notifyListeners();
  }

  // Save/Load System
  Future<void> saveGame(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    final saveData = _state.copyWith(lastSaved: DateTime.now()).toJson();
    await prefs.setString('$_saveKeyPrefix$slot', jsonEncode(saveData));
    notifyListeners();
  }

  Future<bool> loadGame(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    final saveJson = prefs.getString('$_saveKeyPrefix$slot');
    if (saveJson == null) return false;

    try {
      final saveData = jsonDecode(saveJson) as Map<String, dynamic>;
      _state = GameState.fromJson(saveData);
      _loadCurrentMap();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<GameState?>> getSaveSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final slots = <GameState?>[];

    for (int i = 0; i < maxSaveSlots; i++) {
      final saveJson = prefs.getString('$_saveKeyPrefix$i');
      if (saveJson != null) {
        try {
          slots.add(GameState.fromJson(jsonDecode(saveJson)));
        } catch (e) {
          slots.add(null);
        }
      } else {
        slots.add(null);
      }
    }

    return slots;
  }

  Future<void> deleteSave(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_saveKeyPrefix$slot');
    notifyListeners();
  }
}
