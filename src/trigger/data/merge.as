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

            TriggerVolume@ CloneTriggerVolumeForMerge(const TriggerVolume@ source) {
                if (source is null) return TriggerVolume();

                auto copy = TriggerVolume(source.Min, source.Max, source.Source, source.SourceIndex, source.Label);
                copy.DetectedLabel = source.DetectedLabel;
                copy.SubtypeKey = source.SubtypeKey;
                copy.SubtypeLabel = source.SubtypeLabel;
                copy.TargetKeys = source.TargetKeys;
                copy.HasIslandIndex = source.HasIslandIndex;
                copy.IslandIndex = source.IslandIndex;
                copy.IslandCount = source.IslandCount;
                copy.IsMergedGroup = source.IsMergedGroup;
                copy.MergedVolumeCount = NormalizeMergedVolumeCount(source.MergedVolumeCount);
                copy.AllowRawRangeLabel = source.AllowRawRangeLabel;
                return copy;
            }

            TriggerVolume@ MergeTriggerVolumePair(const TriggerVolume@ a, const TriggerVolume@ b) {
                auto merged = CloneTriggerVolumeForMerge(a);
                merged.Min = vec3(
                    Math::Min(a.Min.x, b.Min.x),
                    Math::Min(a.Min.y, b.Min.y),
                    Math::Min(a.Min.z, b.Min.z)
                );
                merged.Max = vec3(
                    Math::Max(a.Max.x, b.Max.x),
                    Math::Max(a.Max.y, b.Max.y),
                    Math::Max(a.Max.z, b.Max.z)
                );
                merged.IsMergedGroup = true;
                merged.MergedVolumeCount = NormalizeMergedVolumeCount(a.MergedVolumeCount) + NormalizeMergedVolumeCount(b.MergedVolumeCount);
                merged.AllowRawRangeLabel = false;
                merged.HasIslandIndex = false;
                return merged;
            }

            array<TriggerVolume@> @MergeAdjacentTriggerVolumes(const array<TriggerVolume@> @volumes) {
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
        }
    }
}
