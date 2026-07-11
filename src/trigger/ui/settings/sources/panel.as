namespace TriggerVisualizer {
    namespace Trigger {
        namespace Ui {
            bool IsOffzoneSourceEnabledForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                if (ctx is null || !ctx.HasMap) return false;

                bool enabled = false;
                if (TryGetMapOnlySourceEnabled(ctx, TriggerVisualizer::Trigger::TRIGGER_SOURCE_OFFZONE, enabled)) {
                    return enabled;
                }
                return IsOffzoneSourceEnabledForContext(GetSourceSettingsContextForRuntime(ctx));
            }

            bool IsMediaTrackerSourceEnabledForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                if (ctx is null || !ctx.HasMap) return false;

                bool enabled = false;
                if (TryGetMapOnlySourceEnabled(ctx, TriggerVisualizer::Trigger::TRIGGER_SOURCE_MEDIATRACKER, enabled)) {
                    return enabled;
                }
                return IsMediaTrackerSourceEnabledForContext(GetSourceSettingsContextForRuntime(ctx));
            }

            bool IsCrystalSourceSupportedForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                return ctx !is null
                    && ctx.HasMap
                    && (ctx.IsPlayableMap || ctx.IsEditorTestMode || ctx.IsMapEditor || ctx.IsMeshModeler || ctx.IsInEditor || ctx.IsEditorMediaTracker || ctx.IsReplayEditor);
            }

            bool IsCrystalSourceEnabledForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                if (!IsCrystalSourceSupportedForRuntime(ctx)) return false;

                bool enabled = false;
                if (TryGetMapOnlySourceEnabled(ctx, TriggerVisualizer::Trigger::TRIGGER_SOURCE_CRYSTAL, enabled)) {
                    return enabled;
                }
                return IsCrystalCustomItemsAndBlockItemsOnlyForRuntime(ctx)
                    || IsCrystalSourceEnabledForContext(GetSourceSettingsContextForRuntime(ctx));
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
                    + "|suggest:" + SettingBoolKey(RespectMapSuggestOffForRuntime(ctx))
                    + "|offzone:" + SettingBoolKey(IsOffzoneSourceEnabledForRuntime(ctx))
                    + "|mt:" + SettingBoolKey(IsMediaTrackerSourceEnabledForRuntime(ctx))
                    + "|crystal:" + SettingBoolKey(IsCrystalSourceEnabledForRuntime(ctx))
                    + "|crystal-custom-items:" + SettingBoolKey(IsCrystalCustomItemsAndBlockItemsOnlyForRuntime(ctx))
                    + "|map-only:" + GetMapOnlyOverridesFilterKey(ctx)
                    + "|mt-types:" + GetMediaTrackerEnabledSubtypesForContext(context);
            }

            string GetMapSnapshotFilterSettingsKey() {
                return GetMapSnapshotFilterSettingsKey(TriggerVisualizer::Trigger::GetCurrentRuntimeContext());
            }

            bool RenderSourceProfileToggleUi(const string &in label, const string &in id, bool value) {
                return UI::Checkbox(label + "##trigger-visualizer-sources-" + id, value);
            }

            bool RenderSourceActionButtonUi(const string &in label) {
                return TriggerVisualizer::Shared::StyledButton(label);
            }

            void RenderMediaTrackerSubtypeToggleUi(int context, const string &in label, const string &in key) {
                bool value = IsMediaTrackerSubtypeEnabledForContext(context, key);
                bool next = UI::Checkbox(
                    label + "##trigger-visualizer-sources-mediatracker-subtype-" + tostring(context) + "-" + key,
                    value
                );
                if (next != value) {
                    SetMediaTrackerSubtypeEnabledForContext(context, key, next);
                }
            }

            void RenderMediaTrackerSubtypeToolbarUi(int context, const array<string> &in keys, const string &in id) {
                string suffix = "##trigger-visualizer-sources-mediatracker-" + tostring(context) + "-" + id;
                if (RenderSourceActionButtonUi("Flip all" + suffix + "-flip")) {
                    FlipMediaTrackerSubtypeKeysForContext(context, keys);
                }
                UI::SameLine();
                if (RenderSourceActionButtonUi("Show all" + suffix + "-show-all")) {
                    SetMediaTrackerSubtypeKeysForContext(context, keys, true);
                }
                UI::SameLine();
                if (RenderSourceActionButtonUi("Hide all" + suffix + "-hide-all")) {
                    SetMediaTrackerSubtypeKeysForContext(context, keys, false);
                }
                UI::Separator();
            }

            void RenderMediaTrackerSubtypeCategoryCamerasUi(int context) {
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
                RenderMediaTrackerSubtypeToolbarUi(context, keys, "cameras");
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Camera (all)",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CAMERA
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Custom Camera",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CUSTOM_CAMERA
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Orbital Camera",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_ORBITAL_CAMERA
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Path Camera",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PATH_CAMERA
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Player Camera",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA
                );
                UI::Indent();
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show CamDefault",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Cam1",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Cam2",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Cam3",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show CamHelico",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show CamFree",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show CamSpectator",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR
                );
                UI::Unindent();
            }

            void RenderMediaTrackerSubtypeCategoryVisualFxUi(int context) {
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
                RenderMediaTrackerSubtypeToolbarUi(context, keys, "visual-fx");
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show 2D Triangles / 2dTriangles",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_2D_TRIANGLES
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show 3D Triangles / 3dTriangles",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_3D_TRIANGLES
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Colors FX",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_COLORS_FX
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Color Grading",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_COLOR_GRADING
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Depth of Field",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_DEPTH_OF_FIELD
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Dirty Lens",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_DIRTY_LENS
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Fading Transition",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_FADING_TRANSITION
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Fog",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_FOG
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show HDR Bloom",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_HDR_BLOOM
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Image",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_IMAGE
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Inertial Tracking CamFX",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_INERTIAL_TRACKING_CAM_FX
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Shake Cam FX",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SHAKE_CAM_FX
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Stereo 3D",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_STEREO_3D
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show ToneMapping",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TONE_MAPPING
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Vehicle Lights",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_VEHICLE_LIGHTS
                );
            }

            void RenderMediaTrackerSubtypeCategoryGameplayInterfaceUi(int context) {
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
                RenderMediaTrackerSubtypeToolbarUi(context, keys, "gameplay-ui");
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Car Trails",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_CAR_TRAILS
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Ghost",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_GHOST
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show ManiaLink UI",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MANIALINK_UI
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show ManiaLink URL",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MANIALINK_URL
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Music Volume",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MUSIC_VOLUME
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Opponent Visibility",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_OPPONENT_VISIBILITY
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Sound FX",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SOUND_FX
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Spectators",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_SPECTATORS
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Text",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TEXT
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Time",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TIME
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Time Speed",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_TIME_SPEED
                );
            }

            void RenderMediaTrackerSubtypeCategoryOtherUi(int context) {
                const string[] keys = {
                    TriggerVisualizer::Trigger::MT_SUBTYPE_GPS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_EDITING_CUT,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_RESET,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MIXED,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_UNKNOWN
                };
                RenderMediaTrackerSubtypeToolbarUi(context, keys, "other");
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show GPS",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_GPS
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Editing Cut",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_EDITING_CUT
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Reset / empty clips",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_RESET
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Mixed",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MIXED
                );
                RenderMediaTrackerSubtypeToggleUi(
                    context,
                    "Show Unknown",
                    TriggerVisualizer::Trigger::MT_SUBTYPE_UNKNOWN
                );
            }

            void RenderAllMediaTrackerSubtypeToolbarUi(int context) {
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
                if (RenderSourceActionButtonUi("Flip all MediaTracker types" + suffix + "-flip")) {
                    FlipMediaTrackerSubtypeKeysForContext(context, keys);
                }
                UI::SameLine();
                if (RenderSourceActionButtonUi("Show all" + suffix + "-show-all")) {
                    SetMediaTrackerSubtypeKeysForContext(context, keys, true);
                }
                UI::SameLine();
                if (RenderSourceActionButtonUi("Hide all" + suffix + "-hide-all")) {
                    SetMediaTrackerSubtypeKeysForContext(context, keys, false);
                }
                UI::SameLine();
                if (RenderSourceActionButtonUi("Reset profile" + suffix + "-reset")) {
                    SetMediaTrackerEnabledSubtypesForContext(
                        context,
                        GetDefaultMediaTrackerEnabledSubtypesForContext(context)
                    );
                }
            }

            void RenderMediaTrackerSubtypeSettingsUi(int context) {
                RenderAllMediaTrackerSubtypeToolbarUi(context);
                UI::Separator();
                UI::BeginTabBar("trigger-visualizer-mediatracker-subtype-tabs-" + tostring(context));
                if (UI::BeginTabItem("Cameras")) {
                    RenderMediaTrackerSubtypeCategoryCamerasUi(context);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Visual FX")) {
                    RenderMediaTrackerSubtypeCategoryVisualFxUi(context);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Gameplay/UI")) {
                    RenderMediaTrackerSubtypeCategoryGameplayInterfaceUi(context);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Other")) {
                    RenderMediaTrackerSubtypeCategoryOtherUi(context);
                    UI::EndTabItem();
                }
                UI::EndTabBar();
            }

            void RenderSourceProfileSettingsUi(int context) {
                bool offzoneValue = IsOffzoneSourceEnabledForContext(context);
                bool offzoneNext = RenderSourceProfileToggleUi(
                    "Show Offzone",
                    "offzone-profile-" + tostring(context),
                    offzoneValue
                );
                if (offzoneNext != offzoneValue) SetOffzoneSourceEnabledForContext(context, offzoneNext);

                bool mediaTrackerValue = IsMediaTrackerSourceEnabledForContext(context);
                bool mediaTrackerNext = RenderSourceProfileToggleUi(
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
                bool crystalNext = RenderSourceProfileToggleUi(
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
                    RenderMediaTrackerSubtypeSettingsUi(context);
                }
            }

            void RenderSourcesSettingsUi() {
                UI::BeginTabBar("trigger-visualizer-source-major-tabs");
                if (UI::BeginTabItem("Playing")) {
                    RenderSourceProfileSettingsUi(SOURCE_SETTINGS_PLAYING);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Editor")) {
                    RenderSourceProfileSettingsUi(SOURCE_SETTINGS_EDITOR);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Mesh Modeler")) {
                    RenderSourceProfileSettingsUi(SOURCE_SETTINGS_MESH_MODELER);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("MediaTracker")) {
                    RenderSourceProfileSettingsUi(SOURCE_SETTINGS_MEDIATRACKER);
                    UI::EndTabItem();
                }
                UI::EndTabBar();
            }
        }
    }
}
