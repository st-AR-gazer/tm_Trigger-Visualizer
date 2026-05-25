namespace OffzoneVisualizer {
    namespace App {
        const string RESTORE_DEFAULTS_POPUP_ID = "Restore defaults?##offzone-visualizer-restore-defaults";

        void RenderRestoreDefaultsModal() {
            if (UI::BeginPopupModal(RESTORE_DEFAULTS_POPUP_ID, UI::WindowFlags::AlwaysAutoResize)) {
                UI::Text("Restore Offzone Visualizer defaults?");
                UI::TextDisabled("This resets General, World Rendering, Line Splitting, Performance, Color, Proximity, and Labels settings.");

                UI::Separator();
                if (UI::Button("Restore defaults##offzone-visualizer-confirm-restore-defaults")) {
                    ResetSettingsToDefaults();
                    OffzoneVisualizer::Offzone::UI::ResetSettingsToDefaults();
                    UI::CloseCurrentPopup();
                }

                UI::SameLine();
                if (UI::Button("Cancel##offzone-visualizer-cancel-restore-defaults")) {
                    UI::CloseCurrentPopup();
                }

                UI::EndPopup();
            }
        }

        void RenderGeneralSettingsUI() {
            bool open = UI::BeginChild("##offzone-visualizer-settings-general", vec2(0, 0), false);
            if (open) {
                S_HideWithGame = UI::Checkbox("Hide with game UI", S_HideWithGame);
                S_HideWithOP = UI::Checkbox("Hide with Openplanet UI", S_HideWithOP);

                UI::Separator();
                UI::Text("Rendering");
                OffzoneVisualizer::Offzone::UI::S_RenderWorld = UI::Checkbox(
                    "Enable all rendering##offzone-visualizer-settings-general",
                    OffzoneVisualizer::Offzone::UI::S_RenderWorld
                );

                UI::Separator();
                UI::Text("Developer Tools");
                S_DevPanelOpen = UI::Checkbox("Show dev panel##offzone-visualizer-settings-general", S_DevPanelOpen);

                UI::Separator();
                UI::Text("Defaults");
                if (UI::Button("Restore defaults##offzone-visualizer-open-restore-defaults")) {
                    UI::OpenPopup(RESTORE_DEFAULTS_POPUP_ID);
                }
                RenderRestoreDefaultsModal();
            }
            UI::EndChild();
        }

        void RenderWorldRenderingSettingsUI() {
            bool open = UI::BeginChild("##offzone-visualizer-settings-world-rendering", vec2(0, 0), false);
            if (open) {
                OffzoneVisualizer::Offzone::UI::RenderWorldRenderingSettingsUI();
            }
            UI::EndChild();
        }

        void RenderLineSplittingSettingsUI() {
            bool open = UI::BeginChild("##offzone-visualizer-settings-line-splitting", vec2(0, 0), false);
            if (open) {
                OffzoneVisualizer::Offzone::UI::RenderLineSplittingSettingsUI();
            }
            UI::EndChild();
        }

        void RenderPerformanceSettingsUI() {
            bool open = UI::BeginChild("##offzone-visualizer-settings-performance", vec2(0, 0), false);
            if (open) {
                OffzoneVisualizer::Offzone::UI::RenderPerformanceSettingsUI();
            }
            UI::EndChild();
        }

        void RenderColorSettingsUI() {
            bool open = UI::BeginChild("##offzone-visualizer-settings-color", vec2(0, 0), false);
            if (open) {
                OffzoneVisualizer::Offzone::UI::RenderColorSettingsUI();
            }
            UI::EndChild();
        }

        void RenderProximitySettingsUI() {
            bool open = UI::BeginChild("##offzone-visualizer-settings-proximity", vec2(0, 0), false);
            if (open) {
                OffzoneVisualizer::Offzone::UI::RenderProximitySettingsUI();
            }
            UI::EndChild();
        }

        void RenderLabelsSettingsUI() {
            bool open = UI::BeginChild("##offzone-visualizer-settings-labels", vec2(0, 0), false);
            if (open) {
                OffzoneVisualizer::Offzone::UI::RenderLabelsSettingsUI();
            }
            UI::EndChild();
        }

        void RenderLoggingSettingsUI() {
            bool open = UI::BeginChild("##offzone-visualizer-settings-logging", vec2(0, 0), false);
            if (open) {
                logging::RenderSettingsUI("offzone-visualizer-logging");
            }
            UI::EndChild();
        }
    }
}
