namespace TriggerVisualizer {
    namespace Trigger {
        namespace Ui {
            float SnapWorldDistanceToPreviousBlock(float value, float blockSize) {
                if (blockSize <= 0.0f) return value;

                float blocks = value / blockSize;
                float snappedBlocks = Math::Floor(blocks);
                if (Math::Abs(snappedBlocks - blocks) <= 0.001f) {
                    snappedBlocks -= 1.0f;
                }

                return Math::Clamp(snappedBlocks * blockSize, 0.0f, WORLD_RENDER_SETTING_MAX);
            }

            float SnapWorldDistanceToNextBlock(float value, float blockSize) {
                if (blockSize <= 0.0f) return value;

                float blocks = value / blockSize;
                float snappedBlocks = Math::Ceil(blocks);
                if (Math::Abs(snappedBlocks - blocks) <= 0.001f) {
                    snappedBlocks += 1.0f;
                }

                return Math::Clamp(snappedBlocks * blockSize, 0.0f, WORLD_RENDER_SETTING_MAX);
            }

            float RenderWorldDistanceSlider(
                const string &in label,
                const string &in id,
                float value,
                float minValue,
                float maxValue,
                float blockSize
            ) {
                UI::SetNextItemWidth(260.0f);
                value = UI::SliderFloat(label + "##" + id, value, minValue, maxValue, "%.0f m");
                float buttonSize = UI::GetFrameHeight();
                UI::SameLine();
                if (TriggerVisualizer::Shared::StyledButton("-##" + id + "-prev-block", vec2(buttonSize, buttonSize))) {
                    value = SnapWorldDistanceToPreviousBlock(value, blockSize);
                }
                UI::SameLine();
                if (TriggerVisualizer::Shared::StyledButton("+##" + id + "-next-block", vec2(buttonSize, buttonSize))) {
                    value = SnapWorldDistanceToNextBlock(value, blockSize);
                }
                UI::SameLine();
                UI::TextDisabled("~" + Text::Format("%.1f", value / blockSize) + " blocks");
                return value;
            }

            int GetRenderProximityModeForDistanceContext(int context) {
                if (context == DISTANCE_SETTINGS_EDITOR) return S_RenderProximityModeEditor;
                if (context == DISTANCE_SETTINGS_MEDIATRACKER) return S_RenderProximityModeMediaTracker;
                return S_RenderProximityMode;
            }

            void SetRenderProximityModeForDistanceContext(int context, int value) {
                if (context == DISTANCE_SETTINGS_EDITOR) {
                    S_RenderProximityModeEditor = value;
                    return;
                }

                if (context == DISTANCE_SETTINGS_MEDIATRACKER) {
                    S_RenderProximityModeMediaTracker = value;
                    return;
                }

                S_RenderProximityMode = value;
            }

            int RenderProximityComboForDistanceContext(int context, const string &in id, int value) {
                if (context == DISTANCE_SETTINGS_PLAYING) {
                    return RenderProximityComboPlaying("Render based on", id, value);
                }

                return RenderProximityComboEditor("Render based on", id, value);
            }

            void RenderDistanceProfileSettingsUi(int context, const string &in id) {
                int proximityMode = GetRenderProximityModeForDistanceContext(context);
                proximityMode = RenderProximityComboForDistanceContext(
                    context,
                    "trigger-visualizer-distance-proximity-" + id,
                    proximityMode
                );
                SetRenderProximityModeForDistanceContext(context, proximityMode);
                UI::Separator();
                bool unlimited = IsUnlimitedRenderDistanceForContext(context);
                unlimited = UI::Checkbox(
                    "Unlimited render distance##trigger-visualizer-settings-unlimited-distance-" + id,
                    unlimited
                );
                SetUnlimitedRenderDistanceForContext(context, unlimited);
                float distanceXZ = GetRenderDistanceXZForContext(context);
                float distanceY = GetRenderDistanceYForContext(context);
                float fadeXZ = GetRenderFadeBandXZForContext(context);
                float fadeY = GetRenderFadeBandYForContext(context);
                distanceXZ = RenderWorldDistanceSlider(
                    "Render distance X/Z",
                    "trigger-visualizer-settings-render-distance-xz-" + id,
                    distanceXZ,
                    0.0f,
                    WORLD_RENDER_SLIDER_MAX_XZ,
                    WORLD_BLOCK_SIZE_XZ
                );
                distanceY = RenderWorldDistanceSlider(
                    "Render distance Y",
                    "trigger-visualizer-settings-render-distance-y-" + id,
                    distanceY,
                    0.0f,
                    WORLD_RENDER_SLIDER_MAX_Y,
                    WORLD_BLOCK_SIZE_Y
                );
                fadeXZ = RenderWorldDistanceSlider(
                    "Render fade X/Z",
                    "trigger-visualizer-settings-render-fade-xz-" + id,
                    fadeXZ,
                    0.0f,
                    WORLD_FADE_SLIDER_MAX_XZ,
                    WORLD_BLOCK_SIZE_XZ
                );
                fadeY = RenderWorldDistanceSlider(
                    "Render fade Y",
                    "trigger-visualizer-settings-render-fade-y-" + id,
                    fadeY,
                    0.0f,
                    WORLD_FADE_SLIDER_MAX_Y,
                    WORLD_BLOCK_SIZE_Y
                );
                SetRenderDistanceForContext(context, distanceXZ, distanceY);
                SetRenderFadeBandForContext(context, fadeXZ, fadeY);
                bool useMapDistance = UseMapSuggestedDrawDistanceForContext(context);
                useMapDistance = UI::Checkbox(
                    "Use map-suggested draw distance##trigger-visualizer-settings-map-distance-" + id,
                    useMapDistance
                );
                SetUseMapSuggestedDrawDistanceForContext(context, useMapDistance);
                ClampWorldRenderingSettings();
                ClampProximitySettings();
            }

            void RenderWorldDistanceSettingsUi() {
                UI::BeginTabBar("trigger-visualizer-distance-profile-tabs");
                if (UI::BeginTabItem("Playing")) {
                    RenderDistanceProfileSettingsUi(
                        DISTANCE_SETTINGS_PLAYING,
                        "playing"
                    );
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Editor")) {
                    RenderDistanceProfileSettingsUi(
                        DISTANCE_SETTINGS_EDITOR,
                        "editor"
                    );
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("MediaTracker")) {
                    RenderDistanceProfileSettingsUi(
                        DISTANCE_SETTINGS_MEDIATRACKER,
                        "mediatracker"
                    );
                    UI::EndTabItem();
                }
                UI::EndTabBar();
            }
        }
    }
}
