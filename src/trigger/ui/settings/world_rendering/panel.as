namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            void RenderWorldRenderingSettingsUI() {
                S_RenderWorld = UI::Checkbox("Enable world render##trigger-visualizer-settings", S_RenderWorld);
                S_ShowOutline = UI::Checkbox("Show outlines##trigger-visualizer-settings", S_ShowOutline);
                S_ShowFill = UI::Checkbox("Show face fill##trigger-visualizer-settings", S_ShowFill);
                S_ShowLabels = UI::Checkbox("Show labels##trigger-visualizer-settings", S_ShowLabels);
                UI::Separator();
                UI::BeginTabBar("trigger-visualizer-world-rendering-tabs");
                if (UI::BeginTabItem("Distance")) {
                    RenderWorldDistanceSettingsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("LineSplitting")) {
                    RenderLineSplittingSettingsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Color")) {
                    RenderColorSettingsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Image/Tiles")) {
                    RenderImageTilesSettingsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Map Hints")) {
                    RenderMapHintsSettingsUI();
                    UI::EndTabItem();
                }
                UI::EndTabBar();
            }
        }
    }
}
