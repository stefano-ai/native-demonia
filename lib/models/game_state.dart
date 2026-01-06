import 'character.dart';
import 'quest.dart';

enum GameScreen {
  title,
  characterSelect,
  map,
  village,
  battle,
  victory,
  defeat,
}

class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  Position copyWith({int? x, int? y}) => Position(x ?? this.x, y ?? this.y);

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory Position.fromJson(Map<String, dynamic> json) =>
      Position(json['x'] ?? 0, json['y'] ?? 0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class StoryFlags {
  final bool metHerald;
  final bool metEldric;
  final bool metMira;
  final bool acceptedChapelQuest;
  final bool defeatedWarden;
  final bool foundSigilFragment;
  final bool completedTutorial;
  final bool completedInterfaceIntro;

  const StoryFlags({
    this.metHerald = false,
    this.metEldric = false,
    this.metMira = false,
    this.acceptedChapelQuest = false,
    this.defeatedWarden = false,
    this.foundSigilFragment = false,
    this.completedTutorial = false,
    this.completedInterfaceIntro = false,
  });

  StoryFlags copyWith({
    bool? metHerald,
    bool? metEldric,
    bool? metMira,
    bool? acceptedChapelQuest,
    bool? defeatedWarden,
    bool? foundSigilFragment,
    bool? completedTutorial,
    bool? completedInterfaceIntro,
  }) {
    return StoryFlags(
      metHerald: metHerald ?? this.metHerald,
      metEldric: metEldric ?? this.metEldric,
      metMira: metMira ?? this.metMira,
      acceptedChapelQuest: acceptedChapelQuest ?? this.acceptedChapelQuest,
      defeatedWarden: defeatedWarden ?? this.defeatedWarden,
      foundSigilFragment: foundSigilFragment ?? this.foundSigilFragment,
      completedTutorial: completedTutorial ?? this.completedTutorial,
      completedInterfaceIntro:
          completedInterfaceIntro ?? this.completedInterfaceIntro,
    );
  }

  Map<String, dynamic> toJson() => {
        'metHerald': metHerald,
        'metEldric': metEldric,
        'metMira': metMira,
        'acceptedChapelQuest': acceptedChapelQuest,
        'defeatedWarden': defeatedWarden,
        'foundSigilFragment': foundSigilFragment,
        'completedTutorial': completedTutorial,
        'completedInterfaceIntro': completedInterfaceIntro,
      };

  factory StoryFlags.fromJson(Map<String, dynamic> json) => StoryFlags(
        metHerald: json['metHerald'] ?? false,
        metEldric: json['metEldric'] ?? false,
        metMira: json['metMira'] ?? false,
        acceptedChapelQuest: json['acceptedChapelQuest'] ?? false,
        defeatedWarden: json['defeatedWarden'] ?? false,
        foundSigilFragment: json['foundSigilFragment'] ?? false,
        completedTutorial: json['completedTutorial'] ?? false,
        completedInterfaceIntro: json['completedInterfaceIntro'] ?? false,
      );
}

class GameState {
  final String id;
  final String saveName;
  final DateTime lastSaved;
  final Character? character;
  final GameScreen currentScreen;
  final int currentFloor;
  final Map<int, Position> playerPositions;
  final Set<String> clearedTiles;
  final Set<String> openedChests;
  final Set<String> unlockedRegions;
  final Set<String> discoveredLore;
  final List<Quest> quests;
  final List<Achievement> achievements;
  final List<String> mailbox;
  final List<String> activityLog;
  final StoryFlags storyFlags;
  final bool reducedMotion;

  GameState({
    required this.id,
    this.saveName = 'Save 1',
    DateTime? lastSaved,
    this.character,
    this.currentScreen = GameScreen.title,
    this.currentFloor = 1,
    Map<int, Position>? playerPositions,
    Set<String>? clearedTiles,
    Set<String>? openedChests,
    Set<String>? unlockedRegions,
    Set<String>? discoveredLore,
    List<Quest>? quests,
    List<Achievement>? achievements,
    List<String>? mailbox,
    List<String>? activityLog,
    this.storyFlags = const StoryFlags(),
    this.reducedMotion = false,
  })  : lastSaved = lastSaved ?? DateTime.now(),
        playerPositions = playerPositions ?? {1: const Position(5, 12)},
        clearedTiles = clearedTiles ?? {},
        openedChests = openedChests ?? {},
        unlockedRegions = unlockedRegions ?? {'goblin_warrens'},
        discoveredLore = discoveredLore ?? {},
        quests = quests ?? List.from(QuestDatabase.defaultQuests),
        achievements =
            achievements ?? List.from(QuestDatabase.defaultAchievements),
        mailbox = mailbox ?? [],
        activityLog = activityLog ?? [];

  Position get currentPosition =>
      playerPositions[currentFloor] ?? const Position(5, 12);

  String get timeSinceLastSave {
    final diff = DateTime.now().difference(lastSaved);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  GameState copyWith({
    String? id,
    String? saveName,
    DateTime? lastSaved,
    Character? character,
    GameScreen? currentScreen,
    int? currentFloor,
    Map<int, Position>? playerPositions,
    Set<String>? clearedTiles,
    Set<String>? openedChests,
    Set<String>? unlockedRegions,
    Set<String>? discoveredLore,
    List<Quest>? quests,
    List<Achievement>? achievements,
    List<String>? mailbox,
    List<String>? activityLog,
    StoryFlags? storyFlags,
    bool? reducedMotion,
  }) {
    return GameState(
      id: id ?? this.id,
      saveName: saveName ?? this.saveName,
      lastSaved: lastSaved ?? this.lastSaved,
      character: character ?? this.character,
      currentScreen: currentScreen ?? this.currentScreen,
      currentFloor: currentFloor ?? this.currentFloor,
      playerPositions: playerPositions ?? Map.from(this.playerPositions),
      clearedTiles: clearedTiles ?? Set.from(this.clearedTiles),
      openedChests: openedChests ?? Set.from(this.openedChests),
      unlockedRegions: unlockedRegions ?? Set.from(this.unlockedRegions),
      discoveredLore: discoveredLore ?? Set.from(this.discoveredLore),
      quests: quests ?? List.from(this.quests),
      achievements: achievements ?? List.from(this.achievements),
      mailbox: mailbox ?? List.from(this.mailbox),
      activityLog: activityLog ?? List.from(this.activityLog),
      storyFlags: storyFlags ?? this.storyFlags,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'saveName': saveName,
        'lastSaved': lastSaved.toIso8601String(),
        'character': character?.toJson(),
        'currentScreen': currentScreen.index,
        'currentFloor': currentFloor,
        'playerPositions':
            playerPositions.map((k, v) => MapEntry(k.toString(), v.toJson())),
        'clearedTiles': clearedTiles.toList(),
        'openedChests': openedChests.toList(),
        'unlockedRegions': unlockedRegions.toList(),
        'discoveredLore': discoveredLore.toList(),
        'quests': quests.map((q) => q.toJson()).toList(),
        'achievements': achievements.map((a) => a.toJson()).toList(),
        'mailbox': mailbox,
        'activityLog': activityLog,
        'storyFlags': storyFlags.toJson(),
        'reducedMotion': reducedMotion,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    final posMap = <int, Position>{};
    if (json['playerPositions'] != null) {
      (json['playerPositions'] as Map<String, dynamic>).forEach((k, v) {
        posMap[int.parse(k)] = Position.fromJson(v);
      });
    }

    return GameState(
      id: json['id'] ?? '',
      saveName: json['saveName'] ?? 'Save',
      lastSaved: json['lastSaved'] != null
          ? DateTime.parse(json['lastSaved'])
          : DateTime.now(),
      character: json['character'] != null
          ? Character.fromJson(json['character'])
          : null,
      currentScreen: GameScreen.values[json['currentScreen'] ?? 0],
      currentFloor: json['currentFloor'] ?? 1,
      playerPositions: posMap,
      clearedTiles: Set<String>.from(json['clearedTiles'] ?? []),
      openedChests: Set<String>.from(json['openedChests'] ?? []),
      unlockedRegions: Set<String>.from(json['unlockedRegions'] ?? []),
      discoveredLore: Set<String>.from(json['discoveredLore'] ?? []),
      quests: (json['quests'] as List?)
              ?.map((q) => Quest.fromJson(q))
              .toList() ??
          [],
      achievements: (json['achievements'] as List?)
              ?.map((a) => Achievement.fromJson(a))
              .toList() ??
          [],
      mailbox: List<String>.from(json['mailbox'] ?? []),
      activityLog: List<String>.from(json['activityLog'] ?? []),
      storyFlags: StoryFlags.fromJson(json['storyFlags'] ?? {}),
      reducedMotion: json['reducedMotion'] ?? false,
    );
  }
}
