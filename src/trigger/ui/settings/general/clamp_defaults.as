namespace TriggerVisualizer {
    namespace Trigger {
        namespace Ui {
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
                S_MediaTrackerEditorRefreshIntervalMs = NormalizeRefreshIntervalMs(S_MediaTrackerEditorRefreshIntervalMs);
                S_OffzoneEditorRefreshIntervalMs = NormalizeRefreshIntervalMs(S_OffzoneEditorRefreshIntervalMs);
                S_CrystalMeshModelerRefreshIntervalMs = NormalizeRefreshIntervalMs(S_CrystalMeshModelerRefreshIntervalMs);
                S_FastDrivingSpeedThresholdKmh = GetFastDrivingForwardSpeedThresholdKmh();
                S_FastDrivingReverseSpeedThresholdKmh = GetFastDrivingReverseSpeedThresholdKmh();
                MigrateSpeedRenderKeepTargetsIfNeeded();
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
                S_TurboRouletteYellowDurationMs = Math::Clamp(S_TurboRouletteYellowDurationMs, 50, 5000);
                S_TurboRouletteCyanDurationMs = Math::Clamp(S_TurboRouletteCyanDurationMs, 50, 5000);
                S_TurboRoulettePurpleDurationMs = Math::Clamp(S_TurboRoulettePurpleDurationMs, 50, 5000);
                S_TurboRoulettePhaseOffsetMs = Math::Clamp(S_TurboRoulettePhaseOffsetMs, -10000, 10000);
                S_SkullTileIconScale = Math::Clamp(S_SkullTileIconScale, 0.05f, 1.0f);
                S_SkullTileIconAlpha = Math::Clamp(S_SkullTileIconAlpha, 0.0f, 1.0f);
            }

            void ClampLabelSettings() {
                S_LabelFontSize = Math::Clamp(S_LabelFontSize, 8.0f, 48.0f);
                S_LabelAlpha = Math::Clamp(S_LabelAlpha, 0.0f, 1.0f);
            }

            void ResetGeneralTriggerSettingsToDefaults() {
                S_RenderWorld = true;
            }

            void ResetLabelContentSettingsToDefaults() {
                S_ShowLabels = true;
                S_LabelShowIndex = false;
                S_LabelShowRawRange = false;
                S_LabelShowWorldSize = false;
                S_LabelShowIslandIndex = false;
                S_LabelShowJoinedCount = false;
                S_LabelShowSourcePrefix = false;
                S_LabelUseDetectedTriggerName = true;
                S_LabelShowDetectedTriggerName = false;
                S_LabelTargetKeys = DEFAULT_LABEL_TARGET_KEYS;
                S_LabelTargetOverrideTexts = DEFAULT_LABEL_TARGET_OVERRIDE_TEXTS;
                g_LabelTargetOverrideInputs.DeleteAll();
            }

            void ResetLabelAppearanceSettingsToDefaults() {
                S_LabelFontSize = 16.0f;
                S_LabelAlpha = 0.95f;
                ClampLabelSettings();
            }

            void ResetLabelSettingsToDefaults() {
                ResetLabelContentSettingsToDefaults();
                ResetLabelAppearanceSettingsToDefaults();
            }

            void ResetWorldDisplaySettingsToDefaults() {
                S_ShowFill = true;
                S_ShowOutline = true;
            }

            void ResetWorldDistanceSettingsToDefaults() {
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
                S_UnlimitedRenderDistanceMediaTracker = true;
                S_UseMapSuggestedDrawDistanceMediaTracker = true;
                S_RenderProximityMode = PROXIMITY_MODE_CAMERA_AND_VEHICLE;
                S_RenderProximityModeEditor = PROXIMITY_MODE_CAMERA_AND_ORBITAL;
                S_RenderProximityModeMediaTracker = PROXIMITY_MODE_CAMERA_AND_ORBITAL;
                ClampWorldRenderingSettings();
                ClampProximitySettings();
            }

            void ResetWorldLineSplittingSettingsToDefaults() {
                S_AdaptiveLineSplitting = true;
                S_LineSplitTargetSegmentLength = 4.0f;
                S_LineSplitStartDistanceFactor = 0.33f;
                S_LineSplitFullDistanceFactor = 0.05f;
                S_LineSplitMinStartDistance = 16.0f;
                S_LineSplitMaxStartDistance = 50000.0f;
                S_LineSplitMinFullDistance = 2.0f;
                S_LineSplitMaxFullDistance = 96.0f;
                S_LineSplitMaxSegmentsPerEdge = 512;
                ClampLineSplittingSettings();
            }

            void ResetWorldColorSettingsToDefaults() {
                S_ColorMode = COLOR_MODE_MEDIATRACKER_TRACK_COLORS;
                S_ColorModeMigrated = true;
                S_ColorSource = COLOR_SOURCE_MEDIATRACKER_TRACK_COLORS;
                S_EnableDistanceFadeColor = false;
                S_EnableLineSplitDensityColor = false;
                S_BaseTriggerColor = vec4(0.85f, 0.71f, 1.0f, 1.0f);
                S_DistanceFadeColor = vec4(1.0f, 0.90f, 0.20f, 1.0f);
                S_DenseLineSplitColor = vec4(0.10f, 0.85f, 1.0f, 1.0f);
                S_MediaTrackerTrackOutlineHueShift = 0.06f;
                S_AnimateTurboRouletteColor = true;
                S_TurboRouletteYellowDurationMs = DEFAULT_TURBO_ROULETTE_YELLOW_DURATION_MS;
                S_TurboRouletteCyanDurationMs = DEFAULT_TURBO_ROULETTE_CYAN_DURATION_MS;
                S_TurboRoulettePurpleDurationMs = DEFAULT_TURBO_ROULETTE_PURPLE_DURATION_MS;
                S_TurboRoulettePhaseOffsetMs = 0;
                S_OutlineAlpha = 0.20f;
                S_FillAlpha = 0.03f;
                S_OutlineWidth = 2.0f;
                S_RandomOutlineSegmentColors = false;
                S_RandomFillTileColors = false;
                ClampWorldRenderingSettings();
                ClampColorSettings();
            }

            void ResetWorldTileIconSettingsToDefaults() {
                S_ShowSkullTileIcons = false;
                S_SkullTileIconScale = 0.45f;
                S_SkullTileIconAlpha = 0.85f;
                S_RepeatTileIconsOnSplitFillTiles = false;
                ResetTileIconSettingsToDefaults();
                g_TileIconImportStatus = "";
                TriggerVisualizer::Trigger::Render::Assets::InvalidateSkullTileIconTexture();
                ClampColorSettings();
            }

            void ResetWorldMapHintSettingsToDefaults() {
                S_RespectMapSuggestOff = true;
            }

            void ResetPerformanceCullingSettingsToDefaults() {
                S_MergeAdjacentTriggerVolumes = true;
                S_PerformanceCullingEnabled = true;
                S_CullOffscreenWorldTiles = true;
            }

            void ResetPerformanceRefreshSettingsToDefaults() {
                S_PerformanceRefreshEnabled = true;
                S_MediaTrackerEditorRefreshIntervalMs = 500;
                S_OffzoneEditorRefreshIntervalMs = 500;
                S_CrystalMeshModelerRefreshIntervalMs = 500;
                ClampPerformanceSettings();
            }

            void ResetPerformanceSpeedRenderSkipSettingsToDefaults() {
                S_FastDrivingPerformanceMode = true;
                S_FastDrivingSpeedThresholdKmh = 60.0f;
                S_FastDrivingReverseSpeedThresholdKmh = -20.0f;
                S_SpeedRenderKeepTargetKeys = DEFAULT_SPEED_RENDER_KEEP_TARGETS;
                ClampPerformanceSettings();
            }

            void ResetPerformanceSettingsToDefaults() {
                ResetPerformanceCullingSettingsToDefaults();
                ResetPerformanceRefreshSettingsToDefaults();
                ResetPerformanceSpeedRenderSkipSettingsToDefaults();
            }
        }
    }
}
