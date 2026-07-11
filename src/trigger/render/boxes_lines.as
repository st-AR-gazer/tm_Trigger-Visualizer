namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            float GetDistanceSqToWorldLineSegment(const vec3 &in point, const vec3 &in start, const vec3 &in end) {
                vec3 line = end - start;
                float lineLengthSq = Math::Distance2(start, end);
                if (lineLengthSq <= 0.0001f) return Math::Distance2(point, start);

                float t = Math::Dot(point - start, line) / lineLengthSq;
                t = Math::Clamp(t, 0.0f, 1.0f);
                return Math::Distance2(point, Math::Lerp(start, end, t));
            }

            float GetDistanceToWorldLineSegment(const vec3 &in point, const vec3 &in start, const vec3 &in end) {
                return Math::Sqrt(GetDistanceSqToWorldLineSegment(point, start, end));
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

            uint GetAdaptiveLineSegmentCount(
                const vec3 &in start,
                const vec3 &in end,
                const vec3 &in cameraPos,
                bool allowAdaptiveSplitting = true
            ) {
                if (!allowAdaptiveSplitting || !TriggerVisualizer::Trigger::Ui::S_AdaptiveLineSplitting) return 1;

                float lineLength = Math::Distance(start, end);
                if (lineLength <= 0.001f) return 1;

                float minSegmentLength = Math::Max(
                    TriggerVisualizer::Trigger::Ui::S_LineSplitTargetSegmentLength,
                    TriggerVisualizer::Trigger::Ui::LINE_SPLIT_MINIMUM_SAFE_LENGTH
                );
                int maxAllowedSegments = Math::Max(TriggerVisualizer::Trigger::Ui::S_LineSplitMaxSegmentsPerEdge, 1);
                int maxSegments = Math::Max(
                    1,
                    Math::Min(int(Math::Floor(lineLength / minSegmentLength)), maxAllowedSegments)
                );
                if (maxSegments <= 1) return 1;

                float startDistance = ClampLineSplitDistanceToUserRange(
                    lineLength * Math::Max(TriggerVisualizer::Trigger::Ui::S_LineSplitStartDistanceFactor, 0.0f),
                    TriggerVisualizer::Trigger::Ui::S_LineSplitMinStartDistance,
                    TriggerVisualizer::Trigger::Ui::S_LineSplitMaxStartDistance
                );
                float fullDistance = ClampLineSplitDistanceToUserRange(
                    lineLength * Math::Max(TriggerVisualizer::Trigger::Ui::S_LineSplitFullDistanceFactor, 0.0f),
                    TriggerVisualizer::Trigger::Ui::S_LineSplitMinFullDistance,
                    TriggerVisualizer::Trigger::Ui::S_LineSplitMaxFullDistance
                );
                fullDistance = Math::Min(fullDistance, Math::Max(startDistance - 0.001f, 0.0f));
                float cameraDistance = GetDistanceToWorldLineSegment(cameraPos, start, end);
                if (cameraDistance >= startDistance) return 1;
                if (cameraDistance <= fullDistance) return uint(maxSegments);

                float proximity = SmoothStep01(Math::InvLerp(startDistance, fullDistance, cameraDistance));
                int segmentCount = 1 + int(Math::Ceil(float(maxSegments - 1) * proximity));
                return uint(Math::Clamp(segmentCount, 1, maxSegments));
            }

            uint CountTriggerVolumeOutlineSegments(const TriggerVolume@ box, const vec3 &in cameraPos) {
                if (box !is null && box.HasChildVolumes()) {
                    if (box.HasStaticOutlineCache()) {
                        uint groupCount = 0;
                        uint cachedCount = box.CachedStaticOutlineCount();
                        for (uint i = 0; i < cachedCount; i++) {
                            groupCount += GetAdaptiveLineSegmentCount(
                                box.CachedStaticOutlineStarts[i],
                                box.CachedStaticOutlineEnds[i],
                                cameraPos,
                                ShouldSplitTriggerVolumeOutlineEdges(box)
                            );
                        }
                        return groupCount;
                    }

                    uint groupCount = 0;
                    if (box.HasCachedGroupGeometry()) {
                        uint cachedEdgeCount = box.CachedGroupOutlineEdgeCount();
                        for (uint i = 0; i < cachedEdgeCount; i++) {
                            if (IsCachedGroupOutlineEdgeDuplicate(box, i)) continue;
                            groupCount += GetAdaptiveLineSegmentCount(
                                box.CachedGroupOutlineEdgeStarts[i],
                                box.CachedGroupOutlineEdgeEnds[i],
                                cameraPos,
                                ShouldSplitTriggerVolumeOutlineEdges(box)
                            );
                        }
                        return groupCount;
                    }

                    auto items = array<WorldOutlineEdgeDrawItem@>();
                    auto edgeKeys = array<string>();
                    auto edgeCounts = array<uint>();
                    CollectTriggerVolumeOutlineEdgeDrawItems(box, 0, items, edgeKeys, edgeCounts);

                    for (uint i = 0; i < items.Length; i++) {
                        if (items[i] is null) continue;
                        if (GetGeometryKeyCount(edgeKeys, edgeCounts, items[i].GeometryKey) > 1) continue;
                        groupCount += GetAdaptiveLineSegmentCount(
                            items[i].Start,
                            items[i].End,
                            cameraPos,
                            ShouldSplitTriggerVolumeOutlineEdges(box)
                        );
                    }
                    return groupCount;
                }

                if (box !is null && box.HasStaticOutlineCache()) {
                    uint cachedCount = box.CachedStaticOutlineCount();
                    uint count = 0;
                    for (uint i = 0; i < cachedCount; i++) {
                        count += GetAdaptiveLineSegmentCount(
                            box.CachedStaticOutlineStarts[i],
                            box.CachedStaticOutlineEnds[i],
                            cameraPos,
                            ShouldSplitTriggerVolumeOutlineEdges(box)
                        );
                    }
                    return count;
                }

                if (box !is null && box.HasCustomOutlineGeometry()) {
                    uint customCount = 0;
                    uint outlineLineCount = box.OutlineLineCount();
                    for (uint i = 0; i < outlineLineCount; i++) {
                        customCount += GetAdaptiveLineSegmentCount(
                            box.OutlineLineStarts[i],
                            box.OutlineLineEnds[i],
                            cameraPos,
                            ShouldSplitTriggerVolumeOutlineEdges(box)
                        );
                    }
                    return customCount;
                }

                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return 0;

                uint count = 0;
                for (uint i = 0; i < TRIGGER_VOLUME_EDGE_INDICES.Length; i++) {
                    auto edge = TRIGGER_VOLUME_EDGE_INDICES[i];
                    count += GetAdaptiveLineSegmentCount(
                        corners[edge[0]],
                        corners[edge[1]],
                        cameraPos,
                        ShouldSplitTriggerVolumeOutlineEdges(box)
                    );
                }
                return count;
            }

            uint GetMaxTriggerVolumeOutlineEdgeSegments(const TriggerVolume@ box, const vec3 &in cameraPos) {
                if (box !is null && box.HasChildVolumes()) {
                    if (box.HasStaticOutlineCache()) {
                        uint groupMaxSegments = 0;
                        uint cachedCount = box.CachedStaticOutlineCount();
                        for (uint i = 0; i < cachedCount; i++) {
                            groupMaxSegments = Math::Max(
                                groupMaxSegments,
                                GetAdaptiveLineSegmentCount(box.CachedStaticOutlineStarts[i], box.CachedStaticOutlineEnds[i], cameraPos, ShouldSplitTriggerVolumeOutlineEdges(box))
                            );
                        }
                        return groupMaxSegments;
                    }

                    uint groupMaxSegments = 0;
                    if (box.HasCachedGroupGeometry()) {
                        uint cachedEdgeCount = box.CachedGroupOutlineEdgeCount();
                        for (uint i = 0; i < cachedEdgeCount; i++) {
                            if (IsCachedGroupOutlineEdgeDuplicate(box, i)) continue;
                            groupMaxSegments = Math::Max(
                                groupMaxSegments,
                                GetAdaptiveLineSegmentCount(box.CachedGroupOutlineEdgeStarts[i], box.CachedGroupOutlineEdgeEnds[i], cameraPos, ShouldSplitTriggerVolumeOutlineEdges(box))
                            );
                        }
                        return groupMaxSegments;
                    }

                    auto items = array<WorldOutlineEdgeDrawItem@>();
                    auto edgeKeys = array<string>();
                    auto edgeCounts = array<uint>();
                    CollectTriggerVolumeOutlineEdgeDrawItems(box, 0, items, edgeKeys, edgeCounts);

                    for (uint i = 0; i < items.Length; i++) {
                        if (items[i] is null) continue;
                        if (GetGeometryKeyCount(edgeKeys, edgeCounts, items[i].GeometryKey) > 1) continue;
                        groupMaxSegments = Math::Max(
                            groupMaxSegments,
                            GetAdaptiveLineSegmentCount(items[i].Start, items[i].End, cameraPos, ShouldSplitTriggerVolumeOutlineEdges(box))
                        );
                    }
                    return groupMaxSegments;
                }

                if (box !is null && box.HasStaticOutlineCache()) {
                    uint cachedCount = box.CachedStaticOutlineCount();
                    uint maxSegments = 0;
                    for (uint i = 0; i < cachedCount; i++) {
                        maxSegments = Math::Max(
                            maxSegments,
                            GetAdaptiveLineSegmentCount(box.CachedStaticOutlineStarts[i], box.CachedStaticOutlineEnds[i], cameraPos, ShouldSplitTriggerVolumeOutlineEdges(box))
                        );
                    }
                    return maxSegments;
                }

                if (box !is null && box.HasCustomOutlineGeometry()) {
                    uint customMaxSegments = 0;
                    uint outlineLineCount = box.OutlineLineCount();
                    for (uint i = 0; i < outlineLineCount; i++) {
                        customMaxSegments = Math::Max(
                            customMaxSegments,
                            GetAdaptiveLineSegmentCount(box.OutlineLineStarts[i], box.OutlineLineEnds[i], cameraPos, ShouldSplitTriggerVolumeOutlineEdges(box))
                        );
                    }
                    return customMaxSegments;
                }

                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return 0;

                uint maxSegments = 0;
                for (uint i = 0; i < TRIGGER_VOLUME_EDGE_INDICES.Length; i++) {
                    auto edge = TRIGGER_VOLUME_EDGE_INDICES[i];
                    maxSegments = Math::Max(
                        maxSegments,
                        GetAdaptiveLineSegmentCount(corners[edge[0]], corners[edge[1]], cameraPos, ShouldSplitTriggerVolumeOutlineEdges(box))
                    );
                }
                return maxSegments;
            }

            float GetLineFrustumResolveMinLength() {
                return Math::Max(
                    TriggerVisualizer::Trigger::Ui::S_LineSplitTargetSegmentLength,
                    TriggerVisualizer::Trigger::Ui::LINE_SPLIT_MINIMUM_SAFE_LENGTH
                );
            }

            bool ShouldResolveMixedWorldLineSegment(const vec3 &in start, const vec3 &in end, uint depth) {
                if (depth >= LINE_FRUSTUM_MAX_DEPTH) return false;
                return Math::Distance(start, end) > GetLineFrustumResolveMinLength();
            }

            bool DrawProjectedLineSegmentFrustumSafe(const vec3 &in start, const vec3 &in end, uint depth) {
                vec3 startScreenPos = Camera::ToScreen(start);
                vec3 endScreenPos = Camera::ToScreen(end);
                bool screenFront = startScreenPos.z < 0 && endScreenPos.z < 0;
                if (screenFront) {
                    if (!IsProjectedLinePotentiallyVisible(startScreenPos, endScreenPos, SCREEN_QUAD_VISIBILITY_MARGIN)) return false;
                    nvg::MoveTo(startScreenPos.xy);
                    nvg::LineTo(endScreenPos.xy);
                    return true;
                }

                bool anyScreenFront = startScreenPos.z < 0 || endScreenPos.z < 0;
                int primitiveClass = WORLD_PRIMITIVE_OUTSIDE;
                if (!g_WorldFrustumState.Valid) {
                    primitiveClass = anyScreenFront ? WORLD_PRIMITIVE_MIXED : WORLD_PRIMITIVE_OUTSIDE;
                } else {
                    primitiveClass = ClassifyCameraLineForFrustum(
                        WorldToFrustumCameraPoint(start),
                        WorldToFrustumCameraPoint(end)
                    );
                    if (primitiveClass == WORLD_PRIMITIVE_OUTSIDE && anyScreenFront) {
                        primitiveClass = WORLD_PRIMITIVE_MIXED;
                    }
                }
                if (primitiveClass == WORLD_PRIMITIVE_OUTSIDE) return false;
                if (primitiveClass == WORLD_PRIMITIVE_FRONT) return false;
                if (!ShouldResolveMixedWorldLineSegment(start, end, depth)) return false;

                vec3 mid = (start + end) * 0.5f;
                bool drewStart = DrawProjectedLineSegmentFrustumSafe(start, mid, depth + 1);
                bool drewEnd = DrawProjectedLineSegmentFrustumSafe(mid, end, depth + 1);
                return drewStart || drewEnd;
            }

            bool DrawWorldLineSegmentToCurrentPath(
                const vec3 &in start,
                const vec3 &in end
            ) {
                return DrawProjectedLineSegmentFrustumSafe(start, end, 0);
            }

            bool DrawWorldLineAdaptiveToCurrentPath(
                const vec3 &in start,
                const vec3 &in end,
                const vec3 &in cameraPos,
                bool allowAdaptiveSplitting
            ) {
                uint segmentCount = GetAdaptiveLineSegmentCount(
                    start,
                    end,
                    cameraPos,
                    allowAdaptiveSplitting
                );
                if (segmentCount <= 1) {
                    return DrawWorldLineSegmentToCurrentPath(start, end);
                }

                bool drewAny = false;
                float invSegments = 1.0f / float(segmentCount);
                for (uint i = 0; i < segmentCount; i++) {
                    float t0 = float(i) * invSegments;
                    float t1 = float(i + 1) * invSegments;
                    drewAny = DrawWorldLineSegmentToCurrentPath(
                        Math::Lerp(start, end, t0),
                        Math::Lerp(start, end, t1)
                    ) || drewAny;
                }
                return drewAny;
            }

            void DrawWorldLineSegmentImmediate(
                const vec3 &in start,
                const vec3 &in end,
                const vec4 &in color
            ) {
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
                uint edgeIndex,
                bool allowAdaptiveSplitting
            ) {
                uint segmentCount = GetAdaptiveLineSegmentCount(
                    start,
                    end,
                    cameraPos,
                    allowAdaptiveSplitting
                );
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
        }
    }
}
