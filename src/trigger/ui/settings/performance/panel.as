namespace TriggerVisualizer {
    namespace Trigger {
        namespace Ui {
            void RenderSpeedRenderSkipTargetsUi() {
                UI::Text("Keep While Fast");
                UI::TextDisabled("Selected targets stay visible after the speed threshold is reached; everything else is hidden.");
                RenderTargetSelectionTabs(
                    TARGET_SELECTION_MODE_SPEED_KEEP,
                    "trigger-visualizer-performance-speed-target-tabs",
                    "speed-keep-targets"
                );
            }

            void RenderPerformanceCullingSettingsUi() {
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

            void RenderPerformanceRefreshSettingsUi() {
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

            void RenderPerformanceSpeedSettingsUi() {
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
                RenderSpeedRenderSkipTargetsUi();
                UI::EndDisabled();
            }

            void RenderPerformanceSettingsUi() {
                UI::BeginTabBar("trigger-visualizer-performance-tabs");
                if (UI::BeginTabItem("Culling")) {
                    RenderPerformanceCullingSettingsUi();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Refresh")) {
                    RenderPerformanceRefreshSettingsUi();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Fast Driving")) {
                    RenderPerformanceSpeedSettingsUi();
                    UI::EndTabItem();
                }
                UI::EndTabBar();
                ClampPerformanceSettings();
            }
        }
    }
}
