namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                bool CrystalShouldSkipExpandableMobilGeometry(
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant
                ) {
                    return CrystalExpandableBlockShouldUseRectangle(block, variant);
                }

                bool ProbeCrystalBlockHelperPrefabResolvedSurface(
                    TriggerSourceSnapshot@ source,
                    CGameCtnBlock@ block,
                    uint blockIndex,
                    const string &in ownerKind,
                    const string &in ownerName,
                    const string &in shapeKind,
                    CPlugSurface@ surface,
                    const string &in detail,
                    bool canRender,
                    bool canRenderVariantSurface,
                    const mat4 &in variantSurfaceTransform,
                    const string &in variantSurfaceWarning,
                    const mat4 &in modelLocalTransform,
                    const string &in transformWarning
                ) {
                    if (source is null || block is null || surface is null) return false;

                    auto probe = AddCrystalSurfaceProbe(
                        source,
                        ownerKind,
                        blockIndex,
                        ownerName,
                        shapeKind,
                        surface,
                        detail
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
                    ResolveCrystalComposedShapeTransform(
                        variantSurfaceTransform,
                        modelLocalTransform,
                        "variant surface",
                        "helper prefab local",
                        CRYSTAL_SHAPE_SPACE_PREFAB_CHILD,
                        transformResult
                    );
                    CrystalApplyShapeTransformResultToProbe(probe, transformResult);
                    return TryAddCrystalVolumeFromProbe(
                        source,
                        probe,
                        transformResult.Transform,
                        AddCrystalSurfaceGameplayTargetKeys(GetCrystalBlockTargetKeys(block, shapeKind), surface)
                    );
                }

                bool ProbeCrystalBlockHelperPrefabModel(
                    TriggerSourceSnapshot@ source,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    CMwNod@ model,
                    uint blockIndex,
                    const string &in ownerKind,
                    const string &in ownerName,
                    const string &in detail,
                    const string &in modelSlot,
                    const mat4 &in modelLocalTransform,
                    bool canRender,
                    bool canRenderVariantSurface,
                    const mat4 &in variantSurfaceTransform,
                    const string &in variantSurfaceWarning,
                    const string &in transformWarning,
                    uint depth = 0
                ) {
                    if (source is null || block is null || variant is null || model is null) return false;

                    bool found = false;
                    auto directSurface = cast<CPlugSurface>(model);
                    if (directSurface !is null && CrystalSurfaceLooksLikeTriggerShape(directSurface)) {
                        string surfaceDetail = detail
                            + " model " + GetCrystalNodTypeName(model)
                            + " fid " + CrystalNodFidText(directSurface);
                        found = ProbeCrystalBlockHelperPrefabResolvedSurface(
                            source,
                            block,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            modelSlot + ".CPlugSurface",
                            directSurface,
                            surfaceDetail,
                            canRender,
                            canRenderVariantSurface,
                            variantSurfaceTransform,
                            variantSurfaceWarning,
                            modelLocalTransform,
                            transformWarning
                        ) || found;
                    }

                    auto waypointTrigger = cast<NPlugTrigger_SWaypoint>(model);
                    if (waypointTrigger !is null) {
                        string waypointDetail = detail
                            + " model " + GetCrystalNodTypeName(model)
                            + " waypointType " + tostring(waypointTrigger.Type)
                            + " noRespawn " + CrystalBoolLabel(waypointTrigger.NoRespawn);
                        found = ProbeCrystalBlockHelperPrefabResolvedSurface(
                            source,
                            block,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            modelSlot + ".NPlugTrigger_SWaypoint.TriggerShape",
                            waypointTrigger.TriggerShape,
                            waypointDetail,
                            canRender,
                            canRenderVariantSurface,
                            variantSurfaceTransform,
                            variantSurfaceWarning,
                            modelLocalTransform,
                            transformWarning
                        ) || found;
                    }

                    auto specialTrigger = cast<NPlugTrigger_SSpecial>(model);
                    if (specialTrigger !is null) {
                        string specialDetail = detail
                            + " model " + GetCrystalNodTypeName(model)
                            + " mergeable " + CrystalBoolLabel(specialTrigger.IsMergeable);
                        auto probe = AddCrystalSurfaceProbe(
                            source,
                            ownerKind,
                            blockIndex,
                            ownerName,
                            modelSlot + ".NPlugTrigger_SSpecial.TriggerShape",
                            specialTrigger.TriggerShape,
                            specialDetail
                        );
                        if (probe !is null) {
                            found = true;
                            if (!canRender || !canRenderVariantSurface) {
                                if (probe.HasLocalBounds) {
                                    source.RejectedShapeCount++;
                                    probe.Warning = CrystalAppendWarning(
                                        probe.Warning,
                                        canRender ? variantSurfaceWarning : transformWarning
                                    );
                                }
                            } else {
                                auto baseSpecialTransformResult = CrystalShapeTransformResult();
                                ResolveCrystalComposedShapeTransform(
                                    variantSurfaceTransform,
                                    modelLocalTransform,
                                    "variant surface",
                                    "helper prefab local",
                                    CRYSTAL_SHAPE_SPACE_PREFAB_CHILD,
                                    baseSpecialTransformResult
                                );
                                CrystalApplyShapeTransformResultToProbe(probe, baseSpecialTransformResult);
                                mat4 baseSpecialTransform = baseSpecialTransformResult.Transform;
                                mat4 specialTransform = baseSpecialTransform;
                                TryGetCrystalSpecialTriggerTransform(probe, baseSpecialTransform, specialTransform);
                                TryAddCrystalVolumeFromProbe(
                                    source,
                                    probe,
                                    specialTransform,
                                    AddCrystalSurfaceGameplayTargetKeys(GetCrystalBlockTargetKeys(block, modelSlot + ".NPlugTrigger_SSpecial.TriggerShape"), specialTrigger.TriggerShape)
                                );
                            }
                        }
                    }

                    auto gate = cast<CGameGateModel>(model);
                    if (gate !is null) {
                        string gateDetail = detail + " model " + GetCrystalNodTypeName(model);
                        found = ProbeCrystalBlockHelperPrefabResolvedSurface(
                            source,
                            block,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            modelSlot + ".CGameGateModel.Shape",
                            gate.Shape,
                            gateDetail,
                            canRender,
                            canRenderVariantSurface,
                            variantSurfaceTransform,
                            variantSurfaceWarning,
                            modelLocalTransform,
                            transformWarning
                        ) || found;
                    }

                    auto teleporter = cast<CGameTeleporterModel>(model);
                    if (teleporter !is null) {
                        string teleporterDetail = detail
                            + " model " + GetCrystalNodTypeName(model)
                            + " centerPos " + CrystalVec3Label(teleporter.CenterPos);
                        found = ProbeCrystalBlockHelperPrefabResolvedSurface(
                            source,
                            block,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            modelSlot + ".CGameTeleporterModel.TriggerShape",
                            teleporter.TriggerShape,
                            teleporterDetail,
                            canRender,
                            canRenderVariantSurface,
                            variantSurfaceTransform,
                            variantSurfaceWarning,
                            modelLocalTransform,
                            transformWarning
                        ) || found;
                    }

                    auto nestedPrefab = cast<CPlugPrefab>(model);
                    if (nestedPrefab !is null) {
                        found = ProbeCrystalBlockHelperPrefab(
                            source,
                            block,
                            variant,
                            nestedPrefab,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            detail,
                            modelSlot + ".CPlugPrefab",
                            modelLocalTransform,
                            canRender,
                            canRenderVariantSurface,
                            variantSurfaceTransform,
                            variantSurfaceWarning,
                            transformWarning,
                            depth + 1
                        ) || found;
                    }

                    return found;
                }

                bool ProbeCrystalBlockHelperPrefab(
                    TriggerSourceSnapshot@ source,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    CPlugPrefab@ prefab,
                    uint blockIndex,
                    const string &in ownerKind,
                    const string &in ownerName,
                    const string &in detail,
                    const string &in prefabSlot,
                    const mat4 &in prefabLocalTransform,
                    bool canRender,
                    bool canRenderVariantSurface,
                    const mat4 &in variantSurfaceTransform,
                    const string &in variantSurfaceWarning,
                    const string &in transformWarning,
                    uint depth = 0
                ) {
                    if (source is null || prefab is null) return false;
                    if (depth > MAX_CRYSTAL_PREFAB_RECURSION) {
                        AddCrystalDiagnostic(
                            source,
                            ownerKind + " " + ownerName + " helper prefab scan reached recursion limit at " + prefabSlot + "."
                        );
                        return false;
                    }

                    bool found = false;
                    uint count = CrystalMinUint(prefab.Ents.Length, MAX_CRYSTAL_PREFAB_ENTS);
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
                        string childDetail = detail
                            + " helperPrefabDepth " + tostring(depth)
                            + " modelSlot " + childSlot
                            + " model " + GetCrystalNodTypeName(entModel)
                            + " | " + CrystalShapeTransformResultDiagnostic(childTransformResult);
                        found = ProbeCrystalBlockHelperPrefabModel(
                            source,
                            block,
                            variant,
                            entModel,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            childDetail,
                            childSlot,
                            childTransformResult.Transform,
                            canRender,
                            canRenderVariantSurface,
                            variantSurfaceTransform,
                            variantSurfaceWarning,
                            transformWarning,
                            depth + 1
                        ) || found;
                    }
                    if (prefab.Ents.Length > count) {
                        AddCrystalDiagnostic(
                            source,
                            ownerKind + " " + ownerName + " helper prefab entry probes truncated at " + tostring(count) + " of " + tostring(prefab.Ents.Length) + " entries."
                        );
                    }
                    return found;
                }

                const int CRYSTAL_EXPANDABLE_DIR_NORTH = 0;
                const int CRYSTAL_EXPANDABLE_DIR_EAST = 1;
                const int CRYSTAL_EXPANDABLE_DIR_SOUTH = 2;
                const int CRYSTAL_EXPANDABLE_DIR_WEST = 3;
                const int CRYSTAL_EXPANDABLE_DIR_TOP = 4;
                const int CRYSTAL_EXPANDABLE_DIR_BOTTOM = 5;
            }
        }
    }
}
