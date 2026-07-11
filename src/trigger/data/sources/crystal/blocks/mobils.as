namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                bool CrystalBlockMobilSurfaceIsVariantSurface(
                    CGameCtnBlockInfoVariant@ variant,
                    CPlugSurface@ surface
                ) {
                    if (variant is null || surface is null) return false;
                    if (surface is variant.WaypointTriggerShape) return true;
                    if (surface is variant.ScreenInteractionTriggerShape) return true;
                    if (variant.Gate !is null && surface is variant.Gate.Shape) return true;
                    if (variant.Teleporter !is null && surface is variant.Teleporter.TriggerShape) return true;
                    return false;
                }

                bool ProbeCrystalBlockMobilResolvedSurface(
                    TriggerSourceSnapshot@ source,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    CGameCtnBlockInfoMobil@ mobil,
                    uint blockIndex,
                    const string &in ownerKind,
                    const string &in ownerName,
                    const string &in detail,
                    const string &in shapeKind,
                    CPlugSurface@ surface,
                    const string &in surfaceDetail,
                    const mat4 &in extraLocalTransform,
                    const string &in extraLocalTransformDetail,
                    uint slot,
                    uint index,
                    bool canRender,
                    bool canRenderVariantSurface,
                    const mat4 &in variantSurfaceTransform,
                    const string &in variantSurfaceDetail,
                    const string &in variantSurfaceWarning,
                    const string &in transformWarning,
                    const vec3 &in variantWorldSize
                ) {
                    if (source is null || block is null || variant is null || mobil is null || surface is null) return false;
                    if (CrystalBlockMobilSurfaceIsVariantSurface(variant, surface)) return false;

                    string probeDetail = detail
                        + " mobil slot " + tostring(slot)
                        + " index " + tostring(index)
                        + " type " + GetCrystalNodTypeName(mobil);
                    if (surfaceDetail.Length > 0) probeDetail += " | " + surfaceDetail;
                    auto probe = AddCrystalSurfaceProbe(
                        source,
                        ownerKind,
                        blockIndex,
                        ownerName,
                        shapeKind,
                        surface,
                        probeDetail
                    );
                    if (probe is null) return false;

                    if (!canRender) {
                        if (probe.HasLocalBounds) {
                            source.RejectedShapeCount++;
                            probe.Warning = CrystalAppendWarning(
                                probe.Warning,
                                transformWarning
                            );
                        }
                        return false;
                    }

                    if (!canRenderVariantSurface) {
                        if (probe.HasLocalBounds) {
                            source.RejectedShapeCount++;
                            probe.Warning = CrystalAppendWarning(
                                probe.Warning,
                                variantSurfaceWarning
                            );
                        }
                        return false;
                    }

                    auto transformResult = CrystalShapeTransformResult();
                    string mobilWarning = "";
                    if (!TryResolveCrystalBlockMobilSurfaceShapeTransform(mobil, probe, variantWorldSize, variantSurfaceTransform, variantSurfaceDetail, extraLocalTransform, extraLocalTransformDetail, transformResult, mobilWarning)) {
                        source.RejectedShapeCount++;
                        probe.Warning = CrystalAppendWarning(
                            probe.Warning,
                            mobilWarning
                        );
                        return false;
                    }
                    CrystalApplyShapeTransformResultToProbe(probe, transformResult);
                    return TryAddCrystalVolumeFromProbe(
                        source,
                        probe,
                        transformResult.Transform,
                        AddCrystalSurfaceGameplayTargetKeys(GetCrystalBlockTargetKeys(block, shapeKind), surface)
                    );
                }

                bool ProbeCrystalBlockMobilSpecialTriggerResolvedSurface(
                    TriggerSourceSnapshot@ source,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    CGameCtnBlockInfoMobil@ mobil,
                    CPlugSurface@ specialSurface,
                    uint blockIndex,
                    const string &in ownerKind,
                    const string &in ownerName,
                    const string &in detail,
                    const string &in shapeKind,
                    const string &in surfaceDetail,
                    const mat4 &in extraLocalTransform,
                    const string &in extraLocalTransformDetail,
                    uint slot,
                    uint index,
                    bool canRender,
                    bool canRenderVariantSurface,
                    const mat4 &in variantSurfaceTransform,
                    const string &in variantSurfaceDetail,
                    const string &in variantSurfaceWarning,
                    const string &in transformWarning,
                    const vec3 &in variantWorldSize
                ) {
                    if (source is null || block is null || variant is null || mobil is null || specialSurface is null) return false;
                    if (CrystalBlockMobilSurfaceIsVariantSurface(variant, specialSurface)) return false;

                    string probeDetail = detail
                        + " mobil slot " + tostring(slot)
                        + " index " + tostring(index)
                        + " type " + GetCrystalNodTypeName(mobil);
                    if (surfaceDetail.Length > 0) probeDetail += " | " + surfaceDetail;
                    auto probe = AddCrystalSurfaceProbe(
                        source,
                        ownerKind,
                        blockIndex,
                        ownerName,
                        shapeKind,
                        specialSurface,
                        probeDetail
                    );
                    if (probe is null) return false;

                    if (!canRender) {
                        if (probe.HasLocalBounds) {
                            source.RejectedShapeCount++;
                            probe.Warning = CrystalAppendWarning(
                                probe.Warning,
                                transformWarning
                            );
                        }
                        return false;
                    }

                    if (!canRenderVariantSurface) {
                        if (probe.HasLocalBounds) {
                            source.RejectedShapeCount++;
                            probe.Warning = CrystalAppendWarning(
                                probe.Warning,
                                variantSurfaceWarning
                            );
                        }
                        return false;
                    }

                    auto transformResult = CrystalShapeTransformResult();
                    string mobilWarning = "";
                    if (!TryResolveCrystalBlockMobilSurfaceShapeTransform(mobil, probe, variantWorldSize, variantSurfaceTransform, variantSurfaceDetail, extraLocalTransform, extraLocalTransformDetail, transformResult, mobilWarning)) {
                        source.RejectedShapeCount++;
                        probe.Warning = CrystalAppendWarning(
                            probe.Warning,
                            mobilWarning
                        );
                        return false;
                    }
                    CrystalApplyShapeTransformResultToProbe(probe, transformResult);
                    mat4 specialTransform = transformResult.Transform;
                    TryGetCrystalSpecialTriggerTransform(probe, transformResult.Transform, specialTransform);
                    return TryAddCrystalVolumeFromProbe(
                        source,
                        probe,
                        specialTransform,
                        AddCrystalSurfaceGameplayTargetKeys(GetCrystalBlockTargetKeys(block, shapeKind), specialSurface)
                    );
                }

                bool ProbeCrystalBlockMobilObjectModelTriggerSurface(
                    TriggerSourceSnapshot@ source,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    CGameCtnBlockInfoMobil@ mobil,
                    CGameObjectModel@ objectModel,
                    uint blockIndex,
                    const string &in ownerKind,
                    const string &in ownerName,
                    const string &in detail,
                    const string &in modelSlot,
                    const mat4 &in modelLocalTransform,
                    const string &in modelLocalTransformDetail,
                    uint slot,
                    uint index,
                    bool canRender,
                    bool canRenderVariantSurface,
                    const mat4 &in variantSurfaceTransform,
                    const string &in variantSurfaceDetail,
                    const string &in variantSurfaceWarning,
                    const string &in transformWarning,
                    const vec3 &in variantWorldSize
                ) {
                    if (source is null || block is null || variant is null || mobil is null || objectModel is null || objectModel.Phy is null) return false;

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

                    string shapeKind = "Mobil." + modelSlot + ".Phy.TriggerShape[" + tostring(slot) + ":" + tostring(index) + "]";
                    string surfaceDetail = "objectModel " + GetCrystalNodTypeName(objectModel)
                        + " phy " + GetCrystalNodTypeName(objectModel.Phy)
                        + " scriptId " + string(objectModel.ScriptId)
                        + " triggerActions " + tostring(objectModel.Phy.Triggers.Length)
                        + " triggerDataRef " + dataRefFilename;
                    if (dataRefDetail.Length > 0) surfaceDetail += " | " + dataRefDetail;
                    return ProbeCrystalBlockMobilResolvedSurface(
                        source,
                        block,
                        variant,
                        mobil,
                        blockIndex,
                        ownerKind,
                        ownerName,
                        detail,
                        shapeKind,
                        surface,
                        surfaceDetail,
                        modelLocalTransform,
                        modelLocalTransformDetail,
                        slot,
                        index,
                        canRender,
                        canRenderVariantSurface,
                        variantSurfaceTransform,
                        variantSurfaceDetail,
                        variantSurfaceWarning,
                        transformWarning,
                        variantWorldSize
                    );
                }

                bool ProbeCrystalBlockMobilPrefab(
                    TriggerSourceSnapshot@ source,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    CGameCtnBlockInfoMobil@ mobil,
                    CPlugPrefab@ prefab,
                    uint blockIndex,
                    const string &in ownerKind,
                    const string &in ownerName,
                    const string &in detail,
                    const string &in prefabSlot,
                    const mat4 &in prefabLocalTransform,
                    const string &in prefabLocalTransformDetail,
                    uint slot,
                    uint index,
                    bool canRender,
                    bool canRenderVariantSurface,
                    const mat4 &in variantSurfaceTransform,
                    const string &in variantSurfaceDetail,
                    const string &in variantSurfaceWarning,
                    const string &in transformWarning,
                    const vec3 &in variantWorldSize,
                    uint depth = 0
                ) {
                    if (source is null || prefab is null) return false;
                    if (depth > MAX_CRYSTAL_PREFAB_RECURSION) {
                        AddCrystalDiagnostic(
                            source,
                            ownerKind + " " + ownerName + " block mobil prefab scan reached recursion limit at " + prefabSlot + "."
                        );
                        return false;
                    }

                    bool found = false;
                    uint count = MinUint(prefab.Ents.Length, MAX_CRYSTAL_PREFAB_ENTS);
                    for (uint i = 0; i < count; i++) {
                        auto ent = prefab.Ents[i];
                        CMwNod@ entModel = ent.Model;
                        if (entModel is null) continue;

                        vec3 entTrans = ent.Location.Trans;
                        quat entRotation = ent.Location.Quat;
                        string entTransformWarning = "";
                        auto childTransformResult = CrystalShapeTransformResult();
                        if (!TryResolveCrystalPrefabChildTransform(entModel, entTrans, entRotation, prefabLocalTransform, childTransformResult, entTransformWarning)) {
                            continue;
                        }

                        string childSlot = prefabSlot + ".Ents[" + tostring(i) + "]";
                        string childDetail = prefabLocalTransformDetail;
                        if (childDetail.Length > 0) childDetail += " | ";
                        childDetail += CrystalShapeTransformResultDiagnostic(childTransformResult);
                        found = ProbeCrystalBlockMobilPrefabTriggerModel(
                            source,
                            block,
                            variant,
                            mobil,
                            entModel,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            detail,
                            childSlot,
                            childTransformResult.Transform,
                            childDetail,
                            slot,
                            index,
                            canRender,
                            canRenderVariantSurface,
                            variantSurfaceTransform,
                            variantSurfaceDetail,
                            variantSurfaceWarning,
                            transformWarning,
                            variantWorldSize,
                            depth + 1
                        ) || found;
                    }
                    if (prefab.Ents.Length > count) {
                        AddCrystalDiagnostic(
                            source,
                            ownerKind + " " + ownerName + " block mobil prefab entry probes truncated at " + tostring(count) + " of " + tostring(prefab.Ents.Length) + " entries."
                        );
                    }
                    return found;
                }

                bool ProbeCrystalBlockMobilPrefabTriggerModel(
                    TriggerSourceSnapshot@ source,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    CGameCtnBlockInfoMobil@ mobil,
                    CMwNod@ model,
                    uint blockIndex,
                    const string &in ownerKind,
                    const string &in ownerName,
                    const string &in detail,
                    const string &in modelSlot,
                    const mat4 &in modelLocalTransform,
                    const string &in modelLocalTransformDetail,
                    uint slot,
                    uint index,
                    bool canRender,
                    bool canRenderVariantSurface,
                    const mat4 &in variantSurfaceTransform,
                    const string &in variantSurfaceDetail,
                    const string &in variantSurfaceWarning,
                    const string &in transformWarning,
                    const vec3 &in variantWorldSize,
                    uint depth = 0
                ) {
                    if (source is null || model is null) return false;

                    bool found = false;
                    auto waypointTrigger = cast<NPlugTrigger_SWaypoint>(model);
                    if (waypointTrigger !is null) {
                        string shapeKind = "Mobil." + modelSlot + ".NPlugTrigger_SWaypoint.TriggerShape[" + tostring(slot) + ":" + tostring(index) + "]";
                        string surfaceDetail = "model " + GetCrystalNodTypeName(model)
                            + " waypointType " + tostring(waypointTrigger.Type)
                            + " noRespawn " + CrystalBoolLabel(waypointTrigger.NoRespawn);
                        found = ProbeCrystalBlockMobilResolvedSurface(
                            source,
                            block,
                            variant,
                            mobil,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            detail,
                            shapeKind,
                            waypointTrigger.TriggerShape,
                            surfaceDetail,
                            modelLocalTransform,
                            modelLocalTransformDetail,
                            slot,
                            index,
                            canRender,
                            canRenderVariantSurface,
                            variantSurfaceTransform,
                            variantSurfaceDetail,
                            variantSurfaceWarning,
                            transformWarning,
                            variantWorldSize
                        ) || found;
                    }

                    auto specialTrigger = cast<NPlugTrigger_SSpecial>(model);
                    if (specialTrigger !is null) {
                        CPlugSurface@ specialSurface = null;
                        try {
                            @specialSurface = specialTrigger.TriggerShape;
                        } catch {
                            logging::HandledException(
                                "ProbeCrystalBlockMobilModel",
                                "Special trigger surface was not readable."
                            );
                            @specialSurface = null;
                        }
                        if (specialSurface !is null) {
                            string shapeKind = "Mobil." + modelSlot + ".NPlugTrigger_SSpecial.TriggerShape[" + tostring(slot) + ":" + tostring(index) + "]";
                            string surfaceDetail = "model " + GetCrystalNodTypeName(model)
                                + " mergeable " + CrystalBoolLabel(specialTrigger.IsMergeable);
                            found = ProbeCrystalBlockMobilSpecialTriggerResolvedSurface(
                                source,
                                block,
                                variant,
                                mobil,
                                specialSurface,
                                blockIndex,
                                ownerKind,
                                ownerName,
                                detail,
                                shapeKind,
                                surfaceDetail,
                                modelLocalTransform,
                                modelLocalTransformDetail,
                                slot,
                                index,
                                canRender,
                                canRenderVariantSurface,
                                variantSurfaceTransform,
                                variantSurfaceDetail,
                                variantSurfaceWarning,
                                transformWarning,
                                variantWorldSize
                            ) || found;
                        }
                    }

                    auto commonEntity = cast<CGameCommonItemEntityModel>(model);
                    if (commonEntity !is null) {
                        auto transformResult = CrystalShapeTransformResult();
                        ResolveCrystalCommonEntityShapeTransform(
                            commonEntity,
                            null,
                            modelLocalTransform,
                            modelLocalTransformDetail.Length > 0 ? modelLocalTransformDetail : "mobil child",
                            CRYSTAL_SHAPE_SPACE_MOBIL_CHILD,
                            false,
                            transformResult
                        );
                        string commonLocalTransformDetail = CrystalShapeTransformResultDiagnostic(transformResult);
                        string shapeKind = "Mobil." + modelSlot + ".CGameCommonItemEntityModel.TriggerShape[" + tostring(slot) + ":" + tostring(index) + "]";
                        string surfaceDetail = "model " + GetCrystalNodTypeName(model)
                            + " spawnLoc " + CrystalVec3Label(vec3(commonEntity.SpawnLoc.tx, commonEntity.SpawnLoc.ty, commonEntity.SpawnLoc.tz));
                        if (transformResult.Warning.Length > 0) {
                            surfaceDetail += " | transform warning " + transformResult.Warning;
                        }
                        found = ProbeCrystalBlockMobilResolvedSurface(
                            source,
                            block,
                            variant,
                            mobil,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            detail,
                            shapeKind,
                            commonEntity.TriggerShape,
                            surfaceDetail,
                            transformResult.Transform,
                            commonLocalTransformDetail,
                            slot,
                            index,
                            canRender,
                            canRenderVariantSurface,
                            variantSurfaceTransform,
                            variantSurfaceDetail,
                            variantSurfaceWarning,
                            transformWarning,
                            variantWorldSize
                        ) || found;
                    }

                    auto gate = cast<CGameGateModel>(model);
                    if (gate !is null) {
                        string shapeKind = "Mobil." + modelSlot + ".CGameGateModel.Shape[" + tostring(slot) + ":" + tostring(index) + "]";
                        string surfaceDetail = "model " + GetCrystalNodTypeName(model);
                        found = ProbeCrystalBlockMobilResolvedSurface(
                            source,
                            block,
                            variant,
                            mobil,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            detail,
                            shapeKind,
                            gate.Shape,
                            surfaceDetail,
                            modelLocalTransform,
                            modelLocalTransformDetail,
                            slot,
                            index,
                            canRender,
                            canRenderVariantSurface,
                            variantSurfaceTransform,
                            variantSurfaceDetail,
                            variantSurfaceWarning,
                            transformWarning,
                            variantWorldSize
                        ) || found;
                    }

                    auto teleporter = cast<CGameTeleporterModel>(model);
                    if (teleporter !is null) {
                        string shapeKind = "Mobil." + modelSlot + ".CGameTeleporterModel.TriggerShape[" + tostring(slot) + ":" + tostring(index) + "]";
                        string surfaceDetail = "model " + GetCrystalNodTypeName(model)
                            + " centerPos " + CrystalVec3Label(teleporter.CenterPos);
                        found = ProbeCrystalBlockMobilResolvedSurface(
                            source,
                            block,
                            variant,
                            mobil,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            detail,
                            shapeKind,
                            teleporter.TriggerShape,
                            surfaceDetail,
                            modelLocalTransform,
                            modelLocalTransformDetail,
                            slot,
                            index,
                            canRender,
                            canRenderVariantSurface,
                            variantSurfaceTransform,
                            variantSurfaceDetail,
                            variantSurfaceWarning,
                            transformWarning,
                            variantWorldSize
                        ) || found;
                    }

                    auto objectModel = cast<CGameObjectModel>(model);
                    if (objectModel !is null) {
                        found = ProbeCrystalBlockMobilObjectModelTriggerSurface(
                            source,
                            block,
                            variant,
                            mobil,
                            objectModel,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            detail,
                            modelSlot + ".CGameObjectModel",
                            modelLocalTransform,
                            modelLocalTransformDetail,
                            slot,
                            index,
                            canRender,
                            canRenderVariantSurface,
                            variantSurfaceTransform,
                            variantSurfaceDetail,
                            variantSurfaceWarning,
                            transformWarning,
                            variantWorldSize
                        ) || found;
                        if (objectModel.SlaveShieldDome !is null) {
                            found = ProbeCrystalBlockMobilPrefabTriggerModel(
                                source,
                                block,
                                variant,
                                mobil,
                                objectModel.SlaveShieldDome,
                                blockIndex,
                                ownerKind,
                                ownerName,
                                detail,
                                modelSlot + ".SlaveShieldDome",
                                modelLocalTransform,
                                modelLocalTransformDetail,
                                slot,
                                index,
                                canRender,
                                canRenderVariantSurface,
                                variantSurfaceTransform,
                                variantSurfaceDetail,
                                variantSurfaceWarning,
                                transformWarning,
                                variantWorldSize,
                                depth + 1
                            ) || found;
                        }
                        if (objectModel.SlaveHealDome !is null) {
                            found = ProbeCrystalBlockMobilPrefabTriggerModel(
                                source,
                                block,
                                variant,
                                mobil,
                                objectModel.SlaveHealDome,
                                blockIndex,
                                ownerKind,
                                ownerName,
                                detail,
                                modelSlot + ".SlaveHealDome",
                                modelLocalTransform,
                                modelLocalTransformDetail,
                                slot,
                                index,
                                canRender,
                                canRenderVariantSurface,
                                variantSurfaceTransform,
                                variantSurfaceDetail,
                                variantSurfaceWarning,
                                transformWarning,
                                variantWorldSize,
                                depth + 1
                            ) || found;
                        }
                    }

                    auto nestedPrefab = cast<CPlugPrefab>(model);
                    if (nestedPrefab !is null) {
                        found = ProbeCrystalBlockMobilPrefab(
                            source,
                            block,
                            variant,
                            mobil,
                            nestedPrefab,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            detail,
                            modelSlot + ".CPlugPrefab",
                            modelLocalTransform,
                            modelLocalTransformDetail,
                            slot,
                            index,
                            canRender,
                            canRenderVariantSurface,
                            variantSurfaceTransform,
                            variantSurfaceDetail,
                            variantSurfaceWarning,
                            transformWarning,
                            variantWorldSize,
                            depth + 1
                        ) || found;
                    }

                    return found;
                }

                bool ProbeCrystalBlockMobilTriggerSurfaces(
                    TriggerSourceSnapshot@ source,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    uint blockIndex,
                    const string &in ownerKind,
                    const string &in ownerName,
                    const string &in detail,
                    bool canRender,
                    const mat4 &in blockTransform,
                    const string &in transformWarning
                ) {
                    if (source is null || block is null || variant is null) return false;

                    mat4 variantSurfaceTransform;
                    string variantSurfaceDetail = "";
                    string variantSurfaceWarning = "";
                    bool canRenderVariantSurface = false;
                    if (canRender) {
                        auto baseTransformResult = CrystalShapeTransformResult();
                        canRenderVariantSurface = TryResolveCrystalBlockLocalBaseTransform(
                            variant,
                            blockTransform,
                            baseTransformResult,
                            variantSurfaceWarning
                        );
                        if (canRenderVariantSurface) {
                            variantSurfaceTransform = baseTransformResult.Transform;
                            variantSurfaceDetail = baseTransformResult.Detail;
                        }
                    }
                    vec3 variantCoordSize = CrystalNat3ToVec3(variant.Size);
                    if (!CrystalIsSaneBlockCoordSize(variantCoordSize)) return false;
                    vec3 blockWorldSize = TriggerVisualizer::Trigger::Data::OFFZONE_BLOCK_WORLD_SIZE;
                    vec3 variantWorldSize = vec3(
                        variantCoordSize.x * blockWorldSize.x,
                        variantCoordSize.y * blockWorldSize.y,
                        variantCoordSize.z * blockWorldSize.z
                    );
                    bool foundAnyMobilTrigger = false;
                    uint checkedCount = 0;
                    for (uint slot = 0; slot < 16; slot++) {
                        uint length = GetCrystalVariantMobilSlotLength(variant, slot);
                        for (uint index = 0; index < length; index++) {
                            if (checkedCount >= MAX_CRYSTAL_BLOCK_MOBIL_TRIGGER_SURFACES) {
                                AddCrystalDiagnostic(
                                    source,
                                    ownerKind + " " + ownerName + " mobil trigger surface scan truncated at " + tostring(checkedCount) + " entries."
                                );
                                return foundAnyMobilTrigger;
                            }
                            checkedCount++;
                            CGameCtnBlockInfoMobil@ mobil = cast<CGameCtnBlockInfoMobil>(GetCrystalVariantMobilNod(variant, slot, index));
                            if (mobil is null) continue;

                            bool foundMobilTrigger = false;
                            mat4 identityLocalTransform = mat4::Identity();
                            if (mobil.SurfaceFromBlockItem !is null && !CrystalBlockMobilSurfaceIsVariantSurface(variant, mobil.SurfaceFromBlockItem)) {
                                string shapeKind = "Mobil.SurfaceFromBlockItem[" + tostring(slot) + ":" + tostring(index) + "]";
                                foundMobilTrigger = ProbeCrystalBlockMobilResolvedSurface(
                                    source,
                                    block,
                                    variant,
                                    mobil,
                                    blockIndex,
                                    ownerKind,
                                    ownerName,
                                    detail,
                                    shapeKind,
                                    mobil.SurfaceFromBlockItem,
                                    "surface from block item",
                                    identityLocalTransform,
                                    "",
                                    slot,
                                    index,
                                    canRender,
                                    canRenderVariantSurface,
                                    variantSurfaceTransform,
                                    variantSurfaceDetail,
                                    variantSurfaceWarning,
                                    transformWarning,
                                    variantWorldSize
                                );
                            }

                            bool foundObjectTrigger = ProbeCrystalBlockMobilObjectModelTriggerSurface(
                                source,
                                block,
                                variant,
                                mobil,
                                mobil.Cache_ObjectModelWithClips,
                                blockIndex,
                                ownerKind,
                                ownerName,
                                detail,
                                "Cache_ObjectModelWithClips",
                                identityLocalTransform,
                                "",
                                slot,
                                index,
                                canRender,
                                canRenderVariantSurface,
                                variantSurfaceTransform,
                                variantSurfaceDetail,
                                variantSurfaceWarning,
                                transformWarning,
                                variantWorldSize
                            );
                            foundMobilTrigger = foundObjectTrigger || foundMobilTrigger;
                            if (!foundObjectTrigger) {
                                foundObjectTrigger = ProbeCrystalBlockMobilObjectModelTriggerSurface(
                                    source,
                                    block,
                                    variant,
                                    mobil,
                                    mobil.Cache_ObjectModelWithoutClips,
                                    blockIndex,
                                    ownerKind,
                                    ownerName,
                                    detail,
                                    "Cache_ObjectModelWithoutClips",
                                    identityLocalTransform,
                                    "",
                                    slot,
                                    index,
                                    canRender,
                                    canRenderVariantSurface,
                                    variantSurfaceTransform,
                                    variantSurfaceDetail,
                                    variantSurfaceWarning,
                                    transformWarning,
                                    variantWorldSize
                                );
                                foundMobilTrigger = foundObjectTrigger || foundMobilTrigger;
                            }
                            foundAnyMobilTrigger = foundAnyMobilTrigger || foundMobilTrigger;
                        }
                    }
                    return foundAnyMobilTrigger;
                }
            }
        }
    }
}
