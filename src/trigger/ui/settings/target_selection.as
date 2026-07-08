namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            const int TARGET_SELECTION_MODE_SPEED_KEEP = 0;
            const int TARGET_SELECTION_MODE_LABELS = 1;

            bool IsTargetSelectionKeyEnabled(int mode, const string &in key) {
                if (mode == TARGET_SELECTION_MODE_SPEED_KEEP) {
                    return IsSpeedRenderKeepTargetEnabled(key);
                }
                return IsLabelTargetEnabled(key);
            }

            void SetTargetSelectionKeyEnabled(int mode, const string &in key, bool enabled) {
                if (mode == TARGET_SELECTION_MODE_SPEED_KEEP) {
                    SetSpeedRenderKeepTargetEnabled(key, enabled);
                    return;
                }
                SetLabelTargetEnabled(key, enabled);
            }

            void SetTargetSelectionKeysEnabled(int mode, const array<string> &in keys, bool enabled) {
                for (uint i = 0; i < keys.Length; i++) {
                    SetTargetSelectionKeyEnabled(mode, keys[i], enabled);
                }
            }

            void FlipTargetSelectionKeys(int mode, const array<string> &in keys) {
                for (uint i = 0; i < keys.Length; i++) {
                    SetTargetSelectionKeyEnabled(mode, keys[i], !IsTargetSelectionKeyEnabled(mode, keys[i]));
                }
            }

            string TargetSelectionBulkEnableLabel(int mode) {
                return mode == TARGET_SELECTION_MODE_SPEED_KEEP ? "Keep all" : "Show all";
            }

            string TargetSelectionPrimaryColumnLabel(int mode) {
                return mode == TARGET_SELECTION_MODE_SPEED_KEEP ? "Keep" : "Show";
            }

            void RenderTargetSelectionToolbar(int mode, const array<string> &in keys, const string &in id) {
                string suffix = "##trigger-visualizer-target-selection-" + id;
                if (TriggerVisualizer::Shared::StyledButton("Flip all" + suffix + "-flip")) {
                    FlipTargetSelectionKeys(mode, keys);
                }
                UI::SameLine();
                if (TriggerVisualizer::Shared::StyledButton(TargetSelectionBulkEnableLabel(mode) + suffix + "-enable-all")) {
                    SetTargetSelectionKeysEnabled(mode, keys, true);
                }
                UI::SameLine();
                if (TriggerVisualizer::Shared::StyledButton("Hide all" + suffix + "-hide-all")) {
                    SetTargetSelectionKeysEnabled(mode, keys, false);
                }
                UI::Separator();
            }

            void RenderTargetSelectionRow(int mode, const string &in label, const string &in key) {
                UI::TableNextRow();
                UI::TableNextColumn();
                bool enabled = IsTargetSelectionKeyEnabled(mode, key);
                bool next = UI::Checkbox("##trigger-visualizer-target-selection-enabled-" + key + "-" + mode, enabled);
                if (next != enabled) SetTargetSelectionKeyEnabled(mode, key, next);

                UI::TableNextColumn();
                UI::Text(label);
                if (mode != TARGET_SELECTION_MODE_LABELS) return;

                UI::TableNextColumn();
                UI::SetNextItemWidth(-1.0f);
                string inputValue = GetLabelTargetOverrideInputValue(key);
                string nextValue = UI::InputText("##trigger-visualizer-label-target-text-" + key, inputValue);
                if (nextValue != inputValue) SetLabelTargetOverrideInputValue(key, nextValue);
            }

            void RenderTargetSelectionTable(
                int mode,
                const string &in id,
                const array<string> &in labels,
                const array<string> &in keys
            ) {
                int columns = mode == TARGET_SELECTION_MODE_LABELS ? 3 : 2;
                if (UI::BeginTable("trigger-visualizer-target-selection-table-" + id, columns, UI::TableFlags::SizingStretchProp | UI::TableFlags::BordersInnerV | UI::TableFlags::RowBg)) {
                    UI::TableSetupColumn(
                        TargetSelectionPrimaryColumnLabel(mode),
                        UI::TableColumnFlags::WidthFixed,
                        54.0f
                    );
                    UI::TableSetupColumn(
                        "Target",
                        mode == TARGET_SELECTION_MODE_LABELS ? UI::TableColumnFlags::WidthFixed : UI::TableColumnFlags::None,
                        170.0f
                    );
                    if (mode == TARGET_SELECTION_MODE_LABELS) {
                        UI::TableSetupColumn("Label Override");
                    }
                    UI::TableHeadersRow();
                    uint count = labels.Length;
                    if (keys.Length < count) count = keys.Length;
                    for (uint i = 0; i < count; i++) {
                        RenderTargetSelectionRow(mode, labels[i], keys[i]);
                    }
                    UI::EndTable();
                }
            }

            void RenderTargetSelectionCategoryUI(
                int mode,
                const string &in id,
                const array<string> &in labels,
                const array<string> &in keys
            ) {
                RenderTargetSelectionToolbar(mode, keys, id);
                RenderTargetSelectionTable(mode, id, labels, keys);
            }

            void RenderTargetSelectionSourceTargetsUI(int mode, const string &in idPrefix) {
                const string[] labels = {
                    "Offzone",
                    "MediaTracker",
                    "Crystal"
                };
                const string[] keys = {
                    TriggerVisualizer::Trigger::TRIGGER_TARGET_OFFZONE,
                    TriggerVisualizer::Trigger::TRIGGER_TARGET_MEDIATRACKER,
                    TriggerVisualizer::Trigger::TRIGGER_TARGET_CRYSTAL
                };
                RenderTargetSelectionCategoryUI(mode, idPrefix + "-sources", labels, keys);
            }

            void RenderTargetSelectionGameplayTargetsUI(int mode, const string &in idPrefix) {
                const string[] labels = {
                    "Checkpoint",
                    "Finish",
                    "Start/Finish",
                    "Turbo",
                    "Turbo2",
                    "Turbo Roulette",
                    "Boost",
                    "Boost2",
                    "Cruise",
                    "No Brakes",
                    "No Engine",
                    "No Steering",
                    "Slowmo",
                    "Fragile",
                    "Reset",
                    "Forced Acceleration",
                    "No Grip",
                    "Stadium Car",
                    "Snow Car",
                    "Rally Car",
                    "Desert Car"
                };
                const string[] keys = {
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_CHECKPOINT,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_FINISH,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_MULTILAP,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_TURBO,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_TURBO2,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_TURBO_ROULETTE,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_BOOST,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_BOOST2,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_CRUISE,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_NO_BRAKES,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_NO_ENGINE,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_NO_STEERING,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_SLOWMO,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_FRAGILE,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_RESET,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_FORCED_ACCELERATION,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_NO_GRIP,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_VEHICLE_TRANSFORM_RESET,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_VEHICLE_TRANSFORM_SNOW,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_VEHICLE_TRANSFORM_RALLY,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_VEHICLE_TRANSFORM_DESERT
                };
                RenderTargetSelectionCategoryUI(mode, idPrefix + "-gameplay", labels, keys);
            }

            void RenderTargetSelectionMediaTrackerCameraTargetsUI(int mode, const string &in idPrefix) {
                const string[] labels = {
                    "Camera (all)",
                    "Custom Camera",
                    "Orbital Camera",
                    "Path Camera",
                    "Player Camera",
                    "CamDefault",
                    "Cam1",
                    "Cam2",
                    "Cam3",
                    "CamHelico",
                    "CamFree",
                    "CamSpectator"
                };
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
                RenderTargetSelectionCategoryUI(mode, idPrefix + "-mt-camera", labels, keys);
            }

            void RenderTargetSelectionMediaTrackerVisualTargetsUI(int mode, const string &in idPrefix) {
                const string[] labels = {
                    "2D Triangles",
                    "3D Triangles",
                    "Colors FX",
                    "Color Grading",
                    "Depth of Field",
                    "Dirty Lens",
                    "Fading Transition",
                    "Fog",
                    "HDR Bloom",
                    "Image",
                    "Inertial Tracking CamFX",
                    "Shake Cam FX",
                    "Stereo 3D",
                    "ToneMapping",
                    "Vehicle Lights"
                };
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
                RenderTargetSelectionCategoryUI(mode, idPrefix + "-mt-visual", labels, keys);
            }

            void RenderTargetSelectionMediaTrackerGameplayUiTargetsUI(int mode, const string &in idPrefix) {
                const string[] labels = {
                    "Car Trails",
                    "Ghost",
                    "ManiaLink UI",
                    "ManiaLink URL",
                    "Music Volume",
                    "Opponent Visibility",
                    "Sound FX",
                    "Spectators",
                    "Text",
                    "Time",
                    "Time Speed"
                };
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
                RenderTargetSelectionCategoryUI(mode, idPrefix + "-mt-gameplay-ui", labels, keys);
            }

            void RenderTargetSelectionMediaTrackerOtherTargetsUI(int mode, const string &in idPrefix) {
                const string[] labels = {
                    "GPS",
                    "Editing Cut",
                    "Reset / empty clips",
                    "Mixed",
                    "Unknown"
                };
                const string[] keys = {
                    TriggerVisualizer::Trigger::MT_SUBTYPE_GPS,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_EDITING_CUT,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_RESET,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_MIXED,
                    TriggerVisualizer::Trigger::MT_SUBTYPE_UNKNOWN
                };
                RenderTargetSelectionCategoryUI(mode, idPrefix + "-mt-other", labels, keys);
            }

            void RenderTargetSelectionMediaTrackerTargetsUI(int mode, const string &in idPrefix) {
                UI::BeginTabBar("trigger-visualizer-target-selection-" + idPrefix + "-mt-tabs");
                if (UI::BeginTabItem("Camera")) {
                    RenderTargetSelectionMediaTrackerCameraTargetsUI(mode, idPrefix);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Visual FX")) {
                    RenderTargetSelectionMediaTrackerVisualTargetsUI(mode, idPrefix);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Gameplay/UI")) {
                    RenderTargetSelectionMediaTrackerGameplayUiTargetsUI(mode, idPrefix);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Other")) {
                    RenderTargetSelectionMediaTrackerOtherTargetsUI(mode, idPrefix);
                    UI::EndTabItem();
                }
                UI::EndTabBar();
            }

            void RenderTargetSelectionCrystalTargetsUI(int mode, const string &in idPrefix) {
                const string[] labels = {
                    "Crystal Block",
                    "Crystal Block Waypoint",
                    "Crystal Screen Interaction",
                    "Crystal Gate",
                    "Crystal Teleporter",
                    "Crystal Item",
                    "Crystal Block Item"
                };
                const string[] keys = {
                    TriggerVisualizer::Trigger::CRYSTAL_SUBTYPE_BLOCK,
                    TriggerVisualizer::Trigger::CRYSTAL_SUBTYPE_BLOCK_WAYPOINT,
                    TriggerVisualizer::Trigger::CRYSTAL_SUBTYPE_SCREEN_INTERACTION,
                    TriggerVisualizer::Trigger::CRYSTAL_SUBTYPE_GATE,
                    TriggerVisualizer::Trigger::CRYSTAL_SUBTYPE_TELEPORTER,
                    TriggerVisualizer::Trigger::CRYSTAL_SUBTYPE_ITEM,
                    TriggerVisualizer::Trigger::CRYSTAL_SUBTYPE_BLOCK_ITEM
                };
                RenderTargetSelectionCategoryUI(mode, idPrefix + "-crystal", labels, keys);
            }

            void RenderTargetSelectionTabs(int mode, const string &in tabBarId, const string &in idPrefix) {
                UI::BeginTabBar(tabBarId);
                if (UI::BeginTabItem("Sources")) {
                    RenderTargetSelectionSourceTargetsUI(mode, idPrefix);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Gameplay")) {
                    RenderTargetSelectionGameplayTargetsUI(mode, idPrefix);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("MediaTracker")) {
                    RenderTargetSelectionMediaTrackerTargetsUI(mode, idPrefix);
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Crystal")) {
                    RenderTargetSelectionCrystalTargetsUI(mode, idPrefix);
                    UI::EndTabItem();
                }
                UI::EndTabBar();
            }
        }
    }
}
