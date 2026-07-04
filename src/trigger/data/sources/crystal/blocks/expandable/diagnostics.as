namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                string CrystalExpandableBlockStructureDiagnostic(
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant
                ) {
                    if (block is null || block.BlockInfo is null) return "<null block>";

                    string detail = "infoType " + GetCrystalNodTypeName(block.BlockInfo);
                    auto classicInfo = cast<CGameCtnBlockInfoClassic>(block.BlockInfo);
                    auto roadInfo = cast<CGameCtnBlockInfoRoad>(block.BlockInfo);
                    auto clipInfo = cast<CGameCtnBlockInfoClip>(block.BlockInfo);
                    auto pylonInfo = cast<CGameCtnBlockInfoPylon>(block.BlockInfo);
                    detail += " classic " + CrystalBoolLabel(classicInfo !is null)
                        + " roadInfo " + CrystalBoolLabel(roadInfo !is null)
                        + " clipInfo " + CrystalBoolLabel(clipInfo !is null)
                        + " pylonInfo " + CrystalBoolLabel(pylonInfo !is null);
                    try {
                        detail += " isRoad " + CrystalBoolLabel(block.BlockInfo.IsRoad)
                            + " isTerrain " + CrystalBoolLabel(block.BlockInfo.IsTerrain)
                            + " isClip " + CrystalBoolLabel(block.BlockInfo.IsClip)
                            + " isPillar " + CrystalBoolLabel(block.BlockInfo.IsPillar)
                            + " multiHeightOrVFC " + CrystalBoolLabel(block.BlockInfo.IsMultiHeightPillarOrVFC)
                            + " baseType " + tostring(block.BlockInfo.BaseType)
                            + " waypointType " + tostring(block.BlockInfo.WaypointType)
                            + " edWaypointType " + tostring(block.BlockInfo.EdWaypointType);
                    } catch {
                        logging::HandledException(
                            "CrystalExpandableBlockStructureDiagnostic",
                            "BlockInfo structural fields were not readable."
                        );
                    }
                    if (classicInfo !is null) {
                        try {
                            detail += " groupInit " + tostring(classicInfo.BlockInfoGroupId_IsInit.Value)
                                + " group " + tostring(classicInfo.BlockInfoGroupId.Value);
                        } catch {
                            logging::HandledException(
                                "CrystalExpandableBlockStructureDiagnostic",
                                "Classic BlockInfo group ids were not readable."
                            );
                        }
                    }
                    if (variant !is null) {
                        try {
                            detail += " variantName " + variant.Name
                                + " variantBaseType " + tostring(variant.VariantBaseType)
                                + " multiDir " + tostring(variant.MultiDir)
                                + " hasFreeClips " + CrystalBoolLabel(variant.HasFreeClips)
                                + " normalSurface " + CrystalBoolLabel(CrystalExpandableEditorVariantHasNormalSurface(variant))
                                + " size " + variant.Size.ToString()
                                + " bbox " + CrystalInt3Label(variant.OffsetBoundingBoxMin) + ".." + CrystalInt3Label(variant.OffsetBoundingBoxMax)
                                + " blockUnits " + tostring(block.BlockUnits.Length)
                                + " unitInfos " + tostring(variant.BlockUnitInfos.Length)
                                + " unitModels " + tostring(variant.BlockUnitModels.Length)
                                + " mobils00 " + tostring(variant.Mobils00.Length);
                        } catch {
                            logging::HandledException(
                                "CrystalExpandableBlockStructureDiagnostic",
                                "Variant structural fields were not readable."
                            );
                        }
                    }
                    return detail;
                }

                string CrystalExpandableMobilShallowDiagnostic(CGameCtnBlockInfoMobil@ mobil, const string &in label) {
                    if (mobil is null) return label + " <null>";

                    string detail = label + " type " + GetCrystalNodTypeName(mobil);
                    try {
                        detail += " prefab " + CrystalBoolLabel(mobil.PrefabFid !is null);
                    } catch {
                        detail += " prefab unreadable";
                    }
                    try {
                        detail += " surfaceFromBlockItem " + CrystalBoolLabel(mobil.SurfaceFromBlockItem !is null);
                    } catch {
                        detail += " surfaceFromBlockItem unreadable";
                    }
                    try {
                        detail += " cacheWithClips " + CrystalBoolLabel(mobil.Cache_ObjectModelWithClips !is null);
                    } catch {
                        detail += " cacheWithClips unreadable";
                    }
                    try {
                        detail += " cacheWithoutClips " + CrystalBoolLabel(mobil.Cache_ObjectModelWithoutClips !is null);
                    } catch {
                        detail += " cacheWithoutClips unreadable";
                    }
                    try {
                        detail += " geomTrans " + CrystalVec3Label(mobil.GeomTranslation)
                            + " geomRot " + CrystalVec3Label(mobil.GeomRotation);
                    } catch {
                        logging::HandledException(
                            "CrystalExpandableMobilDiagnostic",
                            "Mobil geometry transform fields were not readable."
                        );
                    }
                    return detail;
                }

                string CrystalExpandableBlockMobilShallowDiagnostic(
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant
                ) {
                    if (block is null || variant is null) return "";

                    string selectedMobilDetail = "";
                    CGameCtnBlockInfoMobil@ selectedMobil = GetCrystalSelectedBlockMobil(
                        block,
                        variant,
                        selectedMobilDetail
                    );
                    string detail = CrystalExpandableMobilShallowDiagnostic(selectedMobil, selectedMobilDetail);
                    CGameCtnBlockInfoMobil@ fallbackMobil = cast<CGameCtnBlockInfoMobil>(GetCrystalVariantMobilNod(variant, 0, 0));
                    if (fallbackMobil !is null && fallbackMobil !is selectedMobil) {
                        string fallbackMobilDetail = "fallback variant mobil slot 0 index 0 len "
                            + tostring(GetCrystalVariantMobilSlotLength(variant, 0));
                        detail += " | " + CrystalExpandableMobilShallowDiagnostic(fallbackMobil, fallbackMobilDetail);
                    }
                    return detail;
                }

                string CrystalExpandableEditorScriptClipListDiagnostic(
                    CGameEditorPluginMap@ pluginMap,
                    CGameCtnBlock@ block
                ) {
                    if (pluginMap is null || block is null || block.BlockInfo is null) return "editor script clips unavailable";

                    CGameEditorMapScriptClipList@ clipList = null;
                    try {
                        @clipList = pluginMap.CreateFrameClipList();
                    } catch {
                        @clipList = null;
                    }
                    if (clipList is null) return "CreateFrameClipList returned null";

                    bool ok = false;
                    try {
                        ok = clipList.SetClipListFromBlock(block.BlockInfo, block.Coord, block.Dir);
                    } catch {
                        ok = false;
                    }
                    if (!ok) {
                        try {
                            clipList.Destroy();
                        } catch {
                            logging::HandledException(
                                "CrystalExpandableClipListDiagnostic",
                                "Clip list destroy failed after SetClipListFromBlock failure."
                            );
                        }
                        return "SetClipListFromBlock failed";
                    }

                    uint clipCount = 0;
                    int3 clipListSize;
                    bool hasClipListSize = false;
                    try {
                        clipCount = clipList.Clips.Length;
                    } catch {
                        clipCount = 0;
                    }
                    try {
                        clipListSize = CrystalExpandableNat3ToInt3(clipList.Size);
                        hasClipListSize = true;
                    } catch {
                        hasClipListSize = false;
                    }

                    string detail = "scriptClipCount " + tostring(clipCount);
                    if (hasClipListSize) detail += " listSize " + CrystalInt3Label(clipListSize);

                    uint sampleCount = CrystalMinUint(clipCount, 3);
                    for (uint i = 0; i < sampleCount; i++) {
                        CGameEditorMapScriptClip@ clip = null;
                        try {
                            @clip = clipList.Clips[i];
                        } catch {
                            @clip = null;
                        }
                        if (clip is null) continue;

                        try {
                            int3 grid = CrystalExpandableNat3ToInt3(clip.Coord);
                            int3 connectableGrid = clip.GetConnectableCoord();
                            int3 clipOffset = CrystalExpandableNat3ToInt3(clip.Offset);
                            detail += " clip[" + tostring(i) + "] coord "
                                + CrystalInt3Label(grid)
                                + " connectable "
                                + CrystalInt3Label(connectableGrid)
                                + " offset "
                                + CrystalInt3Label(clipOffset)
                                + " dir "
                                + tostring(int(clip.Dir))
                                + " id "
                                + tostring(clip.ClipId);
                        } catch {
                            detail += " clip[" + tostring(i) + "] unreadable";
                        }
                    }

                    try {
                        clipList.Destroy();
                    } catch {
                        logging::HandledException(
                            "CrystalExpandableClipListDiagnostic",
                            "Clip list destroy failed."
                        );
                    }
                    return detail;
                }

                bool CrystalTryGetExpandableOpposedEditorScriptClipEvidence(
                    CGameEditorPluginMap@ pluginMap,
                    CGameCtnBlock@ block,
                    bool &out usesBlockSideAxis,
                    string &out detail
                ) {
                    usesBlockSideAxis = false;
                    detail = "";
                    if (pluginMap is null || block is null || block.BlockInfo is null) return false;

                    CGameEditorMapScriptClipList@ clipList = null;
                    try {
                        @clipList = pluginMap.CreateFrameClipList();
                    } catch {
                        @clipList = null;
                    }
                    if (clipList is null) return false;

                    bool ok = false;
                    try {
                        ok = clipList.SetClipListFromBlock(block.BlockInfo, block.Coord, block.Dir);
                    } catch {
                        ok = false;
                    }
                    if (!ok) {
                        try {
                            clipList.Destroy();
                        } catch {
                            logging::HandledException(
                                "CrystalTryGetExpandableOpposedEditorScriptClipEvidence",
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
                    if (clipCount != 2) {
                        try {
                            clipList.Destroy();
                        } catch {
                            logging::HandledException(
                                "CrystalTryGetExpandableOpposedEditorScriptClipEvidence",
                                "Clip list destroy failed after non-opposed clip count."
                            );
                        }
                        return false;
                    }

                    int3 blockGrid = CrystalExpandableNat3ToInt3(block.Coord);
                    int3 grid0;
                    int3 grid1;
                    int3 connectable0;
                    int3 connectable1;
                    int3 offset0;
                    int3 offset1;
                    int dir0 = -1;
                    int dir1 = -1;
                    int id0 = -1;
                    int id1 = -1;
                    try {
                        auto clip0 = clipList.Clips[0];
                        auto clip1 = clipList.Clips[1];
                        grid0 = CrystalExpandableNat3ToInt3(clip0.Coord);
                        grid1 = CrystalExpandableNat3ToInt3(clip1.Coord);
                        connectable0 = clip0.GetConnectableCoord();
                        connectable1 = clip1.GetConnectableCoord();
                        offset0 = CrystalExpandableNat3ToInt3(clip0.Offset);
                        offset1 = CrystalExpandableNat3ToInt3(clip1.Offset);
                        dir0 = int(clip0.Dir);
                        dir1 = int(clip1.Dir);
                        id0 = clip0.ClipId;
                        id1 = clip1.ClipId;
                    } catch {
                        try {
                            clipList.Destroy();
                        } catch {
                            logging::HandledException(
                                "CrystalTryGetExpandableOpposedEditorScriptClipEvidence",
                                "Clip list destroy failed after clip read failure."
                            );
                        }
                        return false;
                    }

                    try {
                        clipList.Destroy();
                    } catch {
                        logging::HandledException(
                            "CrystalTryGetExpandableOpposedEditorScriptClipEvidence",
                            "Clip list destroy failed."
                        );
                    }
                    if (!CrystalExpandableInt3Equals(connectable0, blockGrid)) return false;
                    if (!CrystalExpandableInt3Equals(connectable1, blockGrid)) return false;
                    if (!CrystalExpandableInt3Opposite(offset0, offset1)) return false;
                    if (offset0.y != 0 || offset1.y != 0) return false;
                    if (offset0.x == 0 && offset0.z == 0) return false;
                    if (offset0.x != 0 && offset0.z != 0) return false;

                    int blockDir = 0;
                    try {
                        blockDir = int(block.Dir);
                    } catch {
                        blockDir = 0;
                    }
                    usesBlockSideAxis = CrystalExpandableOpposedClipOffsetUsesBlockSideAxis(block, offset0);
                    detail = "opposed public editor script clips coord "
                        + CrystalInt3Label(grid0)
                        + "/"
                        + CrystalInt3Label(grid1)
                        + " connectable "
                        + CrystalInt3Label(connectable0)
                        + " offsets "
                        + CrystalInt3Label(offset0)
                        + "/"
                        + CrystalInt3Label(offset1)
                        + " dirs "
                        + tostring(dir0)
                        + "/"
                        + tostring(dir1)
                        + " ids "
                        + tostring(id0)
                        + "/"
                        + tostring(id1)
                        + " blockDir "
                        + tostring(blockDir)
                        + " sideAxis "
                        + CrystalBoolLabel(usesBlockSideAxis);
                    return true;
                }
            }
        }
    }
}
