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
            bool G_FastDrivingPerformanceModeActive = false;
            WorldFrustumState G_WorldFrustumState;

            bool IsFastDrivingPerformanceModeActive() {
                return G_FastDrivingPerformanceModeActive;
            }

            bool ShouldUseFastDrivingPerformanceMode(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                if (!TriggerVisualizer::Trigger::UI::S_FastDrivingPerformanceMode) return false;
                if (ctx is null || (!ctx.IsPlayableMap && !ctx.IsEditorTestMode)) return false;
                if (proximityState is null || !proximityState.HasVehicleSpeed) return false;
                return proximityState.VehicleSpeedKmh >= TriggerVisualizer::Trigger::UI::S_FastDrivingSpeedThresholdKmh;
            }

            int GetEffectiveMaxFillTilesPerFrame() {
                if (IsFastDrivingPerformanceModeActive()) {
                    return Math::Max(TriggerVisualizer::Trigger::UI::S_FastDrivingMaxFillTilesPerFrame, 0);
                }
                return Math::Max(TriggerVisualizer::Trigger::UI::S_MaxFillTilesPerFrame, 1);
            }

            int GetEffectiveMaxOutlineSegmentsPerFrame() {
                if (IsFastDrivingPerformanceModeActive()) {
                    return Math::Max(TriggerVisualizer::Trigger::UI::S_FastDrivingMaxOutlineSegmentsPerFrame, 0);
                }
                return Math::Max(TriggerVisualizer::Trigger::UI::S_MaxOutlineSegmentsPerFrame, 1);
            }

            int GetEffectiveMaxTileIconPatchesPerFrame() {
                if (IsFastDrivingPerformanceModeActive() && TriggerVisualizer::Trigger::UI::S_FastDrivingDisableTileIcons) {
                    return 0;
                }
                return Math::Max(TriggerVisualizer::Trigger::UI::S_MaxTileIconPatchesPerFrame, 0);
            }

            bool ShouldRenderWorldFillNow() {
                return TriggerVisualizer::Trigger::UI::S_ShowFill
                    && !(IsFastDrivingPerformanceModeActive() && TriggerVisualizer::Trigger::UI::S_FastDrivingDisableFill);
            }

            bool ShouldRenderWorldLabelsNow() {
                return TriggerVisualizer::Trigger::UI::S_ShowLabels
                    && !(IsFastDrivingPerformanceModeActive() && TriggerVisualizer::Trigger::UI::S_FastDrivingDisableLabels);
            }

            bool ShouldRenderWorldTileIconsNow() {
                return TriggerVisualizer::Trigger::UI::S_ShowSkullTileIcons
                    && !(IsFastDrivingPerformanceModeActive() && TriggerVisualizer::Trigger::UI::S_FastDrivingDisableTileIcons);
            }

            bool ShouldSimplifyGroupedTriggersNow() {
                return IsFastDrivingPerformanceModeActive()
                    && TriggerVisualizer::Trigger::UI::S_FastDrivingSimplifyGroupedTriggers;
            }

            void ResetWorldRenderPerformanceBudgets() {
                int maxFillTiles = GetEffectiveMaxFillTilesPerFrame();
                int maxOutlineSegments = GetEffectiveMaxOutlineSegmentsPerFrame();
                G_TileIconPatchBudgetRemaining = uint(GetEffectiveMaxTileIconPatchesPerFrame());
                G_FillTileTraversalBudgetRemaining = maxFillTiles <= 0
                    ? 0
                    : uint(Math::Clamp(maxFillTiles * 4, 256, int(FILL_TILE_TRAVERSAL_BUDGET_HARD_MAX)));
                G_WorldLineSegmentBudgetRemaining = maxOutlineSegments <= 0
                    ? 0
                    : uint(Math::Clamp(maxOutlineSegments, 32, int(WORLD_LINE_SEGMENT_BUDGET_HARD_MAX)));
                UpdateWorldFrustumState();
            }

            bool ConsumeWorldFillTileTraversalBudget() {
                if (G_FillTileTraversalBudgetRemaining == 0) return false;
                G_FillTileTraversalBudgetRemaining--;
                return true;
            }

            bool ConsumeWorldLineSegmentBudget() {
                if (G_WorldLineSegmentBudgetRemaining == 0) return false;
                G_WorldLineSegmentBudgetRemaining--;
                return true;
            }

            int GetWorldFillTileCoordKey(float value) {
                float scaled = value * 1000.0f;
                if (scaled >= 0.0f) return int(Math::Floor(scaled + 0.5f));
                return int(Math::Ceil(scaled - 0.5f));
            }

            string GetWorldFillTilePointKey(const vec3 &in point) {
                return tostring(GetWorldFillTileCoordKey(point.x))
                    + "," + tostring(GetWorldFillTileCoordKey(point.y))
                    + "," + tostring(GetWorldFillTileCoordKey(point.z));
            }

            void SortWorldFillTileCornerKeys(array<string> @keys) {
                if (keys is null || keys.Length <= 1) return;

                for (uint i = 1; i < keys.Length; i++) {
                    string key = keys[i];
                    uint j = i;
                    while (j > 0 && keys[j - 1] > key) {
                        keys[j] = keys[j - 1];
                        j--;
                    }
                    keys[j] = key;
                }
            }

            string GetWorldFillTileGeometryKey(const vec3 &in origin, const vec3 &in uEdge, const vec3 &in vEdge) {
                auto keys = array<string>();
                keys.InsertLast(GetWorldFillTilePointKey(origin));
                keys.InsertLast(GetWorldFillTilePointKey(origin + uEdge));
                keys.InsertLast(GetWorldFillTilePointKey(origin + uEdge + vEdge));
                keys.InsertLast(GetWorldFillTilePointKey(origin + vEdge));
                SortWorldFillTileCornerKeys(keys);
                return keys[0] + "|" + keys[1] + "|" + keys[2] + "|" + keys[3];
            }

            class WorldFillTileDrawItem {
                vec3 Origin;
                vec3 UEdge;
                vec3 VEdge;
                vec4 Color;
                string GeometryKey;
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

            class WorldOutlineEdgeDrawItem {
                vec3 Start;
                vec3 End;
                uint BoxIndex = 0;
                uint EdgeIndex = 0;
                string GeometryKey;

                WorldOutlineEdgeDrawItem() { }

                WorldOutlineEdgeDrawItem(
                    const vec3 &in start,
                    const vec3 &in end,
                    uint boxIndex,
                    uint edgeIndex
                ) {
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
                string a = GetWorldFillTilePointKey(start);
                string b = GetWorldFillTilePointKey(end);
                return a < b ? a + "|" + b : b + "|" + a;
            }

            int FindStringIndex(const array<string> @keys, const string &in key) {
                if (keys is null) return -1;
                for (uint i = 0; i < keys.Length; i++) {
                    if (keys[i] == key) return int(i);
                }
                return -1;
            }

            void AddGeometryKeyCount(array<string> @keys, array<uint> @counts, const string &in key) {
                if (keys is null || counts is null || key.Length == 0) return;

                int index = FindStringIndex(keys, key);
                if (index < 0) {
                    keys.InsertLast(key);
                    counts.InsertLast(1);
                    return;
                }

                counts[uint(index)]++;
            }

            uint GetGeometryKeyCount(const array<string> @keys, const array<uint> @counts, const string &in key) {
                if (keys is null || counts is null) return 0;

                int index = FindStringIndex(keys, key);
                if (index < 0 || uint(index) >= counts.Length) return 0;
                return counts[uint(index)];
            }

            vec4 LerpColor(const vec4 &in from, const vec4 &in to, float factor) {
                factor = Math::Clamp(factor, 0.0f, 1.0f);
                return Math::Lerp(from, to, factor);
            }

            float StableRandom01(float seed) {
                float value = Math::Sin(seed * 12.9898f + 78.233f) * 43758.5453f;
                return value - Math::Floor(value);
            }

            vec4 StableRandomColor(float seed, float alpha) {
                float h = StableRandom01(seed);
                float s = 0.65f + StableRandom01(seed + 17.0f) * 0.25f;
                float v = 0.85f + StableRandom01(seed + 31.0f) * 0.15f;

                float r = Math::Clamp(Math::Abs(h * 6.0f - 3.0f) - 1.0f, 0.0f, 1.0f);
                float g = Math::Clamp(2.0f - Math::Abs(h * 6.0f - 2.0f), 0.0f, 1.0f);
                float b = Math::Clamp(2.0f - Math::Abs(h * 6.0f - 4.0f), 0.0f, 1.0f);

                r = (1.0f + (r - 1.0f) * s) * v;
                g = (1.0f + (g - 1.0f) * s) * v;
                b = (1.0f + (b - 1.0f) * s) * v;
                return vec4(r, g, b, alpha);
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
                return Math::Clamp(TriggerVisualizer::Trigger::UI::S_FillTileMinSize, 2.0f, 64.0f);
            }

            float GetTriggerVolumeLineSplitDensityFactor(const TriggerVolume@ box, const vec3 &in cameraPos) {
                if (IsFastDrivingPerformanceModeActive()) return 0.0f;
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

            vec4 GetColorModeColor(const TriggerVolume@ box, const vec3 &in cameraPos, float fade) {
                int colorMode = TriggerVisualizer::Trigger::UI::S_ColorMode;
                vec4 color = TriggerVisualizer::Trigger::UI::S_BaseTriggerColor;

                if (colorMode == TriggerVisualizer::Trigger::UI::COLOR_MODE_DISTANCE_FADE) {
                    color = LerpColor(
                        color,
                        TriggerVisualizer::Trigger::UI::S_DistanceFadeColor,
                        1.0f - Math::Clamp(fade, 0.0f, 1.0f)
                    );
                } else if (colorMode == TriggerVisualizer::Trigger::UI::COLOR_MODE_LINE_SPLIT_DENSITY) {
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
                if (box !is null && box.HasChildVolumes() && !ShouldSimplifyGroupedTriggersNow()) {
                    float groupFade = 0.0f;
                    for (uint i = 0; i < box.ChildVolumes.Length; i++) {
                        groupFade = Math::Max(groupFade, GetTriggerVolumeFadeFactor(box.ChildVolumes[i], cameraPos));
                    }
                    return groupFade;
                }

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
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                int proximityMode = TriggerVisualizer::Trigger::UI::GetRenderProximityModeForRuntime(GetCurrentRuntimeContext());
                float cameraFade = GetTriggerVolumeFadeFactor(box, cameraPos);
                float vehicleFade = GetVehicleTriggerVolumeFadeFactor(box, proximityState);
                float orbitalFade = GetOrbitalTriggerVolumeFadeFactor(box, proximityState);

                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_VEHICLE_ONLY) {
                    return proximityState !is null && proximityState.HasVehiclePosition ? vehicleFade : cameraFade;
                }

                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_AND_VEHICLE) {
                    return Math::Max(cameraFade, vehicleFade);
                }

                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_ORBITAL_ONLY) {
                    return proximityState !is null && proximityState.HasOrbitalPoint ? orbitalFade : cameraFade;
                }

                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_AND_ORBITAL) {
                    return Math::Max(cameraFade, orbitalFade);
                }

                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_VEHICLE_AND_ORBITAL) {
                    float combinedFade = Math::Max(vehicleFade, orbitalFade);
                    return(proximityState !is null && (proximityState.HasVehiclePosition || proximityState.HasOrbitalPoint)) ? combinedFade : cameraFade;
                }

                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_VEHICLE_AND_ORBITAL) {
                    return Math::Max(cameraFade, Math::Max(vehicleFade, orbitalFade));
                }

                return cameraFade;
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
                return (!IsFastDrivingPerformanceModeActive() && TriggerVisualizer::Trigger::UI::S_AdaptiveLineSplitting)
                    || ShouldRenderWorldTileIconsNow()
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
                    AddGeometryKeyCount(keys, counts, GetTriggerVolumeFaceGeometryKey(corners, TRIGGER_VOLUME_FACE_INDICES[i]));
                }
            }

            bool IsDuplicateGroupFaceGeometry(
                const array<vec3> @corners,
                const uint[]@ face,
                const array<string> @faceKeys,
                const array<uint> @faceCounts
            ) {
                return GetGeometryKeyCount(faceKeys, faceCounts, GetTriggerVolumeFaceGeometryKey(corners, face)) > 1;
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
                        item.AllowTileIcon = false;
                        if (!UpdateWorldFillTileScreenProjection(item)) continue;

                        items.InsertLast(item);
                    }
                    return;
                }

                if (!ShouldRenderTriggerVolumeFillTiles(box)) return;
                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return;
                if (color.w <= 0.001f && !ShouldRenderWorldTileIconsNow()) return;

                for (uint i = 0; i < TRIGGER_VOLUME_FACE_INDICES.Length; i++) {
                    auto face = TRIGGER_VOLUME_FACE_INDICES[i];
                    if (IsDuplicateGroupFaceGeometry(corners, face, hiddenFaceKeys, hiddenFaceCounts)) continue;
                    if (!IsTriggerVolumeFaceCameraFacing(corners, face, i, cameraPos)) continue;
                    CollectAdaptiveWorldFaceFillDrawItems(items, corners, face, cameraPos, color, boxIndex, i);
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
                if (box !is null && box.HasChildVolumes()) {
                    if (ShouldSimplifyGroupedTriggersNow()) {
                        auto simplifiedBox = TriggerVisualizer::Trigger::Data::CloneTriggerVolumeForMerge(box);
                        CollectTriggerVolumeFillDrawItems(
                            simplifiedBox,
                            cameraPos,
                            color,
                            boxIndex,
                            items
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
                if (color.w <= 0.001f && !ShouldRenderWorldTileIconsNow()) return;

                for (uint i = 0; i < TRIGGER_VOLUME_FACE_INDICES.Length; i++) {
                    auto face = TRIGGER_VOLUME_FACE_INDICES[i];
                    if (!IsTriggerVolumeFaceCameraFacing(corners, face, i, cameraPos)) continue;
                    CollectAdaptiveWorldFaceFillDrawItems(items, corners, face, cameraPos, color, boxIndex, i);
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
                    AddGeometryKeyCount(edgeKeys, edgeCounts, item.GeometryKey);
                }
            }

            void DrawGroupedTriggerVolumeOutline(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                float strokeWidth,
                uint boxIndex
            ) {
                auto items = array<WorldOutlineEdgeDrawItem@>();
                auto edgeKeys = array<string>();
                auto edgeCounts = array<uint>();
                CollectTriggerVolumeOutlineEdgeDrawItems(box, boxIndex, items, edgeKeys, edgeCounts);
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
                        items[i].EdgeIndex
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
                if (box !is null && box.HasChildVolumes()) {
                    if (ShouldSimplifyGroupedTriggersNow()) {
                        auto simplifiedBox = TriggerVisualizer::Trigger::Data::CloneTriggerVolumeForMerge(box);
                        DrawTriggerVolumeOutline(
                            simplifiedBox,
                            cameraPos,
                            color,
                            strokeWidth,
                            boxIndex
                        );
                        return;
                    }

                    DrawGroupedTriggerVolumeOutline(box, cameraPos, color, strokeWidth, boxIndex);
                    return;
                }

                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return;

                nvg::Reset();
                nvg::StrokeWidth(Math::Clamp(strokeWidth, 0.5f, 16.0f));

                for (uint i = 0; i < TRIGGER_VOLUME_EDGE_INDICES.Length; i++) {
                    auto edge = TRIGGER_VOLUME_EDGE_INDICES[i];
                    DrawWorldLineAdaptiveColored(corners[edge[0]], corners[edge[1]], cameraPos, color, boxIndex, i);
                }
            }
        }
    }
}
