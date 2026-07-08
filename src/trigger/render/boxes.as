namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            const float MIN_VISIBLE_FADE = 0.001f;
            const float FILL_TILE_SPLIT_DISTANCE_FACTOR = 0.75f;
            const uint FILL_TILE_MAX_DEPTH = 8;
            const uint FILL_TILE_MAX_TILES_PER_FACE = 512;
            const uint FILL_TILE_TRAVERSAL_BUDGET_HARD_MAX = 8192;
            const float SCREEN_QUAD_VISIBILITY_MARGIN = 128.0f;
            const float SKULL_TILE_ICON_MIN_SCREEN_SIZE = 2.0f;
            const float SKULL_TILE_ICON_TARGET_PATCH_SCREEN_SIZE = 40.0f;
            const float SKULL_TILE_ICON_TARGET_PATCH_PERSPECTIVE_ERROR = 2.0f;
            const uint SKULL_TILE_ICON_HARD_MAX_SUBDIVISIONS = 12;
            const uint LINE_FRUSTUM_MAX_DEPTH = 12;
            const uint WORLD_LINE_SEGMENT_BUDGET_HARD_MAX = 32768;
            const int WORLD_PRIMITIVE_OUTSIDE = 0;
            const int WORLD_PRIMITIVE_MIXED = 1;
            const int WORLD_PRIMITIVE_FRONT = 2;
            const int FRUSTUM_NEAR = 0;
            const int FRUSTUM_FAR = 1;
            const int FRUSTUM_LEFT = 2;
            const int FRUSTUM_RIGHT = 3;
            const int FRUSTUM_BOTTOM = 4;
            const int FRUSTUM_TOP = 5;
            const float FRUSTUM_EPSILON = 0.0001f;

            class WorldFrustumState {
                bool Valid = false;
                mat4 ViewMatrix = mat4::Identity();
                float ForwardSign = 1.0f;
                float NearZ = 0.1f;
                float FarZ = 50000.0f;
                float TanHalfY = 1.0f;
                float Aspect = 1.0f;
            }

            uint G_TileIconPatchBudgetRemaining = 1600;
            uint G_FillTileTraversalBudgetRemaining = 4096;
            uint G_WorldLineSegmentBudgetRemaining = 1536;
            uint G_CrystalWorldLineSegmentBudgetRemaining = 768;
            bool G_SpeedRenderSkipActive = false;
            WorldFrustumState G_WorldFrustumState;

            bool IsSpeedRenderSkipRuntimeEligible(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                return TriggerVisualizer::Trigger::UI::S_FastDrivingPerformanceMode
                    && ctx !is null
                    && (ctx.IsPlayableMap || ctx.IsEditorTestMode);
            }

            bool CanUseSpeedRenderSkip(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                return IsSpeedRenderSkipRuntimeEligible(ctx)
                    && proximityState !is null
                    && proximityState.HasVehicleSpeed;
            }

            bool SpeedIsPastRenderSkipThreshold(float speedKmh) {
                return speedKmh >= TriggerVisualizer::Trigger::UI::GetFastDrivingForwardSpeedThresholdKmh()
                    || speedKmh <= TriggerVisualizer::Trigger::UI::GetFastDrivingReverseSpeedThresholdKmh();
            }

            bool IsSpeedRenderSkipActiveForSpeed(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                if (!CanUseSpeedRenderSkip(ctx, proximityState)) return false;
                return SpeedIsPastRenderSkipThreshold(proximityState.VehicleSpeedKmh);
            }

            bool IsSpeedRenderSkipActive() {
                return G_SpeedRenderSkipActive;
            }

            bool UpdateSpeedRenderSkipActiveForSpeed(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                G_SpeedRenderSkipActive = IsSpeedRenderSkipActiveForSpeed(ctx, proximityState);
                return G_SpeedRenderSkipActive;
            }

            bool ShouldSkipWorldRenderForSpeed(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                return G_SpeedRenderSkipActive
                    && IsSpeedRenderSkipRuntimeEligible(ctx)
                    && TriggerVisualizer::Trigger::UI::ShouldSpeedRenderSkipHideAllRuntimeSources(ctx);
            }

            bool ShouldSkipTriggerVolumeForSpeed(
                const TriggerVolume@ volume,
                bool speedRenderSkipActive
            ) {
                return speedRenderSkipActive
                    && volume !is null
                    && !TriggerVisualizer::Trigger::UI::ShouldSpeedRenderKeepVolume(volume);
            }

            int GetEffectiveMaxFillTilesPerFrame() {
                if (!TriggerVisualizer::Trigger::UI::ArePerformanceBudgetsEnabled()) return 65536;
                return Math::Max(TriggerVisualizer::Trigger::UI::S_MaxFillTilesPerFrame, 1);
            }

            int GetEffectiveMaxOutlineSegmentsPerFrame() {
                if (!TriggerVisualizer::Trigger::UI::ArePerformanceBudgetsEnabled()) return int(WORLD_LINE_SEGMENT_BUDGET_HARD_MAX);
                return Math::Max(TriggerVisualizer::Trigger::UI::S_MaxOutlineSegmentsPerFrame, 1);
            }

            int GetEffectiveMaxCrystalOutlineSegmentsPerFrame() {
                if (!TriggerVisualizer::Trigger::UI::ArePerformanceBudgetsEnabled()) return int(WORLD_LINE_SEGMENT_BUDGET_HARD_MAX);
                return Math::Clamp(
                    TriggerVisualizer::Trigger::UI::S_MaxCrystalOutlineSegmentsPerFrame,
                    0,
                    int(WORLD_LINE_SEGMENT_BUDGET_HARD_MAX)
                );
            }

            int GetEffectiveMaxTileIconPatchesPerFrame() {
                if (!TriggerVisualizer::Trigger::UI::ArePerformanceBudgetsEnabled()) return 65536;
                return Math::Max(TriggerVisualizer::Trigger::UI::S_MaxTileIconPatchesPerFrame, 0);
            }

            bool ShouldRenderWorldFillNow() {
                return TriggerVisualizer::Trigger::UI::S_ShowFill;
            }

            bool ShouldRenderWorldLabelsNow() {
                return TriggerVisualizer::Trigger::UI::S_ShowLabels;
            }

            bool ShouldRenderWorldTileIconsNow() {
                return TriggerVisualizer::Trigger::UI::S_ShowSkullTileIcons;
            }

            bool ShouldRepeatTileIconsOnSplitFillTilesNow() {
                return ShouldRenderWorldTileIconsNow()
                    && TriggerVisualizer::Trigger::UI::S_RepeatTileIconsOnSplitFillTiles;
            }

            bool ShouldCollectTileIconsSeparatelyNow() {
                return ShouldRenderWorldTileIconsNow()
                    && !TriggerVisualizer::Trigger::UI::S_RepeatTileIconsOnSplitFillTiles;
            }

            bool ShouldSimplifyGroupedTriggersNow() {
                return false;
            }

            void ResetWorldRenderPerformanceBudgets() {
                int maxFillTiles = GetEffectiveMaxFillTilesPerFrame();
                int maxOutlineSegments = GetEffectiveMaxOutlineSegmentsPerFrame();
                int maxCrystalOutlineSegments = GetEffectiveMaxCrystalOutlineSegmentsPerFrame();
                G_TileIconPatchBudgetRemaining = uint(GetEffectiveMaxTileIconPatchesPerFrame());
                G_FillTileTraversalBudgetRemaining = maxFillTiles <= 0 ?
                0 : uint(Math::Clamp(maxFillTiles * 4, 256, int(FILL_TILE_TRAVERSAL_BUDGET_HARD_MAX)));
                G_WorldLineSegmentBudgetRemaining = maxOutlineSegments <= 0 ?
                0 : uint(Math::Clamp(maxOutlineSegments, 32, int(WORLD_LINE_SEGMENT_BUDGET_HARD_MAX)));
                G_CrystalWorldLineSegmentBudgetRemaining = uint(Math::Clamp(maxCrystalOutlineSegments, 0, int(WORLD_LINE_SEGMENT_BUDGET_HARD_MAX)));
                UpdateWorldFrustumState();
            }

            bool ConsumeWorldFillTileTraversalBudget() {
                if (!TriggerVisualizer::Trigger::UI::ArePerformanceBudgetsEnabled()) return true;
                if (G_FillTileTraversalBudgetRemaining == 0) return false;
                G_FillTileTraversalBudgetRemaining--;
                return true;
            }

            bool ConsumeWorldLineSegmentBudget() {
                if (!TriggerVisualizer::Trigger::UI::ArePerformanceBudgetsEnabled()) return true;
                if (G_WorldLineSegmentBudgetRemaining == 0) return false;
                G_WorldLineSegmentBudgetRemaining--;
                return true;
            }

            bool UsesCrystalOutlineBudget(const TriggerVolume@ box) {
                return box !is null && box.Source == TRIGGER_SOURCE_CRYSTAL;
            }

            bool HasWorldLineSegmentBudgetForVolume(const TriggerVolume@ box) {
                if (!TriggerVisualizer::Trigger::UI::ArePerformanceBudgetsEnabled()) return true;
                if (G_WorldLineSegmentBudgetRemaining == 0) return false;
                return !UsesCrystalOutlineBudget(box) || G_CrystalWorldLineSegmentBudgetRemaining > 0;
            }

            bool ConsumeWorldLineSegmentBudgetForVolume(const TriggerVolume@ box) {
                if (!TriggerVisualizer::Trigger::UI::ArePerformanceBudgetsEnabled()) return true;
                if (!HasWorldLineSegmentBudgetForVolume(box)) return false;

                G_WorldLineSegmentBudgetRemaining--;
                if (UsesCrystalOutlineBudget(box)) {
                    G_CrystalWorldLineSegmentBudgetRemaining--;
                }
                return true;
            }

            bool ShouldSplitTriggerVolumeOutlineEdges(const TriggerVolume@ box) {
                if (UsesCrystalOutlineBudget(box)) {
                    return TriggerVisualizer::Trigger::UI::S_SplitCrystalOutlineEdges;
                }
                return true;
            }

            int GetWorldFillTileCoordKey(float value) {
                return TriggerVisualizer::Trigger::GetTriggerGeometryCoordKey(value);
            }

            string GetWorldFillTilePointKey(const vec3 &in point) {
                return TriggerVisualizer::Trigger::GetTriggerGeometryPointKey(point);
            }

            void SortWorldFillTileCornerKeys(array<string> @keys) {
                TriggerVisualizer::Trigger::SortTriggerGeometryCornerKeys(keys);
            }

            string GetWorldFillTileGeometryKey(const vec3 &in origin, const vec3 &in uEdge, const vec3 &in vEdge) {
                return TriggerVisualizer::Trigger::GetTriggerQuadGeometryKey(
                    origin,
                    origin + uEdge,
                    origin + uEdge + vEdge,
                    origin + vEdge
                );
            }

            class WorldFillTileDrawItem {
                vec3 Origin;
                vec3 UEdge;
                vec3 VEdge;
                vec4 Color;
                string GeometryKey;
                string TileIconTextureKey;
                float TileSeed = 0.0f;
                float SortDistanceSq = 0.0f;
                bool Occluded = false;
                bool HasScreenProjection = false;
                bool AllowTileIcon = true;
                vec3 Screen0;
                vec3 Screen1;
                vec3 Screen2;
                vec3 Screen3;

                WorldFillTileDrawItem() { }

                WorldFillTileDrawItem(
                    const vec3 &in origin,
                    const vec3 &in uEdge,
                    const vec3 &in vEdge,
                    const vec4 &in color,
                    float tileSeed,
                    float sortDistanceSq
                ) {
                    Origin = origin;
                    UEdge = uEdge;
                    VEdge = vEdge;
                    Color = color;
                    TileSeed = tileSeed;
                    SortDistanceSq = sortDistanceSq;
                    GeometryKey = GetWorldFillTileGeometryKey(origin, uEdge, vEdge);
                }
            }

            class WorldTileIconDrawItem {
                vec3 Origin;
                vec3 UEdge;
                vec3 VEdge;
                string TextureKey;
                string GeometryKey;
                float SortDistanceSq = 0.0f;
                bool Occluded = false;

                WorldTileIconDrawItem() { }

                WorldTileIconDrawItem(
                    const vec3 &in origin,
                    const vec3 &in uEdge,
                    const vec3 &in vEdge,
                    const string &in textureKey,
                    float sortDistanceSq
                ) {
                    Origin = origin;
                    UEdge = uEdge;
                    VEdge = vEdge;
                    TextureKey = textureKey;
                    SortDistanceSq = sortDistanceSq;
                    GeometryKey = GetWorldFillTileGeometryKey(origin, uEdge, vEdge);
                }
            }

            class WorldOutlineEdgeDrawItem {
                vec3 Start;
                vec3 End;
                vec4 Color;
                uint BoxIndex = 0;
                uint EdgeIndex = 0;
                float SortDistanceSq = 0.0f;
                string GeometryKey;

                WorldOutlineEdgeDrawItem() { }

                WorldOutlineEdgeDrawItem(const vec3 &in start, const vec3 &in end, uint boxIndex, uint edgeIndex) {
                    Start = start;
                    End = end;
                    BoxIndex = boxIndex;
                    EdgeIndex = edgeIndex;
                    GeometryKey = GetWorldLineSegmentGeometryKey(start, end);
                }
            }

            const uint[][] TRIGGER_VOLUME_EDGE_INDICES = {
                {0, 1}, {1, 2}, {2, 3}, {3, 0},
                {4, 5}, {5, 6}, {6, 7}, {7, 4},
                {0, 4}, {1, 5}, {2, 6}, {3, 7}
            };
            const uint[][] TRIGGER_VOLUME_FACE_INDICES = {
                {0, 4, 7, 3},
                {1, 2, 6, 5},
                {0, 1, 5, 4},
                {3, 7, 6, 2},
                {0, 3, 2, 1},
                {4, 5, 6, 7}
            };

            string GetWorldLineSegmentGeometryKey(const vec3 &in start, const vec3 &in end) {
                return TriggerVisualizer::Trigger::GetTriggerLineGeometryKey(start, end);
            }

            int FindStringIndex(const array<string> @keys, const string &in key) {
                return TriggerVisualizer::Trigger::FindTriggerGeometryKeyIndex(keys, key);
            }

            void AddGeometryKeyCount(array<string> @keys, array<uint> @counts, const string &in key) {
                TriggerVisualizer::Trigger::AddTriggerGeometryKeyCount(keys, counts, key);
            }

            uint GetGeometryKeyCount(const array<string> @keys, const array<uint> @counts, const string &in key) {
                return TriggerVisualizer::Trigger::GetTriggerGeometryKeyCount(keys, counts, key);
            }

            bool RenderPriorityModeUsesCamera(int mode) {
                return mode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_ONLY
                    || mode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_AND_VEHICLE
                    || mode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_AND_ORBITAL
                    || mode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_VEHICLE_AND_ORBITAL;
            }

            bool RenderPriorityModeUsesVehicle(int mode) {
                return mode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_VEHICLE_ONLY
                    || mode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_AND_VEHICLE
                    || mode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_VEHICLE_AND_ORBITAL
                    || mode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_VEHICLE_AND_ORBITAL;
            }

            bool RenderPriorityModeUsesOrbital(int mode) {
                return mode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_ORBITAL_ONLY
                    || mode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_AND_ORBITAL
                    || mode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_VEHICLE_AND_ORBITAL
                    || mode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_VEHICLE_AND_ORBITAL;
            }

            float GetDistanceSqToWorldLineSegment(const vec3 &in point, const vec3 &in start, const vec3 &in end) {
                vec3 line = end - start;
                float lineLengthSq = Math::Distance2(start, end);
                if (lineLengthSq <= 0.0001f) return Math::Distance2(point, start);

                float t = Math::Dot(point - start, line) / lineLengthSq;
                t = Math::Clamp(t, 0.0f, 1.0f);
                return Math::Distance2(point, Math::Lerp(start, end, t));
            }

            float GetWorldLineRenderPriorityDistanceSq(
                const vec3 &in start,
                const vec3 &in end,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState,
                int mode
            ) {
                float best = 1e30f;
                bool hasCandidate = false;
                if (RenderPriorityModeUsesCamera(mode)) {
                    best = Math::Min(best, GetDistanceSqToWorldLineSegment(cameraPos, start, end));
                    hasCandidate = true;
                }
                if (RenderPriorityModeUsesVehicle(mode) && proximityState !is null && proximityState.HasVehiclePosition) {
                    best = Math::Min(best, GetDistanceSqToWorldLineSegment(proximityState.VehiclePosition, start, end));
                    hasCandidate = true;
                }
                if (RenderPriorityModeUsesOrbital(mode) && proximityState !is null && proximityState.HasOrbitalPoint) {
                    best = Math::Min(best, GetDistanceSqToWorldLineSegment(proximityState.OrbitalPoint, start, end));
                    hasCandidate = true;
                }

                return hasCandidate ? best : GetDistanceSqToWorldLineSegment(cameraPos, start, end);
            }

            float GetWorldLineRenderPriorityDistanceSq(
                const vec3 &in start,
                const vec3 &in end,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                int mode = TriggerVisualizer::Trigger::UI::GetRenderProximityModeForRuntime(GetCurrentRuntimeContext());
                return GetWorldLineRenderPriorityDistanceSq(start, end, cameraPos, proximityState, mode);
            }

            vec4 LerpColor(const vec4 &in from, const vec4 &in to, float factor) {
                factor = Math::Clamp(factor, 0.0f, 1.0f);
                return Math::Lerp(from, to, factor);
            }

            float Wrap01(float value) {
                value = value - Math::Floor(value);
                if (value < 0.0f) value += 1.0f;
                return value;
            }

            vec3 RgbToHsv(const vec4 &in color) {
                float maxValue = Math::Max(color.x, Math::Max(color.y, color.z));
                float minValue = Math::Min(color.x, Math::Min(color.y, color.z));
                float delta = maxValue - minValue;
                float hue = 0.0f;

                if (delta > 0.00001f) {
                    if (maxValue == color.x) {
                        hue = (color.y - color.z) / delta;
                        if (hue < 0.0f) hue += 6.0f;
                    } else if (maxValue == color.y) {
                        hue = ((color.z - color.x) / delta) + 2.0f;
                    } else {
                        hue = ((color.x - color.y) / delta) + 4.0f;
                    }
                    hue /= 6.0f;
                }

                float saturation = maxValue <= 0.00001f ? 0.0f : delta / maxValue;
                return vec3(hue, saturation, maxValue);
            }

            vec4 HsvToRgb(float hue, float saturation, float value, float alpha) {
                hue = Wrap01(hue);
                saturation = Math::Clamp(saturation, 0.0f, 1.0f);
                value = Math::Clamp(value, 0.0f, 1.0f);
                float r = Math::Clamp(Math::Abs(hue * 6.0f - 3.0f) - 1.0f, 0.0f, 1.0f);
                float g = Math::Clamp(2.0f - Math::Abs(hue * 6.0f - 2.0f), 0.0f, 1.0f);
                float b = Math::Clamp(2.0f - Math::Abs(hue * 6.0f - 4.0f), 0.0f, 1.0f);
                r = (1.0f + (r - 1.0f) * saturation) * value;
                g = (1.0f + (g - 1.0f) * saturation) * value;
                b = (1.0f + (b - 1.0f) * saturation) * value;
                return vec4(r, g, b, alpha);
            }

            vec4 ShiftColorHue(const vec4 &in color, float hueShift) {
                vec3 hsv = RgbToHsv(color);
                return HsvToRgb(hsv.x + hueShift, hsv.y, hsv.z, color.w);
            }

            float StableRandom01(float seed) {
                float value = Math::Sin(seed * 12.9898f + 78.233f) * 43758.5453f;
                return value - Math::Floor(value);
            }

            vec4 StableRandomColor(float seed, float alpha) {
                float h = StableRandom01(seed);
                float s = 0.65f + StableRandom01(seed + 17.0f) * 0.25f;
                float v = 0.85f + StableRandom01(seed + 31.0f) * 0.15f;

                return HsvToRgb(h, s, v, alpha);
            }

            float GetOutlineSegmentColorSeed(uint boxIndex, uint edgeIndex, uint segmentIndex) {
                return 101.0f
                    + float(boxIndex) * 1009.0f
                    + float(edgeIndex) * 73.0f
                    + float(segmentIndex) * 11.0f;
            }

            float GetFillTileColorSeed(uint boxIndex, uint faceIndex) {
                return 503.0f + float(boxIndex) * 1009.0f + float(faceIndex) * 97.0f;
            }

            vec4 GetOutlineSegmentColor(const vec4 &in baseColor, uint boxIndex, uint edgeIndex, uint segmentIndex) {
                if (!TriggerVisualizer::Trigger::UI::S_RandomOutlineSegmentColors) return baseColor;
                return StableRandomColor(GetOutlineSegmentColorSeed(boxIndex, edgeIndex, segmentIndex), baseColor.w);
            }

            vec4 GetFillTileColor(const vec4 &in baseColor, float tileSeed) {
                if (!TriggerVisualizer::Trigger::UI::S_RandomFillTileColors) return baseColor;
                return StableRandomColor(tileSeed, baseColor.w);
            }

            float GetFillTileMinSize() {
                return Math::Clamp(
                    TriggerVisualizer::Trigger::UI::S_FillTileMinSize,
                    2.0f,
                    64.0f
                );
            }

            float GetTriggerVolumeLineSplitDensityFactor(const TriggerVolume@ box, const vec3 &in cameraPos) {
                if (!TriggerVisualizer::Trigger::UI::S_AdaptiveLineSplitting) return 0.0f;

                int maxAllowedSegments = Math::Max(TriggerVisualizer::Trigger::UI::S_LineSplitMaxSegmentsPerEdge, 1);
                if (maxAllowedSegments <= 1) return 0.0f;

                uint maxEdgeSegments = GetMaxTriggerVolumeOutlineEdgeSegments(box, cameraPos);
                return Math::Clamp(
                    float(Math::Max(int(maxEdgeSegments), 1) - 1) / float(maxAllowedSegments - 1),
                    0.0f,
                    1.0f
                );
            }

            int GetTurboRouletteColorPhase() {
                int yellowMs = Math::Max(TriggerVisualizer::Trigger::UI::S_TurboRouletteYellowDurationMs, 50);
                int cyanMs = Math::Max(TriggerVisualizer::Trigger::UI::S_TurboRouletteCyanDurationMs, 50);
                int purpleMs = Math::Max(TriggerVisualizer::Trigger::UI::S_TurboRoulettePurpleDurationMs, 50);
                int cycleMs = yellowMs + cyanMs + purpleMs;
                int phaseMs = int(Time::Now % uint64(cycleMs)) + TriggerVisualizer::Trigger::UI::S_TurboRoulettePhaseOffsetMs;
                phaseMs %= cycleMs;
                if (phaseMs < 0) phaseMs += cycleMs;
                if (phaseMs < yellowMs) return 0;
                if (phaseMs < yellowMs + cyanMs) return 1;
                return 2;
            }

            vec4 GetTurboRouletteRenderColor() {
                int phase = GetTurboRouletteColorPhase();
                if (phase == 1) return vec4(0.0f, 0.95f, 1.0f, 1.0f);
                if (phase == 2) return vec4(0.72f, 0.22f, 1.0f, 1.0f);
                return vec4(1.0f, 0.88f, 0.0f, 1.0f);
            }

            bool ShouldUseAnimatedTurboRouletteColor(const TriggerVolume@ box) {
                return TriggerVisualizer::Trigger::UI::S_AnimateTurboRouletteColor
                    && TriggerVisualizer::Trigger::TriggerVolumeIsTurboRoulette(box);
            }

            vec4 GetColorModeColor(const TriggerVolume@ box, const vec3 &in cameraPos, float fade) {
                vec4 color = TriggerVisualizer::Trigger::UI::S_BaseTriggerColor;
                int colorSource = TriggerVisualizer::Trigger::UI::S_ColorSource;
                if (colorSource != TriggerVisualizer::Trigger::UI::COLOR_SOURCE_UNIFORM && box !is null && box.HasTriggerTypeColor) {
                    color = box.TriggerTypeColor;
                }
                if (colorSource != TriggerVisualizer::Trigger::UI::COLOR_SOURCE_UNIFORM && ShouldUseAnimatedTurboRouletteColor(box)) {
                    color = GetTurboRouletteRenderColor();
                }
                if (colorSource == TriggerVisualizer::Trigger::UI::COLOR_SOURCE_MEDIATRACKER_TRACK_COLORS && box !is null && box.Source == TRIGGER_SOURCE_MEDIATRACKER && box.HasMediaTrackerTrackColor) {
                    color = box.MediaTrackerTrackColor;
                }
                if (TriggerVisualizer::Trigger::UI::S_EnableDistanceFadeColor) {
                    color = LerpColor(
                        color,
                        TriggerVisualizer::Trigger::UI::S_DistanceFadeColor,
                        1.0f - Math::Clamp(fade, 0.0f, 1.0f)
                    );
                }
                if (TriggerVisualizer::Trigger::UI::S_EnableLineSplitDensityColor) {
                    color = LerpColor(
                        color,
                        TriggerVisualizer::Trigger::UI::S_DenseLineSplitColor,
                        GetTriggerVolumeLineSplitDensityFactor(box, cameraPos)
                    );
                }

                return color;
            }

            vec4 GetOutlineColor(const TriggerVolume@ box, const vec3 &in cameraPos, float fade) {
                vec4 color = GetColorModeColor(box, cameraPos, fade);
                if (TriggerVisualizer::Trigger::UI::S_ColorSource == TriggerVisualizer::Trigger::UI::COLOR_SOURCE_MEDIATRACKER_TRACK_COLORS && box !is null && box.Source == TRIGGER_SOURCE_MEDIATRACKER && box.HasMediaTrackerTrackColor) {
                    color = ShiftColorHue(color, TriggerVisualizer::Trigger::UI::S_MediaTrackerTrackOutlineHueShift);
                }
                color.w *= TriggerVisualizer::Trigger::UI::S_OutlineAlpha * Math::Clamp(fade, 0.0f, 1.0f);
                return color;
            }

            vec4 GetFillColor(const TriggerVolume@ box, const vec3 &in cameraPos, float fade) {
                vec4 color = GetColorModeColor(box, cameraPos, fade);
                color.w *= TriggerVisualizer::Trigger::UI::S_FillAlpha * Math::Clamp(fade, 0.0f, 1.0f);
                return color;
            }

            vec3 GetDistanceOutsideTriggerVolume(const TriggerVolume@ box, const vec3 &in point) {
                if (box is null) return vec3(1e9f, 1e9f, 1e9f);

                vec3 halfSize = box.Size() * 0.5f;
                vec3 center = box.Center();
                vec3 absDelta = vec3(
                    Math::Abs(point.x - center.x),
                    Math::Abs(point.y - center.y),
                    Math::Abs(point.z - center.z)
                );
                vec3 delta = absDelta - halfSize;
                return vec3(Math::Max(delta.x, 0.0f), Math::Max(delta.y, 0.0f), Math::Max(delta.z, 0.0f));
            }

            float GetDistanceOutsideTriggerVolumeSq(const TriggerVolume@ box, const vec3 &in point) {
                vec3 outside = GetDistanceOutsideTriggerVolume(box, point);
                return outside.x * outside.x + outside.y * outside.y + outside.z * outside.z;
            }

            float GetTriggerVolumeRenderPriorityDistanceSq(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState,
                int mode
            ) {
                float best = 1e30f;
                bool hasCandidate = false;
                if (RenderPriorityModeUsesCamera(mode)) {
                    best = Math::Min(best, GetDistanceOutsideTriggerVolumeSq(box, cameraPos));
                    hasCandidate = true;
                }
                if (RenderPriorityModeUsesVehicle(mode) && proximityState !is null && proximityState.HasVehiclePosition) {
                    best = Math::Min(best, GetDistanceOutsideTriggerVolumeSq(box, proximityState.VehiclePosition));
                    hasCandidate = true;
                }
                if (RenderPriorityModeUsesOrbital(mode) && proximityState !is null && proximityState.HasOrbitalPoint) {
                    best = Math::Min(best, GetDistanceOutsideTriggerVolumeSq(box, proximityState.OrbitalPoint));
                    hasCandidate = true;
                }

                return hasCandidate ? best : GetDistanceOutsideTriggerVolumeSq(box, cameraPos);
            }

            float GetTriggerVolumeRenderPriorityDistanceSq(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                int mode = TriggerVisualizer::Trigger::UI::GetRenderProximityModeForRuntime(GetCurrentRuntimeContext());
                return GetTriggerVolumeRenderPriorityDistanceSq(box, cameraPos, proximityState, mode);
            }

            float GetAxisFadeFactor(float axisDistance, float renderDistance, float fadeBand) {
                renderDistance = Math::Max(renderDistance, 0.0f);
                fadeBand = Math::Max(fadeBand, 0.0f);
                if (renderDistance <= 0.0f) return axisDistance <= 0.0f ? 1.0f : 0.0f;
                if (axisDistance >= renderDistance) return 0.0f;
                if (fadeBand <= 0.0f) return 1.0f;

                fadeBand = Math::Min(fadeBand, renderDistance);
                float fadeStart = Math::Max(renderDistance - fadeBand, 0.0f);
                if (axisDistance <= fadeStart) return 1.0f;
                return 1.0f - ((axisDistance - fadeStart) / fadeBand);
            }

            float GetTriggerVolumeFadeFactor(const TriggerVolume@ box, const vec3 &in cameraPos) {
                vec3 renderDistance = GetEffectiveRenderDistanceWorld();
                vec3 fadeBand = TriggerVisualizer::Trigger::UI::GetRenderFadeBandWorld();
                vec3 outside = GetDistanceOutsideTriggerVolume(box, cameraPos);
                float fx = GetAxisFadeFactor(outside.x, renderDistance.x, fadeBand.x);
                float fy = GetAxisFadeFactor(outside.y, renderDistance.y, fadeBand.y);
                float fz = GetAxisFadeFactor(outside.z, renderDistance.z, fadeBand.z);
                return Math::Min(fx, Math::Min(fy, fz));
            }

            bool IsVisibleFadeFactor(float fade) {
                return fade > MIN_VISIBLE_FADE;
            }

            bool IsTriggerVolumeInRenderRange(const TriggerVolume@ box, const vec3 &in cameraPos) {
                return IsVisibleFadeFactor(GetTriggerVolumeFadeFactor(box, cameraPos));
            }

            float GetVehicleTriggerVolumeFadeFactor(
                const TriggerVolume@ box,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                if (proximityState is null || !proximityState.HasVehiclePosition) return 0.0f;
                return GetTriggerVolumeFadeFactor(box, proximityState.VehiclePosition);
            }

            float GetOrbitalTriggerVolumeFadeFactor(
                const TriggerVolume@ box,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                if (proximityState is null || !proximityState.HasOrbitalPoint) return 0.0f;
                return GetTriggerVolumeFadeFactor(box, proximityState.OrbitalPoint);
            }

            float GetTriggerVolumeRenderFadeFactor(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState,
                int proximityMode
            ) {
                float cameraFade = GetTriggerVolumeFadeFactor(box, cameraPos);
                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_VEHICLE_ONLY) {
                    float vehicleFade = GetVehicleTriggerVolumeFadeFactor(box, proximityState);
                    return proximityState !is null && proximityState.HasVehiclePosition ? vehicleFade : cameraFade;
                }

                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_AND_VEHICLE) {
                    float vehicleFade = GetVehicleTriggerVolumeFadeFactor(box, proximityState);
                    return Math::Max(cameraFade, vehicleFade);
                }

                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_ORBITAL_ONLY) {
                    float orbitalFade = GetOrbitalTriggerVolumeFadeFactor(box, proximityState);
                    return proximityState !is null && proximityState.HasOrbitalPoint ? orbitalFade : cameraFade;
                }

                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_AND_ORBITAL) {
                    float orbitalFade = GetOrbitalTriggerVolumeFadeFactor(box, proximityState);
                    return Math::Max(cameraFade, orbitalFade);
                }

                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_VEHICLE_AND_ORBITAL) {
                    float vehicleFade = GetVehicleTriggerVolumeFadeFactor(box, proximityState);
                    float orbitalFade = GetOrbitalTriggerVolumeFadeFactor(box, proximityState);
                    float combinedFade = Math::Max(vehicleFade, orbitalFade);
                    return(proximityState !is null && (proximityState.HasVehiclePosition || proximityState.HasOrbitalPoint)) ? combinedFade : cameraFade;
                }

                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_VEHICLE_AND_ORBITAL) {
                    float vehicleFade = GetVehicleTriggerVolumeFadeFactor(box, proximityState);
                    float orbitalFade = GetOrbitalTriggerVolumeFadeFactor(box, proximityState);
                    return Math::Max(cameraFade, Math::Max(vehicleFade, orbitalFade));
                }

                return cameraFade;
            }

            float GetTriggerVolumeRenderFadeFactor(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                int proximityMode = TriggerVisualizer::Trigger::UI::GetRenderProximityModeForRuntime(GetCurrentRuntimeContext());
                return GetTriggerVolumeRenderFadeFactor(box, cameraPos, proximityState, proximityMode);
            }

            bool IsTriggerVolumeInRenderRangeForProximity(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                return IsVisibleFadeFactor(GetTriggerVolumeRenderFadeFactor(box, cameraPos, proximityState));
            }

            uint CountTriggerVolumesInRenderRange(const array<TriggerVolume@> @boxes, const vec3 &in cameraPos) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    if (IsTriggerVolumeInRenderRange(boxes[i], cameraPos)) {
                        count++;
                    }
                }
                return count;
            }

            uint CountTriggerVolumesInRenderRangeForProximity(
                const array<TriggerVolume@> @boxes,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    if (IsTriggerVolumeInRenderRangeForProximity(boxes[i], cameraPos, proximityState)) {
                        count++;
                    }
                }
                return count;
            }

            uint CountTriggerVolumesInFadeBand(const array<TriggerVolume@> @boxes, const vec3 &in cameraPos) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    float fade = GetTriggerVolumeFadeFactor(boxes[i], cameraPos);
                    if (fade >= 1.0f || !IsVisibleFadeFactor(fade)) continue;
                    count++;
                }
                return count;
            }

            uint CountTriggerVolumesInFadeBandForProximity(
                const array<TriggerVolume@> @boxes,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    float fade = GetTriggerVolumeRenderFadeFactor(boxes[i], cameraPos, proximityState);
                    if (fade >= 1.0f || !IsVisibleFadeFactor(fade)) continue;
                    count++;
                }
                return count;
            }

            void DrawTriggerVolumeFill(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                uint boxIndex
            ) {
                auto items = array<WorldFillTileDrawItem@>();
                CollectTriggerVolumeFillDrawItems(box, cameraPos, color, boxIndex, items);
                DrawWorldFillTileDrawItems(items);
            }

            bool ShouldRenderTriggerVolumeFillTiles(const TriggerVolume@ box) {
                if (box is null) return false;
                return TriggerVisualizer::Trigger::UI::S_AdaptiveLineSplitting
                    || ShouldRepeatTileIconsOnSplitFillTilesNow()
                    || TriggerVisualizer::Trigger::UI::S_RandomFillTileColors;
            }

            bool ShouldRenderTriggerVolumeSimpleFill(const TriggerVolume@ box) {
                if (box is null) return false;
                return !ShouldRenderTriggerVolumeFillTiles(box);
            }

            uint CollectSimpleTriggerVolumeFillDrawItems(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                uint boxIndex,
                array<WorldFillTileDrawItem@> @items
            ) {
                if (items is null || color.w <= 0.001f) return 0;

                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return 0;

                int maxFrameTiles = GetEffectiveMaxFillTilesPerFrame();
                uint drawn = 0;
                for (uint i = 0; i < TRIGGER_VOLUME_FACE_INDICES.Length; i++) {
                    if (int(items.Length) >= maxFrameTiles) return drawn;

                    auto face = TRIGGER_VOLUME_FACE_INDICES[i];
                    if (!IsTriggerVolumeFaceCameraFacing(corners, face, i, cameraPos)) continue;

                    vec3 origin = corners[face[0]];
                    vec3 uEdge = corners[face[1]] - origin;
                    vec3 vEdge = corners[face[3]] - origin;
                    float tileSeed = GetFillTileColorSeed(boxIndex, i);
                    WorldFillTileDrawItem@ item = WorldFillTileDrawItem(
                        origin,
                        uEdge,
                        vEdge,
                        GetFillTileColor(color, tileSeed),
                        tileSeed,
                        GetWorldFillTileSortDistanceSq(origin, uEdge, vEdge, cameraPos)
                    );
                    item.TileIconTextureKey = Assets::GetTileIconTextureKeyForVolume(box);
                    item.AllowTileIcon = false;
                    if (!UpdateWorldFillTileScreenProjection(item)) continue;

                    items.InsertLast(item);
                    drawn++;
                }

                return drawn;
            }

            string GetTriggerVolumeFaceGeometryKey(const array<vec3> @corners, const uint[]@ face) {
                if (corners is null || face is null || face.Length != 4) return "";

                vec3 origin = corners[face[0]];
                vec3 uEdge = corners[face[1]] - origin;
                vec3 vEdge = corners[face[3]] - origin;
                return GetWorldFillTileGeometryKey(origin, uEdge, vEdge);
            }

            bool IsCachedGroupOutlineEdgeDuplicate(const TriggerVolume@ box, uint edgeIndex) {
                if (box is null || edgeIndex >= box.CachedGroupOutlineEdgeKeys.Length) return false;
                return GetGeometryKeyCount(
                    box.CachedGroupOutlineEdgeCountKeys,
                    box.CachedGroupOutlineEdgeCounts,
                    box.CachedGroupOutlineEdgeKeys[edgeIndex]
                ) > 1;
            }

            void AddTriggerVolumeFaceGeometryCounts(
                const TriggerVolume@ box,
                array<string> @keys,
                array<uint> @counts
            ) {
                if (box is null || keys is null || counts is null) return;

                if (box.HasChildVolumes()) {
                    for (uint i = 0; i < box.ChildVolumes.Length; i++) {
                        AddTriggerVolumeFaceGeometryCounts(box.ChildVolumes[i], keys, counts);
                    }
                    return;
                }

                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return;

                for (uint i = 0; i < TRIGGER_VOLUME_FACE_INDICES.Length; i++) {
                    AddGeometryKeyCount(
                        keys,
                        counts,
                        GetTriggerVolumeFaceGeometryKey(corners, TRIGGER_VOLUME_FACE_INDICES[i])
                    );
                }
            }

            bool IsDuplicateGroupFaceGeometry(
                const array<vec3> @corners,
                const uint[]@ face,
                const array<string> @faceKeys,
                const array<uint> @faceCounts
            ) {
                return GetGeometryKeyCount(
                    faceKeys,
                    faceCounts,
                    GetTriggerVolumeFaceGeometryKey(corners, face)
                ) > 1;
            }

            void AddTriggerVolumeTileIconDrawItem(
                const TriggerVolume@ box,
                const array<vec3> @corners,
                const uint[]@ face,
                uint faceIndex,
                const vec3 &in cameraPos,
                array<WorldTileIconDrawItem@> @items
            ) {
                if (box is null || corners is null || face is null || face.Length != 4 || items is null) return;
                if (!IsTriggerVolumeFaceCameraFacing(corners, face, faceIndex, cameraPos)) return;

                string textureKey = Assets::GetTileIconTextureKeyForVolume(box);
                if (textureKey.Length == 0) return;

                vec3 origin = corners[face[0]];
                vec3 uEdge = corners[face[1]] - origin;
                vec3 vEdge = corners[face[3]] - origin;
                WorldTileIconDrawItem@ item = WorldTileIconDrawItem(
                    origin,
                    uEdge,
                    vEdge,
                    textureKey,
                    GetWorldFillTileSortDistanceSq(origin, uEdge, vEdge, cameraPos)
                );
                items.InsertLast(item);
            }

            void CollectTriggerVolumeTileIconDrawItemsFiltered(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                array<WorldTileIconDrawItem@> @items,
                const array<string> @hiddenFaceKeys,
                const array<uint> @hiddenFaceCounts
            ) {
                if (!ShouldCollectTileIconsSeparatelyNow() || box is null || items is null) return;

                if (box.HasChildVolumes()) {
                    for (uint i = 0; i < box.ChildVolumes.Length; i++) {
                        CollectTriggerVolumeTileIconDrawItemsFiltered(
                            box.ChildVolumes[i],
                            cameraPos,
                            items,
                            hiddenFaceKeys,
                            hiddenFaceCounts
                        );
                    }
                    return;
                }

                if (box.HasCustomOutlineGeometry()) return;

                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return;

                for (uint i = 0; i < TRIGGER_VOLUME_FACE_INDICES.Length; i++) {
                    auto face = TRIGGER_VOLUME_FACE_INDICES[i];
                    if (IsDuplicateGroupFaceGeometry(corners, face, hiddenFaceKeys, hiddenFaceCounts)) continue;
                    AddTriggerVolumeTileIconDrawItem(
                        box,
                        corners,
                        face,
                        i,
                        cameraPos,
                        items
                    );
                }
            }

            void CollectTriggerVolumeTileIconDrawItems(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                array<WorldTileIconDrawItem@> @items
            ) {
                if (!ShouldCollectTileIconsSeparatelyNow() || box is null || items is null) return;
                if (box.HasCustomOutlineGeometry()) return;

                if (box.HasChildVolumes()) {
                    if (ShouldSimplifyGroupedTriggersNow()) {
                        auto simplifiedBox = TriggerVisualizer::Trigger::Data::CloneTriggerVolumeForMerge(box);
                        CollectTriggerVolumeTileIconDrawItems(simplifiedBox, cameraPos, items);
                        return;
                    }

                    if (box.HasCachedGroupGeometry()) {
                        CollectTriggerVolumeTileIconDrawItemsFiltered(
                            box,
                            cameraPos,
                            items,
                            box.CachedGroupFaceKeys,
                            box.CachedGroupFaceCounts
                        );
                        return;
                    }

                    auto hiddenFaceKeys = array<string>();
                    auto hiddenFaceCounts = array<uint>();
                    AddTriggerVolumeFaceGeometryCounts(box, hiddenFaceKeys, hiddenFaceCounts);
                    CollectTriggerVolumeTileIconDrawItemsFiltered(
                        box,
                        cameraPos,
                        items,
                        hiddenFaceKeys,
                        hiddenFaceCounts
                    );
                    return;
                }

                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return;

                for (uint i = 0; i < TRIGGER_VOLUME_FACE_INDICES.Length; i++) {
                    AddTriggerVolumeTileIconDrawItem(
                        box,
                        corners,
                        TRIGGER_VOLUME_FACE_INDICES[i],
                        i,
                        cameraPos,
                        items
                    );
                }
            }

            void CollectTriggerVolumeFillDrawItemsFiltered(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                uint boxIndex,
                array<WorldFillTileDrawItem@> @items,
                const array<string> @hiddenFaceKeys,
                const array<uint> @hiddenFaceCounts
            ) {
                if (items is null) return;
                int maxFrameTiles = GetEffectiveMaxFillTilesPerFrame();
                if (int(items.Length) >= maxFrameTiles) return;
                if (box is null) return;

                if (box.HasChildVolumes()) {
                    for (uint i = 0; i < box.ChildVolumes.Length; i++) {
                        if (int(items.Length) >= maxFrameTiles) return;
                        CollectTriggerVolumeFillDrawItemsFiltered(
                            box.ChildVolumes[i],
                            cameraPos,
                            color,
                            boxIndex + i + 1,
                            items,
                            hiddenFaceKeys,
                            hiddenFaceCounts
                        );
                    }
                    return;
                }

                if (ShouldRenderTriggerVolumeSimpleFill(box)) {
                    if (color.w <= 0.001f) return;

                    auto corners = GetTriggerVolumeCorners(box);
                    if (corners.Length != 8) return;

                    for (uint i = 0; i < TRIGGER_VOLUME_FACE_INDICES.Length; i++) {
                        if (int(items.Length) >= maxFrameTiles) return;

                        auto face = TRIGGER_VOLUME_FACE_INDICES[i];
                        if (IsDuplicateGroupFaceGeometry(corners, face, hiddenFaceKeys, hiddenFaceCounts)) continue;
                        if (!IsTriggerVolumeFaceCameraFacing(corners, face, i, cameraPos)) continue;

                        vec3 origin = corners[face[0]];
                        vec3 uEdge = corners[face[1]] - origin;
                        vec3 vEdge = corners[face[3]] - origin;
                        float tileSeed = GetFillTileColorSeed(boxIndex, i);
                        WorldFillTileDrawItem@ item = WorldFillTileDrawItem(
                            origin,
                            uEdge,
                            vEdge,
                            GetFillTileColor(color, tileSeed),
                            tileSeed,
                            GetWorldFillTileSortDistanceSq(origin, uEdge, vEdge, cameraPos)
                        );
                        item.TileIconTextureKey = Assets::GetTileIconTextureKeyForVolume(box);
                        item.AllowTileIcon = false;
                        if (!UpdateWorldFillTileScreenProjection(item)) continue;

                        items.InsertLast(item);
                    }
                    return;
                }

                if (!ShouldRenderTriggerVolumeFillTiles(box)) return;
                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return;
                if (color.w <= 0.001f && !ShouldRepeatTileIconsOnSplitFillTilesNow()) return;

                for (uint i = 0; i < TRIGGER_VOLUME_FACE_INDICES.Length; i++) {
                    auto face = TRIGGER_VOLUME_FACE_INDICES[i];
                    if (IsDuplicateGroupFaceGeometry(corners, face, hiddenFaceKeys, hiddenFaceCounts)) continue;
                    if (!IsTriggerVolumeFaceCameraFacing(corners, face, i, cameraPos)) continue;
                    CollectAdaptiveWorldFaceFillDrawItems(
                        items,
                        corners,
                        face,
                        cameraPos,
                        color,
                        boxIndex,
                        i,
                        Assets::GetTileIconTextureKeyForVolume(box)
                    );
                }
            }

            void CollectTriggerVolumeFillDrawItems(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                uint boxIndex,
                array<WorldFillTileDrawItem@> @items
            ) {
                if (items is null) return;
                int maxFrameTiles = GetEffectiveMaxFillTilesPerFrame();
                if (int(items.Length) >= maxFrameTiles) return;
                if (box !is null && box.HasCustomOutlineGeometry()) return;
                if (box !is null && box.HasChildVolumes()) {
                    if (ShouldSimplifyGroupedTriggersNow()) {
                        auto simplifiedBox = TriggerVisualizer::Trigger::Data::CloneTriggerVolumeForMerge(box);
                        CollectTriggerVolumeFillDrawItems(simplifiedBox, cameraPos, color, boxIndex, items);
                        return;
                    }

                    if (box.HasCachedGroupGeometry()) {
                        CollectTriggerVolumeFillDrawItemsFiltered(
                            box,
                            cameraPos,
                            color,
                            boxIndex,
                            items,
                            box.CachedGroupFaceKeys,
                            box.CachedGroupFaceCounts
                        );
                        return;
                    }

                    auto hiddenFaceKeys = array<string>();
                    auto hiddenFaceCounts = array<uint>();
                    AddTriggerVolumeFaceGeometryCounts(box, hiddenFaceKeys, hiddenFaceCounts);
                    CollectTriggerVolumeFillDrawItemsFiltered(
                        box,
                        cameraPos,
                        color,
                        boxIndex,
                        items,
                        hiddenFaceKeys,
                        hiddenFaceCounts
                    );
                    return;
                }
                if (ShouldRenderTriggerVolumeSimpleFill(box)) {
                    CollectSimpleTriggerVolumeFillDrawItems(box, cameraPos, color, boxIndex, items);
                    return;
                }
                if (!ShouldRenderTriggerVolumeFillTiles(box)) return;
                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return;
                if (color.w <= 0.001f && !ShouldRepeatTileIconsOnSplitFillTilesNow()) return;

                for (uint i = 0; i < TRIGGER_VOLUME_FACE_INDICES.Length; i++) {
                    auto face = TRIGGER_VOLUME_FACE_INDICES[i];
                    if (!IsTriggerVolumeFaceCameraFacing(corners, face, i, cameraPos)) continue;
                    CollectAdaptiveWorldFaceFillDrawItems(
                        items,
                        corners,
                        face,
                        cameraPos,
                        color,
                        boxIndex,
                        i,
                        Assets::GetTileIconTextureKeyForVolume(box)
                    );
                }
            }

            void CollectTriggerVolumeOutlineEdgeDrawItems(
                const TriggerVolume@ box,
                uint boxIndex,
                array<WorldOutlineEdgeDrawItem@> @items,
                array<string> @edgeKeys,
                array<uint> @edgeCounts
            ) {
                if (box is null || items is null || edgeKeys is null || edgeCounts is null) return;

                if (box.HasStaticOutlineCache()) {
                    uint count = box.CachedStaticOutlineCount();
                    for (uint i = 0; i < count; i++) {
                        WorldOutlineEdgeDrawItem@ item = WorldOutlineEdgeDrawItem(
                            box.CachedStaticOutlineStarts[i],
                            box.CachedStaticOutlineEnds[i],
                            boxIndex + box.CachedStaticOutlineBoxIndices[i],
                            box.CachedStaticOutlineEdgeIndices[i]
                        );
                        items.InsertLast(item);
                        AddGeometryKeyCount(
                            edgeKeys,
                            edgeCounts,
                            item.GeometryKey
                        );
                    }
                    return;
                }

                if (box.HasCachedGroupGeometry()) {
                    uint count = box.CachedGroupOutlineEdgeCount();
                    for (uint i = 0; i < box.CachedGroupOutlineEdgeCountKeys.Length && i < box.CachedGroupOutlineEdgeCounts.Length; i++) {
                        edgeKeys.InsertLast(box.CachedGroupOutlineEdgeCountKeys[i]);
                        edgeCounts.InsertLast(box.CachedGroupOutlineEdgeCounts[i]);
                    }

                    for (uint i = 0; i < count; i++) {
                        WorldOutlineEdgeDrawItem@ item = WorldOutlineEdgeDrawItem();
                        item.Start = box.CachedGroupOutlineEdgeStarts[i];
                        item.End = box.CachedGroupOutlineEdgeEnds[i];
                        item.BoxIndex = boxIndex + box.CachedGroupOutlineEdgeBoxIndices[i];
                        item.EdgeIndex = box.CachedGroupOutlineEdgeIndices[i];
                        item.GeometryKey = box.CachedGroupOutlineEdgeKeys[i];
                        items.InsertLast(item);
                    }
                    return;
                }

                if (box.HasChildVolumes()) {
                    for (uint i = 0; i < box.ChildVolumes.Length; i++) {
                        CollectTriggerVolumeOutlineEdgeDrawItems(
                            box.ChildVolumes[i],
                            boxIndex + i + 1,
                            items,
                            edgeKeys,
                            edgeCounts
                        );
                    }
                    return;
                }

                if (box.HasCustomOutlineGeometry()) {
                    uint outlineLineCount = box.OutlineLineCount();
                    for (uint i = 0; i < outlineLineCount; i++) {
                        WorldOutlineEdgeDrawItem@ item = WorldOutlineEdgeDrawItem(
                            box.OutlineLineStarts[i],
                            box.OutlineLineEnds[i],
                            boxIndex,
                            i
                        );
                        items.InsertLast(item);
                        AddGeometryKeyCount(
                            edgeKeys,
                            edgeCounts,
                            item.GeometryKey
                        );
                    }
                    return;
                }

                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return;

                for (uint i = 0; i < TRIGGER_VOLUME_EDGE_INDICES.Length; i++) {
                    auto edge = TRIGGER_VOLUME_EDGE_INDICES[i];
                    WorldOutlineEdgeDrawItem@ item = WorldOutlineEdgeDrawItem(
                        corners[edge[0]],
                        corners[edge[1]],
                        boxIndex,
                        i
                    );
                    items.InsertLast(item);
                    AddGeometryKeyCount(
                        edgeKeys,
                        edgeCounts,
                        item.GeometryKey
                    );
                }
            }

            void AddWorldOutlineEdgeDrawItem(
                WorldOutlineEdgeDrawItem@ item,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState,
                int proximityMode,
                const vec4 &in color,
                array<WorldOutlineEdgeDrawItem@> @items
            ) {
                if (item is null || items is null || color.w <= 0.001f) return;

                item.Color = color;
                item.SortDistanceSq = GetWorldLineRenderPriorityDistanceSq(
                    item.Start,
                    item.End,
                    cameraPos,
                    proximityState,
                    proximityMode
                );
                items.InsertLast(item);
            }

            void PrepareWorldOutlineEdgeDrawItemsForCameraPriority(
                array<WorldOutlineEdgeDrawItem@> @items,
                const vec3 &in cameraPos
            ) {
                if (items is null) return;
                for (uint i = 0; i < items.Length; i++) {
                    if (items[i] is null) continue;
                    items[i].SortDistanceSq = GetDistanceSqToWorldLineSegment(
                        cameraPos,
                        items[i].Start,
                        items[i].End
                    );
                }
                SortWorldOutlineEdgeDrawItemsByRenderPriority(items);
            }

            uint GetWorldLineSegmentBudgetRemainingForVolume(const TriggerVolume@ box) {
                if (!TriggerVisualizer::Trigger::UI::ArePerformanceBudgetsEnabled()) {
                    return WORLD_LINE_SEGMENT_BUDGET_HARD_MAX;
                }

                uint remaining = G_WorldLineSegmentBudgetRemaining;
                if (UsesCrystalOutlineBudget(box) && G_CrystalWorldLineSegmentBudgetRemaining<remaining) {
                    remaining = G_CrystalWorldLineSegmentBudgetRemaining;
                }
                return remaining;
            }

            bool ShouldPrioritizeWorldOutlineEdgesForBudget(const TriggerVolume@ box, uint edgeCount) {
                if (edgeCount <= 1) return false;
                uint remaining = GetWorldLineSegmentBudgetRemainingForVolume(box);
                return remaining> 0 && edgeCount > remaining;
            }

            void CollectTriggerVolumeOutlineDrawItems(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState,
                int proximityMode,
                const vec4 &in color,
                uint boxIndex,
                array<WorldOutlineEdgeDrawItem@> @items
            ) {
                if (box is null || items is null || color.w <= 0.001f) return;

                if (box.HasChildVolumes() && ShouldSimplifyGroupedTriggersNow()) {
                    auto simplifiedBox = TriggerVisualizer::Trigger::Data::CloneTriggerVolumeForMerge(box);
                    CollectTriggerVolumeOutlineDrawItems(
                        simplifiedBox,
                        cameraPos,
                        proximityState,
                        proximityMode,
                        color,
                        boxIndex,
                        items
                    );
                    return;
                }

                auto edgeItems = array<WorldOutlineEdgeDrawItem@>();
                auto edgeKeys = array<string>();
                auto edgeCounts = array<uint>();
                CollectTriggerVolumeOutlineEdgeDrawItems(
                    box,
                    boxIndex,
                    edgeItems,
                    edgeKeys,
                    edgeCounts
                );

                for (uint i = 0; i < edgeItems.Length; i++) {
                    if (edgeItems[i] is null) continue;
                    if (GetGeometryKeyCount(edgeKeys, edgeCounts, edgeItems[i].GeometryKey) > 1) continue;
                    AddWorldOutlineEdgeDrawItem(edgeItems[i], cameraPos, proximityState, proximityMode, color, items);
                }
            }

            bool ShouldWorldOutlineEdgeSortAfter(
                const WorldOutlineEdgeDrawItem@ left,
                const WorldOutlineEdgeDrawItem@ right
            ) {
                if (left is null) return false;
                if (right is null) return true;
                if (left.SortDistanceSq > right.SortDistanceSq) return true;
                if (left.SortDistanceSq < right.SortDistanceSq) return false;
                if (left.BoxIndex > right.BoxIndex) return true;
                if (left.BoxIndex < right.BoxIndex) return false;
                return left.EdgeIndex > right.EdgeIndex;
            }

            void SortWorldOutlineEdgeDrawItemsByRenderPriority(array<WorldOutlineEdgeDrawItem@> @items) {
                if (items is null || items.Length <= 1) return;

                uint gap = items.Length / 2;
                while (gap > 0) {
                    for (uint i = gap; i < items.Length; i++) {
                        WorldOutlineEdgeDrawItem@ item = items[i];
                        uint j = i;
                        while (j >= gap && ShouldWorldOutlineEdgeSortAfter(items[j - gap], item)) {
                            @items[j] = items[j - gap];
                            j -= gap;
                        }
                        @items[j] = item;
                    }
                    gap /= 2;
                }
            }

            void DrawWorldOutlineEdgeDrawItems(
                array<WorldOutlineEdgeDrawItem@> @items,
                const vec3 &in cameraPos,
                float strokeWidth
            ) {
                if (items is null || items.Length == 0) return;
                SortWorldOutlineEdgeDrawItemsByRenderPriority(items);
                nvg::Reset();
                nvg::StrokeWidth(Math::Clamp(strokeWidth, 0.5f, 16.0f));

                for (uint i = 0; i < items.Length; i++) {
                    if (!HasWorldLineSegmentBudgetForVolume(null)) break;
                    if (items[i] is null) continue;
                    DrawWorldLineAdaptiveColoredForVolume(
                        items[i].Start,
                        items[i].End,
                        cameraPos,
                        items[i].Color,
                        items[i].BoxIndex,
                        items[i].EdgeIndex,
                        null,
                        true
                    );
                }
            }

            void DrawGroupedTriggerVolumeOutline(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                float strokeWidth,
                uint boxIndex
            ) {
                if (!box.HasCachedGroupGeometry()) {
                    auto items = array<WorldOutlineEdgeDrawItem@>();
                    auto edgeKeys = array<string>();
                    auto edgeCounts = array<uint>();
                    CollectTriggerVolumeOutlineEdgeDrawItems(
                        box,
                        boxIndex,
                        items,
                        edgeKeys,
                        edgeCounts
                    );
                    if (items.Length == 0) return;
                    if (ShouldPrioritizeWorldOutlineEdgesForBudget(box, items.Length)) {
                        PrepareWorldOutlineEdgeDrawItemsForCameraPriority(items, cameraPos);
                    }
                    nvg::Reset();
                    nvg::StrokeWidth(Math::Clamp(strokeWidth, 0.5f, 16.0f));

                    for (uint i = 0; i < items.Length; i++) {
                        if (!HasWorldLineSegmentBudgetForVolume(box)) break;
                        if (items[i] is null) continue;
                        if (GetGeometryKeyCount(edgeKeys, edgeCounts, items[i].GeometryKey) > 1) continue;

                        DrawWorldLineAdaptiveColoredForVolume(
                            items[i].Start,
                            items[i].End,
                            cameraPos,
                            color,
                            items[i].BoxIndex,
                            items[i].EdgeIndex,
                            box,
                            ShouldSplitTriggerVolumeOutlineEdges(box)
                        );
                    }
                    return;
                }

                uint cachedEdgeCount = box.CachedGroupOutlineEdgeCount();
                if (cachedEdgeCount == 0) return;

                if (!ShouldPrioritizeWorldOutlineEdgesForBudget(box, cachedEdgeCount)) {
                    nvg::Reset();
                    nvg::StrokeWidth(Math::Clamp(strokeWidth, 0.5f, 16.0f));

                    for (uint i = 0; i < cachedEdgeCount; i++) {
                        if (!HasWorldLineSegmentBudgetForVolume(box)) break;
                        if (IsCachedGroupOutlineEdgeDuplicate(box, i)) continue;

                        DrawWorldLineAdaptiveColoredForVolume(
                            box.CachedGroupOutlineEdgeStarts[i],
                            box.CachedGroupOutlineEdgeEnds[i],
                            cameraPos,
                            color,
                            boxIndex + box.CachedGroupOutlineEdgeBoxIndices[i],
                            box.CachedGroupOutlineEdgeIndices[i],
                            box,
                            ShouldSplitTriggerVolumeOutlineEdges(box)
                        );
                    }
                    return;
                }

                auto items = array<WorldOutlineEdgeDrawItem@>();
                for (uint i = 0; i < cachedEdgeCount; i++) {
                    if (IsCachedGroupOutlineEdgeDuplicate(box, i)) continue;

                    WorldOutlineEdgeDrawItem@ item = WorldOutlineEdgeDrawItem();
                    item.Start = box.CachedGroupOutlineEdgeStarts[i];
                    item.End = box.CachedGroupOutlineEdgeEnds[i];
                    item.BoxIndex = boxIndex + box.CachedGroupOutlineEdgeBoxIndices[i];
                    item.EdgeIndex = box.CachedGroupOutlineEdgeIndices[i];
                    item.GeometryKey = box.CachedGroupOutlineEdgeKeys[i];
                    items.InsertLast(item);
                }
                if (items.Length == 0) return;
                PrepareWorldOutlineEdgeDrawItemsForCameraPriority(items, cameraPos);
                nvg::Reset();
                nvg::StrokeWidth(Math::Clamp(strokeWidth, 0.5f, 16.0f));

                for (uint i = 0; i < items.Length; i++) {
                    if (!HasWorldLineSegmentBudgetForVolume(box)) break;
                    if (items[i] is null) continue;

                    DrawWorldLineAdaptiveColoredForVolume(
                        items[i].Start,
                        items[i].End,
                        cameraPos,
                        color,
                        items[i].BoxIndex,
                        items[i].EdgeIndex,
                        box,
                        ShouldSplitTriggerVolumeOutlineEdges(box)
                    );
                }
            }

            bool CanBatchTriggerVolumeStaticOutline(const TriggerVolume@ box) {
                if (box is null || !box.HasStaticOutlineCache()) return false;
                return !TriggerVisualizer::Trigger::UI::S_RandomOutlineSegmentColors;
            }

            void DrawTriggerVolumeStaticOutline(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                float strokeWidth,
                uint boxIndex
            ) {
                if (box is null || !box.HasStaticOutlineCache()) return;

                uint count = box.CachedStaticOutlineCount();
                if (count == 0) return;

                bool prioritizeEdges = ShouldPrioritizeWorldOutlineEdgesForBudget(box, count);
                array<WorldOutlineEdgeDrawItem@> @items = null;
                if (prioritizeEdges) {
                    @items = array<WorldOutlineEdgeDrawItem@>();
                    for (uint i = 0; i < count; i++) {
                        items.InsertLast(WorldOutlineEdgeDrawItem(box.CachedStaticOutlineStarts[i], box.CachedStaticOutlineEnds[i], boxIndex + box.CachedStaticOutlineBoxIndices[i], box.CachedStaticOutlineEdgeIndices[i]));
                    }
                    PrepareWorldOutlineEdgeDrawItemsForCameraPriority(items, cameraPos);
                }
                nvg::Reset();
                nvg::StrokeWidth(Math::Clamp(strokeWidth, 0.5f, 16.0f));
                bool allowAdaptiveSplitting = ShouldSplitTriggerVolumeOutlineEdges(box);
                if (CanBatchTriggerVolumeStaticOutline(box)) {
                    nvg::BeginPath();
                    nvg::StrokeColor(color);
                    bool drewAny = false;
                    uint drawCount = count;
                    if (prioritizeEdges) drawCount = items.Length;
                    for (uint i = 0; i < drawCount; i++) {
                        if (!HasWorldLineSegmentBudgetForVolume(box)) break;
                        vec3 start = box.CachedStaticOutlineStarts[i];
                        vec3 end = box.CachedStaticOutlineEnds[i];
                        if (prioritizeEdges) {
                            start = items[i].Start;
                            end = items[i].End;
                        }
                        drewAny = DrawWorldLineAdaptiveToCurrentPathForVolume(
                            start,
                            end,
                            cameraPos,
                            box,
                            allowAdaptiveSplitting
                        ) || drewAny;
                    }
                    if (drewAny) {
                        nvg::Stroke();
                    }
                    nvg::ClosePath();
                    return;
                }

                uint drawCount = count;
                if (prioritizeEdges) drawCount = items.Length;
                for (uint i = 0; i < drawCount; i++) {
                    if (!HasWorldLineSegmentBudgetForVolume(box)) break;
                    vec3 start = box.CachedStaticOutlineStarts[i];
                    vec3 end = box.CachedStaticOutlineEnds[i];
                    uint itemBoxIndex = boxIndex + box.CachedStaticOutlineBoxIndices[i];
                    uint edgeIndex = box.CachedStaticOutlineEdgeIndices[i];
                    if (prioritizeEdges) {
                        start = items[i].Start;
                        end = items[i].End;
                        itemBoxIndex = items[i].BoxIndex;
                        edgeIndex = items[i].EdgeIndex;
                    }
                    DrawWorldLineAdaptiveColoredForVolume(
                        start,
                        end,
                        cameraPos,
                        color,
                        itemBoxIndex,
                        edgeIndex,
                        box,
                        allowAdaptiveSplitting
                    );
                }
            }

            bool CanBatchTriggerVolumeCustomOutline(const TriggerVolume@ box) {
                if (box is null || !box.HasCustomOutlineGeometry()) return false;
                return !TriggerVisualizer::Trigger::UI::S_RandomOutlineSegmentColors;
            }

            void DrawTriggerVolumeCustomOutline(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                float strokeWidth,
                uint boxIndex
            ) {
                if (box is null || !box.HasCustomOutlineGeometry()) return;

                nvg::Reset();
                nvg::StrokeWidth(Math::Clamp(strokeWidth, 0.5f, 16.0f));
                uint outlineLineCount = box.OutlineLineCount();
                bool allowAdaptiveSplitting = ShouldSplitTriggerVolumeOutlineEdges(box);
                bool prioritizeEdges = ShouldPrioritizeWorldOutlineEdgesForBudget(box, outlineLineCount);
                array<WorldOutlineEdgeDrawItem@> @items = null;
                if (prioritizeEdges) {
                    @items = array<WorldOutlineEdgeDrawItem@>();
                    for (uint i = 0; i < outlineLineCount; i++) {
                        items.InsertLast(WorldOutlineEdgeDrawItem(box.OutlineLineStarts[i], box.OutlineLineEnds[i], boxIndex, i));
                    }
                    PrepareWorldOutlineEdgeDrawItemsForCameraPriority(items, cameraPos);
                }

                if (CanBatchTriggerVolumeCustomOutline(box)) {
                    nvg::BeginPath();
                    nvg::StrokeColor(color);
                    bool drewAny = false;
                    uint drawCount = outlineLineCount;
                    if (prioritizeEdges) drawCount = items.Length;
                    for (uint i = 0; i < drawCount; i++) {
                        if (!HasWorldLineSegmentBudgetForVolume(box)) break;
                        vec3 start = box.OutlineLineStarts[i];
                        vec3 end = box.OutlineLineEnds[i];
                        if (prioritizeEdges) {
                            start = items[i].Start;
                            end = items[i].End;
                        }
                        drewAny = DrawWorldLineAdaptiveToCurrentPathForVolume(
                            start,
                            end,
                            cameraPos,
                            box,
                            allowAdaptiveSplitting
                        ) || drewAny;
                    }
                    if (drewAny) {
                        nvg::Stroke();
                    }
                    nvg::ClosePath();
                    return;
                }

                uint drawCount = outlineLineCount;
                if (prioritizeEdges) drawCount = items.Length;
                for (uint i = 0; i < drawCount; i++) {
                    if (!HasWorldLineSegmentBudgetForVolume(box)) break;
                    vec3 start = box.OutlineLineStarts[i];
                    vec3 end = box.OutlineLineEnds[i];
                    uint edgeIndex = i;
                    if (prioritizeEdges) {
                        start = items[i].Start;
                        end = items[i].End;
                        edgeIndex = items[i].EdgeIndex;
                    }
                    DrawWorldLineAdaptiveColoredForVolume(
                        start,
                        end,
                        cameraPos,
                        color,
                        boxIndex,
                        edgeIndex,
                        box,
                        allowAdaptiveSplitting
                    );
                }
            }

            void DrawTriggerVolumeOutline(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                float strokeWidth,
                uint boxIndex
            ) {
                if (box is null || color.w <= 0.001f) return;

                if (box !is null && box.HasChildVolumes()) {
                    if (ShouldSimplifyGroupedTriggersNow()) {
                        auto simplifiedBox = TriggerVisualizer::Trigger::Data::CloneTriggerVolumeForMerge(box);
                        DrawTriggerVolumeOutline(simplifiedBox, cameraPos, color, strokeWidth, boxIndex);
                        return;
                    }

                    if (box.HasStaticOutlineCache()) {
                        DrawTriggerVolumeStaticOutline(box, cameraPos, color, strokeWidth, boxIndex);
                        return;
                    }

                    DrawGroupedTriggerVolumeOutline(box, cameraPos, color, strokeWidth, boxIndex);
                    return;
                }

                if (box.HasStaticOutlineCache()) {
                    DrawTriggerVolumeStaticOutline(box, cameraPos, color, strokeWidth, boxIndex);
                    return;
                }

                if (box !is null && box.HasCustomOutlineGeometry()) {
                    DrawTriggerVolumeCustomOutline(box, cameraPos, color, strokeWidth, boxIndex);
                    return;
                }

                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return;

                bool prioritizeEdges = ShouldPrioritizeWorldOutlineEdgesForBudget(
                    box,
                    TRIGGER_VOLUME_EDGE_INDICES.Length
                );
                array<WorldOutlineEdgeDrawItem@> @items = null;
                if (prioritizeEdges) {
                    @items = array<WorldOutlineEdgeDrawItem@>();
                    for (uint i = 0; i < TRIGGER_VOLUME_EDGE_INDICES.Length; i++) {
                        auto edge = TRIGGER_VOLUME_EDGE_INDICES[i];
                        items.InsertLast(WorldOutlineEdgeDrawItem(corners[edge[0]], corners[edge[1]], boxIndex, i));
                    }
                    PrepareWorldOutlineEdgeDrawItemsForCameraPriority(items, cameraPos);
                }
                nvg::Reset();
                nvg::StrokeWidth(Math::Clamp(strokeWidth, 0.5f, 16.0f));
                uint drawCount = TRIGGER_VOLUME_EDGE_INDICES.Length;
                if (prioritizeEdges) drawCount = items.Length;
                for (uint i = 0; i < drawCount; i++) {
                    if (!HasWorldLineSegmentBudgetForVolume(box)) break;
                    auto edge = TRIGGER_VOLUME_EDGE_INDICES[i];
                    vec3 start = corners[edge[0]];
                    vec3 end = corners[edge[1]];
                    uint edgeIndex = i;
                    if (prioritizeEdges) {
                        start = items[i].Start;
                        end = items[i].End;
                        edgeIndex = items[i].EdgeIndex;
                    }
                    DrawWorldLineAdaptiveColoredForVolume(
                        start,
                        end,
                        cameraPos,
                        color,
                        boxIndex,
                        edgeIndex,
                        box,
                        ShouldSplitTriggerVolumeOutlineEdges(box)
                    );
                }
            }
        }
    }
}
