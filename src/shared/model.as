namespace TriggerVisualizer {
    namespace Shared {
        string FormatStatusLine(const string &in label, const string &in value) {
            return label + ": " + value;
        }

        void PushStyledButtonUi() {
            UI::PushStyleColor(UI::Col::Button, vec4(0.16f, 0.30f, 0.36f, 0.78f));
            UI::PushStyleColor(UI::Col::ButtonHovered, vec4(0.20f, 0.39f, 0.46f, 0.92f));
            UI::PushStyleColor(UI::Col::ButtonActive, vec4(0.24f, 0.46f, 0.54f, 1.00f));
        }

        void PopStyledButtonUi() {
            UI::PopStyleColor(3);
        }

        bool StyledButton(const string &in label) {
            PushStyledButtonUi();
            bool pressed = UI::Button(label);
            PopStyledButtonUi();
            return pressed;
        }

        bool StyledButton(const string &in label, const vec2 &in size) {
            PushStyledButtonUi();
            bool pressed = UI::Button(label, size);
            PopStyledButtonUi();
            return pressed;
        }

        class StatusLine {
            string Label;
            string Value;

            StatusLine() { }

            StatusLine(const string &in label, const string &in value) {
                Label = label;
                Value = value;
            }
        }
    }
}
