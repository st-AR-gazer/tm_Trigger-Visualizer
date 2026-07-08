namespace TriggerVisualizer {
    namespace App {
        const string RESTORE_DEFAULTS_POPUP_ID = "Restore defaults?##trigger-visualizer-restore-defaults";
        bool G_ResetDefaultsGeneral = true;
        bool G_ResetDefaultsWorldDisplay = true;
        bool G_ResetDefaultsWorldDistance = true;
        bool G_ResetDefaultsWorldLineSplitting = true;
        bool G_ResetDefaultsWorldColor = true;
        bool G_ResetDefaultsWorldImageTiles = true;
        bool G_ResetDefaultsWorldMapHints = true;
        bool G_ResetDefaultsPerformance = true;
        bool G_ResetDefaultsSourcesProfiles = true;
        bool G_ResetDefaultsLabels = true;

        bool HasWorldRestoreDefaultsSelection() {
            return G_ResetDefaultsWorldDisplay
                || G_ResetDefaultsWorldDistance
                || G_ResetDefaultsWorldLineSplitting
                || G_ResetDefaultsWorldColor
                || G_ResetDefaultsWorldImageTiles
                || G_ResetDefaultsWorldMapHints;
        }

        bool IsWorldRestoreDefaultsFullySelected() {
            return G_ResetDefaultsWorldDisplay
                && G_ResetDefaultsWorldDistance
                && G_ResetDefaultsWorldLineSplitting
                && G_ResetDefaultsWorldColor
                && G_ResetDefaultsWorldImageTiles
                && G_ResetDefaultsWorldMapHints;
        }

        void SetWorldRestoreDefaultsSelection(bool value) {
            G_ResetDefaultsWorldDisplay = value;
            G_ResetDefaultsWorldDistance = value;
            G_ResetDefaultsWorldLineSplitting = value;
            G_ResetDefaultsWorldColor = value;
            G_ResetDefaultsWorldImageTiles = value;
            G_ResetDefaultsWorldMapHints = value;
        }

        bool HasSourcesRestoreDefaultsSelection() {
            return G_ResetDefaultsSourcesProfiles;
        }

        bool IsSourcesRestoreDefaultsFullySelected() {
            return G_ResetDefaultsSourcesProfiles;
        }

        void SetSourcesRestoreDefaultsSelection(bool value) {
            G_ResetDefaultsSourcesProfiles = value;
        }

        void SetRestoreDefaultsSelection(bool value) {
            G_ResetDefaultsGeneral = value;
            SetWorldRestoreDefaultsSelection(value);
            G_ResetDefaultsPerformance = value;
            SetSourcesRestoreDefaultsSelection(value);
            G_ResetDefaultsLabels = value;
        }

        bool HasRestoreDefaultsSelection() {
            return G_ResetDefaultsGeneral
                || HasWorldRestoreDefaultsSelection()
                || G_ResetDefaultsPerformance
                || HasSourcesRestoreDefaultsSelection()
                || G_ResetDefaultsLabels;
        }

        void ApplySelectedRestoreDefaults() {
            if (G_ResetDefaultsGeneral) {
                ResetGeneralSettingsToDefaults();
                TriggerVisualizer::Trigger::UI::ResetGeneralTriggerSettingsToDefaults();
            }
            if (G_ResetDefaultsWorldDisplay) {
                TriggerVisualizer::Trigger::UI::ResetWorldDisplaySettingsToDefaults();
            }
            if (G_ResetDefaultsWorldDistance) {
                TriggerVisualizer::Trigger::UI::ResetWorldDistanceSettingsToDefaults();
            }
            if (G_ResetDefaultsWorldLineSplitting) {
                TriggerVisualizer::Trigger::UI::ResetWorldLineSplittingSettingsToDefaults();
            }
            if (G_ResetDefaultsWorldColor) {
                TriggerVisualizer::Trigger::UI::ResetWorldColorSettingsToDefaults();
            }
            if (G_ResetDefaultsWorldImageTiles) {
                TriggerVisualizer::Trigger::UI::ResetWorldTileIconSettingsToDefaults();
            }
            if (G_ResetDefaultsWorldMapHints) {
                TriggerVisualizer::Trigger::UI::ResetWorldMapHintSettingsToDefaults();
            }
            if (G_ResetDefaultsPerformance) {
                TriggerVisualizer::Trigger::UI::ResetPerformanceSettingsToDefaults();
            }
            if (G_ResetDefaultsSourcesProfiles) {
                TriggerVisualizer::Trigger::UI::ResetSourceProfileSettingsToDefaults();
            }
            if (G_ResetDefaultsLabels) {
                TriggerVisualizer::Trigger::UI::ResetLabelSettingsToDefaults();
            }
        }

        void RenderWorldRestoreDefaultsSelectionUI() {
            bool selected = IsWorldRestoreDefaultsFullySelected();
            bool next = UI::Checkbox("World Rendering##trigger-visualizer-restore-defaults-world-rendering", selected);
            if (next != selected) SetWorldRestoreDefaultsSelection(next);
            if (HasWorldRestoreDefaultsSelection() && !IsWorldRestoreDefaultsFullySelected()) {
                UI::SameLine();
                UI::TextDisabled("(partial)");
            }
            UI::Indent();
            G_ResetDefaultsWorldDisplay = UI::Checkbox(
                "Display##trigger-visualizer-restore-defaults-world-display",
                G_ResetDefaultsWorldDisplay
            );
            G_ResetDefaultsWorldDistance = UI::Checkbox(
                "Distance##trigger-visualizer-restore-defaults-world-distance",
                G_ResetDefaultsWorldDistance
            );
            G_ResetDefaultsWorldLineSplitting = UI::Checkbox(
                "Line splitting##trigger-visualizer-restore-defaults-world-line-splitting",
                G_ResetDefaultsWorldLineSplitting
            );
            G_ResetDefaultsWorldColor = UI::Checkbox(
                "Color##trigger-visualizer-restore-defaults-world-color",
                G_ResetDefaultsWorldColor
            );
            G_ResetDefaultsWorldImageTiles = UI::Checkbox(
                "Image/Tiles##trigger-visualizer-restore-defaults-world-image-tiles",
                G_ResetDefaultsWorldImageTiles
            );
            G_ResetDefaultsWorldMapHints = UI::Checkbox(
                "Map hints##trigger-visualizer-restore-defaults-world-map-hints",
                G_ResetDefaultsWorldMapHints
            );
            UI::Unindent();
        }

        void RenderSourcesRestoreDefaultsSelectionUI() {
            bool selected = IsSourcesRestoreDefaultsFullySelected();
            bool next = UI::Checkbox("Sources##trigger-visualizer-restore-defaults-sources", selected);
            if (next != selected) SetSourcesRestoreDefaultsSelection(next);
            if (HasSourcesRestoreDefaultsSelection() && !IsSourcesRestoreDefaultsFullySelected()) {
                UI::SameLine();
                UI::TextDisabled("(partial)");
            }
            UI::Indent();
            G_ResetDefaultsSourcesProfiles = UI::Checkbox(
                "Context visibility profiles##trigger-visualizer-restore-defaults-sources-profiles",
                G_ResetDefaultsSourcesProfiles
            );
            UI::Unindent();
        }

        void RenderRestoreDefaultsModal() {
            if (UI::BeginPopupModal(RESTORE_DEFAULTS_POPUP_ID, UI::WindowFlags::AlwaysAutoResize)) {
                UI::Text("Restore selected Trigger Visualizer defaults?");
                UI::Separator();
                G_ResetDefaultsGeneral = UI::Checkbox(
                    "General##trigger-visualizer-restore-defaults-general",
                    G_ResetDefaultsGeneral
                );
                UI::Separator();
                RenderWorldRestoreDefaultsSelectionUI();
                UI::Separator();
                G_ResetDefaultsPerformance = UI::Checkbox(
                    "Performance##trigger-visualizer-restore-defaults-performance",
                    G_ResetDefaultsPerformance
                );
                UI::Separator();
                RenderSourcesRestoreDefaultsSelectionUI();
                UI::Separator();
                G_ResetDefaultsLabels = UI::Checkbox(
                    "Labels##trigger-visualizer-restore-defaults-labels",
                    G_ResetDefaultsLabels
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

        void RenderGeneralSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-general", vec2(0, 0), false);
            if (open) {
                S_HideWithGame = UI::Checkbox("Hide with game UI", S_HideWithGame);
                S_HideWithOP = UI::Checkbox("Hide with Openplanet UI", S_HideWithOP);
                UI::Separator();
                UI::Text("Rendering");
                TriggerVisualizer::Trigger::UI::S_RenderWorld = UI::Checkbox(
                    "Enable all rendering##trigger-visualizer-settings-general",
                    TriggerVisualizer::Trigger::UI::S_RenderWorld
                );
                string mapCommentHideSummary = TriggerVisualizer::Trigger::GetWorldRenderingHiddenByMapCommentSummary();
                if (mapCommentHideSummary.Length > 0) {
                    UI::PushStyleColor(UI::Col::Text, vec4(0.72f, 0.72f, 0.72f, 1.0f));
                    UI::TextWrapped("Hidden by current map comment: " + mapCommentHideSummary + ". Disable map suggest-off handling or remove the map command to render again.");
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
