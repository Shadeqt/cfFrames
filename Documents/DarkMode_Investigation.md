# DarkMode Frame Reference

What we learned while implementing dark mode. Use this when adding new frames.

## Techniques

- `SetVertexColor(0.3, 0.3, 0.3)` on Texture objects — core darkening method
- `hooksecurefunc` on `SetVertexColor` with `.cfDarkChanging` recursion guard to prevent Blizzard resets
- Filter with `region:IsObjectType("Texture")` — FontStrings also have `SetVertexColor`, don't darken those
- Late-loading frames (LFG, Clock, LibDBIcon) need a continuous `ADDON_LOADED` listener, not a timer

## Unit Frame Borders

| Global Name | Frame |
|---|---|
| PlayerFrameTexture | Player |
| TargetFrameTextureFrameTexture | Target |
| TargetFrameToTTextureFrameTexture | Target of Target |
| PetFrameTexture | Pet |
| PartyMemberFrame1-4Texture | Party members |

## Action Bars

- `ActionButton1-12` → `:GetNormalTexture()`
- `MultiBarBottomLeftButton1-12` → `:GetNormalTexture()`
- `MultiBarBottomRightButton1-12` → `:GetNormalTexture()`
- `MultiBarRightButton1-12` → `:GetNormalTexture()`
- `MultiBarLeftButton1-12` → `:GetNormalTexture()`
- `PetActionButton1-10` → `:GetNormalTexture()`
- `StanceButton1-10` → `:GetNormalTexture()`

## Main Menu Bar Artwork

| Global Name | Element |
|---|---|
| MainMenuBarTexture0-3 | Stone bar segments behind action buttons |
| MainMenuBarLeftEndCap | Left gryphon |
| MainMenuBarRightEndCap | Right gryphon |
| MainMenuXPBarTexture0-3 | XP bar border (4 segments, not same as MainMenuBarTexture) |
| ExhaustionTickNormal | Rested XP notch marker |
| ExhaustionTickHighlight | Rested XP notch hover state |

## Bag Buttons

Consistent structure across all bag slots (12 regions each):

| Region | Type | Name Pattern | Texture ID | Darken? |
|---|---|---|---|---|
| 1 | Texture | *IconTexture | varies | No — bag icon |
| 2 | FontString | *Count | — | No — item count text |
| 3 | FontString | *Stock | — | No — text |
| 4 | Texture | *SearchOverlay | none | No — search overlay |
| 5 | Texture | unnamed | 651080 | No |
| 6 | Texture | unnamed | none | No |
| 7 | Texture | *SubIconTexture | none | No |
| 8 | Texture | *NormalTexture | 130841 | Yes — border ring |
| 9 | Texture | unnamed | 130839 | No |
| 10 | Texture | unnamed | 130718 | No |
| 11 | Texture | unnamed | none | No |
| 12 | Texture | unnamed | 130724 | No |

Only region 8 (`NormalTexture`, 130841) needs darkening — it's the border ring around the bag icon. Same texture ID on all bags + backpack.

Targets: `CharacterBag0-3SlotNormalTexture`, `MainMenuBarBackpackButtonNormalTexture`

## Minimap

| Global Name | Element | Notes |
|---|---|---|
| MinimapBorder | Main circular border | Available at load |
| MinimapBorderTop | Top border piece | Available at load |
| MiniMapTrackingBorder | Tracking button border | Available at load |
| LFGMinimapFrameBorder | LFG eye border | Deferred — loads with Blizzard_GroupFinder |
| MinimapZoomIn | Zoom in button | Deferred — 4 regions, all textures, +/- sign baked into texture |
| MinimapZoomOut | Zoom out button | Deferred — same as ZoomIn |
| TimeManagerClockButton | Clock button | Deferred — region 1 = border, region 2 = FontString (clock text), region 3 = alarm texture |

### KeyRingButton Regions (4) — SKIPPED

| # | Type | Name | Texture ID | Notes |
|---|---|---|---|---|
| 1 | Texture | unnamed | none | Not visibly noticeable |
| 2 | Texture | unnamed | 130749 | Button + key icon baked together — can't separate |
| 3 | Texture | unnamed | 130748 | Mouseover highlight border — only visible on hover |
| 4 | Texture | unnamed | 130747 | Pressed/clicked state |

Decision: Skip — same problem as MinimapZoomIn/Out. Icons are baked into the border texture so darkening makes them too dark. Code commented out.

### Micro Menu Buttons (MICRO_BUTTONS) — SKIPPED

Consistent structure across all buttons (5 regions each, MainMenuMicroButton has 6):

| Region | What | Texture ID | Notes |
|---|---|---|---|
| 1 | Flash/glow | 462323 | Named `*Flash`, notification effect |
| 2 | Icon/portrait | varies | Unique per button, the actual icon art |
| 3 | Normal state | varies | Border+icon baked together |
| 4 | Pushed/highlight | varies | Border+icon baked together |
| 5 | Disabled state | 130795 | Same on all buttons |

Buttons: CharacterMicroButton, SpellbookMicroButton, TalentMicroButton, QuestLogMicroButton, SocialsMicroButton, GuildMicroButton, WorldMapMicroButton, MainMenuMicroButton, HelpMicroButton.

Can loop dynamically via WoW's `MICRO_BUTTONS` global table.

Decision: Skip — icons baked into border texture, darkening all regions makes buttons look disabled. Same problem as ZoomIn/Out and KeyRing. Code commented out.

### MinimapZoomIn/Out Regions (4 each)

