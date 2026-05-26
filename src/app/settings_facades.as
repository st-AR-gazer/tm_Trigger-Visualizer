namespace TriggerVisualizer {
    namespace App {
        const string RESTORE_DEFAULTS_POPUP_ID = "Restore defaults?##trigger-visualizer-restore-defaults";

        void RenderRestoreDefaultsModal() {
            if (UI::BeginPopupModal(RESTORE_DEFAULTS_POPUP_ID, UI::WindowFlags::AlwaysAutoResize)) {
                UI::Text("Restore Trigger Visualizer defaults?");
                UI::TextDisabled("This resets General, World Rendering, Sources, and Labels settings.");

                UI::Separator();
                if (UI::Button("Restore defaults##trigger-visualizer-confirm-restore-defaults")) {
                    ResetSettingsToDefaults();
                    TriggerVisualizer::Trigger::UI::ResetSettingsToDefaults();
                    UI::CloseCurrentPopup();
                }

                UI::SameLine();
                if (UI::Button("Cancel##trigger-visualizer-cancel-restore-defaults")) {
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

                UI::Separator();
                UI::Text("Developer Tools");
                S_DevPanelOpen = UI::Checkbox("Show dev panel##trigger-visualizer-settings-general", S_DevPanelOpen);

                UI::Separator();
                UI::Text("Defaults");
                if (UI::Button("Restore defaults##trigger-visualizer-open-restore-defaults")) {
                    UI::OpenPopup(RESTORE_DEFAULTS_POPUP_ID);
                }
                RenderRestoreDefaultsModal();
            }
            UI::EndChild();
        }

        void RenderWorldRenderingSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-world-rendering", vec2(0, 0), false);
            if (open) {
                TriggerVisualizer::Trigger::UI::RenderWorldRenderingSettingsUI();
            }
            UI::EndChild();
        }

        void RenderLineSplittingSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-line-splitting", vec2(0, 0), false);
            if (open) {
                TriggerVisualizer::Trigger::UI::RenderLineSplittingSettingsUI();
            }
            UI::EndChild();
        }

        void RenderPerformanceSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-performance", vec2(0, 0), false);
            if (open) {
                TriggerVisualizer::Trigger::UI::RenderPerformanceSettingsUI();
            }
            UI::EndChild();
        }

        void RenderColorSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-color", vec2(0, 0), false);
            if (open) {
                TriggerVisualizer::Trigger::UI::RenderColorSettingsUI();
            }
            UI::EndChild();
        }

        void RenderProximitySettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-proximity", vec2(0, 0), false);
            if (open) {
                TriggerVisualizer::Trigger::UI::RenderProximitySettingsUI();
            }
            UI::EndChild();
        }

        void RenderLabelsSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-labels", vec2(0, 0), false);
            if (open) {
                TriggerVisualizer::Trigger::UI::RenderLabelsSettingsUI();
            }
            UI::EndChild();
        }

        void RenderSourcesSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-sources", vec2(0, 0), false);
            if (open) {
                TriggerVisualizer::Trigger::UI::RenderSourcesSettingsUI();
            }
            UI::EndChild();
        }

        void RenderLoggingSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-logging", vec2(0, 0), false);
            if (open) {
                logging::RenderSettingsUI("trigger-visualizer-logging");
            }
            UI::EndChild();
        }
    }
}
