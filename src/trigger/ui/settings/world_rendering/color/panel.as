namespace TriggerVisualizer {
    namespace Trigger {
        namespace Ui {
            void RenderColorSettingsUi() {
                if (UI::BeginCombo("Base color source##trigger-visualizer-color", GetColorSourceLabel(S_ColorSource))) {
                    RenderColorSourceOption(COLOR_SOURCE_UNIFORM);
                    RenderColorSourceOption(COLOR_SOURCE_MEDIATRACKER_TRACK_COLORS);
                    UI::EndCombo();
                }
                UI::Separator();
                S_BaseTriggerColor = UI::InputColor4(
                    "Uniform base color##trigger-visualizer-color",
                    S_BaseTriggerColor
                );
                if (S_ColorSource == COLOR_SOURCE_MEDIATRACKER_TRACK_COLORS) {
                    UI::SetNextItemWidth(220.0f);
                    S_MediaTrackerTrackOutlineHueShift = UI::SliderFloat(
                        "Outline hue shift##trigger-visualizer-color",
                        S_MediaTrackerTrackOutlineHueShift,
                        -0.25f,
                        0.25f,
                        "%.2f"
                    );
                }
                UI::Separator();
                S_AnimateTurboRouletteColor = UI::Checkbox(
                    "Animate turbo roulette color##trigger-visualizer-color",
                    S_AnimateTurboRouletteColor
                );
                UI::BeginDisabled(!S_AnimateTurboRouletteColor);
                UI::SetNextItemWidth(160.0f);
                S_TurboRouletteYellowDurationMs = UI::InputInt(
                    "Roulette yellow ms##trigger-visualizer-color",
                    S_TurboRouletteYellowDurationMs
                );
                UI::SetNextItemWidth(160.0f);
                S_TurboRouletteCyanDurationMs = UI::InputInt(
                    "Roulette cyan ms##trigger-visualizer-color",
                    S_TurboRouletteCyanDurationMs
                );
                UI::SetNextItemWidth(160.0f);
                S_TurboRoulettePurpleDurationMs = UI::InputInt(
                    "Roulette purple ms##trigger-visualizer-color",
                    S_TurboRoulettePurpleDurationMs
                );
                UI::SetNextItemWidth(160.0f);
                S_TurboRoulettePhaseOffsetMs = UI::InputInt(
                    "Roulette phase offset ms##trigger-visualizer-color",
                    S_TurboRoulettePhaseOffsetMs
                );
                UI::EndDisabled();
                UI::Separator();
                S_EnableDistanceFadeColor = UI::Checkbox(
                    "Tint by render distance fade##trigger-visualizer-color",
                    S_EnableDistanceFadeColor
                );
                UI::BeginDisabled(!S_EnableDistanceFadeColor);
                S_DistanceFadeColor = UI::InputColor4(
                    "Far fade tint color##trigger-visualizer-color",
                    S_DistanceFadeColor
                );
                UI::EndDisabled();
                S_EnableLineSplitDensityColor = UI::Checkbox(
                    "Tint by line split density##trigger-visualizer-color",
                    S_EnableLineSplitDensityColor
                );
                UI::BeginDisabled(!S_EnableLineSplitDensityColor);
                S_DenseLineSplitColor = UI::InputColor4(
                    "Dense line split tint color##trigger-visualizer-color",
                    S_DenseLineSplitColor
                );
                UI::EndDisabled();
                UI::Separator();
                UI::SetNextItemWidth(220.0f);
                S_OutlineAlpha = UI::SliderFloat("Outline alpha##trigger-visualizer-color", S_OutlineAlpha, 0.0f, 1.0f);
                UI::SetNextItemWidth(220.0f);
                S_FillAlpha = UI::SliderFloat("Fill alpha##trigger-visualizer-color", S_FillAlpha, 0.0f, 1.0f);
                UI::SetNextItemWidth(220.0f);
                S_OutlineWidth = UI::SliderFloat(
                    "Outline width##trigger-visualizer-color",
                    S_OutlineWidth,
                    0.5f,
                    16.0f,
                    "%.1f px"
                );
                UI::Separator();
                S_RandomOutlineSegmentColors = UI::Checkbox(
                    "Random color per outline segment##trigger-visualizer-color",
                    S_RandomOutlineSegmentColors
                );
                S_RandomFillTileColors = UI::Checkbox(
                    "Random color per fill section/tile##trigger-visualizer-color",
                    S_RandomFillTileColors
                );
                ClampWorldRenderingSettings();
                ClampColorSettings();
            }
        }
    }
}
