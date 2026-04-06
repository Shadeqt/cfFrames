# Clock / TimeManager Investigation (Classic Era 1.15+)

## Addon: Blizzard_TimeManager (load-on-demand)

Loaded when the player clicks the minimap clock area or via other triggers.
Must be darkened via `ADDON_LOADED` event since frames don't exist at init.

## Frames and regions

### TimeManagerClockButton (minimap clock display)

- The small clock text visible on the minimap border
- `select(1, TimeManagerClockButton:GetRegions())` — the border/background texture
- **This is the only element visible on the combat screen**
- Darkening: `DarkenTexture()` on the first region

### TimeManagerFrame (clock settings popup)

- Opens when you click the clock button
- Contains multiple regions including `TimeManagerGlobe` (a globe texture)
- The globe should be skipped when darkening (it looks wrong darkened)
- Darkening approach: iterate `GetRegions()`, skip any named `"TimeManagerGlobe"`, `DarkenTexture()` the rest
- **This is a popup — not visible during combat**

### TimeManagerFrameInset.NineSlice

- The inset border inside the TimeManagerFrame popup
- Darkening: `DarkenRegions(TimeManagerFrameInset.NineSlice)`
- **Part of the popup — not visible during combat**

### StopwatchTabFrame

- Tab button to open the stopwatch from the clock popup
- Darkening: `DarkenRegions(StopwatchTabFrame)`
- **Part of the popup — not visible during combat**

### StopwatchFrame

- The floating stopwatch timer frame
- Darkening: `DarkenRegions(StopwatchFrame)`
- **Popup/utility frame — not visible during combat**

## Summary

| Element | Visible during combat? | Darken? |
|---|---|---|
| TimeManagerClockButton (1st region) | Yes — on minimap | Yes |
| TimeManagerFrame regions (minus globe) | No — popup | No |
| TimeManagerFrameInset.NineSlice | No — popup | No |
| StopwatchTabFrame | No — popup | No |
| StopwatchFrame | No — popup | No |
