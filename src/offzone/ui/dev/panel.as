namespace OffzoneVisualizer {
    namespace Offzone {
        namespace UI {
            namespace Dev {
                string OnOff(bool value) {
                    return value ? "On" : "Off";
                }

                void RenderDevPanelContent() {
                    auto ctx = GetCurrentRuntimeContext();
                    auto snapshot = GetCurrentMapSnapshot();

                    UI::Text("Runtime");
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("State", ctx.StateLabel()));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Has Map", OnOff(ctx.HasMap)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Has Playground", OnOff(ctx.HasPlayground)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("In Editor", OnOff(ctx.IsInEditor)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Playable Map", OnOff(ctx.IsPlayableMap)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Map UID", ctx.HasMapUid() ? ctx.MapUid : "<none>"));

                    UI::Separator();
                    UI::Text("Render Settings");
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("World Render", OnOff(UI::S_RenderWorld)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Outline", OnOff(UI::S_ShowOutline)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Fill", OnOff(UI::S_ShowFill)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Labels", OnOff(UI::S_ShowLabels)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Render Distance", UI::GetRenderDistanceWorld().ToString() + " m"));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Fade Band", UI::GetRenderFadeBandWorld().ToString() + " m"));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Proximity Source", UI::GetRenderProximityModeLabel(UI::S_RenderProximityMode)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Color Mode", UI::GetColorModeLabel(UI::S_ColorMode)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Base Color", UI::S_BaseOffzoneColor.ToString()));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Distance Color", UI::S_DistanceFadeColor.ToString()));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Split Color", UI::S_DenseLineSplitColor.ToString()));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Random Segment Colors", OnOff(UI::S_RandomOutlineSegmentColors)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Random Tile Colors", OnOff(UI::S_RandomFillTileColors)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Skull Tile Icons", OnOff(UI::S_ShowSkullTileIcons)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Skull Icon Scale", Text::Format("%.2f", UI::S_SkullTileIconScale)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Offscreen Tile Culling", OnOff(UI::S_CullOffscreenWorldTiles)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Screen Occlusion Culling", OnOff(UI::S_CullScreenOccludedWorldTiles)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Occlusion Cell Size", tostring(UI::S_ScreenOcclusionCellSize)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Fill Tile Min Size", Text::Format("%.1f m", UI::S_FillTileMinSize)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Fill Tile Budget", tostring(UI::S_MaxFillTilesPerFrame)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Icon Patch Budget", tostring(UI::S_MaxTileIconPatchesPerFrame)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Icon Max Subdivisions", tostring(UI::S_TileIconMaxSubdivisions)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Outline Alpha", Text::Format("%.2f", UI::S_OutlineAlpha)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Fill Alpha", Text::Format("%.2f", UI::S_FillAlpha)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Outline Width", Text::Format("%.1f px", UI::S_OutlineWidth)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Label Index", OnOff(UI::S_LabelShowIndex)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Label Raw Range", OnOff(UI::S_LabelShowRawRange)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Label World Size", OnOff(UI::S_LabelShowWorldSize)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Label Font Size", Text::Format("%.1f", UI::S_LabelFontSize)));
                    if (ctx.IsPlayableMap) {
                        vec3 cameraPos = Camera::GetCurrentPosition();
                        auto playerState = OffzoneVisualizer::Offzone::Data::GetPlayerPositionState();
                        uint visibleCount = OffzoneVisualizer::Offzone::Render::CountWorldBoxesInRenderRangeForProximity(
                            snapshot.WorldBoxes,
                            cameraPos,
                            playerState
                        );
                        uint fadingCount = OffzoneVisualizer::Offzone::Render::CountWorldBoxesInFadeBandForProximity(
                            snapshot.WorldBoxes,
                            cameraPos,
                            playerState
                        );
                        uint culledCount = snapshot.WorldBoxes.Length - visibleCount;
                        uint fillFaceCount = OffzoneVisualizer::Offzone::Render::CountWorldBoxesCameraFacingFacesForProximity(
                            snapshot.WorldBoxes,
                            cameraPos,
                            playerState
                        );
                        uint fillTileCount = OffzoneVisualizer::Offzone::Render::CountWorldBoxesFillTilesForProximity(
                            snapshot.WorldBoxes,
                            cameraPos,
                            playerState
                        );
                        uint labelCount = OffzoneVisualizer::Offzone::Render::CountVisibleWorldBoxLabels(
                            snapshot.WorldBoxes,
                            cameraPos,
                            playerState
                        );
                        uint outlineSegmentCount = 0;
                        uint maxEdgeSegments = 0;
                        for (uint i = 0; i < snapshot.WorldBoxes.Length; i++) {
                            auto box = snapshot.WorldBoxes[i];
                            if (!OffzoneVisualizer::Offzone::Render::IsWorldBoxInRenderRangeForProximity(box, cameraPos, playerState)) continue;

                            outlineSegmentCount += OffzoneVisualizer::Offzone::Render::CountWorldBoxOutlineSegments(
                                box,
                                cameraPos
                            );
                            uint edgeSegments = OffzoneVisualizer::Offzone::Render::GetMaxWorldBoxOutlineEdgeSegments(
                                box,
                                cameraPos
                            );
                            if (edgeSegments > maxEdgeSegments) {
                                maxEdgeSegments = edgeSegments;
                            }
                        }

                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Camera Pos", cameraPos.ToString()));
                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Vehicle State", playerState.StateLabel()));
                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Vehicle Pos", playerState.HasVehicle ? playerState.Position.ToString() : "<none>"));
                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Visible Boxes", tostring(visibleCount)));
                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Fading Boxes", tostring(fadingCount)));
                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Culled Boxes", tostring(culledCount)));
                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Fill Faces", tostring(fillFaceCount)));
                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Fill Tiles", tostring(fillTileCount)));
                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Visible Labels", tostring(labelCount)));
                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Adaptive Splitting", OnOff(UI::S_AdaptiveLineSplitting)));
                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Outline Segments", tostring(outlineSegmentCount)));
                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Max Edge Segments", tostring(maxEdgeSegments)));

                        if (snapshot.WorldBoxes.Length > 0 && UI::TreeNode("Per-Box Render Fade##offzone-render-fade")) {
                            for (uint i = 0; i < snapshot.WorldBoxes.Length; i++) {
                                float fade = OffzoneVisualizer::Offzone::Render::GetWorldBoxRenderFadeFactor(
                                    snapshot.WorldBoxes[i],
                                    cameraPos,
                                    playerState
                                );
                                UI::Text("#" + i + ": " + Text::Format("%.3f", fade));
                            }
                            UI::TreePop();
                        }

                        if (snapshot.WorldBoxes.Length > 0 && UI::TreeNode("Per-Box Outline Segments##offzone-render-segments")) {
                            for (uint i = 0; i < snapshot.WorldBoxes.Length; i++) {
                                auto box = snapshot.WorldBoxes[i];
                                uint boxSegments = OffzoneVisualizer::Offzone::Render::CountWorldBoxOutlineSegments(
                                    box,
                                    cameraPos
                                );
                                uint boxMaxEdgeSegments = OffzoneVisualizer::Offzone::Render::GetMaxWorldBoxOutlineEdgeSegments(
                                    box,
                                    cameraPos
                                );
                                UI::Text("#" + i + ": total " + boxSegments + " | max edge " + boxMaxEdgeSegments);
                            }
                            UI::TreePop();
                        }

                        if (snapshot.WorldBoxes.Length > 0 && UI::TreeNode("Per-Box Fill Tiles##offzone-fill-tiles")) {
                            for (uint i = 0; i < snapshot.WorldBoxes.Length; i++) {
                                auto box = snapshot.WorldBoxes[i];
                                uint boxFillTiles = OffzoneVisualizer::Offzone::Render::CountWorldBoxFillTiles(
                                    box,
                                    cameraPos
                                );
                                UI::Text("#" + i + ": " + boxFillTiles + " fill tiles");
                            }
                            UI::TreePop();
                        }
                    }

                    UI::Separator();
                    UI::Text("Raw Map Data");
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Snapshot Map UID", snapshot.MapUid.Length > 0 ? snapshot.MapUid : "<none>"));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Trigger Size", snapshot.RawTriggerSize.ToString()));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Offzone Count", tostring(snapshot.OffzoneCount())));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Buffer Ptr", Text::Format("0x%08x", snapshot.RawBufferPtr)));
                    if (snapshot.RawRanges.Length > 0 && UI::TreeNode("Raw Offzones (" + snapshot.RawRanges.Length + ")##offzone-raw-ranges")) {
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
                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Cells Per Block", snapshot.GridSpec.CellsPerBlock.ToString()));
                        UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Cell World Size", snapshot.GridSpec.CellWorldSize.ToString()));
                    }
                    if (snapshot.WorldBoxes.Length > 0 && UI::TreeNode("World Boxes (" + snapshot.WorldBoxes.Length + ")##offzone-world-boxes")) {
                        for (uint i = 0; i < snapshot.WorldBoxes.Length; i++) {
                            auto box = snapshot.WorldBoxes[i];
                            UI::Text("#" + i + ": min " + box.Min.ToString() + " | max " + box.Max.ToString());
                            UI::Text("    size " + box.Size().ToString() + " | center " + box.Center().ToString());
                        }
                        UI::TreePop();
                    }
                }
            }
        }
    }
}
