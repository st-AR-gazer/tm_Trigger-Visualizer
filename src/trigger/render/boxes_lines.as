namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
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

            float ClampLineSplitDistanceToUserRange(float value, float rangeA, float rangeB) {
                float a = Math::Max(rangeA, 0.0f);
                float b = Math::Max(rangeB, 0.0f);
                return Math::Clamp(value, Math::Min(a, b), Math::Max(a, b));
            }

            uint GetAdaptiveLineSegmentCount(const vec3 &in start, const vec3 &in end, const vec3 &in cameraPos) {
                if (!TriggerVisualizer::Trigger::UI::S_AdaptiveLineSplitting) return 1;

                float lineLength = Math::Distance(start, end);
                if (lineLength <= 0.001f) return 1;

                float minSegmentLength = Math::Max(
                    TriggerVisualizer::Trigger::UI::S_LineSplitTargetSegmentLength,
                    TriggerVisualizer::Trigger::UI::LINE_SPLIT_MINIMUM_SAFE_LENGTH
                );
                int maxAllowedSegments = Math::Max(TriggerVisualizer::Trigger::UI::S_LineSplitMaxSegmentsPerEdge, 1);
                int maxSegments = Math::Max(
                    1,
                    Math::Min(int(Math::Floor(lineLength / minSegmentLength)), maxAllowedSegments)
                );
                if (maxSegments <= 1) return 1;

                float startDistance = ClampLineSplitDistanceToUserRange(
                    lineLength * Math::Max(TriggerVisualizer::Trigger::UI::S_LineSplitStartDistanceFactor, 0.0f),
                    TriggerVisualizer::Trigger::UI::S_LineSplitMinStartDistance,
                    TriggerVisualizer::Trigger::UI::S_LineSplitMaxStartDistance
                );
                float fullDistance = ClampLineSplitDistanceToUserRange(
                    lineLength * Math::Max(TriggerVisualizer::Trigger::UI::S_LineSplitFullDistanceFactor, 0.0f),
                    TriggerVisualizer::Trigger::UI::S_LineSplitMinFullDistance,
                    TriggerVisualizer::Trigger::UI::S_LineSplitMaxFullDistance
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

            uint CountTriggerVolumeOutlineSegments(const TriggerVolume@ box, const vec3 &in cameraPos) {
                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return 0;

                uint count = 0;
                for (uint i = 0; i < TRIGGER_VOLUME_EDGE_INDICES.Length; i++) {
                    auto edge = TRIGGER_VOLUME_EDGE_INDICES[i];
                    count += GetAdaptiveLineSegmentCount(corners[edge[0]], corners[edge[1]], cameraPos);
                }
                return count;
            }

            uint CountTriggerVolumesOutlineSegments(const array<TriggerVolume@> @boxes, const vec3 &in cameraPos) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    count += CountTriggerVolumeOutlineSegments(boxes[i], cameraPos);
                }
                return count;
            }

            uint GetMaxTriggerVolumeOutlineEdgeSegments(const TriggerVolume@ box, const vec3 &in cameraPos) {
                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return 0;

                uint maxSegments = 0;
                for (uint i = 0; i < TRIGGER_VOLUME_EDGE_INDICES.Length; i++) {
                    auto edge = TRIGGER_VOLUME_EDGE_INDICES[i];
                    maxSegments = Math::Max(
                        maxSegments,
                        GetAdaptiveLineSegmentCount(corners[edge[0]], corners[edge[1]], cameraPos)
                    );
                }
                return maxSegments;
            }

            uint GetMaxTriggerVolumesOutlineEdgeSegments(const array<TriggerVolume@> @boxes, const vec3 &in cameraPos) {
                if (boxes is null) return 0;

                uint maxSegments = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    maxSegments = Math::Max(maxSegments, GetMaxTriggerVolumeOutlineEdgeSegments(boxes[i], cameraPos));
                }
                return maxSegments;
            }

            bool DrawProjectedLineSegment(const vec3 &in start, const vec3 &in end) {
                vec3 startScreenPos = Camera::ToScreen(start);
                vec3 endScreenPos = Camera::ToScreen(end);
                if (startScreenPos.z >= 0 || endScreenPos.z >= 0) return false;

                nvg::MoveTo(startScreenPos.xy);
                nvg::LineTo(endScreenPos.xy);
                return true;
            }

            float GetLineFrustumResolveMinLength() {
                return Math::Max(
                    TriggerVisualizer::Trigger::UI::S_LineSplitTargetSegmentLength,
                    TriggerVisualizer::Trigger::UI::LINE_SPLIT_MINIMUM_SAFE_LENGTH
                );
            }

            bool ShouldResolveMixedWorldLineSegment(const vec3 &in start, const vec3 &in end, uint depth) {
                if (depth >= LINE_FRUSTUM_MAX_DEPTH) return false;
                return Math::Distance(start, end) > GetLineFrustumResolveMinLength();
            }

            bool DrawProjectedLineSegmentFrustumSafe(const vec3 &in start, const vec3 &in end, uint depth) {
                int primitiveClass = ClassifyWorldLineForFrustum(start, end);
                if (primitiveClass == WORLD_PRIMITIVE_OUTSIDE) return false;
                if (primitiveClass == WORLD_PRIMITIVE_FRONT) return DrawProjectedLineSegment(start, end);
                if (!ShouldResolveMixedWorldLineSegment(start, end, depth)) return false;

                vec3 mid = (start + end) * 0.5f;
                bool drewStart = DrawProjectedLineSegmentFrustumSafe(start, mid, depth + 1);
                bool drewEnd = DrawProjectedLineSegmentFrustumSafe(mid, end, depth + 1);
                return drewStart || drewEnd;
            }

            void DrawWorldLineSegmentImmediate(const vec3 &in start, const vec3 &in end, const vec4 &in color) {
                if (!ConsumeWorldLineSegmentBudget()) return;

                nvg::BeginPath();
                nvg::StrokeColor(color);
                if (DrawProjectedLineSegmentFrustumSafe(start, end, 0)) {
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
                    if (G_WorldLineSegmentBudgetRemaining == 0) break;

                    float t0 = float(i) * invSegments;
                    float t1 = float(i + 1) * invSegments;
                    DrawWorldLineSegmentImmediate(
                        Math::Lerp(start, end, t0),
                        Math::Lerp(start, end, t1),
                        GetOutlineSegmentColor(baseColor, boxIndex, edgeIndex, i)
                    );
                }
            }
        }
    }
}
