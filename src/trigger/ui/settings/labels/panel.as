namespace TriggerVisualizer {
    namespace Trigger {
        namespace Ui {
            void RenderLabelTargetsUi() {
                UI::TextDisabled("Unchecked targets do not draw labels. Blank override text keeps the normal label.");
                RenderTargetSelectionTabs(
                    TARGET_SELECTION_MODE_LABELS,
                    "trigger-visualizer-label-target-tabs",
                    "label-targets"
                );
            }

            void RenderLabelRenderingSettingsUi() {
                S_ShowLabels = UI::Checkbox("Show labels##trigger-visualizer-labels", S_ShowLabels);
                UI::Separator();
                S_LabelShowIndex = UI::Checkbox("Show index##trigger-visualizer-labels", S_LabelShowIndex);
                S_LabelShowRawRange = UI::Checkbox("Show raw range##trigger-visualizer-labels", S_LabelShowRawRange);
                S_LabelShowWorldSize = UI::Checkbox("Show world size##trigger-visualizer-labels", S_LabelShowWorldSize);
                S_LabelShowIslandIndex = UI::Checkbox(
                    "Show island x/n##trigger-visualizer-labels",
                    S_LabelShowIslandIndex
                );
                S_LabelShowJoinedCount = UI::Checkbox(
                    "Show joined count##trigger-visualizer-labels",
                    S_LabelShowJoinedCount
                );
                S_LabelShowSourcePrefix = UI::Checkbox(
                    "Show source/type prefix##trigger-visualizer-labels",
                    S_LabelShowSourcePrefix
                );
                S_LabelUseDetectedTriggerName = UI::Checkbox(
                    "Overwrite name with detected trigger type##trigger-visualizer-labels",
                    S_LabelUseDetectedTriggerName
                );
                if (S_LabelUseDetectedTriggerName) {
                    S_LabelShowDetectedTriggerName = false;
                }
                UI::BeginDisabled(S_LabelUseDetectedTriggerName);
                S_LabelShowDetectedTriggerName = UI::Checkbox(
                    "Show detected trigger type with name##trigger-visualizer-labels",
                    S_LabelShowDetectedTriggerName
                );
                UI::EndDisabled();
                UI::Separator();
                UI::SetNextItemWidth(220.0f);
                S_LabelFontSize = UI::InputFloat("Font size##trigger-visualizer-labels", S_LabelFontSize);
                UI::SetNextItemWidth(220.0f);
                S_LabelAlpha = UI::SliderFloat("Text alpha##trigger-visualizer-labels", S_LabelAlpha, 0.0f, 1.0f);
            }

            void RenderLabelsSettingsUi() {
                UI::BeginTabBar("trigger-visualizer-labels-tabs");
                if (UI::BeginTabItem("Rendering")) {
                    RenderLabelRenderingSettingsUi();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Targets")) {
                    RenderLabelTargetsUi();
                    UI::EndTabItem();
                }
                UI::EndTabBar();
                ClampLabelSettings();
            }
        }
    }
}
