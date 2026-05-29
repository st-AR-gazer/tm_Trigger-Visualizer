namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            void RenderPerformanceSettingsUI() {
                UI::Text("Performance Guardrails");

                S_CullOffscreenWorldTiles = UI::Checkbox(
                    "Cull off-screen fill/icon tiles##trigger-visualizer-performance",
                    S_CullOffscreenWorldTiles
                );

                S_CullScreenOccludedWorldTiles = UI::Checkbox(
                    "Experimental screen-covered tile culling##trigger-visualizer-performance",
                    S_CullScreenOccludedWorldTiles
                );

                UI::SetNextItemWidth(220.0f);
                S_ScreenOcclusionCellSize = UI::InputInt(
                    "Occlusion cell size##trigger-visualizer-performance",
                    S_ScreenOcclusionCellSize
                );

                UI::Separator();
                UI::SetNextItemWidth(220.0f);
                S_FillTileMinSize = UI::InputFloat(
                    "Fill tile minimum size##trigger-visualizer-performance",
                    S_FillTileMinSize
                );

                UI::SetNextItemWidth(220.0f);
                S_MaxFillTilesPerFrame = UI::InputInt(
                    "Max fill tiles per frame##trigger-visualizer-performance",
                    S_MaxFillTilesPerFrame
                );

                UI::SetNextItemWidth(220.0f);
                S_MaxOutlineSegmentsPerFrame = UI::InputInt(
                    "Max outline segments per frame##trigger-visualizer-performance",
                    S_MaxOutlineSegmentsPerFrame
                );

                UI::SetNextItemWidth(220.0f);
                S_MaxTileIconPatchesPerFrame = UI::InputInt(
                    "Max tile icon patches per frame##trigger-visualizer-performance",
                    S_MaxTileIconPatchesPerFrame
                );

                UI::SetNextItemWidth(220.0f);
                S_TileIconMaxSubdivisions = UI::InputInt(
                    "Tile icon max subdivisions##trigger-visualizer-performance",
                    S_TileIconMaxSubdivisions
                );

                ClampPerformanceSettings();
            }
        }
    }
}
