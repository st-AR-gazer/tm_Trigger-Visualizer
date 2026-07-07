namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            void RenderSpeedRenderSkipTargetToolbar(const array<string> &in keys, const string &in id) {
                string suffix = "##trigger-visualizer-performance-speed-targets-" + id;
                if (TriggerVisualizer::Shared::StyledButton("Flip all" + suffix + "-flip")) {
                    FlipSpeedRenderKeepTargetKeys(keys);
                }
                UI::SameLine();
                if (TriggerVisualizer::Shared::StyledButton("Keep all" + suffix + "-keep-all")) {
                    SetSpeedRenderKeepTargetKeysEnabled(keys, true);
                }
                UI::SameLine();
                if (TriggerVisualizer::Shared::StyledButton("Hide all" + suffix + "-hide-all")) {
                    SetSpeedRenderKeepTargetKeysEnabled(keys, false);
                }
                UI::Separator();
            }

            void RenderSpeedRenderSkipTargetRow(const string &in label, const string &in key) {
                UI::TableNextRow();
                UI::TableNextColumn();
                bool enabled = IsSpeedRenderKeepTargetEnabled(key);
                bool next = UI::Checkbox("##speed-keep-target-" + key, enabled);
                if (next != enabled) SetSpeedRenderKeepTargetEnabled(key, next);

                UI::TableNextColumn();
                UI::Text(label);
            }

            void RenderSpeedRenderSkipTargetTable(
                const string &in id,
                const array<string> &in labels,
                const array<string> &in keys
            ) {
                if (UI::BeginTable("trigger-visualizer-performance-speed-target-table-" + id, 2, UI::TableFlags::SizingStretchProp | UI::TableFlags::BordersInnerV | UI::TableFlags::RowBg)) {
                    UI::TableSetupColumn("Keep", UI::TableColumnFlags::WidthFixed, 54.0f);
                    UI::TableSetupColumn("Target");
                    UI::TableHeadersRow();
                    uint count = labels.Length;
                    if (keys.Length < count) count = keys.Length;
                    for (uint i = 0; i < count; i++) {
                        RenderSpeedRenderSkipTargetRow(labels[i], keys[i]);
                    }
                    UI::EndTable();
                }
            }

            void RenderSpeedRenderSkipTargetCategoryUI(
                const string &in id,
                const array<string> &in labels,
                const array<string> &in keys
            ) {
                RenderSpeedRenderSkipTargetToolbar(keys, id);
                RenderSpeedRenderSkipTargetTable(id, labels, keys);
            }

            void RenderSpeedRenderSkipSourceTargetsUI() {
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
                RenderSpeedRenderSkipTargetCategoryUI("sources", labels, keys);
            }

            void RenderSpeedRenderSkipGameplayTargetsUI() {
                const string[] labels = {
                    "Checkpoint",
                    "Finish",
                    "Start/Finish",
                    "Turbo",
                    "Turbo2",
                    "Turbo Roulette",
                    "Turbo Roulette Yellow",
                    "Turbo Roulette Cyan",
                    "Turbo Roulette Purple",
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
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_TURBO_ROULETTE_YELLOW,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_TURBO_ROULETTE_CYAN,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_TURBO_ROULETTE_PURPLE,
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
                RenderSpeedRenderSkipTargetCategoryUI("gameplay", labels, keys);
            }

            void RenderSpeedRenderSkipMediaTrackerCameraTargetsUI() {
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
                RenderSpeedRenderSkipTargetCategoryUI("mt-camera", labels, keys);
            }

            void RenderSpeedRenderSkipMediaTrackerVisualTargetsUI() {
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
                RenderSpeedRenderSkipTargetCategoryUI("mt-visual", labels, keys);
            }

            void RenderSpeedRenderSkipMediaTrackerGameplayUiTargetsUI() {
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
                RenderSpeedRenderSkipTargetCategoryUI("mt-gameplay-ui", labels, keys);
            }

            void RenderSpeedRenderSkipMediaTrackerOtherTargetsUI() {
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
                RenderSpeedRenderSkipTargetCategoryUI("mt-other", labels, keys);
            }

            void RenderSpeedRenderSkipMediaTrackerTargetsUI() {
                UI::BeginTabBar("trigger-visualizer-performance-speed-mt-tabs");
                if (UI::BeginTabItem("Camera")) {
                    RenderSpeedRenderSkipMediaTrackerCameraTargetsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Visual FX")) {
                    RenderSpeedRenderSkipMediaTrackerVisualTargetsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Gameplay/UI")) {
                    RenderSpeedRenderSkipMediaTrackerGameplayUiTargetsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Other")) {
                    RenderSpeedRenderSkipMediaTrackerOtherTargetsUI();
                    UI::EndTabItem();
                }
                UI::EndTabBar();
            }

            void RenderSpeedRenderSkipCrystalTargetsUI() {
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
                RenderSpeedRenderSkipTargetCategoryUI("crystal", labels, keys);
            }

            void RenderSpeedRenderSkipTargetsUI() {
                UI::Text("Keep While Fast");
                UI::TextDisabled("Selected targets stay visible after the speed threshold is reached; everything else is hidden.");
                UI::BeginTabBar("trigger-visualizer-performance-speed-target-tabs");
                if (UI::BeginTabItem("Sources")) {
                    RenderSpeedRenderSkipSourceTargetsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Gameplay")) {
                    RenderSpeedRenderSkipGameplayTargetsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("MediaTracker")) {
                    RenderSpeedRenderSkipMediaTrackerTargetsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Crystal")) {
                    RenderSpeedRenderSkipCrystalTargetsUI();
                    UI::EndTabItem();
                }
                UI::EndTabBar();
            }

            void RenderPerformanceCullingSettingsUI() {
                UI::Text("Culling");
                S_CullOffscreenWorldTiles = UI::Checkbox(
                    "Cull off-screen fill/icon tiles##trigger-visualizer-performance",
                    S_CullOffscreenWorldTiles
                );
            }

            void RenderPerformanceBudgetSettingsUI() {
                UI::Text("Draw Budgets");
                UI::SetNextItemWidth(220.0f);
                S_FillTileMinSize = UI::InputFloat(
                    "Fill tile minimum size##trigger-visualizer-performance",
                    S_FillTileMinSize
                );
                UI::SetNextItemWidth(220.0f);
                S_MaxVisibleVolumesPerFrame = UI::InputInt(
                    "Max visible volumes per frame##trigger-visualizer-performance",
                    S_MaxVisibleVolumesPerFrame
                );
                UI::SetNextItemWidth(220.0f);
                S_MaxFillTilesPerFrame = UI::InputInt(
                    "Max fill tiles per frame##trigger-visualizer-performance",
                    S_MaxFillTilesPerFrame
                );
                UI::SetNextItemWidth(220.0f);
                S_MaxOutlineSegmentsPerFrame = UI::InputInt(
                    "Max outline segments per frame##trigger-visualizer-performance",
                    S_MaxOutlineSegmentsPerFrame
                );
                UI::SetNextItemWidth(220.0f);
                S_MaxCrystalOutlineSegmentsPerFrame = UI::InputInt(
                    "Max Crystal outline segments per frame##trigger-visualizer-performance",
                    S_MaxCrystalOutlineSegmentsPerFrame
                );
                S_SplitCrystalOutlineEdges = UI::Checkbox(
                    "Split Crystal outline edges##trigger-visualizer-performance",
                    S_SplitCrystalOutlineEdges
                );
                UI::SetNextItemWidth(220.0f);
                S_MaxTileIconPatchesPerFrame = UI::InputInt(
                    "Max tile icon patches per frame##trigger-visualizer-performance",
                    S_MaxTileIconPatchesPerFrame
                );
                UI::SetNextItemWidth(220.0f);
                S_TileIconMaxSubdivisions = UI::InputInt(
                    "Tile icon max subdivisions##trigger-visualizer-performance",
                    S_TileIconMaxSubdivisions
                );
            }

            int RenderRefreshIntervalInput(const string &in id, int value) {
                UI::SetNextItemWidth(120.0f);
                return NormalizeRefreshIntervalMs(UI::InputInt("##trigger-visualizer-performance-refresh-" + id, value));
            }

            int RenderRefreshRow(const string &in source, const string &in context, const string &in id, int value) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text(source);
                UI::TableNextColumn();
                UI::Text(context);
                UI::TableNextColumn();
                return RenderRefreshIntervalInput(id, value);
            }

            void RenderPerformanceRefreshSettingsUI() {
                UI::Text("Source Cache Refresh");
                UI::TextDisabled("Intervals are milliseconds; 0 disables periodic refresh.");
                if (UI::BeginTable("trigger-visualizer-performance-refresh-table", 3, UI::TableFlags::SizingStretchProp | UI::TableFlags::BordersInnerV | UI::TableFlags::RowBg)) {
                    UI::TableSetupColumn("Source");
                    UI::TableSetupColumn("Editable context");
                    UI::TableSetupColumn("Interval", UI::TableColumnFlags::WidthFixed, 140.0f);
                    UI::TableHeadersRow();
                    S_OffzoneEditorRefreshIntervalMs = RenderRefreshRow(
                        "Offzone",
                        "Map Editor",
                        "offzone-editor",
                        S_OffzoneEditorRefreshIntervalMs
                    );
                    S_MediaTrackerEditorRefreshIntervalMs = RenderRefreshRow(
                        "MediaTracker",
                        "MediaTracker Editor",
                        "mediatracker-editor",
                        S_MediaTrackerEditorRefreshIntervalMs
                    );
                    S_CrystalMeshModelerRefreshIntervalMs = RenderRefreshRow(
                        "Crystal",
                        "Mesh Modeler",
                        "crystal-mesh-modeler",
                        S_CrystalMeshModelerRefreshIntervalMs
                    );
                    UI::EndTable();
                }
            }

            void RenderPerformanceSpeedSettingsUI() {
                UI::Text("Speed Render Skip");
                S_FastDrivingPerformanceMode = UI::Checkbox(
                    "Skip world render while fast##trigger-visualizer-performance",
                    S_FastDrivingPerformanceMode
                );
                UI::SetNextItemWidth(220.0f);
                S_FastDrivingSpeedThresholdKmh = UI::InputFloat(
                    "Forward speed threshold (km/h)##trigger-visualizer-performance",
                    S_FastDrivingSpeedThresholdKmh
                );
                UI::SetNextItemWidth(220.0f);
                S_FastDrivingReverseSpeedThresholdKmh = UI::InputFloat(
                    "Reverse speed threshold (km/h)##trigger-visualizer-performance",
                    S_FastDrivingReverseSpeedThresholdKmh
                );
                UI::BeginDisabled(!S_FastDrivingPerformanceMode);
                RenderSpeedRenderSkipTargetsUI();
                UI::EndDisabled();
            }

            void RenderPerformanceSettingsUI() {
                UI::BeginTabBar("trigger-visualizer-performance-tabs");
                if (UI::BeginTabItem("Budgets")) {
                    RenderPerformanceBudgetSettingsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Culling")) {
                    RenderPerformanceCullingSettingsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Refresh")) {
                    RenderPerformanceRefreshSettingsUI();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Fast Driving")) {
                    RenderPerformanceSpeedSettingsUI();
                    UI::EndTabItem();
                }
                UI::EndTabBar();
                ClampPerformanceSettings();
            }
        }
    }
}
