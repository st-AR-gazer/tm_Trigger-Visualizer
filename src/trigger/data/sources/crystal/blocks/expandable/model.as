namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                class CrystalExpandableBlockUnitRef {
                    CGameCtnBlock@ Block;
                    CGameCtnBlockUnit@ Unit;
                    CGameCtnBlockUnitInfo@ UnitInfo;
                    CGameCtnBlockInfoVariant@ Variant;
                    uint BlockIndex = 0;
                    string OwnerKind;
                    string OwnerName;
                    int3 Grid;
                    string GridKey;
                    string TargetKeys;
                    bool HasTriggerTarget = false;
                    array<string> FaceKeys;
                    bool HasEditorScriptClip = false;
                    int3 EditorClipCoord;
                    int3 EditorConnectableCoord;
                    int3 EditorClipOffset;
                    int3 EditorClipListSize;
                    bool HasEditorClipListSize = false;
                    int EditorClipDir = -1;
                    int EditorClipId = -1;
                    uint EditorClipCount = 0;

                    CrystalExpandableBlockUnitRef() {
                        FaceKeys.Resize(6);
                    }
                }

                class CrystalExpandableScanStats {
                    uint UnitsCollected = 0;
                    uint DuplicateGridUnitsSkipped = 0;
                    uint ComponentsSeen = 0;
                    uint ComponentsEligible = 0;
                    uint ComponentsOversizedSkipped = 0;
                    uint RectanglesRendered = 0;
                    uint RectanglesRejected = 0;
                    string FirstRenderedBoundsDetail;
                    string FirstSpecialRenderedBoundsDetail;
                    bool UnitLimitHit = false;
                    bool ComponentLimitHit = false;
                }

                class CrystalExpandableEditorScriptClipStats {
                    uint BlocksScanned = 0;
                    uint SeedsQueued = 0;
                    uint BlocksVisited = 0;
                    uint BlocksRejected = 0;
                    uint NeighborBlocksQueued = 0;
                    uint ClipListsCreated = 0;
                    uint ClipListFailures = 0;
                    uint ClipsRead = 0;
                    uint ClipsRejected = 0;
                    uint EdgesRead = 0;
                    uint DuplicateEdgesSkipped = 0;
                    uint NonAdjacentEdges = 0;
                    uint SpecialMaterialCandidates = 0;
                    uint SpecialMaterialGateModelCandidates = 0;
                    uint SpecialMaterialClipCarrierCandidates = 0;
                    uint SpecialMaterialCarryAreaCandidates = 0;
                    uint SpecialMaterialNonSingleCellCandidates = 0;
                    uint SpecialMaterialTallCandidates = 0;
                    uint SpecialMaterialMultiUnitInfoCandidates = 0;
                    uint SpecialMaterialOpposedScriptClipCandidates = 0;
                    uint SpecialMaterialSideAxisOpposedScriptClipCandidates = 0;
                    bool SeedLimitHit = false;
                    bool BlockLimitHit = false;
                    bool ClipLimitHit = false;
                    bool PickedPrioritySeedUsed = false;
                    string FirstSeedDetail;
                    string FirstSpecialSeedDetail;
                    string FirstSeedStructureDetail;
                    string FirstClipDetail;
                    string FirstRejectedBlockDetail;
                    string FirstNonAdjacentEdgeDetail;
                }

                int CrystalExpandableOppositeDir(int dir) {
                    if (dir == CRYSTAL_EXPANDABLE_DIR_NORTH) return CRYSTAL_EXPANDABLE_DIR_SOUTH;
                    if (dir == CRYSTAL_EXPANDABLE_DIR_EAST) return CRYSTAL_EXPANDABLE_DIR_WEST;
                    if (dir == CRYSTAL_EXPANDABLE_DIR_SOUTH) return CRYSTAL_EXPANDABLE_DIR_NORTH;
                    if (dir == CRYSTAL_EXPANDABLE_DIR_WEST) return CRYSTAL_EXPANDABLE_DIR_EAST;
                    if (dir == CRYSTAL_EXPANDABLE_DIR_TOP) return CRYSTAL_EXPANDABLE_DIR_BOTTOM;
                    if (dir == CRYSTAL_EXPANDABLE_DIR_BOTTOM) return CRYSTAL_EXPANDABLE_DIR_TOP;
                    return -1;
                }

                uint CrystalExpandableDirBit(int dir) {
                    if (dir < 0 || dir > 5) return 0;
                    return uint(1) << uint(dir);
                }

                int CrystalExpandableWorldFaceDir(CGameCtnBlock@ block, int localDir) {
                    if (localDir < CRYSTAL_EXPANDABLE_DIR_NORTH || localDir > CRYSTAL_EXPANDABLE_DIR_BOTTOM) return localDir;
                    if (localDir >= CRYSTAL_EXPANDABLE_DIR_TOP) return localDir;
                    int blockDir = 0;
                    if (block !is null) {
                        try {
                            blockDir = int(block.Dir);
                        } catch {
                            blockDir = 0;
                        }
                    }
                    if (blockDir < 0 || blockDir > 3) blockDir = 0;
                    return(localDir + blockDir) % 4;
                }

                int3 CrystalExpandableNeighborGrid(const int3 &in grid, int dir) {
                    if (dir == CRYSTAL_EXPANDABLE_DIR_NORTH) return int3(grid.x, grid.y, grid.z - 1);
                    if (dir == CRYSTAL_EXPANDABLE_DIR_EAST) return int3(grid.x + 1, grid.y, grid.z);
                    if (dir == CRYSTAL_EXPANDABLE_DIR_SOUTH) return int3(grid.x, grid.y, grid.z + 1);
                    if (dir == CRYSTAL_EXPANDABLE_DIR_WEST) return int3(grid.x - 1, grid.y, grid.z);
                    if (dir == CRYSTAL_EXPANDABLE_DIR_TOP) return int3(grid.x, grid.y + 1, grid.z);
                    if (dir == CRYSTAL_EXPANDABLE_DIR_BOTTOM) return int3(grid.x, grid.y - 1, grid.z);
                    return grid;
                }

                string CrystalExpandableGridKey(const int3 &in grid) {
                    return tostring(grid.x) + "," + tostring(grid.y) + "," + tostring(grid.z);
                }

                string CrystalExpandableUnitGridKey(CGameCtnBlockUnit@ unit) {
                    if (unit is null) return "";
                    return CrystalExpandableGridKey(int3(int(unit.AbsoluteOffset.x), int(unit.AbsoluteOffset.y), int(unit.AbsoluteOffset.z)));
                }

                int3 CrystalExpandableNat3ToInt3(const nat3 &in coord) {
                    return int3(int(coord.x), int(coord.y), int(coord.z));
                }

                bool CrystalExpandableInt3Equals(const int3 &in a, const int3 &in b) {
                    return a.x == b.x && a.y == b.y && a.z == b.z;
                }

                bool CrystalExpandableInt3Opposite(const int3 &in a, const int3 &in b) {
                    return a.x == -b.x && a.y == -b.y && a.z == -b.z;
                }

                bool CrystalExpandableOpposedClipOffsetUsesBlockSideAxis(CGameCtnBlock@ block, const int3 &in offset) {
                    if (block is null || offset.y != 0) return false;
                    bool usesX = offset.x != 0 && offset.z == 0;
                    bool usesZ = offset.z != 0 && offset.x == 0;
                    if (!usesX && !usesZ) return false;

                    int blockDir = 0;
                    try {
                        blockDir = int(block.Dir);
                    } catch {
                        blockDir = 0;
                    }
                    if (blockDir < 0 || blockDir > 3) blockDir = 0;

                    bool forwardUsesZ = blockDir == 0 || blockDir == 2;
                    return forwardUsesZ ? usesX : usesZ;
                }

                bool CrystalExpandableEditorVariantHasFreeClips(CGameCtnBlockInfoVariant@ variant) {
                    if (variant is null) return false;
                    try {
                        return variant.HasFreeClips;
                    } catch {
                        logging::HandledException(
                            "CrystalExpandableEditorVariantHasFreeClips",
                            "Variant.HasFreeClips was not readable."
                        );
                    }
                    return false;
                }

                bool CrystalExpandableEditorVariantHasNormalSurface(CGameCtnBlockInfoVariant@ variant) {
                    return CrystalVariantHasPublicBlockTriggerSurface(variant);
                }

                bool CrystalExpandableEditorBlockCanParticipate(
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant
                ) {
                    if (block is null || block.BlockInfo is null || variant is null) return false;
                    if (IsCrystalFreeBlock(block)) return false;
                    if (CrystalExpandableEditorVariantHasNormalSurface(variant)) return false;
                    return CrystalExpandableEditorVariantHasFreeClips(variant)
                        && CrystalBlockHasExpandableClipEvidence(block, variant);
                }

                bool CrystalExpandableEditorBlockCanCarryTriggerArea(CGameCtnBlock@ block) {
                    if (block is null || block.BlockInfo is null) return false;
                    try {
                        if (block.BlockInfo.IsRoad || block.BlockInfo.IsTerrain || block.BlockInfo.IsClip) return false;
                    } catch {
                        logging::HandledException(
                            "CrystalExpandableEditorBlockCanCarryTriggerArea",
                            "BlockInfo road/terrain/clip flags were not readable."
                        );
                    }
                    return true;
                }

                bool CrystalTryGetExpandableSpecialGateCachedObjectModelTargetKeys(
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoMobil@ mobil,
                    CGameObjectModel@ objectModel,
                    const string &in modelSlot,
                    string &out targetKeys,
                    string &out detail
                ) {
                    targetKeys = "";
                    detail = "";
                    if (block is null || mobil is null || objectModel is null || objectModel.Phy is null) return false;

                    string dataRefFilename = "";
                    string dataRefDetail = "";
                    string dataRefWarning = "";
                    CPlugSurface@ surface = ResolveCrystalPhyModelTriggerShapeSurface(
                        objectModel.Phy,
                        dataRefFilename,
                        dataRefDetail,
                        dataRefWarning
                    );
                    if (surface is null) return false;
                    if (mobil.SurfaceFromBlockItem !is null && surface is mobil.SurfaceFromBlockItem) return false;

                    string surfaceKeys = AddCrystalSurfaceGameplayTargetKeys(
                        GetCrystalExpandableSpecialGateBaseTargetKeys(),
                        surface
                    );
                    string keys = AddCrystalExpandableSpecialGateMaterialKeysAfterSurfaceEvidence(
                        surfaceKeys,
                        block
                    );
                    if (!CrystalTargetKeysHaveGameplaySpecial(keys)) return false;

                    targetKeys = keys;
                    detail = modelSlot + ".Phy.TriggerShape actual cached mobil trigger surface";
                    if (!CrystalTargetKeysHaveGameplaySpecial(surfaceKeys)) detail += " with MaterialModifier target after shape proof";
                    if (dataRefFilename.Length > 0) detail += " dataRef " + dataRefFilename;
                    if (dataRefDetail.Length > 0) detail += " | " + dataRefDetail;
                    return true;
                }

                bool CrystalTryGetExpandableSpecialGateCachedMobilTargetKeysForMobil(
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoMobil@ mobil,
                    const string &in mobilDetail,
                    const string &in mobilSlot,
                    string &out targetKeys,
                    string &out detail
                ) {
                    targetKeys = "";
                    detail = "";
                    if (block is null || mobil is null) return false;

                    if (mobil.SurfaceFromBlockItem !is null) {
                        string surfaceKeys = AddCrystalSurfaceGameplayTargetKeys(
                            GetCrystalExpandableSpecialGateBaseTargetKeys(),
                            mobil.SurfaceFromBlockItem
                        );
                        string keys = AddCrystalExpandableSpecialGateMaterialKeysAfterSurfaceEvidence(
                            surfaceKeys,
                            block
                        );
                        if (CrystalTargetKeysHaveGameplaySpecial(keys)) {
                            targetKeys = keys;
                            detail = mobilDetail + " " + mobilSlot + ".SurfaceFromBlockItem actual cached mobil trigger surface";
                            if (!CrystalTargetKeysHaveGameplaySpecial(surfaceKeys)) detail += " with MaterialModifier target after shape proof";
                            return true;
                        }
                    }

                    if (CrystalTryGetExpandableSpecialGateCachedObjectModelTargetKeys(block, mobil, mobil.Cache_ObjectModelWithClips, mobilSlot + ".Cache_ObjectModelWithClips", targetKeys, detail)) {
                        detail = mobilDetail + " " + detail;
                        return true;
                    }

                    if (CrystalTryGetExpandableSpecialGateCachedObjectModelTargetKeys(block, mobil, mobil.Cache_ObjectModelWithoutClips, mobilSlot + ".Cache_ObjectModelWithoutClips", targetKeys, detail)) {
                        detail = mobilDetail + " " + detail;
                        return true;
                    }
                    return false;
                }

                bool CrystalTryGetExpandableSpecialGateCachedMobilTargetKeys(
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    string &out targetKeys,
                    string &out detail
                ) {
                    targetKeys = "";
                    detail = "";
                    if (block is null || variant is null) return false;
                    if (variant.Gate !is null && variant.Gate.Shape !is null) return false;

                    string selectedMobilDetail = "";
                    CGameCtnBlockInfoMobil@ selectedMobil = GetCrystalSelectedBlockMobil(
                        block,
                        variant,
                        selectedMobilDetail
                    );
                    if (CrystalTryGetExpandableSpecialGateCachedMobilTargetKeysForMobil(block, selectedMobil, selectedMobilDetail, "SelectedMobil", targetKeys, detail)) {
                        return true;
                    }

                    CGameCtnBlockInfoMobil@ fallbackMobil = cast<CGameCtnBlockInfoMobil>(GetCrystalVariantMobilNod(variant, 0, 0));
                    if (fallbackMobil is null || fallbackMobil is selectedMobil) return false;
                    string fallbackMobilDetail = "fallback variant mobil slot 0 index 0 len "
                        + tostring(GetCrystalVariantMobilSlotLength(variant, 0))
                        + " type " + GetCrystalNodTypeName(fallbackMobil);
                    return CrystalTryGetExpandableSpecialGateCachedMobilTargetKeysForMobil(
                        block,
                        fallbackMobil,
                        fallbackMobilDetail,
                        "Mobils00[0]",
                        targetKeys,
                        detail
                    );
                }
            }
        }
    }
}
