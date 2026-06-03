namespace TriggerVisualizer {
    namespace Shared {
        string FormatStatusLine(const string &in label, const string &in value) {
            return label + ": " + value;
        }

        void PushStyledButtonUI() {
            UI::PushStyleColor(UI::Col::Button, vec4(0.16f, 0.30f, 0.36f, 0.78f));
            UI::PushStyleColor(UI::Col::ButtonHovered, vec4(0.20f, 0.39f, 0.46f, 0.92f));
            UI::PushStyleColor(UI::Col::ButtonActive, vec4(0.24f, 0.46f, 0.54f, 1.00f));
        }

        void PopStyledButtonUI() {
            UI::PopStyleColor(3);
        }

        bool StyledButton(const string &in label) {
            PushStyledButtonUI();
            bool pressed = UI::Button(label);
            PopStyledButtonUI();
            return pressed;
        }

        bool StyledButton(const string &in label, const vec2 &in size) {
            PushStyledButtonUI();
            bool pressed = UI::Button(label, size);
            PopStyledButtonUI();
            return pressed;
        }

        class StatusLine {
            string label;
            string value;

            StatusLine() { }

            StatusLine(const string &in label, const string &in value) {
                this.label = label;
                this.value = value;
            }
        }
    }
}
