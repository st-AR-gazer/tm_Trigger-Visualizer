![Signed](https://img.shields.io/badge/Signed-No-FF3333)
![Trackmania2020](https://img.shields.io/badge/Game-Trackmania-blue)

# Trigger Visualizer

Displays map trigger volumes without having to select the specific tool in  play, editor, mediatracker mesh modeller.

## Layout

Core code lives in `src/trigger/`.

- `data/sources/*` reads trigger data from the map.
- `render/` projects trigger volumes, outlines, fills, labels, and tile icons.
- `ui/` contains settings and the developer diagnostics panel.

## Trigger Sources

- Offzone volumes from map offzone data.
- MediaTracker trigger volumes from tracks, clips, and clip-specific trigger metadata.
- Crystal trigger shapes from public block/item trigger surfaces and models.

Crystal support includes all triggers in all nadeo blocks/items as well as custom blocks/items (for those pesky hidden trigger volumes that some mappers hide).

*Note, `GateExpandableSpecial*` and `GateExpandableGameplay*` blocks are drawn as approximate rectangles, data used is block placement, direction, variant size, and material/name metadata. `GateExpandableFinish*` uses a different method for getting the TriggerShape that is not exposed through the "Special" or "Gameplay" expandables, so it is still correct. Runtime expandable clip connectivity and trigger objects are intentionally not probed because those paths were unstable in-game... If any1 is interested the old investigation code is kept under `discoveries/expandable/` for reference.

## Mapper Commands

Map comments can include Trigger Visualizer commands:

```text
/trigger-visualizer <trigger-type>,<> suggest-off
/trigger-visualizer <trigger-type>,<> force-off
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
trigger type, they only apply to matching sources, MediaTracker subtypes, Crystal subtypes, or gameplay trigger types.
An empty target list, `<>`, `*`, `all`, or `everything` is treated as the same
wildcard as no trigger type.

Examples:

```text
/trigger-visualizer camera,offzone,crystal suggest-off
/trigger-visualizer cam3 force-off
/trigger-visualizer fog,cartrails suggest-off
/trigger-visualizer crystal suggest-off
/trigger-visualizer boost2 force-off
/trigger-visualizer crystalgate,checkpoint suggest-off
/trigger-visualizer * force-off
```
*Note, these are read from the maps 'map comment'

Supported source targets:

- `MediaTracker`
- `Offzone`
- `Crystal`

Supported Crystal subtype targets:

- `CrystalBlock`
- `CrystalBlockWaypoint`
- `CrystalScreenInteraction`
- `CrystalGate`
- `CrystalTeleporter`
- `CrystalItem`
- `CrystalBlockItem`

Supported gameplay trigger targets:

- `Checkpoint`
- `Finish`
- `StartFinish`
- `Turbo`
- `Turbo2`
- `TurboRoulette`
- `TurboRouletteYellow`
- `TurboRouletteCyan`
- `TurboRoulettePurple`
- `Boost`
- `Boost2`
- `Cruise`
- `NoBrakes`
- `NoEngine`
- `NoSteering`
- `Slowmo`
- `Fragile`
- `Reset`
- `ForceAcceleration`
- `NoGrip`
- `VehicleTransformReset`
- `VehicleTransformCarSnow`
- `VehicleTransformCarRally`
- `VehicleTransformCarDesert`

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
- `MediaTrackerReset`
- `Unknown`

Target names are case-insensitive. Use no spaces inside the comma-separated target list; hyphens and underscores are accepted. Use `Reset` for Crystal/gameplay reset triggers, and `MediaTrackerReset`, `MTReset`, or `Empty` for empty MediaTracker clips that reset camera switches.

## Build

```powershell
python _build.py
```

## Credits

ar
