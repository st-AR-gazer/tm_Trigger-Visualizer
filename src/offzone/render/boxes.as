namespace OffzoneVisualizer {
    namespace Offzone {
        namespace Render {
            const float MIN_VISIBLE_FADE = 0.001f;
            const float FILL_TILE_MIN_SIZE = 4.0f;
            const float FILL_TILE_SPLIT_DISTANCE_FACTOR = 0.75f;
            const uint FILL_TILE_MAX_DEPTH = 10;
            const uint FILL_TILE_MAX_TILES_PER_FACE = 2048;

            const uint[][] BOX_EDGE_INDICES = {
                {0, 1}, {1, 2}, {2, 3}, {3, 0},
                {4, 5}, {5, 6}, {6, 7}, {7, 4},
                {0, 4}, {1, 5}, {2, 6}, {3, 7}
            };

            const uint[][] BOX_FACE_INDICES = {
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

            vec4 GetOutlineSegmentColor(
                const vec4 &in baseColor,
                uint boxIndex,
                uint edgeIndex,
                uint segmentIndex
            ) {
                if (!OffzoneVisualizer::Offzone::UI::S_RandomOutlineSegmentColors) return baseColor;
                return StableRandomColor(GetOutlineSegmentColorSeed(boxIndex, edgeIndex, segmentIndex), baseColor.w);
            }

            vec4 GetFillTileColor(const vec4 &in baseColor, float tileSeed) {
                if (!OffzoneVisualizer::Offzone::UI::S_RandomFillTileColors) return baseColor;
                return StableRandomColor(tileSeed, baseColor.w);
            }

            float GetWorldBoxLineSplitDensityFactor(const WorldAabb@ box, const vec3 &in cameraPos) {
                if (!OffzoneVisualizer::Offzone::UI::S_AdaptiveLineSplitting) return 0.0f;

                int maxAllowedSegments = Math::Max(OffzoneVisualizer::Offzone::UI::S_LineSplitMaxSegmentsPerEdge, 1);
                if (maxAllowedSegments <= 1) return 0.0f;

                uint maxEdgeSegments = GetMaxWorldBoxOutlineEdgeSegments(box, cameraPos);
                return Math::Clamp(
                    float(Math::Max(int(maxEdgeSegments), 1) - 1) / float(maxAllowedSegments - 1),
                    0.0f,
                    1.0f
                );
            }

            vec4 GetColorModeColor(const WorldAabb@ box, const vec3 &in cameraPos, float fade) {
                int colorMode = OffzoneVisualizer::Offzone::UI::S_ColorMode;
                vec4 color = OffzoneVisualizer::Offzone::UI::S_BaseOffzoneColor;

                if (colorMode == OffzoneVisualizer::Offzone::UI::COLOR_MODE_DISTANCE_FADE) {
                    color = LerpColor(
                        color,
                        OffzoneVisualizer::Offzone::UI::S_DistanceFadeColor,
                        1.0f - Math::Clamp(fade, 0.0f, 1.0f)
                    );
                } else if (colorMode == OffzoneVisualizer::Offzone::UI::COLOR_MODE_LINE_SPLIT_DENSITY) {
                    color = LerpColor(
                        color,
                        OffzoneVisualizer::Offzone::UI::S_DenseLineSplitColor,
                        GetWorldBoxLineSplitDensityFactor(box, cameraPos)
                    );
                }

                return color;
            }

            vec4 GetOutlineColor(const WorldAabb@ box, const vec3 &in cameraPos, float fade) {
                vec4 color = GetColorModeColor(box, cameraPos, fade);
                color.w *= OffzoneVisualizer::Offzone::UI::S_OutlineAlpha * Math::Clamp(fade, 0.0f, 1.0f);
                return color;
            }

            vec4 GetFillColor(const WorldAabb@ box, const vec3 &in cameraPos, float fade) {
                vec4 color = GetColorModeColor(box, cameraPos, fade);
                color.w *= OffzoneVisualizer::Offzone::UI::S_FillAlpha * Math::Clamp(fade, 0.0f, 1.0f);
                return color;
            }

            vec3 GetDistanceOutsideBox(const WorldAabb@ box, const vec3 &in point) {
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

            float GetWorldBoxFadeFactor(const WorldAabb@ box, const vec3 &in cameraPos) {
                vec3 renderDistance = OffzoneVisualizer::Offzone::UI::GetRenderDistanceWorld();
                vec3 fadeBand = OffzoneVisualizer::Offzone::UI::GetRenderFadeBandWorld();
                vec3 outside = GetDistanceOutsideBox(box, cameraPos);

                float fx = GetAxisFadeFactor(outside.x, renderDistance.x, fadeBand.x);
                float fy = GetAxisFadeFactor(outside.y, renderDistance.y, fadeBand.y);
                float fz = GetAxisFadeFactor(outside.z, renderDistance.z, fadeBand.z);
                return Math::Min(fx, Math::Min(fy, fz));
            }

            bool IsVisibleFadeFactor(float fade) {
                return fade > MIN_VISIBLE_FADE;
            }

            bool IsWorldBoxInRenderRange(const WorldAabb@ box, const vec3 &in cameraPos) {
                return IsVisibleFadeFactor(GetWorldBoxFadeFactor(box, cameraPos));
            }

            float GetPlayerWorldBoxFadeFactor(
                const WorldAabb@ box,
                const OffzoneVisualizer::Offzone::Data::PlayerPositionState@ playerState
            ) {
                if (playerState is null || !playerState.HasVehicle) return 0.0f;
                return GetWorldBoxFadeFactor(box, playerState.Position);
            }

            float GetWorldBoxRenderFadeFactor(
                const WorldAabb@ box,
                const vec3 &in cameraPos,
                const OffzoneVisualizer::Offzone::Data::PlayerPositionState@ playerState
            ) {
                int proximityMode = OffzoneVisualizer::Offzone::UI::S_RenderProximityMode;
                float cameraFade = GetWorldBoxFadeFactor(box, cameraPos);

                if (proximityMode == OffzoneVisualizer::Offzone::UI::PROXIMITY_MODE_PLAYER_ONLY) {
                    return GetPlayerWorldBoxFadeFactor(box, playerState);
                }

                if (proximityMode == OffzoneVisualizer::Offzone::UI::PROXIMITY_MODE_CAMERA_AND_PLAYER) {
                    return Math::Max(cameraFade, GetPlayerWorldBoxFadeFactor(box, playerState));
                }

                return cameraFade;
            }

            bool IsWorldBoxInRenderRangeForProximity(
                const WorldAabb@ box,
                const vec3 &in cameraPos,
                const OffzoneVisualizer::Offzone::Data::PlayerPositionState@ playerState
            ) {
                return IsVisibleFadeFactor(GetWorldBoxRenderFadeFactor(box, cameraPos, playerState));
            }

            uint CountWorldBoxesInRenderRange(const array<WorldAabb@> @boxes, const vec3 &in cameraPos) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    if (IsWorldBoxInRenderRange(boxes[i], cameraPos)) {
                        count++;
                    }
                }
                return count;
            }

            uint CountWorldBoxesInRenderRangeForProximity(
                const array<WorldAabb@> @boxes,
                const vec3 &in cameraPos,
                const OffzoneVisualizer::Offzone::Data::PlayerPositionState@ playerState
            ) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    if (IsWorldBoxInRenderRangeForProximity(boxes[i], cameraPos, playerState)) {
                        count++;
                    }
                }
                return count;
            }

            uint CountWorldBoxesInFadeBand(const array<WorldAabb@> @boxes, const vec3 &in cameraPos) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    float fade = GetWorldBoxFadeFactor(boxes[i], cameraPos);
                    if (fade >= 1.0f || !IsVisibleFadeFactor(fade)) continue;
                    count++;
                }
                return count;
            }

            uint CountWorldBoxesInFadeBandForProximity(
                const array<WorldAabb@> @boxes,
                const vec3 &in cameraPos,
                const OffzoneVisualizer::Offzone::Data::PlayerPositionState@ playerState
            ) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    float fade = GetWorldBoxRenderFadeFactor(boxes[i], cameraPos, playerState);
                    if (fade >= 1.0f || !IsVisibleFadeFactor(fade)) continue;
                    count++;
                }
                return count;
            }

            float GetDistanceToWorldLineSegment(const vec3 &in point, const vec3 &in start, const vec3 &in end) {
                vec3 line = end - start;
                float lineLengthSq = Math::Distance2(start, end);
                if (lineLengthSq <= 0.0001f) return Math::Distance(point, start);

                float t = Math::Dot(point - start, line) / lineLengthSq;
                t = Math::Clamp(t, 0.0f, 1.0f);
                return Math::Distance(point, Math::Lerp(start, end, t));
            }

            float SmoothStep01(float value) {
                value = Math::Clamp(value, 0.0f, 1.0f);
                return value * value * (3.0f - 2.0f * value);
            }

            uint GetAdaptiveLineSegmentCount(const vec3 &in start, const vec3 &in end, const vec3 &in cameraPos) {
                if (!OffzoneVisualizer::Offzone::UI::S_AdaptiveLineSplitting) return 1;

                float lineLength = Math::Distance(start, end);
                if (lineLength <= 0.001f) return 1;

                float minSegmentLength = Math::Clamp(
                    OffzoneVisualizer::Offzone::UI::S_LineSplitTargetSegmentLength,
                    4.0f,
                    512.0f
                );
                int maxSegments = Math::Clamp(
                    int(Math::Floor(lineLength / minSegmentLength)),
                    1,
                    OffzoneVisualizer::Offzone::UI::S_LineSplitMaxSegmentsPerEdge
                );
                if (maxSegments <= 1) return 1;

                float startDistance = Math::Clamp(
                    lineLength * OffzoneVisualizer::Offzone::UI::S_LineSplitStartDistanceFactor,
                    OffzoneVisualizer::Offzone::UI::S_LineSplitMinStartDistance,
                    OffzoneVisualizer::Offzone::UI::S_LineSplitMaxStartDistance
                );
                float fullDistance = Math::Clamp(
                    lineLength * OffzoneVisualizer::Offzone::UI::S_LineSplitFullDistanceFactor,
                    OffzoneVisualizer::Offzone::UI::S_LineSplitMinFullDistance,
                    OffzoneVisualizer::Offzone::UI::S_LineSplitMaxFullDistance
                );
                fullDistance = Math::Min(fullDistance, Math::Max(startDistance - 0.001f, 0.0f));

                float cameraDistance = GetDistanceToWorldLineSegment(cameraPos, start, end);
                if (cameraDistance >= startDistance) return 1;
                if (cameraDistance <= fullDistance) return uint(maxSegments);

                float range = Math::Max(startDistance - fullDistance, 0.001f);
                float proximity = SmoothStep01((startDistance - cameraDistance) / range);
                int segmentCount = 1 + int(Math::Ceil(float(maxSegments - 1) * proximity));
                return uint(Math::Clamp(segmentCount, 1, maxSegments));
            }

            uint CountWorldBoxOutlineSegments(const WorldAabb@ box, const vec3 &in cameraPos) {
                auto corners = GetWorldBoxCorners(box);
                if (corners.Length != 8) return 0;

                uint count = 0;
                for (uint i = 0; i < BOX_EDGE_INDICES.Length; i++) {
                    auto edge = BOX_EDGE_INDICES[i];
                    count += GetAdaptiveLineSegmentCount(corners[edge[0]], corners[edge[1]], cameraPos);
                }
                return count;
            }

            uint CountWorldBoxesOutlineSegments(const array<WorldAabb@> @boxes, const vec3 &in cameraPos) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    count += CountWorldBoxOutlineSegments(boxes[i], cameraPos);
                }
                return count;
            }

            uint GetMaxWorldBoxOutlineEdgeSegments(const WorldAabb@ box, const vec3 &in cameraPos) {
                auto corners = GetWorldBoxCorners(box);
                if (corners.Length != 8) return 0;

                uint maxSegments = 0;
                for (uint i = 0; i < BOX_EDGE_INDICES.Length; i++) {
                    auto edge = BOX_EDGE_INDICES[i];
                    maxSegments = Math::Max(
                        maxSegments,
                        GetAdaptiveLineSegmentCount(corners[edge[0]], corners[edge[1]], cameraPos)
                    );
                }
                return maxSegments;
            }

            uint GetMaxWorldBoxesOutlineEdgeSegments(const array<WorldAabb@> @boxes, const vec3 &in cameraPos) {
                if (boxes is null) return 0;

                uint maxSegments = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    maxSegments = Math::Max(maxSegments, GetMaxWorldBoxOutlineEdgeSegments(boxes[i], cameraPos));
                }
                return maxSegments;
            }

            vec3 GetBoxFaceNormal(uint faceIndex) {
                if (faceIndex == 0) return vec3(-1.0f, 0.0f, 0.0f);
                if (faceIndex == 1) return vec3(1.0f, 0.0f, 0.0f);
                if (faceIndex == 2) return vec3(0.0f, -1.0f, 0.0f);
                if (faceIndex == 3) return vec3(0.0f, 1.0f, 0.0f);
                if (faceIndex == 4) return vec3(0.0f, 0.0f, -1.0f);
                return vec3(0.0f, 0.0f, 1.0f);
            }

            array<vec3> @GetWorldBoxCorners(const WorldAabb@ box) {
                auto corners = array<vec3>();
                if (box is null) return corners;

                vec3 min = box.Min;
                vec3 max = box.Max;

                corners.InsertLast(vec3(min.x, min.y, min.z));
                corners.InsertLast(vec3(max.x, min.y, min.z));
                corners.InsertLast(vec3(max.x, max.y, min.z));
                corners.InsertLast(vec3(min.x, max.y, min.z));
                corners.InsertLast(vec3(min.x, min.y, max.z));
                corners.InsertLast(vec3(max.x, min.y, max.z));
                corners.InsertLast(vec3(max.x, max.y, max.z));
                corners.InsertLast(vec3(min.x, max.y, max.z));

                return corners;
            }

            bool DrawProjectedLineSegment(const vec3 &in start, const vec3 &in end) {
                vec3 startScreenPos = Camera::ToScreen(start);
                vec3 endScreenPos = Camera::ToScreen(end);
                if (startScreenPos.z >= 0 || endScreenPos.z >= 0) return false;

                nvg::MoveTo(startScreenPos.xy);
                nvg::LineTo(endScreenPos.xy);
                return true;
            }

            bool DrawProjectedQuad(
                const vec3 &in p0,
                const vec3 &in p1,
                const vec3 &in p2,
                const vec3 &in p3,
                const vec4 &in color
            ) {
                vec3 s0 = Camera::ToScreen(p0);
                vec3 s1 = Camera::ToScreen(p1);
                vec3 s2 = Camera::ToScreen(p2);
                vec3 s3 = Camera::ToScreen(p3);
                if (s0.z >= 0 || s1.z >= 0 || s2.z >= 0 || s3.z >= 0) return false;

                nvg::BeginPath();
                nvg::FillColor(color);
                nvg::MoveTo(s0.xy);
                nvg::LineTo(s1.xy);
                nvg::LineTo(s2.xy);
                nvg::LineTo(s3.xy);
                nvg::ClosePath();
                nvg::Fill();
                return true;
            }

            float GetDistanceToWorldQuad(
                const vec3 &in point,
                const vec3 &in origin,
                const vec3 &in uEdge,
                const vec3 &in vEdge
            ) {
                float uLenSq = Math::Dot(uEdge, uEdge);
                float vLenSq = Math::Dot(vEdge, vEdge);
                float u = uLenSq <= 0.0001f ? 0.0f : Math::Dot(point - origin, uEdge) / uLenSq;
                float v = vLenSq <= 0.0001f ? 0.0f : Math::Dot(point - origin, vEdge) / vLenSq;
                u = Math::Clamp(u, 0.0f, 1.0f);
                v = Math::Clamp(v, 0.0f, 1.0f);
                return Math::Distance(point, origin + uEdge * u + vEdge * v);
            }

            bool ShouldSplitWorldFaceTile(
                const vec3 &in origin,
                const vec3 &in uEdge,
                const vec3 &in vEdge,
                const vec3 &in cameraPos,
                uint depth
            ) {
                if (depth >= FILL_TILE_MAX_DEPTH) return false;

                float uLen = Math::Distance(origin, origin + uEdge);
                float vLen = Math::Distance(origin, origin + vEdge);
                if (uLen <= FILL_TILE_MIN_SIZE && vLen <= FILL_TILE_MIN_SIZE) return false;

                float longestEdge = Math::Max(uLen, vLen);
                float cameraDistance = GetDistanceToWorldQuad(cameraPos, origin, uEdge, vEdge);
                float splitDistance = Math::Max(
                    longestEdge * FILL_TILE_SPLIT_DISTANCE_FACTOR,
                    FILL_TILE_MIN_SIZE
                );
                return cameraDistance <= splitDistance;
            }

            uint DrawAdaptiveWorldFaceTile(
                const vec3 &in origin,
                const vec3 &in uEdge,
                const vec3 &in vEdge,
                const vec3 &in cameraPos,
                const vec4 &in baseColor,
                float tileSeed,
                uint depth,
                uint budget
            ) {
                if (budget == 0) return 0;

                float uLen = Math::Distance(origin, origin + uEdge);
                float vLen = Math::Distance(origin, origin + vEdge);
                bool splitU = uLen > FILL_TILE_MIN_SIZE;
                bool splitV = vLen > FILL_TILE_MIN_SIZE;
                if (!ShouldSplitWorldFaceTile(origin, uEdge, vEdge, cameraPos, depth) || (!splitU && !splitV)) {
                    return DrawProjectedQuad(
                        origin,
                        origin + uEdge,
                        origin + uEdge + vEdge,
                        origin + vEdge,
                        GetFillTileColor(baseColor, tileSeed)
                    ) ? 1 : 0;
                }

                uint drawn = 0;
                vec3 halfU = uEdge * 0.5f;
                vec3 halfV = vEdge * 0.5f;

                if (splitU && splitV) {
                    drawn += DrawAdaptiveWorldFaceTile(origin, halfU, halfV, cameraPos, baseColor, tileSeed * 4.0f + 1.0f, depth + 1, budget - drawn);
                    if (drawn >= budget) return drawn;
                    drawn += DrawAdaptiveWorldFaceTile(origin + halfU, halfU, halfV, cameraPos, baseColor, tileSeed * 4.0f + 2.0f, depth + 1, budget - drawn);
                    if (drawn >= budget) return drawn;
                    drawn += DrawAdaptiveWorldFaceTile(origin + halfV, halfU, halfV, cameraPos, baseColor, tileSeed * 4.0f + 3.0f, depth + 1, budget - drawn);
                    if (drawn >= budget) return drawn;
                    drawn += DrawAdaptiveWorldFaceTile(origin + halfU + halfV, halfU, halfV, cameraPos, baseColor, tileSeed * 4.0f + 4.0f, depth + 1, budget - drawn);
                    return drawn;
                }

                if (splitU) {
                    drawn += DrawAdaptiveWorldFaceTile(origin, halfU, vEdge, cameraPos, baseColor, tileSeed * 2.0f + 1.0f, depth + 1, budget - drawn);
                    if (drawn >= budget) return drawn;
                    drawn += DrawAdaptiveWorldFaceTile(origin + halfU, halfU, vEdge, cameraPos, baseColor, tileSeed * 2.0f + 2.0f, depth + 1, budget - drawn);
                    return drawn;
                }

                drawn += DrawAdaptiveWorldFaceTile(origin, uEdge, halfV, cameraPos, baseColor, tileSeed * 2.0f + 1.0f, depth + 1, budget - drawn);
                if (drawn >= budget) return drawn;
                drawn += DrawAdaptiveWorldFaceTile(origin + halfV, uEdge, halfV, cameraPos, baseColor, tileSeed * 2.0f + 2.0f, depth + 1, budget - drawn);
                return drawn;
            }

            uint CountAdaptiveWorldFaceTiles(
                const vec3 &in origin,
                const vec3 &in uEdge,
                const vec3 &in vEdge,
                const vec3 &in cameraPos,
                uint depth,
                uint budget
            ) {
                if (budget == 0) return 0;

                float uLen = Math::Distance(origin, origin + uEdge);
                float vLen = Math::Distance(origin, origin + vEdge);
                bool splitU = uLen > FILL_TILE_MIN_SIZE;
                bool splitV = vLen > FILL_TILE_MIN_SIZE;
                if (!ShouldSplitWorldFaceTile(origin, uEdge, vEdge, cameraPos, depth) || (!splitU && !splitV)) {
                    return 1;
                }

                uint count = 0;
                vec3 halfU = uEdge * 0.5f;
                vec3 halfV = vEdge * 0.5f;

                if (splitU && splitV) {
                    count += CountAdaptiveWorldFaceTiles(origin, halfU, halfV, cameraPos, depth + 1, budget - count);
                    if (count >= budget) return count;
                    count += CountAdaptiveWorldFaceTiles(origin + halfU, halfU, halfV, cameraPos, depth + 1, budget - count);
                    if (count >= budget) return count;
                    count += CountAdaptiveWorldFaceTiles(origin + halfV, halfU, halfV, cameraPos, depth + 1, budget - count);
                    if (count >= budget) return count;
                    count += CountAdaptiveWorldFaceTiles(origin + halfU + halfV, halfU, halfV, cameraPos, depth + 1, budget - count);
                    return count;
                }

                if (splitU) {
                    count += CountAdaptiveWorldFaceTiles(origin, halfU, vEdge, cameraPos, depth + 1, budget - count);
                    if (count >= budget) return count;
                    count += CountAdaptiveWorldFaceTiles(origin + halfU, halfU, vEdge, cameraPos, depth + 1, budget - count);
                    return count;
                }

                count += CountAdaptiveWorldFaceTiles(origin, uEdge, halfV, cameraPos, depth + 1, budget - count);
                if (count >= budget) return count;
                count += CountAdaptiveWorldFaceTiles(origin + halfV, uEdge, halfV, cameraPos, depth + 1, budget - count);
                return count;
            }

            uint DrawAdaptiveWorldFaceFill(
                const array<vec3> @corners,
                const uint[]@ face,
                const vec3 &in cameraPos,
                const vec4 &in baseColor,
                uint boxIndex,
                uint faceIndex
            ) {
                if (corners is null || face is null || face.Length != 4) return 0;

                vec3 origin = corners[face[0]];
                vec3 uEdge = corners[face[1]] - origin;
                vec3 vEdge = corners[face[3]] - origin;
                return DrawAdaptiveWorldFaceTile(
                    origin,
                    uEdge,
                    vEdge,
                    cameraPos,
                    baseColor,
                    GetFillTileColorSeed(boxIndex, faceIndex),
                    0,
                    FILL_TILE_MAX_TILES_PER_FACE
                );
            }

            uint CountAdaptiveWorldFaceFillTiles(
                const array<vec3> @corners,
                const uint[]@ face,
                const vec3 &in cameraPos
            ) {
                if (corners is null || face is null || face.Length != 4) return 0;

                vec3 origin = corners[face[0]];
                vec3 uEdge = corners[face[1]] - origin;
                vec3 vEdge = corners[face[3]] - origin;
                return CountAdaptiveWorldFaceTiles(
                    origin,
                    uEdge,
                    vEdge,
                    cameraPos,
                    0,
                    FILL_TILE_MAX_TILES_PER_FACE
                );
            }

            bool IsBoxFaceCameraFacing(
                const array<vec3> @corners,
                const uint[]@ face,
                uint faceIndex,
                const vec3 &in cameraPos
            ) {
                if (corners is null || face is null || face.Length != 4) return false;

                vec3 center = vec3();
                for (uint i = 0; i < face.Length; i++) {
                    center += corners[face[i]];
                }
                center *= 0.25f;

                return Math::Dot(GetBoxFaceNormal(faceIndex), cameraPos - center) > 0.0f;
            }

            uint CountWorldBoxCameraFacingFaces(const WorldAabb@ box, const vec3 &in cameraPos) {
                auto corners = GetWorldBoxCorners(box);
                if (corners.Length != 8) return 0;

                uint count = 0;
                for (uint i = 0; i < BOX_FACE_INDICES.Length; i++) {
                    if (IsBoxFaceCameraFacing(corners, BOX_FACE_INDICES[i], i, cameraPos)) {
                        count++;
                    }
                }
                return count;
            }

            uint CountWorldBoxesCameraFacingFaces(const array<WorldAabb@> @boxes, const vec3 &in cameraPos) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    if (!IsWorldBoxInRenderRange(boxes[i], cameraPos)) continue;
                    count += CountWorldBoxCameraFacingFaces(boxes[i], cameraPos);
                }
                return count;
            }

            uint CountWorldBoxesCameraFacingFacesForProximity(
                const array<WorldAabb@> @boxes,
                const vec3 &in cameraPos,
                const OffzoneVisualizer::Offzone::Data::PlayerPositionState@ playerState
            ) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    if (!IsWorldBoxInRenderRangeForProximity(boxes[i], cameraPos, playerState)) continue;
                    count += CountWorldBoxCameraFacingFaces(boxes[i], cameraPos);
                }
                return count;
            }

            uint CountWorldBoxFillTiles(const WorldAabb@ box, const vec3 &in cameraPos) {
                auto corners = GetWorldBoxCorners(box);
                if (corners.Length != 8) return 0;

                uint count = 0;
                for (uint i = 0; i < BOX_FACE_INDICES.Length; i++) {
                    auto face = BOX_FACE_INDICES[i];
                    if (!IsBoxFaceCameraFacing(corners, face, i, cameraPos)) continue;
                    count += CountAdaptiveWorldFaceFillTiles(corners, face, cameraPos);
                }
                return count;
            }

            uint CountWorldBoxesFillTilesForProximity(
                const array<WorldAabb@> @boxes,
                const vec3 &in cameraPos,
                const OffzoneVisualizer::Offzone::Data::PlayerPositionState@ playerState
            ) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    if (!IsWorldBoxInRenderRangeForProximity(boxes[i], cameraPos, playerState)) continue;
                    count += CountWorldBoxFillTiles(boxes[i], cameraPos);
                }
                return count;
            }

            void DrawWorldLineAdaptive(const vec3 &in start, const vec3 &in end, const vec3 &in cameraPos) {
                uint segmentCount = GetAdaptiveLineSegmentCount(start, end, cameraPos);
                if (segmentCount <= 1) {
                    DrawProjectedLineSegment(start, end);
                    return;
                }

                float invSegments = 1.0f / float(segmentCount);
                for (uint i = 0; i < segmentCount; i++) {
                    float t0 = float(i) * invSegments;
                    float t1 = float(i + 1) * invSegments;
                    DrawProjectedLineSegment(Math::Lerp(start, end, t0), Math::Lerp(start, end, t1));
                }
            }

            void DrawWorldLineSegmentImmediate(
                const vec3 &in start,
                const vec3 &in end,
                const vec4 &in color
            ) {
                nvg::BeginPath();
                nvg::StrokeColor(color);
                if (DrawProjectedLineSegment(start, end)) {
                    nvg::Stroke();
                }
                nvg::ClosePath();
            }

            void DrawWorldLineAdaptiveColored(
                const vec3 &in start,
                const vec3 &in end,
                const vec3 &in cameraPos,
                const vec4 &in baseColor,
                uint boxIndex,
                uint edgeIndex
            ) {
                uint segmentCount = GetAdaptiveLineSegmentCount(start, end, cameraPos);
                if (segmentCount <= 1) {
                    DrawWorldLineSegmentImmediate(
                        start,
                        end,
                        GetOutlineSegmentColor(baseColor, boxIndex, edgeIndex, 0)
                    );
                    return;
                }

                float invSegments = 1.0f / float(segmentCount);
                for (uint i = 0; i < segmentCount; i++) {
                    float t0 = float(i) * invSegments;
                    float t1 = float(i + 1) * invSegments;
                    DrawWorldLineSegmentImmediate(
                        Math::Lerp(start, end, t0),
                        Math::Lerp(start, end, t1),
                        GetOutlineSegmentColor(baseColor, boxIndex, edgeIndex, i)
                    );
                }
            }

            void DrawWorldBoxFill(
                const WorldAabb@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                uint boxIndex
            ) {
                auto corners = GetWorldBoxCorners(box);
                if (corners.Length != 8) return;
                if (color.w <= 0.001f) return;

                nvg::Reset();

                for (uint i = 0; i < BOX_FACE_INDICES.Length; i++) {
                    auto face = BOX_FACE_INDICES[i];
                    if (!IsBoxFaceCameraFacing(corners, face, i, cameraPos)) continue;
                    DrawAdaptiveWorldFaceFill(corners, face, cameraPos, color, boxIndex, i);
                }
            }

            void DrawWorldBoxOutline(
                const WorldAabb@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                float strokeWidth,
                uint boxIndex
            ) {
                auto corners = GetWorldBoxCorners(box);
                if (corners.Length != 8) return;

                nvg::Reset();
                nvg::StrokeWidth(Math::Clamp(strokeWidth, 0.5f, 16.0f));

                if (OffzoneVisualizer::Offzone::UI::S_RandomOutlineSegmentColors) {
                    for (uint i = 0; i < BOX_EDGE_INDICES.Length; i++) {
                        auto edge = BOX_EDGE_INDICES[i];
                        DrawWorldLineAdaptiveColored(corners[edge[0]], corners[edge[1]], cameraPos, color, boxIndex, i);
                    }
                    return;
                }

                nvg::BeginPath();
                nvg::StrokeColor(color);
                for (uint i = 0; i < BOX_EDGE_INDICES.Length; i++) {
                    auto edge = BOX_EDGE_INDICES[i];
                    DrawWorldLineAdaptive(corners[edge[0]], corners[edge[1]], cameraPos);
                }

                nvg::Stroke();
                nvg::ClosePath();
            }
        }
    }
}
