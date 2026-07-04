namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                string GetCrystalBlockName(CGameCtnBlock@ block, uint index) {
                    if (block is null) return "#" + tostring(index);
                    if (block.BlockInfo !is null) {
                        string blockName = string(block.BlockInfo.Name);
                        if (blockName.Length > 0) return blockName + " @" + block.Coord.ToString();
                    }
                    return "#" + tostring(index) + " @" + block.Coord.ToString();
                }

                CGameCtnBlockInfoVariant@ GetCrystalBlockVariant(CGameCtnBlock@ block) {
                    if (block is null || block.BlockInfo is null) return null;

                    auto info = block.BlockInfo;
                    uint variantIndex = block.BlockInfoVariantIndex;
                    if (block.IsGround) {
                        if (variantIndex == 0) return info.VariantGround;
                        uint additionalIndex = variantIndex - 1;
                        if (additionalIndex < info.AdditionalVariantsGround.Length) return info.AdditionalVariantsGround[additionalIndex];
                        return info.VariantGround;
                    }

                    if (variantIndex == 0) return info.VariantAir;
                    uint additionalAirIndex = variantIndex - 1;
                    if (additionalAirIndex < info.AdditionalVariantsAir.Length) return info.AdditionalVariantsAir[additionalAirIndex];
                    return info.VariantAir;
                }

                CGameCtnBlockInfoVariant@ GetCrystalBlockVariantWithBaseFallback(CGameCtnBlock@ block) {
                    if (block is null || block.BlockInfo is null) return null;
                    auto variant = GetCrystalBlockVariant(block);
                    if (variant !is null) return variant;

                    auto info = block.BlockInfo;
                    if (block.IsGround) return info.VariantBaseGround;
                    return info.VariantBaseAir;
                }

                void ProbeCrystalBlockSurface(
                    TriggerSourceSnapshot@ source,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    uint blockIndex,
                    const string &in ownerKind,
                    const string &in ownerName,
                    const string &in shapeKind,
                    CPlugSurface@ surface,
                    const string &in detail,
                    bool canRender,
                    const mat4 &in blockTransform,
                    const string &in transformWarning
                ) {
                    string probeDetail = detail;
                    if (CrystalBlockShapeUsesMaterialModifier(shapeKind)) {
                        string modifierDetail = CrystalBlockMaterialModifierDetail(block);
                        if (modifierDetail.Length > 0) probeDetail += " " + modifierDetail;
                    }

                    auto probe = AddCrystalSurfaceProbe(
                        source,
                        ownerKind,
                        blockIndex,
                        ownerName,
                        shapeKind,
                        surface,
                        probeDetail
                    );
                    if (probe is null) return;

                    if (!canRender) {
                        if (probe.HasLocalBounds) {
                            source.RejectedShapeCount++;
                            probe.Warning = CrystalAppendWarning(
                                probe.Warning,
                                transformWarning
                            );
                        }
                        return;
                    }

                    auto transformResult = CrystalShapeTransformResult();
                    string surfaceTransformWarning = "";
                    bool canRenderSurface = TryResolveCrystalBlockSurfaceShapeTransform(
                        block,
                        variant,
                        probe,
                        shapeKind,
                        surface,
                        blockTransform,
                        transformResult,
                        surfaceTransformWarning
                    );
                    if (canRenderSurface) {
                        CrystalApplyShapeTransformResultToProbe(probe, transformResult);
                    } else if (surfaceTransformWarning.Length > 0) {
                        probe.Detail = probe.Detail.Length > 0 ?
                            probe.Detail + " | transform skipped: " + surfaceTransformWarning : "transform skipped: " + surfaceTransformWarning;
                    }
                    if (!canRenderSurface) {
                        source.RejectedShapeCount++;
                        probe.Warning = CrystalAppendWarning(
                            probe.Warning,
                            surfaceTransformWarning
                        );
                        return;
                    }
                    TryAddCrystalVolumeFromProbe(
                        source,
                        probe,
                        transformResult.Transform,
                        AddCrystalSurfaceGameplayTargetKeys(GetCrystalBlockTargetKeys(block, shapeKind), surface)
                    );
                }

                bool ProbeCrystalBlockVariantSpecialTriggerSurface(
                    TriggerSourceSnapshot@ source,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    uint blockIndex,
                    const string &in ownerKind,
                    const string &in ownerName,
                    const string &in shapeKind,
                    NPlugTrigger_SSpecial@ specialTrigger,
                    const string &in detail,
                    bool canRender,
                    const mat4 &in blockTransform,
                    const string &in transformWarning
                ) {
                    if (source is null || block is null || variant is null || specialTrigger is null || specialTrigger.TriggerShape is null) return false;

                    string probeDetail = detail
                        + " model " + GetCrystalNodTypeName(specialTrigger)
                        + " mergeable " + CrystalBoolLabel(specialTrigger.IsMergeable);
                    string modifierDetail = CrystalBlockMaterialModifierDetail(block);
                    if (modifierDetail.Length > 0) probeDetail += " " + modifierDetail;

                    auto probe = AddCrystalSurfaceProbe(
                        source,
                        ownerKind,
                        blockIndex,
                        ownerName,
                        shapeKind,
                        specialTrigger.TriggerShape,
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

                    auto transformResult = CrystalShapeTransformResult();
                    string surfaceTransformWarning = "";
                    if (!TryResolveCrystalBlockSurfaceShapeTransform(block, variant, probe, shapeKind, specialTrigger.TriggerShape, blockTransform, transformResult, surfaceTransformWarning)) {
                        source.RejectedShapeCount++;
                        probe.Warning = CrystalAppendWarning(
                            probe.Warning,
                            surfaceTransformWarning
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
                        AddCrystalSurfaceGameplayTargetKeys(GetCrystalBlockTargetKeys(block, shapeKind), specialTrigger.TriggerShape)
                    );
                }

                bool ProbeCrystalBlockDeprecatedTriggerNod(
                    TriggerSourceSnapshot@ source,
                    CGameCtnBlock@ block,
                    CGameCtnBlockInfoVariant@ variant,
                    uint blockIndex,
                    const string &in ownerKind,
                    const string &in ownerName,
                    const string &in detail,
                    const string &in fieldName,
                    CMwNod@ nod,
                    bool canRender,
                    const mat4 &in blockTransform,
                    const string &in transformWarning
                ) {
                    if (source is null || block is null || variant is null || nod is null) return false;

                    string nodDetail = detail
                        + " | deprecated variant trigger nod " + fieldName
                        + " type " + GetCrystalNodTypeName(nod);
                    auto directSurface = cast<CPlugSurface>(nod);
                    if (directSurface !is null) {
                        ProbeCrystalBlockSurface(
                            source,
                            block,
                            variant,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            fieldName + ".CPlugSurface",
                            directSurface,
                            nodDetail,
                            canRender,
                            blockTransform,
                            transformWarning
                        );
                        return true;
                    }

                    auto waypointTrigger = cast<NPlugTrigger_SWaypoint>(nod);
                    if (waypointTrigger !is null) {
                        ProbeCrystalBlockSurface(
                            source,
                            block,
                            variant,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            fieldName + ".NPlugTrigger_SWaypoint.TriggerShape",
                            waypointTrigger.TriggerShape,
                            nodDetail + " waypointType " + tostring(waypointTrigger.Type) + " noRespawn " + CrystalBoolLabel(waypointTrigger.NoRespawn),
                            canRender,
                            blockTransform,
                            transformWarning
                        );
                        return true;
                    }

                    auto specialTrigger = cast<NPlugTrigger_SSpecial>(nod);
                    if (specialTrigger !is null) {
                        return ProbeCrystalBlockVariantSpecialTriggerSurface(
                            source,
                            block,
                            variant,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            fieldName + ".NPlugTrigger_SSpecial.TriggerShape",
                            specialTrigger,
                            nodDetail,
                            canRender,
                            blockTransform,
                            transformWarning
                        );
                    }

                    auto commonEntity = cast<CGameCommonItemEntityModel>(nod);
                    if (commonEntity !is null) {
                        ProbeCrystalBlockSurface(
                            source,
                            block,
                            variant,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            fieldName + ".CGameCommonItemEntityModel.TriggerShape",
                            commonEntity.TriggerShape,
                            nodDetail + " spawnLoc " + CrystalVec3Label(vec3(commonEntity.SpawnLoc.tx, commonEntity.SpawnLoc.ty, commonEntity.SpawnLoc.tz)),
                            canRender,
                            blockTransform,
                            transformWarning
                        );
                        return true;
                    }

                    auto gate = cast<CGameGateModel>(nod);
                    if (gate !is null) {
                        ProbeCrystalBlockSurface(
                            source,
                            block,
                            variant,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            fieldName + ".CGameGateModel.Shape",
                            gate.Shape,
                            nodDetail,
                            canRender,
                            blockTransform,
                            transformWarning
                        );
                        return true;
                    }

                    auto teleporter = cast<CGameTeleporterModel>(nod);
                    if (teleporter !is null) {
                        ProbeCrystalBlockSurface(
                            source,
                            block,
                            variant,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            fieldName + ".CGameTeleporterModel.TriggerShape",
                            teleporter.TriggerShape,
                            nodDetail + " centerPos " + CrystalVec3Label(teleporter.CenterPos),
                            canRender,
                            blockTransform,
                            transformWarning
                        );
                        return true;
                    }

                    auto objectModel = cast<CGameObjectModel>(nod);
                    if (objectModel !is null && objectModel.Phy !is null) {
                        string dataRefFilename = "";
                        string dataRefDetail = "";
                        string dataRefWarning = "";
                        CPlugSurface@ surface = ResolveCrystalPhyModelTriggerShapeSurface(
                            objectModel.Phy,
                            dataRefFilename,
                            dataRefDetail,
                            dataRefWarning
                        );
                        if (surface !is null) {
                            string objectDetail = nodDetail
                                + " objectModel " + GetCrystalNodTypeName(objectModel)
                                + " phy " + GetCrystalNodTypeName(objectModel.Phy)
                                + " triggerActions " + tostring(objectModel.Phy.Triggers.Length)
                                + " triggerDataRef " + dataRefFilename;
                            if (dataRefDetail.Length > 0) objectDetail += " | " + dataRefDetail;
                            ProbeCrystalBlockSurface(
                                source,
                                block,
                                variant,
                                blockIndex,
                                ownerKind,
                                ownerName,
                                fieldName + ".CGameObjectModel.Phy.TriggerShape",
                                surface,
                                objectDetail,
                                canRender,
                                blockTransform,
                                transformWarning
                            );
                            return true;
                        }
                    }
                    if (CrystalBlockHasGameplaySpecialMaterialModifier(block)) {
                        AddCrystalDiagnostic(
                            source,
                            ownerKind + " " + ownerName + " " + fieldName + " exposed unsupported deprecated trigger nod type " + GetCrystalNodTypeName(nod) + "."
                        );
                    }
                    return false;
                }
            }
        }
    }
}
