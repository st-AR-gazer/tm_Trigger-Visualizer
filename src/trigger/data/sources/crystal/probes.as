namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                void AddCrystalDiagnostic(TriggerSourceSnapshot@ source, const string &in diagnostic) {
                    if (source is null || diagnostic.Length == 0) return;
                    source.Diagnostics.InsertLast(diagnostic);
                }

                CrystalTriggerProbeSnapshot@ AddCrystalSurfaceProbe(
                    TriggerSourceSnapshot@ source,
                    const string &in ownerKind,
                    uint ownerIndex,
                    const string &in ownerName,
                    const string &in shapeKind,
                    CPlugSurface@ surface,
                    const string &in detail = ""
                ) {
                    if (source is null) return null;
                    if (surface is null) return null;
                    source.CandidateShapeCount++;
                    auto probe = CrystalTriggerProbeSnapshot();
                    probe.OwnerKind = ownerKind;
                    probe.OwnerIndex = ownerIndex;
                    probe.OwnerName = ownerName;
                    probe.ShapeKind = shapeKind;
                    probe.Detail = detail;
                    string gameplayDetail = CrystalSurfaceGameplayDetail(surface);
                    if (gameplayDetail.Length > 0) {
                        probe.Detail = probe.Detail.Length > 0 ? probe.Detail + " | " + gameplayDetail : gameplayDetail;
                    }
                    GmSurf@ surf = surface.m_GmSurf;
                    if (surf is null) {
                        probe.Warning = "CPlugSurface has no m_GmSurf.";
                        source.UnsupportedShapeCount++;
                    } else {
                        source.ReadableShapeCount++;
                        probe.GmSurfKind = CrystalGmSurfKind(surf);
                        string gmDetail = CrystalGmSurfDetail(surf);
                        if (probe.Detail.Length > 0 && gmDetail.Length > 0) {
                            probe.Detail += " | " + gmDetail;
                        } else if (gmDetail.Length > 0) {
                            probe.Detail = gmDetail;
                        }
                        vec3 localMin;
                        vec3 localMax;
                        string boundsWarning = "";
                        probe.CandidateForRender = TryGetCrystalGmSurfLocalBounds(
                            surf,
                            localMin,
                            localMax,
                            boundsWarning
                        );
                        if (probe.CandidateForRender) {
                            probe.HasLocalBounds = true;
                            probe.LocalMin = localMin;
                            probe.LocalMax = localMax;
                            auto outlineLines = CrystalOutlineLineBuffer();
                            string outlineWarning = "";
                            if (BuildCrystalGmSurfLocalOutlineLines(surf, outlineLines, outlineWarning)) {
                                uint outlineLineCount = outlineLines.Count();
                                for (uint i = 0; i < outlineLineCount; i++) {
                                    probe.LocalOutlineLineStarts.InsertLast(outlineLines.Starts[i]);
                                    probe.LocalOutlineLineEnds.InsertLast(outlineLines.Ends[i]);
                                }
                                string outlineDetail = "local outline lines " + tostring(probe.LocalOutlineLineCount());
                                probe.Detail = probe.Detail.Length > 0 ? probe.Detail + " | " + outlineDetail : outlineDetail;
                            }
                            if (outlineWarning.Length > 0) {
                                probe.Warning = CrystalAppendWarning(probe.Warning, outlineWarning);
                            }
                        } else {
                            probe.Warning = boundsWarning.Length > 0 ? boundsWarning : "GmSurf type is not handled by the safe bounds path.";
                            source.UnsupportedShapeCount++;
                        }
                    }
                    if (source.CrystalTriggerProbes.Length < MAX_CRYSTAL_TRIGGER_PROBES) {
                        source.CrystalTriggerProbes.InsertLast(probe);
                    } else if (source.CrystalTriggerProbes.Length == MAX_CRYSTAL_TRIGGER_PROBES) {
                        AddCrystalDiagnostic(
                            source,
                            "Crystal trigger probe list truncated at " + tostring(MAX_CRYSTAL_TRIGGER_PROBES) + " entries."
                        );
                    }
                    return probe;
                }

                string CrystalAppendWarning(const string &in existing, const string &in next) {
                    if (existing.Length == 0) return next;
                    if (next.Length == 0) return existing;
                    return existing + " " + next;
                }

                string GetCrystalSubtypeKey(const CrystalTriggerProbeSnapshot@ probe) {
                    if (probe is null) return TRIGGER_TARGET_CRYSTAL;
                    if (probe.ShapeKind.IndexOf("Teleporter") >= 0) return CRYSTAL_SUBTYPE_TELEPORTER;
                    if (probe.ShapeKind.IndexOf("Gate") >= 0) return CRYSTAL_SUBTYPE_GATE;
                    if (probe.ShapeKind.IndexOf("HelperPrefab") >= 0) return CRYSTAL_SUBTYPE_GATE;
                    if (probe.ShapeKind.IndexOf("BlockInfoMobilSkins_TriggerShapes") >= 0) return CRYSTAL_SUBTYPE_GATE;
                    if (probe.ShapeKind.IndexOf("SurfaceFromBlockItem") >= 0) return CRYSTAL_SUBTYPE_GATE;
                    if (probe.ShapeKind.IndexOf("Phy.TriggerShape") >= 0) return CRYSTAL_SUBTYPE_GATE;
                    if (probe.ShapeKind.IndexOf("NPlugTrigger_SSpecial") >= 0) return CRYSTAL_SUBTYPE_GATE;
                    if (probe.ShapeKind.IndexOf("CGameCommonItemEntityModel.TriggerShape") >= 0) return CRYSTAL_SUBTYPE_GATE;
                    if (probe.OwnerKind == "Block" || probe.OwnerKind == "BakedBlock") {
                        if (probe.ShapeKind == "WaypointTriggerShape") return CRYSTAL_SUBTYPE_BLOCK_WAYPOINT;
                        if (probe.ShapeKind.IndexOf("NPlugTrigger_SWaypoint") >= 0) return CRYSTAL_SUBTYPE_BLOCK_WAYPOINT;
                        if (probe.ShapeKind == "ScreenInteractionTriggerShape") return CRYSTAL_SUBTYPE_SCREEN_INTERACTION;
                        if (probe.ShapeKind == "Gate.Shape") return CRYSTAL_SUBTYPE_GATE;
                        if (probe.ShapeKind.IndexOf("DeprecWaypointTriggerSolid") >= 0) return CRYSTAL_SUBTYPE_BLOCK_WAYPOINT;
                        if (probe.ShapeKind.IndexOf("DeprecScreenInteractionTriggerSolid") >= 0) return CRYSTAL_SUBTYPE_SCREEN_INTERACTION;
                        return CRYSTAL_SUBTYPE_BLOCK;
                    }
                    if (probe.OwnerKind == "BlockItem") return CRYSTAL_SUBTYPE_BLOCK_ITEM;
                    if (probe.OwnerKind == "Item") return CRYSTAL_SUBTYPE_ITEM;
                    return TRIGGER_TARGET_CRYSTAL;
                }

                string GetCrystalSubtypeLabel(const CrystalTriggerProbeSnapshot@ probe) {
                    string key = GetCrystalSubtypeKey(probe);
                    if (key == CRYSTAL_SUBTYPE_BLOCK) return "Crystal Block";
                    if (key == CRYSTAL_SUBTYPE_BLOCK_WAYPOINT) return "Crystal Block Waypoint";
                    if (key == CRYSTAL_SUBTYPE_SCREEN_INTERACTION) return "Crystal Screen Interaction";
                    if (key == CRYSTAL_SUBTYPE_GATE) return "Crystal Gate";
                    if (key == CRYSTAL_SUBTYPE_TELEPORTER) return "Crystal Teleporter";
                    if (key == CRYSTAL_SUBTYPE_ITEM) return "Crystal Item";
                    if (key == CRYSTAL_SUBTYPE_BLOCK_ITEM) return "Crystal Block Item";
                    return "Crystal";
                }

                string NormalizeCrystalTriggerTypeSearchText(const string &in rawText) {
                    string text = rawText.ToLower();
                    text = text.Replace(" ", "");
                    text = text.Replace("-", "");
                    text = text.Replace("_", "");
                    text = text.Replace("/", "");
                    text = text.Replace(".", "");
                    text = text.Replace(":", "");
                    return text;
                }

                string AddCrystalTriggerTypeTargetKeysFromText(const string &in keys, const string &in rawText) {
                    string text = NormalizeCrystalTriggerTypeSearchText(rawText);
                    if (text.Length == 0) return keys;

                    string next = keys;
                    bool isVehicleTransformReset = text.IndexOf("vehicletransformreset") >= 0;
                    isVehicleTransformReset = isVehicleTransformReset || text.IndexOf("vehicletransformcarstadium") >= 0;
                    isVehicleTransformReset = isVehicleTransformReset || text.IndexOf("stadiumcar") >= 0;
                    isVehicleTransformReset = isVehicleTransformReset || text.IndexOf("vehicletransformcarsport") >= 0;
                    isVehicleTransformReset = isVehicleTransformReset || text.IndexOf("sportcar") >= 0;
                    isVehicleTransformReset = isVehicleTransformReset || text.IndexOf("gategameplaystadium") >= 0;
                    isVehicleTransformReset = isVehicleTransformReset || text.IndexOf("gategameplaysport") >= 0;
                    isVehicleTransformReset = isVehicleTransformReset || text.IndexOf("gameplaystadium") >= 0;
                    isVehicleTransformReset = isVehicleTransformReset || text.IndexOf("gameplaysport") >= 0;
                    if (isVehicleTransformReset) {
                        next = AddTriggerTargetKey(next, TRIGGER_TYPE_VEHICLE_TRANSFORM_RESET);
                    }
                    if (text.IndexOf("vehicletransformcarsnow") >= 0 || text.IndexOf("snowcar") >= 0 || text.IndexOf("gategameplaysnow") >= 0 || text.IndexOf("gameplaysnow") >= 0) {
                        next = AddTriggerTargetKey(next, TRIGGER_TYPE_VEHICLE_TRANSFORM_SNOW);
                    }
                    if (text.IndexOf("vehicletransformcarrally") >= 0 || text.IndexOf("rallycar") >= 0 || text.IndexOf("gategameplayrally") >= 0 || text.IndexOf("gameplayrally") >= 0) {
                        next = AddTriggerTargetKey(next, TRIGGER_TYPE_VEHICLE_TRANSFORM_RALLY);
                    }
                    if (text.IndexOf("vehicletransformcardesert") >= 0 || text.IndexOf("desertcar") >= 0 || text.IndexOf("gategameplaydesert") >= 0 || text.IndexOf("gameplaydesert") >= 0) {
                        next = AddTriggerTargetKey(next, TRIGGER_TYPE_VEHICLE_TRANSFORM_DESERT);
                    }

                    bool isTurboRoulette = text.IndexOf("turboroulette") >= 0
                        || text.IndexOf("turborandom") >= 0
                        || text.IndexOf("randomturbo") >= 0;
                    if (isTurboRoulette) {
                        next = AddTriggerTargetKey(next, TRIGGER_TYPE_TURBO_ROULETTE);
                    }
                    if (!isTurboRoulette && text.IndexOf("turbo2") >= 0) {
                        next = AddTriggerTargetKey(next, TRIGGER_TYPE_TURBO2);
                    } else if (!isTurboRoulette && text.IndexOf("turbo") >= 0) {
                        next = AddTriggerTargetKey(next, TRIGGER_TYPE_TURBO);
                    }
                    if (text.IndexOf("reactorboost2") >= 0 || text.IndexOf("boost2") >= 0) {
                        next = AddTriggerTargetKey(next, TRIGGER_TYPE_BOOST2);
                    } else if (text.IndexOf("reactorboost") >= 0 || text.IndexOf("boost") >= 0) {
                        next = AddTriggerTargetKey(next, TRIGGER_TYPE_BOOST);
                    }
                    if (text.IndexOf("cruise") >= 0) next = AddTriggerTargetKey(next, TRIGGER_TYPE_CRUISE);
                    if (text.IndexOf("nobrakes") >= 0 || text.IndexOf("nobrake") >= 0) next = AddTriggerTargetKey(
                        next,
                        TRIGGER_TYPE_NO_BRAKES
                    );
                    if (text.IndexOf("noengine") >= 0 || text.IndexOf("freewheeling") >= 0 || text.IndexOf("freewheel") >= 0) next = AddTriggerTargetKey(
                        next,
                        TRIGGER_TYPE_NO_ENGINE
                    );
                    if (text.IndexOf("nosteering") >= 0 || text.IndexOf("nosteer") >= 0) next = AddTriggerTargetKey(
                        next,
                        TRIGGER_TYPE_NO_STEERING
                    );
                    if (text.IndexOf("slowmo") >= 0 || text.IndexOf("slowmotion") >= 0) next = AddTriggerTargetKey(
                        next,
                        TRIGGER_TYPE_SLOWMO
                    );
                    if (text.IndexOf("fragile") >= 0) next = AddTriggerTargetKey(next, TRIGGER_TYPE_FRAGILE);
                    if (!isVehicleTransformReset && text.IndexOf("reset") >= 0) next = AddTriggerTargetKey(
                        next,
                        TRIGGER_TYPE_RESET
                    );
                    if (text.IndexOf("forceacceleration") >= 0 || text.IndexOf("forcedacceleration") >= 0) next = AddTriggerTargetKey(
                        next,
                        TRIGGER_TYPE_FORCED_ACCELERATION
                    );
                    if (text.IndexOf("nogrip") >= 0) next = AddTriggerTargetKey(next, TRIGGER_TYPE_NO_GRIP);
                    return next;
                }

                bool CrystalGameplayIdTextLooksUsable(const string &in rawText) {
                    string text = NormalizeCrystalTriggerTypeSearchText(rawText);
                    return text.Length > 0
                        && text.IndexOf("none") < 0
                        && text.IndexOf("xxxnull") < 0;
                }

                string AddCrystalGameplayIdTextTargetKey(const string &in keys, const string &in gameplayIdText) {
                    if (!CrystalGameplayIdTextLooksUsable(gameplayIdText)) return keys;
                    return AddCrystalTriggerTypeTargetKeysFromText(keys, gameplayIdText);
                }

                string AddCrystalGameplayIdNumberTargetKey(const string &in keys, int gameplayId) {
                    if (gameplayId == 1) return AddTriggerTargetKey(keys, TRIGGER_TYPE_TURBO);
                    if (gameplayId == 2) return AddTriggerTargetKey(keys, TRIGGER_TYPE_TURBO2);
                    if (gameplayId == 3) return AddTriggerTargetKey(keys, TRIGGER_TYPE_TURBO_ROULETTE);
                    if (gameplayId == 4) return AddTriggerTargetKey(keys, TRIGGER_TYPE_NO_ENGINE);
                    if (gameplayId == 5) return AddTriggerTargetKey(keys, TRIGGER_TYPE_NO_GRIP);
                    if (gameplayId == 6) return AddTriggerTargetKey(keys, TRIGGER_TYPE_NO_STEERING);
                    if (gameplayId == 7) return AddTriggerTargetKey(keys, TRIGGER_TYPE_FORCED_ACCELERATION);
                    if (gameplayId == 8) return AddTriggerTargetKey(keys, TRIGGER_TYPE_RESET);
                    if (gameplayId == 9) return AddTriggerTargetKey(keys, TRIGGER_TYPE_SLOWMO);
                    if (gameplayId == 12) return AddTriggerTargetKey(keys, TRIGGER_TYPE_BOOST);
                    if (gameplayId == 13) return AddTriggerTargetKey(keys, TRIGGER_TYPE_FRAGILE);
                    if (gameplayId == 14) return AddTriggerTargetKey(keys, TRIGGER_TYPE_BOOST2);
                    if (gameplayId == 16) return AddTriggerTargetKey(keys, TRIGGER_TYPE_NO_BRAKES);
                    if (gameplayId == 17) return AddTriggerTargetKey(keys, TRIGGER_TYPE_CRUISE);
                    if (gameplayId == 18) return AddTriggerTargetKey(keys, TRIGGER_TYPE_BOOST);
                    if (gameplayId == 19) return AddTriggerTargetKey(keys, TRIGGER_TYPE_BOOST2);
                    if (gameplayId == 20) return AddTriggerTargetKey(keys, TRIGGER_TYPE_VEHICLE_TRANSFORM_RESET);
                    if (gameplayId == 21) return AddTriggerTargetKey(keys, TRIGGER_TYPE_VEHICLE_TRANSFORM_SNOW);
                    if (gameplayId == 22) return AddTriggerTargetKey(keys, TRIGGER_TYPE_VEHICLE_TRANSFORM_RALLY);
                    if (gameplayId == 23) return AddTriggerTargetKey(keys, TRIGGER_TYPE_VEHICLE_TRANSFORM_DESERT);
                    return keys;
                }

                string CrystalGameplayIdNumberLabel(int gameplayId) {
                    if (gameplayId == 1) return "Turbo";
                    if (gameplayId == 2) return "Turbo2";
                    if (gameplayId == 3) return "TurboRoulette";
                    if (gameplayId == 4) return "FreeWheeling";
                    if (gameplayId == 5) return "NoGrip";
                    if (gameplayId == 6) return "NoSteering";
                    if (gameplayId == 7) return "ForceAcceleration";
                    if (gameplayId == 8) return "Reset";
                    if (gameplayId == 9) return "SlowMotion";
                    if (gameplayId == 12) return "ReactorBoost_Legacy";
                    if (gameplayId == 13) return "Fragile";
                    if (gameplayId == 14) return "ReactorBoost2_Legacy";
                    if (gameplayId == 16) return "NoBrakes";
                    if (gameplayId == 17) return "Cruise";
                    if (gameplayId == 18) return "ReactorBoost_Oriented";
                    if (gameplayId == 19) return "ReactorBoost2_Oriented";
                    if (gameplayId == 20) return "VehicleTransform_Reset";
                    if (gameplayId == 21) return "VehicleTransform_CarSnow";
                    if (gameplayId == 22) return "VehicleTransform_CarRally";
                    if (gameplayId == 23) return "VehicleTransform_CarDesert";
                    return "unknown";
                }

                bool CrystalGameplayIdNumberLooksUsable(int gameplayId) {
                    return gameplayId > CRYSTAL_GAMEPLAY_ID_NONE
                        && gameplayId <= CRYSTAL_GAMEPLAY_ID_MAX_KNOWN
                        && gameplayId != CRYSTAL_GAMEPLAY_ID_XXX_NULL;
                }

                string AddCrystalGameplayIdTargetKey(const string &in keys, EPlugSurfaceGameplayId gameplayId) {
                    string next = AddCrystalGameplayIdNumberTargetKey(keys, int(gameplayId));
                    return AddCrystalGameplayIdTextTargetKey(next, tostring(gameplayId));
                }

                string CrystalAppendSearchText(const string &in text, const string &in extra) {
                    if (extra.Length == 0) return text;
                    if (text.Length == 0) return extra;
                    return text + " " + extra;
                }

                string CrystalFidFileText(CSystemFidFile@ fid) {
                    if (fid is null) return "";
                    string text = string(fid.FileName);
                    string fullName = string(fid.FullFileName);
                    if (fullName.Length > 0 && fullName != text) {
                        text = CrystalAppendSearchText(text, fullName);
                    }
                    return text;
                }

                string CrystalNodFidText(CMwNod@ nod) {
                    if (nod is null) return "";

                    CSystemFidFile@ fid = null;
                    try {
                        @fid = GetFidFromNod(nod);
                    } catch {
                        logging::HandledException(
                            "CrystalNodFidText",
                            "Node fid was not readable."
                        );
                        @fid = null;
                    }
                    return CrystalFidFileText(fid);
                }

                bool CrystalCollectorAuthorLooksNadeo(const string &in rawAuthor) {
                    return NormalizeCrystalTriggerTypeSearchText(rawAuthor) == "nadeo";
                }

                string CrystalBlockInfoAuthorName(CGameCtnBlockInfo@ blockInfo) {
                    if (blockInfo is null) return "";
                    try {
                        return blockInfo.Author.GetName();
                    } catch {
                        logging::HandledException(
                            "CrystalBlockInfoAuthorName",
                            "BlockInfo.Author was not readable."
                        );
                    }
                    return "";
                }

                string CrystalItemModelAuthorName(CGameItemModel@ itemModel) {
                    if (itemModel is null) return "";
                    try {
                        return itemModel.Author.GetName();
                    } catch {
                        logging::HandledException(
                            "CrystalItemModelAuthorName",
                            "ItemModel.Author was not readable."
                        );
                    }
                    return "";
                }

                bool CrystalBlockInfoLooksCustomContent(CGameCtnBlockInfo@ blockInfo) {
                    if (blockInfo is null) return false;
                    return !CrystalCollectorAuthorLooksNadeo(CrystalBlockInfoAuthorName(blockInfo));
                }

                bool CrystalItemModelLooksCustomContent(CGameItemModel@ itemModel) {
                    if (itemModel is null) return false;
                    return !CrystalCollectorAuthorLooksNadeo(CrystalItemModelAuthorName(itemModel));
                }

                bool CrystalSurfaceLooksLikeTriggerShape(CPlugSurface@ surface) {
                    if (surface is null) return false;
                    if (CrystalSurfaceGameplayDetail(surface).Length > 0) return true;

                    string fidText = NormalizeCrystalTriggerTypeSearchText(CrystalNodFidText(surface));
                    return fidText.IndexOf("trigger") >= 0
                        || fidText.IndexOf("gameplay") >= 0;
                }

                string CrystalFidsFolderText(CSystemFidsFolder@ folder) {
                    if (folder is null) return "";

                    string text = CrystalFidsFolderNameText(folder);
                    uint leafCount = MinUint(
                        folder.Leaves.Length,
                        MAX_CRYSTAL_MATERIAL_MODIFIER_FOLDER_LEAVES
                    );
                    for (uint i = 0; i < leafCount; i++) {
                        text = CrystalAppendSearchText(text, CrystalFidFileText(folder.Leaves[i]));
                    }
                    return text;
                }

                string CrystalFidsFolderNameText(CSystemFidsFolder@ folder) {
                    if (folder is null) return "";

                    string text = string(folder.DirName);
                    string fullName = string(folder.FullDirName);
                    if (fullName.Length > 0 && fullName != text) {
                        text = CrystalAppendSearchText(text, fullName);
                    }
                    return text;
                }

                string CrystalGameSkinAndFolderText(CPlugGameSkinAndFolder@ modifier) {
                    if (modifier is null) return "";

                    string text = CrystalNodFidText(modifier);
                    text = CrystalAppendSearchText(text, CrystalNodFidText(modifier.Remapping));
                    text = CrystalAppendSearchText(text, CrystalNodFidText(modifier.Remapping_NoTrackWall_Cache));
                    text = CrystalAppendSearchText(text, CrystalFidsFolderText(modifier.RemapFolder));
                    return text;
                }

                string CrystalGameSkinAndFolderTargetText(CPlugGameSkinAndFolder@ modifier) {
                    if (modifier is null) return "";

                    string text = CrystalNodFidText(modifier);
                    text = CrystalAppendSearchText(text, CrystalNodFidText(modifier.Remapping));
                    text = CrystalAppendSearchText(text, CrystalNodFidText(modifier.Remapping_NoTrackWall_Cache));
                    text = CrystalAppendSearchText(text, CrystalFidsFolderNameText(modifier.RemapFolder));
                    return text;
                }

                string GetCrystalMaterialModifierTriggerTargetKeys(CPlugGameSkinAndFolder@ modifier) {
                    if (modifier is null) return "";

                    string fidText = CrystalGameSkinAndFolderTargetText(modifier);
                    if (fidText.Length == 0) return "";
                    return AddCrystalTriggerTypeTargetKeysFromText("", fidText);
                }

                string CrystalMaterialModifierDetailText(
                    CPlugGameSkinAndFolder@ modifier,
                    const string &in label
                ) {
                    if (modifier is null) return "";

                    string fidText = CrystalGameSkinAndFolderText(modifier);
                    if (fidText.Length == 0) return label + " <embedded>";
                    return label + " " + fidText;
                }

                string MergeCrystalMaterialModifierTargetKeys(
                    const string &in keys,
                    CPlugGameSkinAndFolder@ modifier
                ) {
                    if (modifier is null) return keys;

                    string modifierKeys = GetCrystalMaterialModifierTriggerTargetKeys(modifier);
                    if (modifierKeys.Length == 0) return keys;
                    return MergeTriggerTargetKeys(keys, modifierKeys);
                }

                string CrystalMaterialModifierDetail(CGameItemModel@ itemModel) {
                    if (itemModel is null) return "";
                    return CrystalMaterialModifierDetailText(itemModel.MaterialModifier, "material modifier");
                }

                string AddCrystalMaterialModifierTargetKeys(const string &in keys, CGameItemModel@ itemModel) {
                    if (itemModel is null) return keys;
                    return MergeCrystalMaterialModifierTargetKeys(keys, itemModel.MaterialModifier);
                }

                string CrystalBlockMaterialModifierDetail(CGameCtnBlock@ block) {
                    if (block is null || block.BlockInfo is null) return "";

                    string detail = CrystalMaterialModifierDetailText(
                        block.BlockInfo.MaterialModifier,
                        "block material modifier"
                    );
                    string detail2 = CrystalMaterialModifierDetailText(
                        block.BlockInfo.MaterialModifier2,
                        "block material modifier2"
                    );
                    if (detail.Length == 0) return detail2;
                    if (detail2.Length == 0) return detail;
                    return detail + " | " + detail2;
                }

                string AddCrystalBlockMaterialModifierTargetKeys(const string &in keys, CGameCtnBlock@ block) {
                    if (block is null || block.BlockInfo is null) return keys;

                    string next = MergeCrystalMaterialModifierTargetKeys(keys, block.BlockInfo.MaterialModifier);
                    return MergeCrystalMaterialModifierTargetKeys(next, block.BlockInfo.MaterialModifier2);
                }

                bool CrystalBlockShapeUsesMaterialModifier(const string &in shapeKind) {
                    return shapeKind == "WaypointTriggerShape"
                        || shapeKind == "Gate.Shape"
                        || shapeKind.IndexOf("HelperPrefab") >= 0
                        || shapeKind.IndexOf("BlockInfoMobilSkins_TriggerShapes") >= 0
                        || shapeKind.IndexOf("SurfaceFromBlockItem") >= 0
                        || shapeKind.IndexOf("Phy.TriggerShape") >= 0
                        || shapeKind.IndexOf("NPlugTrigger_SSpecial") >= 0
                        || shapeKind.IndexOf("CGameCommonItemEntityModel.TriggerShape") >= 0
                        || shapeKind.IndexOf("CGameGateModel.Shape") >= 0
                        || shapeKind.IndexOf("Deprec") >= 0;
                }

                bool TryReadCrystalMaterialGameplayId(CPlugMaterial@ material, int &out gameplayId) {
                    gameplayId = CRYSTAL_GAMEPLAY_ID_NONE;
                    if (material is null) return false;

                    try {
                        gameplayId = int(Dev::GetOffsetUint8(material, O_CRYSTAL_MATERIAL_GAMEPLAY_ID));
                    } catch {
                        logging::HandledException(
                            "TryReadCrystalMaterialGameplayId",
                            "Material gameplay id offset read failed."
                        );
                        gameplayId = CRYSTAL_GAMEPLAY_ID_NONE;
                        return false;
                    }

                    return CrystalGameplayIdNumberLooksUsable(gameplayId);
                }

                string CrystalAppendGameplayDetail(
                    const string &in detail,
                    const string &in source,
                    int gameplayId
                ) {
                    string next = detail;
                    if (next.Length > 0) next += ", ";
                    next += source + "=" + tostring(gameplayId) + " " + CrystalGameplayIdNumberLabel(gameplayId);
                    return next;
                }

                string CrystalSurfaceGameplayDetail(CPlugSurface@ surface) {
                    if (surface is null) return "";

                    string detail = "";
                    uint materialIdCount = MinUint(
                        surface.MaterialIds.Length,
                        MAX_CRYSTAL_SURFACE_MATERIAL_IDS_FOR_TYPE
                    );
                    for (uint i = 0; i < materialIdCount; i++) {
                        int gameplayId = int(surface.MaterialIds[i].GameplayId);
                        if (CrystalGameplayIdNumberLooksUsable(gameplayId)) {
                            detail = CrystalAppendGameplayDetail(
                                detail,
                                "MaterialIds[" + tostring(i) + "]",
                                gameplayId
                            );
                        }
                    }

                    uint materialCount = MinUint(
                        surface.Materials.Length,
                        MAX_CRYSTAL_SURFACE_MATERIAL_IDS_FOR_TYPE
                    );
                    for (uint i = 0; i < materialCount; i++) {
                        CMwNod@ materialNod = surface.Materials[i];
                        auto userMaterial = cast<CPlugMaterialUserInst>(materialNod);
                        if (userMaterial !is null) {
                            int userGameplayId = int(userMaterial.GameplayID);
                            if (CrystalGameplayIdNumberLooksUsable(userGameplayId)) {
                                detail = CrystalAppendGameplayDetail(
                                    detail,
                                    "UserMaterial[" + tostring(i) + "]",
                                    userGameplayId
                                );
                            }
                            continue;
                        }

                        auto material = cast<CPlugMaterial>(materialNod);
                        int materialGameplayId = CRYSTAL_GAMEPLAY_ID_NONE;
                        if (TryReadCrystalMaterialGameplayId(material, materialGameplayId)) {
                            detail = CrystalAppendGameplayDetail(
                                detail,
                                "Material[" + tostring(i) + "]",
                                materialGameplayId
                            );
                        }
                    }
                    if (detail.Length == 0) return "";
                    return "surface gameplay " + detail;
                }

                string AddCrystalGmSurfGameplayTargetKeys(const string &in keys, GmSurf@ surf, uint depth = 0) {
                    if (surf is null) return keys;
                    if (depth > MAX_CRYSTAL_BOUNDS_RECURSION) return keys;

                    string next = keys;
                    auto primitive = cast<GmSurfPrimitive>(surf);
                    if (primitive !is null) {
                        next = AddCrystalGameplayIdTargetKey(next, primitive.SurfaceIds_GameplayId);
                    }

                    auto mesh = cast<GmSurfMesh>(surf);
                    if (mesh !is null) {
                        uint triCount = MinUint(mesh.m_Tris.Length, 512);
                        for (uint i = 0; i < triCount; i++) {
                            next = AddCrystalGameplayIdTargetKey(next, mesh.m_Tris[i].SurfaceIds_GameplayId);
                        }
                    }

                    auto compound = cast<GmSurfCompound>(surf);
                    if (compound !is null) {
                        uint count = MinUint(compound.Surfs.Length, MAX_CRYSTAL_COMPOUND_SURFS_FOR_BOUNDS);
                        for (uint i = 0; i < count; i++) {
                            next = AddCrystalGmSurfGameplayTargetKeys(next, compound.Surfs[i], depth + 1);
                        }
                    }

                    auto compoundInstance = cast<GmSurfCompoundInstance>(surf);
                    if (compoundInstance !is null) {
                        next = AddCrystalGmSurfGameplayTargetKeys(next, compoundInstance.Compound, depth + 1);
                    }

                    return next;
                }

                string AddCrystalSurfaceGameplayTargetKeys(const string &in keys, CPlugSurface@ surface) {
                    if (surface is null) return keys;
                    string next = keys;
                    uint materialIdCount = MinUint(
                        surface.MaterialIds.Length,
                        MAX_CRYSTAL_SURFACE_MATERIAL_IDS_FOR_TYPE
                    );
                    for (uint i = 0; i < materialIdCount; i++) {
                        next = AddCrystalGameplayIdTargetKey(next, surface.MaterialIds[i].GameplayId);
                    }
                    uint materialCount = MinUint(
                        surface.Materials.Length,
                        MAX_CRYSTAL_SURFACE_MATERIAL_IDS_FOR_TYPE
                    );
                    for (uint i = 0; i < materialCount; i++) {
                        CMwNod@ materialNod = surface.Materials[i];
                        auto userMaterial = cast<CPlugMaterialUserInst>(materialNod);
                        if (userMaterial !is null) {
                            next = AddCrystalGameplayIdNumberTargetKey(next, int(userMaterial.GameplayID));
                            continue;
                        }

                        auto material = cast<CPlugMaterial>(materialNod);
                        int materialGameplayId = CRYSTAL_GAMEPLAY_ID_NONE;
                        if (TryReadCrystalMaterialGameplayId(material, materialGameplayId)) {
                            next = AddCrystalGameplayIdNumberTargetKey(next, materialGameplayId);
                        }
                    }
                    return AddCrystalGmSurfGameplayTargetKeys(next, surface.m_GmSurf);
                }

                string GetCrystalItemTargetKeys(CGameItemModel@ itemModel) {
                    string keys = GetTriggerSourceTargetKeys(TRIGGER_SOURCE_CRYSTAL);
                    keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_ITEM);
                    if (itemModel is null) return keys;
                    if (itemModel.IsStart) keys = AddTriggerTargetKey(keys, "start");
                    if (itemModel.IsCheckpoint) keys = AddTriggerTargetKey(keys, "checkpoint");
                    if (itemModel.IsFinish) keys = AddTriggerTargetKey(keys, "finish");
                    if (itemModel.IsStartFinish) keys = AddTriggerTargetKey(keys, "startfinish");
                    return keys;
                }

                string GetCrystalWaypointTriggerTargetKeys(
                    NPlugTrigger_SWaypoint@ waypointTrigger,
                    CGameItemModel@ itemModel
                ) {
                    string keys = GetCrystalItemTargetKeys(itemModel);
                    if (waypointTrigger is null) return keys;

                    string waypointType = tostring(waypointTrigger.Type).ToLower();
                    if (waypointType.IndexOf("startfinish") >= 0) {
                        keys = AddTriggerTargetKey(keys, "startfinish");
                    } else if (waypointType.IndexOf("checkpoint") >= 0) {
                        keys = AddTriggerTargetKey(keys, "checkpoint");
                    } else if (waypointType.IndexOf("finish") >= 0) {
                        keys = AddTriggerTargetKey(keys, "finish");
                    } else if (waypointType.IndexOf("start") >= 0) {
                        keys = AddTriggerTargetKey(keys, "start");
                    } else if (waypointType.IndexOf("dispenser") >= 0) {
                        keys = AddTriggerTargetKey(keys, "dispenser");
                    }
                    return keys;
                }

                string GetCrystalBlockItemTargetKeys(CGameItemModel@ itemModel) {
                    string keys = GetCrystalItemTargetKeys(itemModel);
                    keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_BLOCK_ITEM);
                    return keys;
                }

                string GetCrystalTeleporterTargetKeys(CGameItemModel@ itemModel) {
                    string keys = GetCrystalItemTargetKeys(itemModel);
                    keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_TELEPORTER);
                    keys = AddTriggerTargetKey(keys, "teleporter");
                    return keys;
                }

                string GetCrystalGateTargetKeys(CGameItemModel@ itemModel) {
                    string keys = GetCrystalItemTargetKeys(itemModel);
                    keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_GATE);
                    keys = AddTriggerTargetKey(keys, "gate");
                    return keys;
                }

                string GetCrystalBlockTargetKeys(CGameCtnBlock@ block, const string &in shapeKind) {
                    string keys = GetTriggerSourceTargetKeys(TRIGGER_SOURCE_CRYSTAL);
                    keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_BLOCK);
                    if (shapeKind == "WaypointTriggerShape") {
                        keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_BLOCK_WAYPOINT);
                        keys = AddTriggerTargetKey(keys, "waypoint");
                    } else if (shapeKind.IndexOf("NPlugTrigger_SWaypoint") >= 0) {
                        keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_BLOCK_WAYPOINT);
                        keys = AddTriggerTargetKey(keys, "waypoint");
                    } else if (shapeKind == "ScreenInteractionTriggerShape") {
                        keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_SCREEN_INTERACTION);
                        keys = AddTriggerTargetKey(keys, "screeninteraction");
                    } else if (shapeKind == "Gate.Shape") {
                        keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_GATE);
                        keys = AddTriggerTargetKey(keys, "gate");
                    } else if (shapeKind.IndexOf("HelperPrefab") >= 0) {
                        keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_GATE);
                        keys = AddTriggerTargetKey(keys, "gate");
                    } else if (shapeKind.IndexOf("BlockInfoMobilSkins_TriggerShapes") >= 0) {
                        keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_GATE);
                        keys = AddTriggerTargetKey(keys, "gate");
                    } else if (shapeKind.IndexOf("SurfaceFromBlockItem") >= 0) {
                        keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_GATE);
                        keys = AddTriggerTargetKey(keys, "gate");
                    } else if (shapeKind.IndexOf("Phy.TriggerShape") >= 0) {
                        keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_GATE);
                        keys = AddTriggerTargetKey(keys, "gate");
                    } else if (shapeKind.IndexOf("NPlugTrigger_SSpecial") >= 0 || shapeKind.IndexOf("CGameCommonItemEntityModel.TriggerShape") >= 0 || shapeKind.IndexOf("CGameGateModel.Shape") >= 0) {
                        keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_GATE);
                        keys = AddTriggerTargetKey(keys, "gate");
                    } else if (shapeKind.IndexOf("DeprecWaypointTriggerSolid") >= 0) {
                        keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_BLOCK_WAYPOINT);
                        keys = AddTriggerTargetKey(keys, "waypoint");
                    } else if (shapeKind.IndexOf("DeprecScreenInteractionTriggerSolid") >= 0) {
                        keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_SCREEN_INTERACTION);
                        keys = AddTriggerTargetKey(keys, "screeninteraction");
                    } else if (shapeKind == "Teleporter.TriggerShape") {
                        keys = AddTriggerTargetKey(keys, CRYSTAL_SUBTYPE_TELEPORTER);
                        keys = AddTriggerTargetKey(keys, "teleporter");
                    }
                    if (block is null || block.BlockInfo is null) return keys;
                    if (CrystalBlockShapeUsesMaterialModifier(shapeKind)) {
                        keys = AddCrystalBlockMaterialModifierTargetKeys(keys, block);
                    }
                    auto waypointType = block.BlockInfo.WaypointType;
                    if (waypointType == CGameCtnBlockInfo::EWayPointType::Start) {
                        keys = AddTriggerTargetKey(keys, "start");
                    } else if (waypointType == CGameCtnBlockInfo::EWayPointType::Checkpoint) {
                        keys = AddTriggerTargetKey(keys, "checkpoint");
                    } else if (waypointType == CGameCtnBlockInfo::EWayPointType::Finish) {
                        keys = AddTriggerTargetKey(keys, "finish");
                    } else if (waypointType == CGameCtnBlockInfo::EWayPointType::StartFinish) {
                        keys = AddTriggerTargetKey(keys, "startfinish");
                    } else if (waypointType == CGameCtnBlockInfo::EWayPointType::Dispenser) {
                        keys = AddTriggerTargetKey(keys, "dispenser");
                    }
                    return keys;
                }
            }
        }
    }
}
