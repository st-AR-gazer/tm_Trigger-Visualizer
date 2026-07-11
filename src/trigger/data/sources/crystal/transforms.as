namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                string GetCrystalBlockItemSpawnDetail(CGameBlockItem@ blockItem, uint shapeIndex) {
                    if (blockItem is null) return "";

                    string detail = "blockItemTriggerIndex " + tostring(shapeIndex)
                        + " archetype " + blockItem.ArchetypeBlockInfoId.GetName();
                    if (shapeIndex < blockItem.BlockInfoMobilSkins_MobilIds.Length) {
                        detail += " mobilId " + tostring(blockItem.BlockInfoMobilSkins_MobilIds[shapeIndex]);
                    }
                    if (shapeIndex < blockItem.BlockInfoMobilSkins_SpawnLocTranss.Length) {
                        detail += " spawnTrans " + CrystalVec3Label(blockItem.BlockInfoMobilSkins_SpawnLocTranss[shapeIndex]);
                    }
                    if (shapeIndex < blockItem.BlockInfoMobilSkins_SpawnLocYaws.Length) {
                        detail += " spawnYaw " + Text::Format(
                            "%.3f",
                            blockItem.BlockInfoMobilSkins_SpawnLocYaws[shapeIndex]
                        );
                    }
                    if (shapeIndex < blockItem.BlockInfoMobilSkins_SpawnLocPitchs.Length) {
                        detail += " spawnPitch " + Text::Format(
                            "%.3f",
                            blockItem.BlockInfoMobilSkins_SpawnLocPitchs[shapeIndex]
                        );
                    }
                    if (shapeIndex < blockItem.BlockInfoMobilSkins_SpawnLocRolls.Length) {
                        detail += " spawnRoll " + Text::Format(
                            "%.3f",
                            blockItem.BlockInfoMobilSkins_SpawnLocRolls[shapeIndex]
                        );
                    }
                    return detail;
                }

                bool TryGetCrystalBlockItemShapeTransform(
                    CGameBlockItem@ blockItem,
                    uint shapeIndex,
                    const mat4 &in itemTransform,
                    mat4 &out transform,
                    string &out detail,
                    string &out warning
                ) {
                    transform = mat4::Identity();
                    detail = "";
                    warning = "";

                    if (blockItem is null) {
                        warning = "No block-item model for trigger transform.";
                        return false;
                    }
                    if (shapeIndex >= blockItem.BlockInfoMobilSkins_TriggerShapes.Length) {
                        warning = "Block-item trigger shape index is outside the trigger shape buffer.";
                        return false;
                    }
                    if (shapeIndex >= blockItem.BlockInfoMobilSkins_SpawnLocTranss.Length || shapeIndex >= blockItem.BlockInfoMobilSkins_SpawnLocYaws.Length || shapeIndex >= blockItem.BlockInfoMobilSkins_SpawnLocPitchs.Length || shapeIndex >= blockItem.BlockInfoMobilSkins_SpawnLocRolls.Length) {
                        warning = "Missing public block-item spawn transform buffer for trigger index.";
                        return false;
                    }

                    vec3 spawnTrans = blockItem.BlockInfoMobilSkins_SpawnLocTranss[shapeIndex];
                    float spawnYaw = blockItem.BlockInfoMobilSkins_SpawnLocYaws[shapeIndex];
                    float spawnPitch = blockItem.BlockInfoMobilSkins_SpawnLocPitchs[shapeIndex];
                    float spawnRoll = blockItem.BlockInfoMobilSkins_SpawnLocRolls[shapeIndex];
                    if (!CrystalIsFiniteVec3(spawnTrans) || !CrystalIsFiniteFloat(spawnYaw) || !CrystalIsFiniteFloat(spawnPitch) || !CrystalIsFiniteFloat(spawnRoll)) {
                        warning = "Block-item spawn transform contains NaN or Inf.";
                        return false;
                    }

                    mat4 spawnTransform = mat4::Translate(spawnTrans)
                        * CrystalEulerToMat(vec3(spawnPitch, spawnYaw, spawnRoll));
                    transform = itemTransform * spawnTransform;
                    detail = "transform item * public BlockInfoMobilSkins spawn";
                    return true;
                }

                bool TryGetCrystalVariantSurfaceTransform(
                    CGameCtnBlockInfoVariant@ variant,
                    const mat4 &in blockTransform,
                    mat4 &out transform,
                    string &out detail,
                    string &out warning
                ) {
                    transform = blockTransform;
                    detail = "transform block";
                    warning = "";

                    if (variant is null) {
                        warning = "No selected block variant for surface transform.";
                        return false;
                    }

                    if (variant.CompoundModel is null) {
                        detail += " (no CompoundModel)";
                        return true;
                    }

                    mat4 compoundTransform = mat4(variant.CompoundLoc);
                    vec3 compoundOrigin = (compoundTransform * vec3()).xyz;
                    if (!CrystalIsFiniteVec3(compoundOrigin)) {
                        warning = "Variant CompoundLoc origin is not finite.";
                        return false;
                    }

                    transform = blockTransform * compoundTransform;
                    detail += " * public variant CompoundLoc origin " + CrystalVec3Label(compoundOrigin);
                    return true;
                }

                uint GetCrystalVariantMobilSlotLength(CGameCtnBlockInfoVariant@ variant, uint slot) {
                    if (variant is null) return 0;
                    if (slot == 0) return variant.Mobils00.Length;
                    if (slot == 1) return variant.Mobils01.Length;
                    if (slot == 2) return variant.Mobils02.Length;
                    if (slot == 3) return variant.Mobils03.Length;
                    if (slot == 4) return variant.Mobils04.Length;
                    if (slot == 5) return variant.Mobils05.Length;
                    if (slot == 6) return variant.Mobils06.Length;
                    if (slot == 7) return variant.Mobils07.Length;
                    if (slot == 8) return variant.Mobils08.Length;
                    if (slot == 9) return variant.Mobils09.Length;
                    if (slot == 10) return variant.Mobils10.Length;
                    if (slot == 11) return variant.Mobils11.Length;
                    if (slot == 12) return variant.Mobils12.Length;
                    if (slot == 13) return variant.Mobils13.Length;
                    if (slot == 14) return variant.Mobils14.Length;
                    if (slot == 15) return variant.Mobils15.Length;
                    return 0;
                }

                CMwNod@ GetCrystalVariantMobilNod(CGameCtnBlockInfoVariant@ variant, uint slot, uint index) {
                    if (variant is null) return null;
                    if (slot == 0 && index < variant.Mobils00.Length) return variant.Mobils00[index];
                    if (slot == 1 && index < variant.Mobils01.Length) return variant.Mobils01[index];
                    if (slot == 2 && index < variant.Mobils02.Length) return variant.Mobils02[index];
                    if (slot == 3 && index < variant.Mobils03.Length) return variant.Mobils03[index];
                    if (slot == 4 && index < variant.Mobils04.Length) return variant.Mobils04[index];
                    if (slot == 5 && index < variant.Mobils05.Length) return variant.Mobils05[index];
                    if (slot == 6 && index < variant.Mobils06.Length) return variant.Mobils06[index];
                    if (slot == 7 && index < variant.Mobils07.Length) return variant.Mobils07[index];
                    if (slot == 8 && index < variant.Mobils08.Length) return variant.Mobils08[index];
                    if (slot == 9 && index < variant.Mobils09.Length) return variant.Mobils09[index];
                    if (slot == 10 && index < variant.Mobils10.Length) return variant.Mobils10[index];
                    if (slot == 11 && index < variant.Mobils11.Length) return variant.Mobils11[index];
                    if (slot == 12 && index < variant.Mobils12.Length) return variant.Mobils12[index];
                    if (slot == 13 && index < variant.Mobils13.Length) return variant.Mobils13[index];
                    if (slot == 14 && index < variant.Mobils14.Length) return variant.Mobils14[index];
                    if (slot == 15 && index < variant.Mobils15.Length) return variant.Mobils15[index];
                    return null;
                }

                CGameCtnBlockInfoMobil@ GetCrystalSelectedBlockMobil(
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    string &out detail
                ) {
                    detail = "";
                    if (block is null || variant is null) return null;

                    uint slot = block.MobilVariantIndex;
                    uint index = block.MobilIndex;
                    uint length = GetCrystalVariantMobilSlotLength(variant, slot);
                    detail = "selected mobil slot " + tostring(slot) + " index " + tostring(index) + " len " + tostring(length);
                    if (slot >= 16 || index >= length) return null;

                    CMwNod@ nod = GetCrystalVariantMobilNod(variant, slot, index);
                    detail += " type " + GetCrystalNodTypeName(nod);
                    return cast<CGameCtnBlockInfoMobil>(nod);
                }

                CGameCtnBlockInfoMobil@ FindCrystalSurfaceMobil(
                    CGameCtnBlockInfoVariant@ variant,
                    CPlugSurface@ surface,
                    string &out detail
                ) {
                    detail = "";
                    if (variant is null || surface is null) return null;

                    uint checkedCount = 0;
                    for (uint slot = 0; slot < 16; slot++) {
                        uint length = GetCrystalVariantMobilSlotLength(variant, slot);
                        for (uint index = 0; index < length; index++) {
                            if (checkedCount >= 512) {
                                detail = "surface mobil scan stopped at 512 entries";
                                return null;
                            }
                            checkedCount++;
                            CGameCtnBlockInfoMobil@ mobil = cast<CGameCtnBlockInfoMobil>(GetCrystalVariantMobilNod(variant, slot, index));
                            if (mobil is null) continue;
                            if (mobil.SurfaceFromBlockItem !is surface) continue;

                            detail = "surface mobil slot " + tostring(slot) + " index " + tostring(index)
                                + " checked " + tostring(checkedCount);
                            return mobil;
                        }
                    }
                    detail = "surface mobil scan checked " + tostring(checkedCount) + " entries";
                    return null;
                }

                bool TryGetCrystalMobilLocalTransform(
                    CGameCtnBlockInfoMobil@ mobil,
                    CrystalTriggerProbeSnapshot@ probe,
                    const vec3 &in variantWorldSize,
                    mat4 &out transform,
                    string &out detail,
                    string &out warning
                ) {
                    transform = mat4::Identity();
                    detail = "";
                    warning = "";
                    if (mobil is null || probe is null || !probe.HasLocalBounds) return false;

                    vec3 geomTranslation = mobil.GeomTranslation;
                    vec3 geomRotation = mobil.GeomRotation;
                    if (!CrystalIsFiniteVec3(geomTranslation) || !CrystalIsFiniteVec3(geomRotation)) {
                        warning = "Mobil geometry transform contains NaN or Inf.";
                        return false;
                    }

                    mat4 localTransform = mat4::Translate(geomTranslation)
                        * CrystalEulerToMat(CrystalDegToRadVec3(geomRotation));
                    vec3 localMin;
                    vec3 localMax;
                    string transformWarning = "";
                    if (!CrystalTransformBounds(localTransform, probe.LocalMin, probe.LocalMax, localMin, localMax, transformWarning)) {
                        warning = transformWarning;
                        return false;
                    }

                    vec3 localSize = localMax - localMin;
                    vec3 localAbsMin = CrystalAbsVec3(localMin);
                    vec3 localAbsMax = CrystalAbsVec3(localMax);
                    float localLimit = Math::Max(
                        Math::Max(variantWorldSize.x, variantWorldSize.y),
                        variantWorldSize.z
                    ) + 256.0f;
                    if (!CrystalIsFiniteVec3(localSize) || localSize.x <= 0.0f || localSize.y <= 0.0f || localSize.z <= 0.0f || localSize.x > CRYSTAL_MAX_VOLUME_AXIS_SIZE || localSize.y > CRYSTAL_MAX_VOLUME_AXIS_SIZE || localSize.z > CRYSTAL_MAX_VOLUME_AXIS_SIZE || localAbsMin.x > localLimit || localAbsMin.y > localLimit || localAbsMin.z > localLimit || localAbsMax.x > localLimit || localAbsMax.y > localLimit || localAbsMax.z > localLimit) {
                        warning = "Mobil geometry transform produced out-of-range local bounds "
                            + CrystalVec3Label(localMin) + ".." + CrystalVec3Label(localMax)
                            + " limit " + Text::Format("%.3f", localLimit);
                        return false;
                    }

                    transform = localTransform;
                    detail = "mobil geom trans " + CrystalVec3Label(geomTranslation)
                        + " rotDeg " + CrystalVec3Label(geomRotation)
                        + " bounds " + CrystalVec3Label(localMin) + ".." + CrystalVec3Label(localMax);
                    return true;
                }

                bool TryGetCrystalSurfaceMobilTransform(
                    CGameCtnBlockInfoVariant@ variant,
                    CrystalTriggerProbeSnapshot@ probe,
                    CPlugSurface@ surface,
                    const mat4 &in baseTransform,
                    mat4 &out transform,
                    string &out detail
                ) {
                    transform = baseTransform;
                    detail = "";
                    if (variant is null || probe is null || surface is null) return false;
                    if (!probe.HasLocalBounds) return false;

                    vec3 variantCoordSize = CrystalNat3ToVec3(variant.Size);
                    if (!CrystalIsSaneBlockCoordSize(variantCoordSize)) return false;

                    vec3 blockWorldSize = TriggerVisualizer::Trigger::Data::OFFZONE_BLOCK_WORLD_SIZE;
                    vec3 variantWorldSize = vec3(
                        variantCoordSize.x * blockWorldSize.x,
                        variantCoordSize.y * blockWorldSize.y,
                        variantCoordSize.z * blockWorldSize.z
                    );
                    string surfaceMobilDetail = "";
                    CGameCtnBlockInfoMobil@ surfaceMobil = FindCrystalSurfaceMobil(
                        variant,
                        surface,
                        surfaceMobilDetail
                    );
                    if (surfaceMobil is null) return false;

                    mat4 mobilLocalTransform;
                    string mobilDetail = "";
                    string mobilWarning = "";
                    if (!TryGetCrystalMobilLocalTransform(surfaceMobil, probe, variantWorldSize, mobilLocalTransform, mobilDetail, mobilWarning)) {
                        if (mobilWarning.Length > 0) detail = "public surface mobil transform rejected: " + mobilWarning;
                        return false;
                    }

                    transform = baseTransform * mobilLocalTransform;
                    detail = "public surface mobil transform " + surfaceMobilDetail + " | " + mobilDetail;
                    return true;
                }

                bool TryGetCrystalWallCheckpointSurfaceTransform(
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    CrystalTriggerProbeSnapshot@ probe,
                    const string &in shapeKind,
                    CPlugSurface@ surface,
                    const mat4 &in baseTransform,
                    mat4 &out transform,
                    string &out detail
                ) {
                    transform = baseTransform;
                    detail = "";
                    if (block is null || block.BlockInfo is null || variant is null || probe is null) return false;
                    if (shapeKind != "WaypointTriggerShape") return false;
                    if (!probe.HasLocalBounds) return false;

                    string blockName = string(block.BlockInfo.Name).ToLower();
                    if (blockName.IndexOf("withwallcheckpoint") >= 0) return false;
                    if (blockName.IndexOf("wallcheckpoint") < 0) return false;

                    vec3 variantCoordSize = CrystalNat3ToVec3(variant.Size);
                    if (!CrystalIsSaneBlockCoordSize(variantCoordSize)) return false;

                    vec3 blockWorldSize = TriggerVisualizer::Trigger::Data::OFFZONE_BLOCK_WORLD_SIZE;
                    vec3 variantWorldSize = vec3(
                        variantCoordSize.x * blockWorldSize.x,
                        variantCoordSize.y * blockWorldSize.y,
                        variantCoordSize.z * blockWorldSize.z
                    );
                    vec3 targetCenter = variantWorldSize * 0.5f;
                    mat4 mobilLocalTransform;
                    string mobilDetail = "";
                    string mobilWarning = "";
                    string selectedMobilDetail = "";
                    CGameCtnBlockInfoMobil@ selectedMobil = GetCrystalSelectedBlockMobil(
                        block,
                        variant,
                        selectedMobilDetail
                    );
                    string surfaceMobilDetail = "";
                    CGameCtnBlockInfoMobil@ surfaceMobil = FindCrystalSurfaceMobil(
                        variant,
                        surface,
                        surfaceMobilDetail
                    );
                    if (surfaceMobil !is null && TryGetCrystalMobilLocalTransform(surfaceMobil, probe, variantWorldSize, mobilLocalTransform, mobilDetail, mobilWarning)) {
                        transform = baseTransform * mobilLocalTransform;
                        detail = "wall checkpoint public surface mobil transform "
                            + surfaceMobilDetail + " | " + mobilDetail;
                        return true;
                    }

                    if (selectedMobil !is null && selectedMobil !is surfaceMobil && TryGetCrystalMobilLocalTransform(selectedMobil, probe, variantWorldSize, mobilLocalTransform, mobilDetail, mobilWarning)) {
                        transform = baseTransform * mobilLocalTransform;
                        detail = "wall checkpoint public selected mobil transform "
                            + selectedMobilDetail + " | " + mobilDetail;
                        return true;
                    }

                    vec3 localMin;
                    vec3 localMax;
                    CrystalNormalizeBounds(probe.LocalMin, probe.LocalMax, localMin, localMax);
                    vec3 triggerCenter = (localMin + localMax) * 0.5f;
                    if (!CrystalIsFiniteVec3(triggerCenter) || !CrystalIsFiniteVec3(targetCenter)) return false;

                    float angle = 0.0f;
                    vec3 axis = vec3(0.0f, 1.0f, 0.0f);
                    string orientation = "";
                    if (blockName.EndsWith("wallcheckpointup")) {
                        angle = Math::PI * 0.5f;
                        axis = vec3(1.0f, 0.0f, 0.0f);
                        orientation = "up";
                    } else if (blockName.EndsWith("wallcheckpointdown")) {
                        angle = -Math::PI * 0.5f;
                        axis = vec3(1.0f, 0.0f, 0.0f);
                        orientation = "down";
                    } else if (blockName.EndsWith("wallcheckpointleft")) {
                        angle = Math::PI * 0.5f;
                        axis = vec3(0.0f, 1.0f, 0.0f);
                        orientation = "left";
                    } else if (blockName.EndsWith("wallcheckpointright")) {
                        angle = -Math::PI * 0.5f;
                        axis = vec3(0.0f, 1.0f, 0.0f);
                        orientation = "right";
                    } else {
                        return false;
                    }
                    mat4 localTransform = mat4::Translate(targetCenter)
                        * mat4::Rotate(angle, axis)
                        * mat4::Translate(triggerCenter * -1.0f);
                    transform = baseTransform * localTransform;
                    detail = "wall checkpoint local trigger recenter/axis rotation " + orientation
                        + " angleDeg " + Text::Format("%.1f", Math::ToDeg(angle))
                        + " axis " + CrystalVec3Label(axis)
                        + (selectedMobilDetail.Length > 0 ? " | " + selectedMobilDetail : "")
                        + (surfaceMobilDetail.Length > 0 ? " | " + surfaceMobilDetail : "")
                        + (mobilWarning.Length > 0 ? " | mobil transform rejected: " + mobilWarning : "")
                        + " triggerCenter " + CrystalVec3Label(triggerCenter)
                        + " targetCenter " + CrystalVec3Label(targetCenter)
                        + " variantSize " + variant.Size.ToString()
                        + " offsetBBox " + CrystalInt3Label(variant.OffsetBoundingBoxMin)
                        + ".." + CrystalInt3Label(variant.OffsetBoundingBoxMax)
                        + " blockUnitModels " + tostring(variant.BlockUnitModels.Length)
                        + CrystalWallCheckpointBlockUnitDetail(variant)
                        + " deprecSolid " + GetCrystalNodTypeName(variant.DeprecWaypointTriggerSolid)
                        + " variantCardinal " + tostring(variant.CardinalDir)
                        + " variantMulti " + tostring(variant.MultiDir)
                        + " spawnTrans " + CrystalVec3Label(variant.SpawnTrans)
                        + " spawnYPRdeg " + Text::Format("%.3f", variant.SpawnYaw)
                        + "/" + Text::Format("%.3f", variant.SpawnPitch)
                        + "/" + Text::Format("%.3f", variant.SpawnRoll);
                    return true;
                }

                string CrystalWallCheckpointBlockUnitDetail(CGameCtnBlockInfoVariant@ variant) {
                    if (variant is null) return "";

                    string detail = "";
                    uint count = MinUint(variant.BlockUnitModels.Length, 4);
                    for (uint i = 0; i < count; i++) {
                        auto unit = variant.BlockUnitModels[i];
                        if (unit is null) {
                            detail += " unit" + tostring(i) + " <null>";
                            continue;
                        }
                        detail += " unit" + tostring(i)
                            + " off " + unit.Offset.ToString()
                            + " rel " + unit.RelativeOffset.ToString();
                    }
                    if (variant.BlockUnitModels.Length > count) detail += " ...";
                    return detail;
                }

                bool CrystalItemEditionIsBlockLike(
                    CGameCommonItemEntityModelEdition@ entityModelEdition,
                    CGameBlockItem@ blockItem
                ) {
                    if (blockItem !is null) return true;
                    if (entityModelEdition is null) return false;

                    try {
                        return tostring(entityModelEdition.ItemType).ToLower().IndexOf("block") >= 0;
                    } catch {
                        logging::HandledException(
                            "CrystalItemEditionIsBlockLike",
                            "EntityModelEdition.ItemType was not readable."
                        );
                    }
                    return false;
                }

                bool CrystalItemIsWaypointLike(CGameItemModel@ itemModel) {
                    if (itemModel is null) return false;
                    if (itemModel.IsStart || itemModel.IsCheckpoint || itemModel.IsFinish || itemModel.IsStartFinish) return true;

                    try {
                        string waypointType = tostring(itemModel.WaypointType).ToLower();
                        if (waypointType.IndexOf("start") >= 0 || waypointType.IndexOf("checkpoint") >= 0 || waypointType.IndexOf("finish") >= 0 || waypointType.IndexOf("dispenser") >= 0) {
                            return true;
                        }
                    } catch {
                        logging::HandledException(
                            "CrystalItemIsWaypointLike",
                            "ItemModel.WaypointType was not readable."
                        );
                    }

                    string itemName = string(itemModel.Name).ToLower();
                    string idName = itemModel.Id.GetName().ToLower();
                    return itemName.IndexOf("start") >= 0
                        || itemName.IndexOf("checkpoint") >= 0
                        || itemName.IndexOf("finish") >= 0
                        || itemName.IndexOf("gate") >= 0
                        || idName.IndexOf("start") >= 0
                        || idName.IndexOf("checkpoint") >= 0
                        || idName.IndexOf("finish") >= 0
                        || idName.IndexOf("gate") >= 0;
                }

                bool CrystalProbeLooksBlockLocal(const CrystalTriggerProbeSnapshot@ probe) {
                    if (probe is null || !probe.HasLocalBounds) return false;

                    vec3 localMin;
                    vec3 localMax;
                    CrystalNormalizeBounds(probe.LocalMin, probe.LocalMax, localMin, localMax);
                    if (!CrystalIsFiniteVec3(localMin) || !CrystalIsFiniteVec3(localMax)) return false;

                    vec3 localSize = localMax - localMin;
                    if (localMin.x < -0.5f || localMin.z < -0.5f) return false;
                    if (localMax.x > 256.5f || localMax.z > 256.5f) return false;
                    return localSize.x > 4.0f || localSize.z > 4.0f;
                }

                const string CRYSTAL_SHAPE_SPACE_ITEM_LOCAL = "item-local";
                const string CRYSTAL_SHAPE_SPACE_BLOCK_LOCAL = "block-local";
                const string CRYSTAL_SHAPE_SPACE_PREFAB_CHILD = "prefab-child";
                const string CRYSTAL_SHAPE_SPACE_MOBIL_CHILD = "mobil-child";
                const string CRYSTAL_SHAPE_SPACE_CENTERED_BLOCK_LOCAL = "centered-block-local";

                class CrystalShapeTransformResult {
                    bool CanRender = true;
                    mat4 Transform;
                    string ShapeSpace;
                    string Detail;
                    string Warning;
                }

                void CrystalResetShapeTransformResult(
                    CrystalShapeTransformResult@ result,
                    const mat4 &in parentTransform,
                    const string &in parentDetail,
                    const string &in parentShapeSpace
                ) {
                    if (result is null) return;
                    result.CanRender = true;
                    result.Transform = parentTransform;
                    result.ShapeSpace = parentShapeSpace;
                    result.Detail = parentDetail;
                    result.Warning = "";
                }

                void CrystalAppendProbeDetail(CrystalTriggerProbeSnapshot@ probe, const string &in detail) {
                    if (probe is null || detail.Length == 0) return;
                    probe.Detail = probe.Detail.Length > 0 ? probe.Detail + " | " + detail : detail;
                }

                string CrystalShapeTransformResultDiagnostic(CrystalShapeTransformResult@ result) {
                    if (result is null) return "";

                    string detail = "";
                    if (result.ShapeSpace.Length > 0) {
                        detail = "triggerShapeSpace " + result.ShapeSpace;
                    }
                    if (result.Detail.Length > 0) {
                        string transformDetail = "triggerTransform " + result.Detail;
                        detail = detail.Length > 0 ? detail + " | " + transformDetail : transformDetail;
                    }
                    return detail;
                }

                void CrystalApplyShapeTransformResultToProbe(
                    CrystalTriggerProbeSnapshot@ probe,
                    CrystalShapeTransformResult@ result
                ) {
                    if (probe is null || result is null) return;

                    CrystalAppendProbeDetail(probe, CrystalShapeTransformResultDiagnostic(result));
                    if (result.Warning.Length > 0) {
                        probe.Warning = CrystalAppendWarning(probe.Warning, result.Warning);
                    }
                }

                void ResolveCrystalComposedShapeTransform(
                    const mat4 &in parentTransform,
                    const mat4 &in childTransform,
                    const string &in parentDetail,
                    const string &in childDetail,
                    const string &in shapeSpace,
                    CrystalShapeTransformResult@ result
                ) {
                    string detail = parentDetail;
                    if (detail.Length > 0 && childDetail.Length > 0) detail += " | ";
                    detail += childDetail;
                    CrystalResetShapeTransformResult(
                        result,
                        parentTransform * childTransform,
                        detail,
                        shapeSpace
                    );
                }

                bool TryResolveCrystalBlockLocalBaseTransform(
                    CGameCtnBlockInfoVariant@ variant,
                    const mat4 &in blockTransform,
                    CrystalShapeTransformResult@ result,
                    string &out warning
                ) {
                    warning = "";
                    if (result is null) {
                        warning = "No transform result object for block-local base transform.";
                        return false;
                    }

                    mat4 variantTransform;
                    string variantDetail = "";
                    string variantWarning = "";
                    if (!TryGetCrystalVariantSurfaceTransform(variant, blockTransform, variantTransform, variantDetail, variantWarning)) {
                        warning = variantWarning;
                        return false;
                    }

                    CrystalResetShapeTransformResult(
                        result,
                        variantTransform,
                        variantDetail,
                        CRYSTAL_SHAPE_SPACE_BLOCK_LOCAL
                    );
                    return true;
                }

                bool TryResolveCrystalBlockSurfaceShapeTransform(
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    CrystalTriggerProbeSnapshot@ probe,
                    const string &in shapeKind,
                    CPlugSurface@ surface,
                    const mat4 &in blockTransform,
                    CrystalShapeTransformResult@ result,
                    string &out warning
                ) {
                    warning = "";
                    if (result is null) {
                        warning = "No transform result object for block surface transform.";
                        return false;
                    }

                    auto baseResult = CrystalShapeTransformResult();
                    if (!TryResolveCrystalBlockLocalBaseTransform(variant, blockTransform, baseResult, warning)) {
                        return false;
                    }
                    result.Transform = baseResult.Transform;
                    result.ShapeSpace = baseResult.ShapeSpace;
                    result.Detail = baseResult.Detail;
                    result.Warning = baseResult.Warning;
                    mat4 orientedSurfaceTransform;
                    string orientedSurfaceDetail = "";
                    if (TryGetCrystalWallCheckpointSurfaceTransform(block, variant, probe, shapeKind, surface, baseResult.Transform, orientedSurfaceTransform, orientedSurfaceDetail)) {
                        result.Transform = orientedSurfaceTransform;
                        result.Detail = result.Detail.Length > 0 && orientedSurfaceDetail.Length > 0 ?
                            result.Detail + " | " + orientedSurfaceDetail : result.Detail + orientedSurfaceDetail;
                    } else if (TryGetCrystalSurfaceMobilTransform(variant, probe, surface, baseResult.Transform, orientedSurfaceTransform, orientedSurfaceDetail)) {
                        result.Transform = orientedSurfaceTransform;
                        result.ShapeSpace = CRYSTAL_SHAPE_SPACE_MOBIL_CHILD;
                        result.Detail = result.Detail.Length > 0 && orientedSurfaceDetail.Length > 0 ?
                            result.Detail + " | " + orientedSurfaceDetail : result.Detail + orientedSurfaceDetail;
                    }
                    return true;
                }

                bool TryResolveCrystalBlockMobilSurfaceShapeTransform(
                    CGameCtnBlockInfoMobil@ mobil,
                    CrystalTriggerProbeSnapshot@ probe,
                    const vec3 &in variantWorldSize,
                    const mat4 &in variantSurfaceTransform,
                    const string &in variantSurfaceDetail,
                    const mat4 &in extraLocalTransform,
                    const string &in extraLocalTransformDetail,
                    CrystalShapeTransformResult@ result,
                    string &out warning
                ) {
                    warning = "";
                    if (result is null) {
                        warning = "No transform result object for block mobil surface transform.";
                        return false;
                    }

                    mat4 mobilLocalTransform;
                    string mobilDetail = "";
                    string mobilWarning = "";
                    if (!TryGetCrystalMobilLocalTransform(mobil, probe, variantWorldSize, mobilLocalTransform, mobilDetail, mobilWarning)) {
                        warning = mobilWarning;
                        return false;
                    }

                    mat4 localTransform = mobilLocalTransform * extraLocalTransform;
                    string localDetail = mobilDetail;
                    if (localDetail.Length > 0 && extraLocalTransformDetail.Length > 0) localDetail += " | ";
                    localDetail += extraLocalTransformDetail;
                    ResolveCrystalComposedShapeTransform(
                        variantSurfaceTransform,
                        localTransform,
                        variantSurfaceDetail,
                        localDetail,
                        CRYSTAL_SHAPE_SPACE_MOBIL_CHILD,
                        result
                    );
                    return true;
                }

                bool TryResolveCrystalCenteredBlockLocalShapeTransform(
                    CrystalTriggerProbeSnapshot@ probe,
                    const mat4 &in parentTransform,
                    const string &in parentDetail,
                    mat4 &out transform,
                    string &out detail,
                    string &out warning
                ) {
                    transform = parentTransform;
                    detail = parentDetail;
                    warning = "";
                    if (!CrystalProbeLooksBlockLocal(probe)) return false;

                    vec3 localMin;
                    vec3 localMax;
                    CrystalNormalizeBounds(probe.LocalMin, probe.LocalMax, localMin, localMax);
                    vec3 localCenter = (localMin + localMax) * 0.5f;
                    vec3 localOffset = vec3(-localCenter.x, 0.0f, -localCenter.z);
                    if (!CrystalIsFiniteVec3(localOffset)) {
                        warning = "Centered block-local offset contains NaN or Inf.";
                        return false;
                    }

                    transform = parentTransform * mat4::Translate(localOffset);
                    detail = parentDetail + " * horizontal local-center offset "
                        + CrystalVec3Label(localOffset)
                        + " localCenter " + CrystalVec3Label(localCenter);
                    return true;
                }

                void ResolveCrystalCommonEntityShapeTransform(
                    CGameCommonItemEntityModel@ entityModel,
                    CrystalTriggerProbeSnapshot@ probe,
                    const mat4 &in parentTransform,
                    const string &in parentDetail,
                    const string &in parentShapeSpace,
                    bool preferBlockLocal,
                    CrystalShapeTransformResult@ result
                ) {
                    CrystalResetShapeTransformResult(
                        result,
                        parentTransform,
                        parentDetail,
                        parentShapeSpace
                    );
                    if (result is null) return;

                    if (preferBlockLocal && parentShapeSpace == CRYSTAL_SHAPE_SPACE_BLOCK_LOCAL) {
                        mat4 centeredTransform;
                        string centeredDetail = "";
                        string centeredWarning = "";
                        if (TryResolveCrystalCenteredBlockLocalShapeTransform(probe, parentTransform, parentDetail, centeredTransform, centeredDetail, centeredWarning)) {
                            result.Transform = centeredTransform;
                            result.ShapeSpace = CRYSTAL_SHAPE_SPACE_CENTERED_BLOCK_LOCAL;
                            result.Detail = centeredDetail;
                            return;
                        }
                        if (centeredWarning.Length > 0) {
                            result.Warning = CrystalAppendWarning(result.Warning, centeredWarning);
                        }
                    }
                    if (entityModel !is null) {
                        vec3 spawnOrigin = vec3(
                            entityModel.SpawnLoc.tx,
                            entityModel.SpawnLoc.ty,
                            entityModel.SpawnLoc.tz
                        );
                        if (CrystalIsFiniteVec3(spawnOrigin)) {
                            result.Detail = result.Detail.Length > 0 ?
                                result.Detail + " | public SpawnLoc reference origin " + CrystalVec3Label(spawnOrigin) : "public SpawnLoc reference origin " + CrystalVec3Label(spawnOrigin);
                        }
                    }
                }

                bool CrystalPrefabTriggerModelIgnoresVerticalFlip(CMwNod@ model) {
                    return cast<NPlugTrigger_SWaypoint>(model) !is null
                        || cast<NPlugTrigger_SSpecial>(model) !is null
                        || cast<CGameGateModel>(model) !is null
                        || cast<CGameTeleporterModel>(model) !is null;
                }

                bool TryResolveCrystalPrefabChildTransform(
                    CMwNod@ entModel,
                    const vec3 &in entTrans,
                    const quat &in entRotation,
                    const mat4 &in parentTransform,
                    CrystalShapeTransformResult@ result,
                    string &out warning
                ) {
                    warning = "";
                    if (result is null) {
                        warning = "No transform result object for prefab child transform.";
                        return false;
                    }

                    mat4 entLocalTransform;
                    string entTransformDetail = "";
                    string entTransformWarning = "";
                    if (!TryGetCrystalTransQuatTransform(entTrans, entRotation, entLocalTransform, entTransformDetail, entTransformWarning)) {
                        warning = entTransformWarning;
                        return false;
                    }

                    mat4 childTransform = parentTransform * entLocalTransform;
                    string childDetail = entTransformDetail;
                    if (CrystalPrefabTriggerModelIgnoresVerticalFlip(entModel) && CrystalQuatLooksVerticalFlip(entRotation)) {
                        childTransform = parentTransform * mat4::Translate(entTrans);
                        childDetail += " | trigger model transform ignored prefab vertical-flip rotation";
                    }
                    CrystalResetShapeTransformResult(
                        result,
                        childTransform,
                        childDetail,
                        CRYSTAL_SHAPE_SPACE_PREFAB_CHILD
                    );
                    return true;
                }

                bool TryGetCrystalSpecialTriggerTransform(
                    CrystalTriggerProbeSnapshot@ probe,
                    const mat4 &in baseTransform,
                    mat4 &out transform
                ) {
                    transform = baseTransform;
                    string transformDetail = "";
                    string transformWarning = "";
                    if (!TryResolveCrystalCenteredBlockLocalShapeTransform(probe, baseTransform, "base", transform, transformDetail, transformWarning)) {
                        if (transformWarning.Length > 0) {
                            probe.Warning = CrystalAppendWarning(probe.Warning, transformWarning);
                        }
                        return false;
                    }

                    CrystalAppendProbeDetail(probe, "triggerShapeSpace " + CRYSTAL_SHAPE_SPACE_CENTERED_BLOCK_LOCAL);
                    CrystalAppendProbeDetail(probe, "special triggerTransform " + transformDetail);
                    return true;
                }

                const uint16 O_CRYSTAL_ANCHOREDOBJECT_PIVOT_MAT = GetMemberOffset(
                    "CGameCtnAnchoredObject",
                    "AbsolutePositionInMap"
                ) + 0xC;
                const uint16 O_CRYSTAL_ANCHOREDOBJECT_PIVOT_POS = O_CRYSTAL_ANCHOREDOBJECT_PIVOT_MAT + 0x24;

                bool CrystalItemAnchorVectorIsSane(const vec3 &in value, string &out reason) {
                    reason = "";
                    if (!CrystalIsFiniteVec3(value)) {
                        reason = "non-finite";
                        return false;
                    }

                    vec3 absValue = CrystalAbsVec3(value);
                    if (absValue.x > CRYSTAL_MAX_VOLUME_AXIS_SIZE || absValue.y > CRYSTAL_MAX_VOLUME_AXIS_SIZE || absValue.z > CRYSTAL_MAX_VOLUME_AXIS_SIZE) {
                        reason = "outside sanity limit " + CrystalVec3Label(value);
                        return false;
                    }
                    return true;
                }

                bool CrystalItemAnchorVectorHasOffset(const vec3 &in value) {
                    return value.LengthSquared() > 0.000001f;
                }

                bool TryReadCrystalPlacedItemPivot(
                    CGameCtnAnchoredObject@ anchoredObject,
                    vec3 &out pivot,
                    string &out warning
                ) {
                    warning = "";
                    pivot = vec3();
                    if (anchoredObject is null) {
                        warning = "private placed item pivot unavailable: no object";
                        return false;
                    }

                    try {
                        pivot = Dev::GetOffsetVec3(anchoredObject, O_CRYSTAL_ANCHOREDOBJECT_PIVOT_POS);
                    } catch {
                        logging::HandledException(
                            "TryReadCrystalPlacedItemPivot",
                            "Placed item private pivot read failed."
                        );
                        warning = "private placed item pivot unavailable: read failed";
                        return false;
                    }

                    string reason = "";
                    if (!CrystalItemAnchorVectorIsSane(pivot, reason)) {
                        warning = "private placed item pivot rejected: " + reason;
                        return false;
                    }
                    return true;
                }

                bool TryGetCrystalItemGroundPointAnchor(
                    CGameItemModel@ itemModel,
                    vec3 &out anchor,
                    string &out warning
                ) {
                    warning = "";
                    anchor = vec3();
                    if (itemModel is null) {
                        warning = "item GroundPoint unavailable: no item model";
                        return false;
                    }

                    anchor = itemModel.GroundPoint;
                    string reason = "";
                    if (!CrystalItemAnchorVectorIsSane(anchor, reason)) {
                        warning = "item GroundPoint rejected: " + reason;
                        return false;
                    }
                    if (!CrystalItemAnchorVectorHasOffset(anchor)) {
                        warning = "item GroundPoint zero";
                        return false;
                    }
                    return true;
                }

                bool TryGetCrystalDefaultItemPivotAnchor(
                    CGameItemModel@ itemModel,
                    vec3 &out anchor,
                    string &out warning
                ) {
                    warning = "";
                    anchor = vec3();
                    if (itemModel is null) {
                        warning = "default item pivot unavailable: no item model";
                        return false;
                    }

                    auto placementParam = itemModel.DefaultPlacementParam_Content;
                    if (placementParam is null) {
                        warning = "default item pivot unavailable: no placement params";
                        return false;
                    }
                    if (placementParam.PivotPositions.Length == 0) {
                        warning = "default item pivot unavailable: no pivot positions";
                        return false;
                    }

                    anchor = placementParam.PivotPositions[0];
                    string reason = "";
                    if (!CrystalItemAnchorVectorIsSane(anchor, reason)) {
                        warning = "default item pivot rejected: " + reason;
                        return false;
                    }
                    if (!CrystalItemAnchorVectorHasOffset(anchor)) {
                        warning = "default item pivot zero";
                        return false;
                    }
                    return true;
                }

                mat4 GetCrystalAnchoredObjectTransform(CGameCtnAnchoredObject@ anchoredObject, string &out source) {
                    source = "AbsolutePositionInMap * YawPitchRoll";
                    if (anchoredObject is null) return mat4::Identity();

                    mat4 transform = mat4::Translate(anchoredObject.AbsolutePositionInMap)
                        * CrystalEulerToMat(vec3(anchoredObject.Pitch, anchoredObject.Yaw, anchoredObject.Roll));
                    bool usesAbsolutePlacement = true;
                    if (anchoredObject.IsLocationInitialised) {
                        mat4 locationTransform = mat4(anchoredObject.BlockLocation) * mat4(anchoredObject.LocationInBlock);
                        vec3 locationOrigin = (locationTransform * vec3()).xyz;
                        vec3 absLocationOrigin = CrystalAbsVec3(locationOrigin);
                        bool hasFiniteAbsolutePosition = CrystalIsFiniteVec3(anchoredObject.AbsolutePositionInMap);
                        bool locationOriginLooksPlaceholder = hasFiniteAbsolutePosition
                            && locationOrigin.LengthSquared() <= 0.000001f
                            && anchoredObject.AbsolutePositionInMap.LengthSquared() > 1.0f;
                        if (CrystalIsFiniteVec3(locationOrigin) && absLocationOrigin.x <= CRYSTAL_MAX_ABS_WORLD_COORD && absLocationOrigin.y <= CRYSTAL_MAX_ABS_WORLD_COORD && absLocationOrigin.z <= CRYSTAL_MAX_ABS_WORLD_COORD && !locationOriginLooksPlaceholder) {
                            vec3 absoluteDelta = locationOrigin - anchoredObject.AbsolutePositionInMap;
                            source = "BlockLocation * LocationInBlock origin " + CrystalVec3Label(locationOrigin)
                                + " absoluteDelta " + CrystalVec3Label(absoluteDelta);
                            transform = locationTransform;
                            usesAbsolutePlacement = false;
                        } else {
                            source = "AbsolutePositionInMap * YawPitchRoll (public location transform rejected";
                            if (CrystalIsFiniteVec3(locationOrigin)) {
                                source += ": origin " + CrystalVec3Label(locationOrigin);
                                if (locationOriginLooksPlaceholder) source += " looks like an unpopulated zero placeholder";
                            } else {
                                source += ": non-finite origin";
                            }
                            source += ")";
                        }
                    }

                    float scale = anchoredObject.Scale;
                    if (CrystalIsFiniteFloat(scale) && Math::Abs(scale) > 0.0001f && Math::Abs(scale - 1.0f) > 0.0001f) {
                        transform = transform * mat4::Scale(vec3(scale, scale, scale));
                        source += " * Scale";
                    }
                    auto itemModel = anchoredObject.ItemModel;
                    if (usesAbsolutePlacement && itemModel !is null) {
                        bool appliedItemAnchor = false;
                        bool allowDefaultItemPivotAnchor = true;
                        vec3 placedItemPivot = vec3();
                        string itemAnchorWarning = "";
                        if (TryReadCrystalPlacedItemPivot(anchoredObject, placedItemPivot, itemAnchorWarning)) {
                            if (CrystalItemAnchorVectorHasOffset(placedItemPivot)) {
                                transform = transform * mat4::Translate(placedItemPivot);
                                source += " * private placed item pivot offset " + CrystalVec3Label(placedItemPivot);
                                appliedItemAnchor = true;
                            } else {
                                source += " (private placed item pivot zero)";
                                allowDefaultItemPivotAnchor = false;
                            }
                        } else if (itemAnchorWarning.Length > 0) {
                            source += " (" + itemAnchorWarning + ")";
                        }
                        if (!appliedItemAnchor) {
                            vec3 groundPoint = vec3();
                            string groundPointWarning = "";
                            if (TryGetCrystalItemGroundPointAnchor(itemModel, groundPoint, groundPointWarning)) {
                                transform = transform * mat4::Translate(vec3(-groundPoint.x, -groundPoint.y, -groundPoint.z));
                                source += " * item GroundPoint anchor " + CrystalVec3Label(groundPoint);
                                appliedItemAnchor = true;
                            } else if (groundPointWarning.Length > 0) {
                                source += " (" + groundPointWarning + ")";
                            }
                        }
                        if (!appliedItemAnchor && allowDefaultItemPivotAnchor) {
                            vec3 defaultPivot = vec3();
                            string defaultPivotWarning = "";
                            if (TryGetCrystalDefaultItemPivotAnchor(itemModel, defaultPivot, defaultPivotWarning)) {
                                transform = transform * mat4::Translate(vec3(-defaultPivot.x, -defaultPivot.y, -defaultPivot.z));
                                source += " * default item pivot anchor " + CrystalVec3Label(defaultPivot);
                            } else if (defaultPivotWarning.Length > 0) {
                                source += " (" + defaultPivotWarning + ")";
                            }
                        }
                    }
                    return transform;
                }

                bool TryAddCrystalVolumeFromProbe(
                    TriggerSourceSnapshot@ source,
                    CrystalTriggerProbeSnapshot@ probe,
                    const mat4 &in worldTransform,
                    const string &in targetKeys
                ) {
                    if (source is null || probe is null) return false;
                    if (!probe.HasLocalBounds) {
                        source.RejectedShapeCount++;
                        probe.Warning = CrystalAppendWarning(probe.Warning, "No local bounds available for rendering.");
                        return false;
                    }

                    vec3 worldMin;
                    vec3 worldMax;
                    string transformWarning = "";
                    if (!CrystalTransformBounds(worldTransform, probe.LocalMin, probe.LocalMax, worldMin, worldMax, transformWarning)) {
                        source.RejectedShapeCount++;
                        probe.Warning = CrystalAppendWarning(probe.Warning, transformWarning);
                        return false;
                    }

                    string validationWarning = "";
                    if (!CrystalValidateBounds(worldMin, worldMax, true, validationWarning)) {
                        source.RejectedShapeCount++;
                        probe.Warning = CrystalAppendWarning(probe.Warning, validationWarning);
                        return false;
                    }

                    CrystalNormalizeBounds(worldMin, worldMax, probe.WorldMin, probe.WorldMax);
                    uint sourceIndex = source.TriggerVolumes.Length;
                    auto volume = TriggerVolume(
                        probe.WorldMin,
                        probe.WorldMax,
                        TRIGGER_SOURCE_CRYSTAL,
                        sourceIndex,
                        probe.DisplayName()
                    );
                    volume.DetectedLabel = probe.ShapeKind;
                    volume.SubtypeKey = GetCrystalSubtypeKey(probe);
                    volume.SubtypeLabel = GetCrystalSubtypeLabel(probe);
                    volume.TargetKeys = targetKeys.Length > 0 ? targetKeys : GetTriggerSourceTargetKeys(TRIGGER_SOURCE_CRYSTAL);
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
                    if (probe.HasLocalOutlineGeometry()) {
                        string outlineWarning = "";
                        auto localOutlineLines = CrystalOutlineLineBuffer();
                        localOutlineLines.Starts = probe.LocalOutlineLineStarts;
                        localOutlineLines.Ends = probe.LocalOutlineLineEnds;
                        if (CrystalTransformOutlineLinesToWorld(localOutlineLines, worldTransform, volume.OutlineLineStarts, volume.OutlineLineEnds, outlineWarning)) {
                            volume.OutlineShapeKind = probe.GmSurfKind;
                        }
                        if (outlineWarning.Length > 0) {
                            probe.Warning = CrystalAppendWarning(probe.Warning, outlineWarning);
                        }
                    }
                    source.TriggerVolumes.InsertLast(volume);
                    source.RenderedShapeCount++;
                    return true;
                }

                bool IsCrystalFreeBlock(CGameCtnBlock@ block) {
                    return block !is null && int(block.CoordX) < 0;
                }

                const uint16 O_CRYSTAL_CTN_BLOCK_DIR = GetMemberOffset("CGameCtnBlock", "Dir");
                const uint16 O_CRYSTAL_FREE_BLOCK_POS = O_CRYSTAL_CTN_BLOCK_DIR + 0x8;
                const uint16 O_CRYSTAL_FREE_BLOCK_ROT_YPR = O_CRYSTAL_FREE_BLOCK_POS + 0xC;

                bool CrystalIsSaneBlockCoordSize(const vec3 &in coordSize) {
                    return CrystalIsFiniteVec3(coordSize)
                        && coordSize.x > 0.0f && coordSize.y > 0.0f && coordSize.z > 0.0f
                        && coordSize.x <= float(CRYSTAL_MAX_BLOCK_COORD_SIZE)
                        && coordSize.y <= float(CRYSTAL_MAX_BLOCK_COORD_SIZE)
                        && coordSize.z <= float(CRYSTAL_MAX_BLOCK_COORD_SIZE);
                }

                bool TryGetCrystalFreeBlockTransform(
                    CGameCtnBlock@ block,
                    mat4 &out transform,
                    string &out detail,
                    string &out warning
                ) {
                    transform = mat4::Identity();
                    detail = "";
                    warning = "";

                    if (block is null) {
                        warning = "No free block for transform.";
                        return false;
                    }

                    vec3 pos = vec3();
                    vec3 ypr = vec3();
                    try {
                        pos = Dev::GetOffsetVec3(block, O_CRYSTAL_FREE_BLOCK_POS);
                        ypr = Dev::GetOffsetVec3(block, O_CRYSTAL_FREE_BLOCK_ROT_YPR);
                    } catch {
                        logging::HandledException(
                            "TryGetCrystalFreeBlockTransform",
                            "Free block private transform read failed."
                        );
                        warning = "Free block private position/rotation read failed.";
                        return false;
                    }

                    if (!CrystalIsFiniteVec3(pos)) {
                        warning = "Free block private position is not finite.";
                        return false;
                    }
                    vec3 absPos = CrystalAbsVec3(pos);
                    if (absPos.x > CRYSTAL_MAX_ABS_WORLD_COORD || absPos.y > CRYSTAL_MAX_ABS_WORLD_COORD || absPos.z > CRYSTAL_MAX_ABS_WORLD_COORD) {
                        warning = "Free block private position is outside sanity limit: " + CrystalVec3Label(pos);
                        return false;
                    }
                    if (!CrystalIsFiniteVec3(ypr)) {
                        warning = "Free block private rotation is not finite.";
                        return false;
                    }

                    vec3 pyr = vec3(ypr.y, ypr.x, ypr.z);
                    transform = mat4::Translate(pos) * CrystalEulerToMat(pyr);
                    detail = "transform private free-block pos/rot"
                        + " pos " + CrystalVec3Label(pos)
                        + " ypr " + CrystalVec3Label(ypr)
                        + " pyr " + CrystalVec3Label(pyr);
                    return true;
                }

                bool TryGetCrystalPlacedBlockTransform(
                    CGameCtnChallenge@ map,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    mat4 &out transform,
                    string &out detail,
                    string &out warning
                ) {
                    transform = mat4::Identity();
                    detail = "";
                    warning = "";

                    if (map is null) {
                        warning = "No RootMap for block transform.";
                        return false;
                    }
                    if (block is null) {
                        warning = "No block for transform.";
                        return false;
                    }
                    if (variant is null) {
                        warning = "No selected block variant for transform.";
                        return false;
                    }
                    if (IsCrystalFreeBlock(block)) {
                        return TryGetCrystalFreeBlockTransform(block, transform, detail, warning);
                    }

                    int dir = int(block.Dir);
                    if (dir < 0 || dir > 3) {
                        warning = "Block direction is outside the cardinal range: " + tostring(dir);
                        return false;
                    }

                    vec3 coordSize = CrystalNat3ToVec3(variant.Size);
                    if (!CrystalIsSaneBlockCoordSize(coordSize)) {
                        warning = "Block variant size is invalid: " + variant.Size.ToString();
                        return false;
                    }

                    vec3 coord = CrystalNat3ToVec3(block.Coord);
                    if (dir == 1) {
                        coord.x += coordSize.z - 1.0f;
                    } else if (dir == 2) {
                        coord.x += coordSize.x - 1.0f;
                        coord.z += coordSize.z - 1.0f;
                    } else if (dir == 3) {
                        coord.z += coordSize.x - 1.0f;
                    }

                    string anchorSource = "";
                    string collectionName = "";
                    int collectionId = -1;
                    uint decoBaseHeightOffset = 0;
                    float triggerGridWorldYAnchor = 0.0f;
                    float worldYAnchor = TriggerVisualizer::Trigger::Data::GetMapPlacedBlockWorldYAnchor(
                        map,
                        block,
                        anchorSource,
                        collectionName,
                        collectionId,
                        decoBaseHeightOffset,
                        triggerGridWorldYAnchor
                    );
                    if (!CrystalIsFiniteFloat(worldYAnchor)) {
                        warning = "Map placed-block world-y anchor is not finite.";
                        return false;
                    }
                    if (!CrystalIsFiniteFloat(triggerGridWorldYAnchor)) {
                        warning = "Map trigger-grid world-y anchor is not finite.";
                        return false;
                    }

                    vec3 blockWorldSize = TriggerVisualizer::Trigger::Data::OFFZONE_BLOCK_WORLD_SIZE;
                    vec3 pos = vec3(
                        coord.x * blockWorldSize.x,
                        (coord.y - worldYAnchor) * blockWorldSize.y,
                        coord.z * blockWorldSize.z
                    );
                    if (!CrystalIsFiniteVec3(pos)) {
                        warning = "Computed block position is not finite.";
                        return false;
                    }

                    mat4 rotation = CrystalEulerToMat(vec3(0.0f, CrystalCardinalDirectionToYaw(dir), 0.0f));
                    transform = mat4::Translate(pos)
                        * mat4::Translate(blockWorldSize * 0.5f)
                        * rotation
                        * mat4::Translate(blockWorldSize * -0.5f);
                    detail = "transform public Coord/Dir"
                        + " dir " + tostring(dir)
                        + " variantSize " + variant.Size.ToString()
                        + " adjustedCoord " + CrystalVec3Label(coord)
                        + " pos " + CrystalVec3Label(pos)
                        + " blockYAnchor " + Text::Format("%.3f", worldYAnchor)
                        + " triggerGridYAnchor " + Text::Format("%.3f", triggerGridWorldYAnchor)
                        + " yAnchorSource " + anchorSource;
                    float blockYDeltaVsGrid = (triggerGridWorldYAnchor - worldYAnchor) * blockWorldSize.y;
                    if (Math::Abs(blockYDeltaVsGrid) > 0.001f) {
                        detail += " blockYDeltaVsGrid " + Text::Format("%.3f", blockYDeltaVsGrid);
                    }
                    if (collectionName.Length > 0) detail += " collection " + collectionName;
                    return true;
                }
            }
        }
    }
}
