# cfFrames v0.3 — Implementation Plan

## Current State

cfFrames v0.3 has a clean modular architecture with dark mode, status bar textures, bigger health bars, class health colors, icon borders/zoom, nameplate castbars, player castbar icon, a Core callback system, and various UI fixes. Each feature has Enable/Disable functions, per-character saved variables, and a Settings panel with live toggles.

---

## Completed

### Phase 1 — Core ✓

#### 1.1 StatusBar Textures — `StatusBarTexture.lua` ✓

Custom status bar textures (Retail Bar, Dragonflight, Blizzard default) applied to all health/mana/cast/XP bars. Dropdown in settings.

#### 1.2 Bigger Health Bars — `BiggerHealthbar.lua` ✓

Enlarged player and target health bars with custom frame textures, repositioned elements, and classification-based border swapping.

#### 1.3 Colored Health Bars — `HealthbarColor.lua` ✓

Class-colored health bars for players, reaction-colored for NPCs. Hooks UnitFrameHealthBar_Update, CompactUnitFrame_UpdateHealthColor, and ToT.

### Phase 2 — Dark Mode ✓

#### 2.1 Dark Mode — `DarkMode.lua` ✓

Vertex color darkening + desaturation across all UI elements with per-category toggles:
- Unit Frames (player, target, pet, party, compact raid)
- Action Bars (buttons, bags, menu bar, micro buttons)
- Minimap (borders, zoom, addon icons via LibDBIcon)
- Chat (edit box, tabs)
- Castbars (player, target borders)
- Nameplates (health bar borders)

Exposes `cff.SaveAndDarken` for external modules. Fires `cff.RunCallbacks(M.DarkMode)` on enable for cross-module darkening.

#### 2.2 Dark Mode Icons — `DarkModeIcons.lua` ✓

Icon borders (BackdropTemplate tooltip-style) and icon zoom (SetTexCoord) on:
- **Buffs toggle:** Player buffs, target buffs, pet buffs, compact raid/party buffs
- **Action Bars toggle:** All action bars, pet bar, stance bar, bag slots, backpack

Separate settings toggles: `DarkModeIconBuffs`, `DarkModeIconActionBars`. Full disable support (hides borders, resets zoom).

### Phase 3 — Castbars & Core ✓

#### 3.1 Nameplate Castbars — `NameplateCastbar.lua` ✓

Cast bars on enemy nameplates using `SmallCastingBarFrameTemplate`. Lazy-created per plate, cached on `plate.cffCastBar`. Border, flash, icon, text repositioned. Registered callbacks for DarkMode (darken border) and StatusBar (update texture). Castbar icon has separate show/hide toggle (`NameplateCastbarIcon` module).

#### 3.2 Player Castbar Icon — `PlayerCastbarIcon.lua` ✓

Shows the existing hidden `CastingBarFrame.Icon`, sized to match bar height, positioned left of the bar.

#### 3.3 Pet Castbar — `PetCastbar.lua` ✓

Cast bar for pet frame with icon support, scale/position settings.

#### 3.4 Core Callback System — `Core.lua` ✓

Generic callback registry: `cff.RegisterCallback(key, fn)` / `cff.RunCallbacks(key)` using module keys. Shared `cff.GetStatusBarTexture()` getter with Blizzard fallback.

### Phase 4 — Nameplate Enhancements ✓

#### 4.1 Nameplate Classification Icons — `NameplateClassification.lua` ✓

Elite/rare dragon icons on nameplates. On `NAME_PLATE_UNIT_ADDED`: check `UnitClassification(unit)`, create overlay texture (64x32) at health bar right edge. Elite/worldboss → `EliteNameplateIcon`, rare/rareelite → `RareEliteNameplateIcon`. Enable/disable works on existing and new nameplates.

#### 4.2 Nameplate Settings — `Settings/Nameplate.lua`, `Frames/Nameplates.lua` ✓

