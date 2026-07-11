namespace TriggerVisualizer {
    namespace Trigger {
        namespace Ui {
            const string TILE_ICON_EXPLORER_ID_PREFIX = "trigger-tile-icon-";

            string GetTileIconSessionId(const string &in key) {
                return TILE_ICON_EXPLORER_ID_PREFIX + NormalizeTriggerTargetKey(key);
            }

            string GetTileIconDisplayPath(const string &in defaultPath, const string &in storagePath) {
                if (storagePath.Length == 0) return defaultPath;
                return IO::FromStorageFolder(storagePath);
            }

            string GetTileIconPathInputValue(
                const string &in key,
                const string &in defaultPath,
                const string &in storagePath
            ) {
                string inputKey = NormalizeTriggerTargetKey(key);
                string value;
                if (!g_TileIconPathInputs.Get(inputKey, value)) {
                    value = GetTileIconDisplayPath(defaultPath, storagePath);
                    g_TileIconPathInputs.Set(inputKey, value);
                }
                return value;
            }

            void SetTileIconPathInputValue(const string &in key, const string &in value) {
                g_TileIconPathInputs.Set(NormalizeTriggerTargetKey(key), value);
            }

            void SetTileIconStoragePath(const string &in key, bool isOffzone, const string &in storagePath) {
                if (isOffzone) {
                    S_CustomTileIconStoragePath = storagePath;
                    TriggerVisualizer::Trigger::Render::Assets::InvalidateSkullTileIconTexture();
                } else {
                    SetTileIconCustomStoragePathForSubtype(key, storagePath);
                }
            }

            string GetTileIconStoragePath(const string &in key, bool isOffzone) {
                return isOffzone ? S_CustomTileIconStoragePath : GetTileIconCustomStoragePathForSubtype(key);
            }

            bool GetTileIconEnabled(const string &in key, bool isOffzone) {
                return isOffzone ? S_ShowOffzoneTileIcon : IsTileIconEnabledForSubtype(key);
            }

            void SetTileIconEnabled(const string &in key, bool isOffzone, bool value) {
                if (isOffzone) {
                    S_ShowOffzoneTileIcon = value;
                } else {
                    SetTileIconEnabledForSubtype(key, value);
                }
            }

            bool ApplyTileIconSourcePath(
                const string &in key,
                bool isOffzone,
                const string &in defaultPath,
                const string &in sourcePath
            ) {
                string trimmedPath = sourcePath.Trim();
                if (trimmedPath.Length == 0 || trimmedPath == defaultPath) {
                    SetTileIconStoragePath(key, isOffzone, "");
                    SetTileIconPathInputValue(key, defaultPath);
                    g_TileIconImportStatus = "Using default image for " + GetMediaTrackerSubtypeDisplayName(key) + ".";
                    return true;
                }

                if (!TriggerVisualizer::Trigger::Render::Assets::IsSupportedTileIconImagePath(trimmedPath)) {
                    g_TileIconImportStatus = "Unsupported image type: " + trimmedPath;
                    NotifyWarning(g_TileIconImportStatus, TriggerVisualizer::g_PluginMeta.Name, 6000);
                    return false;
                }

                string storagePath = TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage(trimmedPath);
                if (storagePath.Length == 0) {
                    g_TileIconImportStatus = "Could not add image. Make sure the path exists and is a supported image file.";
                    NotifyWarning(g_TileIconImportStatus, TriggerVisualizer::g_PluginMeta.Name, 6000);
                    return false;
                }

                SetTileIconStoragePath(key, isOffzone, storagePath);
                SetTileIconPathInputValue(key, IO::FromStorageFolder(storagePath));
                g_TileIconImportStatus = "Added image: " + IO::FromStorageFolder(storagePath);
                NotifyInfo("Tile icon image added.", TriggerVisualizer::g_PluginMeta.Name, 5000);
                return true;
            }

            void ResetTileIconPath(const string &in key, bool isOffzone, const string &in defaultPath) {
                SetTileIconStoragePath(key, isOffzone, "");
                SetTileIconPathInputValue(key, defaultPath);
                g_TileIconImportStatus = "Using default image.";
            }

            void OpenTileIconFileExplorer(const string &in key, const string &in currentPath) {
                string startPath = IO::FromUserGameFolder("");
                if (currentPath.Length > 0 && IO::FileExists(currentPath)) {
                    startPath = Path::GetDirectoryName(currentPath);
                }
                FileExplorer::fe_Start(
                    GetTileIconSessionId(key),
                    true,
                    "path",
                    vec2(1, 1),
                    startPath,
                    "",
                    {"png", "jpg", "jpeg", "webp"},
                    {"png", "jpg", "jpeg", "webp"}
                );
            }

            void HandleTileIconFileExplorerSelection(
                const string &in key,
                bool isOffzone,
                const string &in defaultPath
            ) {
                auto explorer = FileExplorer::fe_GetExplorerById(GetTileIconSessionId(key));
                if (explorer is null || !explorer.exports.IsSelectionComplete()) return;

                auto paths = explorer.exports.GetSelectedPaths();
                if (paths is null || paths.Length == 0) return;
                ApplyTileIconSourcePath(key, isOffzone, defaultPath, paths[0]);
            }

            void RenderTileIconRow(
                const string &in label,
                const string &in key,
                const string &in defaultPath,
                bool isOffzone = false
            ) {
                HandleTileIconFileExplorerSelection(key, isOffzone, defaultPath);
                string storagePath = GetTileIconStoragePath(key, isOffzone);
                bool enabled = GetTileIconEnabled(key, isOffzone);
                UI::TableNextRow();
                UI::TableNextColumn();
                bool nextEnabled = UI::Checkbox("##show-icon-" + key, enabled);
                if (nextEnabled != enabled) SetTileIconEnabled(key, isOffzone, nextEnabled);

                UI::TableNextColumn();
                UI::Text(label);
                UI::TableNextColumn();
                if (TriggerVisualizer::Shared::StyledButton("Reset##reset-icon-" + key)) {
                    ResetTileIconPath(key, isOffzone, defaultPath);
                }
                UI::TableNextColumn();
                UI::PushItemWidth(-1.0f);
                bool submitted = false;
                string inputValue = GetTileIconPathInputValue(key, defaultPath, storagePath);
                inputValue = UI::InputText(
                    "##path-icon-" + key,
                    inputValue,
                    submitted,
                    UI::InputTextFlags::EnterReturnsTrue
                );
                UI::PopItemWidth();
                SetTileIconPathInputValue(key, inputValue);
                if (submitted) {
                    ApplyTileIconSourcePath(key, isOffzone, defaultPath, inputValue);
                }
                UI::TableNextColumn();
                if (TriggerVisualizer::Shared::StyledButton(Icons::FolderOpen + "##explore-icon-" + key)) {
                    OpenTileIconFileExplorer(
                        key,
                        GetTileIconDisplayPath(defaultPath, storagePath)
                    );
                }
            }

            void RenderTileIconTableHeader() {
                UI::TableSetupColumn("Show", UI::TableColumnFlags::WidthFixed, 54.0f);
                UI::TableSetupColumn("Icon", UI::TableColumnFlags::WidthFixed, 150.0f);
                UI::TableSetupColumn("Default", UI::TableColumnFlags::WidthFixed, 74.0f);
                UI::TableSetupColumn("Current path");
                UI::TableSetupColumn("Browse", UI::TableColumnFlags::WidthFixed, 64.0f);
                UI::TableHeadersRow();
            }

            void RenderOffzoneTileIconSettingsUi() {
                if (UI::BeginTable("trigger-visualizer-offzone-tile-icons", 5, UI::TableFlags::SizingStretchProp | UI::TableFlags::BordersInnerV | UI::TableFlags::RowBg)) {
                    RenderTileIconTableHeader();
                    RenderTileIconRow(
                        "Offzone",
                        "offzone",
                        TriggerVisualizer::Trigger::Render::Assets::DEFAULT_SKULL_TILE_ICON_PATH,
                        true
                    );
                    UI::EndTable();
                }
            }

            void RenderCameraTileIconSettingsUi() {
                if (UI::BeginTable("trigger-visualizer-camera-tile-icons", 5, UI::TableFlags::SizingStretchProp | UI::TableFlags::BordersInnerV | UI::TableFlags::RowBg)) {
                    RenderTileIconTableHeader();
                    RenderTileIconRow(
                        "Camera",
                        MT_SUBTYPE_CAMERA,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_CAMERA)
                    );
                    RenderTileIconRow(
                        "Custom Camera",
                        MT_SUBTYPE_CUSTOM_CAMERA,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_CUSTOM_CAMERA)
                    );
                    RenderTileIconRow(
                        "Orbital Camera",
                        MT_SUBTYPE_ORBITAL_CAMERA,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_ORBITAL_CAMERA)
                    );
                    RenderTileIconRow(
                        "Path Camera",
                        MT_SUBTYPE_PATH_CAMERA,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_PATH_CAMERA)
                    );
                    RenderTileIconRow(
                        "Player Camera",
                        MT_SUBTYPE_PLAYER_CAMERA,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_PLAYER_CAMERA)
                    );
                    RenderTileIconRow(
                        "CamDefault",
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT)
                    );
                    RenderTileIconRow(
                        "Cam1",
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1)
                    );
                    RenderTileIconRow(
                        "Cam2",
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2)
                    );
                    RenderTileIconRow(
                        "Cam3",
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3)
                    );
                    RenderTileIconRow(
                        "CamHelico",
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO)
                    );
                    RenderTileIconRow(
                        "CamFree",
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE)
                    );
                    RenderTileIconRow(
                        "CamSpectator",
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR)
                    );
                    UI::EndTable();
                }
            }

            void RenderVisualTileIconSettingsUi() {
                if (UI::BeginTable("trigger-visualizer-visual-tile-icons", 5, UI::TableFlags::SizingStretchProp | UI::TableFlags::BordersInnerV | UI::TableFlags::RowBg)) {
                    RenderTileIconTableHeader();
                    RenderTileIconRow(
                        "2D Triangles",
                        MT_SUBTYPE_2D_TRIANGLES,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_2D_TRIANGLES)
                    );
                    RenderTileIconRow(
                        "3D Triangles",
                        MT_SUBTYPE_3D_TRIANGLES,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_3D_TRIANGLES)
                    );
                    RenderTileIconRow(
                        "Colors FX",
                        MT_SUBTYPE_COLORS_FX,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_COLORS_FX)
                    );
                    RenderTileIconRow(
                        "Color Grading",
                        MT_SUBTYPE_COLOR_GRADING,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_COLOR_GRADING)
                    );
                    RenderTileIconRow(
                        "Depth of Field",
                        MT_SUBTYPE_DEPTH_OF_FIELD,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_DEPTH_OF_FIELD)
                    );
                    RenderTileIconRow(
                        "Dirty Lens",
                        MT_SUBTYPE_DIRTY_LENS,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_DIRTY_LENS)
                    );
                    RenderTileIconRow(
                        "Fading Transition",
                        MT_SUBTYPE_FADING_TRANSITION,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_FADING_TRANSITION)
                    );
                    RenderTileIconRow(
                        "Fog",
                        MT_SUBTYPE_FOG,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_FOG)
                    );
                    RenderTileIconRow(
                        "HDR Bloom",
                        MT_SUBTYPE_HDR_BLOOM,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_HDR_BLOOM)
                    );
                    RenderTileIconRow(
                        "Image",
                        MT_SUBTYPE_IMAGE,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_IMAGE)
                    );
                    UI::EndTable();
                }
            }

            void RenderInterfaceTileIconSettingsUi() {
                if (UI::BeginTable("trigger-visualizer-interface-tile-icons", 5, UI::TableFlags::SizingStretchProp | UI::TableFlags::BordersInnerV | UI::TableFlags::RowBg)) {
                    RenderTileIconTableHeader();
                    RenderTileIconRow(
                        "ManiaLink UI",
                        MT_SUBTYPE_MANIALINK_UI,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_MANIALINK_UI)
                    );
                    RenderTileIconRow(
                        "ManiaLink URL",
                        MT_SUBTYPE_MANIALINK_URL,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_MANIALINK_URL)
                    );
                    RenderTileIconRow(
                        "Text",
                        MT_SUBTYPE_TEXT,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_TEXT)
                    );
                    RenderTileIconRow(
                        "Time",
                        MT_SUBTYPE_TIME,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_TIME)
                    );
                    RenderTileIconRow(
                        "Time Speed",
                        MT_SUBTYPE_TIME_SPEED,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_TIME_SPEED)
                    );
                    UI::EndTable();
                }
            }

            void RenderOtherTileIconSettingsUi() {
                if (UI::BeginTable("trigger-visualizer-other-tile-icons", 5, UI::TableFlags::SizingStretchProp | UI::TableFlags::BordersInnerV | UI::TableFlags::RowBg)) {
                    RenderTileIconTableHeader();
                    RenderTileIconRow(
                        "Ghost",
                        MT_SUBTYPE_GHOST,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_GHOST)
                    );
                    RenderTileIconRow(
                        "Music Volume",
                        MT_SUBTYPE_MUSIC_VOLUME,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_MUSIC_VOLUME)
                    );
                    RenderTileIconRow(
                        "Reset",
                        MT_SUBTYPE_RESET,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_RESET)
                    );
                    RenderTileIconRow(
                        "Sound FX",
                        MT_SUBTYPE_SOUND_FX,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_SOUND_FX)
                    );
                    RenderTileIconRow(
                        "Spectators",
                        MT_SUBTYPE_SPECTATORS,
                        TriggerVisualizer::Trigger::Render::Assets::GetMediaTrackerTileIconPathForSubtype(MT_SUBTYPE_SPECTATORS)
                    );
                    UI::EndTable();
                }
            }

            void RenderMediaTrackerTileIconSettingsUi() {
                UI::BeginTabBar("trigger-visualizer-mediatracker-tile-icon-tabs");
                if (UI::BeginTabItem("Camera")) {
                    RenderCameraTileIconSettingsUi();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Visual")) {
                    RenderVisualTileIconSettingsUi();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Interface/Time")) {
                    RenderInterfaceTileIconSettingsUi();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Audio/Other")) {
                    RenderOtherTileIconSettingsUi();
                    UI::EndTabItem();
                }
                UI::EndTabBar();
            }

            void RenderTileIconGlobalSettingsUi() {
                S_ShowSkullTileIcons = UI::Checkbox(
                    "Show tile icon at tile centers##trigger-visualizer-image-tiles",
                    S_ShowSkullTileIcons
                );
                UI::SameLine();
                UI::TextDisabled("~20 fps performance drop! (e.g. 90 fps -> 70 fps)");
                S_RepeatTileIconsOnSplitFillTiles = UI::Checkbox(
                    "Repeat icons on split fill tiles##trigger-visualizer-image-tiles",
                    S_RepeatTileIconsOnSplitFillTiles
                );
                UI::SetNextItemWidth(220.0f);
                S_SkullTileIconScale = UI::SliderFloat(
                    "Tile icon scale##trigger-visualizer-image-tiles",
                    S_SkullTileIconScale,
                    0.05f,
                    1.0f
                );
                UI::SetNextItemWidth(220.0f);
                S_SkullTileIconAlpha = UI::SliderFloat(
                    "Tile icon alpha##trigger-visualizer-image-tiles",
                    S_SkullTileIconAlpha,
                    0.0f,
                    1.0f
                );
                UI::TextDisabled("Typed paths are applied with Enter. Browse selections are copied into plugin storage.");
                if (g_TileIconImportStatus.Length > 0) {
                    UI::TextWrapped(g_TileIconImportStatus);
                }
                ClampColorSettings();
            }

            void RenderImageTilesSettingsUi() {
                RenderTileIconGlobalSettingsUi();
                UI::Separator();
                UI::BeginTabBar("trigger-visualizer-tile-icon-source-tabs");
                if (UI::BeginTabItem("Offzone")) {
                    RenderOffzoneTileIconSettingsUi();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("MediaTracker")) {
                    RenderMediaTrackerTileIconSettingsUi();
                    UI::EndTabItem();
                }
                UI::EndTabBar();
            }
        }
    }
}
