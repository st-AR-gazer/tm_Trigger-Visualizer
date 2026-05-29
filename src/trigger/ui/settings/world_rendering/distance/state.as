namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            const int PROXIMITY_MODE_CAMERA_ONLY = 0;
            const int PROXIMITY_MODE_VEHICLE_ONLY = 1;
            const int PROXIMITY_MODE_CAMERA_AND_VEHICLE = 2;
            const int PROXIMITY_MODE_ORBITAL_ONLY = 3;
            const int PROXIMITY_MODE_CAMERA_AND_ORBITAL = 4;
            const int PROXIMITY_MODE_VEHICLE_AND_ORBITAL = 5;
            const int PROXIMITY_MODE_CAMERA_VEHICLE_AND_ORBITAL = 6;

            const float WORLD_BLOCK_SIZE_XZ = 32.0f;
            const float WORLD_BLOCK_SIZE_Y = 8.0f;
            const float WORLD_RENDER_SLIDER_MAX_XZ = WORLD_BLOCK_SIZE_XZ * 48.0f;
            const float WORLD_RENDER_SLIDER_MAX_Y = WORLD_BLOCK_SIZE_Y * 40.0f;
            const float WORLD_FADE_SLIDER_MAX_XZ = WORLD_BLOCK_SIZE_XZ * 5.0f;
            const float WORLD_FADE_SLIDER_MAX_Y = WORLD_BLOCK_SIZE_Y * 5.0f;
            const float WORLD_RENDER_SETTING_MAX = 50000.0f;
            const int DISTANCE_SETTINGS_PLAYING = 0;
            const int DISTANCE_SETTINGS_EDITOR = 1;
            const int DISTANCE_SETTINGS_MEDIATRACKER = 2;

            [Setting hidden name="Trigger: Render distance XZ" min=0 max=50000]
            float S_RenderDistanceXZ = 224.0f;

            [Setting hidden name="Trigger: Render distance Y" min=0 max=50000]
            float S_RenderDistanceY = 56.0f;

            [Setting hidden name="Trigger: Render fade band XZ" min=0 max=50000]
            float S_RenderFadeBandXZ = 32.0f;

            [Setting hidden name="Trigger: Render fade band Y" min=0 max=50000]
            float S_RenderFadeBandY = 8.0f;

            [Setting hidden name="Trigger: Unlimited render distance"]
            bool S_UnlimitedRenderDistance = false;

            [Setting hidden name="Trigger: Use map suggested draw distance"]
            bool S_UseMapSuggestedDrawDistance = true;

            [Setting hidden name="Trigger: Render editor distance XZ" min=0 max=50000]
            float S_RenderDistanceXZEditor = 320.0f;

            [Setting hidden name="Trigger: Render editor distance Y" min=0 max=50000]
            float S_RenderDistanceYEditor = 80.0f;

            [Setting hidden name="Trigger: Render editor fade band XZ" min=0 max=50000]
            float S_RenderFadeBandXZEditor = 32.0f;

            [Setting hidden name="Trigger: Render editor fade band Y" min=0 max=50000]
            float S_RenderFadeBandYEditor = 8.0f;

            [Setting hidden name="Trigger: Unlimited editor render distance"]
            bool S_UnlimitedRenderDistanceEditor = false;

            [Setting hidden name="Trigger: Use editor map suggested draw distance"]
            bool S_UseMapSuggestedDrawDistanceEditor = true;

            [Setting hidden name="Trigger: Render MediaTracker distance XZ" min=0 max=50000]
            float S_RenderDistanceXZMediaTracker = 224.0f;

            [Setting hidden name="Trigger: Render MediaTracker distance Y" min=0 max=50000]
            float S_RenderDistanceYMediaTracker = 56.0f;

            [Setting hidden name="Trigger: Render MediaTracker fade band XZ" min=0 max=50000]
            float S_RenderFadeBandXZMediaTracker = 32.0f;

            [Setting hidden name="Trigger: Render MediaTracker fade band Y" min=0 max=50000]
            float S_RenderFadeBandYMediaTracker = 8.0f;

            [Setting hidden name="Trigger: Unlimited MediaTracker render distance"]
            bool S_UnlimitedRenderDistanceMediaTracker = false;

            [Setting hidden name="Trigger: Use MediaTracker map suggested draw distance"]
            bool S_UseMapSuggestedDrawDistanceMediaTracker = true;

            [Setting hidden name="Trigger: Render proximity mode" min=0 max=2]
            int S_RenderProximityMode = PROXIMITY_MODE_CAMERA_AND_VEHICLE;

            [Setting hidden name="Trigger: Render editor proximity mode" min=0 max=6]
            int S_RenderProximityModeEditor = PROXIMITY_MODE_CAMERA_AND_ORBITAL;

            [Setting hidden name="Trigger: Render MediaTracker proximity mode" min=0 max=6]
            int S_RenderProximityModeMediaTracker = PROXIMITY_MODE_CAMERA_AND_ORBITAL;

            [Setting hidden name="Trigger: Render replay editor proximity mode" min=0 max=6]
            int S_RenderProximityModeReplayEditor = PROXIMITY_MODE_CAMERA_AND_ORBITAL;

            int GetDistanceSettingsContextForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                if (ctx is null) return DISTANCE_SETTINGS_PLAYING;
                if (ctx.IsReplayEditor || ctx.IsEditorMediaTracker) return DISTANCE_SETTINGS_MEDIATRACKER;
                if (ctx.IsEditorTestMode || ctx.IsPlayableMap) return DISTANCE_SETTINGS_PLAYING;
                if (ctx.IsInEditor) return DISTANCE_SETTINGS_EDITOR;
                return DISTANCE_SETTINGS_PLAYING;
            }

            string GetDistanceSettingsContextLabel(int context) {
                if (context == DISTANCE_SETTINGS_EDITOR) return "Editor";
                if (context == DISTANCE_SETTINGS_MEDIATRACKER) return "MediaTracker";
                return "Playing";
            }

            float GetRenderDistanceXZForContext(int context) {
                if (context == DISTANCE_SETTINGS_EDITOR) return S_RenderDistanceXZEditor;
                if (context == DISTANCE_SETTINGS_MEDIATRACKER) return S_RenderDistanceXZMediaTracker;
                return S_RenderDistanceXZ;
            }

            float GetRenderDistanceYForContext(int context) {
                if (context == DISTANCE_SETTINGS_EDITOR) return S_RenderDistanceYEditor;
                if (context == DISTANCE_SETTINGS_MEDIATRACKER) return S_RenderDistanceYMediaTracker;
                return S_RenderDistanceY;
            }

            float GetRenderFadeBandXZForContext(int context) {
                if (context == DISTANCE_SETTINGS_EDITOR) return S_RenderFadeBandXZEditor;
                if (context == DISTANCE_SETTINGS_MEDIATRACKER) return S_RenderFadeBandXZMediaTracker;
                return S_RenderFadeBandXZ;
            }

            float GetRenderFadeBandYForContext(int context) {
                if (context == DISTANCE_SETTINGS_EDITOR) return S_RenderFadeBandYEditor;
                if (context == DISTANCE_SETTINGS_MEDIATRACKER) return S_RenderFadeBandYMediaTracker;
                return S_RenderFadeBandY;
            }

            bool IsUnlimitedRenderDistanceForContext(int context) {
                if (context == DISTANCE_SETTINGS_EDITOR) return S_UnlimitedRenderDistanceEditor;
                if (context == DISTANCE_SETTINGS_MEDIATRACKER) return S_UnlimitedRenderDistanceMediaTracker;
                return S_UnlimitedRenderDistance;
            }

            bool UseMapSuggestedDrawDistanceForContext(int context) {
                if (context == DISTANCE_SETTINGS_EDITOR) return S_UseMapSuggestedDrawDistanceEditor;
                if (context == DISTANCE_SETTINGS_MEDIATRACKER) return S_UseMapSuggestedDrawDistanceMediaTracker;
                return S_UseMapSuggestedDrawDistance;
            }

            void SetRenderDistanceForContext(int context, float xz, float y) {
                if (context == DISTANCE_SETTINGS_EDITOR) {
                    S_RenderDistanceXZEditor = xz;
                    S_RenderDistanceYEditor = y;
                    return;
                }

                if (context == DISTANCE_SETTINGS_MEDIATRACKER) {
                    S_RenderDistanceXZMediaTracker = xz;
                    S_RenderDistanceYMediaTracker = y;
                    return;
                }

                S_RenderDistanceXZ = xz;
                S_RenderDistanceY = y;
            }

            void SetRenderFadeBandForContext(int context, float xz, float y) {
                if (context == DISTANCE_SETTINGS_EDITOR) {
                    S_RenderFadeBandXZEditor = xz;
                    S_RenderFadeBandYEditor = y;
                    return;
                }

                if (context == DISTANCE_SETTINGS_MEDIATRACKER) {
                    S_RenderFadeBandXZMediaTracker = xz;
                    S_RenderFadeBandYMediaTracker = y;
                    return;
                }

                S_RenderFadeBandXZ = xz;
                S_RenderFadeBandY = y;
            }

            void SetUnlimitedRenderDistanceForContext(int context, bool value) {
                if (context == DISTANCE_SETTINGS_EDITOR) {
                    S_UnlimitedRenderDistanceEditor = value;
                    return;
                }

                if (context == DISTANCE_SETTINGS_MEDIATRACKER) {
                    S_UnlimitedRenderDistanceMediaTracker = value;
                    return;
                }

                S_UnlimitedRenderDistance = value;
            }

            void SetUseMapSuggestedDrawDistanceForContext(int context, bool value) {
                if (context == DISTANCE_SETTINGS_EDITOR) {
                    S_UseMapSuggestedDrawDistanceEditor = value;
                    return;
                }

                if (context == DISTANCE_SETTINGS_MEDIATRACKER) {
                    S_UseMapSuggestedDrawDistanceMediaTracker = value;
                    return;
                }

                S_UseMapSuggestedDrawDistance = value;
            }

            bool IsUnlimitedRenderDistanceForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                return IsUnlimitedRenderDistanceForContext(GetDistanceSettingsContextForRuntime(ctx));
            }

            bool UseMapSuggestedDrawDistanceForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                return UseMapSuggestedDrawDistanceForContext(GetDistanceSettingsContextForRuntime(ctx));
            }

            vec3 GetRenderDistanceWorldForContext(int context) {
                return vec3(
                    GetRenderDistanceXZForContext(context),
                    GetRenderDistanceYForContext(context),
                    GetRenderDistanceXZForContext(context)
                );
            }

            vec3 GetRenderDistanceWorldForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                return GetRenderDistanceWorldForContext(GetDistanceSettingsContextForRuntime(ctx));
            }

            vec3 GetRenderDistanceWorld() {
                return GetRenderDistanceWorldForRuntime(TriggerVisualizer::Trigger::GetCurrentRuntimeContext());
            }

            vec3 GetRenderFadeBandWorldForContext(int context) {
                return vec3(
                    GetRenderFadeBandXZForContext(context),
                    GetRenderFadeBandYForContext(context),
                    GetRenderFadeBandXZForContext(context)
                );
            }

            vec3 GetRenderFadeBandWorldForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                return GetRenderFadeBandWorldForContext(GetDistanceSettingsContextForRuntime(ctx));
            }

            vec3 GetRenderFadeBandWorld() {
                return GetRenderFadeBandWorldForRuntime(TriggerVisualizer::Trigger::GetCurrentRuntimeContext());
            }

        }
    }
}
