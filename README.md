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
/trigger-visualizer <trigger-type>[,<trigger-type>...] suggest-off
/trigger-visualizer <trigger-type>[,<trigger-type>...] force-off
/trigger-visualizer suggest-draw-distance-xz <units>
/trigger-visualizer suggest-draw-distance-xz !<blocks>
/trigger-visualizer suggest-draw-distance-y <units>
/trigger-visualizer suggest-draw-distance-y !<blocks>
```

`!<blocks>` converts block counts to world units. X/Z uses 32 units per block;
Y uses 8 units per block. The old offzone command prefix is intentionally not
supported.

`suggest-off` asks Trigger Visualizer to start matching triggers hidden when the
user respects map suggestions. `force-off` always hides matching triggers.
Without a trigger type, these commands apply to all world rendering. With a
trigger type, they only apply to matching sources or MediaTracker subtypes.

Examples:

```text
/trigger-visualizer camera,offzone suggest-off
/trigger-visualizer cam3 force-off
/trigger-visualizer fog,cartrails suggest-off
```

Supported source targets:

- `MediaTracker`
- `Offzone`

Supported MediaTracker subtype targets:

- `Camera`
- `CustomCamera`
- `OrbitalCamera`
- `PathCamera`
- `PlayerCamera`
- `PlayerCameraSubtypeCamDefault`
- `PlayerCameraSubtypeCam1`
- `PlayerCameraSubtypeCam2`
- `PlayerCameraSubtypeCam3`
- `PlayerCameraSubtypeCamHelico`
- `PlayerCameraSubtypeCamFree`
- `PlayerCameraSubtypeCamSpectator`
- `2dTriangles`
- `3dTriangles`
- `CarTrails`
- `ColorsFX`
- `ColorGrading`
- `DepthOfField`
- `DirtyLens`
- `EditingCut`
- `FadingTransition`
- `Fog`
- `Ghost`
- `HDRBloom`
- `Image`
- `InertialTrackingCamFX`
- `ManiaLinkUI`
- `ManiaLinkURL`
- `MusicVolume`
- `OpponentVisibility`
- `ShakeCamFX`
- `Stereo3D`
- `SoundFX`
- `Spectators`
- `Text`
- `Time`
- `TimeSpeed`
- `ToneMapping`
- `VehicleLights`
- `Reset`
- `Unknown`

Target names are case-insensitive. Use no spaces inside the comma-separated
target list; hyphens and underscores are accepted. Legacy aliases such as
`CamCustom`, `Cam1`, and `CarTrail` are still accepted.

## Build

```powershell
python _build.py
```

## Credits

ar
