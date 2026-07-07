namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                uint CountCrystalExpandableVolumes(const TriggerSourceSnapshot@ source) {
                    if (source is null) return 0;

                    uint count = 0;
                    for (uint i = 0; i < source.TriggerVolumes.Length; i++) {
                        auto volume = source.TriggerVolumes[i];
                        if (volume is null) continue;
                        if (volume.DetectedLabel.StartsWith("ExpandableRectangle.") || volume.Label.StartsWith("Expandable Crystal ")) {
                            count++;
                        }
                    }
                    return count;
                }

                void AddCrystalFinalCountsDiagnostic(TriggerSourceSnapshot@ source) {
                    if (source is null) return;
                    uint expandableVolumeCount = CountCrystalExpandableVolumes(source);
                    string countsDiagnostic = "Counts: blocks " + tostring(source.RawBlockCount) + ", baked blocks " + tostring(source.RawBakedBlockCount) + ", anchored objects " + tostring(source.RawAnchoredObjectCount) + ", candidate shapes " + tostring(source.CandidateShapeCount) + ", readable shapes " + tostring(source.ReadableShapeCount) + ", unsupported/null shapes " + tostring(source.UnsupportedShapeCount) + ", rendered shapes " + tostring(source.RenderedShapeCount) + ", rejected shapes " + tostring(source.RejectedShapeCount) + ", trigger volumes " + tostring(source.TriggerVolumeCount()) + ", expandable volumes " + tostring(expandableVolumeCount);
                    AddCrystalDiagnostic(
                        source,
                        countsDiagnostic
                    );
                }

                const uint CRYSTAL_SOURCE_BUILD_FRAME_BUDGET_MS = 4;

                uint CrystalSourceBuildCheckpoint(uint frameStart) {
                    if (Time::Now - frameStart < CRYSTAL_SOURCE_BUILD_FRAME_BUDGET_MS) return frameStart;
                    yield();
                    return Time::Now;
                }

                TriggerSourceSnapshot@ CreateCrystalTriggerSourceShell(
                    const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                    bool enabled
                ) {
                    auto source = TriggerSourceSnapshot(TRIGGER_SOURCE_CRYSTAL, enabled);
                    AddCrystalDiagnostic(
                        source,
                        "Crystal source: public crystal/item/block trigger shapes are inspected; finite validated bounds drive culling/labels and copied surface outlines drive Crystal rendering when available."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "Placed block trigger transforms use public Coord/Dir/variant-size, calibrated native block-grid Y anchors, and variant CompoundLoc data; free blocks use their saved private world position/rotation."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "Placed block trigger surfaces use public CGameCtnBlockInfoMobil geometry transforms when the surface is stored on a mobil; named wall checkpoint blocks still have the narrow local fallback path."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "Placed block mobil SurfaceFromBlockItem trigger surfaces are probed directly when they are not already exposed through the selected variant waypoint, screen, gate, or teleporter fields."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "Placed block mobil CGameObjectModel.Phy.TriggerShape DataRefs are resolved through Fids::Preload and probed with the same public mobil geometry transforms."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "Placed block deprecated variant trigger nods are probed only when the normal waypoint/screen surface slot is empty, and only when the nod itself exposes a real CPlugSurface or public trigger model."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "GateExpandableSpecial* areas use one approximate local rectangle per matching block from public Coord/Dir/variant-size placement plus MaterialModifier target metadata. Other expandable Crystal blocks use the normal block/item trigger discovery paths."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "Block-item trigger shapes use public BlockInfoMobilSkins spawn transforms when the indexed transform buffers are complete and finite."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "Placed item transforms use public anchored-object placement; AbsolutePositionInMap fallback placement is corrected by the saved placed-item pivot, then finite item GroundPoint/default pivot anchors, and NPlugItem_SVariantList uses the placed object variant index before trigger probing."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "Crystal trigger shape transforms are resolved through explicit shape-space labels: item-local, block-local, prefab-child, mobil-child, centered-block-local, and helper-template."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "Direct and prefab NPlugTrigger waypoint/special item models are rendered when their public TriggerShape is exposed."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "Common item entity TriggerShape uses its public surface bounds in the parent shape space; SpawnLoc is recorded as waypoint metadata, not applied as trigger geometry."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "Item CGameGateModel Shape and CGameTeleporterModel TriggerShape are rendered when exposed through EntityModel, EntityModelEdition, PhyModel, or prefab entries."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "Runtime NGameWaypoint_STrigger is not used for geometry: local docs expose no public bounds or surface members."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "Performance: full crystal probing is cached per RootMap/context and periodically refreshed only in the Mesh Modeler when enabled in Performance > Refresh."
                    );

                    if (ctx is null) {
                        AddCrystalDiagnostic(
                            source,
                            "No runtime context."
                        );
                        return source;
                    }

                    AddCrystalDiagnostic(
                        source,
                        "Runtime: " + ctx.StateLabel() + " | has RootMap " + CrystalBoolLabel(ctx.HasMap)
                    );

                    if (!ctx.HasMap || ctx.RootMap is null) {
                        AddCrystalDiagnostic(
                            source,
                            "No RootMap; crystal source stays inactive."
                        );
                        return source;
                    }

                    if (!enabled) {
                        AddCrystalDiagnostic(
                            source,
                            "Crystal source disabled for this source profile; probe skipped."
                        );
                        return source;
                    }

                    return source;
                }

                TriggerSourceSnapshot@ ReadCrystalTriggerSource(
                    const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                    bool enabled
                ) {
                    auto source = CreateCrystalTriggerSourceShell(ctx, enabled);
                    if (ctx is null || !ctx.HasMap || ctx.RootMap is null || !enabled) return source;

                    uint frameStart = Time::Now;
                    ProbeCrystalExpandableBlockUnitTriggers(source, ctx.RootMap);
                    frameStart = CrystalSourceBuildCheckpoint(frameStart);
                    ProbeCrystalBlocks(source, ctx.RootMap);
                    frameStart = CrystalSourceBuildCheckpoint(frameStart);
                    ProbeCrystalAnchoredObjects(source, ctx.RootMap);
                    frameStart = CrystalSourceBuildCheckpoint(frameStart);
                    AddCrystalFinalCountsDiagnostic(source);

                    return source;
                }
            }
        }
    }
}
