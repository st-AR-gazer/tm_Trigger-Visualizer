namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            namespace Dev {
                string OnOff(bool value) {
                    return value ? "On" : "Off";
                }

                string PointerLabel(uint64 ptr) {
                    return ptr == 0 ? "0x0" : Text::FormatPointer(ptr);
                }

                void RenderSourceDiagnostics(const TriggerSourceSnapshot@ source, uint sourceIndex) {
                    if (source is null || source.DiagnosticCount() == 0) return;

                    if (UI::TreeNode("Diagnostics (" + source.DiagnosticCount() + ")##trigger-source-diags-" + sourceIndex)) {
                        for (uint i = 0; i < source.Diagnostics.Length; i++) {
                            UI::TextWrapped(source.Diagnostics[i]);
                        }
                        UI::TreePop();
                    }
                }

                void RenderMediaTrackerClipTriggerProbe(const TriggerSourceSnapshot@ source, uint sourceIndex) {
                    if (source is null || source.Source != TriggerVisualizer::Trigger::TRIGGER_SOURCE_MEDIATRACKER) return;

                    UI::Text("    clips " + source.RawClipCount + " | triggers " + source.RawTriggerCount + " / " + source.RawTriggerCapacity);
                    UI::Text("    readable " + source.ReadableTriggerCount + " | bad " + source.BadTriggerCount + " | raw coords " + source.RawCoordCount);
                    UI::Text("    trigger buffer " + PointerLabel(source.RawBufferPtr));
                    UI::Text("    map size " + source.MapSize.ToString());
                    if (source.GridSpec !is null) {
                        UI::Text("    grid " + source.GridSpec.CellsPerBlock.ToString() + " | cell " + source.GridSpec.CellWorldSize.ToString());
                        UI::Text("    world y anchor " + Text::Format("%.2f", source.GridSpec.WorldYAnchor));
                        UI::Text("    anchor source " + source.GridSpec.WorldYAnchorSource);
                    }
                    if (source.MediaTrackerClipTriggerCount() == 0) return;
                    if (!UI::TreeNode("MediaTracker Clip Triggers (" + source.MediaTrackerClipTriggerCount() + ")##trigger-source-mt-clips-" + sourceIndex)) return;

                    for (uint i = 0; i < source.MediaTrackerClipTriggers.Length; i++) {
                        auto trigger = source.MediaTrackerClipTriggers[i];
                        if (trigger is null) continue;

                        string label = "#" + trigger.ClipIndex + " " + trigger.DisplayName();
                        if (trigger.HasWarning()) label += " [warning]";
                        if (!UI::TreeNode(label + "##trigger-source-mt-clip-" + sourceIndex + "-" + i)) continue;

                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Has Clip", OnOff(trigger.HasClip)));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Detected Label", trigger.DetectedLabel.Length > 0 ? trigger.DetectedLabel : "<none>"));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Subtype", trigger.SubtypeLabel.Length > 0 ? trigger.SubtypeLabel + " (" + trigger.SubtypeKey + ")" : "<none>"));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Targets", trigger.TargetKeys.Length > 0 ? trigger.TargetKeys : "<none>"));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Track Color", trigger.HasMediaTrackerTrackColor ? trigger.MediaTrackerTrackColor.ToString() : "<none>"));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Ghost Color Override", OnOff(TriggerVisualizer::Trigger::TriggerTargetListContains(trigger.TargetKeys, TriggerVisualizer::Trigger::MT_SUBTYPE_GHOST))));
                        if (trigger.EntityInfo.Length > 0) {
                            UI::TextWrapped("Entity: " + trigger.EntityInfo);
                        }
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Trigger Ptr", PointerLabel(trigger.TriggerStructPtr)));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Coord Buffer", PointerLabel(trigger.CoordBufferPtr)));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Coord Count", tostring(trigger.RawCoordCount)));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Coord Capacity", tostring(trigger.RawCoordCapacity)));
                        string renderShape = trigger.RenderCoordsSkipped ? "Skipped" : "Exact cells";
                        if (trigger.RenderIslandsUsed) {
                            renderShape = "Cell islands (" + tostring(trigger.RenderIslandCount) + ")";
                        }
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Render Shape", renderShape));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Min Coord", trigger.MinCoord.ToString()));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Max Coord", trigger.MaxCoord.ToString()));
                        if (trigger.CoordSamplesTruncated) {
                            UI::TextDisabled("Showing first " + tostring(trigger.SampledCoordCount) + " coordinate samples.");
                        }
                        if (trigger.HasWarning()) {
                            UI::TextWrapped("Warning: " + trigger.Warning);
                        }
                        if (trigger.RawCoordSamples.Length > 0 && UI::TreeNode("Coordinate Samples (" + trigger.RawCoordSamples.Length + ")##trigger-source-mt-samples-" + sourceIndex + "-" + i)) {
                            for (uint j = 0; j < trigger.RawCoordSamples.Length; j++) {
                                UI::Text("#" + j + ": " + trigger.RawCoordSamples[j].ToString());
                            }
                            UI::TreePop();
                        }
                        UI::TreePop();
                    }
                    UI::TreePop();
                }

                void RenderDevPanelContent() {
                    auto ctx = GetCurrentRuntimeContext();
                    auto snapshot = GetCurrentMapSnapshot();
                    UI::Text("Runtime");
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("State", ctx.StateLabel()));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Has Map", OnOff(ctx.HasMap)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Has Playground", OnOff(ctx.HasPlayground)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("In Editor", OnOff(ctx.IsInEditor)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Map Editor", OnOff(ctx.IsMapEditor)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Editor Test Mode", OnOff(ctx.IsEditorTestMode)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Has MediaTracker Editor", OnOff(ctx.HasMediaTrackerEditor)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Editor MediaTracker", OnOff(ctx.IsEditorMediaTracker)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Replay Editor", OnOff(ctx.IsReplayEditor)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Playable Map", OnOff(ctx.IsPlayableMap)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Map UID", ctx.HasMapUid() ? ctx.MapUid : "<none>"));
                    UI::Separator();
                    UI::Text("Render Settings");
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("World Render", OnOff(UI::S_RenderWorld)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Outline", OnOff(UI::S_ShowOutline)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Fill", OnOff(UI::S_ShowFill)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Labels", OnOff(UI::S_ShowLabels)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Distance Profile", UI::GetDistanceSettingsContextLabel(UI::GetDistanceSettingsContextForRuntime(ctx))));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Render Distance", UI::GetRenderDistanceWorldForRuntime(ctx).ToString() + " m"));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Effective Distance", TriggerVisualizer::Trigger::Render::GetEffectiveRenderDistanceWorld().ToString() + " m"));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Fade Band", UI::GetRenderFadeBandWorldForRuntime(ctx).ToString() + " m"));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Proximity Area", UI::GetRuntimeAreaLabel(ctx)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Proximity Source", UI::GetRenderProximityModeLabel(UI::GetRenderProximityModeForRuntime(ctx))));
                    int sourceContext = UI::GetSourceSettingsContextForRuntime(ctx);
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Source Profile", UI::GetSourceSettingsContextLabel(sourceContext)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Offzone Source", OnOff(UI::IsOffzoneSourceEnabledForContext(sourceContext))));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Offzone Effective", OnOff(UI::IsOffzoneSourceEnabledForRuntime(ctx))));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("MediaTracker Source", OnOff(UI::IsMediaTrackerSourceEnabledForContext(sourceContext))));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("MediaTracker Effective", OnOff(UI::IsMediaTrackerSourceEnabledForRuntime(ctx))));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Crystal Source", OnOff(UI::IsCrystalSourceEnabledForContext(sourceContext))));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Crystal Effective", OnOff(UI::IsCrystalSourceEnabledForRuntime(ctx))));
                    if (TriggerVisualizer::Shared::StyledButton("Refresh Crystal Cache##trigger-dev-refresh-crystal")) {
                        TriggerVisualizer::Trigger::RefreshCrystalSourceCache();
                    }
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Use Map Distance", OnOff(UI::UseMapSuggestedDrawDistanceForRuntime(ctx))));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Respect Suggest Off", OnOff(UI::S_RespectMapSuggestOff)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Color Source", UI::GetColorSourceLabel(UI::S_ColorSource)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Base Color", UI::S_BaseTriggerColor.ToString()));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Distance Tint", OnOff(UI::S_EnableDistanceFadeColor) + " " + UI::S_DistanceFadeColor.ToString()));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Split Tint", OnOff(UI::S_EnableLineSplitDensityColor) + " " + UI::S_DenseLineSplitColor.ToString()));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Random Segment Colors", OnOff(UI::S_RandomOutlineSegmentColors)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Random Tile Colors", OnOff(UI::S_RandomFillTileColors)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Tile Icons", OnOff(UI::S_ShowSkullTileIcons)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Skull Icon Scale", Text::Format("%.2f", UI::S_SkullTileIconScale)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Culling System", OnOff(UI::S_PerformanceCullingEnabled)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Offscreen Tile Culling", OnOff(UI::ShouldCullOffscreenWorldTiles())));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Refresh System", OnOff(UI::S_PerformanceRefreshEnabled)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Offzone Editor Refresh", tostring(UI::S_OffzoneEditorRefreshIntervalMs) + " ms"));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("MT Editor Refresh", tostring(UI::S_MediaTrackerEditorRefreshIntervalMs) + " ms"));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Speed Render Skip", OnOff(UI::S_FastDrivingPerformanceMode)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Speed Skip Forward", Text::Format("%.1f km/h", UI::GetFastDrivingForwardSpeedThresholdKmh())));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Speed Skip Reverse", Text::Format("%.1f km/h", UI::GetFastDrivingReverseSpeedThresholdKmh())));
                    UI::TextWrapped("Speed Kept Targets: " + (UI::S_SpeedRenderKeepTargetKeys.Length > 0 ? UI::S_SpeedRenderKeepTargetKeys : "<none>"));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Outline Alpha", Text::Format("%.2f", UI::S_OutlineAlpha)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Fill Alpha", Text::Format("%.2f", UI::S_FillAlpha)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Outline Width", Text::Format("%.1f px", UI::S_OutlineWidth)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Label Index", OnOff(UI::S_LabelShowIndex)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Label Raw Range", OnOff(UI::S_LabelShowRawRange)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Label World Size", OnOff(UI::S_LabelShowWorldSize)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Label Island", OnOff(UI::S_LabelShowIslandIndex)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Label Source Prefix", OnOff(UI::S_LabelShowSourcePrefix)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Label Detected Overwrite", OnOff(UI::S_LabelUseDetectedTriggerName)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Label Detected Extra", OnOff(UI::S_LabelShowDetectedTriggerName)));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Label Font Size", Text::Format("%.1f", UI::S_LabelFontSize)));
                    if (ctx.HasMap) {
                        vec3 cameraPos = Camera::GetCurrentPosition();
                        auto proximityState = TriggerVisualizer::Trigger::Data::GetProximityReferenceState(ctx);
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Proximity State", proximityState.StateLabel()));
                        if (proximityState.HasOrbitalPoint) {
                            UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Orbital Point", proximityState.OrbitalPoint.ToString()));
                        }
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Camera Pos", cameraPos.ToString()));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Vehicle Pos", proximityState.HasVehiclePosition ? proximityState.VehiclePosition.ToString() : "<none>"));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Vehicle Speed", proximityState.HasVehicleSpeed ? Text::Format("%.1f km/h", proximityState.VehicleSpeedKmh) : "<none>"));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Speed Skip Active", OnOff(TriggerVisualizer::Trigger::Render::IsSpeedRenderSkipActive())));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Speed Over Threshold", OnOff(TriggerVisualizer::Trigger::Render::IsSpeedRenderSkipActiveForSpeed(ctx, proximityState))));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Speed Skips All Sources", OnOff(TriggerVisualizer::Trigger::Render::ShouldSkipWorldRenderForSpeed(ctx, proximityState))));
                        if (UI::TreeNode("Render Metrics (expensive)##trigger-render-metrics")) {
                            uint visibleCount = TriggerVisualizer::Trigger::Render::CountTriggerVolumesInRenderRangeForProximity(
                                snapshot.TriggerVolumes,
                                cameraPos,
                                proximityState
                            );
                            uint fadingCount = TriggerVisualizer::Trigger::Render::CountTriggerVolumesInFadeBandForProximity(
                                snapshot.TriggerVolumes,
                                cameraPos,
                                proximityState
                            );
                            uint culledCount = snapshot.TriggerVolumes.Length - visibleCount;
                            uint fillFaceCount = TriggerVisualizer::Trigger::Render::CountTriggerVolumesCameraFacingFacesForProximity(
                                snapshot.TriggerVolumes,
                                cameraPos,
                                proximityState
                            );
                            uint fillTileCount = TriggerVisualizer::Trigger::Render::CountTriggerVolumesFillTilesForProximity(
                                snapshot.TriggerVolumes,
                                cameraPos,
                                proximityState
                            );
                            uint labelCount = TriggerVisualizer::Trigger::Render::CountVisibleTriggerVolumeLabels(
                                snapshot.TriggerVolumes,
                                cameraPos,
                                proximityState
                            );
                            uint outlineSegmentCount = 0;
                            uint maxEdgeSegments = 0;
                            for (uint i = 0; i < snapshot.TriggerVolumes.Length; i++) {
                                auto box = snapshot.TriggerVolumes[i];
                                if (!TriggerVisualizer::Trigger::Render::IsTriggerVolumeInRenderRangeForProximity(box, cameraPos, proximityState)) continue;

                                outlineSegmentCount += TriggerVisualizer::Trigger::Render::CountTriggerVolumeOutlineSegments(
                                    box,
                                    cameraPos
                                );
                                uint edgeSegments = TriggerVisualizer::Trigger::Render::GetMaxTriggerVolumeOutlineEdgeSegments(
                                    box,
                                    cameraPos
                                );
                                if (edgeSegments > maxEdgeSegments) {
                                    maxEdgeSegments = edgeSegments;
                                }
                            }
                            UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Visible Volumes", tostring(visibleCount)));
                            UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Fading Volumes", tostring(fadingCount)));
                            UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Culled Volumes", tostring(culledCount)));
                            UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Fill Faces", tostring(fillFaceCount)));
                            UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Fill Tiles", tostring(fillTileCount)));
                            UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Visible Labels", tostring(labelCount)));
                            UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Adaptive Splitting", OnOff(UI::S_AdaptiveLineSplitting)));
                            UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Outline Segments", tostring(outlineSegmentCount)));
                            UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Max Edge Segments", tostring(maxEdgeSegments)));

                            if (snapshot.TriggerVolumes.Length > 0 && UI::TreeNode("Per-Volume Render Fade##trigger-render-fade")) {
                                for (uint i = 0; i < snapshot.TriggerVolumes.Length; i++) {
                                    float fade = TriggerVisualizer::Trigger::Render::GetTriggerVolumeRenderFadeFactor(
                                        snapshot.TriggerVolumes[i],
                                        cameraPos,
                                        proximityState
                                    );
                                    UI::Text("#" + i + ": " + Text::Format("%.3f", fade));
                                }
                                UI::TreePop();
                            }

                            if (snapshot.TriggerVolumes.Length > 0 && UI::TreeNode("Per-Volume Outline Segments##trigger-render-segments")) {
                                for (uint i = 0; i < snapshot.TriggerVolumes.Length; i++) {
                                    auto box = snapshot.TriggerVolumes[i];
                                    uint boxSegments = TriggerVisualizer::Trigger::Render::CountTriggerVolumeOutlineSegments(
                                        box,
                                        cameraPos
                                    );
                                    uint boxMaxEdgeSegments = TriggerVisualizer::Trigger::Render::GetMaxTriggerVolumeOutlineEdgeSegments(
                                        box,
                                        cameraPos
                                    );
                                    UI::Text("#" + i + ": total " + boxSegments + " | max edge " + boxMaxEdgeSegments);
                                }
                                UI::TreePop();
                            }

                            if (snapshot.TriggerVolumes.Length > 0 && UI::TreeNode("Per-Volume Fill Tiles##trigger-fill-tiles")) {
                                for (uint i = 0; i < snapshot.TriggerVolumes.Length; i++) {
                                    auto box = snapshot.TriggerVolumes[i];
                                    uint boxFillTiles = TriggerVisualizer::Trigger::Render::CountTriggerVolumeFillTiles(
                                        box,
                                        cameraPos
                                    );
                                    UI::Text("#" + i + ": " + boxFillTiles + " fill tiles");
                                }
                                UI::TreePop();
                            }
                            UI::TreePop();
                        }
                    }
                    UI::Separator();
                    UI::Text("Raw Map Data");
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Snapshot Map UID", snapshot.MapUid.Length > 0 ? snapshot.MapUid : "<none>"));
                    if (snapshot.RenderHints is null || !snapshot.RenderHints.HasAnyCommand) {
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Map Hints", "<none>"));
                    } else {
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Map Hints", snapshot.RenderHints.DisableSummary()));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Hint Targets", snapshot.RenderHints.TargetDisableSummary()));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Hint Distances", snapshot.RenderHints.DistanceSummary()));
                        if (UI::TreeNode("Map Hint Commands (" + snapshot.RenderHints.Commands.Length + ")##trigger-map-hint-commands")) {
                            for (uint i = 0; i < snapshot.RenderHints.Commands.Length; i++) {
                                UI::Text(snapshot.RenderHints.Commands[i]);
                            }
                            UI::TreePop();
                        }
                    }
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Trigger Size", snapshot.RawTriggerSize.ToString()));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Source Count", tostring(snapshot.SourceCount())));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Offzone Raw Count", tostring(snapshot.OffzoneCount())));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Trigger Volume Count", tostring(snapshot.TriggerVolumeCount())));
                    UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Buffer Ptr", Text::Format("0x%08x", snapshot.RawBufferPtr)));
                    if (snapshot.Sources.Length > 0 && UI::TreeNode("Trigger Sources (" + snapshot.Sources.Length + ")##trigger-sources")) {
                        for (uint i = 0; i < snapshot.Sources.Length; i++) {
                            auto source = snapshot.Sources[i];
                            if (source is null) continue;
                            UI::Text(source.Name + ": " + OnOff(source.Enabled));
                            UI::Text("    raw ranges " + source.RawRangeCount() + " | volumes " + source.TriggerVolumeCount());
                            RenderMediaTrackerClipTriggerProbe(source, i);
                            RenderSourceDiagnostics(source, i);
                        }
                        UI::TreePop();
                    }
                    if (snapshot.RawRanges.Length > 0 && UI::TreeNode("Raw Offzone Ranges (" + snapshot.RawRanges.Length + ")##trigger-raw-ranges")) {
                        for (uint i = 0; i < snapshot.RawRanges.Length; i++) {
                            auto range = snapshot.RawRanges[i];
                            UI::Text("#" + i + ": " + range.Start.ToString() + " -> " + range.End.ToString());
                        }
                        UI::TreePop();
                    }
                    UI::Separator();
                    UI::Text("Computed World Data");
                    if (snapshot.GridSpec is null) {
                        UI::TextDisabled("No grid spec available.");
                    } else {
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Cells Per Block", snapshot.GridSpec.CellsPerBlock.ToString()));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Cell World Size", snapshot.GridSpec.CellWorldSize.ToString()));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("World Y Anchor", Text::Format("%.2f", snapshot.GridSpec.WorldYAnchor)));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Anchor Source", snapshot.GridSpec.WorldYAnchorSource));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Collection", snapshot.GridSpec.MapCollectionName.Length > 0 ? snapshot.GridSpec.MapCollectionName : "<unknown>"));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Collection Id", snapshot.GridSpec.MapCollectionId >= 0 ? tostring(snapshot.GridSpec.MapCollectionId) : "<unknown>"));
                        UI::Text(TriggerVisualizer::Shared::FormatStatusLine("Deco Base Height", tostring(snapshot.GridSpec.MapDecoBaseHeightOffset)));
                    }
                    if (snapshot.TriggerVolumes.Length > 0 && UI::TreeNode("Trigger Volumes (" + snapshot.TriggerVolumes.Length + ")##trigger-trigger-volumes")) {
                        for (uint i = 0; i < snapshot.TriggerVolumes.Length; i++) {
                            auto box = snapshot.TriggerVolumes[i];
                            UI::Text("#" + i + " (" + box.DisplayLabel() + "): min " + box.Min.ToString() + " | max " + box.Max.ToString());
                            UI::Text("    size " + box.Size().ToString() + " | center " + box.Center().ToString());
                            UI::Text("    source " + box.SourceName() + " index " + tostring(box.SourceIndex));
                            if (box.SubtypeKey.Length > 0) {
                                UI::Text("    subtype " + box.SubtypeLabel + " (" + box.SubtypeKey + ")");
                            }
                            if (box.TargetKeys.Length > 0) {
                                UI::Text("    targets " + box.TargetKeys);
                            }
                            if (box.Source == TriggerVisualizer::Trigger::TRIGGER_SOURCE_MEDIATRACKER) {
                                UI::Text("    track color " + (box.HasMediaTrackerTrackColor ? box.MediaTrackerTrackColor.ToString() : "<none>"));
                                UI::Text("    ghost override " + OnOff(TriggerVisualizer::Trigger::TriggerVolumeMatchesTargetKey(box, TriggerVisualizer::Trigger::MT_SUBTYPE_GHOST)));
                            }
                        }
                        UI::TreePop();
                    }
                }
            }
        }
    }
}
