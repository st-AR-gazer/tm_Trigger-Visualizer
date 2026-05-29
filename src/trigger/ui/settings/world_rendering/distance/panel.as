namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
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
                if (UI::Button("-##" + id + "-prev-block", vec2(buttonSize, buttonSize))) {
                    value = SnapWorldDistanceToPreviousBlock(value, blockSize);
                }

                UI::SameLine();
                if (UI::Button("+##" + id + "-next-block", vec2(buttonSize, buttonSize))) {
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
                    S_RenderProximityModeReplayEditor = value;
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

            void RenderDistanceProfileSettingsUI(int context, const string &in id, const string &in description) {
                UI::Text(GetDistanceSettingsContextLabel(context) + " Distance");
                UI::TextDisabled(description);

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

            void RenderWorldDistanceSettingsUI() {
                UI::BeginTabBar("trigger-visualizer-distance-profile-tabs");

                if (UI::BeginTabItem("Playing")) {
                    RenderDistanceProfileSettingsUI(
                        DISTANCE_SETTINGS_PLAYING,
                        "playing",
                        "Used in playable maps and editor test mode."
                    );
                    UI::EndTabItem();
                }

                if (UI::BeginTabItem("Editor")) {
                    RenderDistanceProfileSettingsUI(
                        DISTANCE_SETTINGS_EDITOR,
                        "editor",
                        "Used in the normal map editor."
                    );
                    UI::EndTabItem();
                }

                if (UI::BeginTabItem("MediaTracker")) {
                    RenderDistanceProfileSettingsUI(
                        DISTANCE_SETTINGS_MEDIATRACKER,
                        "mediatracker",
                        "Used in Editor MediaTracker and Replay Editor."
                    );
                    UI::EndTabItem();
                }

                UI::EndTabBar();
            }

        }
    }
}
