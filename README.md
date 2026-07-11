![Signed](https://img.shields.io/badge/Signed-No-FF3333)
![Trackmania2020](https://img.shields.io/badge/Game-Trackmania-blue)

# Trigger Visualizer

Displays trigger volumes present in the current runtime context.

## Layout

Core code lives in `src/trigger/`.

- `data/sources/*` reads trigger data from the map.
- `render/` projects trigger volumes, outlines, fills, labels, and tile icons.
- `ui/` contains settings that the project uses.

## Trigger Sources

- Offzone volumes from map offzone data.
- MediaTracker trigger volumes from clips embedded in the map data.
- Crystal trigger shapes from block/item trigger data.

Crystal support discovers trigger shapes exposed by Nadeo and custom blocks/items, including those pesky hidden custom trigger volumes that some mappers use xdd.

`GateExpandableSpecial*` and `GateExpandableGameplay*` blocks are drawn as approximate rectangles because they do not expose their final connected trigger geometry safely. `GateExpandableFinish*` exposes its actual trigger shape through a different path, so its visualization uses the real bounds and merges connected finish pieces without approximating them.

## Mapper Commands

Map comments can include Trigger Visualizer commands:

```text
/trigger-visualizer suggest-off
/trigger-visualizer force-off
/trigger-visualizer <trigger-type>,<> suggest-off
/trigger-visualizer <trigger-type>,<> force-off
/trigger-visualizer <trigger-type>[,<trigger-type>...] suggest-off
/trigger-visualizer <trigger-type>[,<trigger-type>...] force-off
/trigger-visualizer suggest-draw-distance-xz <units>
/trigger-visualizer suggest-draw-distance-xz !<blocks>
/trigger-visualizer suggest-draw-distance-y <units>
/trigger-visualizer suggest-draw-distance-y !<blocks>
/fx hide
/uci hide
```

`!<blocks>` converts block counts to world units using Trackmania's block dimensions. For example, `/trigger-visualizer suggest-draw-distance-xz !2` suggests 64 world units on the X/Z axes, while `/trigger-visualizer suggest-draw-distance-y !2` suggests 16 world units vertically.

`suggest-off` asks Trigger Visualizer to hide matching triggers by default when the user respects map suggestions.
`force-off` always hides matching triggers.
Without a trigger type, these commands apply to all world rendering. With a trigger type, they only apply to matching sources, MediaTracker subtypes, Crystal subtypes, or gameplay trigger types.

`/fx hide` and `/uci hide` are established compatibility commands. Either command forces all Trigger Visualizer rendering off and cannot be overridden for that map, equivalent to `/trigger-visualizer force-off`.

An empty target list, `<>`, `*`, `all`, or `everything` acts as a wildcard, so all types are affected.

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
These commands are read from the map comment. To edit it, open Map Options from the bottom toolbar in the editor, then select Edit Map Comment:

![Screwdriver and wrench icon on the bottom toolbar in the editor](meta/image.png)

![Map Options menu showcasing the Edit Map Comment button](meta/image-1.png)

![Map comments menu showcasing some examples of what you can enter into the comment and have the plugin accept](meta/image-2.png)


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
