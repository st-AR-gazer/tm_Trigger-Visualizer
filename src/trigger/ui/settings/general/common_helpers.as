namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            string GetColorModeLabel(int mode) {
                if (mode == COLOR_MODE_DISTANCE_FADE) return "Distance fade";
                if (mode == COLOR_MODE_LINE_SPLIT_DENSITY) return "Line split density";
                if (mode == COLOR_MODE_MEDIATRACKER_TRACK_COLORS) return "MediaTracker track colors";
                return "Uniform color";
            }

            string GetColorSourceLabel(int source) {
                if (source == COLOR_SOURCE_MEDIATRACKER_TRACK_COLORS) return "MediaTracker track colors";
                return "Uniform color";
            }

            string GetRenderProximityModeLabel(int mode) {
                if (mode == PROXIMITY_MODE_VEHICLE_ONLY) return "Vehicle only";
                if (mode == PROXIMITY_MODE_CAMERA_AND_VEHICLE) return "Camera + vehicle";
                if (mode == PROXIMITY_MODE_ORBITAL_ONLY) return "Orbital point only";
                if (mode == PROXIMITY_MODE_CAMERA_AND_ORBITAL) return "Camera + orbital point";
                if (mode == PROXIMITY_MODE_VEHICLE_AND_ORBITAL) return "Vehicle + orbital point";
                if (mode == PROXIMITY_MODE_CAMERA_VEHICLE_AND_ORBITAL) return "Camera + vehicle + orbital point";
                return "Camera only";
            }

            string GetRuntimeAreaLabel(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                if (ctx is null) return "Playing";
                if (ctx.IsReplayEditor) return "Replay Editor";
                if (ctx.IsEditorMediaTracker) return "Editor MediaTracker";
                if (ctx.IsEditorTestMode) return "Playing (editor test mode)";
                if (ctx.IsInEditor) return "Editor";
                return "Playing";
            }

            bool IsPlayingProximityMode(int mode) {
                return mode == PROXIMITY_MODE_CAMERA_ONLY
                    || mode == PROXIMITY_MODE_VEHICLE_ONLY
                    || mode == PROXIMITY_MODE_CAMERA_AND_VEHICLE;
            }

            bool IsEditorProximityMode(int mode) {
                return mode == PROXIMITY_MODE_CAMERA_ONLY
                    || mode == PROXIMITY_MODE_ORBITAL_ONLY
                    || mode == PROXIMITY_MODE_CAMERA_AND_ORBITAL;
            }

            void ClampProximitySettings() {
                if (!IsPlayingProximityMode(S_RenderProximityMode)) {
                    S_RenderProximityMode = PROXIMITY_MODE_CAMERA_AND_VEHICLE;
                }
                if (!IsEditorProximityMode(S_RenderProximityModeEditor)) {
                    S_RenderProximityModeEditor = PROXIMITY_MODE_CAMERA_AND_ORBITAL;
                }
                if (!IsEditorProximityMode(S_RenderProximityModeMediaTracker)) {
                    S_RenderProximityModeMediaTracker = PROXIMITY_MODE_CAMERA_AND_ORBITAL;
                }
                S_RenderProximityModeReplayEditor = S_RenderProximityModeMediaTracker;
            }

            int GetRenderProximityModeForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                ClampProximitySettings();
                if (ctx is null) return S_RenderProximityMode;
                if (ctx.IsReplayEditor) return S_RenderProximityModeMediaTracker;
                if (ctx.IsEditorMediaTracker) return S_RenderProximityModeMediaTracker;
                if (ctx.IsEditorTestMode) return S_RenderProximityMode;
                if (ctx.IsInEditor) return S_RenderProximityModeEditor;
                return S_RenderProximityMode;
            }

            void RenderColorSourceOption(int source) {
                bool selected = S_ColorSource == source;
                if (UI::Selectable(GetColorSourceLabel(source), selected)) {
                    S_ColorSource = source;
                }
            }

            bool RenderProximityModeOption(int mode, int currentMode) {
                bool selected = currentMode == mode;
                if (UI::Selectable(GetRenderProximityModeLabel(mode), selected)) {
                    return true;
                }
                return false;
            }

            int RenderProximityComboPlaying(const string &in label, const string &in id, int value) {
                if (UI::BeginCombo(label + "##" + id, GetRenderProximityModeLabel(value))) {
                    if (RenderProximityModeOption(PROXIMITY_MODE_CAMERA_ONLY, value)) value = PROXIMITY_MODE_CAMERA_ONLY;
                    if (RenderProximityModeOption(PROXIMITY_MODE_VEHICLE_ONLY, value)) value = PROXIMITY_MODE_VEHICLE_ONLY;
                    if (RenderProximityModeOption(PROXIMITY_MODE_CAMERA_AND_VEHICLE, value)) value = PROXIMITY_MODE_CAMERA_AND_VEHICLE;
                    UI::EndCombo();
                }
                if (!IsPlayingProximityMode(value)) value = PROXIMITY_MODE_CAMERA_AND_VEHICLE;
                return value;
            }

            int RenderProximityComboEditor(const string &in label, const string &in id, int value) {
                if (UI::BeginCombo(label + "##" + id, GetRenderProximityModeLabel(value))) {
                    if (RenderProximityModeOption(PROXIMITY_MODE_CAMERA_ONLY, value)) value = PROXIMITY_MODE_CAMERA_ONLY;
                    if (RenderProximityModeOption(PROXIMITY_MODE_ORBITAL_ONLY, value)) value = PROXIMITY_MODE_ORBITAL_ONLY;
                    if (RenderProximityModeOption(PROXIMITY_MODE_CAMERA_AND_ORBITAL, value)) value = PROXIMITY_MODE_CAMERA_AND_ORBITAL;
                    UI::EndCombo();
                }
                if (!IsEditorProximityMode(value)) value = PROXIMITY_MODE_CAMERA_AND_ORBITAL;
                return value;
            }

            void RenderProximitySettingsUI() {
                RenderWorldDistanceSettingsUI();
            }
        }
    }
}
