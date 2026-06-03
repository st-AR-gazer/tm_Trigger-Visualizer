namespace TriggerVisualizer {
    namespace App {
        void RenderWorldRenderingSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-world-rendering", vec2(0, 0), false);
            if (open) {
                PushPluginButtonStyleUI();
                TriggerVisualizer::Trigger::UI::RenderWorldRenderingSettingsUI();
                PopPluginButtonStyleUI();
            }
            UI::EndChild();
        }

        void RenderLineSplittingSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-line-splitting", vec2(0, 0), false);
            if (open) {
                PushPluginButtonStyleUI();
                TriggerVisualizer::Trigger::UI::RenderLineSplittingSettingsUI();
                PopPluginButtonStyleUI();
            }
            UI::EndChild();
        }

        void RenderPerformanceSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-performance", vec2(0, 0), false);
            if (open) {
                PushPluginButtonStyleUI();
                TriggerVisualizer::Trigger::UI::RenderPerformanceSettingsUI();
                PopPluginButtonStyleUI();
            }
            UI::EndChild();
        }

        void RenderColorSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-color", vec2(0, 0), false);
            if (open) {
                PushPluginButtonStyleUI();
                TriggerVisualizer::Trigger::UI::RenderColorSettingsUI();
                PopPluginButtonStyleUI();
            }
            UI::EndChild();
        }

        void RenderProximitySettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-proximity", vec2(0, 0), false);
            if (open) {
                PushPluginButtonStyleUI();
                TriggerVisualizer::Trigger::UI::RenderProximitySettingsUI();
                PopPluginButtonStyleUI();
            }
            UI::EndChild();
        }

        void RenderLabelsSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-labels", vec2(0, 0), false);
            if (open) {
                PushPluginButtonStyleUI();
                TriggerVisualizer::Trigger::UI::RenderLabelsSettingsUI();
                PopPluginButtonStyleUI();
            }
            UI::EndChild();
        }

        void RenderSourcesSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-sources", vec2(0, 0), false);
            if (open) {
                PushPluginButtonStyleUI();
                TriggerVisualizer::Trigger::UI::RenderSourcesSettingsUI();
                PopPluginButtonStyleUI();
            }
            UI::EndChild();
        }

        void RenderLoggingSettingsUI() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-logging", vec2(0, 0), false);
            if (open) {
                PushPluginButtonStyleUI();
                logging::RenderSettingsUI("trigger-visualizer-logging");
                PopPluginButtonStyleUI();
            }
            UI::EndChild();
        }
    }
}
