namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                void ProbeCrystalBlockVariant(
                    TriggerSourceSnapshot@ source,
                    CGameCtnChallenge@ map,
                    CGameCtnBlock@ block,
                    uint blockIndex,
                    const string &in ownerKind
                ) {
                    if (source is null || block is null) return;

                    auto variant = GetCrystalBlockVariantWithBaseFallback(block);
                    string ownerName = GetCrystalBlockName(block, blockIndex);
                    string detail = "coord " + block.Coord.ToString()
                        + " ground " + CrystalBoolLabel(block.IsGround)
                        + " variant " + tostring(block.BlockInfoVariantIndex)
                        + " mobil " + tostring(block.MobilIndex)
                        + " mobilVariant " + tostring(block.MobilVariantIndex);

                    if (block.BlockInfo is null) {
                        AddCrystalDiagnostic(
                            source,
                            ownerKind + " #" + tostring(blockIndex) + " has no BlockInfo."
                        );
                        return;
                    }

                    if (variant is null) {
                        AddCrystalDiagnostic(
                            source,
                            ownerKind + " " + ownerName + " has no selected block variant."
                        );
                        return;
                    }

                    mat4 blockTransform;
                    string transformDetail = "";
                    string transformWarning = "";
                    bool canRender = TryGetCrystalPlacedBlockTransform(
                        map,
                        block,
                        variant,
                        blockTransform,
                        transformDetail,
                        transformWarning
                    );
                    if (transformDetail.Length > 0) {
                        detail += " " + transformDetail;
                    } else if (transformWarning.Length > 0) {
                        detail += " transform skipped: " + transformWarning;
                    }
                    ProbeCrystalBlockSurface(
                        source,
                        block,
                        variant,
                        blockIndex,
                        ownerKind,
                        ownerName,
                        "WaypointTriggerShape",
                        variant.WaypointTriggerShape,
                        detail,
                        canRender,
                        blockTransform,
                        transformWarning
                    );
                    ProbeCrystalBlockSurface(
                        source,
                        block,
                        variant,
                        blockIndex,
                        ownerKind,
                        ownerName,
                        "ScreenInteractionTriggerShape",
                        variant.ScreenInteractionTriggerShape,
                        detail,
                        canRender,
                        blockTransform,
                        transformWarning
                    );
                    if (variant.Gate !is null) {
                        ProbeCrystalBlockSurface(
                            source,
                            block,
                            variant,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            "Gate.Shape",
                            variant.Gate.Shape,
                            detail,
                            canRender,
                            blockTransform,
                            transformWarning
                        );
                    }
                    if (variant.Teleporter !is null) {
                        ProbeCrystalBlockSurface(
                            source,
                            block,
                            variant,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            "Teleporter.TriggerShape",
                            variant.Teleporter.TriggerShape,
                            detail,
                            canRender,
                            blockTransform,
                            transformWarning
                        );
                    }
                    if (variant.WaypointTriggerShape is null) {
                        ProbeCrystalBlockDeprecatedTriggerNod(
                            source,
                            block,
                            variant,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            detail,
                            "DeprecWaypointTriggerSolid",
                            variant.DeprecWaypointTriggerSolid,
                            canRender,
                            blockTransform,
                            transformWarning
                        );
                    }
                    if (variant.ScreenInteractionTriggerShape is null) {
                        ProbeCrystalBlockDeprecatedTriggerNod(
                            source,
                            block,
                            variant,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            detail,
                            "DeprecScreenInteractionTriggerSolid",
                            variant.DeprecScreenInteractionTriggerSolid,
                            canRender,
                            blockTransform,
                            transformWarning
                        );
                    }
                    bool skipExpandableMobilGeometry = CrystalShouldSkipExpandableMobilGeometry(
                        block,
                        variant
                    );
                    if (!skipExpandableMobilGeometry) {
                        ProbeCrystalBlockMobilTriggerSurfaces(
                            source,
                            block,
                            variant,
                            blockIndex,
                            ownerKind,
                            ownerName,
                            detail,
                            canRender,
                            blockTransform,
                            transformWarning
                        );
                    }
                }

                bool CrystalBlockVariantHasEarlyTriggerSurface(CGameCtnBlockInfoVariant@ variant) {
                    if (variant is null) return false;
                    if (variant.WaypointTriggerShape !is null) return true;
                    if (variant.ScreenInteractionTriggerShape !is null) return true;
                    if (variant.Gate !is null && variant.Gate.Shape !is null) return true;
                    if (variant.Teleporter !is null && variant.Teleporter.TriggerShape !is null) return true;
                    if (variant.WaypointTriggerShape is null && variant.DeprecWaypointTriggerSolid !is null) return true;
                    if (variant.ScreenInteractionTriggerShape is null && variant.DeprecScreenInteractionTriggerSolid !is null) return true;
                    return false;
                }

                bool CrystalBlockShouldProbeEarly(CGameCtnBlock@ block) {
                    if (block is null) return false;
                    return CrystalBlockVariantHasEarlyTriggerSurface(GetCrystalBlockVariantWithBaseFallback(block));
                }

                bool CrystalBlockShouldProbeForCustomOnly(CGameCtnBlock@ block, bool customOnly) {
                    if (!customOnly) return true;
                    return block !is null
                        && block.BlockInfo !is null
                        && CrystalCollectorLooksCustomContent(block.BlockInfo);
                }

                bool ProbeCrystalBlocksWithProgress(
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

                    source.RawBlockCount = map.Blocks.Length;
                    source.RawBakedBlockCount = map.BakedBlocks.Length;
                    uint frameStart = Time::Now;

                    for (uint i = 0; i < map.Blocks.Length; i++) {
                        if (!CrystalBlockShouldProbeForCustomOnly(map.Blocks[i], customOnly)) continue;
                        if (!CrystalBlockShouldProbeEarly(map.Blocks[i])) continue;
                        ProbeCrystalBlockVariant(source, map, map.Blocks[i], i, "Block");
                        frameStart = CrystalSourceBuildCheckpoint(frameStart);
                        if (!TriggerVisualizer::Trigger::PublishCrystalSourceBuildProgressIfDue(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, source)) return false;
                    }
                    for (uint i = 0; i < map.BakedBlocks.Length; i++) {
                        if (!CrystalBlockShouldProbeForCustomOnly(map.BakedBlocks[i], customOnly)) continue;
                        if (!CrystalBlockShouldProbeEarly(map.BakedBlocks[i])) continue;
                        ProbeCrystalBlockVariant(source, map, map.BakedBlocks[i], i, "BakedBlock");
                        frameStart = CrystalSourceBuildCheckpoint(frameStart);
                        if (!TriggerVisualizer::Trigger::PublishCrystalSourceBuildProgressIfDue(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, source)) return false;
                    }
                    if (!TriggerVisualizer::Trigger::PublishCrystalSourceBuildProgressIfDue(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, source, true)) return false;
                    for (uint i = 0; i < map.Blocks.Length; i++) {
                        if (!CrystalBlockShouldProbeForCustomOnly(map.Blocks[i], customOnly)) continue;
                        if (CrystalBlockShouldProbeEarly(map.Blocks[i])) continue;
                        ProbeCrystalBlockVariant(source, map, map.Blocks[i], i, "Block");
                        frameStart = CrystalSourceBuildCheckpoint(frameStart);
                        if (!TriggerVisualizer::Trigger::PublishCrystalSourceBuildProgressIfDue(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, source)) return false;
                    }
                    for (uint i = 0; i < map.BakedBlocks.Length; i++) {
                        if (!CrystalBlockShouldProbeForCustomOnly(map.BakedBlocks[i], customOnly)) continue;
                        if (CrystalBlockShouldProbeEarly(map.BakedBlocks[i])) continue;
                        ProbeCrystalBlockVariant(source, map, map.BakedBlocks[i], i, "BakedBlock");
                        frameStart = CrystalSourceBuildCheckpoint(frameStart);
                        if (!TriggerVisualizer::Trigger::PublishCrystalSourceBuildProgressIfDue(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, source)) return false;
                    }
                    return true;
                }

                void ProbeCrystalBlocks(
                    TriggerSourceSnapshot@ source,
                    CGameCtnChallenge@ map,
                    bool customOnly = false
                ) {
                    ProbeCrystalBlocksWithProgress(source, map, null, "", 0, 0, 0, 0, customOnly);
                }
            }
        }
    }
}
