namespace TriggerVisualizer {
    namespace App {
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
