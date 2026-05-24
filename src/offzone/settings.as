namespace OffzoneVisualizer {
    namespace Offzone {
        [Setting hidden name = "Offzone: Render world overlay"]
        bool S_RenderWorld = true;

        [Setting hidden name = "Offzone: Show panel contents"]
        bool S_ShowPanel = true;

        [Setting hidden name = "Offzone: Show labels"]
        bool S_ShowLabels = false;

        [Setting hidden name = "Offzone: Show face fill"]
        bool S_ShowFill = false;

        [Setting hidden name = "Offzone: Show outline"]
        bool S_ShowOutline = true;

        [Setting hidden name = "Offzone: Max render distance" min = 100 max = 50000]
        float S_MaxRenderDistance = 5000.0f;

        [Setting hidden name = "Offzone: Outline alpha" min = 0 max = 1]
        float S_OutlineAlpha = 0.95f;

        [Setting hidden name = "Offzone: Fill alpha" min = 0 max = 1]
        float S_FillAlpha = 0.18f;

        void RenderSettingsUI() {
            UI::Text("World Rendering");
            S_RenderWorld = UI::Checkbox("Enable world render##offzone-visualizer-settings", S_RenderWorld);
            S_ShowOutline = UI::Checkbox("Show outlines##offzone-visualizer-settings", S_ShowOutline);
            S_ShowFill = UI::Checkbox("Show face fill##offzone-visualizer-settings", S_ShowFill);
            S_ShowLabels = UI::Checkbox("Show labels##offzone-visualizer-settings", S_ShowLabels);

            UI::SetNextItemWidth(220.0f);
            S_MaxRenderDistance = UI::InputFloat("Max render distance##offzone-visualizer-settings", S_MaxRenderDistance);
            S_MaxRenderDistance = Math::Clamp(S_MaxRenderDistance, 100.0f, 50000.0f);

            UI::SetNextItemWidth(220.0f);
            S_OutlineAlpha = UI::SliderFloat("Outline alpha##offzone-visualizer-settings", S_OutlineAlpha, 0.0f, 1.0f);

            UI::SetNextItemWidth(220.0f);
            S_FillAlpha = UI::SliderFloat("Fill alpha##offzone-visualizer-settings", S_FillAlpha, 0.0f, 1.0f);

            UI::Separator();
            UI::Text("Panel");
            S_ShowPanel = UI::Checkbox("Show panel contents##offzone-visualizer-settings", S_ShowPanel);
            UI::TextDisabled("These settings are foundation only for now. World rendering is still a no-op until later steps.");
        }
    }
}
