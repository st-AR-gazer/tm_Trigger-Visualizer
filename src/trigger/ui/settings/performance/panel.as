namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            void RenderSpeedRenderSkipTargetsUI() {
                UI::Text("Keep While Fast");
                UI::TextDisabled("Selected targets stay visible after the speed threshold is reached; everything else is hidden.");
                RenderTargetSelectionTabs(
                    TARGET_SELECTION_MODE_SPEED_KEEP,
                    "trigger-visualizer-performance-speed-target-tabs",
                    "speed-keep-targets"
                );
            }

            void RenderPerformanceCullingSettingsUI() {
                S_MergeAdjacentTriggerVolumes = UI::Checkbox(
                    "Merge adjacent compatible trigger volumes##trigger-visualizer-performance",
                    S_MergeAdjacentTriggerVolumes
                );
                UI::Separator();
                S_PerformanceCullingEnabled = UI::Checkbox(
                    "Enable culling##trigger-visualizer-performance",
                    S_PerformanceCullingEnabled
                );
                UI::BeginDisabled(!S_PerformanceCullingEnabled);
                S_CullOffscreenWorldTiles = UI::Checkbox(
                    "Cull off-screen fill/icon tiles##trigger-visualizer-performance",
                    S_CullOffscreenWorldTiles
                );
                UI::EndDisabled();
            }

            void RenderPerformanceBudgetSettingsUI() {
                S_PerformanceBudgetsEnabled = UI::Checkbox(
                    "Enable draw budgets##trigger-visualizer-performance",
                    S_PerformanceBudgetsEnabled
                );
                UI::BeginDisabled(!S_PerformanceBudgetsEnabled);
                UI::Text("Budget Presets");
                if (TriggerVisualizer::Shared::StyledButton("Low##trigger-visualizer-performance-budget-preset-low")) {
                    ApplyLowPerformanceDrawBudgetPreset();
                }
                UI::SameLine();
                if (TriggerVisualizer::Shared::StyledButton("Medium##trigger-visualizer-performance-budget-preset-medium")) {
                    ApplyMediumPerformanceDrawBudgetPreset();
                }
                UI::SameLine();
                if (TriggerVisualizer::Shared::StyledButton("High##trigger-visualizer-performance-budget-preset-high")) {
                    ApplyHighPerformanceDrawBudgetPreset();
                }
                UI::Separator();
                UI::SetNextItemWidth(220.0f);
                S_FillTileMinSize = UI::InputFloat(
                    "Fill tile minimum size##trigger-visualizer-performance",
                    S_FillTileMinSize
                );
                UI::SetNextItemWidth(220.0f);
                S_MaxVisibleVolumesPerFrame = UI::InputInt(
                    "Max visible volumes per frame##trigger-visualizer-performance",
                    S_MaxVisibleVolumesPerFrame
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
                S_MaxCrystalOutlineSegmentsPerFrame = UI::InputInt(
                    "Max Crystal outline segments per frame##trigger-visualizer-performance",
                    S_MaxCrystalOutlineSegmentsPerFrame
                );
                S_SplitCrystalOutlineEdges = UI::Checkbox(
                    "Split Crystal outline edges##trigger-visualizer-performance",
                    S_SplitCrystalOutlineEdges
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
                UI::EndDisabled();
            }

            int RenderRefreshIntervalInput(const string &in id, int value) {
                UI::SetNextItemWidth(120.0f);
                return NormalizeRefreshIntervalMs(UI::InputInt("##trigger-visualizer-performance-refresh-" + id, value));
            }

            int RenderRefreshRow(const string &in source, const string &in context, const string &in id, int value) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text(source);
                UI::TableNextColumn();
                UI::Text(context);
                UI::TableNextColumn();
                return RenderRefreshIntervalInput(id, value);
            }

            void RenderPerformanceRefreshSettingsUI() {
                UI::TextDisabled("Intervals are milliseconds; 0 disables periodic refresh.");
                S_PerformanceRefreshEnabled = UI::Checkbox(
                    "Enable source cache refresh##trigger-visualizer-performance",
                    S_PerformanceRefreshEnabled
                );
                UI::BeginDisabled(!S_PerformanceRefreshEnabled);
                if (UI::BeginTable("trigger-visualizer-performance-refresh-table", 3, UI::TableFlags::SizingStretchProp | UI::TableFlags::BordersInnerV | UI::TableFlags::RowBg)) {
                    UI::TableSetupColumn("Source");
                    UI::TableSetupColumn("Editable context");
                    UI::TableSetupColumn("Interval", UI::TableColumnFlags::WidthFixed, 140.0f);
                    UI::TableHeadersRow();
                    S_OffzoneEditorRefreshIntervalMs = RenderRefreshRow(
                        "Offzone",
                        "Map Editor",
                        "offzone-editor",
                        S_OffzoneEditorRefreshIntervalMs
                    );
                    S_MediaTrackerEditorRefreshIntervalMs = RenderRefreshRow(
                        "MediaTracker",
                        "MediaTracker Editor",
                        "mediatracker-editor",
                        S_MediaTrackerEditorRefreshIntervalMs
                    );
                    S_CrystalMeshModelerRefreshIntervalMs = RenderRefreshRow(
                        "Crystal",
                        "Mesh Modeler",
                        "crystal-mesh-modeler",
                        S_CrystalMeshModelerRefreshIntervalMs
                    );
                    UI::EndTable();
                }
                UI::EndDisabled();
            }

            void RenderPerformanceSpeedSettingsUI() {
                S_FastDrivingPerformanceMode = UI::Checkbox(
                    "Enable fast driving render skip##trigger-visualizer-performance",
                    S_FastDrivingPerformanceMode
                );
                UI::BeginDisabled(!S_FastDrivingPerformanceMode);
                UI::SetNextItemWidth(220.0f);
                S_FastDrivingSpeedThresholdKmh = UI::InputFloat(
                    "Forward speed threshold (km/h)##trigger-visualizer-performance",
                    S_FastDrivingSpeedThresholdKmh
                );
                UI::SetNextItemWidth(220.0f);
                S_FastDrivingReverseSpeedThresholdKmh = UI::InputFloat(
                    "Reverse speed threshold (km/h)##trigger-visualizer-performance",
                    S_FastDrivingReverseSpeedThresholdKmh
                );
                RenderSpeedRenderSkipTargetsUI();
                UI::EndDisabled();
            }

            void RenderPerformanceSettingsUI() {
                UI::BeginTabBar("trigger-visualizer-performance-tabs");
                if (UI::BeginTabItem("Budgets")) {
                    RenderPerformanceBudgetSettingsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Culling")) {
                    RenderPerformanceCullingSettingsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Refresh")) {
                    RenderPerformanceRefreshSettingsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Fast Driving")) {
                    RenderPerformanceSpeedSettingsUI();
                    UI::EndTabItem();
                }
                UI::EndTabBar();
                ClampPerformanceSettings();
            }
        }
    }
}
