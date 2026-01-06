# Demonia RPG - HD Asset Specifications

This document provides detailed specifications for all PNG image assets required for the Demonia RPG game. All assets should be created in HD quality (at least 512x512 pixels) with transparent backgrounds where applicable.

## Asset Directory Structure

```
assets/
├── tiles/
│   ├── stone_floor.png
│   ├── grass.png
│   ├── water.png
│   ├── wood_floor.png
│   ├── wall_stone.png
│   ├── wall_wood.png
│   ├── door_closed.png
│   ├── door_open.png
│   ├── chest_closed.png
│   ├── chest_open.png
│   ├── stairs_down.png
│   └── stairs_up.png
└── sprites/
    ├── player_warrior.png
    ├── player_mage.png
    ├── player_rogue.png
    ├── goblin.png
    ├── orc.png
    ├── troll.png
    ├── skeleton.png
    ├── ghost.png
    ├── demon.png
    ├── dragon.png
    ├── npc_merchant.png
    ├── npc_guard.png
    ├── npc_healer.png
    └── npc_questgiver.png
```

## Tile Assets (512x512 pixels)

### Floor Tiles

#### `stone_floor.png`
- **Size:** 512x512 pixels
- **Background:** Opaque
- **Description:** Dark grey stone floor with visible cracks and weathering
- **Color Scheme:** Grey tones (#3C3C3C to #5A5A5A)
- **Details:** Show mortar lines between stones, subtle texture variation, ancient dungeon aesthetic

#### `grass.png`
- **Size:** 512x512 pixels
- **Background:** Opaque
- **Description:** Lush green grass with individual blades visible
- **Color Scheme:** Green tones (#2D5016 to #4A8028)
- **Details:** Varied grass blade heights, subtle shadow depth, natural outdoor feel

#### `water.png`
- **Size:** 512x512 pixels
- **Background:** Opaque
- **Description:** Deep blue water with animated ripple effect texture
- **Color Scheme:** Blue tones (#1E3A5F to #2E5A8F)
- **Details:** Light reflections, ripple patterns, semi-transparent appearance

#### `wood_floor.png`
- **Size:** 512x512 pixels
- **Background:** Opaque
- **Description:** Wooden planks with visible grain
- **Color Scheme:** Brown tones (#6B4423 to #8B6535)
- **Details:** Wood grain texture, plank separation lines, weathered appearance

### Wall Tiles

#### `wall_stone.png`
- **Size:** 512x512 pixels
- **Background:** Opaque
- **Description:** Solid stone wall with brick pattern
- **Color Scheme:** Dark grey (#2A2A2A to #404040)
- **Details:** Brick mortar lines, rough stone texture, medieval dungeon style

#### `wall_wood.png`
- **Size:** 512x512 pixels
- **Background:** Opaque
- **Description:** Wooden wall with vertical planks
- **Color Scheme:** Brown tones (#4A3020 to #6B4423)
- **Details:** Vertical plank pattern, metal rivets/nails, medieval construction

### Interactive Tiles

#### `door_closed.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Heavy wooden door in closed position
- **Color Scheme:** Dark brown (#3E2723) with iron fittings
- **Details:** Metal hinges, door handle, iron reinforcements, closed state

#### `door_open.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Same door but in open position (rotated perspective)
- **Color Scheme:** Dark brown (#3E2723) with iron fittings
- **Details:** Shows door swung open, visible interior, open state

#### `chest_closed.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Treasure chest with golden glow, lid closed
- **Color Scheme:** Gold (#FFD700) with brown wood
- **Details:** Ornate lock, metallic bands, magical glow effect, closed lid

#### `chest_open.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Same treasure chest with lid open, light emanating
- **Color Scheme:** Gold (#FFD700) with brown wood
- **Details:** Open lid, visible interior, magical light rays, empty state

#### `stairs_down.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Stone staircase leading downward with purple glow
- **Color Scheme:** Grey stone with purple (#7B68EE) mystical glow
- **Details:** Descending steps, purple magical aura, downward arrow or indication

#### `stairs_up.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Stone staircase leading upward with blue glow
- **Color Scheme:** Grey stone with blue (#4169E1) mystical glow
- **Details:** Ascending steps, blue magical aura, upward arrow or indication

## Sprite Assets (512x512 pixels)

All sprites should have transparent backgrounds and be designed to be viewed from a top-down perspective.

### Player Sprites

#### `player_warrior.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Warrior character in armor with sword and shield
- **Color Scheme:** Blue (#4169E1) armor with gold (#FFD700) accents
- **Details:** Heavy armor, shield on back, sword visible, heroic stance, male or neutral appearance

#### `player_mage.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Mage character in robes with staff
- **Color Scheme:** Blue (#4169E1) robes with magical aura
- **Details:** Long robes, magical staff, pointed hat or hood, mystical energy effect

#### `player_rogue.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Rogue character in leather armor with dual daggers
- **Color Scheme:** Blue (#4169E1) leather with dark grey accents
- **Details:** Light armor, dual daggers, hood or mask, sneaky pose

### Enemy Sprites

#### `goblin.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Small goblin creature with crude weapon
- **Color Scheme:** Green skin (#2D5016), red eyes (#DC143C)
- **Details:** Small stature, pointed ears, crude club or dagger, menacing expression

#### `orc.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Large orc warrior with battle axe
- **Color Scheme:** Grey-green skin, red eyes (#DC143C)
- **Details:** Muscular build, tusks, battle axe, fierce appearance, larger than goblin

#### `troll.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Massive troll with club
- **Color Scheme:** Grey-brown skin, dark red eyes
- **Details:** Very large and bulky, massive club, hunched posture, regenerating wounds

#### `skeleton.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Undead skeleton warrior with sword
- **Color Scheme:** Bone white (#F5F5DC) with dark accents
- **Details:** Visible bones, rusty sword, tattered clothing, undead appearance

#### `ghost.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Ethereal ghost with flowing form
- **Color Scheme:** Translucent white/blue with glow effect
- **Details:** Semi-transparent, flowing appearance, eerie glow, no legs (floating)

#### `demon.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Infernal demon with horns and claws
- **Color Scheme:** Red (#DC143C) skin with black (#1A0000) accents
- **Details:** Horns, bat wings, clawed hands, tail, hellfire aura

#### `dragon.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Powerful dragon with scales and wings
- **Color Scheme:** Dark red (#8B0000) scales with orange fire
- **Details:** Large wings, sharp claws, horned head, scales visible, fire breath effect

### NPC Sprites

#### `npc_merchant.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Friendly merchant with goods
- **Color Scheme:** Brown and gold tones
- **Details:** Merchant outfit, coin purse, friendly expression, pack or goods visible

#### `npc_guard.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Town guard in armor with spear
- **Color Scheme:** Grey armor (#808080) with blue (#4169E1) tabard
- **Details:** Medium armor, spear or halberd, guard helm, protective stance

#### `npc_healer.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Healer in white robes with healing staff
- **Color Scheme:** White (#FFFAF0) robes with green (#2D5016) accents
- **Details:** White/light robes, healing staff, kind expression, healing aura

#### `npc_questgiver.png`
- **Size:** 512x512 pixels
- **Background:** Transparent
- **Description:** Quest giver with scroll and golden exclamation mark
- **Color Scheme:** Purple/blue robes with gold (#FFD700) accents
- **Details:** Robed figure, quest scroll, golden exclamation mark above head, wise appearance

## Technical Requirements

### All Assets
- **Format:** PNG with transparency (where applicable)
- **Resolution:** Minimum 512x512 pixels (can be larger for higher quality)
- **Color Depth:** 32-bit RGBA
- **Compression:** Optimized PNG compression for web/mobile

### Tile Assets
- **Tileable:** Floor and wall tiles should tile seamlessly when placed adjacent to each other
- **Lighting:** Consistent lighting direction (top-left light source)
- **Style:** Dark fantasy aesthetic matching the game's theme

### Sprite Assets
- **Perspective:** Top-down view (slight 3/4 angle acceptable)
- **Centering:** Character/creature should be centered in the canvas
- **Scale:** Character should occupy 60-80% of the canvas space
- **Shadow:** Include subtle drop shadow for depth

## Color Reference

### Game Color Palette (from theme)
- **Abyss Black:** #0A0A0A
- **Deep Void:** #1A1A1A
- **Stone Gray:** #3C3C3C
- **Bone White:** #F5E6D3
- **Gold:** #FFD700
- **Hellfire Red:** #DC143C
- **Crimson:** #8B0000
- **Mana Blue:** #4169E1
- **Void Purple:** #7B68EE
- **Poison Green:** #2D5016

## Asset Creation Guidelines

1. **Consistency:** Maintain consistent art style across all assets
2. **Quality:** Use high-resolution source images, scale down if needed
3. **Optimization:** Compress PNGs without visible quality loss
4. **Testing:** Test assets at multiple scales (small mobile screens to large tablets)
5. **Accessibility:** Ensure good contrast and visibility against background

## Asset Sources

You can create these assets using:
- **AI Generation:** DALL-E, Midjourney, Stable Diffusion (recommended for consistency)
- **Asset Packs:** Purchase from itch.io, Unity Asset Store, or similar
- **Commission:** Hire pixel artists or illustrators
- **Free Resources:** OpenGameArt.org, Kenney.nl (may require style adaptation)

## Implementation Notes

All assets are automatically loaded by the `AssetManager` class located at `/lib/utils/asset_manager.dart`. The game will:
- Preload all assets on startup for smooth performance
- Use `FilterQuality.high` for crisp rendering
- Apply animations (scaling, pulsing) to certain sprites
- Automatically select correct sprites based on character class, enemy type, and tile state

Once you have created or obtained these assets, place them in the corresponding folders:
- Create `assets/tiles/` folder in project root
- Create `assets/sprites/` folder in project root
- Place each PNG file with the exact filename specified above

After adding the assets, run:
```bash
flutter pub get
flutter run
```

The game will automatically load and display your HD assets!
