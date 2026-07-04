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
                    bool useExpandableScriptClipGeometryOnly = CrystalShouldUseExpandableScriptClipGeometryOnly(
                        block,
                        variant
                    );
                    if (!useExpandableScriptClipGeometryOnly) {
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

                void ProbeCrystalBlocks(TriggerSourceSnapshot@ source, CGameCtnChallenge@ map) {
                    if (source is null || map is null) return;

                    source.RawBlockCount = map.Blocks.Length;
                    source.RawBakedBlockCount = map.BakedBlocks.Length;
                    uint frameStart = Time::Now;

                    for (uint i = 0; i < map.Blocks.Length; i++) {
                        ProbeCrystalBlockVariant(source, map, map.Blocks[i], i, "Block");
                        frameStart = CrystalSourceBuildCheckpoint(frameStart);
                    }
                    for (uint i = 0; i < map.BakedBlocks.Length; i++) {
                        ProbeCrystalBlockVariant(source, map, map.BakedBlocks[i], i, "BakedBlock");
                        frameStart = CrystalSourceBuildCheckpoint(frameStart);
                    }
                }
            }
        }
    }
}
