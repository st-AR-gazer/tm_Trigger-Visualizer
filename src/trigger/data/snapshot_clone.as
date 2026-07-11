namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            TriggerVolume@ CloneTriggerVolumeForSnapshotCache(const TriggerVolume@ source) {
                if (source is null) return TriggerVolume();

                auto copy = CloneTriggerVolumeForMerge(source);
                copy.ChildVolumes.Resize(0);
                for (uint i = 0; i < source.ChildVolumes.Length; i++) {
                    copy.ChildVolumes.InsertLast(CloneTriggerVolumeForSnapshotCache(source.ChildVolumes[i]));
                }
                if (copy.HasChildVolumes()) {
                    BuildTriggerVolumeGroupGeometryCache(copy);
                }
                return copy;
            }

            TriggerSourceSnapshot@ CloneTriggerSourceSnapshotForCache(const TriggerSourceSnapshot@ source) {
                if (source is null) return TriggerSourceSnapshot();

                auto copy = TriggerSourceSnapshot(source.Source, source.Enabled);
                copy.Name = source.Name;
                copy.RawTriggerSize = source.RawTriggerSize;
                copy.RawBufferPtr = source.RawBufferPtr;
                copy.RawClipCount = source.RawClipCount;
                copy.RawTriggerCount = source.RawTriggerCount;
                copy.RawTriggerCapacity = source.RawTriggerCapacity;
                copy.RawCoordCount = source.RawCoordCount;
                copy.ReadableTriggerCount = source.ReadableTriggerCount;
                copy.BadTriggerCount = source.BadTriggerCount;
                copy.RawBlockCount = source.RawBlockCount;
                copy.RawBakedBlockCount = source.RawBakedBlockCount;
                copy.RawAnchoredObjectCount = source.RawAnchoredObjectCount;
                copy.CandidateShapeCount = source.CandidateShapeCount;
                copy.ReadableShapeCount = source.ReadableShapeCount;
                copy.UnsupportedShapeCount = source.UnsupportedShapeCount;
                copy.RenderedShapeCount = source.RenderedShapeCount;
                copy.RejectedShapeCount = source.RejectedShapeCount;
                copy.MapSize = source.MapSize;
                @copy.GridSpec = source.GridSpec;
                copy.RawRanges = source.RawRanges;
                for (uint i = 0; i < source.TriggerVolumes.Length; i++) {
                    copy.TriggerVolumes.InsertLast(CloneTriggerVolumeForSnapshotCache(source.TriggerVolumes[i]));
                }
                for (uint i = 0; i < source.CachedExpandableMergeSourceVolumes.Length; i++) {
                    copy.CachedExpandableMergeSourceVolumes.InsertLast(CloneTriggerVolumeForSnapshotCache(source.CachedExpandableMergeSourceVolumes[i]));
                }
                copy.Diagnostics = source.Diagnostics;
                copy.MediaTrackerClipTriggers = source.MediaTrackerClipTriggers;
                copy.CrystalTriggerProbes = source.CrystalTriggerProbes;

                return copy;
            }
        }
    }
}
