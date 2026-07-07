namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                string CrystalExpandableAreaLabelForTargetKeys(const string &in targetKeys) {
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
                    if (TriggerTargetListContains(targetKeys, "startfinish")) return "Start/Finish Waypoint";
                    if (TriggerTargetListContains(targetKeys, "checkpoint")) return "Checkpoint";
                    if (TriggerTargetListContains(targetKeys, "finish")) return "Finish";
                    if (TriggerTargetListContains(targetKeys, "start")) return "Start";
                    if (TriggerTargetListContains(targetKeys, "dispenser")) return "Dispenser";
                    return "Waypoint";
                }

                string CrystalExpandableUnitVolumeTargetKeys(
                    const CrystalExpandableBlockUnitRef@ unitRef,
                    const string &in componentTargetKeys
                ) {
                    if (unitRef !is null && unitRef.HasTriggerTarget && unitRef.TargetKeys.Length > 0) {
                        return unitRef.TargetKeys;
                    }
                    return componentTargetKeys.Length > 0 ?
                        componentTargetKeys : GetTriggerSourceTargetKeys(TRIGGER_SOURCE_CRYSTAL);
                }

                bool CrystalBuildExpandableUnitWorldBounds(
                    CGameCtnChallenge@ map,
                    const CrystalExpandableBlockUnitRef@ unitRef,
                    bool thinX,
                    vec3 &out worldMin,
                    vec3 &out worldMax,
                    string &out warning
                ) {
                    warning = "";
                    worldMin = vec3();
                    worldMax = vec3();
                    if (map is null || unitRef is null || unitRef.Block is null) {
                        warning = "No map or block unit for expandable bounds.";
                        return false;
                    }

                    string anchorSource = "";
                    string collectionName = "";
                    int collectionId = -1;
                    uint decoBaseHeightOffset = 0;
                    float triggerGridWorldYAnchor = 0.0f;
                    float worldYAnchor = TriggerVisualizer::Trigger::Data::GetMapPlacedBlockWorldYAnchor(
                        map,
                        unitRef.Block,
                        anchorSource,
                        collectionName,
                        collectionId,
                        decoBaseHeightOffset,
                        triggerGridWorldYAnchor
                    );
                    if (!CrystalIsFiniteFloat(worldYAnchor)) {
                        warning = "Expandable block world-y anchor is not finite.";
                        return false;
                    }

                    vec3 cell = TriggerVisualizer::Trigger::Data::OFFZONE_BLOCK_WORLD_SIZE;
                    float minX = float(unitRef.Grid.x) * cell.x;
                    float maxX = float(unitRef.Grid.x + 1) * cell.x;
                    float minY = (float(unitRef.Grid.y) - worldYAnchor) * cell.y;
                    float maxY = (float(unitRef.Grid.y + 1) - worldYAnchor) * cell.y;
                    float minZ = float(unitRef.Grid.z) * cell.z;
                    float maxZ = float(unitRef.Grid.z + 1) * cell.z;

                    if (!unitRef.HasEditorScriptClip) {
                        minY += CRYSTAL_EXPANDABLE_TRIGGER_BOTTOM_INSET;
                        maxY -= CRYSTAL_EXPANDABLE_TRIGGER_TOP_INSET;
                        if (maxY - minY <= CRYSTAL_MIN_VOLUME_AXIS_SIZE) {
                            minY = (float(unitRef.Grid.y) - worldYAnchor) * cell.y;
                            maxY = (float(unitRef.Grid.y + 1) - worldYAnchor) * cell.y;
                        }
                    }
                    if (thinX) {
                        float centerX = (minX + maxX) * 0.5f;
                        minX = centerX - CRYSTAL_EXPANDABLE_TRIGGER_THICKNESS * 0.5f;
                        maxX = centerX + CRYSTAL_EXPANDABLE_TRIGGER_THICKNESS * 0.5f;
                    } else {
                        float centerZ = (minZ + maxZ) * 0.5f;
                        minZ = centerZ - CRYSTAL_EXPANDABLE_TRIGGER_THICKNESS * 0.5f;
                        maxZ = centerZ + CRYSTAL_EXPANDABLE_TRIGGER_THICKNESS * 0.5f;
                    }

                    string validationWarning = "";
                    if (!CrystalValidateBounds(vec3(minX, minY, minZ), vec3(maxX, maxY, maxZ), true, validationWarning)) {
                        warning = validationWarning;
                        return false;
                    }

                    CrystalNormalizeBounds(vec3(minX, minY, minZ), vec3(maxX, maxY, maxZ), worldMin, worldMax);
                    return true;
                }

                bool CrystalExpandableUnitUsesThinX(
                    const CrystalExpandableBlockUnitRef@ unitRef,
                    uint connectedMask,
                    uint northSouthEdges,
                    uint eastWestEdges
                ) {
                    bool hasEastWest = (connectedMask & (CrystalExpandableDirBit(CRYSTAL_EXPANDABLE_DIR_EAST) | CrystalExpandableDirBit(CRYSTAL_EXPANDABLE_DIR_WEST))) != 0;
                    bool hasNorthSouth = (connectedMask & (CrystalExpandableDirBit(CRYSTAL_EXPANDABLE_DIR_NORTH) | CrystalExpandableDirBit(CRYSTAL_EXPANDABLE_DIR_SOUTH))) != 0;
                    if (hasEastWest && !hasNorthSouth) return false;
                    if (hasNorthSouth && !hasEastWest) return true;
                    if (!hasEastWest && !hasNorthSouth && unitRef !is null && unitRef.Block !is null) {
                        int blockDir = int(unitRef.Block.Dir);
                        return blockDir == 1 || blockDir == 3;
                    }
                    return northSouthEdges > eastWestEdges;
                }

                uint AddCrystalExpandableComponentVolumes(
                    TriggerSourceSnapshot@ source,
                    CGameCtnChallenge@ map,
                    const array<CrystalExpandableBlockUnitRef@> @units,
                    const array<uint> @memberIndices,
                    const array<uint> @connectedMasks,
                    const string &in targetKeys,
                    uint northSouthEdges,
                    uint eastWestEdges,
                    uint componentNumber,
                    CrystalExpandableScanStats@ stats
                ) {
                    if (source is null || map is null || units is null || memberIndices is null || connectedMasks is null || stats is null) return 0;
                    if (memberIndices.Length > MAX_CRYSTAL_EXPANDABLE_COMPONENT_RECTANGLES) {
                        stats.ComponentsOversizedSkipped++;
                        stats.RectanglesRejected += memberIndices.Length;
                        return 0;
                    }

                    uint rendered = 0;
                    uint componentSourceIndex = source.TriggerVolumes.Length;
                    bool componentIsGate = TriggerTargetListContains(
                        targetKeys,
                        CRYSTAL_SUBTYPE_GATE
                    ) || TriggerTargetListContains(targetKeys, "gate");
                    string componentLabel = "Expandable Crystal " + CrystalExpandableAreaLabelForTargetKeys(targetKeys) + " #" + tostring(componentNumber + 1);
                    for (uint i = 0; i < memberIndices.Length; i++) {
                        uint unitIndex = memberIndices[i];
                        if (unitIndex >= units.Length || unitIndex >= connectedMasks.Length) continue;

                        string volumeTargetKeys = CrystalExpandableUnitVolumeTargetKeys(
                            units[unitIndex],
                            targetKeys
                        );
                        bool volumeIsGate = TriggerTargetListContains(
                            volumeTargetKeys,
                            CRYSTAL_SUBTYPE_GATE
                        ) || TriggerTargetListContains(volumeTargetKeys, "gate");
                        string label = componentLabel;
                        if (units[unitIndex] !is null && units[unitIndex].HasTriggerTarget && units[unitIndex].TargetKeys.Length > 0) {
                            label = "Expandable Crystal " + CrystalExpandableAreaLabelForTargetKeys(volumeTargetKeys) + " #" + tostring(componentNumber + 1);
                        }
                        vec3 worldMin;
                        vec3 worldMax;
                        string warning = "";
                        bool thinX = CrystalExpandableUnitUsesThinX(
                            units[unitIndex],
                            connectedMasks[unitIndex],
                            northSouthEdges,
                            eastWestEdges
                        );
                        if (!CrystalBuildExpandableUnitWorldBounds(map, units[unitIndex], thinX, worldMin, worldMax, warning)) {
                            stats.RectanglesRejected++;
                            continue;
                        }
                        if (stats.FirstRenderedBoundsDetail.Length == 0) {
                            vec3 size = worldMax - worldMin;
                            stats.FirstRenderedBoundsDetail = "grid " + CrystalInt3Label(units[unitIndex].Grid)
                                + " thinAxis " + (thinX ? "X" : "Z")
                                + " world " + CrystalVec3Label(worldMin) + ".." + CrystalVec3Label(worldMax)
                                + " size " + CrystalVec3Label(size);
                            if (units[unitIndex].HasEditorScriptClip) {
                                stats.FirstRenderedBoundsDetail += " clipCoord " + CrystalInt3Label(units[unitIndex].EditorClipCoord)
                                    + " connectable " + CrystalInt3Label(units[unitIndex].EditorConnectableCoord)
                                    + " offset " + CrystalInt3Label(units[unitIndex].EditorClipOffset)
                                    + " dir " + tostring(units[unitIndex].EditorClipDir)
                                    + " id " + tostring(units[unitIndex].EditorClipId)
                                    + " mergedClips " + tostring(units[unitIndex].EditorClipCount);
                                if (units[unitIndex].HasEditorClipListSize) {
                                    stats.FirstRenderedBoundsDetail += " listSize " + CrystalInt3Label(units[unitIndex].EditorClipListSize);
                                }
                            }
                        }
                        if (componentIsGate && stats.FirstSpecialRenderedBoundsDetail.Length == 0) {
                            vec3 specialSize = worldMax - worldMin;
                            stats.FirstSpecialRenderedBoundsDetail = "grid " + CrystalInt3Label(units[unitIndex].Grid)
                                + " thinAxis " + (thinX ? "X" : "Z")
                                + " world " + CrystalVec3Label(worldMin) + ".." + CrystalVec3Label(worldMax)
                                + " size " + CrystalVec3Label(specialSize);
                            if (units[unitIndex].HasEditorScriptClip) {
                                stats.FirstSpecialRenderedBoundsDetail += " clipCoord " + CrystalInt3Label(units[unitIndex].EditorClipCoord)
                                    + " connectable " + CrystalInt3Label(units[unitIndex].EditorConnectableCoord)
                                    + " offset " + CrystalInt3Label(units[unitIndex].EditorClipOffset)
                                    + " dir " + tostring(units[unitIndex].EditorClipDir)
                                    + " id " + tostring(units[unitIndex].EditorClipId)
                                    + " mergedClips " + tostring(units[unitIndex].EditorClipCount);
                                if (units[unitIndex].HasEditorClipListSize) {
                                    stats.FirstSpecialRenderedBoundsDetail += " listSize " + CrystalInt3Label(units[unitIndex].EditorClipListSize);
                                }
                            }
                        }

                        auto volume = TriggerVolume(
                            worldMin,
                            worldMax,
                            TRIGGER_SOURCE_CRYSTAL,
                            componentSourceIndex,
                            label
                        );
                        volume.DetectedLabel = volumeIsGate ? "ExpandableClip.SpecialGateArea" : "ExpandableClip.WaypointArea";
                        volume.SubtypeKey = volumeIsGate ? CRYSTAL_SUBTYPE_GATE : CRYSTAL_SUBTYPE_BLOCK_WAYPOINT;
                        volume.SubtypeLabel = volumeIsGate ? "Crystal Gate" : "Crystal Block Waypoint";
                        volume.TargetKeys = volumeTargetKeys;
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
                        volume.AllowRawRangeLabel = false;
                        source.TriggerVolumes.InsertLast(volume);
                        source.CandidateShapeCount++;
                        source.ReadableShapeCount++;
                        source.RenderedShapeCount++;
                        stats.RectanglesRendered++;
                        rendered++;
                    }
                    return rendered;
                }

                const uint CRYSTAL_EXPANDABLE_SCAN_FRAME_BUDGET_MS = 4;

                uint CrystalExpandableScanBudgetCheckpoint(uint frameStart) {
                    if (Time::Now - frameStart < CRYSTAL_EXPANDABLE_SCAN_FRAME_BUDGET_MS) return frameStart;
                    yield();
                    return Time::Now;
                }
            }
        }
    }
}
