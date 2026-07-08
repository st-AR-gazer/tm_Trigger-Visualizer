namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            [Setting hidden name="Trigger: Performance budgets enabled"]
            bool S_PerformanceBudgetsEnabled = true;
            [Setting hidden name="Trigger: Performance culling enabled"]
            bool S_PerformanceCullingEnabled = true;
            [Setting hidden name="Trigger: Performance refresh enabled"]
            bool S_PerformanceRefreshEnabled = true;
            [Setting hidden name="Trigger: Merge adjacent trigger volumes"]
            bool S_MergeAdjacentTriggerVolumes = true;
            [Setting hidden name="Trigger: Cull offscreen world tiles"]
            bool S_CullOffscreenWorldTiles = true;
            [Setting hidden name="Trigger: Fill tile minimum size" min=2 max=64]
            float S_FillTileMinSize = 4.0f;
            [Setting hidden name="Trigger: Max visible volumes per frame" min=16 max=4096]
            int S_MaxVisibleVolumesPerFrame = 512;
            [Setting hidden name="Trigger: Max fill tiles per frame" min=128 max=65536]
            int S_MaxFillTilesPerFrame = 4096;
            [Setting hidden name="Trigger: Max outline segments per frame" min=64 max=65536]
            int S_MaxOutlineSegmentsPerFrame = 1536;
            [Setting hidden name="Trigger: Max Crystal outline segments per frame" min=0 max=65536]
            int S_MaxCrystalOutlineSegmentsPerFrame = 768;
            [Setting hidden name="Trigger: Split Crystal outline edges"]
            bool S_SplitCrystalOutlineEdges = false;
            [Setting hidden name="Trigger: Max tile icon patches per frame" min=0 max=65536]
            int S_MaxTileIconPatchesPerFrame = 1600;
            [Setting hidden name="Trigger: Tile icon max subdivisions" min=1 max=12]
            int S_TileIconMaxSubdivisions = 6;
            [Setting hidden name="Trigger: MediaTracker editor refresh interval ms" min=0 max=60000]
            int S_MediaTrackerEditorRefreshIntervalMs = 500;
            [Setting hidden name="Trigger: Offzone editor refresh interval ms" min=0 max=60000]
            int S_OffzoneEditorRefreshIntervalMs = 500;
            const int REFRESH_INTERVAL_DISABLED = 0;
            const int REFRESH_INTERVAL_MIN_ACTIVE_MS = 100;
            const int REFRESH_INTERVAL_MAX_MS = 60000;

            [Setting hidden name="Trigger: Crystal refresh mesh modeler interval ms" min=0 max=60000]
            int S_CrystalMeshModelerRefreshIntervalMs = 500;
            [Setting hidden name="Trigger: Fast driving performance mode"]
            bool S_FastDrivingPerformanceMode = true;
            [Setting hidden name="Trigger: Fast driving speed threshold kmh" min=0 max=1000]
            float S_FastDrivingSpeedThresholdKmh = 60.0f;
            [Setting hidden name="Trigger: Fast driving reverse speed threshold kmh" min=-1000 max=0]
            float S_FastDrivingReverseSpeedThresholdKmh = -20.0f;
            const string LEGACY_SPEED_RENDER_KEEP_TARGETS_RESET_KEY = "playercamera|playercamerasubtypecamdefault|playercamerasubtypecam1|playercamerasubtypecam2|playercamerasubtypecam3|playercamerasubtypecamhelico|playercamerasubtypecamfree|playercamerasubtypecamspectator|reset|";
            const string DEFAULT_SPEED_RENDER_KEEP_TARGETS = "playercamera|playercamerasubtypecamdefault|playercamerasubtypecam1|playercamerasubtypecam2|playercamerasubtypecam3|playercamerasubtypecamhelico|playercamerasubtypecamfree|playercamerasubtypecamspectator|mediatrackerreset|";

            [Setting hidden name="Trigger: Speed render keep target keys"]
            string S_SpeedRenderKeepTargetKeys = DEFAULT_SPEED_RENDER_KEEP_TARGETS;

            bool ArePerformanceBudgetsEnabled() {
                return S_PerformanceBudgetsEnabled;
            }

            bool IsPerformanceCullingEnabled() {
                return S_PerformanceCullingEnabled;
            }

            bool ShouldCullOffscreenWorldTiles() {
                return S_PerformanceCullingEnabled && S_CullOffscreenWorldTiles;
            }

            bool IsPerformanceRefreshEnabled() {
                return S_PerformanceRefreshEnabled;
            }

            void ApplyPerformanceDrawBudgetValues(
                float fillTileMinSize,
                int maxVisibleVolumes,
                int maxFillTiles,
                int maxOutlineSegments,
                int maxCrystalOutlineSegments,
                bool splitCrystalOutlineEdges,
                int maxTileIconPatches,
                int tileIconMaxSubdivisions
            ) {
                S_FillTileMinSize = fillTileMinSize;
                S_MaxVisibleVolumesPerFrame = maxVisibleVolumes;
                S_MaxFillTilesPerFrame = maxFillTiles;
                S_MaxOutlineSegmentsPerFrame = maxOutlineSegments;
                S_MaxCrystalOutlineSegmentsPerFrame = maxCrystalOutlineSegments;
                S_SplitCrystalOutlineEdges = splitCrystalOutlineEdges;
                S_MaxTileIconPatchesPerFrame = maxTileIconPatches;
                S_TileIconMaxSubdivisions = tileIconMaxSubdivisions;
                ClampPerformanceSettings();
            }

            void ApplyLowPerformanceDrawBudgetPreset() {
                ApplyPerformanceDrawBudgetValues(6.0f, 256, 2048, 768, 256, false, 512, 4);
            }

            void ApplyMediumPerformanceDrawBudgetPreset() {
                ApplyPerformanceDrawBudgetValues(4.0f, 512, 4096, 1536, 768, false, 1600, 6);
            }

            void ApplyHighPerformanceDrawBudgetPreset() {
                ApplyPerformanceDrawBudgetValues(3.0f, 2048, 8192, 8192, 4096, true, 6400, 8);
            }

            int NormalizeRefreshIntervalMs(int value) {
                if (value <= 0) return REFRESH_INTERVAL_DISABLED;
                return Math::Clamp(value, REFRESH_INTERVAL_MIN_ACTIVE_MS, REFRESH_INTERVAL_MAX_MS);
            }

            int GetOffzoneRefreshIntervalMsForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                if (!S_PerformanceRefreshEnabled) return REFRESH_INTERVAL_DISABLED;
                if (ctx is null || !ctx.IsMapEditor) return REFRESH_INTERVAL_DISABLED;
                return NormalizeRefreshIntervalMs(S_OffzoneEditorRefreshIntervalMs);
            }

            int GetMediaTrackerRefreshIntervalMsForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                if (!S_PerformanceRefreshEnabled) return REFRESH_INTERVAL_DISABLED;
                if (ctx is null || !ctx.IsEditorMediaTracker) return REFRESH_INTERVAL_DISABLED;
                return NormalizeRefreshIntervalMs(S_MediaTrackerEditorRefreshIntervalMs);
            }

            int GetCrystalRefreshIntervalMsForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                if (!S_PerformanceRefreshEnabled) return REFRESH_INTERVAL_DISABLED;
                if (ctx is null || !ctx.IsMeshModeler) return REFRESH_INTERVAL_DISABLED;
                return NormalizeRefreshIntervalMs(S_CrystalMeshModelerRefreshIntervalMs);
            }

            float GetFastDrivingForwardSpeedThresholdKmh() {
                return Math::Abs(Math::Clamp(S_FastDrivingSpeedThresholdKmh, -1000.0f, 1000.0f));
            }

            float GetFastDrivingReverseSpeedThresholdKmh() {
                return -Math::Abs(Math::Clamp(S_FastDrivingReverseSpeedThresholdKmh, -1000.0f, 1000.0f));
            }

            void MigrateSpeedRenderKeepTargetsIfNeeded() {
                if (S_SpeedRenderKeepTargetKeys == LEGACY_SPEED_RENDER_KEEP_TARGETS_RESET_KEY) {
                    S_SpeedRenderKeepTargetKeys = DEFAULT_SPEED_RENDER_KEEP_TARGETS;
                }
            }

            bool IsSpeedRenderKeepTargetEnabled(const string &in rawKey) {
                MigrateSpeedRenderKeepTargetsIfNeeded();
                return TriggerVisualizer::Trigger::TriggerTargetListContains(
                    S_SpeedRenderKeepTargetKeys,
                    rawKey
                );
            }

            void SetSpeedRenderKeepTargetEnabled(const string &in rawKey, bool enabled) {
                MigrateSpeedRenderKeepTargetsIfNeeded();
                S_SpeedRenderKeepTargetKeys = SetTargetListKeyEnabled(
                    S_SpeedRenderKeepTargetKeys,
                    rawKey,
                    enabled
                );
            }

            void SetSpeedRenderKeepTargetKeysEnabled(const array<string> &in keys, bool enabled) {
                for (uint i = 0; i < keys.Length; i++) {
                    SetSpeedRenderKeepTargetEnabled(keys[i], enabled);
                }
            }

            void FlipSpeedRenderKeepTargetKeys(const array<string> &in keys) {
                for (uint i = 0; i < keys.Length; i++) {
                    SetSpeedRenderKeepTargetEnabled(keys[i], !IsSpeedRenderKeepTargetEnabled(keys[i]));
                }
            }

            bool ShouldSpeedRenderKeepVolume(const TriggerVolume@ volume) {
                if (volume is null) return false;
                MigrateSpeedRenderKeepTargetsIfNeeded();
                if (S_SpeedRenderKeepTargetKeys.Length == 0) return false;

                auto parts = S_SpeedRenderKeepTargetKeys.Split("|");
                for (uint i = 0; i < parts.Length; i++) {
                    string key = TriggerVisualizer::Trigger::NormalizeTriggerTargetKey(parts[i]);
                    if (key.Length == 0) continue;
                    if (TriggerVisualizer::Trigger::TriggerVolumeMatchesTargetKey(volume, key)) return true;
                }
                return false;
            }

            bool ShouldSpeedRenderSkipHideAllRuntimeSources(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                MigrateSpeedRenderKeepTargetsIfNeeded();
                return ctx !is null && S_SpeedRenderKeepTargetKeys.Length == 0;
            }
        }
    }
}
