namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            void RenderColorSettingsUI() {
                UI::Text("Trigger Volume Color");
                if (UI::BeginCombo("Color mode##trigger-visualizer-color", GetColorModeLabel(S_ColorMode))) {
                    RenderColorModeOption(COLOR_MODE_STATIC);
                    RenderColorModeOption(COLOR_MODE_DISTANCE_FADE);
                    RenderColorModeOption(COLOR_MODE_LINE_SPLIT_DENSITY);
                    UI::EndCombo();
                }

                UI::Separator();
                S_BaseTriggerColor = UI::InputColor4("Base color##trigger-visualizer-color", S_BaseTriggerColor);
                S_DistanceFadeColor = UI::InputColor4(
                    "Distance fade color##trigger-visualizer-color",
                    S_DistanceFadeColor
                );
                S_DenseLineSplitColor = UI::InputColor4(
                    "Dense line split color##trigger-visualizer-color",
                    S_DenseLineSplitColor
                );

                UI::Separator();
                UI::Text("Appearance");
                UI::SetNextItemWidth(220.0f);
                S_OutlineAlpha = UI::SliderFloat("Outline alpha##trigger-visualizer-color", S_OutlineAlpha, 0.0f, 1.0f);

                UI::SetNextItemWidth(220.0f);
                S_FillAlpha = UI::SliderFloat("Fill alpha##trigger-visualizer-color", S_FillAlpha, 0.0f, 1.0f);

                UI::SetNextItemWidth(220.0f);
                S_OutlineWidth = UI::SliderFloat(
                    "Outline width##trigger-visualizer-color",
                    S_OutlineWidth,
                    0.5f,
                    16.0f,
                    "%.1f px"
                );

                UI::Separator();
                UI::Text("Stable Random Colors");
                S_RandomOutlineSegmentColors = UI::Checkbox(
                    "Random color per outline segment##trigger-visualizer-color",
                    S_RandomOutlineSegmentColors
                );
                S_RandomFillTileColors = UI::Checkbox(
                    "Random color per fill section/tile##trigger-visualizer-color",
                    S_RandomFillTileColors
                );

                ClampWorldRenderingSettings();
                ClampColorSettings();
            }
        }
    }
}
