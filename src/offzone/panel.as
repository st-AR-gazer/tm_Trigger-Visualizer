namespace OffzoneVisualizer {
    namespace Offzone {
        string OnOff(bool value) {
            return value ? "On" : "Off";
        }

        void RenderPanelContent() {
            if (!S_ShowPanel) {
                UI::TextDisabled("Offzone panel contents are disabled in settings.");
                return;
            }

            UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("World Render", OnOff(S_RenderWorld)));
            UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Outline", OnOff(S_ShowOutline)));
            UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Fill", OnOff(S_ShowFill)));
            UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Labels", OnOff(S_ShowLabels)));
            UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Max Distance", Text::Format("%.0f m", S_MaxRenderDistance)));
            UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Outline Alpha", Text::Format("%.2f", S_OutlineAlpha)));
            UI::Text(OffzoneVisualizer::Shared::FormatStatusLine("Fill Alpha", Text::Format("%.2f", S_FillAlpha)));

            UI::Separator();
            UI::TextDisabled("Offzone data gathering and rendering will be added in later steps.");
        }
    }
}
