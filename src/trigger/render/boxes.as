namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            const float MIN_VISIBLE_FADE = 0.001f;
            const float FILL_TILE_SPLIT_DISTANCE_FACTOR = 0.75f;
            const uint FILL_TILE_MAX_DEPTH = 8;
            const uint FILL_TILE_MAX_TILES_PER_FACE = 512;
            const int FILL_TILE_FRAME_SAFETY_LIMIT = 65536;
            const float FILL_TILE_MIN_SIZE = 4.0f;
            const float SCREEN_QUAD_VISIBILITY_MARGIN = 128.0f;
            const float SKULL_TILE_ICON_MIN_SCREEN_SIZE = 2.0f;
            const float SKULL_TILE_ICON_TARGET_PATCH_SCREEN_SIZE = 40.0f;
            const float SKULL_TILE_ICON_TARGET_PATCH_PERSPECTIVE_ERROR = 2.0f;
            const int SKULL_TILE_ICON_MAX_SUBDIVISIONS = 6;
            const uint LINE_FRUSTUM_MAX_DEPTH = 12;
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

            bool g_SpeedRenderSkipActive = false;
            WorldFrustumState g_WorldFrustumState;

            bool IsSpeedRenderSkipRuntimeEligible(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                return TriggerVisualizer::Trigger::Ui::S_FastDrivingPerformanceMode
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
                return speedKmh >= TriggerVisualizer::Trigger::Ui::GetFastDrivingForwardSpeedThresholdKmh()
                    || speedKmh <= TriggerVisualizer::Trigger::Ui::GetFastDrivingReverseSpeedThresholdKmh();
            }

            bool IsSpeedRenderSkipActiveForSpeed(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                if (!CanUseSpeedRenderSkip(ctx, proximityState)) return false;
                return SpeedIsPastRenderSkipThreshold(proximityState.VehicleSpeedKmh);
            }

            bool IsSpeedRenderSkipActive() {
                return g_SpeedRenderSkipActive;
            }

            bool UpdateSpeedRenderSkipActiveForSpeed(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                g_SpeedRenderSkipActive = IsSpeedRenderSkipActiveForSpeed(ctx, proximityState);
                return g_SpeedRenderSkipActive;
            }

            bool ShouldSkipWorldRenderForSpeed(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                return g_SpeedRenderSkipActive
                    && IsSpeedRenderSkipRuntimeEligible(ctx)
                    && TriggerVisualizer::Trigger::Ui::ShouldSpeedRenderSkipHideAllRuntimeSources(ctx);
            }

            bool ShouldSkipTriggerVolumeForSpeed(
                const TriggerVolume@ volume,
                bool speedRenderSkipActive
            ) {
                return speedRenderSkipActive
                    && volume !is null
                    && !TriggerVisualizer::Trigger::Ui::ShouldSpeedRenderKeepVolume(volume);
            }

            int GetFillTileFrameSafetyLimit() {
                return FILL_TILE_FRAME_SAFETY_LIMIT;
            }

            bool ShouldRenderWorldFillNow() {
                return TriggerVisualizer::Trigger::Ui::S_ShowFill;
            }

            bool ShouldRenderWorldLabelsNow() {
                return TriggerVisualizer::Trigger::Ui::S_ShowLabels;
            }

            bool ShouldRenderWorldTileIconsNow() {
                return TriggerVisualizer::Trigger::Ui::S_ShowSkullTileIcons;
            }

            bool ShouldRepeatTileIconsOnSplitFillTilesNow() {
                return ShouldRenderWorldTileIconsNow()
                    && TriggerVisualizer::Trigger::Ui::S_RepeatTileIconsOnSplitFillTiles;
            }

            bool ShouldCollectTileIconsSeparatelyNow() {
                return ShouldRenderWorldTileIconsNow()
                    && !TriggerVisualizer::Trigger::Ui::S_RepeatTileIconsOnSplitFillTiles;
            }

            void PrepareWorldRenderFrame() {
                UpdateWorldFrustumState();
            }

            bool ShouldSplitTriggerVolumeOutlineEdges(const TriggerVolume@ box) {
                return box is null || box.Source != TRIGGER_SOURCE_CRYSTAL;
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
                uint SortOrder = 0;
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
                uint SortOrder = 0;
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
                uint BoxIndex = 0;
                uint EdgeIndex = 0;
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

            void AddGeometryKeyCount(array<string> @keys, array<uint> @counts, const string &in key) {
                TriggerVisualizer::Trigger::AddTriggerGeometryKeyCount(keys, counts, key);
            }

            uint GetGeometryKeyCount(const array<string> @keys, const array<uint> @counts, const string &in key) {
                return TriggerVisualizer::Trigger::GetTriggerGeometryKeyCount(keys, counts, key);
            }

            bool RenderPriorityModeUsesCamera(int mode) {
                return mode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_CAMERA_ONLY
                    || mode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_CAMERA_AND_VEHICLE
                    || mode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_CAMERA_AND_ORBITAL
                    || mode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_CAMERA_VEHICLE_AND_ORBITAL;
            }

            bool RenderPriorityModeUsesVehicle(int mode) {
                return mode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_VEHICLE_ONLY
                    || mode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_CAMERA_AND_VEHICLE
                    || mode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_VEHICLE_AND_ORBITAL
                    || mode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_CAMERA_VEHICLE_AND_ORBITAL;
            }

            bool RenderPriorityModeUsesOrbital(int mode) {
                return mode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_ORBITAL_ONLY
                    || mode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_CAMERA_AND_ORBITAL
                    || mode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_VEHICLE_AND_ORBITAL
                    || mode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_CAMERA_VEHICLE_AND_ORBITAL;
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

            vec4 ShiftColorHue(const vec4 &in color, float hueShift) {
                vec3 hsv = UI::ToHSV(color.x, color.y, color.z);
                vec4 shifted = UI::HSV(Wrap01(hsv.x + hueShift), hsv.y, hsv.z);
                shifted.w = color.w;
                return shifted;
            }

            float StableRandom01(float seed) {
                float value = Math::Sin(seed * 12.9898f + 78.233f) * 43758.5453f;
                return value - Math::Floor(value);
            }

            vec4 StableRandomColor(float seed, float alpha) {
                float h = StableRandom01(seed);
                float s = 0.65f + StableRandom01(seed + 17.0f) * 0.25f;
                float v = 0.85f + StableRandom01(seed + 31.0f) * 0.15f;
                vec4 color = UI::HSV(h, s, v);
                color.w = alpha;
                return color;
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
                if (!TriggerVisualizer::Trigger::Ui::S_RandomOutlineSegmentColors) return baseColor;
                return StableRandomColor(GetOutlineSegmentColorSeed(boxIndex, edgeIndex, segmentIndex), baseColor.w);
            }

            vec4 GetFillTileColor(const vec4 &in baseColor, float tileSeed) {
                if (!TriggerVisualizer::Trigger::Ui::S_RandomFillTileColors) return baseColor;
                return StableRandomColor(tileSeed, baseColor.w);
            }

            float GetFillTileMinSize() {
                return FILL_TILE_MIN_SIZE;
            }

            float GetTriggerVolumeLineSplitDensityFactor(const TriggerVolume@ box, const vec3 &in cameraPos) {
                if (!TriggerVisualizer::Trigger::Ui::S_AdaptiveLineSplitting) return 0.0f;

                int maxAllowedSegments = Math::Max(TriggerVisualizer::Trigger::Ui::S_LineSplitMaxSegmentsPerEdge, 1);
                if (maxAllowedSegments <= 1) return 0.0f;

                uint maxEdgeSegments = GetMaxTriggerVolumeOutlineEdgeSegments(box, cameraPos);
                return Math::Clamp(
                    float(Math::Max(int(maxEdgeSegments), 1) - 1) / float(maxAllowedSegments - 1),
                    0.0f,
                    1.0f
                );
            }

            int GetTurboRouletteColorPhase() {
                int yellowMs = Math::Max(TriggerVisualizer::Trigger::Ui::S_TurboRouletteYellowDurationMs, 50);
                int cyanMs = Math::Max(TriggerVisualizer::Trigger::Ui::S_TurboRouletteCyanDurationMs, 50);
                int purpleMs = Math::Max(TriggerVisualizer::Trigger::Ui::S_TurboRoulettePurpleDurationMs, 50);
                int cycleMs = yellowMs + cyanMs + purpleMs;
                int phaseMs = int(Time::Now % uint64(cycleMs)) + TriggerVisualizer::Trigger::Ui::S_TurboRoulettePhaseOffsetMs;
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
                return TriggerVisualizer::Trigger::Ui::S_AnimateTurboRouletteColor
                    && TriggerVisualizer::Trigger::TriggerVolumeIsTurboRoulette(box);
            }

            vec4 GetColorModeColor(const TriggerVolume@ box, const vec3 &in cameraPos, float fade) {
                vec4 color = TriggerVisualizer::Trigger::Ui::S_BaseTriggerColor;
                int colorSource = TriggerVisualizer::Trigger::Ui::S_ColorSource;
                if (colorSource != TriggerVisualizer::Trigger::Ui::COLOR_SOURCE_UNIFORM && box !is null && box.HasTriggerTypeColor) {
                    color = box.TriggerTypeColor;
                }
                if (colorSource != TriggerVisualizer::Trigger::Ui::COLOR_SOURCE_UNIFORM && ShouldUseAnimatedTurboRouletteColor(box)) {
                    color = GetTurboRouletteRenderColor();
                }
                if (colorSource == TriggerVisualizer::Trigger::Ui::COLOR_SOURCE_MEDIATRACKER_TRACK_COLORS && box !is null && box.Source == TRIGGER_SOURCE_MEDIATRACKER && box.HasMediaTrackerTrackColor) {
                    color = box.MediaTrackerTrackColor;
                }
                if (TriggerVisualizer::Trigger::Ui::S_EnableDistanceFadeColor) {
                    color = LerpColor(
                        color,
                        TriggerVisualizer::Trigger::Ui::S_DistanceFadeColor,
                        1.0f - Math::Clamp(fade, 0.0f, 1.0f)
                    );
                }
                if (TriggerVisualizer::Trigger::Ui::S_EnableLineSplitDensityColor) {
                    color = LerpColor(
                        color,
                        TriggerVisualizer::Trigger::Ui::S_DenseLineSplitColor,
                        GetTriggerVolumeLineSplitDensityFactor(box, cameraPos)
                    );
                }

                return color;
            }

            vec4 GetOutlineColor(const TriggerVolume@ box, const vec3 &in cameraPos, float fade) {
                vec4 color = GetColorModeColor(box, cameraPos, fade);
                if (TriggerVisualizer::Trigger::Ui::S_ColorSource == TriggerVisualizer::Trigger::Ui::COLOR_SOURCE_MEDIATRACKER_TRACK_COLORS && box !is null && box.Source == TRIGGER_SOURCE_MEDIATRACKER && box.HasMediaTrackerTrackColor) {
                    color = ShiftColorHue(color, TriggerVisualizer::Trigger::Ui::S_MediaTrackerTrackOutlineHueShift);
                }
                color.w *= TriggerVisualizer::Trigger::Ui::S_OutlineAlpha * Math::Clamp(fade, 0.0f, 1.0f);
                return color;
            }

            vec4 GetFillColor(const TriggerVolume@ box, const vec3 &in cameraPos, float fade) {
                vec4 color = GetColorModeColor(box, cameraPos, fade);
                color.w *= TriggerVisualizer::Trigger::Ui::S_FillAlpha * Math::Clamp(fade, 0.0f, 1.0f);
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
                return outside.LengthSquared();
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
                int mode = TriggerVisualizer::Trigger::Ui::GetRenderProximityModeForRuntime(GetCurrentRuntimeContext());
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
                return 1.0f - Math::InvLerp(fadeStart, renderDistance, axisDistance);
            }

            float GetTriggerVolumeFadeFactor(const TriggerVolume@ box, const vec3 &in cameraPos) {
                vec3 renderDistance = GetEffectiveRenderDistanceWorld();
                vec3 fadeBand = TriggerVisualizer::Trigger::Ui::GetRenderFadeBandWorld();
                vec3 outside = GetDistanceOutsideTriggerVolume(box, cameraPos);
                float fx = GetAxisFadeFactor(outside.x, renderDistance.x, fadeBand.x);
                float fy = GetAxisFadeFactor(outside.y, renderDistance.y, fadeBand.y);
                float fz = GetAxisFadeFactor(outside.z, renderDistance.z, fadeBand.z);
                return Math::Min(fx, Math::Min(fy, fz));
            }

            bool IsVisibleFadeFactor(float fade) {
                return fade > MIN_VISIBLE_FADE;
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
                if (proximityMode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_VEHICLE_ONLY) {
                    float vehicleFade = GetVehicleTriggerVolumeFadeFactor(box, proximityState);
                    return proximityState !is null && proximityState.HasVehiclePosition ? vehicleFade : cameraFade;
                }

                if (proximityMode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_CAMERA_AND_VEHICLE) {
                    float vehicleFade = GetVehicleTriggerVolumeFadeFactor(box, proximityState);
                    return Math::Max(cameraFade, vehicleFade);
                }

                if (proximityMode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_ORBITAL_ONLY) {
                    float orbitalFade = GetOrbitalTriggerVolumeFadeFactor(box, proximityState);
                    return proximityState !is null && proximityState.HasOrbitalPoint ? orbitalFade : cameraFade;
                }

                if (proximityMode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_CAMERA_AND_ORBITAL) {
                    float orbitalFade = GetOrbitalTriggerVolumeFadeFactor(box, proximityState);
                    return Math::Max(cameraFade, orbitalFade);
                }

                if (proximityMode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_VEHICLE_AND_ORBITAL) {
                    float vehicleFade = GetVehicleTriggerVolumeFadeFactor(box, proximityState);
                    float orbitalFade = GetOrbitalTriggerVolumeFadeFactor(box, proximityState);
                    float combinedFade = Math::Max(vehicleFade, orbitalFade);
                    return(proximityState !is null && (proximityState.HasVehiclePosition || proximityState.HasOrbitalPoint)) ? combinedFade : cameraFade;
                }

                if (proximityMode == TriggerVisualizer::Trigger::Ui::PROXIMITY_MODE_CAMERA_VEHICLE_AND_ORBITAL) {
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
                int proximityMode = TriggerVisualizer::Trigger::Ui::GetRenderProximityModeForRuntime(GetCurrentRuntimeContext());
                return GetTriggerVolumeRenderFadeFactor(box, cameraPos, proximityState, proximityMode);
            }

            bool IsTriggerVolumeInRenderRangeForProximity(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                return IsVisibleFadeFactor(GetTriggerVolumeRenderFadeFactor(box, cameraPos, proximityState));
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

            bool ShouldRenderTriggerVolumeFillTiles(const TriggerVolume@ box) {
                if (box is null) return false;
                return TriggerVisualizer::Trigger::Ui::S_AdaptiveLineSplitting
                    || ShouldRepeatTileIconsOnSplitFillTilesNow()
                    || TriggerVisualizer::Trigger::Ui::S_RandomFillTileColors;
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

                int maxFrameTiles = GetFillTileFrameSafetyLimit();
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
                int maxFrameTiles = GetFillTileFrameSafetyLimit();
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
                int maxFrameTiles = GetFillTileFrameSafetyLimit();
                if (int(items.Length) >= maxFrameTiles) return;
                if (box !is null && box.HasCustomOutlineGeometry()) return;
                if (box !is null && box.HasChildVolumes()) {
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
                    nvg::Reset();
                    nvg::StrokeWidth(Math::Clamp(strokeWidth, 0.5f, 16.0f));

                    for (uint i = 0; i < items.Length; i++) {
                        if (items[i] is null) continue;
                        if (GetGeometryKeyCount(edgeKeys, edgeCounts, items[i].GeometryKey) > 1) continue;

                        DrawWorldLineAdaptiveColored(
                            items[i].Start,
                            items[i].End,
                            cameraPos,
                            color,
                            items[i].BoxIndex,
                            items[i].EdgeIndex,
                            ShouldSplitTriggerVolumeOutlineEdges(box)
                        );
                    }
                    return;
                }

                uint cachedEdgeCount = box.CachedGroupOutlineEdgeCount();
                if (cachedEdgeCount == 0) return;

                nvg::Reset();
                nvg::StrokeWidth(Math::Clamp(strokeWidth, 0.5f, 16.0f));

                for (uint i = 0; i < cachedEdgeCount; i++) {
                    if (IsCachedGroupOutlineEdgeDuplicate(box, i)) continue;

                    DrawWorldLineAdaptiveColored(
                        box.CachedGroupOutlineEdgeStarts[i],
                        box.CachedGroupOutlineEdgeEnds[i],
                        cameraPos,
                        color,
                        boxIndex + box.CachedGroupOutlineEdgeBoxIndices[i],
                        box.CachedGroupOutlineEdgeIndices[i],
                        ShouldSplitTriggerVolumeOutlineEdges(box)
                    );
                }
            }

            bool CanBatchTriggerVolumeStaticOutline(const TriggerVolume@ box) {
                if (box is null || !box.HasStaticOutlineCache()) return false;
                return !TriggerVisualizer::Trigger::Ui::S_RandomOutlineSegmentColors;
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

                nvg::Reset();
                nvg::StrokeWidth(Math::Clamp(strokeWidth, 0.5f, 16.0f));
                bool allowAdaptiveSplitting = ShouldSplitTriggerVolumeOutlineEdges(box);
                if (CanBatchTriggerVolumeStaticOutline(box)) {
                    nvg::BeginPath();
                    nvg::StrokeColor(color);
                    bool drewAny = false;
                    for (uint i = 0; i < count; i++) {
                        drewAny = DrawWorldLineAdaptiveToCurrentPath(
                            box.CachedStaticOutlineStarts[i],
                            box.CachedStaticOutlineEnds[i],
                            cameraPos,
                            allowAdaptiveSplitting
                        ) || drewAny;
                    }
                    if (drewAny) {
                        nvg::Stroke();
                    }
                    nvg::ClosePath();
                    return;
                }

                for (uint i = 0; i < count; i++) {
                    DrawWorldLineAdaptiveColored(
                        box.CachedStaticOutlineStarts[i],
                        box.CachedStaticOutlineEnds[i],
                        cameraPos,
                        color,
                        boxIndex + box.CachedStaticOutlineBoxIndices[i],
                        box.CachedStaticOutlineEdgeIndices[i],
                        allowAdaptiveSplitting
                    );
                }
            }

            bool CanBatchTriggerVolumeCustomOutline(const TriggerVolume@ box) {
                if (box is null || !box.HasCustomOutlineGeometry()) return false;
                return !TriggerVisualizer::Trigger::Ui::S_RandomOutlineSegmentColors;
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

                if (CanBatchTriggerVolumeCustomOutline(box)) {
                    nvg::BeginPath();
                    nvg::StrokeColor(color);
                    bool drewAny = false;
                    for (uint i = 0; i < outlineLineCount; i++) {
                        drewAny = DrawWorldLineAdaptiveToCurrentPath(
                            box.OutlineLineStarts[i],
                            box.OutlineLineEnds[i],
                            cameraPos,
                            allowAdaptiveSplitting
                        ) || drewAny;
                    }
                    if (drewAny) {
                        nvg::Stroke();
                    }
                    nvg::ClosePath();
                    return;
                }

                for (uint i = 0; i < outlineLineCount; i++) {
                    DrawWorldLineAdaptiveColored(
                        box.OutlineLineStarts[i],
                        box.OutlineLineEnds[i],
                        cameraPos,
                        color,
                        boxIndex,
                        i,
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

                nvg::Reset();
                nvg::StrokeWidth(Math::Clamp(strokeWidth, 0.5f, 16.0f));
                for (uint i = 0; i < TRIGGER_VOLUME_EDGE_INDICES.Length; i++) {
                    auto edge = TRIGGER_VOLUME_EDGE_INDICES[i];
                    DrawWorldLineAdaptiveColored(
                        corners[edge[0]],
                        corners[edge[1]],
                        cameraPos,
                        color,
                        boxIndex,
                        i,
                        ShouldSplitTriggerVolumeOutlineEdges(box)
                    );
                }
            }
        }
    }
}
