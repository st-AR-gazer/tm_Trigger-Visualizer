namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                const float CRYSTAL_EXPANDABLE_FINISH_CONNECT_GAP_EPSILON = 4.0f;

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

                bool CrystalVolumeIsRealExpandableFinishWaypoint(const TriggerVolume@ volume) {
                    if (volume is null || volume.Source != TRIGGER_SOURCE_CRYSTAL) return false;
                    if (volume.IsMergedGroup || volume.HasChildVolumes()) return false;
                    if (volume.SubtypeKey != CRYSTAL_SUBTYPE_BLOCK_WAYPOINT) return false;
                    if (!TriggerTargetListContains(volume.TargetKeys, TRIGGER_TYPE_FINISH) && !TriggerTargetListContains(volume.TargetKeys, TRIGGER_TYPE_MULTILAP)) {
                        return false;
                    }

                    string detected = volume.DetectedLabel.ToLower();
                    bool isWaypointShape = detected.IndexOf("waypointtriggershape") >= 0
                        || detected.IndexOf("nplugtrigger_swaypoint") >= 0
                        || detected.IndexOf("deprecwaypointtriggersolid") >= 0
                        || detected.StartsWith("expandablefinish.");
                    if (!isWaypointShape) return false;

                    string label = NormalizeCrystalTriggerTypeSearchText(volume.Label);
                    return label.IndexOf("expandable") >= 0
                        && label.IndexOf("finish") >= 0;
                }

                void ClearCrystalExpandableFinishMergeOutline(TriggerVolume@ volume) {
                    if (volume is null) return;
                    volume.OutlineShapeKind = "";
                    volume.OutlineLineStarts.Resize(0);
                    volume.OutlineLineEnds.Resize(0);
                }

                float CrystalExpandableFinishAxisMin(const TriggerVolume@ volume, int axis) {
                    if (volume is null) return 0.0f;
                    if (axis == 0) return volume.Min.x;
                    if (axis == 1) return volume.Min.y;
                    return volume.Min.z;
                }

                float CrystalExpandableFinishAxisMax(const TriggerVolume@ volume, int axis) {
                    if (volume is null) return 0.0f;
                    if (axis == 0) return volume.Max.x;
                    if (axis == 1) return volume.Max.y;
                    return volume.Max.z;
                }

                void SetCrystalExpandableFinishAxisMin(TriggerVolume@ volume, int axis, float value) {
                    if (volume is null) return;
                    vec3 next = volume.Min;
                    if (axis == 0) {
                        next.x = value;
                    } else if (axis == 1) {
                        next.y = value;
                    } else {
                        next.z = value;
                    }
                    volume.Min = next;
                }

                void SetCrystalExpandableFinishAxisMax(TriggerVolume@ volume, int axis, float value) {
                    if (volume is null) return;
                    vec3 next = volume.Max;
                    if (axis == 0) {
                        next.x = value;
                    } else if (axis == 1) {
                        next.y = value;
                    } else {
                        next.z = value;
                    }
                    volume.Max = next;
                }

                bool CrystalExpandableFinishVolumesOverlapOnOtherAxes(
                    const TriggerVolume@ a,
                    const TriggerVolume@ b,
                    int axis
                ) {
                    for (int otherAxis = 0; otherAxis < 3; otherAxis++) {
                        if (otherAxis == axis) continue;
                        if (!TriggerVisualizer::Trigger::Data::IntervalsOverlapWithArea(CrystalExpandableFinishAxisMin(a, otherAxis), CrystalExpandableFinishAxisMax(a, otherAxis), CrystalExpandableFinishAxisMin(b, otherAxis), CrystalExpandableFinishAxisMax(b, otherAxis))) {
                            return false;
                        }
                    }
                    return true;
                }

                bool CloseCrystalExpandableFinishGapOnAxis(TriggerVolume@ a, TriggerVolume@ b, int axis) {
                    if (a is null || b is null) return false;
                    if (!TriggerVisualizer::Trigger::Data::TriggerVolumesHaveCompatibleMergeMetadata(a, b)) return false;
                    if (!CrystalExpandableFinishVolumesOverlapOnOtherAxes(a, b, axis)) return false;

                    float aMin = CrystalExpandableFinishAxisMin(a, axis);
                    float aMax = CrystalExpandableFinishAxisMax(a, axis);
                    float bMin = CrystalExpandableFinishAxisMin(b, axis);
                    float bMax = CrystalExpandableFinishAxisMax(b, axis);
                    if (aMax < bMin) {
                        float gap = bMin - aMax;
                        if (gap <= 0.0f || gap > CRYSTAL_EXPANDABLE_FINISH_CONNECT_GAP_EPSILON) return false;

                        float seam = (aMax + bMin) * 0.5f;
                        SetCrystalExpandableFinishAxisMax(a, axis, seam);
                        SetCrystalExpandableFinishAxisMin(b, axis, seam);
                        ClearCrystalExpandableFinishMergeOutline(a);
                        ClearCrystalExpandableFinishMergeOutline(b);
                        return true;
                    }

                    if (bMax < aMin) {
                        float gap = aMin - bMax;
                        if (gap <= 0.0f || gap > CRYSTAL_EXPANDABLE_FINISH_CONNECT_GAP_EPSILON) return false;

                        float seam = (bMax + aMin) * 0.5f;
                        SetCrystalExpandableFinishAxisMax(b, axis, seam);
                        SetCrystalExpandableFinishAxisMin(a, axis, seam);
                        ClearCrystalExpandableFinishMergeOutline(a);
                        ClearCrystalExpandableFinishMergeOutline(b);
                        return true;
                    }

                    return false;
                }

                uint CloseCrystalExpandableFinishVisualGaps(array<TriggerVolume@> @volumes) {
                    if (volumes is null || volumes.Length <= 1) return 0;

                    uint closed = 0;
                    for (uint i = 0; i < volumes.Length; i++) {
                        for (uint j = i + 1; j < volumes.Length; j++) {
                            for (int axis = 0; axis < 3; axis++) {
                                if (CloseCrystalExpandableFinishGapOnAxis(volumes[i], volumes[j], axis)) {
                                    closed++;
                                }
                            }
                        }
                    }
                    return closed;
                }

                string CrystalExpandableFinishMergeLabel(const string &in targetKeys) {
                    if (TriggerTargetListContains(targetKeys, TRIGGER_TYPE_MULTILAP)) {
                        return "Expandable Crystal Start/Finish";
                    }
                    return "Expandable Crystal Finish";
                }

                TriggerVolume@ CloneCrystalExpandableFinishVolumeForMerge(const TriggerVolume@ volume) {
                    auto copy = TriggerVisualizer::Trigger::Data::CloneTriggerVolumeForMerge(volume);
                    copy.SourceIndex = 0;
                    copy.Label = CrystalExpandableFinishMergeLabel(copy.TargetKeys);
                    copy.DetectedLabel = "ExpandableFinish.WaypointArea";
                    copy.SubtypeKey = CRYSTAL_SUBTYPE_BLOCK_WAYPOINT;
                    copy.SubtypeLabel = "Crystal Block Waypoint";
                    copy.AllowRawRangeLabel = false;
                    copy.HasIslandIndex = false;
                    return copy;
                }

                bool CrystalVolumeIsExpandableRectangleVolume(const TriggerVolume@ volume) {
                    if (volume is null || volume.Source != TRIGGER_SOURCE_CRYSTAL) return false;
                    return volume.DetectedLabel.StartsWith("ExpandableRectangle.");
                }

                bool CrystalVolumeIsExpandableFinishVolume(const TriggerVolume@ volume) {
                    if (volume is null || volume.Source != TRIGGER_SOURCE_CRYSTAL) return false;
                    return volume.DetectedLabel.StartsWith("ExpandableFinish.")
                        || CrystalVolumeIsRealExpandableFinishWaypoint(volume);
                }

                bool CrystalVolumeIsExpandableMergeViewVolume(const TriggerVolume@ volume) {
                    if (volume is null || volume.Source != TRIGGER_SOURCE_CRYSTAL) return false;
                    return CrystalVolumeIsExpandableRectangleVolume(volume)
                        || CrystalVolumeIsExpandableFinishVolume(volume)
                        || volume.Label.StartsWith("Expandable Crystal ");
                }

                string CrystalExpandableMergeSourceVolumeKey(const TriggerVolume@ volume) {
                    if (volume is null) return "";
                    return volume.DetectedLabel
                        + "|" + volume.SubtypeKey
                        + "|" + volume.TargetKeys
                        + "|" + volume.Label
                        + "|" + GetTriggerGeometryPointKey(volume.Min)
                        + "|" + GetTriggerGeometryPointKey(volume.Max);
                }

                TriggerVolume@ CloneCrystalExpandableMergeSourceVolume(const TriggerVolume@ volume) {
                    auto copy = TriggerVisualizer::Trigger::Data::CloneTriggerVolumeForMerge(volume);
                    copy.ChildVolumes.Resize(0);
                    return copy;
                }

                void AppendUniqueCrystalExpandableMergeSourceVolume(
                    array<TriggerVolume@> @target,
                    dictionary@ seenKeys,
                    const TriggerVolume@ volume
                ) {
                    if (target is null || seenKeys is null || volume is null) return;

                    string key = CrystalExpandableMergeSourceVolumeKey(volume);
                    if (key.Length == 0 || seenKeys.Exists(key)) return;

                    seenKeys.Set(key, true);
                    target.InsertLast(CloneCrystalExpandableMergeSourceVolume(volume));
                }

                void StoreCrystalExpandableMergeSourceVolumes(
                    TriggerSourceSnapshot@ source,
                    const array<TriggerVolume@> @volumes
                ) {
                    if (source is null || volumes is null) return;

                    dictionary seenKeys;
                    for (uint i = 0; i < source.CachedExpandableMergeSourceVolumes.Length; i++) {
                        auto cached = source.CachedExpandableMergeSourceVolumes[i];
                        if (cached is null) continue;
                        seenKeys.Set(CrystalExpandableMergeSourceVolumeKey(cached), true);
                    }

                    for (uint i = 0; i < volumes.Length; i++) {
                        AppendUniqueCrystalExpandableMergeSourceVolume(
                            source.CachedExpandableMergeSourceVolumes,
                            seenKeys,
                            volumes[i]
                        );
                    }
                }

                void AppendFlattenedCrystalExpandableVolume(
                    array<TriggerVolume@> @target,
                    const TriggerVolume@ volume
                ) {
                    if (target is null || volume is null) return;
                    if (volume.HasChildVolumes()) {
                        for (uint i = 0; i < volume.ChildVolumes.Length; i++) {
                            AppendFlattenedCrystalExpandableVolume(target, volume.ChildVolumes[i]);
                        }
                        return;
                    }
                    target.InsertLast(CloneCrystalExpandableMergeSourceVolume(volume));
                }

                void CollectCrystalExpandableMergeSourceVolumes(
                    const TriggerSourceSnapshot@ source,
                    array<TriggerVolume@> @target
                ) {
                    if (source is null || target is null) return;

                    dictionary seenKeys;
                    for (uint i = 0; i < source.CachedExpandableMergeSourceVolumes.Length; i++) {
                        AppendUniqueCrystalExpandableMergeSourceVolume(
                            target,
                            seenKeys,
                            source.CachedExpandableMergeSourceVolumes[i]
                        );
                    }

                    auto visible = array<TriggerVolume@>();
                    for (uint i = 0; i < source.TriggerVolumes.Length; i++) {
                        auto volume = source.TriggerVolumes[i];
                        if (!CrystalVolumeIsExpandableMergeViewVolume(volume)) continue;
                        AppendFlattenedCrystalExpandableVolume(visible, volume);
                    }
                    for (uint i = 0; i < visible.Length; i++) {
                        AppendUniqueCrystalExpandableMergeSourceVolume(
                            target,
                            seenKeys,
                            visible[i]
                        );
                    }
                }

                void AppendCrystalSourceVolumeWithNextIndex(
                    TriggerSourceSnapshot@ source,
                    TriggerVolume@ volume
                ) {
                    if (source is null || volume is null) return;
                    volume.SourceIndex = source.TriggerVolumes.Length;
                    source.TriggerVolumes.InsertLast(volume);
                }

                TriggerSourceSnapshot@ CloneCrystalSourceForMergeMode(
                    const TriggerSourceSnapshot@ source,
                    bool mergeAdjacent
                ) {
                    auto copy = TriggerVisualizer::Trigger::Data::CloneTriggerSourceSnapshotForCache(source);
                    if (copy is null || copy.Source != TRIGGER_SOURCE_CRYSTAL) return copy;

                    auto passthrough = array<TriggerVolume@>();
                    auto expandableSourceVolumes = array<TriggerVolume@>();
                    auto expandableRectangles = array<TriggerVolume@>();
                    auto expandableFinish = array<TriggerVolume@>();
                    CollectCrystalExpandableMergeSourceVolumes(source, expandableSourceVolumes);

                    for (uint i = 0; i < copy.TriggerVolumes.Length; i++) {
                        auto volume = copy.TriggerVolumes[i];
                        if (CrystalVolumeIsExpandableMergeViewVolume(volume)) continue;
                        passthrough.InsertLast(TriggerVisualizer::Trigger::Data::CloneTriggerVolumeForMerge(volume));
                    }

                    for (uint i = 0; i < expandableSourceVolumes.Length; i++) {
                        auto volume = expandableSourceVolumes[i];
                        if (CrystalVolumeIsExpandableRectangleVolume(volume)) {
                            expandableRectangles.InsertLast(CloneCrystalExpandableMergeSourceVolume(volume));
                        } else if (CrystalVolumeIsExpandableFinishVolume(volume)) {
                            expandableFinish.InsertLast(CloneCrystalExpandableMergeSourceVolume(volume));
                        }
                    }
                    copy.TriggerVolumes.Resize(0);
                    copy.CachedExpandableMergeSourceVolumes.Resize(0);
                    StoreCrystalExpandableMergeSourceVolumes(copy, expandableSourceVolumes);
                    for (uint i = 0; i < passthrough.Length; i++) {
                        AppendCrystalSourceVolumeWithNextIndex(copy, passthrough[i]);
                    }
                    if (mergeAdjacent) {
                        auto stats = CrystalExpandableRectangleStats();
                        AppendCrystalExpandableRectangleGroups(copy, expandableRectangles, stats);
                    } else {
                        AppendCrystalExpandableRectanglesUnmerged(copy, expandableRectangles);
                    }

                    for (uint i = 0; i < expandableFinish.Length; i++) {
                        AppendCrystalSourceVolumeWithNextIndex(copy, expandableFinish[i]);
                    }
                    MergeCrystalExpandableFinishWaypointVolumes(
                        copy,
                        mergeAdjacent
                    );
                    AddCrystalDiagnostic(
                        copy,
                        "Crystal merge view rebuilt from cached trigger volumes for immediate merge-setting feedback; no Crystal rescan was required."
                    );
                    return copy;
                }

                void MergeCrystalExpandableFinishWaypointVolumes(
                    TriggerSourceSnapshot@ source,
                    bool mergeAdjacent = true
                ) {
                    if (source is null || source.TriggerVolumes.Length <= 1) return;
                    if (!mergeAdjacent) return;

                    auto passthrough = array<TriggerVolume@>();
                    auto expandableFinish = array<TriggerVolume@>();
                    for (uint i = 0; i < source.TriggerVolumes.Length; i++) {
                        auto volume = source.TriggerVolumes[i];
                        if (CrystalVolumeIsRealExpandableFinishWaypoint(volume)) {
                            expandableFinish.InsertLast(CloneCrystalExpandableFinishVolumeForMerge(volume));
                        } else {
                            passthrough.InsertLast(volume);
                        }
                    }
                    StoreCrystalExpandableMergeSourceVolumes(source, expandableFinish);
                    if (expandableFinish.Length <= 1) return;

                    for (uint i = 0; i < expandableFinish.Length; i++) {
                        ClearCrystalExpandableFinishMergeOutline(expandableFinish[i]);
                    }
                    uint closedGapCount = CloseCrystalExpandableFinishVisualGaps(expandableFinish);
                    auto mergedFinish = TriggerVisualizer::Trigger::Data::MergeAdjacentTriggerVolumes(expandableFinish);
                    uint originalCount = expandableFinish.Length;
                    uint mergedCount = mergedFinish.Length;
                    if (mergedCount == 0) return;

                    source.TriggerVolumes.Resize(0);
                    for (uint i = 0; i < passthrough.Length; i++) {
                        source.TriggerVolumes.InsertLast(passthrough[i]);
                    }
                    for (uint i = 0; i < mergedFinish.Length; i++) {
                        if (mergedFinish[i] is null) continue;
                        mergedFinish[i].SourceIndex = source.TriggerVolumes.Length;
                        source.TriggerVolumes.InsertLast(mergedFinish[i]);
                    }
                    AddCrystalDiagnostic(
                        source,
                        "Merged real expandable finish waypoint Crystal volumes: " + tostring(originalCount) + " exposed trigger volumes into " + tostring(mergedCount) + " connected finish volume(s). Geometry comes from the exposed waypoint trigger bounds; no synthetic expandable finish rectangles are generated."
                    );
                    if (closedGapCount > 0) {
                        AddCrystalDiagnostic(
                            source,
                            "Closed " + tostring(closedGapCount) + " small visual seam(s) between clipped expandable finish trigger bounds."
                        );
                    }
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

                const uint CRYSTAL_SOURCE_BUILD_FRAME_BUDGET_MS = 1;

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
                        "GateExpandableSpecial* and GateExpandableGameplay* areas use one approximate local rectangle per matching block from public Coord/Dir/variant-size placement plus material/name target metadata. Other expandable Crystal blocks use the normal block/item trigger discovery paths."
                    );
                    AddCrystalDiagnostic(
                        source,
                        "GateExpandableFinish* / ExpandableFinish waypoint triggers use their exposed Crystal trigger bounds, then adjacent finish pieces are merged as one connected finish volume."
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
                        "Item CGameObjectPhyModel TriggerShape DataRefs are resolved through Fids::Preload and rendered through anchored-object placement when exposed."
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
                    bool customOnly = TriggerVisualizer::Trigger::UI::S_CrystalCustomItemsAndBlockItemsOnly;
                    ProbeCrystalAnchoredObjects(source, ctx.RootMap, customOnly);
                    frameStart = CrystalSourceBuildCheckpoint(frameStart);
                    if (customOnly) {
                        AddCrystalDiagnostic(
                            source,
                            "Crystal custom block/item mode is enabled; Nadeo block and expandable rectangle probing is skipped."
                        );
                        ProbeCrystalBlocks(source, ctx.RootMap, true);
                        frameStart = CrystalSourceBuildCheckpoint(frameStart);
                    } else {
                        ProbeCrystalExpandableBlockUnitTriggers(
                            source,
                            ctx.RootMap,
                            TriggerVisualizer::Trigger::UI::S_MergeAdjacentTriggerVolumes
                        );
                        frameStart = CrystalSourceBuildCheckpoint(frameStart);
                        ProbeCrystalBlocks(source, ctx.RootMap);
                        frameStart = CrystalSourceBuildCheckpoint(frameStart);
                    }
                    MergeCrystalExpandableFinishWaypointVolumes(
                        source,
                        TriggerVisualizer::Trigger::UI::S_MergeAdjacentTriggerVolumes
                    );
                    frameStart = CrystalSourceBuildCheckpoint(frameStart);
                    AddCrystalFinalCountsDiagnostic(source);

                    return source;
                }
            }
        }
    }
}
