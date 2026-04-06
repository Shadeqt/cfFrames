# Context Menu Investigation (Classic Era 1.15+)

## System

Classic Era uses the new Blizzard `Menu` system (not the legacy `DropDownList` system).
Context menus are built from anonymous pool frames at `FULLSCREEN_DIALOG` strata.

- `Menu` global exists with: `ModifyMenu`, `GetManager`, `GetOpenMenuTags`, `PrintOpenMenuTags`
- `DropDownList1/2/3` exist as globals but are NOT used for unit frame right-click menus
- `UnitPopup_OpenMenu` is the hook point for unit frame right-click menus
- `ToggleDropDownMenu` exists but does NOT fire for unit popup menus

## Frame structure

All menu frames are anonymous (no `GetName()`), pool-created, at `FULLSCREEN_DIALOG` strata.
Found via `EnumerateFrames()` filtered by strata + no name + `IsShown()`.

### Frame types found (allTex = all regions are Texture type)

#### 4-region per-row frames (allTex, ~17 instances per menu)
- Textures: 130829, 130832, 130830 (ARTWORK layer) + 130831 (HIGHLIGHT layer)
- These are the visible menu row decorations
- Repeats once per menu item/section

#### 9-region NineSlice frames (allTex, 2-3 instances)
- Textures: 137057 x8 (BORDER layer) + 137056 x1 (BACKGROUND layer)
- OR: 136764 x8 (BORDER) + 131071 x1 (BACKGROUND)
- SetVertexColor applies but produces NO visible change
- These frames appear to be invisible/transparent despite being "shown"

#### 3-region separator frames (allTex)
- Textures: 4331838 x2 (ARTWORK) + 4332072 x1 (ARTWORK)
- Likely section dividers

#### 1-region background frames (allTex)
- Texture: 4331838 (BACKGROUND layer)

#### 2-region frames
- Texture: 616343 (BORDER + HIGHLIGHT layers)

## Draw layer summary

| Layer | Contents | Safe to darken? |
|---|---|---|
| BACKGROUND | NineSlice centers, bg fills | No — these are menu backgrounds |
| BORDER | NineSlice edge/corner textures | Technically yes, but no visible effect |
| ARTWORK | Per-row decorations, separators | Yes — these are the visible elements |
| HIGHLIGHT | Hover highlights | No — would break hover feedback |

## What works

- Darkening ALL anonymous FULLSCREEN_DIALOG frames: visually works, darkens entire menu
- Darkening allTex frames only: darkens rows but not text/arrows (arrows are in mixed frames)
- Filtering by draw layer (exclude BACKGROUND + HIGHLIGHT): darkens ARTWORK + BORDER only

## What does NOT work

- SetVertexColor on 9-region NineSlice BORDER regions: color sets but no visual change
- SetBackdropBorderColor on parent frames: method missing on most, wrong frames on others
- Targeting only BORDER draw layer: invisible because NineSlice border regions don't render visibly

## Parent frame structure

- Parent frames are also anonymous, at FULLSCREEN_DIALOG strata
- Most have no `GetBackdrop()` (returns nil)
- A few have backdrops with:
  - edgeFile: `Interface\PVPFrame\UI-Character-PVP-Highlight`
  - bgFile: `Interface\DialogFrame\UI-DialogBox-Background`
  - 8 BORDER regions (tex 136764) + 1 BACKGROUND region (tex 131071)
- But these parent frames with backdrops are NOT consistently the same across reloads (pool reuse)
- Coloring them red produced no visible change — they are not the visible border

## Conclusion

The context menu outer border in Classic Era's new Menu system appears to be rendered by C++ code
or a mechanism not accessible from Lua addon code. The visible elements that CAN be colored are
the per-row ARTWORK textures, but these include both border-like decorations and content elements
that cannot be easily distinguished from Lua.

Border-only darkening is not achievable with current knowledge of the Menu system.
