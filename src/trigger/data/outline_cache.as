namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            void ResetTriggerVolumeStaticOutlineCache(TriggerVolume@ volume) {
                if (volume is null) return;

                volume.StaticOutlineCacheReady = false;
                volume.CachedStaticOutlineStarts.Resize(0);
                volume.CachedStaticOutlineEnds.Resize(0);
                volume.CachedStaticOutlineBoxIndices.Resize(0);
                volume.CachedStaticOutlineEdgeIndices.Resize(0);
            }

            void AddTriggerVolumeStaticOutlinePrimitive(
                TriggerVolume@ volume,
                const vec3 &in start,
                const vec3 &in end,
                uint relativeBoxIndex,
                uint edgeIndex
            ) {
                if (volume is null) return;

                volume.CachedStaticOutlineStarts.InsertLast(start);
                volume.CachedStaticOutlineEnds.InsertLast(end);
                volume.CachedStaticOutlineBoxIndices.InsertLast(relativeBoxIndex);
                volume.CachedStaticOutlineEdgeIndices.InsertLast(edgeIndex);
            }

            bool IsCachedGroupOutlineEdgeInternal(const TriggerVolume@ volume, uint edgeIndex) {
                if (volume is null || edgeIndex >= volume.CachedGroupOutlineEdgeKeys.Length) return false;
                return GetTriggerGeometryKeyCount(
                    volume.CachedGroupOutlineEdgeCountKeys,
                    volume.CachedGroupOutlineEdgeCounts,
                    volume.CachedGroupOutlineEdgeKeys[edgeIndex]
                ) > 1;
            }

            bool BuildGroupedTriggerVolumeStaticOutlineCache(TriggerVolume@ volume) {
                if (volume is null || !volume.HasCachedGroupGeometry()) return false;

                uint count = volume.CachedGroupOutlineEdgeCount();
                for (uint i = 0; i < count; i++) {
                    if (IsCachedGroupOutlineEdgeInternal(volume, i)) continue;
                    AddTriggerVolumeStaticOutlinePrimitive(
                        volume,
                        volume.CachedGroupOutlineEdgeStarts[i],
                        volume.CachedGroupOutlineEdgeEnds[i],
                        volume.CachedGroupOutlineEdgeBoxIndices[i],
                        volume.CachedGroupOutlineEdgeIndices[i]
                    );
                }
                return true;
            }

            bool BuildCustomTriggerVolumeStaticOutlineCache(TriggerVolume@ volume) {
                if (volume is null || !volume.HasCustomOutlineGeometry()) return false;

                uint count = volume.OutlineLineCount();
                for (uint i = 0; i < count; i++) {
                    AddTriggerVolumeStaticOutlinePrimitive(
                        volume,
                        volume.OutlineLineStarts[i],
                        volume.OutlineLineEnds[i],
                        0,
                        i
                    );
                }
                return true;
            }

            bool BuildBoxTriggerVolumeStaticOutlineCache(TriggerVolume@ volume) {
                if (volume is null) return false;

                for (uint i = 0; i < TRIGGER_VOLUME_BOX_EDGE_INDICES.Length; i++) {
                    auto edge = TRIGGER_VOLUME_BOX_EDGE_INDICES[i];
                    AddTriggerVolumeStaticOutlinePrimitive(
                        volume,
                        GetTriggerVolumeCorner(volume, edge[0]),
                        GetTriggerVolumeCorner(volume, edge[1]),
                        0,
                        i
                    );
                }
                return true;
            }

            void BuildTriggerVolumeStaticOutlineCache(TriggerVolume@ volume) {
                ResetTriggerVolumeStaticOutlineCache(volume);
                if (volume is null) return;

                bool built = false;
                if (volume.HasChildVolumes()) {
                    built = BuildGroupedTriggerVolumeStaticOutlineCache(volume);
                } else if (volume.HasCustomOutlineGeometry()) {
                    built = BuildCustomTriggerVolumeStaticOutlineCache(volume);
                } else {
                    built = BuildBoxTriggerVolumeStaticOutlineCache(volume);
                }
                volume.StaticOutlineCacheReady = built;
            }

            void BuildMapSnapshotStaticOutlineCache(MapSnapshot@ snapshot) {
                if (snapshot is null) return;

                for (uint i = 0; i < snapshot.TriggerVolumes.Length; i++) {
                    BuildTriggerVolumeStaticOutlineCache(snapshot.TriggerVolumes[i]);
                }
            }
        }
    }
}
