![Signed](https://img.shields.io/badge/Signed-No-FF3333)
![Trackmania2020](https://img.shields.io/badge/Game-Trackmania-blue)

# Trigger Visualizer

Displays map trigger volumes without having to select the specific tool in editor 
(i.e offzone, or a specific layer in the mediatracker), as well as in the normal 
game mode.

## Layout

Core code lives in `src/trigger/`.

- `data/sources/*` reads trigger data from the map.
- `render/` projects trigger volumes, outlines, fills, labels, and tile icons.
- `ui/` contains settings and the developer diagnostics panel.

## Mapper Commands

Map comments can include Trigger Visualizer commands:

```text
/trigger-visualizer <trigger-type>,<> suggest-off
/trigger-visualizer <trigger-type>,<> force-off
/trigger-visualizer suggest-draw-distance-xz <units>
/trigger-visualizer suggest-draw-distance-xz !<blocks>
/trigger-visualizer suggest-draw-distance-y <units>
/trigger-visualizer suggest-draw-distance-y !<blocks>
```

`!<blocks>` converts block counts to world units. X/Z uses 32 units per block;
Y uses 8 units per block. The old offzone command prefix is intentionally not
supported.

`<trigger-type>` is the trigger you want to explicitally controll the state of,
these can be any of the normal mediatracker trigger clip types, like "camera", 
"ghost" and so on, but it can also be the "mediatracker" source type or the 
"offzone" source type". You can add more than one trigger type by setting a comma
after the first trigger type, as an example:
`/trigger-visualizer camera,offzone suggest-off`
would start the 'camera' and 'offzone' triggers as off by default when a user 
loads onto a map.

Here is a list of everything that is supported as a `<trigger-type>`

Source:
- "MediaTracker"
- "Offzone"

MediaTracker Subtypes
- "Camera"
- "Ghost"
- "Ambiance"
- etc
(more to be added)


## Build

```powershell
python _build.py
```

## Credits

ar
