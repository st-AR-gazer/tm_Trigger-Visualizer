namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                bool CrystalTryGetExpandableEditorScriptClipTargetKeys(
                    CGameEditorPluginMap@ pluginMap,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    string &out targetKeys,
                    string &out detail,
                    bool allowWaypointTargets,
                    bool allowMaterialClipTargetEvidence,
                    CrystalExpandableEditorScriptClipStats@ editorStats
                ) {
                    targetKeys = "";
                    detail = "";
                    if (!CrystalExpandableEditorBlockCanParticipate(block, variant)) return false;

                    if (allowWaypointTargets && CrystalBlockHasExpandableWaypointTriggerTarget(block)) {
                        targetKeys = AddCrystalBlockWaypointTargetKeysNoMaterial(
                            GetTriggerSourceTargetKeys(TRIGGER_SOURCE_CRYSTAL),
                            block
                        );
                        detail = "waypoint target from BlockInfo.WaypointType";
                        return true;
                    }

                    if (!CrystalExpandableEditorBlockCanCarryTriggerArea(block)) return false;
                    string specialKeys = "";
                    string specialDetail = "";
                    bool hasSpecialEvidence = CrystalTryGetExpandableSpecialGateCachedMobilTargetKeys(
                        block,
                        variant,
                        specialKeys,
                        specialDetail
                    );
                    if (!hasSpecialEvidence && allowMaterialClipTargetEvidence) {
                        hasSpecialEvidence = CrystalTryGetExpandableSpecialGateClipTargetKeys(
                            pluginMap,
                            block,
                            variant,
                            specialKeys,
                            specialDetail,
                            editorStats
                        );
                    }
                    if (!hasSpecialEvidence) return false;
                    if (CrystalTargetKeysHaveGameplaySpecial(specialKeys)) {
                        targetKeys = specialKeys;
                        detail = "special gate target from " + specialDetail + "; geometry from editor script clips";
                        return true;
                    }
                    return false;
                }

                CGameEditorPluginMap@ CrystalGetExpandableEditorPluginMap(CGameCtnChallenge@ map) {
                    auto app = cast<CTrackMania>(GetApp());
                    if (app is null || app.Editor is null) return null;

                    auto mapEditor = cast<CGameCtnEditorFree>(app.Editor);
                    if (mapEditor is null || mapEditor.PluginMapType is null) return null;

                    auto pluginMap = cast<CGameEditorPluginMap>(mapEditor.PluginMapType);
                    if (pluginMap is null) return null;
                    try {
                        if (map !is null && pluginMap.Map !is null && pluginMap.Map !is map) return null;
                    } catch {
                        logging::HandledException(
                            "CrystalGetExpandableEditorPluginMap",
                            "PluginMap.Map was not readable."
                        );
                    }
                    return pluginMap;
                }

                bool G_CrystalHasRecentExpandableEditorPickedBlock = false;
                int3 G_CrystalRecentExpandableEditorPickedBlockCoord;
                string G_CrystalRecentExpandableEditorPickedBlockDetail;
                uint G_CrystalRecentExpandableEditorPickedBlockTime = 0;

                void CrystalRememberExpandableEditorFocusBlock(
                    CGameCtnBlock@ block,
                    const string &in sourceLabel,
                    string &out pickedBlockDetail
                ) {
                    pickedBlockDetail = "";
                    if (block is null) return;
                    try {
                        G_CrystalRecentExpandableEditorPickedBlockCoord = CrystalExpandableNat3ToInt3(block.Coord);
                        G_CrystalRecentExpandableEditorPickedBlockDetail = GetCrystalBlockName(block, 0)
                            + " @"
                            + block.Coord.ToString()
                            + " via "
                            + sourceLabel;
                        G_CrystalRecentExpandableEditorPickedBlockTime = Time::Now;
                        G_CrystalHasRecentExpandableEditorPickedBlock = true;
                        pickedBlockDetail = G_CrystalRecentExpandableEditorPickedBlockDetail;
                    } catch {
                        logging::HandledException(
                            "CrystalRememberExpandableEditorFocusBlock",
                            "Focused block coord/name was not readable."
                        );
                    }
                }

                CGameCtnBlock@ CrystalGetExpandableEditorPickedBlock(
                    CGameEditorPluginMap@ pluginMap,
                    bool &out fromRecentPickedBlock,
                    string &out pickedBlockDetail
                ) {
                    fromRecentPickedBlock = false;
                    pickedBlockDetail = "";
                    auto app = cast<CTrackMania>(GetApp());
                    if (app is null || app.Editor is null) return null;

                    auto mapEditor = cast<CGameCtnEditorFree>(app.Editor);
                    if (mapEditor is null) return null;

                    CGameCtnBlock@ pickedBlock = null;
                    try {
                        @pickedBlock = mapEditor.PickedBlock;
                    } catch {
                        @pickedBlock = null;
                    }
                    if (pickedBlock !is null) {
                        CrystalRememberExpandableEditorFocusBlock(pickedBlock, "PickedBlock", pickedBlockDetail);
                        return pickedBlock;
                    }

                    if (pluginMap !is null) {
                        try {
                            int3 cursorCoord = CrystalExpandableNat3ToInt3(pluginMap.CursorCoord);
                            @pickedBlock = pluginMap.GetBlock(cursorCoord);
                        } catch {
                            @pickedBlock = null;
                        }
                        if (pickedBlock !is null) {
                            CrystalRememberExpandableEditorFocusBlock(pickedBlock, "CursorCoord", pickedBlockDetail);
                            return pickedBlock;
                        }
                    }

                    if (!G_CrystalHasRecentExpandableEditorPickedBlock || pluginMap is null || G_CrystalRecentExpandableEditorPickedBlockTime == 0 || Time::Now - G_CrystalRecentExpandableEditorPickedBlockTime > CRYSTAL_EXPANDABLE_PICKED_BLOCK_STICKY_MS) {
                        return null;
                    }

                    try {
                        @pickedBlock = pluginMap.GetBlock(G_CrystalRecentExpandableEditorPickedBlockCoord);
                    } catch {
                        @pickedBlock = null;
                    }
                    if (pickedBlock is null) return null;
                    fromRecentPickedBlock = true;
                    pickedBlockDetail = G_CrystalRecentExpandableEditorPickedBlockDetail;
                    return pickedBlock;
                }

                string CrystalExpandableBlockQueueKey(CGameCtnBlock@ block) {
                    if (block is null) return "";
                    try {
                        return CrystalExpandableGridKey(CrystalExpandableNat3ToInt3(block.Coord));
                    } catch {
                        logging::HandledException(
                            "CrystalExpandableBlockQueueKey",
                            "Block.Coord was not readable."
                        );
                    }
                    return "";
                }

                string CrystalExpandableEditorConnectionKey(const string &in a, const string &in b) {
                    return a + "->" + b;
                }

                int CrystalExpandableEditorDirFromDelta(const int3 &in fromGrid, const int3 &in toGrid) {
                    int dx = toGrid.x - fromGrid.x;
                    int dy = toGrid.y - fromGrid.y;
                    int dz = toGrid.z - fromGrid.z;
                    if (dx == 1 && dy == 0 && dz == 0) return CRYSTAL_EXPANDABLE_DIR_EAST;
                    if (dx == -1 && dy == 0 && dz == 0) return CRYSTAL_EXPANDABLE_DIR_WEST;
                    if (dx == 0 && dy == 0 && dz == -1) return CRYSTAL_EXPANDABLE_DIR_NORTH;
                    if (dx == 0 && dy == 0 && dz == 1) return CRYSTAL_EXPANDABLE_DIR_SOUTH;
                    if (dx == 0 && dy == 1 && dz == 0) return CRYSTAL_EXPANDABLE_DIR_TOP;
                    if (dx == 0 && dy == -1 && dz == 0) return CRYSTAL_EXPANDABLE_DIR_BOTTOM;
                    return -1;
                }

                int CrystalExpandableEditorMajorDirFromDelta(const int3 &in fromGrid, const int3 &in toGrid) {
                    int dx = toGrid.x - fromGrid.x;
                    int dy = toGrid.y - fromGrid.y;
                    int dz = toGrid.z - fromGrid.z;
                    int ax = Math::Abs(dx);
                    int ay = Math::Abs(dy);
                    int az = Math::Abs(dz);
                    if (ax == 0 && ay == 0 && az == 0) return -1;
                    if (ay >= ax && ay >= az) return dy >= 0 ? CRYSTAL_EXPANDABLE_DIR_TOP : CRYSTAL_EXPANDABLE_DIR_BOTTOM;
                    if (ax >= az) return dx >= 0 ? CRYSTAL_EXPANDABLE_DIR_EAST : CRYSTAL_EXPANDABLE_DIR_WEST;
                    return dz >= 0 ? CRYSTAL_EXPANDABLE_DIR_SOUTH : CRYSTAL_EXPANDABLE_DIR_NORTH;
                }

                bool CrystalExpandableEditorGridIsSane(const int3 &in grid) {
                    return Math::Abs(grid.x) < int(CRYSTAL_MAX_ABS_WORLD_COORD)
                        && Math::Abs(grid.y) < int(CRYSTAL_MAX_ABS_WORLD_COORD)
                        && Math::Abs(grid.z) < int(CRYSTAL_MAX_ABS_WORLD_COORD);
                }

                uint CrystalGetOrCreateExpandableEditorUnit(
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    const string &in ownerName,
                    const int3 &in grid,
                    const int3 &in clipCoord,
                    const int3 &in clipOffset,
                    const int3 &in clipListSize,
                    bool hasClipListSize,
                    int clipDir,
                    int clipId,
                    bool hasTriggerTarget,
                    const string &in targetKeys,
                    array<CrystalExpandableBlockUnitRef@> @units,
                    dictionary@ unitIndexByGrid,
                    CrystalExpandableScanStats@ renderStats
                ) {
                    string gridKey = CrystalExpandableGridKey(grid);
                    int existingIndex = -1;
                    if (unitIndexByGrid.Get(gridKey, existingIndex) && existingIndex >= 0 && existingIndex < int(units.Length)) {
                        auto existing = units[uint(existingIndex)];
                        if (existing !is null && hasTriggerTarget) {
                            existing.HasTriggerTarget = true;
                            existing.TargetKeys = existing.TargetKeys.Length > 0 ?
                                MergeTriggerTargetKeys(existing.TargetKeys, targetKeys) : targetKeys;
                        }
                        if (existing !is null) {
                            existing.EditorClipCount++;
                            if (!existing.HasEditorScriptClip) {
                                existing.HasEditorScriptClip = true;
                                existing.EditorClipCoord = clipCoord;
                                existing.EditorConnectableCoord = grid;
                                existing.EditorClipOffset = clipOffset;
                                existing.EditorClipListSize = clipListSize;
                                existing.HasEditorClipListSize = hasClipListSize;
                                existing.EditorClipDir = clipDir;
                                existing.EditorClipId = clipId;
                            }
                        }
                        if (renderStats !is null) renderStats.DuplicateGridUnitsSkipped++;
                        return uint(existingIndex);
                    }

                    auto unitRef = CrystalExpandableBlockUnitRef();
                    @unitRef.Block = block;
                    @unitRef.Variant = variant;
                    unitRef.BlockIndex = units.Length;
                    unitRef.OwnerKind = "EditorScriptClip";
                    unitRef.OwnerName = ownerName;
                    unitRef.Grid = grid;
                    unitRef.GridKey = gridKey;
                    unitRef.HasTriggerTarget = hasTriggerTarget;
                    unitRef.TargetKeys = targetKeys;
                    unitRef.HasEditorScriptClip = true;
                    unitRef.EditorClipCoord = clipCoord;
                    unitRef.EditorConnectableCoord = grid;
                    unitRef.EditorClipOffset = clipOffset;
                    unitRef.EditorClipListSize = clipListSize;
                    unitRef.HasEditorClipListSize = hasClipListSize;
                    unitRef.EditorClipDir = clipDir;
                    unitRef.EditorClipId = clipId;
                    unitRef.EditorClipCount = 1;
                    unitIndexByGrid.Set(gridKey, int(units.Length));
                    units.InsertLast(unitRef);
                    if (renderStats !is null) renderStats.UnitsCollected++;
                    return units.Length - 1;
                }

                bool CrystalQueueExpandableEditorBlock(
                    CGameCtnBlock@ block,
                    array<CGameCtnBlock@> @queue,
                    dictionary@ queuedBlocks,
                    dictionary@ visitedBlocks,
                    CrystalExpandableEditorScriptClipStats@ editorStats,
                    bool seed
                ) {
                    if (block is null || queue is null || queuedBlocks is null || visitedBlocks is null) return false;
                    string key = CrystalExpandableBlockQueueKey(block);
                    if (key.Length == 0 || queuedBlocks.Exists(key) || visitedBlocks.Exists(key)) return false;
                    if (queue.Length >= MAX_CRYSTAL_EXPANDABLE_EDITOR_SCRIPT_CLIP_BLOCKS) {
                        if (editorStats !is null) editorStats.BlockLimitHit = true;
                        return false;
                    }
                    queuedBlocks.Set(key, true);
                    queue.InsertLast(block);
                    if (editorStats !is null) {
                        if (seed) {
                            editorStats.SeedsQueued++;
                        } else {
                            editorStats.NeighborBlocksQueued++;
                        }
                    }
                    return true;
                }

                bool CrystalQueueExpandableEditorEndpointBlock(
                    CGameEditorPluginMap@ pluginMap,
                    CGameCtnBlock@ currentBlock,
                    const int3 &in endpoint,
                    array<CGameCtnBlock@> @queue,
                    dictionary@ queuedBlocks,
                    dictionary@ visitedBlocks,
                    CrystalExpandableEditorScriptClipStats@ editorStats
                ) {
                    if (pluginMap is null || currentBlock is null) return false;
                    CGameCtnBlock@ endpointBlock = null;
                    try {
                        @endpointBlock = pluginMap.GetBlock(endpoint);
                    } catch {
                        @endpointBlock = null;
                    }
                    if (endpointBlock is null || endpointBlock is currentBlock) return false;

                    auto endpointVariant = GetCrystalBlockVariantWithBaseFallback(endpointBlock);
                    if (!CrystalExpandableEditorBlockCanParticipate(endpointBlock, endpointVariant)) return false;

                    return CrystalQueueExpandableEditorBlock(
                        endpointBlock,
                        queue,
                        queuedBlocks,
                        visitedBlocks,
                        editorStats,
                        false
                    );
                }

                bool CrystalCollectExpandableEditorScriptClipUnitsForBlock(
                    CGameEditorPluginMap@ pluginMap,
                    CGameCtnBlock@ block,
                    array<CGameCtnBlock@> @queue,
                    dictionary@ queuedBlocks,
                    dictionary@ visitedBlocks,
                    array<CrystalExpandableBlockUnitRef@> @units,
                    dictionary@ unitIndexByGrid,
                    array<string> @edgeFromGridKeys,
                    array<string> @edgeToGridKeys,
                    array<int> @edgeDirs,
                    dictionary@ edgeKeys,
                    CrystalExpandableEditorScriptClipStats@ editorStats,
                    CrystalExpandableScanStats@ renderStats
                ) {
                    if (pluginMap is null || block is null || queue is null || queuedBlocks is null || visitedBlocks is null || units is null || unitIndexByGrid is null || edgeFromGridKeys is null || edgeToGridKeys is null || edgeDirs is null || edgeKeys is null || editorStats is null || renderStats is null) {
                        return false;
                    }

                    auto variant = GetCrystalBlockVariantWithBaseFallback(block);
                    if (!CrystalExpandableEditorBlockCanParticipate(block, variant)) {
                        editorStats.BlocksRejected++;
                        if (editorStats.FirstRejectedBlockDetail.Length == 0) {
                            editorStats.FirstRejectedBlockDetail = GetCrystalBlockName(
                                block,
                                0
                            ) + " cannot participate: no safe free-clip variant evidence or already has a normal trigger surface";
                        }
                        return false;
                    }

                    string ownerName = GetCrystalBlockName(block, 0);
                    string targetKeys = "";
                    string targetDetail = "";
                    bool hasTriggerTarget = CrystalTryGetExpandableEditorScriptClipTargetKeys(
                        pluginMap,
                        block,
                        variant,
                        targetKeys,
                        targetDetail,
                        true,
                        true,
                        editorStats
                    );
                    if (hasTriggerTarget && editorStats.FirstSeedDetail.Length == 0) {
                        editorStats.FirstSeedDetail = ownerName + " " + targetDetail;
                        editorStats.FirstSeedStructureDetail = CrystalExpandableBlockStructureDiagnostic(
                            block,
                            variant
                        );
                    }
                    if (hasTriggerTarget && CrystalTargetKeysHaveGameplaySpecial(targetKeys) && editorStats.FirstSpecialSeedDetail.Length == 0) {
                        editorStats.FirstSpecialSeedDetail = ownerName
                            + " "
                            + targetDetail;
                    }
                    CGameEditorMapScriptClipList@ clipList = null;
                    try {
                        @clipList = pluginMap.CreateFrameClipList();
                    } catch {
                        @clipList = null;
                    }
                    if (clipList is null) {
                        editorStats.ClipListFailures++;
                        return false;
                    }

                    editorStats.ClipListsCreated++;
                    bool ok = false;
                    try {
                        ok = clipList.SetClipListFromBlock(block.BlockInfo, block.Coord, block.Dir);
                    } catch {
                        ok = false;
                    }
                    if (!ok) {
                        editorStats.ClipListFailures++;
                        try {
                            clipList.Destroy();
                        } catch {
                            logging::HandledException(
                                "CrystalCollectExpandableEditorScriptClipUnitsForBlock",
                                "Clip list destroy failed after SetClipListFromBlock failure."
                            );
                        }
                        return false;
                    }

                    uint clipCount = 0;
                    try {
                        clipCount = clipList.Clips.Length;
                    } catch {
                        clipCount = 0;
                    }
                    if (clipCount > MAX_CRYSTAL_EXPANDABLE_EDITOR_SCRIPT_CLIPS_PER_BLOCK) {
                        clipCount = MAX_CRYSTAL_EXPANDABLE_EDITOR_SCRIPT_CLIPS_PER_BLOCK;
                        editorStats.ClipLimitHit = true;
                    }
                    int3 clipListSize;
                    bool hasClipListSize = false;
                    try {
                        clipListSize = CrystalExpandableNat3ToInt3(clipList.Size);
                        hasClipListSize = true;
                    } catch {
                        hasClipListSize = false;
                    }

                    for (uint i = 0; i < clipCount; i++) {
                        CGameEditorMapScriptClip@ clip = null;
                        try {
                            @clip = clipList.Clips[i];
                        } catch {
                            @clip = null;
                        }
                        if (clip is null) {
                            editorStats.ClipsRejected++;
                            continue;
                        }

                        int3 grid;
                        int3 connectableGrid;
                        int3 clipOffset;
                        int clipId = -1;
                        int clipDir = -1;
                        try {
                            grid = CrystalExpandableNat3ToInt3(clip.Coord);
                            connectableGrid = clip.GetConnectableCoord();
                            clipOffset = CrystalExpandableNat3ToInt3(clip.Offset);
                            clipId = clip.ClipId;
                            clipDir = int(clip.Dir);
                        } catch {
                            editorStats.ClipsRejected++;
                            continue;
                        }

                        if (!CrystalExpandableEditorGridIsSane(grid) || !CrystalExpandableEditorGridIsSane(connectableGrid)) {
                            editorStats.ClipsRejected++;
                            continue;
                        }

                        if (editorStats.FirstClipDetail.Length == 0) {
                            editorStats.FirstClipDetail = ownerName
                                + " blockDir " + tostring(int(block.Dir))
                                + " clip coord " + CrystalInt3Label(grid)
                                + " connectable " + CrystalInt3Label(connectableGrid)
                                + " offset " + CrystalInt3Label(clipOffset)
                                + " dir " + tostring(clipDir)
                                + " id " + tostring(clipId);
                            if (hasClipListSize) editorStats.FirstClipDetail += " listSize " + CrystalInt3Label(clipListSize);
                        }
                        CrystalGetOrCreateExpandableEditorUnit(
                            block,
                            variant,
                            ownerName,
                            connectableGrid,
                            grid,
                            clipOffset,
                            clipListSize,
                            hasClipListSize,
                            clipDir,
                            clipId,
                            hasTriggerTarget,
                            targetKeys,
                            units,
                            unitIndexByGrid,
                            renderStats
                        );
                        editorStats.ClipsRead++;
                        string fromKey = CrystalExpandableGridKey(grid);
                        string toKey = CrystalExpandableGridKey(connectableGrid);
                        if (fromKey == toKey) {
                            editorStats.ClipsRejected++;
                            continue;
                        }

                        int dir = CrystalExpandableEditorDirFromDelta(grid, connectableGrid);
                        if (dir < 0) {
                            dir = CrystalExpandableEditorMajorDirFromDelta(grid, connectableGrid);
                            editorStats.NonAdjacentEdges++;
                            if (editorStats.FirstNonAdjacentEdgeDetail.Length == 0) {
                                editorStats.FirstNonAdjacentEdgeDetail = ownerName
                                    + " clip coord " + CrystalInt3Label(grid)
                                    + " connectable " + CrystalInt3Label(connectableGrid)
                                    + " used major-axis dir " + tostring(dir);
                            }
                        }
                        if (dir < 0) {
                            editorStats.ClipsRejected++;
                            continue;
                        }

                        string edgeKey = CrystalExpandableEditorConnectionKey(fromKey, toKey);
                        string reverseEdgeKey = CrystalExpandableEditorConnectionKey(toKey, fromKey);
                        if (edgeKeys.Exists(edgeKey) || edgeKeys.Exists(reverseEdgeKey)) {
                            editorStats.DuplicateEdgesSkipped++;
                        } else {
                            edgeKeys.Set(edgeKey, true);
                            edgeKeys.Set(reverseEdgeKey, true);
                            edgeFromGridKeys.InsertLast(fromKey);
                            edgeToGridKeys.InsertLast(toKey);
                            edgeDirs.InsertLast(dir);
                            editorStats.EdgesRead++;
                        }
                        CrystalQueueExpandableEditorEndpointBlock(
                            pluginMap,
                            block,
                            grid,
                            queue,
                            queuedBlocks,
                            visitedBlocks,
                            editorStats
                        );
                        CrystalQueueExpandableEditorEndpointBlock(
                            pluginMap,
                            block,
                            connectableGrid,
                            queue,
                            queuedBlocks,
                            visitedBlocks,
                            editorStats
                        );
                    }

                    try {
                        clipList.Destroy();
                    } catch {
                        logging::HandledException(
                            "CrystalCollectExpandableEditorScriptClipUnitsForBlock",
                            "Clip list destroy failed."
                        );
                    }
                    return true;
                }
            }
        }
    }
}
