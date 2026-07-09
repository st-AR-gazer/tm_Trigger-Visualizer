namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                string GetCrystalItemModelName(CGameItemModel@ itemModel, uint index) {
                    if (itemModel is null) return "#" + tostring(index);
                    string itemName = string(itemModel.Name);
                    if (itemName.Length > 0) return itemName;
                    string idName = itemModel.Id.GetName();
                    if (idName.Length > 0) return idName;
                    return "#" + tostring(index);
                }

                void ProbeCrystalBlockItemTriggerShapes(
                    TriggerSourceSnapshot@ source,
                    uint objectIndex,
                    const string &in ownerName,
                    CGameBlockItem@ blockItem,
                    const string &in itemDetail,
                    const mat4 &in itemTransform,
                    const string &in targetKeys
                ) {
                    if (source is null || blockItem is null) return;

                    AddCrystalDiagnostic(
                        source,
                        "Item " + ownerName + " block item edition: triggerShapes " + tostring(blockItem.BlockInfoMobilSkins_TriggerShapes.Length) + ", crystals " + tostring(blockItem.BlockInfoMobilSkins_Crystals.Length) + ", staticObjModels " + tostring(blockItem.BlockInfoMobilSkins_StaticObjModels.Length) + ", spawnLocs " + tostring(blockItem.BlockInfoMobilSkins_SpawnLocTranss.Length)
                    );
                    uint count = CrystalMinUint(
                        blockItem.BlockInfoMobilSkins_TriggerShapes.Length,
                        MAX_CRYSTAL_BLOCK_ITEM_TRIGGER_SHAPES
                    );
                    for (uint i = 0; i < count; i++) {
                        string detail = itemDetail + " " + GetCrystalBlockItemSpawnDetail(blockItem, i);
                        auto probe = AddCrystalSurfaceProbe(
                            source,
                            "BlockItem",
                            objectIndex,
                            ownerName,
                            "BlockInfoMobilSkins_TriggerShapes[" + tostring(i) + "]",
                            blockItem.BlockInfoMobilSkins_TriggerShapes[i],
                            detail
                        );
                        if (probe !is null && probe.HasLocalBounds) {
                            mat4 shapeTransform;
                            string transformDetail = "";
                            string transformWarning = "";
                            bool canRender = TryGetCrystalBlockItemShapeTransform(
                                blockItem,
                                i,
                                itemTransform,
                                shapeTransform,
                                transformDetail,
                                transformWarning
                            );
                            if (transformDetail.Length > 0) {
                                probe.Detail = probe.Detail.Length > 0 ? probe.Detail + " | " + transformDetail : transformDetail;
                            } else if (transformWarning.Length > 0) {
                                probe.Detail = probe.Detail.Length > 0 ?
                                    probe.Detail + " | transform skipped: " + transformWarning : "transform skipped: " + transformWarning;
                            }
                            if (canRender) {
                                string shapeTargetKeys = AddCrystalSurfaceGameplayTargetKeys(
                                    targetKeys,
                                    blockItem.BlockInfoMobilSkins_TriggerShapes[i]
                                );
                                TryAddCrystalVolumeFromProbe(
                                    source,
                                    probe,
                                    shapeTransform,
                                    shapeTargetKeys
                                );
                            } else {
                                source.RejectedShapeCount++;
                                probe.Warning = CrystalAppendWarning(probe.Warning, transformWarning);
                            }
                        }
                    }
                    if (blockItem.BlockInfoMobilSkins_TriggerShapes.Length > count) {
                        AddCrystalDiagnostic(
                            source,
                            "Item " + ownerName + " block item trigger shape probes truncated at " + tostring(count) + " entries."
                        );
                    }
                }

                void ProbeCrystalItemTeleporterModel(
                    TriggerSourceSnapshot@ source,
                    uint objectIndex,
                    const string &in ownerName,
                    CGameItemModel@ itemModel,
                    CGameCtnCollection@ collection,
                    CGameTeleporterModel@ teleporterModel,
                    const string &in modelSlot,
                    const string &in itemDetail,
                    const mat4 &in itemTransform
                ) {
                    if (source is null || teleporterModel is null) return;

                    string detail = itemDetail
                        + " modelSlot " + modelSlot
                        + " centerPos " + CrystalVec3Label(teleporterModel.CenterPos);
                    auto probe = AddCrystalSurfaceProbe(
                        source,
                        "Item",
                        objectIndex,
                        ownerName,
                        modelSlot + ".CGameTeleporterModel.TriggerShape",
                        teleporterModel.TriggerShape,
                        detail
                    );
                    if (probe !is null) {
                        string teleporterTargetKeys = AddCrystalSurfaceGameplayTargetKeys(
                            GetCrystalTeleporterTargetKeys(itemModel),
                            teleporterModel.TriggerShape
                        );
                        TryAddCrystalVolumeFromProbe(
                            source,
                            probe,
                            itemTransform,
                            teleporterTargetKeys
                        );
                    }
                }

                void ProbeCrystalItemGateModel(
                    TriggerSourceSnapshot@ source,
                    uint objectIndex,
                    const string &in ownerName,
                    CGameItemModel@ itemModel,
                    CGameCtnCollection@ collection,
                    CGameGateModel@ gateModel,
                    const string &in modelSlot,
                    const string &in itemDetail,
                    const mat4 &in itemTransform
                ) {
                    if (source is null || gateModel is null) return;

                    string detail = itemDetail + " modelSlot " + modelSlot;
                    string modifierDetail = CrystalMaterialModifierDetail(itemModel);
                    if (modifierDetail.Length > 0) detail += " " + modifierDetail;
                    auto probe = AddCrystalSurfaceProbe(
                        source,
                        "Item",
                        objectIndex,
                        ownerName,
                        modelSlot + ".CGameGateModel.Shape",
                        gateModel.Shape,
                        detail
                    );
                    if (probe !is null) {
                        string gateTargetKeys = AddCrystalSurfaceGameplayTargetKeys(
                            GetCrystalGateTargetKeys(itemModel),
                            gateModel.Shape
                        );
                        gateTargetKeys = AddCrystalMaterialModifierTargetKeys(gateTargetKeys, itemModel);
                        TryAddCrystalVolumeFromProbe(
                            source,
                            probe,
                            itemTransform,
                            gateTargetKeys
                        );
                    }
                }

                bool ProbeCrystalItemPhyModelTriggerShape(
                    TriggerSourceSnapshot@ source,
                    uint objectIndex,
                    const string &in ownerName,
                    CGameItemModel@ itemModel,
                    CGameObjectPhyModel@ phyModel,
                    const string &in modelSlot,
                    const string &in itemDetail,
                    const mat4 &in itemTransform
                ) {
                    if (source is null || phyModel is null) return false;

                    string dataRefFilename = "";
                    string dataRefDetail = "";
                    string dataRefWarning = "";
                    CPlugSurface@ surface = ResolveCrystalPhyModelTriggerShapeSurface(
                        phyModel,
                        dataRefFilename,
                        dataRefDetail,
                        dataRefWarning
                    );
                    string detail = itemDetail
                        + " modelSlot " + modelSlot
                        + " triggerActions " + tostring(phyModel.Triggers.Length)
                        + " triggerDataRef " + dataRefFilename;
                    if (dataRefDetail.Length > 0) detail += " | " + dataRefDetail;
                    if (dataRefWarning.Length > 0) detail += " | " + dataRefWarning;

                    auto probe = AddCrystalSurfaceProbe(
                        source,
                        "Item",
                        objectIndex,
                        ownerName,
                        modelSlot + ".CGameObjectPhyModel.TriggerShape",
                        surface,
                        detail
                    );
                    if (probe is null) return false;
                    if (surface is null) {
                        probe.Warning = CrystalAppendWarning(probe.Warning, dataRefWarning);
                        return false;
                    }

                    string targetKeys = AddCrystalSurfaceGameplayTargetKeys(
                        GetCrystalItemTargetKeys(itemModel),
                        surface
                    );
                    targetKeys = AddCrystalMaterialModifierTargetKeys(targetKeys, itemModel);
                    TryAddCrystalVolumeFromProbe(
                        source,
                        probe,
                        itemTransform,
                        targetKeys
                    );
                    return true;
                }

                bool ProbeCrystalSpecialTriggerModel(
                    TriggerSourceSnapshot@ source,
                    uint objectIndex,
                    const string &in ownerName,
                    CGameItemModel@ itemModel,
                    CGameCtnCollection@ collection,
                    NPlugTrigger_SSpecial@ specialTrigger,
                    const string &in modelSlot,
                    const string &in itemDetail,
                    const mat4 &in modelTransform
                ) {
                    if (source is null || specialTrigger is null) return false;

                    string specialDetail = itemDetail + " mergeable " + CrystalBoolLabel(specialTrigger.IsMergeable);
                    string modifierDetail = CrystalMaterialModifierDetail(itemModel);
                    if (modifierDetail.Length > 0) specialDetail += " " + modifierDetail;
                    string shapeSlot = modelSlot.Length > 0 ?
                        modelSlot + ".NPlugTrigger_SSpecial.TriggerShape" : "NPlugTrigger_SSpecial.TriggerShape";
                    auto probe = AddCrystalSurfaceProbe(
                        source,
                        "Item",
                        objectIndex,
                        ownerName,
                        shapeSlot,
                        specialTrigger.TriggerShape,
                        specialDetail
                    );
                    if (probe is null) return false;

                    mat4 specialTransform = modelTransform;
                    TryGetCrystalSpecialTriggerTransform(probe, modelTransform, specialTransform);
                    string specialBaseTargetKeys = GetCrystalItemTargetKeys(itemModel);
                    string specialTargetKeys = AddCrystalMaterialModifierTargetKeys(
                        specialBaseTargetKeys,
                        itemModel
                    );
                    if (specialTargetKeys == specialBaseTargetKeys) {
                        specialTargetKeys = AddCrystalSurfaceGameplayTargetKeys(
                            specialBaseTargetKeys,
                            specialTrigger.TriggerShape
                        );
                    }
                    TryAddCrystalVolumeFromProbe(
                        source,
                        probe,
                        specialTransform,
                        specialTargetKeys
                    );
                    return true;
                }

                bool ProbeCrystalItemVariantListModel(
                    TriggerSourceSnapshot@ source,
                    uint objectIndex,
                    const string &in ownerName,
                    CGameItemModel@ itemModel,
                    CGameCtnCollection@ collection,
                    NPlugItem_SVariantList@ variantList,
                    uint itemVariantIndex,
                    const string &in modelSlot,
                    const string &in itemDetail,
                    const mat4 &in itemTransform
                ) {
                    if (source is null || variantList is null) return false;

                    uint variantCount = variantList.Variants.Length;
                    if (variantCount == 0) {
                        AddCrystalDiagnostic(
                            source,
                            "Item " + ownerName + " " + modelSlot + " NPlugItem_SVariantList has no variants."
                        );
                        return false;
                    }

                    uint count = CrystalMinUint(
                        variantCount,
                        MAX_CRYSTAL_ITEM_VARIANTS
                    );
                    uint selectedIndex = itemVariantIndex < count ? itemVariantIndex : 0;
                    if (itemVariantIndex >= count) {
                        AddCrystalDiagnostic(
                            source,
                            "Item " + ownerName + " " + modelSlot + " variant index " + tostring(itemVariantIndex) + " outside probed variants " + tostring(count) + "/" + tostring(variantCount) + "; using variant 0."
                        );
                    }
                    CMwNod@ variantModel = variantList.Variants[selectedIndex].EntityModel;
                    if (variantModel is null) {
                        AddCrystalDiagnostic(
                            source,
                            "Item " + ownerName + " " + modelSlot + " variant " + tostring(selectedIndex) + " has no EntityModel."
                        );
                        return false;
                    }

                    string variantSlot = modelSlot + ".NPlugItem_SVariantList.Variants[" + tostring(selectedIndex) + "].EntityModel";
                    string variantDetail = itemDetail
                        + " modelSlot " + modelSlot
                        + " selectedVariant " + tostring(selectedIndex)
                        + "/" + tostring(variantCount)
                        + " variantModel " + GetCrystalNodTypeName(variantModel);
                    bool found = ProbeCrystalPrefabTriggerModel(
                        source,
                        objectIndex,
                        ownerName,
                        itemModel,
                        collection,
                        variantModel,
                        variantSlot,
                        variantDetail,
                        itemTransform
                    );
                    if (!found) {
                        AddCrystalDiagnostic(
                            source,
                            "Item " + ownerName + " " + variantSlot + " had no public trigger model entries."
                        );
                    }
                    return found;
                }

                bool ProbeCrystalPrefabModel(
                    TriggerSourceSnapshot@ source,
                    uint objectIndex,
                    const string &in ownerName,
                    CGameItemModel@ itemModel,
                    CGameCtnCollection@ collection,
                    CPlugPrefab@ prefab,
                    const string &in modelSlot,
                    const string &in itemDetail,
                    const mat4 &in prefabTransform,
                    uint depth = 0
                ) {
                    if (source is null || prefab is null) return false;
                    if (depth > MAX_CRYSTAL_PREFAB_RECURSION) {
                        AddCrystalDiagnostic(
                            source,
                            "Item " + ownerName + " prefab scan reached recursion limit at " + modelSlot + "."
                        );
                        return false;
                    }

                    bool found = false;
                    uint count = CrystalMinUint(
                        prefab.Ents.Length,
                        MAX_CRYSTAL_PREFAB_ENTS
                    );
                    for (uint i = 0; i < count; i++) {
                        auto ent = prefab.Ents[i];
                        CMwNod@ entModel = ent.Model;
                        if (entModel is null) continue;

                        vec3 entTrans = ent.Location.Trans;
                        quat entRotation = ent.Location.Quat;
                        string entTransformWarning = "";
                        auto childTransformResult = CrystalShapeTransformResult();
                        if (!TryResolveCrystalPrefabChildTransform(entModel, entTrans, entRotation, prefabTransform, childTransformResult, entTransformWarning)) {
                            AddCrystalDiagnostic(
                                source,
                                "Item " + ownerName + " prefab entry " + modelSlot + ".Ents[" + tostring(i) + "] skipped: " + entTransformWarning
                            );
                            continue;
                        }

                        string childSlot = modelSlot + ".Ents[" + tostring(i) + "]";
                        string childDetail = itemDetail
                            + " prefabDepth " + tostring(depth)
                            + " modelSlot " + childSlot
                            + " model " + GetCrystalNodTypeName(entModel)
                            + " | " + CrystalShapeTransformResultDiagnostic(childTransformResult);
                        if (ProbeCrystalPrefabTriggerModel(source, objectIndex, ownerName, itemModel, collection, entModel, childSlot, childDetail, childTransformResult.Transform, depth + 1)) {
                            found = true;
                        }
                    }
                    if (prefab.Ents.Length > count) {
                        AddCrystalDiagnostic(
                            source,
                            "Item " + ownerName + " prefab entry probes truncated at " + tostring(count) + " of " + tostring(prefab.Ents.Length) + " entries."
                        );
                    }
                    return found;
                }

                bool ProbeCrystalPrefabTriggerModel(
                    TriggerSourceSnapshot@ source,
                    uint objectIndex,
                    const string &in ownerName,
                    CGameItemModel@ itemModel,
                    CGameCtnCollection@ collection,
                    CMwNod@ model,
                    const string &in modelSlot,
                    const string &in itemDetail,
                    const mat4 &in modelTransform,
                    uint depth = 0
                ) {
                    if (source is null || model is null) return false;

                    bool found = false;
                    auto objectPhyModel = cast<CGameObjectPhyModel>(model);
                    if (objectPhyModel !is null) {
                        found = ProbeCrystalItemPhyModelTriggerShape(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            objectPhyModel,
                            modelSlot,
                            itemDetail,
                            modelTransform
                        ) || found;
                    }

                    auto waypointTrigger = cast<NPlugTrigger_SWaypoint>(model);
                    if (waypointTrigger !is null) {
                        string waypointDetail = itemDetail
                            + " waypointType " + tostring(waypointTrigger.Type)
                            + " noRespawn " + CrystalBoolLabel(waypointTrigger.NoRespawn);
                        auto probe = AddCrystalSurfaceProbe(
                            source,
                            "Item",
                            objectIndex,
                            ownerName,
                            modelSlot + ".NPlugTrigger_SWaypoint.TriggerShape",
                            waypointTrigger.TriggerShape,
                            waypointDetail
                        );
                        if (probe !is null) {
                            found = true;
                            string waypointTargetKeys = AddCrystalSurfaceGameplayTargetKeys(
                                GetCrystalWaypointTriggerTargetKeys(waypointTrigger, itemModel),
                                waypointTrigger.TriggerShape
                            );
                            TryAddCrystalVolumeFromProbe(
                                source,
                                probe,
                                modelTransform,
                                waypointTargetKeys
                            );
                        }
                    }

                    auto specialTrigger = cast<NPlugTrigger_SSpecial>(model);
                    if (specialTrigger !is null) {
                        found = ProbeCrystalSpecialTriggerModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            specialTrigger,
                            modelSlot,
                            itemDetail,
                            modelTransform
                        ) || found;
                    }

                    auto commonEntity = cast<CGameCommonItemEntityModel>(model);
                    if (commonEntity !is null) {
                        string entityDetail = itemDetail
                            + " spawnLoc " + CrystalVec3Label(vec3(commonEntity.SpawnLoc.tx, commonEntity.SpawnLoc.ty, commonEntity.SpawnLoc.tz))
                            + " parentShapeSpace " + CRYSTAL_SHAPE_SPACE_PREFAB_CHILD;
                        auto probe = AddCrystalSurfaceProbe(
                            source,
                            "Item",
                            objectIndex,
                            ownerName,
                            modelSlot + ".CGameCommonItemEntityModel.TriggerShape",
                            commonEntity.TriggerShape,
                            entityDetail
                        );
                        if (probe !is null) {
                            found = true;
                            auto transformResult = CrystalShapeTransformResult();
                            ResolveCrystalCommonEntityShapeTransform(
                                commonEntity,
                                probe,
                                modelTransform,
                                "prefab child",
                                CRYSTAL_SHAPE_SPACE_PREFAB_CHILD,
                                CrystalItemIsWaypointLike(itemModel),
                                transformResult
                            );
                            CrystalApplyShapeTransformResultToProbe(probe, transformResult);
                            string commonTargetKeys = AddCrystalSurfaceGameplayTargetKeys(
                                GetCrystalItemTargetKeys(itemModel),
                                commonEntity.TriggerShape
                            );
                            TryAddCrystalVolumeFromProbe(
                                source,
                                probe,
                                transformResult.Transform,
                                commonTargetKeys
                            );
                        }
                    }

                    auto gate = cast<CGameGateModel>(model);
                    if (gate !is null) {
                        ProbeCrystalItemGateModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            gate,
                            modelSlot,
                            itemDetail,
                            modelTransform
                        );
                        found = true;
                    }

                    auto teleporter = cast<CGameTeleporterModel>(model);
                    if (teleporter !is null) {
                        ProbeCrystalItemTeleporterModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            teleporter,
                            modelSlot,
                            itemDetail,
                            modelTransform
                        );
                        found = true;
                    }

                    auto nestedPrefab = cast<CPlugPrefab>(model);
                    if (nestedPrefab !is null) {
                        found = ProbeCrystalPrefabModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            nestedPrefab,
                            modelSlot + ".CPlugPrefab",
                            itemDetail,
                            modelTransform,
                            depth
                        ) || found;
                    }

                    return found;
                }

                void ProbeCrystalItemEntityModel(
                    TriggerSourceSnapshot@ source,
                    uint objectIndex,
                    const string &in ownerName,
                    CGameItemModel@ itemModel,
                    CGameCtnCollection@ collection,
                    const string &in placementDetail,
                    const mat4 &in itemTransform,
                    uint itemVariantIndex
                ) {
                    if (source is null || itemModel is null) return;

                    auto entityModelEdition = cast<CGameCommonItemEntityModelEdition>(itemModel.EntityModelEdition);
                    auto blockItem = cast<CGameBlockItem>(itemModel.EntityModelEdition);
                    bool isBlockLikeEdition = CrystalItemEditionIsBlockLike(entityModelEdition, blockItem);
                    string itemDetail = placementDetail
                        + " editionBlockLike " + CrystalBoolLabel(isBlockLikeEdition)
                        + " start " + CrystalBoolLabel(itemModel.IsStart)
                        + " checkpoint " + CrystalBoolLabel(itemModel.IsCheckpoint)
                        + " finish " + CrystalBoolLabel(itemModel.IsFinish)
                        + " startFinish " + CrystalBoolLabel(itemModel.IsStartFinish);
                    bool isWaypointLikeItem = CrystalItemIsWaypointLike(itemModel);
                    auto waypointTrigger = cast<NPlugTrigger_SWaypoint>(itemModel.EntityModel);
                    if (waypointTrigger !is null) {
                        string waypointDetail = itemDetail
                            + " waypointType " + tostring(waypointTrigger.Type)
                            + " noRespawn " + CrystalBoolLabel(waypointTrigger.NoRespawn);
                        auto probe = AddCrystalSurfaceProbe(
                            source,
                            "Item",
                            objectIndex,
                            ownerName,
                            "NPlugTrigger_SWaypoint.TriggerShape",
                            waypointTrigger.TriggerShape,
                            waypointDetail
                        );
                        if (probe !is null) {
                            string waypointTargetKeys = AddCrystalSurfaceGameplayTargetKeys(
                                GetCrystalWaypointTriggerTargetKeys(waypointTrigger, itemModel),
                                waypointTrigger.TriggerShape
                            );
                            TryAddCrystalVolumeFromProbe(
                                source,
                                probe,
                                itemTransform,
                                waypointTargetKeys
                            );
                        }
                    }

                    auto specialTrigger = cast<NPlugTrigger_SSpecial>(itemModel.EntityModel);
                    if (specialTrigger !is null) {
                        ProbeCrystalSpecialTriggerModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            specialTrigger,
                            "",
                            itemDetail,
                            itemTransform
                        );
                    }

                    auto entityModel = cast<CGameCommonItemEntityModel>(itemModel.EntityModel);
                    if (entityModel !is null) {
                        string entityDetail = itemDetail
                            + " spawnLoc " + CrystalVec3Label(vec3(entityModel.SpawnLoc.tx, entityModel.SpawnLoc.ty, entityModel.SpawnLoc.tz))
                            + " parentShapeSpace " + CRYSTAL_SHAPE_SPACE_ITEM_LOCAL;
                        mat4 entityChildTransform = itemTransform;
                        bool hasEntityChildTransform = false;
                        auto probe = AddCrystalSurfaceProbe(
                            source,
                            "Item",
                            objectIndex,
                            ownerName,
                            "EntityModel.TriggerShape",
                            entityModel.TriggerShape,
                            entityDetail
                        );
                        if (probe !is null) {
                            auto transformResult = CrystalShapeTransformResult();
                            ResolveCrystalCommonEntityShapeTransform(
                                entityModel,
                                probe,
                                itemTransform,
                                "item placement",
                                CRYSTAL_SHAPE_SPACE_ITEM_LOCAL,
                                isBlockLikeEdition || isWaypointLikeItem,
                                transformResult
                            );
                            CrystalApplyShapeTransformResultToProbe(probe, transformResult);
                            entityChildTransform = transformResult.Transform;
                            hasEntityChildTransform = true;
                            string entityTargetKeys = AddCrystalSurfaceGameplayTargetKeys(
                                GetCrystalItemTargetKeys(itemModel),
                                entityModel.TriggerShape
                            );
                            TryAddCrystalVolumeFromProbe(
                                source,
                                probe,
                                transformResult.Transform,
                                entityTargetKeys
                            );
                        }
                        if (!hasEntityChildTransform) {
                            auto transformResult = CrystalShapeTransformResult();
                            ResolveCrystalCommonEntityShapeTransform(
                                entityModel,
                                null,
                                itemTransform,
                                "item placement",
                                CRYSTAL_SHAPE_SPACE_ITEM_LOCAL,
                                false,
                                transformResult
                            );
                            entityChildTransform = transformResult.Transform;
                        }
                        if (entityModel.PhyModel !is null && entityModel.PhyModel !is itemModel.PhyModel) {
                            ProbeCrystalPrefabTriggerModel(
                                source,
                                objectIndex,
                                ownerName,
                                itemModel,
                                collection,
                                entityModel.PhyModel,
                                "EntityModel.PhyModel",
                                itemDetail + " triggerShapeSpace entity-phy",
                                entityChildTransform
                            );
                        }
                    }

                    auto prefab = cast<CPlugPrefab>(itemModel.EntityModel);
                    auto variantList = cast<NPlugItem_SVariantList>(itemModel.EntityModel);
                    bool foundVariantListTrigger = false;
                    if (variantList !is null) {
                        foundVariantListTrigger = ProbeCrystalItemVariantListModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            variantList,
                            itemVariantIndex,
                            "EntityModel",
                            itemDetail + " triggerShapeSpace variant-list",
                            itemTransform
                        );
                    }
                    bool foundPrefabTrigger = false;
                    if (prefab !is null) {
                        foundPrefabTrigger = ProbeCrystalPrefabModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            prefab,
                            "EntityModel.CPlugPrefab",
                            itemDetail + " triggerShapeSpace prefab",
                            itemTransform
                        );
                    }
                    if (itemModel.EntityModel !is null && waypointTrigger is null && specialTrigger is null && entityModel is null && prefab is null && variantList is null && cast<CGameGateModel>(itemModel.EntityModel) is null && cast<CGameTeleporterModel>(itemModel.EntityModel) is null) {
                        AddCrystalDiagnostic(
                            source,
                            "Item " + ownerName + " EntityModel is " + GetCrystalNodTypeName(itemModel.EntityModel) + ", not CGameCommonItemEntityModel."
                        );
                    } else if (prefab !is null && !foundPrefabTrigger) {
                        AddCrystalDiagnostic(
                            source,
                            "Item " + ownerName + " EntityModel CPlugPrefab had no public trigger model entries."
                        );
                    } else if (variantList !is null && !foundVariantListTrigger) {
                        AddCrystalDiagnostic(
                            source,
                            "Item " + ownerName + " EntityModel NPlugItem_SVariantList had no public trigger model entries for selected variant."
                        );
                    }
                    if (entityModelEdition !is null) {
                        string editionDetail = itemDetail
                            + " itemType " + tostring(entityModelEdition.ItemType)
                            + " editionTriggers " + tostring(entityModelEdition.Triggers.Length)
                            + " triggeredActions " + tostring(entityModelEdition.TriggeredActions.Length);
                        if (entityModelEdition.MeshCrystal !is null) {
                            editionDetail += " meshCrystal v/e/f "
                                + tostring(entityModelEdition.MeshCrystal.CrystalVertexCount)
                                + "/"
                                + tostring(entityModelEdition.MeshCrystal.CrystalEdgeCount)
                                + "/"
                                + tostring(entityModelEdition.MeshCrystal.CrystalFaceCount);
                        }
                        AddCrystalDiagnostic(
                            source,
                            "Item " + ownerName + " edition: " + editionDetail
                        );
                    }
                    if (blockItem !is null) {
                        ProbeCrystalBlockItemTriggerShapes(
                            source,
                            objectIndex,
                            ownerName,
                            blockItem,
                            itemDetail,
                            itemTransform,
                            GetCrystalBlockItemTargetKeys(itemModel)
                        );
                    }

                    auto entityGate = cast<CGameGateModel>(itemModel.EntityModel);
                    if (entityGate !is null) {
                        ProbeCrystalItemGateModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            entityGate,
                            "EntityModel",
                            itemDetail,
                            itemTransform
                        );
                    }

                    auto editionGate = cast<CGameGateModel>(itemModel.EntityModelEdition);
                    if (editionGate !is null && editionGate !is entityGate) {
                        ProbeCrystalItemGateModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            editionGate,
                            "EntityModelEdition",
                            itemDetail,
                            itemTransform
                        );
                    }

                    auto phyGate = cast<CGameGateModel>(itemModel.PhyModel);
                    if (phyGate !is null && phyGate !is entityGate && phyGate !is editionGate) {
                        ProbeCrystalItemGateModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            phyGate,
                            "PhyModel",
                            itemDetail,
                            itemTransform
                        );
                    }

                    auto entityTeleporter = cast<CGameTeleporterModel>(itemModel.EntityModel);
                    if (entityTeleporter !is null) {
                        ProbeCrystalItemTeleporterModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            entityTeleporter,
                            "EntityModel",
                            itemDetail,
                            itemTransform
                        );
                    }

                    auto editionTeleporter = cast<CGameTeleporterModel>(itemModel.EntityModelEdition);
                    if (editionTeleporter !is null && editionTeleporter !is entityTeleporter) {
                        ProbeCrystalItemTeleporterModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            editionTeleporter,
                            "EntityModelEdition",
                            itemDetail,
                            itemTransform
                        );
                    }

                    auto phyTeleporter = cast<CGameTeleporterModel>(itemModel.PhyModel);
                    if (phyTeleporter !is null && phyTeleporter !is entityTeleporter && phyTeleporter !is editionTeleporter) {
                        ProbeCrystalItemTeleporterModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            phyTeleporter,
                            "PhyModel",
                            itemDetail,
                            itemTransform
                        );
                    }
                    if (itemModel.PhyModel !is null && phyGate is null && phyTeleporter is null && cast<CGameObjectPhyModel>(itemModel.PhyModel) is null) {
                        ProbeCrystalPrefabTriggerModel(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            collection,
                            itemModel.PhyModel,
                            "PhyModel",
                            itemDetail + " triggerShapeSpace phy",
                            itemTransform
                        );
                    }

                    auto phyModel = cast<CGameObjectPhyModel>(itemModel.PhyModel);
                    if (phyModel !is null) {
                        ProbeCrystalItemPhyModelTriggerShape(
                            source,
                            objectIndex,
                            ownerName,
                            itemModel,
                            phyModel,
                            "PhyModel",
                            itemDetail + " triggerShapeSpace phy",
                            itemTransform
                        );
                    }
                }

                void ProbeCrystalAnchoredObjectAt(
                    TriggerSourceSnapshot@ source,
                    CGameCtnChallenge@ map,
                    uint objectIndex,
                    bool customOnly = false
                ) {
                    if (source is null || map is null || objectIndex >= map.AnchoredObjects.Length) return;

                    auto anchoredObject = map.AnchoredObjects[objectIndex];
                    if (anchoredObject is null) {
                        AddCrystalDiagnostic(
                            source,
                            "AnchoredObject #" + tostring(objectIndex) + " is null."
                        );
                        return;
                    }

                    auto itemModel = anchoredObject.ItemModel;
                    string ownerName = GetCrystalItemModelName(
                        itemModel,
                        objectIndex
                    ) + " @" + CrystalVec3Label(anchoredObject.AbsolutePositionInMap);
                    if (itemModel is null) {
                        AddCrystalDiagnostic(
                            source,
                            "AnchoredObject #" + tostring(objectIndex) + " has no ItemModel."
                        );
                        return;
                    }
                    if (customOnly && !CrystalItemModelLooksCustomContent(itemModel)) {
                        return;
                    }

                    string placementDetail = "pos " + CrystalVec3Label(anchoredObject.AbsolutePositionInMap)
                        + " blockUnit " + anchoredObject.BlockUnitCoord.ToString()
                        + " variant " + tostring(anchoredObject.IVariant)
                        + " yaw/pitch/roll "
                        + Text::Format("%.3f", anchoredObject.Yaw)
                        + "/"
                        + Text::Format("%.3f", anchoredObject.Pitch)
                        + "/"
                        + Text::Format("%.3f", anchoredObject.Roll)
                        + " scale " + Text::Format("%.3f", anchoredObject.Scale);
                    string transformSource = "";
                    mat4 itemTransform = GetCrystalAnchoredObjectTransform(anchoredObject, transformSource);
                    placementDetail += " transform " + transformSource;
                    ProbeCrystalItemEntityModel(
                        source,
                        objectIndex,
                        ownerName,
                        itemModel,
                        map.Collection,
                        placementDetail,
                        itemTransform,
                        anchoredObject.IVariant
                    );
                }

                bool ProbeCrystalAnchoredObjectsWithProgress(
                    TriggerSourceSnapshot@ source,
                    CGameCtnChallenge@ map,
                    const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                    const string &in contextKey,
                    uint blockCount,
                    uint bakedBlockCount,
                    uint anchoredObjectCount,
                    uint cacheVersion,
                    bool customOnly = false
                ) {
                    if (source is null || map is null) return true;

                    source.RawAnchoredObjectCount = map.AnchoredObjects.Length;
                    uint frameStart = Time::Now;
                    for (uint i = 0; i < map.AnchoredObjects.Length; i++) {
                        ProbeCrystalAnchoredObjectAt(source, map, i, customOnly);
                        frameStart = CrystalSourceBuildCheckpoint(frameStart);
                        if (!TriggerVisualizer::Trigger::PublishCrystalSourceBuildProgressIfDue(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, source)) return false;
                    }
                    return true;
                }

                void ProbeCrystalAnchoredObjects(
                    TriggerSourceSnapshot@ source,
                    CGameCtnChallenge@ map,
                    bool customOnly = false
                ) {
                    ProbeCrystalAnchoredObjectsWithProgress(source, map, null, "", 0, 0, 0, 0, customOnly);
                }
            }
        }
    }
}
