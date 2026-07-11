namespace TriggerVisualizer {
    namespace App {
        const string RESTORE_DEFAULTS_POPUP_ID = "Restore defaults?##trigger-visualizer-restore-defaults";
        bool g_ResetDefaultsGeneral = true;
        bool g_ResetDefaultsWorldDisplay = true;
        bool g_ResetDefaultsWorldDistance = true;
        bool g_ResetDefaultsWorldLineSplitting = true;
        bool g_ResetDefaultsWorldColor = true;
        bool g_ResetDefaultsWorldImageTiles = true;
        bool g_ResetDefaultsWorldMapHints = true;
        bool g_ResetDefaultsPerformance = true;
        bool g_ResetDefaultsSourcesProfiles = true;
        bool g_ResetDefaultsLabels = true;

        bool HasWorldRestoreDefaultsSelection() {
            return g_ResetDefaultsWorldDisplay
                || g_ResetDefaultsWorldDistance
                || g_ResetDefaultsWorldLineSplitting
                || g_ResetDefaultsWorldColor
                || g_ResetDefaultsWorldImageTiles
                || g_ResetDefaultsWorldMapHints;
        }

        bool IsWorldRestoreDefaultsFullySelected() {
            return g_ResetDefaultsWorldDisplay
                && g_ResetDefaultsWorldDistance
                && g_ResetDefaultsWorldLineSplitting
                && g_ResetDefaultsWorldColor
                && g_ResetDefaultsWorldImageTiles
                && g_ResetDefaultsWorldMapHints;
        }

        void SetWorldRestoreDefaultsSelection(bool value) {
            g_ResetDefaultsWorldDisplay = value;
            g_ResetDefaultsWorldDistance = value;
            g_ResetDefaultsWorldLineSplitting = value;
            g_ResetDefaultsWorldColor = value;
            g_ResetDefaultsWorldImageTiles = value;
            g_ResetDefaultsWorldMapHints = value;
        }

        bool HasSourcesRestoreDefaultsSelection() {
            return g_ResetDefaultsSourcesProfiles;
        }

        bool IsSourcesRestoreDefaultsFullySelected() {
            return g_ResetDefaultsSourcesProfiles;
        }

        void SetSourcesRestoreDefaultsSelection(bool value) {
            g_ResetDefaultsSourcesProfiles = value;
        }

        void SetRestoreDefaultsSelection(bool value) {
            g_ResetDefaultsGeneral = value;
            SetWorldRestoreDefaultsSelection(value);
            g_ResetDefaultsPerformance = value;
            SetSourcesRestoreDefaultsSelection(value);
            g_ResetDefaultsLabels = value;
        }

        bool HasRestoreDefaultsSelection() {
            return g_ResetDefaultsGeneral
                || HasWorldRestoreDefaultsSelection()
                || g_ResetDefaultsPerformance
                || HasSourcesRestoreDefaultsSelection()
                || g_ResetDefaultsLabels;
        }

        void ApplySelectedRestoreDefaults() {
            if (g_ResetDefaultsGeneral) {
                ResetGeneralSettingsToDefaults();
                TriggerVisualizer::Trigger::Ui::ResetGeneralTriggerSettingsToDefaults();
            }
            if (g_ResetDefaultsWorldDisplay) {
                TriggerVisualizer::Trigger::Ui::ResetWorldDisplaySettingsToDefaults();
            }
            if (g_ResetDefaultsWorldDistance) {
                TriggerVisualizer::Trigger::Ui::ResetWorldDistanceSettingsToDefaults();
            }
            if (g_ResetDefaultsWorldLineSplitting) {
                TriggerVisualizer::Trigger::Ui::ResetWorldLineSplittingSettingsToDefaults();
            }
            if (g_ResetDefaultsWorldColor) {
                TriggerVisualizer::Trigger::Ui::ResetWorldColorSettingsToDefaults();
            }
            if (g_ResetDefaultsWorldImageTiles) {
                TriggerVisualizer::Trigger::Ui::ResetWorldTileIconSettingsToDefaults();
            }
            if (g_ResetDefaultsWorldMapHints) {
                TriggerVisualizer::Trigger::Ui::ResetWorldMapHintSettingsToDefaults();
            }
            if (g_ResetDefaultsPerformance) {
                TriggerVisualizer::Trigger::Ui::ResetPerformanceSettingsToDefaults();
            }
            if (g_ResetDefaultsSourcesProfiles) {
                TriggerVisualizer::Trigger::Ui::ResetSourceProfileSettingsToDefaults();
            }
            if (g_ResetDefaultsLabels) {
                TriggerVisualizer::Trigger::Ui::ResetLabelSettingsToDefaults();
            }
        }

        void RenderWorldRestoreDefaultsSelectionUi() {
            bool selected = IsWorldRestoreDefaultsFullySelected();
            bool next = UI::Checkbox("World Rendering##trigger-visualizer-restore-defaults-world-rendering", selected);
            if (next != selected) SetWorldRestoreDefaultsSelection(next);
            if (HasWorldRestoreDefaultsSelection() && !IsWorldRestoreDefaultsFullySelected()) {
                UI::SameLine();
                UI::TextDisabled("(partial)");
            }
            UI::Indent();
            g_ResetDefaultsWorldDisplay = UI::Checkbox(
                "Display##trigger-visualizer-restore-defaults-world-display",
                g_ResetDefaultsWorldDisplay
            );
            g_ResetDefaultsWorldDistance = UI::Checkbox(
                "Distance##trigger-visualizer-restore-defaults-world-distance",
                g_ResetDefaultsWorldDistance
            );
            g_ResetDefaultsWorldLineSplitting = UI::Checkbox(
                "Line splitting##trigger-visualizer-restore-defaults-world-line-splitting",
                g_ResetDefaultsWorldLineSplitting
            );
            g_ResetDefaultsWorldColor = UI::Checkbox(
                "Color##trigger-visualizer-restore-defaults-world-color",
                g_ResetDefaultsWorldColor
            );
            g_ResetDefaultsWorldImageTiles = UI::Checkbox(
                "Image/Tiles##trigger-visualizer-restore-defaults-world-image-tiles",
                g_ResetDefaultsWorldImageTiles
            );
            g_ResetDefaultsWorldMapHints = UI::Checkbox(
                "Map hints##trigger-visualizer-restore-defaults-world-map-hints",
                g_ResetDefaultsWorldMapHints
            );
            UI::Unindent();
        }

        void RenderSourcesRestoreDefaultsSelectionUi() {
            bool selected = IsSourcesRestoreDefaultsFullySelected();
            bool next = UI::Checkbox("Sources##trigger-visualizer-restore-defaults-sources", selected);
            if (next != selected) SetSourcesRestoreDefaultsSelection(next);
            if (HasSourcesRestoreDefaultsSelection() && !IsSourcesRestoreDefaultsFullySelected()) {
                UI::SameLine();
                UI::TextDisabled("(partial)");
            }
            UI::Indent();
            g_ResetDefaultsSourcesProfiles = UI::Checkbox(
                "Context visibility profiles##trigger-visualizer-restore-defaults-sources-profiles",
                g_ResetDefaultsSourcesProfiles
            );
            UI::Unindent();
        }

        void RenderRestoreDefaultsModal() {
            if (UI::BeginPopupModal(RESTORE_DEFAULTS_POPUP_ID, UI::WindowFlags::AlwaysAutoResize)) {
                UI::Text("Restore selected Trigger Visualizer defaults?");
                UI::Separator();
                g_ResetDefaultsGeneral = UI::Checkbox(
                    "General##trigger-visualizer-restore-defaults-general",
                    g_ResetDefaultsGeneral
                );
                UI::Separator();
                RenderWorldRestoreDefaultsSelectionUi();
                UI::Separator();
                g_ResetDefaultsPerformance = UI::Checkbox(
                    "Performance##trigger-visualizer-restore-defaults-performance",
                    g_ResetDefaultsPerformance
                );
                UI::Separator();
                RenderSourcesRestoreDefaultsSelectionUi();
                UI::Separator();
                g_ResetDefaultsLabels = UI::Checkbox(
                    "Labels##trigger-visualizer-restore-defaults-labels",
                    g_ResetDefaultsLabels
                );
                UI::Separator();
                if (TriggerVisualizer::Shared::StyledButton("Select all##trigger-visualizer-restore-defaults-select-all")) {
                    SetRestoreDefaultsSelection(true);
                }
                UI::SameLine();
                if (TriggerVisualizer::Shared::StyledButton("Select none##trigger-visualizer-restore-defaults-select-none")) {
                    SetRestoreDefaultsSelection(false);
                }
                UI::Separator();
                bool hasSelection = HasRestoreDefaultsSelection();
                if (!hasSelection) {
                    UI::TextDisabled("Select at least one settings group to reset.");
                }
                UI::BeginDisabled(!hasSelection);
                if (TriggerVisualizer::Shared::StyledButton("Restore selected defaults##trigger-visualizer-confirm-restore-defaults")) {
                    ApplySelectedRestoreDefaults();
                    UI::CloseCurrentPopup();
                }
                UI::EndDisabled();
                UI::SameLine();
                if (TriggerVisualizer::Shared::StyledButton("Cancel##trigger-visualizer-cancel-restore-defaults")) {
                    UI::CloseCurrentPopup();
                }
                UI::EndPopup();
            }
        }

        void RenderGeneralSettingsUi() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-general", vec2(0, 0), false);
            if (open) {
                S_HideWithGame = UI::Checkbox("Hide with game UI", S_HideWithGame);
                S_HideWithOP = UI::Checkbox("Hide with Openplanet UI", S_HideWithOP);
                UI::Separator();
                UI::Text("Rendering");
                TriggerVisualizer::Trigger::Ui::S_RenderWorld = UI::Checkbox(
                    "Enable all rendering##trigger-visualizer-settings-general",
                    TriggerVisualizer::Trigger::Ui::S_RenderWorld
                );
                auto snapshot = TriggerVisualizer::Trigger::GetCurrentMapSnapshot();
                auto hints = snapshot is null ? null : snapshot.RenderHints;
                bool forceOff = hints !is null && hints.ForceOff;
                bool suggestOff = hints !is null
                    && hints.SuggestOff
                    && TriggerVisualizer::Trigger::Ui::RespectMapSuggestOffForRuntime(TriggerVisualizer::Trigger::GetCurrentRuntimeContext());
                if (forceOff || suggestOff) {
                    UI::PushStyleColor(UI::Col::Text, vec4(0.72f, 0.72f, 0.72f, 1.0f));
                    UI::TextWrapped(forceOff ? "Rendering is forcibly hidden by the current map's forced-hide command." : "The current map suggests hiding Trigger Visualizer. This is only a suggestion and can be overridden for this map.");
                    UI::PopStyleColor();
                }
                UI::Separator();
                UI::Text("Developer Tools");
                S_DevPanelOpen = UI::Checkbox("Show dev panel##trigger-visualizer-settings-general", S_DevPanelOpen);
                UI::Separator();
                UI::Text("Defaults");
                if (TriggerVisualizer::Shared::StyledButton("Restore defaults##trigger-visualizer-open-restore-defaults")) {
                    SetRestoreDefaultsSelection(true);
                    UI::OpenPopup(RESTORE_DEFAULTS_POPUP_ID);
                }
                RenderRestoreDefaultsModal();
            }
            UI::EndChild();
        }
    }
}
