namespace TriggerVisualizer {
    namespace Trigger {
        namespace Ui {
            void RenderWorldRenderingSettingsUi() {
                S_RenderWorld = UI::Checkbox("Enable world render##trigger-visualizer-settings", S_RenderWorld);
                S_ShowOutline = UI::Checkbox("Show outlines##trigger-visualizer-settings", S_ShowOutline);
                S_ShowFill = UI::Checkbox("Show face fill##trigger-visualizer-settings", S_ShowFill);
                S_ShowLabels = UI::Checkbox("Show labels##trigger-visualizer-settings", S_ShowLabels);
                UI::Separator();
                UI::BeginTabBar("trigger-visualizer-world-rendering-tabs");
                if (UI::BeginTabItem("Distance")) {
                    RenderWorldDistanceSettingsUi();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("LineSplitting")) {
                    RenderLineSplittingSettingsUi();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Color")) {
                    RenderColorSettingsUi();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Image/Tiles")) {
                    RenderImageTilesSettingsUi();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Map Hints")) {
                    RenderMapHintsSettingsUi();
                    UI::EndTabItem();
                }
                UI::EndTabBar();
            }
        }
    }
}
