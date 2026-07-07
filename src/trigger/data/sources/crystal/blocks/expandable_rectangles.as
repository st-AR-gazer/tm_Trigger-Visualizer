namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                const uint MAX_CRYSTAL_SIMPLE_EXPANDABLE_RECTANGLES = 8192;
                const float CRYSTAL_EXPANDABLE_RECTANGLE_HORIZONTAL_CONNECT_TOUCH_EPSILON = 0.25f;
                const float CRYSTAL_EXPANDABLE_RECTANGLE_VERTICAL_CONNECT_TOUCH_EPSILON = 0.25f;
                const float CRYSTAL_EXPANDABLE_RECTANGLE_CONNECT_OVERLAP_EPSILON = 0.001f;

                class CrystalExpandableRectangleStats {
                    uint BlocksScanned = 0;
                    uint ExpandableCandidates = 0;
                    uint NamedSpecialGateCandidates = 0;
                    uint TargetBlocks = 0;
                    uint RectanglesRendered = 0;
                    uint RectanglesMerged = 0;
                    uint RectangleGroupsRendered = 0;
                    uint ConnectedRectanglesGrouped = 0;
                    uint RectanglesRejected = 0;
                    uint RectangleLimitSkipped = 0;
                    string FirstRenderedDetail = "";
                    string FirstRejectedDetail = "";
                }

                bool CrystalExpandableVariantHasFreeClips(CGameCtnBlockInfoVariant@ variant) {
                    if (variant is null) return false;
                    try {
                        return variant.HasFreeClips;
                    } catch {
                        logging::HandledException(
                            "CrystalExpandableVariantHasFreeClips",
                            "Variant.HasFreeClips was not readable."
                        );
                    }
                    return false;
                }

                bool CrystalBlockHasAnyMaterialModifier(CGameCtnBlock@ block) {
                    if (block is null || block.BlockInfo is null) return false;
                    try {
                        if (block.BlockInfo.MaterialModifier !is null) return true;
                    } catch {
                        logging::HandledException(
                            "CrystalBlockHasAnyMaterialModifier",
                            "BlockInfo.MaterialModifier was not readable."
                        );
                    }
                    try {
                        if (block.BlockInfo.MaterialModifier2 !is null) return true;
                    } catch {
                        logging::HandledException(
                            "CrystalBlockHasAnyMaterialModifier",
                            "BlockInfo.MaterialModifier2 was not readable."
                        );
                    }
                    return false;
                }

                bool CrystalTargetKeysHaveGameplaySpecial(const string &in targetKeys) {
                    return TriggerTargetListContains(targetKeys, TRIGGER_TYPE_TURBO)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_TURBO2)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_TURBO_ROULETTE)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_TURBO_ROULETTE_YELLOW)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_TURBO_ROULETTE_CYAN)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_TURBO_ROULETTE_PURPLE)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_BOOST)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_BOOST2)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_CRUISE)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_NO_BRAKES)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_NO_ENGINE)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_NO_STEERING)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_SLOWMO)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_FRAGILE)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_RESET)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_FORCED_ACCELERATION)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_NO_GRIP)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_VEHICLE_TRANSFORM_RESET)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_VEHICLE_TRANSFORM_SNOW)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_VEHICLE_TRANSFORM_RALLY)
                        || TriggerTargetListContains(targetKeys, TRIGGER_TYPE_VEHICLE_TRANSFORM_DESERT);
                }

                bool CrystalBlockHasGameplaySpecialMaterialModifier(CGameCtnBlock@ block) {
                    if (block is null || block.BlockInfo is null) return false;
                    if (!CrystalBlockHasAnyMaterialModifier(block)) return false;

                    string keys = AddCrystalBlockMaterialModifierTargetKeys(
                        GetTriggerSourceTargetKeys(TRIGGER_SOURCE_CRYSTAL),
                        block
                    );
                    return CrystalTargetKeysHaveGameplaySpecial(keys);
                }

                string CrystalExpandableBlockInfoName(CGameCtnBlock@ block) {
                    if (block is null || block.BlockInfo is null) return "";
                    try {
                        return string(block.BlockInfo.Name);
                    } catch {
                        logging::HandledException(
                            "CrystalExpandableBlockInfoName",
                            "BlockInfo.Name was not readable."
                        );
                    }
                    return "";
                }

                bool CrystalExpandableBlockNameLooksSpecialGate(CGameCtnBlock@ block) {
                    string name = CrystalExpandableBlockInfoName(block).ToLower();
                    return name.StartsWith("gateexpandablespecial");
                }

                bool CrystalExpandableBlockCanCarryRectangle(CGameCtnBlock@ block) {
                    if (block is null || block.BlockInfo is null) return false;
                    try {
                        if (block.BlockInfo.IsRoad || block.BlockInfo.IsTerrain || block.BlockInfo.IsClip) return false;
                    } catch {
                        logging::HandledException(
                            "CrystalExpandableBlockCanCarryRectangle",
                            "BlockInfo road/terrain/clip flags were not readable."
                        );
                    }
                    return true;
                }

                bool CrystalExpandableBlockShouldUseRectangle(CGameCtnBlock@ block, CGameCtnBlockInfoVariant@ variant) {
                    if (block is null || block.BlockInfo is null || variant is null) return false;
                    if (!CrystalExpandableVariantHasFreeClips(variant)) return false;
                    if (!CrystalExpandableBlockNameLooksSpecialGate(block)) return false;
                    if (!CrystalExpandableBlockCanCarryRectangle(block)) return false;
                    return CrystalBlockHasGameplaySpecialMaterialModifier(block);
                }

                string GetCrystalExpandableSpecialGateBaseTargetKeys() {
                    string keys = GetTriggerSourceTargetKeys(TRIGGER_SOURCE_CRYSTAL);
                    keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_BLOCK);
                    keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_GATE);
                    keys = AddTriggerTargetKey(keys, "gate");
                    return keys;
                }

                string GetCrystalExpandableSpecialGateTargetKeys(CGameCtnBlock@ block) {
                    return AddCrystalBlockMaterialModifierTargetKeys(
                        GetCrystalExpandableSpecialGateBaseTargetKeys(),
                        block
                    );
                }

                string GetCrystalExpandableRectangleTargetKeys(CGameCtnBlock@ block) {
                    return GetCrystalExpandableSpecialGateTargetKeys(block);
                }

                string CrystalExpandableRectangleLabelForTargetKeys(const string &in targetKeys) {
                    if (TriggerTargetListContains(targetKeys, CRYSTAL_SUBTYPE_GATE) || TriggerTargetListContains(targetKeys, "gate")) {
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_BOOST2)) return "Boost2 Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_BOOST)) return "Boost Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_TURBO2)) return "Turbo2 Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_TURBO)) return "Turbo Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_NO_ENGINE)) return "No Engine Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_NO_BRAKES)) return "No Brakes Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_NO_STEERING)) return "No Steering Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_NO_GRIP)) return "No Grip Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_CRUISE)) return "Cruise Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_RESET)) return "Reset Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_SLOWMO)) return "Slowmo Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_FRAGILE)) return "Fragile Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_FORCED_ACCELERATION)) return "Forced Acceleration Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_VEHICLE_TRANSFORM_SNOW)) return "Snow Car Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_VEHICLE_TRANSFORM_RALLY)) return "Rally Car Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_VEHICLE_TRANSFORM_DESERT)) return "Desert Car Gate";
                        if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_VEHICLE_TRANSFORM_RESET)) return "Stadium Car Gate";
                        return "Special Gate";
                    }
                    return "Special Gate";
                }

                string GetCrystalExpandableRectangleBoundsKey(const vec3 &in worldMin, const vec3 &in worldMax) {
                    return GetTriggerGeometryPointKey(worldMin) + "|" + GetTriggerGeometryPointKey(worldMax);
                }

                string GetCrystalExpandableRectangleMergeKey(
                    const vec3 &in worldMin,
                    const vec3 &in worldMax,
                    const string &in targetKeys
                ) {
                    return GetCrystalExpandableRectangleBoundsKey(worldMin, worldMax) + "|" + targetKeys;
                }

                bool BuildCrystalExpandableRectangleWorldBounds(
                    CGameCtnChallenge@ map,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    vec3 &out worldMin,
                    vec3 &out worldMax,
                    string &out detail,
                    string &out warning
                ) {
                    worldMin = vec3();
                    worldMax = vec3();
                    detail = "";
                    warning = "";

                    if (map is null || block is null || variant is null) {
                        warning = "No map, block, or variant for expandable rectangle.";
                        return false;
                    }

                    vec3 coordSize = CrystalNat3ToVec3(variant.Size);
                    if (!CrystalIsSaneBlockCoordSize(coordSize)) {
                        warning = "Expandable variant size is invalid: " + variant.Size.ToString();
                        return false;
                    }

                    vec3 blockWorldSize = TriggerVisualizer::Trigger::Data::OFFZONE_BLOCK_WORLD_SIZE;
                    vec3 localSize = vec3(
                        coordSize.x * blockWorldSize.x,
                        coordSize.y * blockWorldSize.y,
                        coordSize.z * blockWorldSize.z
                    );
                    if (!CrystalIsFiniteVec3(localSize)) {
                        warning = "Expandable local size is not finite.";
                        return false;
                    }

                    float localMinY = 0.0f;
                    float localMaxY = localSize.y;
                    float centerZ = localSize.z * 0.5f;
                    vec3 localMin = vec3(
                        0.0f,
                        localMinY,
                        centerZ - CRYSTAL_EXPANDABLE_TRIGGER_THICKNESS * 0.5f
                    );
                    vec3 localMax = vec3(
                        localSize.x,
                        localMaxY,
                        centerZ + CRYSTAL_EXPANDABLE_TRIGGER_THICKNESS * 0.5f
                    );
                    mat4 blockTransform;
                    string transformDetail = "";
                    string transformWarning = "";
                    if (!TryGetCrystalPlacedBlockTransform(map, block, variant, blockTransform, transformDetail, transformWarning)) {
                        warning = transformWarning;
                        return false;
                    }

                    string boundsWarning = "";
                    if (!CrystalTransformBounds(blockTransform, localMin, localMax, worldMin, worldMax, boundsWarning)) {
                        warning = boundsWarning;
                        return false;
                    }

                    string validationWarning = "";
                    if (!CrystalValidateBounds(worldMin, worldMax, true, validationWarning)) {
                        warning = validationWarning;
                        return false;
                    }

                    CrystalNormalizeBounds(worldMin, worldMax, worldMin, worldMax);
                    detail = "variantSize " + variant.Size.ToString()
                        + " local " + CrystalVec3Label(localMin) + ".." + CrystalVec3Label(localMax)
                        + " world " + CrystalVec3Label(worldMin) + ".." + CrystalVec3Label(worldMax)
                        + " | " + transformDetail;
                    return true;
                }

                void ApplyCrystalExpandableRectangleColor(TriggerVolume@ volume) {
                    if (volume is null) return;

                    vec4 triggerTypeColor;
                    volume.HasTriggerTypeColor = TryGetTriggerTypeColorForTargetKeys(
                        volume.TargetKeys,
                        triggerTypeColor
                    );
                    if (volume.HasTriggerTypeColor) {
                        volume.TriggerTypeColor = triggerTypeColor;
                    } else {
                        volume.TargetKeys = AddTriggerTargetKey(volume.TargetKeys, MT_SUBTYPE_UNKNOWN);
                        volume.HasTriggerTypeColor = true;
                        volume.TriggerTypeColor = GetMissingElementColor();
                    }
                }

                void RefreshCrystalExpandableRectangleMetadata(TriggerVolume@ volume, const string &in targetKeys) {
                    if (volume is null) return;

                    volume.TargetKeys = targetKeys;
                    volume.Label = "Expandable Crystal " + CrystalExpandableRectangleLabelForTargetKeys(targetKeys);
                    volume.DetectedLabel = "ExpandableRectangle.SpecialGateArea";
                    volume.SubtypeKey = CRYSTAL_SUBTYPE_GATE;
                    volume.SubtypeLabel = "Crystal Gate";
                    volume.AllowRawRangeLabel = false;
                    ApplyCrystalExpandableRectangleColor(volume);
                }

                bool AddOrMergeCrystalExpandableRectangle(
                    array<TriggerVolume@> @rectangles,
                    const vec3 &in worldMin,
                    const vec3 &in worldMax,
                    const string &in targetKeys,
                    dictionary@ rectangleIndexByBounds,
                    CrystalExpandableRectangleStats@ stats
                ) {
                    if (rectangles is null || rectangleIndexByBounds is null || stats is null) return false;

                    string boundsKey = GetCrystalExpandableRectangleMergeKey(
                        worldMin,
                        worldMax,
                        targetKeys
                    );
                    int existingIndex = -1;
                    if (rectangleIndexByBounds.Get(boundsKey, existingIndex)) {
                        if (existingIndex >= 0 && existingIndex < int(rectangles.Length)) {
                            auto existing = rectangles[uint(existingIndex)];
                            if (existing !is null) {
                                existing.MergedVolumeCount++;
                                existing.IsMergedGroup = existing.MergedVolumeCount > 1;
                                stats.RectanglesMerged++;
                                return true;
                            }
                        }
                    }

                    if (stats.RectanglesRendered >= MAX_CRYSTAL_SIMPLE_EXPANDABLE_RECTANGLES) {
                        stats.RectangleLimitSkipped++;
                        return false;
                    }

                    auto volume = TriggerVolume(
                        worldMin,
                        worldMax,
                        TRIGGER_SOURCE_CRYSTAL,
                        rectangles.Length,
                        ""
                    );
                    RefreshCrystalExpandableRectangleMetadata(volume, targetKeys);
                    rectangles.InsertLast(volume);
                    rectangleIndexByBounds.Set(boundsKey, int(rectangles.Length - 1));
                    stats.RectanglesRendered++;
                    return true;
                }

                bool CrystalExpandableRectangleIntervalsTouchOrOverlap(
                    float aMin,
                    float aMax,
                    float bMin,
                    float bMax,
                    float epsilon
                ) {
                    return aMax + epsilon >= bMin
                        && bMax + epsilon >= aMin;
                }

                bool CrystalExpandableRectangleIntervalsOverlapWithArea(
                    float aMin,
                    float aMax,
                    float bMin,
                    float bMax
                ) {
                    return Math::Min(
                        aMax,
                        bMax
                    ) - Math::Max(aMin, bMin) > CRYSTAL_EXPANDABLE_RECTANGLE_CONNECT_OVERLAP_EPSILON;
                }

                bool CrystalExpandableRectanglesHaveCompatibleGroupMetadata(
                    const TriggerVolume@ a,
                    const TriggerVolume@ b
                ) {
                    if (a is null || b is null) return false;
                    return a.Source == b.Source
                        && a.SubtypeKey == b.SubtypeKey
                        && a.SubtypeLabel == b.SubtypeLabel
                        && a.DetectedLabel == b.DetectedLabel
                        && a.TargetKeys == b.TargetKeys;
                }

                int CrystalExpandableRectangleThinHorizontalAxis(const TriggerVolume@ volume) {
                    if (volume is null) return -1;

                    vec3 size = volume.Size();
                    if (!CrystalIsFiniteVec3(size)) return -1;

                    float thinLimit = CRYSTAL_EXPANDABLE_TRIGGER_THICKNESS + 0.5f;
                    bool thinX = size.x <= thinLimit && size.x <= size.z;
                    bool thinZ = size.z <= thinLimit && size.z <= size.x;
                    if (thinX == thinZ) return -1;
                    return thinX ? 0 : 2;
                }

                bool CrystalExpandableRectanglesUseSameConnectionAxis(const TriggerVolume@ a, const TriggerVolume@ b) {
                    int axisA = CrystalExpandableRectangleThinHorizontalAxis(a);
                    int axisB = CrystalExpandableRectangleThinHorizontalAxis(b);
                    return axisA >= 0 && axisA == axisB;
                }

                bool CrystalExpandableRectanglesConnect(const TriggerVolume@ a, const TriggerVolume@ b) {
                    if (!CrystalExpandableRectanglesHaveCompatibleGroupMetadata(a, b)) return false;
                    if (!CrystalExpandableRectanglesUseSameConnectionAxis(a, b)) return false;

                    bool touchX = CrystalExpandableRectangleIntervalsTouchOrOverlap(
                        a.Min.x,
                        a.Max.x,
                        b.Min.x,
                        b.Max.x,
                        CRYSTAL_EXPANDABLE_RECTANGLE_HORIZONTAL_CONNECT_TOUCH_EPSILON
                    );
                    bool touchY = CrystalExpandableRectangleIntervalsTouchOrOverlap(
                        a.Min.y,
                        a.Max.y,
                        b.Min.y,
                        b.Max.y,
                        CRYSTAL_EXPANDABLE_RECTANGLE_VERTICAL_CONNECT_TOUCH_EPSILON
                    );
                    bool touchZ = CrystalExpandableRectangleIntervalsTouchOrOverlap(
                        a.Min.z,
                        a.Max.z,
                        b.Min.z,
                        b.Max.z,
                        CRYSTAL_EXPANDABLE_RECTANGLE_HORIZONTAL_CONNECT_TOUCH_EPSILON
                    );
                    if (!touchX || !touchY || !touchZ) return false;

                    uint overlappingAxes = 0;
                    if (CrystalExpandableRectangleIntervalsOverlapWithArea(a.Min.x, a.Max.x, b.Min.x, b.Max.x)) overlappingAxes++;
                    if (CrystalExpandableRectangleIntervalsOverlapWithArea(a.Min.y, a.Max.y, b.Min.y, b.Max.y)) overlappingAxes++;
                    if (CrystalExpandableRectangleIntervalsOverlapWithArea(a.Min.z, a.Max.z, b.Min.z, b.Max.z)) overlappingAxes++;
                    return overlappingAxes >= 2;
                }

                TriggerVolume@ BuildCrystalExpandableRectangleGroup(
                    const array<TriggerVolume@> @rectangles,
                    const array<uint> @memberIndices
                ) {
                    if (rectangles is null || memberIndices is null || memberIndices.Length == 0) return TriggerVolume();

                    uint firstIndex = memberIndices[0];
                    if (firstIndex >= rectangles.Length || rectangles[firstIndex] is null) return TriggerVolume();

                    if (memberIndices.Length == 1) {
                        return TriggerVisualizer::Trigger::Data::CloneTriggerVolumeForMerge(rectangles[firstIndex]);
                    }

                    auto group = TriggerVisualizer::Trigger::Data::CloneTriggerVolumeForMerge(rectangles[firstIndex]);
                    group.IsMergedGroup = true;
                    group.AllowRawRangeLabel = false;
                    group.HasIslandIndex = false;
                    group.MergedVolumeCount = 0;
                    group.ChildVolumes.Resize(0);

                    for (uint i = 0; i < memberIndices.Length; i++) {
                        uint memberIndex = memberIndices[i];
                        if (memberIndex >= rectangles.Length || rectangles[memberIndex] is null) continue;
                        TriggerVisualizer::Trigger::Data::ExpandTriggerVolumeBounds(group, rectangles[memberIndex]);
                        group.MergedVolumeCount += TriggerVisualizer::Trigger::Data::NormalizeMergedVolumeCount(rectangles[memberIndex].MergedVolumeCount);
                        group.ChildVolumes.InsertLast(TriggerVisualizer::Trigger::Data::CloneTriggerVolumeForMerge(rectangles[memberIndex]));
                    }
                    if (group.MergedVolumeCount == 0) {
                        group.MergedVolumeCount = uint(group.ChildVolumes.Length);
                    }
                    TriggerVisualizer::Trigger::Data::BuildTriggerVolumeGroupGeometryCache(group);
                    return group;
                }

                void AppendCrystalExpandableRectangleGroups(
                    TriggerSourceSnapshot@ source,
                    const array<TriggerVolume@> @rectangles,
                    CrystalExpandableRectangleStats@ stats
                ) {
                    if (source is null || rectangles is null || stats is null) return;

                    auto consumed = array<bool>(rectangles.Length, false);
                    for (uint i = 0; i < rectangles.Length; i++) {
                        if (consumed[i] || rectangles[i] is null) continue;

                        auto memberIndices = array<uint>();
                        auto pending = array<uint>();
                        pending.InsertLast(i);
                        consumed[i] = true;
                        uint pendingIndex = 0;

                        while (pendingIndex < pending.Length) {
                            uint current = pending[pendingIndex++];
                            memberIndices.InsertLast(current);

                            for (uint j = 0; j < rectangles.Length; j++) {
                                if (consumed[j] || rectangles[j] is null) continue;
                                if (!CrystalExpandableRectanglesConnect(rectangles[current], rectangles[j])) continue;

                                consumed[j] = true;
                                pending.InsertLast(j);
                            }
                        }

                        auto grouped = BuildCrystalExpandableRectangleGroup(rectangles, memberIndices);
                        if (grouped is null) continue;
                        grouped.SourceIndex = source.TriggerVolumes.Length;
                        source.TriggerVolumes.InsertLast(grouped);
                        stats.RectangleGroupsRendered++;
                        if (memberIndices.Length > 1) {
                            stats.ConnectedRectanglesGrouped += memberIndices.Length;
                        }
                    }
                }

                void ProbeCrystalExpandableBlockUnitTriggers(TriggerSourceSnapshot@ source, CGameCtnChallenge@ map) {
                    if (source is null || map is null) return;

                    auto stats = CrystalExpandableRectangleStats();
                    dictionary rectangleIndexByBounds;
                    auto rectangles = array<TriggerVolume@>();
                    uint frameStart = Time::Now;

                    for (uint i = 0; i < map.Blocks.Length; i++) {
                        auto block = map.Blocks[i];
                        stats.BlocksScanned++;
                        if (block is null) {
                            frameStart = CrystalSourceBuildCheckpoint(frameStart);
                            continue;
                        }

                        auto variant = GetCrystalBlockVariantWithBaseFallback(block);
                        if (CrystalExpandableVariantHasFreeClips(variant)) {
                            stats.ExpandableCandidates++;
                            if (CrystalExpandableBlockNameLooksSpecialGate(block)) {
                                stats.NamedSpecialGateCandidates++;
                            }
                        }
                        if (!CrystalExpandableBlockShouldUseRectangle(block, variant)) {
                            frameStart = CrystalSourceBuildCheckpoint(frameStart);
                            continue;
                        }

                        stats.TargetBlocks++;
                        string targetKeys = GetCrystalExpandableRectangleTargetKeys(block);
                        vec3 worldMin;
                        vec3 worldMax;
                        string detail = "";
                        string warning = "";
                        if (!BuildCrystalExpandableRectangleWorldBounds(map, block, variant, worldMin, worldMax, detail, warning)) {
                            stats.RectanglesRejected++;
                            if (stats.FirstRejectedDetail.Length == 0) {
                                stats.FirstRejectedDetail = warning;
                            }
                            frameStart = CrystalSourceBuildCheckpoint(frameStart);
                            continue;
                        }

                        if (stats.FirstRenderedDetail.Length == 0) {
                            stats.FirstRenderedDetail = detail;
                        }
                        bool added = AddOrMergeCrystalExpandableRectangle(
                            rectangles,
                            worldMin,
                            worldMax,
                            targetKeys,
                            rectangleIndexByBounds,
                            stats
                        );
                        if (added) {
                            source.CandidateShapeCount++;
                            source.ReadableShapeCount++;
                            source.RenderedShapeCount++;
                        }
                        frameStart = CrystalSourceBuildCheckpoint(frameStart);
                    }
                    AppendCrystalExpandableRectangleGroups(
                        source,
                        rectangles,
                        stats
                    );
                    string diagnostic = "Expandable rectangle scan: scanned "
                        + tostring(stats.BlocksScanned)
                        + " placed blocks, saw "
                        + tostring(stats.ExpandableCandidates)
                        + " expandable candidates, saw "
                        + tostring(stats.NamedSpecialGateCandidates)
                        + " GateExpandableSpecial name candidates, matched "
                        + tostring(stats.TargetBlocks)
                        + " gameplay-special expandable gate blocks, rendered "
                        + tostring(stats.RectanglesRendered)
                        + " source rectangles into "
                        + tostring(stats.RectangleGroupsRendered)
                        + " connected groups, grouped "
                        + tostring(stats.ConnectedRectanglesGrouped)
                        + " connected rectangles, merged "
                        + tostring(stats.RectanglesMerged)
                        + " duplicate-position rectangles, rejected "
                        + tostring(stats.RectanglesRejected)
                        + ". Geometry is one approximate local rectangle per GateExpandableSpecial* block with public expandable/free-clip support and gameplay-special MaterialModifier metadata; other expandable blocks use the normal Crystal trigger paths. Script-clip connectivity and runtime trigger objects are intentionally not probed.";
                    if (stats.RectangleLimitSkipped > 0) {
                        diagnostic += " Rectangle limit skipped " + tostring(stats.RectangleLimitSkipped) + ".";
                    }
                    if (stats.FirstRenderedDetail.Length > 0) {
                        diagnostic += " First rendered " + stats.FirstRenderedDetail + ".";
                    }
                    if (stats.FirstRejectedDetail.Length > 0) {
                        diagnostic += " First rejected " + stats.FirstRejectedDetail + ".";
                    }
                    AddCrystalDiagnostic(source, diagnostic);
                }
            }
        }
    }
}
