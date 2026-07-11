namespace TriggerVisualizer {
    namespace App {
        void RenderWorldRenderingSettingsUi() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-world-rendering", vec2(0, 0), false);
            if (open) {
                TriggerVisualizer::Shared::PushStyledButtonUi();
                TriggerVisualizer::Trigger::Ui::RenderWorldRenderingSettingsUi();
                TriggerVisualizer::Shared::PopStyledButtonUi();
            }
            UI::EndChild();
        }

        void RenderPerformanceSettingsUi() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-performance", vec2(0, 0), false);
            if (open) {
                TriggerVisualizer::Shared::PushStyledButtonUi();
                TriggerVisualizer::Trigger::Ui::RenderPerformanceSettingsUi();
                TriggerVisualizer::Shared::PopStyledButtonUi();
            }
            UI::EndChild();
        }

        void RenderLabelsSettingsUi() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-labels", vec2(0, 0), false);
            if (open) {
                TriggerVisualizer::Shared::PushStyledButtonUi();
                TriggerVisualizer::Trigger::Ui::RenderLabelsSettingsUi();
                TriggerVisualizer::Shared::PopStyledButtonUi();
            }
            UI::EndChild();
        }

        void RenderSourcesSettingsUi() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-sources", vec2(0, 0), false);
            if (open) {
                TriggerVisualizer::Shared::PushStyledButtonUi();
                TriggerVisualizer::Trigger::Ui::RenderSourcesSettingsUi();
                TriggerVisualizer::Shared::PopStyledButtonUi();
            }
            UI::EndChild();
        }

        void RenderLoggingSettingsUi() {
            bool open = UI::BeginChild("##trigger-visualizer-settings-logging", vec2(0, 0), false);
            if (open) {
                TriggerVisualizer::Shared::PushStyledButtonUi();
                logging::RenderSettingsUI("trigger-visualizer-logging");
                TriggerVisualizer::Shared::PopStyledButtonUi();
            }
            UI::EndChild();
        }
    }
}
