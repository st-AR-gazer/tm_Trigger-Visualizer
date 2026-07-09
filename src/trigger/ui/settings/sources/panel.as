namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            string GetRuntimeSourceContextLabel(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                if (ctx is null || !ctx.HasMap) return "No RootMap";
                if (ctx.IsReplayEditor) return "Replay Editor";
                if (ctx.IsEditorMediaTracker) return "Editor MediaTracker";
                if (ctx.IsEditorTestMode) return "Editor Test Mode";
                if (ctx.IsMeshModeler) return "Mesh Modeller";
                if (ctx.IsInEditor) return "Editor";
                if (ctx.IsPlayableMap) return "Playable Map";
                return "Loaded RootMap";
            }

            bool IsOffzoneSourceEnabledForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                return ctx !is null && ctx.HasMap && IsOffzoneSourceEnabledForContext(GetSourceSettingsContextForRuntime(ctx));
            }

            bool IsMediaTrackerSourceEnabledForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                return ctx !is null && ctx.HasMap && IsMediaTrackerSourceEnabledForContext(GetSourceSettingsContextForRuntime(ctx));
            }

            bool IsCrystalSourceSupportedForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                return ctx !is null
                    && ctx.HasMap
                    && (ctx.IsPlayableMap || ctx.IsEditorTestMode || ctx.IsMapEditor || ctx.IsMeshModeler || ctx.IsInEditor || ctx.IsEditorMediaTracker || ctx.IsReplayEditor);
            }

            bool IsCrystalSourceEnabledForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                return IsCrystalSourceSupportedForRuntime(ctx)
                    && (S_CrystalCustomItemsAndBlockItemsOnly || IsCrystalSourceEnabledForContext(GetSourceSettingsContextForRuntime(ctx)));
            }

            string SettingBoolKey(bool value) {
                return value ? "1" : "0";
            }

            bool IsMediaTrackerKnownSubtypeDisabledForContext(
                const TriggerVolume@ volume,
                int context,
                const string &in targetKey
            ) {
                return TriggerVisualizer::Trigger::TriggerVolumeMatchesTargetKey(volume, targetKey)
                    && !IsMediaTrackerSubtypeEnabledForContext(context, targetKey);
            }

            bool IsTriggerVolumeEnabledBySubtypeSettings(
                const TriggerVolume@ volume,
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx
            ) {
                if (volume is null || volume.Source != TriggerVisualizer::Trigger::TRIGGER_SOURCE_MEDIATRACKER) {
                    return true;
                }

                int context = GetSourceSettingsContextForRuntime(ctx);
                if (TriggerVisualizer::Trigger::TriggerVolumeMatchesTargetKey(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_GPS)) {
                    return IsMediaTrackerSubtypeEnabledForContext(context, TriggerVisualizer::Trigger::MT_SUBTYPE_GPS);
                }

                const string[] keys = {
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CUSTOM_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_ORBITAL_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PATH_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_2D_TRIANGLES,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_3D_TRIANGLES,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CAR_TRAILS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_COLORS_FX,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_COLOR_GRADING,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_DEPTH_OF_FIELD,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_DIRTY_LENS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_EDITING_CUT,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_FADING_TRANSITION,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_FOG,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_GHOST,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_HDR_BLOOM,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_IMAGE,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_INERTIAL_TRACKING_CAM_FX,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MANIALINK_UI,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MANIALINK_URL,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MUSIC_VOLUME,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_OPPONENT_VISIBILITY,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SHAKE_CAM_FX,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_STEREO_3D,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SOUND_FX,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SPECTATORS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TEXT,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TIME,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TIME_SPEED,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TONE_MAPPING,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_VEHICLE_LIGHTS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_RESET,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MIXED,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_UNKNOWN
                };

                for (uint i = 0; i < keys.Length; i++) {
                    if (IsMediaTrackerKnownSubtypeDisabledForContext(volume, context, keys[i])) return false;
                }
                return true;
            }

            bool IsTriggerVolumeEnabledBySubtypeSettings(const TriggerVolume@ volume) {
                return IsTriggerVolumeEnabledBySubtypeSettings(
                    volume,
                    TriggerVisualizer::Trigger::GetCurrentRuntimeContext()
                );
            }

            string GetMapSnapshotFilterSettingsKey(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                int context = GetSourceSettingsContextForRuntime(ctx);
                return "src-profile:" + tostring(context)
                    + "|merge:" + SettingBoolKey(S_MergeAdjacentTriggerVolumes)
                    + "|suggest:" + SettingBoolKey(S_RespectMapSuggestOff)
                    + "|offzone:" + SettingBoolKey(IsOffzoneSourceEnabledForContext(context))
                    + "|mt:" + SettingBoolKey(IsMediaTrackerSourceEnabledForContext(context))
                    + "|crystal:" + SettingBoolKey(IsCrystalSourceEnabledForContext(context))
                    + "|crystal-custom-items:" + SettingBoolKey(S_CrystalCustomItemsAndBlockItemsOnly)
                    + "|mt-types:" + GetMediaTrackerEnabledSubtypesForContext(context);
            }

            string GetMapSnapshotFilterSettingsKey() {
                return GetMapSnapshotFilterSettingsKey(TriggerVisualizer::Trigger::GetCurrentRuntimeContext());
            }

            bool RenderSourceProfileToggleUI(const string &in label, const string &in id, bool value) {
                return UI::Checkbox(label + "##trigger-visualizer-sources-" + id, value);
            }

            bool RenderSourceActionButtonUI(const string &in label) {
                return TriggerVisualizer::Shared::StyledButton(label);
            }

            void RenderMediaTrackerSubtypeToggleUI(int context, const string &in label, const string &in key) {
                bool value = IsMediaTrackerSubtypeEnabledForContext(context, key);
                bool next = UI::Checkbox(
                    label + "##trigger-visualizer-sources-mediatracker-subtype-" + tostring(context) + "-" + key,
                    value
                );
                if (next != value) {
                    SetMediaTrackerSubtypeEnabledForContext(context, key, next);
                }
            }

            void RenderMediaTrackerSubtypeToolbarUI(int context, const array<string> &in keys, const string &in id) {
                string suffix = "##trigger-visualizer-sources-mediatracker-" + tostring(context) + "-" + id;
                if (RenderSourceActionButtonUI("Flip all" + suffix + "-flip")) {
                    FlipMediaTrackerSubtypeKeysForContext(context, keys);
                }
                UI::SameLine();
                if (RenderSourceActionButtonUI("Show all" + suffix + "-show-all")) {
                    SetMediaTrackerSubtypeKeysForContext(context, keys, true);
                }
                UI::SameLine();
                if (RenderSourceActionButtonUI("Hide all" + suffix + "-hide-all")) {
                    SetMediaTrackerSubtypeKeysForContext(context, keys, false);
                }
                UI::Separator();
            }

            void RenderMediaTrackerSubtypeCategoryCamerasUI(int context) {
                const string[] keys = {
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CUSTOM_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_ORBITAL_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PATH_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR
                };
                RenderMediaTrackerSubtypeToolbarUI(context, keys, "cameras");
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Camera (all)",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CAMERA
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Custom Camera",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CUSTOM_CAMERA
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Orbital Camera",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_ORBITAL_CAMERA
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Path Camera",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PATH_CAMERA
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Player Camera",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA
                );
                UI::Indent();
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show CamDefault",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Cam1",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Cam2",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Cam3",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show CamHelico",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show CamFree",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show CamSpectator",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR
                );
                UI::Unindent();
            }

            void RenderMediaTrackerSubtypeCategoryVisualFxUI(int context) {
                const string[] keys = {
                    TriggerVisualizer::Trigger::MT_SUBTYPE_2D_TRIANGLES,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_3D_TRIANGLES,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_COLORS_FX,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_COLOR_GRADING,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_DEPTH_OF_FIELD,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_DIRTY_LENS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_FADING_TRANSITION,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_FOG,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_HDR_BLOOM,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_IMAGE,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_INERTIAL_TRACKING_CAM_FX,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SHAKE_CAM_FX,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_STEREO_3D,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TONE_MAPPING,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_VEHICLE_LIGHTS
                };
                RenderMediaTrackerSubtypeToolbarUI(context, keys, "visual-fx");
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show 2D Triangles / 2dTriangles",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_2D_TRIANGLES
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show 3D Triangles / 3dTriangles",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_3D_TRIANGLES
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Colors FX",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_COLORS_FX
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Color Grading",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_COLOR_GRADING
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Depth of Field",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_DEPTH_OF_FIELD
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Dirty Lens",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_DIRTY_LENS
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Fading Transition",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_FADING_TRANSITION
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Fog",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_FOG
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show HDR Bloom",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_HDR_BLOOM
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Image",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_IMAGE
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Inertial Tracking CamFX",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_INERTIAL_TRACKING_CAM_FX
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Shake Cam FX",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SHAKE_CAM_FX
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Stereo 3D",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_STEREO_3D
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show ToneMapping",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TONE_MAPPING
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Vehicle Lights",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_VEHICLE_LIGHTS
                );
            }

            void RenderMediaTrackerSubtypeCategoryGameplayUiUI(int context) {
                const string[] keys = {
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CAR_TRAILS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_GHOST,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MANIALINK_UI,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MANIALINK_URL,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MUSIC_VOLUME,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_OPPONENT_VISIBILITY,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SOUND_FX,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SPECTATORS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TEXT,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TIME,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TIME_SPEED
                };
                RenderMediaTrackerSubtypeToolbarUI(context, keys, "gameplay-ui");
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Car Trails",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CAR_TRAILS
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Ghost",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_GHOST
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show ManiaLink UI",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MANIALINK_UI
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show ManiaLink URL",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MANIALINK_URL
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Music Volume",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MUSIC_VOLUME
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Opponent Visibility",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_OPPONENT_VISIBILITY
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Sound FX",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SOUND_FX
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Spectators",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SPECTATORS
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Text",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TEXT
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Time",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TIME
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Time Speed",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TIME_SPEED
                );
            }

            void RenderMediaTrackerSubtypeCategoryOtherUI(int context) {
                const string[] keys = {
                    TriggerVisualizer::Trigger::MT_SUBTYPE_GPS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_EDITING_CUT,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_RESET,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MIXED,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_UNKNOWN
                };
                RenderMediaTrackerSubtypeToolbarUI(context, keys, "other");
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show GPS",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_GPS
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Editing Cut",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_EDITING_CUT
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Reset / empty clips",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_RESET
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Mixed",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MIXED
                );
                RenderMediaTrackerSubtypeToggleUI(
                    context,
                    "Show Unknown",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_UNKNOWN
                );
            }

            void RenderAllMediaTrackerSubtypeToolbarUI(int context) {
                const string[] keys = {
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CUSTOM_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_ORBITAL_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PATH_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_2D_TRIANGLES,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_3D_TRIANGLES,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CAR_TRAILS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_COLORS_FX,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_COLOR_GRADING,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_DEPTH_OF_FIELD,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_DIRTY_LENS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_EDITING_CUT,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_FADING_TRANSITION,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_FOG,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_GHOST,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_GPS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_HDR_BLOOM,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_IMAGE,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_INERTIAL_TRACKING_CAM_FX,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MANIALINK_UI,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MANIALINK_URL,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MUSIC_VOLUME,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_OPPONENT_VISIBILITY,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SHAKE_CAM_FX,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_STEREO_3D,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SOUND_FX,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SPECTATORS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TEXT,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TIME,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TIME_SPEED,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TONE_MAPPING,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_VEHICLE_LIGHTS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_RESET,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MIXED,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_UNKNOWN
                };
                string suffix = "##trigger-visualizer-sources-mediatracker-profile-" + tostring(context);
                if (RenderSourceActionButtonUI("Flip all MediaTracker types" + suffix + "-flip")) {
                    FlipMediaTrackerSubtypeKeysForContext(context, keys);
                }
                UI::SameLine();
                if (RenderSourceActionButtonUI("Show all" + suffix + "-show-all")) {
                    SetMediaTrackerSubtypeKeysForContext(context, keys, true);
                }
                UI::SameLine();
                if (RenderSourceActionButtonUI("Hide all" + suffix + "-hide-all")) {
                    SetMediaTrackerSubtypeKeysForContext(context, keys, false);
                }
                UI::SameLine();
                if (RenderSourceActionButtonUI("Reset profile" + suffix + "-reset")) {
                    SetMediaTrackerEnabledSubtypesForContext(
                        context,
                        GetDefaultMediaTrackerEnabledSubtypesForContext(context)
                    );
                }
            }

            void RenderMediaTrackerSubtypeSettingsUI(int context) {
                RenderAllMediaTrackerSubtypeToolbarUI(context);
                UI::Separator();
                UI::BeginTabBar("trigger-visualizer-mediatracker-subtype-tabs-" + tostring(context));
                if (UI::BeginTabItem("Cameras")) {
                    RenderMediaTrackerSubtypeCategoryCamerasUI(context);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Visual FX")) {
                    RenderMediaTrackerSubtypeCategoryVisualFxUI(context);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Gameplay/UI")) {
                    RenderMediaTrackerSubtypeCategoryGameplayUiUI(context);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Other")) {
                    RenderMediaTrackerSubtypeCategoryOtherUI(context);
                    UI::EndTabItem();
                }
                UI::EndTabBar();
            }

            void RenderSourceProfileSettingsUI(int context) {
                bool offzoneValue = IsOffzoneSourceEnabledForContext(context);
                bool offzoneNext = RenderSourceProfileToggleUI(
                    "Show Offzone",
                    "offzone-profile-" + tostring(context),
                    offzoneValue
                );
                if (offzoneNext != offzoneValue) SetOffzoneSourceEnabledForContext(context, offzoneNext);

                bool mediaTrackerValue = IsMediaTrackerSourceEnabledForContext(context);
                bool mediaTrackerNext = RenderSourceProfileToggleUI(
                    "Show MediaTracker",
                    "mediatracker-profile-" + tostring(context),
                    mediaTrackerValue
                );
                if (mediaTrackerNext != mediaTrackerValue) SetMediaTrackerSourceEnabledForContext(
                    context,
                    mediaTrackerNext
                );

                bool crystalValue = IsCrystalSourceEnabledForContext(context);
                UI::BeginDisabled(S_CrystalCustomItemsAndBlockItemsOnly);
                bool crystalNext = RenderSourceProfileToggleUI(
                    "Show Crystal",
                    "crystal-profile-" + tostring(context),
                    crystalValue
                );
                UI::EndDisabled();
                if (!S_CrystalCustomItemsAndBlockItemsOnly && crystalNext != crystalValue) {
                    SetCrystalSourceEnabledForContext(context, crystalNext);
                }

                UI::Indent(18.0f);
                bool customOnlyNext = UI::Checkbox(
                    "Only scan custom blocks/items##trigger-visualizer-sources-crystal-custom-items",
                    S_CrystalCustomItemsAndBlockItemsOnly
                );
                UI::Unindent(18.0f);
                if (customOnlyNext != S_CrystalCustomItemsAndBlockItemsOnly) {
                    SetCrystalCustomItemsAndBlockItemsOnly(customOnlyNext);
                }
                if (IsMediaTrackerSourceEnabledForContext(context)) {
                    UI::Separator();
                    UI::Text("MediaTracker Types");
                    RenderMediaTrackerSubtypeSettingsUI(context);
                }
            }

            void RenderSourcesSettingsUI() {
                UI::BeginTabBar("trigger-visualizer-source-major-tabs");
                if (UI::BeginTabItem("Playing")) {
                    RenderSourceProfileSettingsUI(SOURCE_SETTINGS_PLAYING);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Editor")) {
                    RenderSourceProfileSettingsUI(SOURCE_SETTINGS_EDITOR);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Mesh Modeller")) {
                    RenderSourceProfileSettingsUI(SOURCE_SETTINGS_MESH_MODELLER);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("MediaTracker")) {
                    RenderSourceProfileSettingsUI(SOURCE_SETTINGS_MEDIATRACKER);
                    UI::EndTabItem();
                }
                UI::EndTabBar();
            }
        }
    }
}
