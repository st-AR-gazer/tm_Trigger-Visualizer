namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            const float TRIGGER_VOLUME_MERGE_EPSILON = 0.001f;

            bool NearlyEqual(float a, float b) {
                return Math::Abs(a - b) <= TRIGGER_VOLUME_MERGE_EPSILON;
            }

            bool IntervalsMatch(float aMin, float aMax, float bMin, float bMax) {
                return NearlyEqual(aMin, bMin) && NearlyEqual(aMax, bMax);
            }

            bool IntervalsTouchOrOverlap(float aMin, float aMax, float bMin, float bMax) {
                return aMax + TRIGGER_VOLUME_MERGE_EPSILON >= bMin
                    && bMax + TRIGGER_VOLUME_MERGE_EPSILON >= aMin;
            }

            bool IntervalsOverlapWithArea(float aMin, float aMax, float bMin, float bMax) {
                return Math::Min(aMax, bMax) - Math::Max(aMin, bMin) > TRIGGER_VOLUME_MERGE_EPSILON;
            }

            uint NormalizeMergedVolumeCount(uint count) {
                return count == 0 ? 1 : count;
            }

            bool TriggerVolumesHaveCompatibleMergeMetadata(const TriggerVolume@ a, const TriggerVolume@ b) {
                if (a is null || b is null) return false;
                if (a.Source != b.Source) return false;
                if (a.SubtypeKey != b.SubtypeKey) return false;
                if (a.SubtypeLabel != b.SubtypeLabel) return false;
                if (a.DetectedLabel != b.DetectedLabel) return false;
                if (a.TargetKeys != b.TargetKeys) return false;

                if (a.Source == TRIGGER_SOURCE_OFFZONE) return true;

                return a.SourceIndex == b.SourceIndex && a.Label == b.Label;
            }

            bool CanMergeTriggerVolumesOnX(const TriggerVolume@ a, const TriggerVolume@ b) {
                return IntervalsMatch(a.Min.y, a.Max.y, b.Min.y, b.Max.y)
                    && IntervalsMatch(a.Min.z, a.Max.z, b.Min.z, b.Max.z)
                    && IntervalsTouchOrOverlap(a.Min.x, a.Max.x, b.Min.x, b.Max.x);
            }

            bool CanMergeTriggerVolumesOnY(const TriggerVolume@ a, const TriggerVolume@ b) {
                return IntervalsMatch(a.Min.x, a.Max.x, b.Min.x, b.Max.x)
                    && IntervalsMatch(a.Min.z, a.Max.z, b.Min.z, b.Max.z)
                    && IntervalsTouchOrOverlap(a.Min.y, a.Max.y, b.Min.y, b.Max.y);
            }

            bool CanMergeTriggerVolumesOnZ(const TriggerVolume@ a, const TriggerVolume@ b) {
                return IntervalsMatch(a.Min.x, a.Max.x, b.Min.x, b.Max.x)
                    && IntervalsMatch(a.Min.y, a.Max.y, b.Min.y, b.Max.y)
                    && IntervalsTouchOrOverlap(a.Min.z, a.Max.z, b.Min.z, b.Max.z);
            }

            bool CanMergeTriggerVolumes(const TriggerVolume@ a, const TriggerVolume@ b) {
                if (!TriggerVolumesHaveCompatibleMergeMetadata(a, b)) return false;
                return CanMergeTriggerVolumesOnX(a, b)
                    || CanMergeTriggerVolumesOnY(a, b)
                    || CanMergeTriggerVolumesOnZ(a, b);
            }

            bool CanConnectTriggerVolumesOnX(const TriggerVolume@ a, const TriggerVolume@ b) {
                return IntervalsTouchOrOverlap(a.Min.x, a.Max.x, b.Min.x, b.Max.x)
                    && IntervalsOverlapWithArea(a.Min.y, a.Max.y, b.Min.y, b.Max.y)
                    && IntervalsOverlapWithArea(a.Min.z, a.Max.z, b.Min.z, b.Max.z);
            }

            bool CanConnectTriggerVolumesOnY(const TriggerVolume@ a, const TriggerVolume@ b) {
                return IntervalsOverlapWithArea(a.Min.x, a.Max.x, b.Min.x, b.Max.x)
                    && IntervalsTouchOrOverlap(a.Min.y, a.Max.y, b.Min.y, b.Max.y)
                    && IntervalsOverlapWithArea(a.Min.z, a.Max.z, b.Min.z, b.Max.z);
            }

            bool CanConnectTriggerVolumesOnZ(const TriggerVolume@ a, const TriggerVolume@ b) {
                return IntervalsOverlapWithArea(a.Min.x, a.Max.x, b.Min.x, b.Max.x)
                    && IntervalsOverlapWithArea(a.Min.y, a.Max.y, b.Min.y, b.Max.y)
                    && IntervalsTouchOrOverlap(a.Min.z, a.Max.z, b.Min.z, b.Max.z);
            }

            bool CanConnectTriggerVolumes(const TriggerVolume@ a, const TriggerVolume@ b) {
                if (!TriggerVolumesHaveCompatibleMergeMetadata(a, b)) return false;
                return CanConnectTriggerVolumesOnX(a, b)
                    || CanConnectTriggerVolumesOnY(a, b)
                    || CanConnectTriggerVolumesOnZ(a, b);
            }

            TriggerVolume@ CloneTriggerVolumeForMerge(const TriggerVolume@ source) {
                if (source is null) return TriggerVolume();

                auto copy = TriggerVolume(source.Min, source.Max, source.Source, source.SourceIndex, source.Label);
                copy.DetectedLabel = source.DetectedLabel;
                copy.SubtypeKey = source.SubtypeKey;
                copy.SubtypeLabel = source.SubtypeLabel;
                copy.TargetKeys = source.TargetKeys;
                copy.HasMediaTrackerTrackColor = source.HasMediaTrackerTrackColor;
                copy.MediaTrackerTrackColor = source.MediaTrackerTrackColor;
                copy.HasTriggerTypeColor = source.HasTriggerTypeColor;
                copy.TriggerTypeColor = source.TriggerTypeColor;
                copy.HasIslandIndex = source.HasIslandIndex;
                copy.IslandIndex = source.IslandIndex;
                copy.IslandCount = source.IslandCount;
                copy.IsMergedGroup = source.IsMergedGroup;
                copy.MergedVolumeCount = NormalizeMergedVolumeCount(source.MergedVolumeCount);
                copy.AllowRawRangeLabel = source.AllowRawRangeLabel;
                copy.OutlineShapeKind = source.OutlineShapeKind;
                uint outlineLineCount = source.OutlineLineCount();
                for (uint i = 0; i < outlineLineCount; i++) {
                    copy.OutlineLineStarts.InsertLast(source.OutlineLineStarts[i]);
                    copy.OutlineLineEnds.InsertLast(source.OutlineLineEnds[i]);
                }
                return copy;
            }

            void ExpandTriggerVolumeBounds(TriggerVolume@ target, const TriggerVolume@ source) {
                if (target is null || source is null) return;
                target.Min = vec3(
                    Math::Min(target.Min.x, source.Min.x),
                    Math::Min(target.Min.y, source.Min.y),
                    Math::Min(target.Min.z, source.Min.z)
                );
                target.Max = vec3(
                    Math::Max(target.Max.x, source.Max.x),
                    Math::Max(target.Max.y, source.Max.y),
                    Math::Max(target.Max.z, source.Max.z)
                );
            }

            string GetTriggerVolumeCachedFaceGeometryKey(const TriggerVolume@ box, const uint[]@ face) {
                if (box is null || face is null || face.Length != 4) return "";

                return GetTriggerQuadGeometryKey(
                    GetTriggerVolumeCorner(box, face[0]),
                    GetTriggerVolumeCorner(box, face[1]),
                    GetTriggerVolumeCorner(box, face[2]),
                    GetTriggerVolumeCorner(box, face[3])
                );
            }

            void AddTriggerVolumeGroupFaceGeometryCounts(
                const TriggerVolume@ box,
                array<string> @keys,
                array<uint> @counts
            ) {
                if (box is null || keys is null || counts is null) return;

                if (box.HasChildVolumes()) {
                    for (uint i = 0; i < box.ChildVolumes.Length; i++) {
                        AddTriggerVolumeGroupFaceGeometryCounts(
                            box.ChildVolumes[i],
                            keys,
                            counts
                        );
                    }
                    return;
                }

                for (uint i = 0; i < TRIGGER_VOLUME_BOX_FACE_INDICES.Length; i++) {
                    AddTriggerGeometryKeyCount(
                        keys,
                        counts,
                        GetTriggerVolumeCachedFaceGeometryKey(box, TRIGGER_VOLUME_BOX_FACE_INDICES[i])
                    );
                }
            }

            void AddTriggerVolumeCachedGroupOutlineEdge(
                TriggerVolume@ group,
                const vec3 &in start,
                const vec3 &in end,
                uint relativeBoxIndex,
                uint edgeIndex
            ) {
                if (group is null) return;

                string key = GetTriggerLineGeometryKey(start, end);
                group.CachedGroupOutlineEdgeStarts.InsertLast(start);
                group.CachedGroupOutlineEdgeEnds.InsertLast(end);
                group.CachedGroupOutlineEdgeBoxIndices.InsertLast(relativeBoxIndex);
                group.CachedGroupOutlineEdgeIndices.InsertLast(edgeIndex);
                group.CachedGroupOutlineEdgeKeys.InsertLast(key);
                AddTriggerGeometryKeyCount(
                    group.CachedGroupOutlineEdgeCountKeys,
                    group.CachedGroupOutlineEdgeCounts,
                    key
                );
            }

            void AddTriggerVolumeGroupOutlineGeometryCache(
                TriggerVolume@ group,
                const TriggerVolume@ box,
                uint relativeBoxIndex
            ) {
                if (group is null || box is null) return;

                if (box.HasChildVolumes()) {
                    for (uint i = 0; i < box.ChildVolumes.Length; i++) {
                        AddTriggerVolumeGroupOutlineGeometryCache(
                            group,
                            box.ChildVolumes[i],
                            relativeBoxIndex + i + 1
                        );
                    }
                    return;
                }

                if (box.HasCustomOutlineGeometry()) {
                    uint outlineLineCount = box.OutlineLineCount();
                    for (uint i = 0; i < outlineLineCount; i++) {
                        AddTriggerVolumeCachedGroupOutlineEdge(
                            group,
                            box.OutlineLineStarts[i],
                            box.OutlineLineEnds[i],
                            relativeBoxIndex,
                            i
                        );
                    }
                    return;
                }

                for (uint i = 0; i < TRIGGER_VOLUME_BOX_EDGE_INDICES.Length; i++) {
                    auto edge = TRIGGER_VOLUME_BOX_EDGE_INDICES[i];
                    AddTriggerVolumeCachedGroupOutlineEdge(
                        group,
                        GetTriggerVolumeCorner(box, edge[0]),
                        GetTriggerVolumeCorner(box, edge[1]),
                        relativeBoxIndex,
                        i
                    );
                }
            }

            void ResetTriggerVolumeGroupGeometryCache(TriggerVolume@ group) {
                if (group is null) return;

                group.GroupGeometryCacheReady = false;
                group.CachedGroupFaceKeys.Resize(0);
                group.CachedGroupFaceCounts.Resize(0);
                group.CachedGroupOutlineEdgeStarts.Resize(0);
                group.CachedGroupOutlineEdgeEnds.Resize(0);
                group.CachedGroupOutlineEdgeBoxIndices.Resize(0);
                group.CachedGroupOutlineEdgeIndices.Resize(0);
                group.CachedGroupOutlineEdgeKeys.Resize(0);
                group.CachedGroupOutlineEdgeCountKeys.Resize(0);
                group.CachedGroupOutlineEdgeCounts.Resize(0);
            }

            void BuildTriggerVolumeGroupGeometryCache(TriggerVolume@ group) {
                ResetTriggerVolumeGroupGeometryCache(group);
                if (group is null || !group.HasChildVolumes()) return;

                AddTriggerVolumeGroupFaceGeometryCounts(
                    group,
                    group.CachedGroupFaceKeys,
                    group.CachedGroupFaceCounts
                );
                AddTriggerVolumeGroupOutlineGeometryCache(
                    group,
                    group,
                    0
                );
                group.GroupGeometryCacheReady = true;
            }

            TriggerVolume@ MergeTriggerVolumePair(const TriggerVolume@ a, const TriggerVolume@ b) {
                auto merged = CloneTriggerVolumeForMerge(a);
                ExpandTriggerVolumeBounds(merged, b);
                merged.IsMergedGroup = true;
                merged.MergedVolumeCount = NormalizeMergedVolumeCount(a.MergedVolumeCount) + NormalizeMergedVolumeCount(b.MergedVolumeCount);
                merged.AllowRawRangeLabel = false;
                merged.HasIslandIndex = false;
                if (merged.Source == TRIGGER_SOURCE_OFFZONE) {
                    merged.Label = "";
                }
                return merged;
            }

            array<TriggerVolume@> @MergeAlignedTriggerCuboids(const array<TriggerVolume@> @volumes) {
                auto merged = array<TriggerVolume@>();
                if (volumes is null) return merged;

                for (uint i = 0; i < volumes.Length; i++) {
                    if (volumes[i] is null) continue;
                    merged.InsertLast(CloneTriggerVolumeForMerge(volumes[i]));
                }

                bool changed = true;
                while (changed) {
                    changed = false;

                    for (uint i = 0; i < merged.Length && !changed; i++) {
                        for (uint j = i + 1; j < merged.Length; j++) {
                            if (!CanMergeTriggerVolumes(merged[i], merged[j])) continue;

                            @merged[i] = MergeTriggerVolumePair(merged[i], merged[j]);
                            merged.RemoveAt(j);
                            changed = true;
                            break;
                        }
                    }
                }

                return merged;
            }

            TriggerVolume@ BuildConnectedTriggerVolumeGroup(const array<TriggerVolume@> @members, uint groupIndex) {
                if (members is null || members.Length == 0) return TriggerVolume();

                auto group = CloneTriggerVolumeForMerge(members[0]);
                group.IsMergedGroup = true;
                group.AllowRawRangeLabel = false;
                group.HasIslandIndex = false;
                group.MergedVolumeCount = 0;
                if (group.Source == TRIGGER_SOURCE_OFFZONE) {
                    group.SourceIndex = groupIndex;
                    group.Label = "";
                }

                for (uint i = 0; i < members.Length; i++) {
                    if (members[i] is null) continue;
                    ExpandTriggerVolumeBounds(group, members[i]);
                    group.MergedVolumeCount += NormalizeMergedVolumeCount(members[i].MergedVolumeCount);
                    group.ChildVolumes.InsertLast(CloneTriggerVolumeForMerge(members[i]));
                }
                if (group.MergedVolumeCount == 0) {
                    group.MergedVolumeCount = uint(group.ChildVolumes.Length);
                }
                BuildTriggerVolumeGroupGeometryCache(group);

                return group;
            }

            array<TriggerVolume@> @GroupConnectedTriggerVolumes(const array<TriggerVolume@> @volumes) {
                auto grouped = array<TriggerVolume@>();
                if (volumes is null) return grouped;

                auto consumed = array<bool>(volumes.Length, false);
                uint groupIndex = 0;

                for (uint i = 0; i < volumes.Length; i++) {
                    if (consumed[i] || volumes[i] is null) continue;

                    auto memberIndices = array<uint>();
                    auto pending = array<uint>();
                    pending.InsertLast(i);
                    consumed[i] = true;
                    uint pendingIndex = 0;
                    while (pendingIndex < pending.Length) {
                        uint current = pending[pendingIndex++];
                        memberIndices.InsertLast(current);

                        for (uint j = 0; j < volumes.Length; j++) {
                            if (consumed[j] || volumes[j] is null) continue;
                            if (!CanConnectTriggerVolumes(volumes[current], volumes[j])) continue;

                            consumed[j] = true;
                            pending.InsertLast(j);
                        }
                    }

                    if (memberIndices.Length <= 1) {
                        grouped.InsertLast(CloneTriggerVolumeForMerge(volumes[i]));
                        continue;
                    }

                    auto members = array<TriggerVolume@>();
                    for (uint j = 0; j < memberIndices.Length; j++) {
                        members.InsertLast(volumes[memberIndices[j]]);
                    }
                    grouped.InsertLast(BuildConnectedTriggerVolumeGroup(members, groupIndex++));
                }

                return grouped;
            }

            array<TriggerVolume@> @MergeAdjacentTriggerVolumes(const array<TriggerVolume@> @volumes) {
                auto mergedCuboids = MergeAlignedTriggerCuboids(volumes);
                return GroupConnectedTriggerVolumes(mergedCuboids);
            }
        }
    }
}
