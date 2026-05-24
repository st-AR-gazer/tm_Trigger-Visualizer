namespace OffzoneVisualizer {
    namespace Offzone {
        namespace UI {
            namespace Dev {
                string OnOff(bool value) {
                    return value ? "On" : "Off";
                }

                void RenderPanelContent() {
                    auto ctx = GetCurrentRuntimeContext();
                    auto snapshot = GetCurrentMapSnapshot();

                    if (!UI::S_ShowPanel) {
                        UI::TextDisabled("Offzone panel contents are disabled in settings.");
                        return;
                    }

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
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Max Distance", Text::Format("%.0f m", UI::S_MaxRenderDistance)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Outline Alpha", Text::Format("%.2f", UI::S_OutlineAlpha)));
                    UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Fill Alpha", Text::Format("%.2f", UI::S_FillAlpha)));

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

                    UI::Separator();
                    UI::TextDisabled("Offzone data gathering and rendering will be added in later steps.");
                }
            }
        }
    }
}
