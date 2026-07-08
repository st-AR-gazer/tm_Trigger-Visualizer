namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            void RenderMapHintsSettingsUI() {
                S_RespectMapSuggestOff = UI::Checkbox(
                    "Respect map suggest-off##trigger-visualizer-settings",
                    S_RespectMapSuggestOff
                );
                ClampWorldRenderingSettings();
            }
        }
    }
}
