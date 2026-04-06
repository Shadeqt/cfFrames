# cfFrames v0.3 — Implementation Plan

## Current State

cfFrames v0.2 has a clean modular architecture with dark mode, status bar textures, bigger health bars, class health colors, icon borders/zoom, and various UI fixes. Each feature has Enable/Disable functions, per-character saved variables, and a Settings panel with live toggles.

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

#### 2.2 Dark Mode Icons — `DarkModeIcons.lua` ✓

Icon borders (BackdropTemplate tooltip-style) and icon zoom (SetTexCoord) on:
- **Buffs toggle:** Player buffs, target buffs, pet buffs, compact raid/party buffs
- **Action Bars toggle:** All action bars, pet bar, stance bar, bag slots, backpack

Separate settings toggles: `DarkModeIconBuffs`, `DarkModeIconActionBars`. Full disable support (hides borders, resets zoom).

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

---

## Remaining

### Phase 3 — Nameplate Enhancements

#### 3.1 Nameplate Castbars — `NameplateCastbar.lua`

**What:** Show cast bars on enemy nameplates.

**Reference:** `cfTest/NameplateCastbar.lua`, `_Old/NameplateCastbar.lua`

**Implementation:**
- `cff.EnableNameplateCastbar()` / `cff.DisableNameplateCastbar()`
- On `NAME_PLATE_UNIT_ADDED`: create castbar from `SmallCastingBarFrameTemplate`, call `CastingBarFrame_OnLoad`, set unit via `CastingBarFrame_SetUnit`
- Position below health bar with configurable offset
- Style: border, flash, icon, text — all repositioned to align
- On `NAME_PLATE_UNIT_REMOVED`: hide castbar, clear unit
- Use statusbar texture from StatusBarTexture.lua if enabled

**Settings:**
- Checkbox: "Nameplate Castbars"
- DB key: `NameplateCastbar` (boolean)
- Default: `true`

---

#### 3.2 Nameplate Classification Icons — `NameplateClassification.lua`

**What:** Show elite/rare icons on nameplates.

**Reference:** `_Old/NameplateClassification.lua`

**Implementation:**
- On `NAME_PLATE_UNIT_ADDED`: check `UnitClassification(unit)`
- Create overlay texture (64x32) at health bar right edge
- elite/worldboss → `Interface\Tooltips\EliteNameplateIcon`
- rare/rareelite → `Interface\Tooltips\RareEliteNameplateIcon`
- Desaturate border for rares

**Settings:**
- Checkbox: "Nameplate Classification"
- DB key: `NameplateClassification` (boolean)
- Default: `true`

---

### Phase 4 — Nice-to-Have (Lower Priority)

| Feature | File | Reference |
|---------|------|-----------|
| Druid Mana Bar | `DruidBar.lua` | `cfTest/DruidBar.lua` |
| Player Castbar Icon | `CastbarIcon.lua` | `cfTest/CastbarIcon.lua` |
| Pet Level / XP Bar | `PetLevel.lua` | `_Old/PetLevel.lua`, `_Old/PetXpBar.lua` |
| Hide Combat Glow | `CombatGlow.lua` | `_Old/CombatGlow.lua` |
| Hide Hit Indicator | `HitIndicator.lua` | `_Old/HitIndicator.lua` |

---

## File Structure

```
cfFrames/
├── cfFrames.toc
├── Init.lua
├── DarkMode.lua
├── DarkModeIcons.lua
├── StatusBarTexture.lua
├── BiggerHealthbar.lua
├── HealthbarColor.lua
├── Fixes/
│   ├── ActionBarAlphaFix.lua
│   ├── ToTPortraitFix.lua
│   ├── ToTBackgroundFix.lua
│   ├── TargetCastbarBorderFix.lua
│   ├── TargetNameWidthFix.lua
│   ├── TargetCastbarIconFix.lua
│   ├── NameplateLevelPositionFix.lua
│   ├── ActionBarIconPositionFix.lua
│   └── PetActionBarCheckedFix.lua
├── Settings/
│   ├── _Factory.lua
│   ├── Main.lua
│   └── DarkMode.lua
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
Fixes\ActionBarAlphaFix.lua
Fixes\ToTPortraitFix.lua
Fixes\ToTBackgroundFix.lua
Fixes\TargetCastbarBorderFix.lua
Fixes\TargetNameWidthFix.lua
Fixes\TargetCastbarIconFix.lua
Fixes\NameplateLevelPositionFix.lua
Fixes\ActionBarIconPositionFix.lua
Fixes\PetActionBarCheckedFix.lua
StatusBarTexture.lua
BiggerHealthbar.lua
HealthbarColor.lua
DarkMode.lua
DarkModeIcons.lua
Settings\_Factory.lua
Settings\Main.lua
Settings\DarkMode.lua
```

Init first. Fixes before features (they run at PLAYER_ENTERING_WORLD). Features in dependency order. Settings last so all modules are defined.

---

## Pattern Per Feature File

```lua
-- cff.Enable<Feature>()   — apply changes, register hooks/events
-- cff.Disable<Feature>()  — restore originals, but hooks remain (idempotent re-enable)
-- Local helper functions as needed
-- No global pollution beyond cff namespace
```
