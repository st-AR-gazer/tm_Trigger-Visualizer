namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            void RenderLineSplittingSettingsUI() {
                UI::Text("Adaptive Line/Face Splitting");
                S_AdaptiveLineSplitting = UI::Checkbox(
                    "Enable adaptive line/face splitting##trigger-visualizer-line-splitting",
                    S_AdaptiveLineSplitting
                );

                UI::Separator();
                UI::SetNextItemWidth(220.0f);
                S_LineSplitTargetSegmentLength = UI::SliderFloat(
                    "Minimum segment length##trigger-visualizer-line-splitting",
                    S_LineSplitTargetSegmentLength,
                    LINE_SPLIT_MINIMUM_SAFE_LENGTH,
                    LINE_SPLIT_TARGET_LENGTH_SLIDER_MAX,
                    "%.3f m"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitStartDistanceFactor = UI::SliderFloat(
                    "Start distance factor##trigger-visualizer-line-splitting",
                    S_LineSplitStartDistanceFactor,
                    0.01f,
                    4.0f,
                    "%.3f"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitFullDistanceFactor = UI::SliderFloat(
                    "Full distance factor##trigger-visualizer-line-splitting",
                    S_LineSplitFullDistanceFactor,
                    0.001f,
                    1.0f,
                    "%.4f"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMinStartDistance = UI::SliderFloat(
                    "Min start distance##trigger-visualizer-line-splitting",
                    S_LineSplitMinStartDistance,
                    0.0f,
                    LINE_SPLIT_START_DISTANCE_SLIDER_MAX,
                    "%.1f m"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMaxStartDistance = UI::SliderFloat(
                    "Max start distance##trigger-visualizer-line-splitting",
                    S_LineSplitMaxStartDistance,
                    0.0f,
                    LINE_SPLIT_START_DISTANCE_SLIDER_MAX,
                    "%.1f m"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMinFullDistance = UI::SliderFloat(
                    "Min full distance##trigger-visualizer-line-splitting",
                    S_LineSplitMinFullDistance,
                    0.0f,
                    LINE_SPLIT_FULL_DISTANCE_SLIDER_MAX,
                    "%.1f m"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMaxFullDistance = UI::SliderFloat(
                    "Max full distance##trigger-visualizer-line-splitting",
                    S_LineSplitMaxFullDistance,
                    0.0f,
                    LINE_SPLIT_FULL_DISTANCE_SLIDER_MAX,
                    "%.1f m"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMaxSegmentsPerEdge = UI::SliderInt(
                    "Max segments per edge##trigger-visualizer-line-splitting",
                    S_LineSplitMaxSegmentsPerEdge,
                    1,
                    LINE_SPLIT_SEGMENTS_SLIDER_MAX
                );

                ClampLineSplittingSettings();
            }
        }
    }
}