1. Texture 136483 — outer ring
2. Texture 136482 — inner background
3. Texture 136481 — +/- icon (baked into texture, can't separate from border)
4. Texture 136477 — disabled/highlight state

Decision: Skip — icons are baked into the border texture so darkening makes them too dark. Same as KeyRingButton. Code commented out.

### TimeManagerClockButton Regions (3)

| # | Type | Name | Texture ID | Darken? |
|---|---|---|---|---|
| 1 | Texture | unnamed | 137043 | Yes — border |
| 2 | FontString | TimeManagerClockTicker | — | No — clock time text (filtered by IsObjectType) |
| 3 | Texture | TimeManagerAlarmFiredTexture | 137043 | No — alarm indicator, skip |

Currently only region 1 is darkened. Could loop all since FontString is auto-filtered, but region 3 (alarm) would also darken.

### LibDBIcon Buttons

- Dynamic — created by other addons (Questie, Leatrix, etc.)
- Pattern: `_G` keys matching `^LibDBIcon10_` with a `.border` child
- Must scan `_G` in deferred handler since they load late

## TimeManager Panel (click clock to open)

### TimeManagerFrame Regions (20)

| # | Type | Name | Texture ID | Darken? |
|---|---|---|---|---|
| 1 | Texture | TimeManagerFrameBg | 374155 | No — skipped by `Bg$` filter |
| 2 | Texture | TimeManagerFrameTitleBg | 374157 | No — skipped by `Bg$` filter |
| 3 | Texture | TimeManagerFramePortrait | none | No — portrait |
| 4 | Texture | TimeManagerFramePortraitFrame | 374156 | Yes |
| 5 | Texture | TimeManagerFrameTopRightCorner | 374156 | Yes |
| 6 | Texture | TimeManagerFrameTopLeftCorner | 374156 | Yes |
| 7 | Texture | TimeManagerFrameTopBorder | 374157 | Yes |
| 8 | FontString | TimeManagerFrameTitleText | — | No — text |
| 9 | Texture | TimeManagerFrameTopTileStreaks | 374157 | Yes |
| 10 | Texture | TimeManagerFrameBotLeftCorner | 374156 | Yes |
| 11 | Texture | TimeManagerFrameBotRightCorner | 374156 | Yes |
| 12 | Texture | TimeManagerFrameBottomBorder | 374157 | Yes |
| 13 | Texture | TimeManagerFrameLeftBorder | 374153 | Yes |
| 14 | Texture | TimeManagerFrameRightBorder | 374153 | Yes |
| 15 | Texture | TimeManagerFrameBtnCornerLeft | 374156 | Yes |
| 16 | Texture | TimeManagerFrameBtnCornerRight | 374156 | Yes |
| 17 | Texture | TimeManagerFrameButtonBottomBorder | 374157 | Yes |
| 18 | Texture | TimeManagerGlobe | 137046 | No — icon |
| 19 | FontString | TimeManagerFrameTicker | — | No — text |
| 20 | FontString | unnamed | — | No — text |

Uses old-style frame borders, NOT NineSlice. Each border piece is a named global.

### TimeManagerFrameInset

- Has a NineSlice child with border regions — darken all via loop
- `TimeManagerFrameInsetBg` — the inset background

### Stopwatch (child of TimeManager)

**StopwatchFrame Regions (2):**

| # | Name | Texture ID | Notes |
|---|---|---|---|
| 1 | StopwatchFrameBackgroundLeft | 137049 | Named |
| 2 | unnamed | 137049 | Same texture, no global name — must loop to catch |

**StopwatchTabFrame Regions (4):**

| # | Type | Name | Notes |
|---|---|---|---|
| 1 | Texture | StopwatchTabFrameLeft | Darken |
| 2 | Texture | StopwatchTabFrameMiddle | Darken |
| 3 | Texture | StopwatchTabFrameRight | Darken |
| 4 | FontString | StopwatchTitle | Skip — text, use IsObjectType("Texture") filter |

## Future: Lighter Darkening Pass

These elements are currently skipped because icons are baked into border textures — darkening at 0.3 makes them look disabled. However, a lighter value (e.g. 0.55-0.65) could subtly darken them without making icons invisible. Worth testing.

- **MinimapZoomIn/Out** — all 4 regions, baked +/- icons
- **KeyRingButton** — region 2 (130749), baked key icon
- **Micro menu buttons** — loop via `MICRO_BUTTONS` global table, region 2 is the icon
- **ExhaustionTickNormal/Highlight** — rested XP notch, currently darkened at 0.3 but could look better lighter

- **Container frames (opened bags)** — no separate border, leather background IS the frame art. 4 textures per frame: BackgroundTop, BackgroundMiddle1, BackgroundMiddle2, BackgroundBottom (all texture 131003). BackgroundTop includes the portrait area and can't be separated. At 0.3 the whole bag becomes too dark. A lighter value might work but portrait will also dim.

Would need a separate `DarkenTexture` call with a lighter color value, or a second color constant like `COLOR_LIGHT = 0.6`.

## Gotchas

- **FontStrings have SetVertexColor** — always filter with `IsObjectType("Texture")` when looping regions
- **Unnamed regions** — some border pieces have no global name (StopwatchFrame region 2). Must loop `GetRegions()` instead of using `_G["name"]`
- **NineSlice vs old-style** — TimeManagerFrame uses old-style named borders, not NineSlice. Check both patterns.
- **Deferred loading** — LFG, TimeManager, LibDBIcon don't exist at ADDON_LOADED for cfFrames. Use continuous ADDON_LOADED listener.
- **DarkenTexture nil check** — always safe to call with nil, returns early
- **Disable requires restoring** — loop `darkenedTextures` table and set back to `(1, 1, 1)` with `cfDarkChanging` flag
