namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            void ClampWorldRenderingSettings() {
                S_RenderDistanceXZ = Math::Clamp(S_RenderDistanceXZ, 0.0f, WORLD_RENDER_SETTING_MAX);
                S_RenderDistanceY = Math::Clamp(S_RenderDistanceY, 0.0f, WORLD_RENDER_SETTING_MAX);
                S_RenderFadeBandXZ = Math::Clamp(S_RenderFadeBandXZ, 0.0f, WORLD_RENDER_SETTING_MAX);
                S_RenderFadeBandY = Math::Clamp(S_RenderFadeBandY, 0.0f, WORLD_RENDER_SETTING_MAX);
                S_RenderDistanceXZEditor = Math::Clamp(S_RenderDistanceXZEditor, 0.0f, WORLD_RENDER_SETTING_MAX);
                S_RenderDistanceYEditor = Math::Clamp(S_RenderDistanceYEditor, 0.0f, WORLD_RENDER_SETTING_MAX);
                S_RenderFadeBandXZEditor = Math::Clamp(S_RenderFadeBandXZEditor, 0.0f, WORLD_RENDER_SETTING_MAX);
                S_RenderFadeBandYEditor = Math::Clamp(S_RenderFadeBandYEditor, 0.0f, WORLD_RENDER_SETTING_MAX);
                S_RenderDistanceXZMediaTracker = Math::Clamp(
                    S_RenderDistanceXZMediaTracker,
                    0.0f,
                    WORLD_RENDER_SETTING_MAX
                );
                S_RenderDistanceYMediaTracker = Math::Clamp(
                    S_RenderDistanceYMediaTracker,
                    0.0f,
                    WORLD_RENDER_SETTING_MAX
                );
                S_RenderFadeBandXZMediaTracker = Math::Clamp(
                    S_RenderFadeBandXZMediaTracker,
                    0.0f,
                    WORLD_RENDER_SETTING_MAX
                );
                S_RenderFadeBandYMediaTracker = Math::Clamp(
                    S_RenderFadeBandYMediaTracker,
                    0.0f,
                    WORLD_RENDER_SETTING_MAX
                );
                S_OutlineAlpha = Math::Clamp(S_OutlineAlpha, 0.0f, 1.0f);
                S_FillAlpha = Math::Clamp(S_FillAlpha, 0.0f, 1.0f);
                S_OutlineWidth = Math::Clamp(S_OutlineWidth, 0.5f, 16.0f);
            }

            void ClampLineSplittingSettings() {
                S_LineSplitTargetSegmentLength = Math::Max(
                    S_LineSplitTargetSegmentLength,
                    LINE_SPLIT_MINIMUM_SAFE_LENGTH
                );
                S_LineSplitStartDistanceFactor = Math::Max(S_LineSplitStartDistanceFactor, 0.0f);
                S_LineSplitFullDistanceFactor = Math::Max(S_LineSplitFullDistanceFactor, 0.0f);
                S_LineSplitMinStartDistance = Math::Max(S_LineSplitMinStartDistance, 0.0f);
                S_LineSplitMaxStartDistance = Math::Max(S_LineSplitMaxStartDistance, 0.0f);
                S_LineSplitMinFullDistance = Math::Max(S_LineSplitMinFullDistance, 0.0f);
                S_LineSplitMaxFullDistance = Math::Max(S_LineSplitMaxFullDistance, 0.0f);
                S_LineSplitMaxSegmentsPerEdge = Math::Max(S_LineSplitMaxSegmentsPerEdge, 1);
            }

            void ClampPerformanceSettings() {
                S_ScreenOcclusionCellSize = Math::Clamp(S_ScreenOcclusionCellSize, 8, 256);
                S_FillTileMinSize = Math::Clamp(S_FillTileMinSize, 2.0f, 64.0f);
                S_MaxFillTilesPerFrame = Math::Clamp(S_MaxFillTilesPerFrame, 128, 65536);
                S_MaxOutlineSegmentsPerFrame = Math::Clamp(S_MaxOutlineSegmentsPerFrame, 64, 65536);
                S_MaxTileIconPatchesPerFrame = Math::Clamp(S_MaxTileIconPatchesPerFrame, 0, 65536);
                S_TileIconMaxSubdivisions = Math::Clamp(S_TileIconMaxSubdivisions, 1, 12);
                S_MediaTrackerEditorRefreshIntervalMs = Math::Clamp(S_MediaTrackerEditorRefreshIntervalMs, 100, 5000);
                S_OffzoneEditorRefreshIntervalMs = Math::Clamp(S_OffzoneEditorRefreshIntervalMs, 100, 5000);
                S_FastDrivingSpeedThresholdKmh = Math::Clamp(S_FastDrivingSpeedThresholdKmh, 0.0f, 1000.0f);
                S_FastDrivingMaxVisibleVolumes = Math::Clamp(S_FastDrivingMaxVisibleVolumes, 1, 512);
                S_FastDrivingMaxFillTilesPerFrame = Math::Clamp(S_FastDrivingMaxFillTilesPerFrame, 0, 8192);
                S_FastDrivingMaxOutlineSegmentsPerFrame = Math::Clamp(S_FastDrivingMaxOutlineSegmentsPerFrame, 0, 8192);
            }

            vec4 ClampColor(const vec4 &in color) {
                return vec4(
                    Math::Clamp(color.x, 0.0f, 1.0f),
                    Math::Clamp(color.y, 0.0f, 1.0f),
                    Math::Clamp(color.z, 0.0f, 1.0f),
                    Math::Clamp(color.w, 0.0f, 1.0f)
                );
            }

            void ClampColorSettings() {
                S_ColorMode = Math::Clamp(S_ColorMode, COLOR_MODE_STATIC, COLOR_MODE_MEDIATRACKER_TRACK_COLORS);
                if (!S_ColorModeMigrated) {
                    if (S_ColorMode == COLOR_MODE_MEDIATRACKER_TRACK_COLORS) {
                        S_ColorSource = COLOR_SOURCE_MEDIATRACKER_TRACK_COLORS;
                    } else if (S_ColorMode == COLOR_MODE_DISTANCE_FADE) {
                        S_ColorSource = COLOR_SOURCE_UNIFORM;
                        S_EnableDistanceFadeColor = true;
                    } else if (S_ColorMode == COLOR_MODE_LINE_SPLIT_DENSITY) {
                        S_ColorSource = COLOR_SOURCE_UNIFORM;
                        S_EnableLineSplitDensityColor = true;
                    } else {
                        S_ColorSource = COLOR_SOURCE_UNIFORM;
                    }
                    S_ColorModeMigrated = true;
                }
                S_ColorSource = Math::Clamp(
                    S_ColorSource,
                    COLOR_SOURCE_UNIFORM,
                    COLOR_SOURCE_MEDIATRACKER_TRACK_COLORS
                );
                S_BaseTriggerColor = ClampColor(S_BaseTriggerColor);
                S_DistanceFadeColor = ClampColor(S_DistanceFadeColor);
                S_DenseLineSplitColor = ClampColor(S_DenseLineSplitColor);
                S_MediaTrackerTrackOutlineHueShift = Math::Clamp(S_MediaTrackerTrackOutlineHueShift, -1.0f, 1.0f);
                S_SkullTileIconScale = Math::Clamp(S_SkullTileIconScale, 0.05f, 1.0f);
                S_SkullTileIconAlpha = Math::Clamp(S_SkullTileIconAlpha, 0.0f, 1.0f);
            }

            void ClampLabelSettings() {
                S_LabelFontSize = Math::Clamp(S_LabelFontSize, 8.0f, 48.0f);
                S_LabelAlpha = Math::Clamp(S_LabelAlpha, 0.0f, 1.0f);
                S_LabelBackgroundAlpha = Math::Clamp(S_LabelBackgroundAlpha, 0.0f, 1.0f);
            }

            void ResetSettingsToDefaults() {
                S_RenderWorld = true;
                S_ShowLabels = true;
                S_LabelShowIndex = false;
                S_LabelShowRawRange = false;
                S_LabelShowWorldSize = false;
                S_LabelShowIslandIndex = false;
                S_LabelShowSourcePrefix = false;
                S_LabelUseDetectedTriggerName = true;
                S_LabelShowDetectedTriggerName = false;
                S_LabelFontSize = 16.0f;
                S_LabelAlpha = 0.95f;
                S_LabelBackgroundAlpha = 0.20f;
                S_ShowFill = true;
                S_ShowOutline = true;
                S_RenderDistanceXZ = 224.0f;
                S_RenderDistanceY = 56.0f;
                S_RenderFadeBandXZ = 32.0f;
                S_RenderFadeBandY = 8.0f;
                S_UnlimitedRenderDistance = false;
                S_UseMapSuggestedDrawDistance = true;
                S_RenderDistanceXZEditor = 320.0f;
                S_RenderDistanceYEditor = 80.0f;
                S_RenderFadeBandXZEditor = 32.0f;
                S_RenderFadeBandYEditor = 8.0f;
                S_UnlimitedRenderDistanceEditor = false;
                S_UseMapSuggestedDrawDistanceEditor = true;
                S_RenderDistanceXZMediaTracker = 224.0f;
                S_RenderDistanceYMediaTracker = 56.0f;
                S_RenderFadeBandXZMediaTracker = 32.0f;
                S_RenderFadeBandYMediaTracker = 8.0f;
                S_UnlimitedRenderDistanceMediaTracker = false;
                S_UseMapSuggestedDrawDistanceMediaTracker = true;
                S_RespectMapSuggestOff = true;
                S_OutlineAlpha = 0.20f;
                S_FillAlpha = 0.03f;
                S_OutlineWidth = 2.0f;
                S_AdaptiveLineSplitting = true;
                S_LineSplitTargetSegmentLength = 4.0f;
                S_LineSplitStartDistanceFactor = 0.33f;
                S_LineSplitFullDistanceFactor = 0.05f;
                S_LineSplitMinStartDistance = 16.0f;
                S_LineSplitMaxStartDistance = 50000.0f;
                S_LineSplitMinFullDistance = 2.0f;
                S_LineSplitMaxFullDistance = 96.0f;
                S_LineSplitMaxSegmentsPerEdge = 512;
                S_MaxOutlineSegmentsPerFrame = 1536;
                S_CullOffscreenWorldTiles = true;
                S_CullScreenOccludedWorldTiles = false;
                S_ScreenOcclusionCellSize = 32;
                S_FillTileMinSize = 4.0f;
                S_MaxFillTilesPerFrame = 4096;
                S_MaxTileIconPatchesPerFrame = 1600;
                S_TileIconMaxSubdivisions = 6;
                S_MediaTrackerEditorRefreshIntervalMs = 500;
                S_OffzoneEditorRefreshIntervalMs = 500;
                S_FastDrivingPerformanceMode = true;
                S_FastDrivingSpeedThresholdKmh = 60.0f;
                S_FastDrivingMaxVisibleVolumes = 24;
                S_FastDrivingMaxFillTilesPerFrame = 128;
                S_FastDrivingMaxOutlineSegmentsPerFrame = 256;
                S_FastDrivingDisableFill = true;
                S_FastDrivingDisableLabels = true;
                S_FastDrivingDisableTileIcons = true;
                S_FastDrivingSimplifyGroupedTriggers = true;
                S_ColorMode = COLOR_MODE_MEDIATRACKER_TRACK_COLORS;
                S_ColorModeMigrated = true;
                S_ColorSource = COLOR_SOURCE_MEDIATRACKER_TRACK_COLORS;
                S_EnableDistanceFadeColor = false;
                S_EnableLineSplitDensityColor = false;
                S_RenderProximityMode = PROXIMITY_MODE_CAMERA_AND_VEHICLE;
                S_RenderProximityModeEditor = PROXIMITY_MODE_CAMERA_AND_ORBITAL;
                S_RenderProximityModeMediaTracker = PROXIMITY_MODE_CAMERA_AND_ORBITAL;
                S_RenderProximityModeReplayEditor = PROXIMITY_MODE_CAMERA_AND_ORBITAL;
                S_BaseTriggerColor = vec4(0.85f, 0.71f, 1.0f, 1.0f);
                S_DistanceFadeColor = vec4(1.0f, 0.90f, 0.20f, 1.0f);
                S_DenseLineSplitColor = vec4(0.10f, 0.85f, 1.0f, 1.0f);
                S_MediaTrackerTrackOutlineHueShift = 0.06f;
                S_RandomOutlineSegmentColors = false;
                S_RandomFillTileColors = false;
                S_ShowSkullTileIcons = false;
                S_SkullTileIconScale = 0.45f;
                S_SkullTileIconAlpha = 0.85f;
                ResetTileIconSettingsToDefaults();
                S_MergeAdjacentTriggerVolumes = true;
                S_ShowOffzoneSource = true;
                S_ShowOffzoneInPlayableMap = true;
                S_ShowOffzoneInEditor = true;
                S_ShowOffzoneInEditorTestMode = true;
                S_ShowOffzoneInEditorMediaTracker = true;
                S_ShowOffzoneInReplayEditor = true;
                S_ShowMediaTrackerSource = true;
                S_ShowMediaTrackerInPlayableMap = true;
                S_ShowMediaTrackerInEditor = true;
                S_ShowMediaTrackerInEditorTestMode = true;
                S_ShowMediaTrackerInEditorMediaTracker = true;
                S_ShowMediaTrackerInReplayEditor = true;
                S_ShowMediaTrackerSubtypeCamera = true;
                S_ShowMediaTrackerSubtypeCamCustom = true;
                S_ShowMediaTrackerSubtypeCamOrbital = true;
                S_ShowMediaTrackerSubtypeCamPath = true;
                S_ShowMediaTrackerSubtypeCamPlayer = true;
                S_ShowMediaTrackerSubtypeCamDefault = true;
                S_ShowMediaTrackerSubtypeCam1 = true;
                S_ShowMediaTrackerSubtypeCam2 = true;
                S_ShowMediaTrackerSubtypeCam3 = true;
                S_ShowMediaTrackerSubtypeCamHelico = true;
                S_ShowMediaTrackerSubtypeCamFree = true;
                S_ShowMediaTrackerSubtypeCamSpectator = true;
                S_ShowMediaTrackerSubtype2DTriangles = true;
                S_ShowMediaTrackerSubtype3DTriangles = true;
                S_ShowMediaTrackerSubtypeCarTrail = true;
                S_ShowMediaTrackerSubtypeColorsFx = true;
                S_ShowMediaTrackerSubtypeColorGrading = true;
                S_ShowMediaTrackerSubtypeDepthOfField = true;
                S_ShowMediaTrackerSubtypeDirtyLens = true;
                S_ShowMediaTrackerSubtypeEditingCut = true;
                S_ShowMediaTrackerSubtypeFadingTransition = true;
                S_ShowMediaTrackerSubtypeFog = true;
                S_ShowMediaTrackerSubtypeGhost = true;
                S_ShowMediaTrackerSubtypeHdrBloom = true;
                S_ShowMediaTrackerSubtypeImage = true;
                S_ShowMediaTrackerSubtypeInertialTrackingCamFx = true;
                S_ShowMediaTrackerSubtypeManiaLinkUi = true;
                S_ShowMediaTrackerSubtypeManiaLinkUrl = true;
                S_ShowMediaTrackerSubtypeMusicVolume = true;
                S_ShowMediaTrackerSubtypeOpponentVisibility = true;
                S_ShowMediaTrackerSubtypeShakeCamFx = true;
                S_ShowMediaTrackerSubtypeStereo3D = true;
                S_ShowMediaTrackerSubtypeSoundFx = true;
                S_ShowMediaTrackerSubtypeSpectators = true;
                S_ShowMediaTrackerSubtypeText = true;
                S_ShowMediaTrackerSubtypeTime = true;
                S_ShowMediaTrackerSubtypeTimeSpeed = true;
                S_ShowMediaTrackerSubtypeToneMapping = true;
                S_ShowMediaTrackerSubtypeVehicleLights = true;
                S_ShowMediaTrackerSubtypeReset = true;
                S_ShowMediaTrackerSubtypeUnknown = true;
                G_TileIconImportStatus = "";
                TriggerVisualizer::Trigger::Render::Assets::InvalidateSkullTileIconTexture();
                ClampWorldRenderingSettings();
                ClampLineSplittingSettings();
                ClampPerformanceSettings();
                ClampColorSettings();
                ClampProximitySettings();
                ClampLabelSettings();
            }
        }
    }
}
