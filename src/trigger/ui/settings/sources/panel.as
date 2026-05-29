namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            string GetRuntimeSourceContextLabel(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                if (ctx is null || !ctx.HasMap) return "No RootMap";
                if (ctx.IsReplayEditor) return "Replay Editor";
                if (ctx.IsEditorMediaTracker) return "Editor MediaTracker";
                if (ctx.IsEditorTestMode) return "Editor Test Mode";
                if (ctx.IsInEditor) return "Editor";
                if (ctx.IsPlayableMap) return "Playable Map";
                return "Loaded RootMap";
            }

            bool IsSourceEnabledForRuntime(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                bool globalEnabled,
                bool showInPlayableMap,
                bool showInEditor,
                bool showInEditorTestMode,
                bool showInEditorMediaTracker,
                bool showInReplayEditor
            ) {
                if (!globalEnabled || ctx is null || !ctx.HasMap) return false;
                if (ctx.IsReplayEditor) return showInReplayEditor;
                if (ctx.IsEditorMediaTracker) return showInEditorMediaTracker;
                if (ctx.IsEditorTestMode) return showInEditorTestMode;
                if (ctx.IsInEditor) return showInEditor;
                if (ctx.IsPlayableMap) return showInPlayableMap;
                return true;
            }

            bool IsOffzoneSourceEnabledForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                return IsSourceEnabledForRuntime(
                    ctx,
                    S_ShowOffzoneSource,
                    S_ShowOffzoneInPlayableMap,
                    S_ShowOffzoneInEditor,
                    S_ShowOffzoneInEditorTestMode,
                    S_ShowOffzoneInEditorMediaTracker,
                    S_ShowOffzoneInReplayEditor
                );
            }

            bool IsMediaTrackerSourceEnabledForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                return IsSourceEnabledForRuntime(
                    ctx,
                    S_ShowMediaTrackerSource,
                    S_ShowMediaTrackerInPlayableMap,
                    S_ShowMediaTrackerInEditor,
                    S_ShowMediaTrackerInEditorTestMode,
                    S_ShowMediaTrackerInEditorMediaTracker,
                    S_ShowMediaTrackerInReplayEditor
                );
            }

            bool IsTriggerVolumeDisabledBySubtypeToggle(
                const TriggerVolume@ volume,
                const string &in targetKey,
                bool enabled
            ) {
                return !enabled && TriggerVisualizer::Trigger::TriggerVolumeMatchesTargetKey(volume, targetKey);
            }

            bool IsTriggerVolumeEnabledBySubtypeSettings(const TriggerVolume@ volume) {
                if (volume is null || volume.Source != TriggerVisualizer::Trigger::TRIGGER_SOURCE_MEDIATRACKER) return true;

                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_CAMERA, S_ShowMediaTrackerSubtypeCamera)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_CAM_CUSTOM, S_ShowMediaTrackerSubtypeCamCustom)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_CAM_ORBITAL, S_ShowMediaTrackerSubtypeCamOrbital)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_CAM_PATH, S_ShowMediaTrackerSubtypeCamPath)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_CAM_PLAYER, S_ShowMediaTrackerSubtypeCamPlayer)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_CAM_DEFAULT, S_ShowMediaTrackerSubtypeCamDefault)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_CAM_1, S_ShowMediaTrackerSubtypeCam1)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_CAM_2, S_ShowMediaTrackerSubtypeCam2)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_CAM_3, S_ShowMediaTrackerSubtypeCam3)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_TRIANGLES_2D, S_ShowMediaTrackerSubtype2DTriangles)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_TRIANGLES_3D, S_ShowMediaTrackerSubtype3DTriangles)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_CAR_TRAIL, S_ShowMediaTrackerSubtypeCarTrail)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_COLORS_FX, S_ShowMediaTrackerSubtypeColorsFx)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_COLOR_GRADING, S_ShowMediaTrackerSubtypeColorGrading)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_DEPTH_OF_FIELD, S_ShowMediaTrackerSubtypeDepthOfField)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_DIRTY_LENS, S_ShowMediaTrackerSubtypeDirtyLens)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_EDITING_CUT, S_ShowMediaTrackerSubtypeEditingCut)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_FADING_TRANSITION, S_ShowMediaTrackerSubtypeFadingTransition)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_FOG, S_ShowMediaTrackerSubtypeFog)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_GHOST, S_ShowMediaTrackerSubtypeGhost)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_AMBIANCE, S_ShowMediaTrackerSubtypeAmbiance)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_HDR_BLOOM, S_ShowMediaTrackerSubtypeHdrBloom)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_IMAGE, S_ShowMediaTrackerSubtypeImage)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_INERTIAL_TRACKING_CAM_FX, S_ShowMediaTrackerSubtypeInertialTrackingCamFx)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_MANIALINK_UI, S_ShowMediaTrackerSubtypeManiaLinkUi)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_MANIALINK_URL, S_ShowMediaTrackerSubtypeManiaLinkUrl)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_MUSIC_VOLUME, S_ShowMediaTrackerSubtypeMusicVolume)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_OPPONENT_VISIBILITY, S_ShowMediaTrackerSubtypeOpponentVisibility)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_SHAKE_CAM_FX, S_ShowMediaTrackerSubtypeShakeCamFx)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_STEREO_3D, S_ShowMediaTrackerSubtypeStereo3D)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_SOUND_FX, S_ShowMediaTrackerSubtypeSoundFx)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_SPECTATORS, S_ShowMediaTrackerSubtypeSpectators)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_TEXT, S_ShowMediaTrackerSubtypeText)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_TIME, S_ShowMediaTrackerSubtypeTime)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_TIME_SPEED, S_ShowMediaTrackerSubtypeTimeSpeed)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_TONE_MAPPING, S_ShowMediaTrackerSubtypeToneMapping)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_VEHICLE_LIGHTS, S_ShowMediaTrackerSubtypeVehicleLights)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_RESET, S_ShowMediaTrackerSubtypeReset)) return false;
                if (IsTriggerVolumeDisabledBySubtypeToggle(volume, TriggerVisualizer::Trigger::MT_SUBTYPE_UNKNOWN, S_ShowMediaTrackerSubtypeUnknown)) return false;

                return true;
            }

            string SettingBoolKey(bool value) {
                return value ? "1" : "0";
            }

            string GetMapSnapshotFilterSettingsKey() {
                return SettingBoolKey(S_RespectMapSuggestOff)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeCamera)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeCamCustom)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeCamOrbital)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeCamPath)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeCamPlayer)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeCamDefault)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeCam1)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeCam2)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeCam3)
                    + SettingBoolKey(S_ShowMediaTrackerSubtype2DTriangles)
                    + SettingBoolKey(S_ShowMediaTrackerSubtype3DTriangles)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeCarTrail)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeColorsFx)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeColorGrading)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeDepthOfField)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeDirtyLens)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeEditingCut)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeFadingTransition)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeFog)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeGhost)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeAmbiance)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeHdrBloom)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeImage)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeInertialTrackingCamFx)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeManiaLinkUi)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeManiaLinkUrl)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeMusicVolume)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeOpponentVisibility)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeShakeCamFx)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeStereo3D)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeSoundFx)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeSpectators)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeText)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeTime)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeTimeSpeed)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeToneMapping)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeVehicleLights)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeReset)
                    + SettingBoolKey(S_ShowMediaTrackerSubtypeUnknown);
            }

            bool RenderSourceContextToggleUI(const string &in label, const string &in id, bool value) {
                return UI::Checkbox(label + "##" + id, value);
            }

            bool RenderMediaTrackerSubtypeToggleUI(const string &in label, const string &in key, bool value) {
                return UI::Checkbox(label + "##trigger-visualizer-sources-mediatracker-subtype-" + key, value);
            }

            void RenderMediaTrackerSubtypeSettingsUI() {
                UI::Text("MediaTracker Subtypes");
                UI::TextDisabled("These also match mapper command targets, e.g. /trigger-visualizer camera,offzone suggest-off.");

                UI::BeginTabBar("trigger-visualizer-mediatracker-subtype-tabs");

                if (UI::BeginTabItem("Cameras")) {
                    S_ShowMediaTrackerSubtypeCamera = RenderMediaTrackerSubtypeToggleUI(
                        "Show Camera (all)",
                        "camera",
                        S_ShowMediaTrackerSubtypeCamera
                    );
                    S_ShowMediaTrackerSubtypeCamCustom = RenderMediaTrackerSubtypeToggleUI(
                        "Show Custom Camera / CamCustom",
                        "camcustom",
                        S_ShowMediaTrackerSubtypeCamCustom
                    );
                    S_ShowMediaTrackerSubtypeCamOrbital = RenderMediaTrackerSubtypeToggleUI(
                        "Show Orbital Camera / CamOrbital",
                        "camorbital",
                        S_ShowMediaTrackerSubtypeCamOrbital
                    );
                    S_ShowMediaTrackerSubtypeCamPath = RenderMediaTrackerSubtypeToggleUI(
                        "Show Path Camera / CamPath",
                        "campath",
                        S_ShowMediaTrackerSubtypeCamPath
                    );
                    S_ShowMediaTrackerSubtypeCamPlayer = RenderMediaTrackerSubtypeToggleUI(
                        "Show Player Camera",
                        "camplayer",
                        S_ShowMediaTrackerSubtypeCamPlayer
                    );
                    UI::Indent();
                    S_ShowMediaTrackerSubtypeCamDefault = RenderMediaTrackerSubtypeToggleUI(
                        "Show CamDefault",
                        "camdefault",
                        S_ShowMediaTrackerSubtypeCamDefault
                    );
                    S_ShowMediaTrackerSubtypeCam1 = RenderMediaTrackerSubtypeToggleUI(
                        "Show Cam1",
                        "cam1",
                        S_ShowMediaTrackerSubtypeCam1
                    );
                    S_ShowMediaTrackerSubtypeCam2 = RenderMediaTrackerSubtypeToggleUI(
                        "Show Cam2",
                        "cam2",
                        S_ShowMediaTrackerSubtypeCam2
                    );
                    S_ShowMediaTrackerSubtypeCam3 = RenderMediaTrackerSubtypeToggleUI(
                        "Show Cam3",
                        "cam3",
                        S_ShowMediaTrackerSubtypeCam3
                    );
                    UI::Unindent();
                    UI::EndTabItem();
                }

                if (UI::BeginTabItem("Visual FX")) {
                    S_ShowMediaTrackerSubtype2DTriangles = RenderMediaTrackerSubtypeToggleUI(
                        "Show 2D Triangles / 2dTriangles",
                        "2dtriangles",
                        S_ShowMediaTrackerSubtype2DTriangles
                    );
                    S_ShowMediaTrackerSubtype3DTriangles = RenderMediaTrackerSubtypeToggleUI(
                        "Show 3D Triangles / 3dTriangles",
                        "3dtriangles",
                        S_ShowMediaTrackerSubtype3DTriangles
                    );
                    S_ShowMediaTrackerSubtypeColorsFx = RenderMediaTrackerSubtypeToggleUI(
                        "Show Colors FX",
                        "colorsfx",
                        S_ShowMediaTrackerSubtypeColorsFx
                    );
                    S_ShowMediaTrackerSubtypeColorGrading = RenderMediaTrackerSubtypeToggleUI(
                        "Show Color Grading",
                        "colorgrading",
                        S_ShowMediaTrackerSubtypeColorGrading
                    );
                    S_ShowMediaTrackerSubtypeDepthOfField = RenderMediaTrackerSubtypeToggleUI(
                        "Show Depth of Field",
                        "depthoffield",
                        S_ShowMediaTrackerSubtypeDepthOfField
                    );
                    S_ShowMediaTrackerSubtypeDirtyLens = RenderMediaTrackerSubtypeToggleUI(
                        "Show Dirty Lens",
                        "dirtylens",
                        S_ShowMediaTrackerSubtypeDirtyLens
                    );
                    S_ShowMediaTrackerSubtypeFadingTransition = RenderMediaTrackerSubtypeToggleUI(
                        "Show Fading Transition",
                        "fadingtransition",
                        S_ShowMediaTrackerSubtypeFadingTransition
                    );
                    S_ShowMediaTrackerSubtypeFog = RenderMediaTrackerSubtypeToggleUI(
                        "Show Fog",
                        "fog",
                        S_ShowMediaTrackerSubtypeFog
                    );
                    S_ShowMediaTrackerSubtypeHdrBloom = RenderMediaTrackerSubtypeToggleUI(
                        "Show HDR Bloom",
                        "hdrbloom",
                        S_ShowMediaTrackerSubtypeHdrBloom
                    );
                    S_ShowMediaTrackerSubtypeImage = RenderMediaTrackerSubtypeToggleUI(
                        "Show Image",
                        "image",
                        S_ShowMediaTrackerSubtypeImage
                    );
                    S_ShowMediaTrackerSubtypeInertialTrackingCamFx = RenderMediaTrackerSubtypeToggleUI(
                        "Show Inertial Tracking CamFX",
                        "inertialtrackingcamfx",
                        S_ShowMediaTrackerSubtypeInertialTrackingCamFx
                    );
                    S_ShowMediaTrackerSubtypeShakeCamFx = RenderMediaTrackerSubtypeToggleUI(
                        "Show Shake Cam FX",
                        "shakecamfx",
                        S_ShowMediaTrackerSubtypeShakeCamFx
                    );
                    S_ShowMediaTrackerSubtypeStereo3D = RenderMediaTrackerSubtypeToggleUI(
                        "Show Stereo 3D",
                        "stereo3d",
                        S_ShowMediaTrackerSubtypeStereo3D
                    );
                    S_ShowMediaTrackerSubtypeToneMapping = RenderMediaTrackerSubtypeToggleUI(
                        "Show ToneMapping",
                        "tonemapping",
                        S_ShowMediaTrackerSubtypeToneMapping
                    );
                    S_ShowMediaTrackerSubtypeVehicleLights = RenderMediaTrackerSubtypeToggleUI(
                        "Show Vehicle Lights",
                        "vehiclelights",
                        S_ShowMediaTrackerSubtypeVehicleLights
                    );
                    UI::EndTabItem();
                }

                if (UI::BeginTabItem("Gameplay/UI")) {
                    S_ShowMediaTrackerSubtypeCarTrail = RenderMediaTrackerSubtypeToggleUI(
                        "Show Car Trail / CarTrail",
                        "cartrail",
                        S_ShowMediaTrackerSubtypeCarTrail
                    );
                    S_ShowMediaTrackerSubtypeGhost = RenderMediaTrackerSubtypeToggleUI(
                        "Show Ghost",
                        "ghost",
                        S_ShowMediaTrackerSubtypeGhost
                    );
                    S_ShowMediaTrackerSubtypeAmbiance = RenderMediaTrackerSubtypeToggleUI(
                        "Show Ambiance",
                        "ambiance",
                        S_ShowMediaTrackerSubtypeAmbiance
                    );
                    S_ShowMediaTrackerSubtypeManiaLinkUi = RenderMediaTrackerSubtypeToggleUI(
                        "Show ManiaLink UI",
                        "manialinkui",
                        S_ShowMediaTrackerSubtypeManiaLinkUi
                    );
                    S_ShowMediaTrackerSubtypeManiaLinkUrl = RenderMediaTrackerSubtypeToggleUI(
                        "Show ManiaLink URL",
                        "manialinkurl",
                        S_ShowMediaTrackerSubtypeManiaLinkUrl
                    );
                    S_ShowMediaTrackerSubtypeMusicVolume = RenderMediaTrackerSubtypeToggleUI(
                        "Show Music Volume",
                        "musicvolume",
                        S_ShowMediaTrackerSubtypeMusicVolume
                    );
                    S_ShowMediaTrackerSubtypeOpponentVisibility = RenderMediaTrackerSubtypeToggleUI(
                        "Show Opponent Visibility",
                        "opponentvisibility",
                        S_ShowMediaTrackerSubtypeOpponentVisibility
                    );
                    S_ShowMediaTrackerSubtypeSoundFx = RenderMediaTrackerSubtypeToggleUI(
                        "Show Sound FX",
                        "soundfx",
                        S_ShowMediaTrackerSubtypeSoundFx
                    );
                    S_ShowMediaTrackerSubtypeSpectators = RenderMediaTrackerSubtypeToggleUI(
                        "Show Spectators",
                        "spectators",
                        S_ShowMediaTrackerSubtypeSpectators
                    );
                    S_ShowMediaTrackerSubtypeText = RenderMediaTrackerSubtypeToggleUI(
                        "Show Text",
                        "text",
                        S_ShowMediaTrackerSubtypeText
                    );
                    S_ShowMediaTrackerSubtypeTime = RenderMediaTrackerSubtypeToggleUI(
                        "Show Time",
                        "time",
                        S_ShowMediaTrackerSubtypeTime
                    );
                    S_ShowMediaTrackerSubtypeTimeSpeed = RenderMediaTrackerSubtypeToggleUI(
                        "Show Time Speed",
                        "timespeed",
                        S_ShowMediaTrackerSubtypeTimeSpeed
                    );
                    UI::EndTabItem();
                }

                if (UI::BeginTabItem("Other")) {
                    S_ShowMediaTrackerSubtypeEditingCut = RenderMediaTrackerSubtypeToggleUI(
                        "Show Editing Cut",
                        "editingcut",
                        S_ShowMediaTrackerSubtypeEditingCut
                    );
                    S_ShowMediaTrackerSubtypeReset = RenderMediaTrackerSubtypeToggleUI(
                        "Show Reset / empty clips",
                        "reset",
                        S_ShowMediaTrackerSubtypeReset
                    );
                    S_ShowMediaTrackerSubtypeUnknown = RenderMediaTrackerSubtypeToggleUI(
                        "Show Unknown",
                        "unknown",
                        S_ShowMediaTrackerSubtypeUnknown
                    );
                    UI::EndTabItem();
                }

                UI::EndTabBar();
            }

            void RenderSourcesSettingsUI() {
                UI::Text("Trigger Sources");
                auto ctx = TriggerVisualizer::Trigger::GetCurrentRuntimeContext();

                UI::BeginTabBar("trigger-visualizer-source-tabs");

                if (UI::BeginTabItem("Offzone")) {
                    S_ShowOffzoneSource = UI::Checkbox(
                        "Show Offzone (global trigger)##trigger-visualizer-sources-offzone-global",
                        S_ShowOffzoneSource
                    );
                    S_ShowOffzoneInPlayableMap = RenderSourceContextToggleUI(
                        "Show in playable map",
                        "trigger-visualizer-sources-offzone-playable-map",
                        S_ShowOffzoneInPlayableMap
                    );
                    S_ShowOffzoneInEditor = RenderSourceContextToggleUI(
                        "Show in Editor",
                        "trigger-visualizer-sources-offzone-editor",
                        S_ShowOffzoneInEditor
                    );
                    S_ShowOffzoneInEditorTestMode = RenderSourceContextToggleUI(
                        "Show in Editor (test mode)",
                        "trigger-visualizer-sources-offzone-editor-test-mode",
                        S_ShowOffzoneInEditorTestMode
                    );
                    S_ShowOffzoneInEditorMediaTracker = RenderSourceContextToggleUI(
                        "Show in Editor (MediaTracker)",
                        "trigger-visualizer-sources-offzone-editor-mediatracker",
                        S_ShowOffzoneInEditorMediaTracker
                    );
                    S_ShowOffzoneInReplayEditor = RenderSourceContextToggleUI(
                        "Show in ReplayEditor",
                        "trigger-visualizer-sources-offzone-replay-editor",
                        S_ShowOffzoneInReplayEditor
                    );
                    UI::TextDisabled("Effective now: " + (IsOffzoneSourceEnabledForRuntime(ctx) ? "shown" : "hidden"));
                    UI::EndTabItem();
                }

                if (UI::BeginTabItem("MediaTracker")) {
                    S_ShowMediaTrackerSource = UI::Checkbox(
                        "Show MediaTracker (global trigger)##trigger-visualizer-sources-mediatracker-global",
                        S_ShowMediaTrackerSource
                    );
                    S_ShowMediaTrackerInPlayableMap = RenderSourceContextToggleUI(
                        "Show in playable map",
                        "trigger-visualizer-sources-mediatracker-playable-map",
                        S_ShowMediaTrackerInPlayableMap
                    );
                    S_ShowMediaTrackerInEditor = RenderSourceContextToggleUI(
                        "Show in Editor",
                        "trigger-visualizer-sources-mediatracker-editor",
                        S_ShowMediaTrackerInEditor
                    );
                    S_ShowMediaTrackerInEditorTestMode = RenderSourceContextToggleUI(
                        "Show in Editor (test mode)",
                        "trigger-visualizer-sources-mediatracker-editor-test-mode",
                        S_ShowMediaTrackerInEditorTestMode
                    );
                    S_ShowMediaTrackerInEditorMediaTracker = RenderSourceContextToggleUI(
                        "Show in Editor (MediaTracker)",
                        "trigger-visualizer-sources-mediatracker-editor-mediatracker",
                        S_ShowMediaTrackerInEditorMediaTracker
                    );
                    S_ShowMediaTrackerInReplayEditor = RenderSourceContextToggleUI(
                        "Show in ReplayEditor",
                        "trigger-visualizer-sources-mediatracker-replay-editor",
                        S_ShowMediaTrackerInReplayEditor
                    );
                    UI::TextDisabled("Effective now: " + (IsMediaTrackerSourceEnabledForRuntime(ctx) ? "shown" : "hidden"));
                    UI::Separator();
                    RenderMediaTrackerSubtypeSettingsUI();
                    UI::EndTabItem();
                }

                UI::EndTabBar();
            }
        }
    }
}