Nameplates settings subcategory with: classification toggle, global scale (CVar-based), castbar scale/X/Y, castbar icon show/hide + scale/X/Y. Sliders conditionally hidden when parent feature is off. Apply functions in `Frames/Nameplates.lua`.

### Phase 5 — Frame Positioning ✓

Scale and X/Y offset sliders for player, pet, target frames and their castbars/icons. Each in `Frames/<Name>.lua` with SetPoint hook pattern to preserve Blizzard offsets. Settings in subcategory pages (`Settings/Player.lua`, `Settings/Pet.lua`, `Settings/Target.lua`).

### Fixes ✓

| Fix | File | Description |
|-----|------|-------------|
| ActionBarAlphaFix | `Fixes/ActionBarAlphaFix.lua` | Reduces main bar button NormalTexture alpha to 50% |
| ToTPortraitFix | `Fixes/ToTPortraitFix.lua` | Adjusts Target-of-Target portrait position |
| ToTBackgroundFix | `Fixes/ToTBackgroundFix.lua` | Aligns ToT background with health/mana bars |
| TargetCastbarBorderFix | `Fixes/TargetCastbarBorderFix.lua` | Widens target castbar border alignment |
| TargetNameWidthFix | `Fixes/TargetNameWidthFix.lua` | Increases target name text width |
| TargetCastbarIconFix | `Fixes/TargetCastbarIconFix.lua` | Adjusts target castbar icon vertical position |
| NameplateLevelPositionFix | `Fixes/NameplateLevelPositionFix.lua` | Centers level text on compact nameplates |
| ActionBarIconPositionFix | `Fixes/ActionBarIconPositionFix.lua` | Centers action bar icon textures in buttons |
| PetActionBarCheckedFix | `Fixes/PetActionBarCheckedFix.lua` | Aligns pet button checked texture with icon |
| UnitFrameResetFix | `Fixes/UnitFrameResetFix.lua` | Makes reset-to-default position persist on reload |

---

## Remaining

### Phase 6 — Pet Features

| Feature | File | Reference | Description |
|---------|------|-----------|-------------|
| Pet Debuffs | `PetDebuffs.lua` | `_Old/PetDebuffs.lua` | Show debuff icons on pet frame |
| Pet Level | `PetLevel.lua` | `_Old/PetLevel.lua` | Show pet level when different from player |
| Pet Name | `PetName.lua` | `_Old/PetName.lua` | Reposition pet name above health bar |
| Pet XP Bar | `PetXpBar.lua` | `_Old/PetXpBar.lua` | Show pet experience bar |

---

### Phase 7 — Buff & Aura Features

| Feature | File | Reference | Description |
|---------|------|-----------|-------------|
| Buff Sorting | `BuffSorting.lua` | `_Old/BuffSorting.lua` | Sort player buffs by duration, target buffs by player-cast first |
| Target Castbar Icon | `TargetCastbarIcon.lua` | `_Old/CastbarTargetIcon.lua` | Show spell icon on target castbar |

---

### Phase 8 — UI Tweaks (Simple Toggles)

| Feature | File | Reference | Description |
|---------|------|-----------|-------------|
| Hide Combat Glow | `CombatGlow.lua` | `_Old/CombatGlow.lua` | Hide combat glow on player/pet frames |
| Hide Hit Indicator | `HitIndicator.lua` | `_Old/HitIndicator.lua` | Hide hit text on player/pet frames |
| Hide Group Indicator | `GroupIndicator.lua` | `_Old/GroupIndicator.lua` | Hide group number on player frame |
| Name Background | `NameBackground.lua` | `_Old/NameBackground.lua` | Hide/darken target name background |

---

### Phase 9 — Druid & Class Features

| Feature | File | Reference | Description |
|---------|------|-----------|-------------|
| Druid Mana Bar | `DruidBar.lua` | `_Old/DruidBar.lua`, `cfTest/DruidBar.lua` | Extra mana bar for druids when shapeshifted |

---

### Phase 10 — Remaining Frame Positioning

