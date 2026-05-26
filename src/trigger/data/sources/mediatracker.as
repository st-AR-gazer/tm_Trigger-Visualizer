namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                // ty XertroV for the RE :PeepoHeart:

                const uint16 O_MAP_CLIPAMBIANCE = GetMemberOffset("CGameCtnChallenge", "ClipAmbiance");
                const uint16 O_MAP_MEDIATRACKER_SIZE_OFFSET = O_MAP_CLIPAMBIANCE + 0x18;

                const uint16 O_MT_CLIPGROUP_TRIGGER_BUFFER = 0x28;
                const uint16 O_MT_TRIGGER_MIN_COORDS = 0x0;
                const uint16 O_MT_TRIGGER_MAX_COORDS = 0xC;
                const uint16 O_MT_TRIGGER_COORD_BUFFER = 0x18;
                const uint16 SZ_MT_CLIPGROUP_TRIGGER_STRUCT = 0x40;

                const uint64 BASE_ADDR_END = Dev::BaseAddressEnd();

                const uint MAX_MEDIATRACKER_TRIGGER_PROBE_COUNT = 128;
                const uint MAX_MEDIATRACKER_TRIGGER_CAPACITY = 4096;
                const uint MAX_MEDIATRACKER_COORD_SAMPLES_PER_TRIGGER = 16;
                const uint MAX_MEDIATRACKER_RENDER_COORDS_PER_TRIGGER = 4096;
                const uint MAX_MEDIATRACKER_RENDER_COORDS_TOTAL = 20000;
                const uint MEDIATRACKER_MAP_BOUNDS_MARGIN_BLOCKS = 16;

                bool IsLikelyReadablePointer(uint64 ptr) {
                    if (ptr == 0) return false;
                    if (ptr < 0x10000000000) return false;
                    if ((ptr & 0x7) != 0) return false;
                    if ((ptr >> 48) > 0) return false;
                    if (BASE_ADDR_END > 0 && ptr > BASE_ADDR_END) return false;
                    return true;
                }

                bool CanSafelyTouchPointer(uint64 ptr) {
                    if (!IsLikelyReadablePointer(ptr)) return false;

                    try {
                        Dev::SafeReadUInt64(ptr);
                    } catch {
                        return false;
                    }

                    return true;
                }

                uint MinUint(uint a, uint b) {
                    return a < b ? a : b;
                }

                uint SaturatingAddUint(uint a, uint b) {
                    if (4294967295 - a < b) return 4294967295;
                    return a + b;
                }

                uint64 ExpectedMaxCoordAxis(uint blocks, uint cellsPerBlock) {
                    return uint64(blocks + MEDIATRACKER_MAP_BOUNDS_MARGIN_BLOCKS) * uint64(Math::Max(cellsPerBlock, 1));
                }

                int3 Nat3ToInt3(const nat3 &in coord) {
                    return int3(int(coord.x), int(coord.y), int(coord.z));
                }

                bool IsOrderedCoordRange(const nat3 &in minCoord, const nat3 &in maxCoord) {
                    return minCoord.x <= maxCoord.x
                        && minCoord.y <= maxCoord.y
                        && minCoord.z <= maxCoord.z;
                }

                bool IsCoordWithinExpectedMapBounds(
                    const nat3 &in coord,
                    const nat3 &in mapSize,
                    const nat3 &in cellsPerBlock
                ) {
                    return uint64(coord.x) <= ExpectedMaxCoordAxis(mapSize.x, cellsPerBlock.x)
                        && uint64(coord.y) <= ExpectedMaxCoordAxis(mapSize.y + uint(OFFZONE_WORLD_Y_ANCHOR), cellsPerBlock.y)
                        && uint64(coord.z) <= ExpectedMaxCoordAxis(mapSize.z, cellsPerBlock.z);
                }

                bool IsCoordRangeWithinExpectedMapBounds(
                    const nat3 &in minCoord,
                    const nat3 &in maxCoord,
                    const nat3 &in mapSize,
                    const nat3 &in cellsPerBlock
                ) {
                    return IsCoordWithinExpectedMapBounds(minCoord, mapSize, cellsPerBlock)
                        && IsCoordWithinExpectedMapBounds(maxCoord, mapSize, cellsPerBlock);
                }

                nat3 ReadMediaTrackerTriggerSize(CGameCtnChallenge@ map) {
                    if (map is null) return nat3(1, 1, 1);
                    return Dev::GetOffsetNat3(map, O_MAP_MEDIATRACKER_SIZE_OFFSET);
                }

                uint ReadMediaTrackerClipGroupTriggerCount(CGameCtnMediaClipGroup@ clipGroup) {
                    if (clipGroup is null) return 0;
                    return Dev::GetOffsetUint32(clipGroup, O_MT_CLIPGROUP_TRIGGER_BUFFER + 0x8);
                }

                uint ReadMediaTrackerClipGroupTriggerCapacity(CGameCtnMediaClipGroup@ clipGroup) {
                    if (clipGroup is null) return 0;
                    return Dev::GetOffsetUint32(clipGroup, O_MT_CLIPGROUP_TRIGGER_BUFFER + 0xC);
                }

                uint64 ReadMediaTrackerClipGroupTriggerBufferPtr(CGameCtnMediaClipGroup@ clipGroup) {
                    if (clipGroup is null) return 0;
                    return Dev::GetOffsetUint64(clipGroup, O_MT_CLIPGROUP_TRIGGER_BUFFER);
                }

                array<int3> @ReadMediaTrackerTriggerCoords(
                    uint64 bufferPtr,
                    uint coordCount
                ) {
                    auto coords = array<int3>();
                    if (coordCount == 0 || bufferPtr == 0) return coords;

                    coords.Reserve(coordCount);
                    for (uint i = 0; i < coordCount; i++) {
                        try {
                            coords.InsertLast(Nat3ToInt3(Dev::SafeReadNat3(bufferPtr + i * 0xC)));
                        } catch {
                            break;
                        }
                    }

                    return coords;
                }

                array<int3> @ReadMediaTrackerTriggerCoordSamples(
                    uint64 bufferPtr,
                    uint coordCount,
                    uint maxSamples
                ) {
                    auto coords = array<int3>();
                    if (coordCount == 0 || bufferPtr == 0 || maxSamples == 0) return coords;

                    uint sampleCount = MinUint(coordCount, maxSamples);
                    coords.Reserve(sampleCount);
                    for (uint i = 0; i < sampleCount; i++) {
                        try {
                            coords.InsertLast(Nat3ToInt3(Dev::SafeReadNat3(bufferPtr + i * 0xC)));
                        } catch {
                            break;
                        }
                    }

                    return coords;
                }

                array<int3> @CopyMediaTrackerTriggerCoordSamples(
                    const array<int3> @coords,
                    uint maxSamples
                ) {
                    auto samples = array<int3>();
                    if (coords is null || maxSamples == 0) return samples;

                    uint sampleCount = MinUint(coords.Length, maxSamples);
                    samples.Reserve(sampleCount);
                    for (uint i = 0; i < sampleCount; i++) {
                        samples.InsertLast(coords[i]);
                    }

                    return samples;
                }

                TriggerVolume@ MediaTrackerCoordToTriggerVolume(
                    const int3 &in coord,
                    const TriggerGridSpec@ spec,
                    uint clipIndex,
                    const string &in clipName
                ) {
                    vec3 min = TriggerCoordToWorldPos(coord, spec);
                    vec3 max = TriggerCoordToWorldPos(coord + int3(1, 1, 1), spec);
                    return TriggerVolume(
                        min,
                        max,
                        TRIGGER_SOURCE_MEDIATRACKER,
                        clipIndex,
                        "MediaTracker #" + tostring(clipIndex) + ": " + clipName
                    );
                }

                TriggerVolume@ MediaTrackerBoundsToTriggerVolume(
                    const nat3 &in minCoord,
                    const nat3 &in maxCoord,
                    const TriggerGridSpec@ spec,
                    uint clipIndex,
                    const string &in clipName
                ) {
                    vec3 min = TriggerCoordToWorldPos(Nat3ToInt3(minCoord), spec);
                    vec3 max = TriggerCoordToWorldPos(Nat3ToInt3(maxCoord) + int3(1, 1, 1), spec);
                    return TriggerVolume(
                        min,
                        max,
                        TRIGGER_SOURCE_MEDIATRACKER,
                        clipIndex,
                        "MediaTracker #" + tostring(clipIndex) + ": " + clipName
                    );
                }

                MediaTrackerClipTriggerSnapshot@ ReadMediaTrackerClipTrigger(
                    CGameCtnMediaClipGroup@ clipGroup,
                    uint clipIndex,
                    uint64 triggerPtr,
                    const nat3 &in mapSize,
                    const nat3 &in cellsPerBlock,
                    uint renderCoordBudgetRemaining,
                    bool readRenderCells
                ) {
                    auto trigger = MediaTrackerClipTriggerSnapshot();
                    trigger.ClipIndex = clipIndex;
                    trigger.TriggerStructPtr = triggerPtr;

                    if (clipGroup !is null && clipIndex < clipGroup.Clips.Length) {
                        auto clip = clipGroup.Clips[clipIndex];
                        trigger.HasClip = clip !is null;
                        if (clip !is null) {
                            trigger.ClipName = string(clip.Name);
                        } else {
                            trigger.ClipName = "<null clip>";
                        }
                    } else {
                        trigger.ClipName = "<missing clip>";
                    }

                    if (!CanSafelyTouchPointer(triggerPtr)) {
                        trigger.Warning = "Bad trigger struct pointer: " + Text::FormatPointer(triggerPtr);
                        return trigger;
                    }

                    trigger.MinCoord = Dev::SafeReadNat3(triggerPtr + O_MT_TRIGGER_MIN_COORDS);
                    trigger.MaxCoord = Dev::SafeReadNat3(triggerPtr + O_MT_TRIGGER_MAX_COORDS);
                    trigger.CoordBufferPtr = Dev::SafeReadUInt64(triggerPtr + O_MT_TRIGGER_COORD_BUFFER);
                    trigger.RawCoordCount = Dev::SafeReadUInt32(triggerPtr + O_MT_TRIGGER_COORD_BUFFER + 0x8);
                    trigger.RawCoordCapacity = Dev::SafeReadUInt32(triggerPtr + O_MT_TRIGGER_COORD_BUFFER + 0xC);

                    if (!IsOrderedCoordRange(trigger.MinCoord, trigger.MaxCoord)) {
                        trigger.Warning = "Coordinate bounds are not ordered.";
                        return trigger;
                    }

                    if (!IsCoordRangeWithinExpectedMapBounds(trigger.MinCoord, trigger.MaxCoord, mapSize, cellsPerBlock)) {
                        trigger.Warning = "Coordinate bounds are outside expected map limits.";
                        return trigger;
                    }

                    if (trigger.RawCoordCount > trigger.RawCoordCapacity) {
                        trigger.Warning = "Coordinate count exceeds capacity.";
                        return trigger;
                    }

                    if (trigger.RawCoordCapacity > MAX_MEDIATRACKER_RENDER_COORDS_TOTAL) {
                        trigger.Warning = "Coordinate capacity is suspiciously large.";
                        return trigger;
                    }

                    trigger.HasReadableCoordBuffer = trigger.RawCoordCount == 0 || CanSafelyTouchPointer(trigger.CoordBufferPtr);
                    if (!trigger.HasReadableCoordBuffer) {
                        trigger.Warning = "Bad coordinate buffer pointer: " + Text::FormatPointer(trigger.CoordBufferPtr);
                        return trigger;
                    }

                    if (!readRenderCells) {
                        trigger.RenderCoordsSkipped = true;
                        trigger.RawCoordSamples = ReadMediaTrackerTriggerCoordSamples(
                            trigger.CoordBufferPtr,
                            trigger.RawCoordCount,
                            MAX_MEDIATRACKER_COORD_SAMPLES_PER_TRIGGER
                        );
                        trigger.SampledCoordCount = trigger.RawCoordSamples.Length;
                        trigger.CoordSamplesTruncated = trigger.RawCoordCount > trigger.SampledCoordCount;
                        return trigger;
                    }

                    if (trigger.RawCoordCount > MAX_MEDIATRACKER_RENDER_COORDS_PER_TRIGGER) {
                        trigger.RenderCoordsSkipped = true;
                        trigger.Warning = "Coordinate count exceeds render cap of " + tostring(MAX_MEDIATRACKER_RENDER_COORDS_PER_TRIGGER) + ".";
                        trigger.RawCoordSamples = ReadMediaTrackerTriggerCoordSamples(
                            trigger.CoordBufferPtr,
                            trigger.RawCoordCount,
                            MAX_MEDIATRACKER_COORD_SAMPLES_PER_TRIGGER
                        );
                        trigger.SampledCoordCount = trigger.RawCoordSamples.Length;
                        trigger.CoordSamplesTruncated = trigger.RawCoordCount > trigger.SampledCoordCount;
                        return trigger;
                    }

                    if (trigger.RawCoordCount > renderCoordBudgetRemaining) {
                        trigger.RenderCoordsSkipped = true;
                        trigger.Warning = "Total MediaTracker render coordinate budget exhausted.";
                        trigger.RawCoordSamples = ReadMediaTrackerTriggerCoordSamples(
                            trigger.CoordBufferPtr,
                            trigger.RawCoordCount,
                            MAX_MEDIATRACKER_COORD_SAMPLES_PER_TRIGGER
                        );
                        trigger.SampledCoordCount = trigger.RawCoordSamples.Length;
                        trigger.CoordSamplesTruncated = trigger.RawCoordCount > trigger.SampledCoordCount;
                        return trigger;
                    }

                    trigger.RawCoords = ReadMediaTrackerTriggerCoords(
                        trigger.CoordBufferPtr,
                        trigger.RawCoordCount
                    );
                    trigger.RawCoordSamples = CopyMediaTrackerTriggerCoordSamples(
                        trigger.RawCoords,
                        MAX_MEDIATRACKER_COORD_SAMPLES_PER_TRIGGER
                    );
                    trigger.SampledCoordCount = trigger.RawCoordSamples.Length;
                    trigger.CoordSamplesTruncated = trigger.RawCoordCount > trigger.SampledCoordCount;

                    return trigger;
                }

                void ReadMediaTrackerClipGroupIntoSource(
                    TriggerSourceSnapshot@ source,
                    CGameCtnMediaClipGroup@ clipGroup,
                    const string &in groupName,
                    bool renderCells
                ) {
                    if (source is null) return;
                    if (clipGroup is null) {
                        source.Diagnostics.InsertLast(groupName + " clip group is not present.");
                        return;
                    }

                    source.RawClipCount = clipGroup.Clips.Length;
                    source.RawTriggerCount = ReadMediaTrackerClipGroupTriggerCount(clipGroup);
                    source.RawTriggerCapacity = ReadMediaTrackerClipGroupTriggerCapacity(clipGroup);
                    source.RawBufferPtr = ReadMediaTrackerClipGroupTriggerBufferPtr(clipGroup);

                    if (source.RawTriggerCount > MAX_MEDIATRACKER_TRIGGER_CAPACITY || source.RawTriggerCapacity > MAX_MEDIATRACKER_TRIGGER_CAPACITY) {
                        source.Diagnostics.InsertLast(
                            groupName + " trigger count/capacity is suspiciously large; skipping MediaTracker probe."
                        );
                        source.BadTriggerCount = source.RawTriggerCount;
                        return;
                    }

                    if (source.RawTriggerCount != source.RawClipCount) {
                        source.Diagnostics.InsertLast(
                            groupName + " clip count (" + tostring(source.RawClipCount) +
                            ") differs from trigger count (" + tostring(source.RawTriggerCount) + ")."
                        );
                    }

                    if (source.RawTriggerCount > source.RawTriggerCapacity && source.RawTriggerCapacity > 0) {
                        source.Diagnostics.InsertLast(
                            groupName + " trigger count exceeds trigger capacity."
                        );
                        source.BadTriggerCount = source.RawTriggerCount;
                        return;
                    }

                    if (source.RawTriggerCount > 0 && source.RawTriggerCapacity == 0) {
                        source.Diagnostics.InsertLast(
                            groupName + " trigger capacity is zero while trigger count is non-zero."
                        );
                        source.BadTriggerCount = source.RawTriggerCount;
                        return;
                    }

                    if (source.RawTriggerCount == 0) return;

                    if (!CanSafelyTouchPointer(source.RawBufferPtr)) {
                        source.Diagnostics.InsertLast(
                            groupName + " trigger buffer pointer is not readable: " + Text::FormatPointer(source.RawBufferPtr)
                        );
                        source.BadTriggerCount = source.RawTriggerCount;
                        return;
                    }

                    uint probeCount = MinUint(source.RawTriggerCount, MAX_MEDIATRACKER_TRIGGER_PROBE_COUNT);
                    if (probeCount < source.RawTriggerCount) {
                        source.Diagnostics.InsertLast(
                            groupName + " trigger probe capped at " + tostring(probeCount) +
                            " of " + tostring(source.RawTriggerCount) + " triggers."
                        );
                    }

                    uint renderCoordCount = 0;
                    if (!renderCells) {
                        source.Diagnostics.InsertLast(groupName + " exact cell expansion disabled; rendering cached trigger bounding boxes only.");
                    }

                    for (uint i = 0; i < probeCount; i++) {
                        uint64 triggerPtr = source.RawBufferPtr + uint64(i) * SZ_MT_CLIPGROUP_TRIGGER_STRUCT;
                        auto trigger = ReadMediaTrackerClipTrigger(
                            clipGroup,
                            i,
                            triggerPtr,
                            source.MapSize,
                            source.RawTriggerSize,
                            MAX_MEDIATRACKER_RENDER_COORDS_TOTAL - renderCoordCount,
                            renderCells
                        );
                        source.MediaTrackerClipTriggers.InsertLast(trigger);
                        source.RawCoordCount = SaturatingAddUint(source.RawCoordCount, trigger.RawCoordCount);

                        if (trigger.HasWarning()) {
                            source.BadTriggerCount++;
                            source.Diagnostics.InsertLast(
                                groupName + " clip #" + tostring(i) + " (" + trigger.DisplayName() + "): " + trigger.Warning
                            );
                        } else {
                            source.ReadableTriggerCount++;
                            renderCoordCount += trigger.RawCoords.Length;
                            if (!renderCells) {
                                trigger.RenderBoundsUsed = true;
                                auto range = TriggerRangeRaw(Nat3ToInt3(trigger.MinCoord), Nat3ToInt3(trigger.MaxCoord));
                                source.RawRanges.InsertLast(range);
                                source.TriggerVolumes.InsertLast(MediaTrackerBoundsToTriggerVolume(
                                    trigger.MinCoord,
                                    trigger.MaxCoord,
                                    source.GridSpec,
                                    trigger.ClipIndex,
                                    trigger.DisplayName()
                                ));
                                continue;
                            }

                            for (uint j = 0; j < trigger.RawCoords.Length; j++) {
                                auto range = TriggerRangeRaw(trigger.RawCoords[j], trigger.RawCoords[j]);
                                source.RawRanges.InsertLast(range);
                                source.TriggerVolumes.InsertLast(MediaTrackerCoordToTriggerVolume(
                                    trigger.RawCoords[j],
                                    source.GridSpec,
                                    trigger.ClipIndex,
                                    trigger.DisplayName()
                                ));
                            }
                        }
                    }
                }

                TriggerSourceSnapshot@ ReadMediaTrackerTriggerSource(CGameCtnChallenge@ map, bool enabled, bool renderCells) {
                    auto source = TriggerSourceSnapshot(TRIGGER_SOURCE_MEDIATRACKER, enabled);
                    source.RawTriggerSize = ReadMediaTrackerTriggerSize(map);
                    source.MapSize = map is null ? nat3() : map.Size;
                    @source.GridSpec = BuildTriggerGridSpec(source.RawTriggerSize);

                    if (map is null) {
                        source.Diagnostics.InsertLast("No map available for MediaTracker trigger probing.");
                        return source;
                    }

                    if (!enabled) {
                        source.Diagnostics.InsertLast("MediaTracker source disabled; no private MediaTracker memory was probed.");
                        return source;
                    }

                    if (!renderCells) {
                        source.Diagnostics.InsertLast(
                            "MediaTracker exact cell rendering is disabled for crash safety; using one bounding box per readable clip trigger."
                        );
                    }

                    ReadMediaTrackerClipGroupIntoSource(source, map.ClipGroupInGame, "InGame", renderCells);
                    return source;
                }
            }
        }
    }
}
