namespace OffzoneVisualizer {
    namespace App {
        void RenderGeneralSettingsUI() {
            bool open = UI::BeginChild("##offzone-visualizer-settings-general", vec2(0, 0), false);
            if (open) {
                S_WindowOpen = UI::Checkbox("Show main window", S_WindowOpen);
                S_HideWithGame = UI::Checkbox("Hide with game UI", S_HideWithGame);
                S_HideWithOP = UI::Checkbox("Hide with Openplanet UI", S_HideWithOP);

                UI::Separator();
                OffzoneVisualizer::Offzone::RenderSettingsUI();
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
