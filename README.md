![Signed](https://img.shields.io/badge/Signed-No-FF3333)
![Trackmania2020](https://img.shields.io/badge/Game-Trackmania-blue)

# Trigger Visualizer

Displays map trigger volumes in normal gameplay. The current implemented source
is Trackmania offzones, with the code structured so more trigger sources can be
added later.

## Layout

Core code lives in `src/trigger/`.

- `data/sources/offzone.as` reads offzone trigger data from the map.
- `render/` projects trigger volumes, outlines, fills, labels, and tile icons.
- `ui/` contains settings and the developer diagnostics panel.

## Mapper Commands

Map comments can include Trigger Visualizer commands:

```text
/trigger-visualizer suggest-off
/trigger-visualizer force-off
/trigger-visualizer suggest-draw-distance-xz <units>
/trigger-visualizer suggest-draw-distance-xz !<blocks>
/trigger-visualizer suggest-draw-distance-y <units>
/trigger-visualizer suggest-draw-distance-y !<blocks>
```

`!<blocks>` converts block counts to world units. X/Z uses 32 units per block;
Y uses 8 units per block. The old offzone command prefix is intentionally not
supported.

## Build

```powershell
python _build.py
```

## Credits

ar
