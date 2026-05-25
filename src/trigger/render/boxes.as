namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            const float MIN_VISIBLE_FADE = 0.001f;
            const float FILL_TILE_SPLIT_DISTANCE_FACTOR = 0.75f;
            const uint FILL_TILE_MAX_DEPTH = 10;
            const uint FILL_TILE_MAX_TILES_PER_FACE = 2048;
            const float SCREEN_QUAD_VISIBILITY_MARGIN = 128.0f;
            const float SKULL_TILE_ICON_MIN_SCREEN_SIZE = 2.0f;
            const float SKULL_TILE_ICON_TARGET_PATCH_SCREEN_SIZE = 40.0f;
            const float SKULL_TILE_ICON_TARGET_PATCH_PERSPECTIVE_ERROR = 2.0f;
            const uint SKULL_TILE_ICON_HARD_MAX_SUBDIVISIONS = 12;
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

            uint G_TileIconPatchBudgetRemaining = 1600;
            WorldFrustumState G_WorldFrustumState;

            void ResetWorldRenderPerformanceBudgets() {
                G_TileIconPatchBudgetRemaining = uint(Math::Max(
                    TriggerVisualizer::Trigger::UI::S_MaxTileIconPatchesPerFrame,
                    0
                ));
                UpdateWorldFrustumState();
            }

            class WorldFillTileDrawItem {
                vec3 Origin;
                vec3 UEdge;
                vec3 VEdge;
                vec4 Color;
                float TileSeed = 0.0f;
                float SortDistanceSq = 0.0f;
                bool Occluded = false;
                bool HasScreenProjection = false;
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

            float GetPlayerTriggerVolumeFadeFactor(
                const TriggerVolume@ box,
                const TriggerVisualizer::Trigger::Data::PlayerPositionState@ playerState
            ) {
                if (playerState is null || !playerState.HasVehicle) return 0.0f;
                return GetTriggerVolumeFadeFactor(box, playerState.Position);
            }

            float GetTriggerVolumeRenderFadeFactor(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::PlayerPositionState@ playerState
            ) {
                int proximityMode = TriggerVisualizer::Trigger::UI::S_RenderProximityMode;
                float cameraFade = GetTriggerVolumeFadeFactor(box, cameraPos);

                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_PLAYER_ONLY) {
                    return GetPlayerTriggerVolumeFadeFactor(box, playerState);
                }

                if (proximityMode == TriggerVisualizer::Trigger::UI::PROXIMITY_MODE_CAMERA_AND_PLAYER) {
                    return Math::Max(cameraFade, GetPlayerTriggerVolumeFadeFactor(box, playerState));
                }

                return cameraFade;
            }

            bool IsTriggerVolumeInRenderRangeForProximity(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::PlayerPositionState@ playerState
            ) {
                return IsVisibleFadeFactor(GetTriggerVolumeRenderFadeFactor(box, cameraPos, playerState));
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
                const TriggerVisualizer::Trigger::Data::PlayerPositionState@ playerState
            ) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    if (IsTriggerVolumeInRenderRangeForProximity(boxes[i], cameraPos, playerState)) {
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
                const TriggerVisualizer::Trigger::Data::PlayerPositionState@ playerState
            ) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    float fade = GetTriggerVolumeRenderFadeFactor(boxes[i], cameraPos, playerState);
                    if (fade >= 1.0f || !IsVisibleFadeFactor(fade)) continue;
                    count++;
                }
                return count;
            }

            void DrawTriggerVolumeFill(const TriggerVolume@ box, const vec3 &in cameraPos, const vec4 &in color, uint boxIndex) {
                auto items = array<WorldFillTileDrawItem@>();
                CollectTriggerVolumeFillDrawItems(box, cameraPos, color, boxIndex, items);
                DrawWorldFillTileDrawItems(items);
            }

            void CollectTriggerVolumeFillDrawItems(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                uint boxIndex,
                array<WorldFillTileDrawItem@> @items
            ) {
                if (items is null) return;
                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return;
                if (color.w <= 0.001f && !TriggerVisualizer::Trigger::UI::S_ShowSkullTileIcons) return;

                for (uint i = 0; i < TRIGGER_VOLUME_FACE_INDICES.Length; i++) {
                    auto face = TRIGGER_VOLUME_FACE_INDICES[i];
                    if (!IsTriggerVolumeFaceCameraFacing(corners, face, i, cameraPos)) continue;
                    CollectAdaptiveWorldFaceFillDrawItems(items, corners, face, cameraPos, color, boxIndex, i);
                }
            }

            void DrawTriggerVolumeOutline(
                const TriggerVolume@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                float strokeWidth,
                uint boxIndex
            ) {
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
