# Quick Start: Creating HD Assets for Demonia RPG

Your RPG is now configured to use HD PNG image assets! Here's how to get started.

## What Changed?

✅ **Code Updated:** The game now loads PNG images instead of drawing graphics procedurally  
✅ **Asset Manager:** Automatically handles sprite selection based on character class, enemy type, etc.  
✅ **Performance:** Images are preloaded on startup for smooth gameplay  
✅ **Quality:** Supports high-resolution assets with FilterQuality.high

## What You Need to Do

Create or obtain 27 PNG image files and place them in the correct folders.

## Option 1: AI Generation (Recommended - Fastest)

Use AI tools like **DALL-E**, **Midjourney**, or **Stable Diffusion** to generate assets:

### Example Prompts:

**For Tiles:**
```
"Dark stone dungeon floor tile, 512x512, top-down view, seamless tileable texture, fantasy RPG game asset, dark grey stone with cracks"

"Green grass field tile, 512x512, top-down view, seamless tileable texture, RPG game asset, lush vibrant grass"

"Stone dungeon wall, 512x512, top-down view, tileable texture, dark medieval fantasy, brick pattern"
```

**For Player Sprites:**
```
"Warrior character sprite, 512x512, transparent background, top-down view, blue armor with sword and shield, fantasy RPG pixel art style"

"Mage character sprite, 512x512, transparent background, top-down view, blue robes with magical staff, fantasy RPG"

"Rogue character sprite, 512x512, transparent background, top-down view, leather armor with dual daggers, hooded"
```

**For Enemy Sprites:**
```
"Goblin enemy sprite, 512x512, transparent background, top-down view, green skin, crude weapon, menacing, fantasy RPG"

"Orc warrior sprite, 512x512, transparent background, top-down view, grey-green skin, battle axe, fierce, fantasy RPG"

"Dragon sprite, 512x512, transparent background, top-down view, red scales, wings, breathing fire, fantasy RPG boss"
```

**For NPC Sprites:**
```
"Merchant NPC sprite, 512x512, transparent background, top-down view, friendly shopkeeper with goods, fantasy RPG"

"Guard NPC sprite, 512x512, transparent background, top-down view, armored guard with spear, fantasy RPG"
```

### Tips for AI Generation:
- Generate multiple versions and pick the best
- Use "fantasy RPG" or "pixel art" in prompts for consistent style
- Request "transparent background" for sprites
- Specify "512x512" for consistent size
- For tiles, add "seamless tileable" to ensure they connect properly

## Option 2: Asset Packs (High Quality)

Purchase professional asset packs from:

- **itch.io**: Search for "fantasy RPG tiles" and "fantasy character sprites"
- **Unity Asset Store**: Many assets work great for Flutter games
- **GameDev Market**: Professional game assets
- **Humble Bundle**: Often has game asset bundles on sale

Look for packs with:
- ✅ Top-down perspective
- ✅ PNG format with transparency
- ✅ Fantasy/medieval theme
- ✅ Commercial license

## Option 3: Free Resources

Download free assets from:

- **OpenGameArt.org**: Large collection of free game assets
- **Kenney.nl**: High-quality free game assets (may need style tweaks)
- **Pixabay**: Free images (search "fantasy game sprites")

## Folder Setup

Create these folders in your project root:

```bash
mkdir -p assets/tiles
mkdir -p assets/sprites
```

## Required Assets (27 files total)

### Tiles (12 files) - Place in `assets/tiles/`
- ✅ stone_floor.png - Dark grey stone floor
- ✅ grass.png - Green grass field
- ✅ water.png - Blue water with ripples
- ✅ wood_floor.png - Wooden planks
- ✅ wall_stone.png - Stone wall/barrier
- ✅ wall_wood.png - Wooden wall
- ✅ door_closed.png - Closed wooden door
- ✅ door_open.png - Open door
- ✅ chest_closed.png - Treasure chest (closed, golden)
- ✅ chest_open.png - Treasure chest (open, empty)
- ✅ stairs_down.png - Stairs going down (purple glow)
- ✅ stairs_up.png - Stairs going up (blue glow)

### Player Sprites (3 files) - Place in `assets/sprites/`
- ✅ player_warrior.png - Warrior with sword/shield
- ✅ player_mage.png - Mage with staff/robes
- ✅ player_rogue.png - Rogue with daggers/hood

### Enemy Sprites (7 files) - Place in `assets/sprites/`
- ✅ goblin.png - Small goblin creature
- ✅ orc.png - Large orc warrior
- ✅ troll.png - Massive troll
- ✅ skeleton.png - Undead skeleton
- ✅ ghost.png - Ethereal ghost
- ✅ demon.png - Horned demon
- ✅ dragon.png - Large dragon (boss)

### NPC Sprites (4 files) - Place in `assets/sprites/`
- ✅ npc_merchant.png - Friendly merchant
- ✅ npc_guard.png - Town guard
- ✅ npc_healer.png - Healer/priest
- ✅ npc_questgiver.png - Quest giver with scroll

## Asset Specifications

- **Format:** PNG
- **Size:** Minimum 512x512 pixels (can be larger)
- **Transparent Background:** Required for sprites
- **Color Depth:** 32-bit RGBA
- **Perspective:** Top-down view (slight 3/4 angle OK)
- **Style:** Consistent dark fantasy aesthetic

See `ASSET_SPECIFICATIONS.md` for detailed specifications, color palettes, and descriptions for each asset.

## After Adding Assets

Once you've placed all PNG files in the correct folders:

```bash
# Verify assets are in place
ls assets/tiles/
ls assets/sprites/

# Uncomment the assets section in pubspec.yaml
# Remove the # from lines 96-128 in pubspec.yaml

# Run the game
flutter pub get
flutter run
```

The game will automatically:
- Load all your HD assets
- Display them with high-quality filtering
- Apply animations (pulse, scale) to sprites
- Select correct sprites based on game state

## Quick Test

To quickly test if assets are working:

1. Create just one test asset: `assets/sprites/player_warrior.png` (any image, 512x512)
2. Run `flutter pub get`
3. Start game and select Warrior class
4. If the image appears on the map, your asset system is working!

## Troubleshooting

**"Asset not found" error:**
- Verify file paths exactly match (case-sensitive)
- Ensure folders are named `assets/tiles/` and `assets/sprites/`
- Run `flutter clean && flutter pub get`

**Images look blurry:**
- Use larger source images (1024x1024 or higher)
- Ensure images are actually high resolution, not upscaled low-res

**Images don't tile properly:**
- Tile assets need seamless edges
- Use AI prompt "seamless tileable texture"
- Or use image editing software to make edges seamless

## Need Help?

- Check `ASSET_SPECIFICATIONS.md` for detailed requirements
- Explore existing free asset packs on OpenGameArt.org
- Use AI generation tools with the prompts above
- Mix and match from different sources (maintain style consistency)

## What Happens Without Assets?

The app will show error messages when trying to load missing PNG files. The old procedural rendering code is still in the file but is no longer called. You MUST add the assets for the game to display properly.

---

Happy asset hunting! Your Demonia RPG will look amazing with HD graphics! 🎮✨
