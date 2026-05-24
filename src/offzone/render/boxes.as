namespace OffzoneVisualizer {
    namespace Offzone {
        namespace Render {
            const float MIN_VISIBLE_FADE = 0.001f;

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
                renderDistance = Math::Max(renderDistance, 0.001f);
                fadeBand = Math::Clamp(fadeBand, 0.001f, renderDistance);
                float fadeStart = Math::Max(renderDistance - fadeBand, 0.0f);

                if (axisDistance <= fadeStart) return 1.0f;
                if (axisDistance >= renderDistance) return 0.0f;
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

                float targetSegmentLength = Math::Max(
                    Math::Min(OffzoneVisualizer::Offzone::UI::S_LineSplitTargetSegmentLength, 4.0f),
                    0.25f
                );
                int maxSegments = Math::Clamp(
                    int(Math::Ceil(lineLength / targetSegmentLength)),
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

            bool DrawProjectedFace(const array<vec3> @corners, const uint[]@ face) {
                if (corners is null || face is null || face.Length != 4) return false;

                array<vec3> screenPositions;
                screenPositions.Resize(4);
                for (uint i = 0; i < face.Length; i++) {
                    screenPositions[i] = Camera::ToScreen(corners[face[i]]);
                    if (screenPositions[i].z >= 0) return false;
                }

                nvg::BeginPath();
                nvg::MoveTo(screenPositions[0].xy);
                for (uint i = 1; i < screenPositions.Length; i++) {
                    nvg::LineTo(screenPositions[i].xy);
                }
                nvg::ClosePath();
                nvg::Fill();
                return true;
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

            void DrawWorldBoxFill(const WorldAabb@ box, const vec3 &in cameraPos, const vec4 &in color) {
                auto corners = GetWorldBoxCorners(box);
                if (corners.Length != 8) return;
                if (color.w <= 0.001f) return;

                nvg::Reset();
                nvg::FillColor(color);

                for (uint i = 0; i < BOX_FACE_INDICES.Length; i++) {
                    auto face = BOX_FACE_INDICES[i];
                    if (!IsBoxFaceCameraFacing(corners, face, i, cameraPos)) continue;
                    DrawProjectedFace(corners, face);
                }
            }

            void DrawWorldBoxOutline(
                const WorldAabb@ box,
                const vec3 &in cameraPos,
                const vec4 &in color,
                float strokeWidth = 2.0f
            ) {
                auto corners = GetWorldBoxCorners(box);
                if (corners.Length != 8) return;

                nvg::Reset();
                nvg::BeginPath();
                nvg::StrokeColor(color);
                nvg::StrokeWidth(strokeWidth);

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
