namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                bool ProbeCrystalExpandableEditorScriptClipTriggers(
                    TriggerSourceSnapshot@ source,
                    CGameCtnChallenge@ map
                ) {
                    if (source is null || map is null) return false;

                    auto pluginMap = CrystalGetExpandableEditorPluginMap(map);
                    if (pluginMap is null) {
                        string noPluginMapDiagnostic = "Expandable editor script-clip pass skipped: CGameCtnEditorFree.PluginMapType is unavailable for this runtime context.";
                        AddCrystalDiagnostic(
                            source,
                            noPluginMapDiagnostic
                        );
                        log(
                            noPluginMapDiagnostic,
                            LogLevel::Info,
                            18,
                            "UnknownFunction"
                        );
                        return false;
                    }

                    auto editorStats = CrystalExpandableEditorScriptClipStats();
                    auto renderStats = CrystalExpandableScanStats();
                    auto queue = array<CGameCtnBlock@>();
                    dictionary queuedBlocks;
                    dictionary visitedBlocks;
                    auto units = array<CrystalExpandableBlockUnitRef@>();
                    dictionary unitIndexByGrid;
                    auto edgeFromGridKeys = array<string>();
                    auto edgeToGridKeys = array<string>();
                    auto edgeDirs = array<int>();
                    dictionary edgeKeys;
                    uint frameStart = Time::Now;
                    bool pickedBlockFromRecent = false;
                    string pickedBlockDetail = "";
                    auto pickedBlock = CrystalGetExpandableEditorPickedBlock(
                        pluginMap,
                        pickedBlockFromRecent,
                        pickedBlockDetail
                    );
                    if (pickedBlock !is null) {
                        editorStats.BlocksScanned++;
                        auto pickedVariant = GetCrystalBlockVariantWithBaseFallback(pickedBlock);
                        string pickedTargetKeys = "";
                        string pickedTargetDetail = "";
                        if (CrystalTryGetExpandableEditorScriptClipTargetKeys(pluginMap, pickedBlock, pickedVariant, pickedTargetKeys, pickedTargetDetail, true, true, editorStats)) {
                            editorStats.PickedPrioritySeedUsed = true;
                            CrystalQueueExpandableEditorBlock(
                                pickedBlock,
                                queue,
                                queuedBlocks,
                                visitedBlocks,
                                editorStats,
                                true
                            );
                        }
                    }

                    for (uint i = 0; i < map.Blocks.Length; i++) {
                        auto block = map.Blocks[i];
                        if (block is null) continue;

                        auto variant = GetCrystalBlockVariantWithBaseFallback(block);
                        bool canParticipate = CrystalExpandableEditorBlockCanParticipate(block, variant);
                        if (!canParticipate) {
                            frameStart = CrystalExpandableScanBudgetCheckpoint(frameStart);
                            continue;
                        }

                        bool hasWaypointTarget = CrystalBlockHasWaypointTarget(block);
                        bool canCarryTriggerArea = CrystalExpandableEditorBlockCanCarryTriggerArea(block);
                        bool hasSpecialMaterialTarget = canCarryTriggerArea
                            && CrystalBlockHasGameplaySpecialMaterialModifier(block);
                        if (!hasWaypointTarget && !hasSpecialMaterialTarget) {
                            frameStart = CrystalExpandableScanBudgetCheckpoint(frameStart);
                            continue;
                        }

                        if (hasSpecialMaterialTarget) {
                            editorStats.SpecialMaterialCandidates++;
                            if (CrystalExpandableEditorVariantHasSpecialGateModelEvidence(variant)) {
                                editorStats.SpecialMaterialGateModelCandidates++;
                            }
                            editorStats.SpecialMaterialClipCarrierCandidates++;
                            try {
                                if (variant.Size.x != 1 || variant.Size.y != 1 || variant.Size.z != 1) {
                                    editorStats.SpecialMaterialNonSingleCellCandidates++;
                                }
                                if (variant.Size.y > 1) {
                                    editorStats.SpecialMaterialTallCandidates++;
                                }
                            } catch {
                                logging::HandledException(
                                    "TriggerVisualizer::Trigger::Data::Sources::ProbeCrystalExpandableEditorScriptClipTriggers",
                                    "Variant.Size was not readable for special material stats."
                                );
                            }
                            try {
                                if (variant.BlockUnitInfos.Length > 1 || variant.BlockUnitModels.Length > 1) {
                                    editorStats.SpecialMaterialMultiUnitInfoCandidates++;
                                }
                            } catch {
                                logging::HandledException(
                                    "TriggerVisualizer::Trigger::Data::Sources::ProbeCrystalExpandableEditorScriptClipTriggers",
                                    "Variant unit-info buffers were not readable for special material stats."
                                );
                            }
                            editorStats.SpecialMaterialCarryAreaCandidates++;
                        }
                        editorStats.BlocksScanned++;
                        string targetKeys = "";
                        string targetDetail = "";
                        if (!CrystalTryGetExpandableEditorScriptClipTargetKeys(pluginMap, block, variant, targetKeys, targetDetail, true, true, editorStats)) {
                            frameStart = CrystalExpandableScanBudgetCheckpoint(frameStart);
                            continue;
                        }

                        if (editorStats.SeedsQueued >= MAX_CRYSTAL_EXPANDABLE_EDITOR_SCRIPT_CLIP_SEEDS) {
                            editorStats.SeedLimitHit = true;
                            break;
                        }
                        CrystalQueueExpandableEditorBlock(
                            block,
                            queue,
                            queuedBlocks,
                            visitedBlocks,
                            editorStats,
                            true
                        );
                        frameStart = CrystalExpandableScanBudgetCheckpoint(frameStart);
                    }
                    if (queue.Length == 0) {
                        string noSeedsDiagnostic = "Expandable editor script-clip scan found no target seeds after scanning "
                            + tostring(editorStats.BlocksScanned)
                            + " placed blocks. Seeds require a non-road/non-terrain/non-clip expandable carrier with public editor free-clip support plus either a public waypoint target or gameplay-special MaterialModifier on that same clip-proven carrier; block names are not used and MaterialModifier alone does not create geometry.";
                        AddCrystalDiagnostic(
                            source,
                            noSeedsDiagnostic
                        );
                        log(
                            noSeedsDiagnostic,
                            LogLevel::Info,
                            146,
                            "UnknownFunction"
                        );
                        return false;
                    }

                    uint queueIndex = 0;
                    while (queueIndex < queue.Length) {
                        auto block = queue[queueIndex++];
                        string blockKey = CrystalExpandableBlockQueueKey(block);
                        if (blockKey.Length == 0 || visitedBlocks.Exists(blockKey)) continue;
                        visitedBlocks.Set(blockKey, true);
                        editorStats.BlocksVisited++;
                        CrystalCollectExpandableEditorScriptClipUnitsForBlock(
                            pluginMap,
                            block,
                            queue,
                            queuedBlocks,
                            visitedBlocks,
                            units,
                            unitIndexByGrid,
                            edgeFromGridKeys,
                            edgeToGridKeys,
                            edgeDirs,
                            edgeKeys,
                            editorStats,
                            renderStats
                        );
                        if (editorStats.BlockLimitHit || units.Length >= MAX_CRYSTAL_EXPANDABLE_BLOCK_UNITS) {
                            renderStats.UnitLimitHit = units.Length >= MAX_CRYSTAL_EXPANDABLE_BLOCK_UNITS;
                            break;
                        }
                        frameStart = CrystalExpandableScanBudgetCheckpoint(frameStart);
                    }
                    if (units.Length == 0) {
                        string noUnitsDiagnostic = "Expandable editor script-clip pass queued "
                            + tostring(editorStats.SeedsQueued)
                            + " target seeds but collected no script-clip connectable cells from "
                            + tostring(editorStats.BlocksVisited)
                            + " visited blocks; clip list failures "
                            + tostring(editorStats.ClipListFailures)
                            + ".";
                        if (editorStats.FirstSeedDetail.Length > 0) noUnitsDiagnostic += " First seed " + editorStats.FirstSeedDetail + ".";
                        AddCrystalDiagnostic(
                            source,
                            noUnitsDiagnostic
                        );
                        log(
                            noUnitsDiagnostic,
                            LogLevel::Info,
                            196,
                            "UnknownFunction"
                        );
                        return false;
                    }

                    auto connectedMasks = array<uint>(units.Length, 0);
                    auto neighbors = array<array<uint> @>(units.Length);
                    auto neighborDirs = array<array<int> @>(units.Length);
                    for (uint i = 0; i < units.Length; i++) {
                        @neighbors[i] = array<uint>();
                        @neighborDirs[i] = array<int>();
                    }

                    uint edgeCount = CrystalMinUint(
                        edgeFromGridKeys.Length,
                        CrystalMinUint(edgeToGridKeys.Length, edgeDirs.Length)
                    );
                    for (uint i = 0; i < edgeCount; i++) {
                        int fromIndexInt = -1;
                        int toIndexInt = -1;
                        if (!unitIndexByGrid.Get(edgeFromGridKeys[i], fromIndexInt)) continue;
                        if (!unitIndexByGrid.Get(edgeToGridKeys[i], toIndexInt)) continue;
                        if (fromIndexInt < 0 || toIndexInt < 0) continue;
                        if (fromIndexInt >= int(units.Length) || toIndexInt >= int(units.Length)) continue;
                        if (fromIndexInt == toIndexInt) continue;

                        uint fromIndex = uint(fromIndexInt);
                        uint toIndex = uint(toIndexInt);
                        int dir = edgeDirs[i];
                        int opposite = CrystalExpandableOppositeDir(dir);
                        if (opposite < 0) continue;

                        connectedMasks[fromIndex] = connectedMasks[fromIndex] | CrystalExpandableDirBit(dir);
                        connectedMasks[toIndex] = connectedMasks[toIndex] | CrystalExpandableDirBit(opposite);
                        neighbors[fromIndex].InsertLast(toIndex);
                        neighborDirs[fromIndex].InsertLast(dir);
                        neighbors[toIndex].InsertLast(fromIndex);
                        neighborDirs[toIndex].InsertLast(opposite);
                    }

                    auto consumed = array<bool>(units.Length, false);
                    for (uint i = 0; i < units.Length; i++) {
                        if (consumed[i] || units[i] is null) continue;
                        if (renderStats.ComponentsSeen >= MAX_CRYSTAL_EXPANDABLE_BLOCK_COMPONENTS) {
                            renderStats.ComponentLimitHit = true;
                            break;
                        }

                        auto pending = array<uint>();
                        auto memberIndices = array<uint>();
                        pending.InsertLast(i);
                        consumed[i] = true;
                        uint pendingIndex = 0;
                        uint northSouthEdges = 0;
                        uint eastWestEdges = 0;

                        while (pendingIndex < pending.Length) {
                            uint currentIndex = pending[pendingIndex++];
                            memberIndices.InsertLast(currentIndex);
                            if (currentIndex >= neighbors.Length || neighbors[currentIndex] is null) continue;

                            for (uint j = 0; j < neighbors[currentIndex].Length; j++) {
                                uint neighborIndex = neighbors[currentIndex][j];
                                if (neighborIndex >= units.Length || units[neighborIndex] is null) continue;
                                int dir = j < neighborDirs[currentIndex].Length ? neighborDirs[currentIndex][j] :-1;
                                if (currentIndex < neighborIndex) {
                                    if (dir == CRYSTAL_EXPANDABLE_DIR_NORTH || dir == CRYSTAL_EXPANDABLE_DIR_SOUTH) {
                                        northSouthEdges++;
                                    } else if (dir == CRYSTAL_EXPANDABLE_DIR_EAST || dir == CRYSTAL_EXPANDABLE_DIR_WEST) {
                                        eastWestEdges++;
                                    }
                                }
                                if (!consumed[neighborIndex]) {
                                    consumed[neighborIndex] = true;
                                    pending.InsertLast(neighborIndex);
                                }
                            }
                        }
                        renderStats.ComponentsSeen++;
                        string targetKeys = GetTriggerSourceTargetKeys(TRIGGER_SOURCE_CRYSTAL);
                        bool componentHasTriggerTarget = false;
                        for (uint j = 0; j < memberIndices.Length; j++) {
                            uint unitIndex = memberIndices[j];
                            if (unitIndex >= units.Length || units[unitIndex] is null) continue;
                            if (!units[unitIndex].HasTriggerTarget) continue;

                            componentHasTriggerTarget = true;
                            targetKeys = MergeTriggerTargetKeys(targetKeys, units[unitIndex].TargetKeys);
                        }
                        if (!componentHasTriggerTarget) continue;

                        renderStats.ComponentsEligible++;
                        AddCrystalExpandableComponentVolumes(
                            source,
                            map,
                            units,
                            memberIndices,
                            connectedMasks,
                            targetKeys,
                            northSouthEdges,
                            eastWestEdges,
                            renderStats.ComponentsEligible - 1,
                            renderStats
                        );
                        frameStart = CrystalExpandableScanBudgetCheckpoint(frameStart);
                    }

                    string diagnostic = "Expandable editor script-clip scan: scanned "
                        + tostring(editorStats.BlocksScanned)
                        + " blocks, queued "
                        + tostring(editorStats.SeedsQueued)
                        + " target seeds, visited "
                        + tostring(editorStats.BlocksVisited)
                        + " connected expandable blocks, queued "
                        + tostring(editorStats.NeighborBlocksQueued)
                        + " neighbor endpoint blocks, read "
                        + tostring(editorStats.ClipsRead)
                        + " script clips from "
                        + tostring(editorStats.ClipListsCreated)
                        + " editor clip lists, built "
                        + tostring(editorStats.EdgesRead)
                        + " clip edges, collected "
                        + tostring(renderStats.UnitsCollected)
                        + " script-clip connectable cells, saw "
                        + tostring(renderStats.ComponentsSeen)
                        + " components, rendered "
                        + tostring(renderStats.RectanglesRendered)
                        + " rectangles from "
                        + tostring(renderStats.ComponentsEligible)
                        + " eligible components. Geometry comes from CGameEditorMapScriptClipList public clip endpoints, offsets, and Clip.GetConnectableCoord as equal-sized cell rectangles, not block names or raw BlockUnitInfo clip buffers.";
                    if (editorStats.SeedLimitHit) diagnostic += " Seed limit hit " + tostring(MAX_CRYSTAL_EXPANDABLE_EDITOR_SCRIPT_CLIP_SEEDS) + ".";
                    if (editorStats.BlockLimitHit) diagnostic += " Connected block limit hit " + tostring(MAX_CRYSTAL_EXPANDABLE_EDITOR_SCRIPT_CLIP_BLOCKS) + ".";
                    if (editorStats.ClipLimitHit) diagnostic += " Per-block script clip limit hit " + tostring(MAX_CRYSTAL_EXPANDABLE_EDITOR_SCRIPT_CLIPS_PER_BLOCK) + ".";
                    if (renderStats.UnitLimitHit) diagnostic += " Unit limit hit " + tostring(MAX_CRYSTAL_EXPANDABLE_BLOCK_UNITS) + ".";
                    if (renderStats.ComponentLimitHit) diagnostic += " Component limit hit " + tostring(MAX_CRYSTAL_EXPANDABLE_BLOCK_COMPONENTS) + ".";
                    if (editorStats.PickedPrioritySeedUsed) diagnostic += " Focused picked/cursor block was used as the public clip/material seed.";
                    if (editorStats.SpecialMaterialCandidates > 0) {
                        diagnostic += " Special MaterialModifier candidates "
                            + tostring(editorStats.SpecialMaterialCandidates)
                            + ", with public Gate model "
                            + tostring(editorStats.SpecialMaterialGateModelCandidates)
                            + ", expandable clip carriers "
                            + tostring(editorStats.SpecialMaterialClipCarrierCandidates)
                            + ", trigger-area carriers "
                            + tostring(editorStats.SpecialMaterialCarryAreaCandidates)
                            + ", non-single-cell carriers "
                            + tostring(editorStats.SpecialMaterialNonSingleCellCandidates)
                            + ", tall carriers "
                            + tostring(editorStats.SpecialMaterialTallCandidates)
                            + ", multi-unit-info carriers "
                            + tostring(editorStats.SpecialMaterialMultiUnitInfoCandidates)
                            + ", opposed-script-clip carriers "
                            + tostring(editorStats.SpecialMaterialOpposedScriptClipCandidates)
                            + ", side-axis opposed-script-clip carriers "
                            + tostring(editorStats.SpecialMaterialSideAxisOpposedScriptClipCandidates)
                            + ".";
                    }
                    if (editorStats.ClipListFailures > 0) diagnostic += " Clip list failures " + tostring(editorStats.ClipListFailures) + ".";
                    if (editorStats.NonAdjacentEdges > 0) diagnostic += " Non-adjacent script clip edges " + tostring(editorStats.NonAdjacentEdges) + ".";
                    if (editorStats.FirstSeedDetail.Length > 0) diagnostic += " First seed " + editorStats.FirstSeedDetail + ".";
                    if (editorStats.FirstSpecialSeedDetail.Length > 0) diagnostic += " First special seed " + editorStats.FirstSpecialSeedDetail + ".";
                    if (editorStats.FirstSeedStructureDetail.Length > 0) diagnostic += " First seed structure " + editorStats.FirstSeedStructureDetail + ".";
                    if (editorStats.FirstClipDetail.Length > 0) diagnostic += " First clip " + editorStats.FirstClipDetail + ".";
                    if (renderStats.FirstRenderedBoundsDetail.Length > 0) diagnostic += " First rendered bounds " + renderStats.FirstRenderedBoundsDetail + ".";
                    if (renderStats.FirstSpecialRenderedBoundsDetail.Length > 0) diagnostic += " First special rendered bounds " + renderStats.FirstSpecialRenderedBoundsDetail + ".";
                    if (editorStats.FirstNonAdjacentEdgeDetail.Length > 0) diagnostic += " First non-adjacent edge " + editorStats.FirstNonAdjacentEdgeDetail + ".";
                    if (editorStats.FirstRejectedBlockDetail.Length > 0) diagnostic += " First rejected neighbor " + editorStats.FirstRejectedBlockDetail + ".";
                    AddCrystalDiagnostic(
                        source,
                        diagnostic
                    );
                    log(
                        diagnostic,
                        LogLevel::Info,
                        371,
                        "UnknownFunction"
                    );
                    return renderStats.RectanglesRendered > 0;
                }

                void ProbeCrystalExpandableBlockUnitTriggers(TriggerSourceSnapshot@ source, CGameCtnChallenge@ map) {
                    if (source is null || map is null) return;
                    ProbeCrystalExpandableEditorScriptClipTriggers(source, map);
                }
            }
        }
    }
}
