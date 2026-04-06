# Tooltip Investigation (Classic Era 1.15+)

## GameTooltip

- Frame: `GameTooltip` (global, available at init)
- Border: `GameTooltip.NineSlice` — contains all border/edge regions
- Source: `Blizzard_GameTooltip/Classic/GameTooltip.xml`
- Darkening approach: `DarkenRegions(GameTooltip.NineSlice)` at init (one-time)
- Tested: vertex colors persist across tooltip shows, no OnShow hook needed

## PartyMemberBuffTooltip

- Frame: `PartyMemberBuffTooltip` (global, may be nil if not loaded)
- Border: `PartyMemberBuffTooltip.NineSlice`
- Darkening approach: `DarkenRegions(PartyMemberBuffTooltip.NineSlice)` at init (one-time)
- Note: also contains buff icons inside — those are separate from the NineSlice border

## Other tooltips (not yet investigated)

- `ShoppingTooltip1` / `ShoppingTooltip2` — item comparison tooltips
- `ItemRefTooltip` — linked item tooltips in chat
- `SmallTextTooltip`
- `EmbeddedItemTooltip`

These likely follow the same pattern: `frame.NineSlice` contains the border regions.

## General pattern

Most Blizzard tooltips in Classic Era use:
- A `NineSlice` child frame for the border (9 texture regions)
- Regions 1-8: edge/corner textures at BORDER draw layer
- Region 9: center/background texture at BACKGROUND draw layer
- `DarkenRegions(tooltip.NineSlice)` darkens all of them (border + background)
- To darken only the border, iterate regions and filter by `GetDrawLayer() == "BORDER"`