Most frame positioning is done (Player, Pet, Target, all castbars). Remaining:

| Feature | File | Reference | Description |
|---------|------|-----------|-------------|
| Movable Frames | `Frames/_Movable.lua` | `_Old/Frames/_Movable.lua` | Drag-to-reposition system |
| Target of Target | `Frames/TargetOfTarget.lua` | `_Old/Frames/TargetOfTarget.lua` | ToT frame positioning |

---

## File Structure

```
cfFrames/
├── cfFrames.toc
├── Init.lua
├── Core.lua
├── StatusBarTexture.lua
├── BiggerHealthbar.lua
├── HealthbarColor.lua
├── PlayerCastbarIcon.lua
├── PetCastbar.lua
├── NameplateCastbar.lua
├── NameplateClassification.lua
├── DarkMode.lua
├── DarkModeIcons.lua
├── Fixes/
│   ├── ActionBarAlphaFix.lua
│   ├── ToTPortraitFix.lua
│   ├── ToTBackgroundFix.lua
│   ├── TargetCastbarBorderFix.lua
│   ├── TargetNameWidthFix.lua
│   ├── TargetCastbarIconFix.lua
│   ├── NameplateLevelPositionFix.lua
│   ├── ActionBarIconPositionFix.lua
│   ├── PetActionBarCheckedFix.lua
│   └── UnitFrameResetFix.lua
├── Frames/
│   ├── PlayerFrame.lua
│   ├── PetFrame.lua
│   ├── TargetFrame.lua
│   └── Nameplates.lua
├── Settings/
│   ├── _Factory.lua
│   ├── Main.lua
│   ├── DarkMode.lua
│   ├── Player.lua
│   ├── Pet.lua
│   ├── Target.lua
│   └── Nameplate.lua
├── Media/
│   ├── StatusBar/
│   │   ├── BlizzardRetailBarCrop2.tga
│   │   └── DragonflightTexture.tga
│   └── TargetingFrame/
│       ├── UI-TargetingFrame.blp
│       ├── UI-TargetingFrame-Elite.blp
│       ├── UI-TargetingFrame-Rare.blp
│       ├── UI-TargetingFrame-Rare-Elite.blp
│       └── UI-Player-Status.blp
├── _Docs/
│   └── ImplementationPlan.md
└── _Old/
```

---

## TOC Load Order

```
Init.lua
Core.lua
Fixes\ActionBarAlphaFix.lua
Fixes\ToTPortraitFix.lua
Fixes\ToTBackgroundFix.lua
Fixes\TargetCastbarBorderFix.lua
Fixes\TargetNameWidthFix.lua
Fixes\TargetCastbarIconFix.lua
Fixes\NameplateLevelPositionFix.lua
Fixes\ActionBarIconPositionFix.lua
Fixes\PetActionBarCheckedFix.lua
Fixes\UnitFrameResetFix.lua
StatusBarTexture.lua
BiggerHealthbar.lua
HealthbarColor.lua
PlayerCastbarIcon.lua
PetCastbar.lua
Frames\PlayerFrame.lua
Frames\PetFrame.lua
Frames\TargetFrame.lua
Frames\Nameplates.lua
NameplateCastbar.lua
NameplateClassification.lua
DarkMode.lua
DarkModeIcons.lua
Settings\_Factory.lua
Settings\Main.lua
Settings\DarkMode.lua
Settings\Player.lua
Settings\Pet.lua
Settings\Target.lua
Settings\Nameplate.lua
```

Init first, Core second. Fixes before features (they run at PLAYER_ENTERING_WORLD). Features in dependency order. Frames before feature files that reference Apply functions. DarkMode after features that register callbacks. Settings last so all modules are defined.

---

## Pattern Per Feature File

```lua
-- cff.Enable<Feature>()   — apply changes, register hooks/events
-- cff.Disable<Feature>()  — restore originals, but hooks remain (idempotent re-enable)
-- Local helper functions as needed
-- No global pollution beyond cff namespace
```
