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
                const uint MAX_MEDIATRACKER_COORD_CAPACITY_HARD = 1000000;
                const uint MEDIATRACKER_MAP_BOUNDS_MARGIN_BLOCKS = 16;

                const int MEDIATRACKER_GAME_CAM_DEFAULT = 0;
                const int MEDIATRACKER_GAME_CAM_INTERNAL = 1;
                const int MEDIATRACKER_GAME_CAM_EXTERNAL = 2;
                const int MEDIATRACKER_GAME_CAM_EXTERNAL_2 = 6;

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

                string CoordKey(const int3 &in coord) {
                    return tostring(coord.x) + "," + tostring(coord.y) + "," + tostring(coord.z);
                }

                int3 GetCoordNeighbor(const int3 &in coord, uint neighborIndex) {
                    if (neighborIndex == 0) return coord + int3(1, 0, 0);
                    if (neighborIndex == 1) return coord + int3(-1, 0, 0);
                    if (neighborIndex == 2) return coord + int3(0, 1, 0);
                    if (neighborIndex == 3) return coord + int3(0, -1, 0);
                    if (neighborIndex == 4) return coord + int3(0, 0, 1);
                    return coord + int3(0, 0, -1);
                }

                int3 MinCoord(const int3 &in a, const int3 &in b) {
                    return int3(b.x < a.x ? b.x : a.x, b.y < a.y ? b.y : a.y, b.z < a.z ? b.z : a.z);
                }

                int3 MaxCoord(const int3 &in a, const int3 &in b) {
                    return int3(b.x > a.x ? b.x : a.x, b.y > a.y ? b.y : a.y, b.z > a.z ? b.z : a.z);
                }

                array<TriggerRangeRaw@> @MediaTrackerCoordsToConnectedRanges(const array<int3> @coords) {
                    auto ranges = array<TriggerRangeRaw@>();
                    if (coords is null || coords.Length == 0) return ranges;

                    dictionary remaining;
                    auto uniqueCoords = array<int3>();
                    uniqueCoords.Reserve(coords.Length);
                    for (uint i = 0; i < coords.Length; i++) {
                        string key = CoordKey(coords[i]);
                        if (remaining.Exists(key)) continue;

                        remaining.Set(key, true);
                        uniqueCoords.InsertLast(coords[i]);
                    }

                    for (uint i = 0; i < uniqueCoords.Length; i++) {
                        string startKey = CoordKey(uniqueCoords[i]);
                        if (!remaining.Exists(startKey)) continue;

                        remaining.Delete(startKey);
                        auto queue = array<int3>();
                        queue.InsertLast(uniqueCoords[i]);

                        int3 minCoord = uniqueCoords[i];
                        int3 maxCoord = uniqueCoords[i];
                        uint cursor = 0;
                        while (cursor < queue.Length) {
                            int3 coord = queue[cursor];
                            cursor++;
                            minCoord = MinCoord(minCoord, coord);
                            maxCoord = MaxCoord(maxCoord, coord);

                            for (uint neighborIndex = 0; neighborIndex < 6; neighborIndex++) {
                                int3 neighbor = GetCoordNeighbor(coord, neighborIndex);
                                string neighborKey = CoordKey(neighbor);
                                if (!remaining.Exists(neighborKey)) continue;

                                remaining.Delete(neighborKey);
                                queue.InsertLast(neighbor);
                            }
                        }

                        ranges.InsertLast(TriggerRangeRaw(minCoord, maxCoord));
                    }

                    return ranges;
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

                array<int3> @ReadMediaTrackerTriggerCoords(uint64 bufferPtr, uint coordCount) {
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

                array<int3> @ReadMediaTrackerTriggerCoordSamples(uint64 bufferPtr, uint coordCount, uint maxSamples) {
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

                array<int3> @CopyMediaTrackerTriggerCoordSamples(const array<int3> @coords, uint maxSamples) {
                    auto samples = array<int3>();
                    if (coords is null || maxSamples == 0) return samples;

                    uint sampleCount = MinUint(coords.Length, maxSamples);
                    samples.Reserve(sampleCount);
                    for (uint i = 0; i < sampleCount; i++) {
                        samples.InsertLast(coords[i]);
                    }

                    return samples;
                }

                string GetDetectedMediaTrackerCameraLabel(int gameCam) {
                    if (gameCam == MEDIATRACKER_GAME_CAM_DEFAULT) return "CamDefault";
                    if (gameCam == MEDIATRACKER_GAME_CAM_EXTERNAL) return "Cam1";
                    if (gameCam == MEDIATRACKER_GAME_CAM_EXTERNAL_2) return "Cam2";
                    if (gameCam == MEDIATRACKER_GAME_CAM_INTERNAL) return "Cam3";
                    return "";
                }

                string GetDetectedMediaTrackerCameraLabel(CGameCtnMediaBlockCameraGame@ cameraBlock) {
                    if (cameraBlock is null) return "";

                    int gameCam = int(cameraBlock.GameCam);
                    int designGameCam = int(cameraBlock.GameCamDesign);
                    if (designGameCam != MEDIATRACKER_GAME_CAM_DEFAULT) {
                        gameCam = designGameCam;
                    }

                    return GetDetectedMediaTrackerCameraLabel(gameCam);
                }

                class MediaTrackerClipClassification {
                    string SubtypeKey = MT_SUBTYPE_UNKNOWN;
                    string SubtypeLabel = GetMediaTrackerSubtypeDisplayName(MT_SUBTYPE_UNKNOWN);
                    string DetectedLabel;
                    string TargetKeys;
                    uint BlockCount = 0;
                }

                bool ClassifyMediaTrackerBlock(
                    CGameCtnMediaBlock@ block,
                    string &out subtypeKey,
                    string &out detectedLabel
                ) {
                    subtypeKey = MT_SUBTYPE_UNKNOWN;
                    detectedLabel = "";
                    if (block is null) return false;

                    auto playerCamera = cast<CGameCtnMediaBlockCameraGame>(block);
                    if (playerCamera !is null) {
                        subtypeKey = MT_SUBTYPE_CAM_PLAYER;
                        detectedLabel = GetDetectedMediaTrackerCameraLabel(playerCamera);
                        if (detectedLabel.Length == 0) detectedLabel = "Player Camera";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockCameraCustom>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_CAM_CUSTOM;
                        detectedLabel = "CamCustom";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockCameraOrbital>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_CAM_ORBITAL;
                        detectedLabel = "CamOrbital";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockCameraPath>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_CAM_PATH;
                        detectedLabel = "CamPath";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockTriangles2D>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_TRIANGLES_2D;
                        detectedLabel = "2dTriangles";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockTriangles3D>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_TRIANGLES_3D;
                        detectedLabel = "3dTriangles";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockTrails>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_CAR_TRAIL;
                        detectedLabel = "CarTrail";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockFxColors>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_COLORS_FX;
                        detectedLabel = "ColorsFX";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockColorGrading>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_COLOR_GRADING;
                        detectedLabel = "ColorGrading";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockDOF>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_DEPTH_OF_FIELD;
                        detectedLabel = "DepthOfField";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockDirtyLens>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_DIRTY_LENS;
                        detectedLabel = "DirtyLens";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockEvent_deprecated>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_EDITING_CUT;
                        detectedLabel = "EditingCut";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockTransitionFade>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_FADING_TRANSITION;
                        detectedLabel = "FadingTransition";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockFog>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_FOG;
                        detectedLabel = "Fog";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockGhostTM>(block) !is null || cast<CGameCtnMediaBlockEntity>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_GHOST;
                        detectedLabel = "Ghost";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockBloomHdr>(block) !is null || cast<CGameCtnMediaBlockFxBloom>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_HDR_BLOOM;
                        detectedLabel = "HDRBloom";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockImage>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_IMAGE;
                        detectedLabel = "Image";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockCameraEffectInertialTracking>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_INERTIAL_TRACKING_CAM_FX;
                        detectedLabel = "InertialTrackingCamFX";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockInterface>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_MANIALINK_UI;
                        detectedLabel = "ManiaLinkUI";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockManialink>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_MANIALINK_URL;
                        detectedLabel = "ManiaLinkURL";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockMusicEffect>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_MUSIC_VOLUME;
                        detectedLabel = "MusicVolume";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockOpponentVisibility>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_OPPONENT_VISIBILITY;
                        detectedLabel = "OpponentVisibility";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockCameraEffectShake>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_SHAKE_CAM_FX;
                        detectedLabel = "ShakeCamFX";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlock3dStereo>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_STEREO_3D;
                        detectedLabel = "Stereo3D";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockSound>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_SOUND_FX;
                        detectedLabel = "SoundFX";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockSpectators>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_SPECTATORS;
                        detectedLabel = "Spectators";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockText>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_TEXT;
                        detectedLabel = "Text";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockTime>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_TIME;
                        detectedLabel = "Time";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockTimeSpeed>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_TIME_SPEED;
                        detectedLabel = "TimeSpeed";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockToneMapping>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_TONE_MAPPING;
                        detectedLabel = "ToneMapping";
                        return true;
                    }

                    if (cast<CGameCtnMediaBlockVehicleLight>(block) !is null) {
                        subtypeKey = MT_SUBTYPE_VEHICLE_LIGHTS;
                        detectedLabel = "VehicleLights";
                        return true;
                    }

                    return false;
                }

                MediaTrackerClipClassification@ DetectMediaTrackerClipTrigger(CGameCtnMediaClip@ clip) {
                    auto classification = MediaTrackerClipClassification();
                    if (clip is null) return classification;

                    uint blockCount = 0;
                    string primarySubtypeKey = "";
                    bool mixedSubtypes = false;

                    for (uint trackIndex = 0; trackIndex < clip.Tracks.Length; trackIndex++) {
                        auto track = clip.Tracks[trackIndex];
                        if (track is null) continue;

                        for (uint blockIndex = 0; blockIndex < track.Blocks.Length; blockIndex++) {
                            auto block = track.Blocks[blockIndex];
                            blockCount++;

                            string subtypeKey = MT_SUBTYPE_UNKNOWN;
                            string detectedLabel = "";
                            ClassifyMediaTrackerBlock(block, subtypeKey, detectedLabel);

                            classification.TargetKeys = AddMediaTrackerSubtypeTargetKey(
                                classification.TargetKeys,
                                subtypeKey
                            );
                            if (subtypeKey == MT_SUBTYPE_CAM_PLAYER && detectedLabel.Length > 0) {
                                classification.TargetKeys = AddMediaTrackerSubtypeTargetKey(
                                    classification.TargetKeys,
                                    detectedLabel
                                );
                            }

                            if (primarySubtypeKey.Length == 0) {
                                primarySubtypeKey = subtypeKey;
                            } else if (primarySubtypeKey != subtypeKey) {
                                mixedSubtypes = true;
                            }

                            if (blockCount == 1 && detectedLabel.Length > 0) {
                                classification.DetectedLabel = detectedLabel;
                            }
                        }
                    }

                    classification.BlockCount = blockCount;
                    if (blockCount == 0) {
                        classification.SubtypeKey = MT_SUBTYPE_RESET;
                        classification.SubtypeLabel = GetMediaTrackerSubtypeDisplayName(MT_SUBTYPE_RESET);
                        classification.DetectedLabel = "Reset";
                        classification.TargetKeys = AddMediaTrackerSubtypeTargetKey(
                            classification.TargetKeys,
                            MT_SUBTYPE_RESET
                        );
                        return classification;
                    }

                    classification.SubtypeKey = mixedSubtypes ? MT_SUBTYPE_MIXED : primarySubtypeKey;
                    classification.SubtypeLabel = GetMediaTrackerSubtypeDisplayName(classification.SubtypeKey);
                    if (blockCount == 1 && classification.DetectedLabel.Length == 0) {
                        classification.DetectedLabel = classification.SubtypeLabel;
                    }
                    return classification;
                }

                TriggerVolume@ MediaTrackerRangeToTriggerVolume(
                    const TriggerRangeRaw@ range,
                    const TriggerGridSpec@ spec,
                    uint clipIndex,
                    const string &in clipName,
                    const string &in detectedLabel,
                    const string &in subtypeKey,
                    const string &in subtypeLabel,
                    const string &in targetKeys,
                    uint islandIndex,
                    uint islandCount
                ) {
                    if (range is null) return TriggerVolume();

                    vec3 min = TriggerCoordToWorldPos(range.Start, spec);
                    vec3 max = TriggerCoordToWorldPos(range.End + int3(1, 1, 1), spec);
                    string label = clipName;
                    auto volume = TriggerVolume(min, max, TRIGGER_SOURCE_MEDIATRACKER, clipIndex, label);
                    volume.DetectedLabel = detectedLabel;
                    volume.SubtypeKey = subtypeKey;
                    volume.SubtypeLabel = subtypeLabel;
                    volume.TargetKeys = MergeTriggerTargetKeys(volume.TargetKeys, targetKeys);
                    volume.AllowRawRangeLabel = false;
                    if (islandCount > 1) {
                        volume.HasIslandIndex = true;
                        volume.IslandIndex = islandIndex;
                        volume.IslandCount = islandCount;
                    }
                    return volume;
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
                            auto classification = DetectMediaTrackerClipTrigger(clip);
                            trigger.DetectedLabel = classification.DetectedLabel;
                            trigger.SubtypeKey = classification.SubtypeKey;
                            trigger.SubtypeLabel = classification.SubtypeLabel;
                            trigger.TargetKeys = classification.TargetKeys;
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

                    if (trigger.RawCoordCapacity > MAX_MEDIATRACKER_COORD_CAPACITY_HARD) {
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

                    trigger.RawCoords = ReadMediaTrackerTriggerCoords(trigger.CoordBufferPtr, trigger.RawCoordCount);
                    if (trigger.RawCoords.Length != trigger.RawCoordCount) {
                        trigger.RenderCoordsSkipped = true;
                        trigger.Warning = "Coordinate buffer read stopped at " + tostring(trigger.RawCoords.Length) +
                        " of " + tostring(trigger.RawCoordCount) + " coordinates.";
                        trigger.RawCoordSamples = CopyMediaTrackerTriggerCoordSamples(
                            trigger.RawCoords,
                            MAX_MEDIATRACKER_COORD_SAMPLES_PER_TRIGGER
                        );
                        trigger.SampledCoordCount = trigger.RawCoordSamples.Length;
                        trigger.CoordSamplesTruncated = trigger.RawCoordCount > trigger.SampledCoordCount;
                        return trigger;
                    }
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
                        source.Diagnostics.InsertLast(groupName + " trigger count/capacity is suspiciously large; skipping MediaTracker probe.");
                        source.BadTriggerCount = source.RawTriggerCount;
                        return;
                    }

                    if (source.RawTriggerCount != source.RawClipCount) {
                        source.Diagnostics.InsertLast(groupName + " clip count (" + tostring(source.RawClipCount) + ") differs from trigger count (" + tostring(source.RawTriggerCount) + ").");
                    }

                    if (source.RawTriggerCount > source.RawTriggerCapacity && source.RawTriggerCapacity > 0) {
                        source.Diagnostics.InsertLast(groupName + " trigger count exceeds trigger capacity.");
                        source.BadTriggerCount = source.RawTriggerCount;
                        return;
                    }

                    if (source.RawTriggerCount > 0 && source.RawTriggerCapacity == 0) {
                        source.Diagnostics.InsertLast(groupName + " trigger capacity is zero while trigger count is non-zero.");
                        source.BadTriggerCount = source.RawTriggerCount;
                        return;
                    }

                    if (source.RawTriggerCount == 0) return;

                    if (!CanSafelyTouchPointer(source.RawBufferPtr)) {
                        source.Diagnostics.InsertLast(groupName + " trigger buffer pointer is not readable: " + Text::FormatPointer(source.RawBufferPtr));
                        source.BadTriggerCount = source.RawTriggerCount;
                        return;
                    }

                    uint probeCount = MinUint(source.RawTriggerCount, MAX_MEDIATRACKER_TRIGGER_PROBE_COUNT);
                    if (probeCount < source.RawTriggerCount) {
                        source.Diagnostics.InsertLast(groupName + " trigger probe capped at " + tostring(probeCount) + " of " + tostring(source.RawTriggerCount) + " triggers.");
                    }

                    uint renderCoordCount = 0;
                    if (!renderCells) {
                        source.Diagnostics.InsertLast(groupName + " exact cell expansion disabled; trigger bounds fallback is suppressed to avoid giant sparse boxes.");
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
                            source.Diagnostics.InsertLast(groupName + " clip #" + tostring(i) + " (" + trigger.DisplayName() + "): " + trigger.Warning);
                        } else {
                            source.ReadableTriggerCount++;
                            renderCoordCount += trigger.RawCoords.Length;
                            if (!renderCells) {
                                trigger.RenderCoordsSkipped = true;
                                continue;
                            }

                            auto ranges = MediaTrackerCoordsToConnectedRanges(trigger.RawCoords);
                            trigger.RenderIslandsUsed = true;
                            trigger.RenderIslandCount = ranges.Length;
                            for (uint j = 0; j < ranges.Length; j++) {
                                auto range = ranges[j];
                                source.RawRanges.InsertLast(range);
                                source.TriggerVolumes.InsertLast(MediaTrackerRangeToTriggerVolume(range, source.GridSpec, trigger.ClipIndex, trigger.DisplayName(), trigger.DetectedLabel, trigger.SubtypeKey, trigger.SubtypeLabel, trigger.TargetKeys, j, ranges.Length));
                            }
                            trigger.RawCoords.Resize(0);
                        }
                    }
                }

                TriggerSourceSnapshot@ ReadMediaTrackerTriggerSource(
                    CGameCtnChallenge@ map,
                    CGameCtnMediaClipGroup@ clipGroup,
                    const string &in groupName,
                    bool enabled,
                    bool renderCells
                ) {
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
                        source.Diagnostics.InsertLast("MediaTracker exact cell rendering is disabled; no bounds fallback will be drawn for sparse triggers.");
                    }

                    ReadMediaTrackerClipGroupIntoSource(source, clipGroup, groupName, renderCells);
                    return source;
                }
            }
        }
    }
}
