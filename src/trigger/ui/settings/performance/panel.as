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

                UI::Separator();
                UI::Text("Editable Source Cache");

                UI::SetNextItemWidth(220.0f);
                S_OffzoneEditorRefreshIntervalMs = UI::InputInt(
                    "Offzone editor refresh interval (ms)##trigger-visualizer-performance",
                    S_OffzoneEditorRefreshIntervalMs
                );

                UI::SetNextItemWidth(220.0f);
                S_MediaTrackerEditorRefreshIntervalMs = UI::InputInt(
                    "MediaTracker editor refresh interval (ms)##trigger-visualizer-performance",
                    S_MediaTrackerEditorRefreshIntervalMs
                );

                UI::Separator();
                UI::Text("Fast Driving Mode");
                S_FastDrivingPerformanceMode = UI::Checkbox(
                    "Enable fast-driving performance mode##trigger-visualizer-performance",
                    S_FastDrivingPerformanceMode
                );

                UI::SetNextItemWidth(220.0f);
                S_FastDrivingSpeedThresholdKmh = UI::InputFloat(
                    "Speed threshold##trigger-visualizer-performance",
                    S_FastDrivingSpeedThresholdKmh
                );

                UI::SetNextItemWidth(220.0f);
                S_FastDrivingMaxVisibleVolumes = UI::InputInt(
                    "Fast max visible volumes##trigger-visualizer-performance",
                    S_FastDrivingMaxVisibleVolumes
                );

                UI::SetNextItemWidth(220.0f);
                S_FastDrivingMaxFillTilesPerFrame = UI::InputInt(
                    "Fast max fill tiles##trigger-visualizer-performance",
                    S_FastDrivingMaxFillTilesPerFrame
                );

                UI::SetNextItemWidth(220.0f);
                S_FastDrivingMaxOutlineSegmentsPerFrame = UI::InputInt(
                    "Fast max outline segments##trigger-visualizer-performance",
                    S_FastDrivingMaxOutlineSegmentsPerFrame
                );

                S_FastDrivingDisableFill = UI::Checkbox(
                    "Disable fill while fast##trigger-visualizer-performance",
                    S_FastDrivingDisableFill
                );

                S_FastDrivingDisableLabels = UI::Checkbox(
                    "Disable labels while fast##trigger-visualizer-performance",
                    S_FastDrivingDisableLabels
                );

                S_FastDrivingDisableTileIcons = UI::Checkbox(
                    "Disable tile icons while fast##trigger-visualizer-performance",
                    S_FastDrivingDisableTileIcons
                );

                S_FastDrivingSimplifyGroupedTriggers = UI::Checkbox(
                    "Simplify grouped triggers while fast##trigger-visualizer-performance",
                    S_FastDrivingSimplifyGroupedTriggers
                );

                ClampPerformanceSettings();
            }
        }
    }
}
