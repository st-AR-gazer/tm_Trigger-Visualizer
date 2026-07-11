namespace TriggerVisualizer {
    namespace Trigger {
        namespace Ui {
            void RenderCurrentMapSuggestOffOverrideUi() {
                auto ctx = TriggerVisualizer::Trigger::Data::GetRuntimeContext();
                auto snapshot = TriggerVisualizer::Trigger::GetCurrentMapSnapshot();
                if (ctx is null || snapshot is null || snapshot.RenderHints is null) return;
                if (!snapshot.RenderHints.SuggestOff) return;

                UI::Separator();
                UI::TextWrapped("The current map suggests hiding Trigger Visualizer. This is a suggestion, not a forced restriction.");
                if (snapshot.RenderHints.ForceOff) {
                    UI::TextDisabled("This map also has a forced hide, which cannot be overridden.");
                    return;
                }

                bool overrideValue = true;
                bool hasOverride = TryGetMapOnlyOverride(
                    ctx,
                    MAP_ONLY_OVERRIDE_RESPECT_SUGGEST_OFF,
                    overrideValue
                );
                bool ignoresSuggestion = hasOverride && !overrideValue;
                if (ignoresSuggestion) {
                    if (TriggerVisualizer::Shared::StyledButton("Use global setting for this map##trigger-visualizer-map-suggest-off-override")) {
                        ClearMapSuggestOffOverride(ctx);
                    }
                    return;
                }

                if (!RespectMapSuggestOffForRuntime(ctx)) {
                    UI::TextDisabled("The suggestion is already ignored globally.");
                    return;
                }
                if (TriggerVisualizer::Shared::StyledButton("Show despite suggestion on this map##trigger-visualizer-map-suggest-off-override")) {
                    IgnoreMapSuggestOffForCurrentMap(ctx);
                }
            }

            void RenderMapHintsSettingsUi() {
                S_RespectMapSuggestOff = UI::Checkbox(
                    "Respect map suggest-off##trigger-visualizer-settings",
                    S_RespectMapSuggestOff
                );
                RenderCurrentMapSuggestOffOverrideUi();
                ClampWorldRenderingSettings();
            }
        }
    }
}
