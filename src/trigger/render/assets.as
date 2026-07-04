namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            namespace Assets {
                const string DEFAULT_SKULL_TILE_ICON_PATH = "src/assets/skull_and_crossbones.png";
                const string DEFAULT_MISSING_TILE_ICON_PATH = "src/assets/missing-element.png";
                const string OFFZONE_TILE_ICON_TEXTURE_KEY = "$offzone";
                const string MISSING_TILE_ICON_TEXTURE_KEY = "$missing";
                const string MISSING_TILE_ICON_STORAGE_PATH = "$missing";
                const string STORAGE_TILE_ICON_TEXTURE_KEY_PREFIX = "$storage:";
                const string MEDIATRACKER_TILE_ICON_BASE_PATH = "src/assets/mediatracker/";
                const string TILE_ICON_STORAGE_DIR = "assets/";

                nvg::Texture@ g_SkullTileIconTexture = null;
                bool g_TriedLoadSkullTileIconTexture = false;
                string g_LoadedSkullTileIconPath = "";
                nvg::Texture@ g_MissingTileIconTexture = null;
                bool g_TriedLoadMissingTileIconTexture = false;
                array<string> g_BuiltInTileIconTexturePaths;
                array<bool> g_TriedLoadBuiltInTileIconTextures;
                array<nvg::Texture@> g_BuiltInTileIconTextures;
                array<string> g_StorageTileIconTexturePaths;
                array<bool> g_TriedLoadStorageTileIconTextures;
                array<nvg::Texture@> g_StorageTileIconTextures;

                bool IsSupportedTileIconImagePath(const string &in path) {
                    string ext = Path::GetExtension(path).ToLower();
                    return ext == ".png" || ext == ".jpg" || ext == ".jpeg" || ext == ".webp";
                }

                string GetTileIconStorageFolderPath() {
                    return IO::FromStorageFolder(TILE_ICON_STORAGE_DIR);
                }

                string GetConfiguredSkullTileIconTexturePath() {
                    string storagePath = TriggerVisualizer::Trigger::UI::S_CustomTileIconStoragePath;
                    if (storagePath.Length == 0) return DEFAULT_SKULL_TILE_ICON_PATH;
                    if (storagePath == MISSING_TILE_ICON_STORAGE_PATH) return DEFAULT_MISSING_TILE_ICON_PATH;
                    return IO::FromStorageFolder(storagePath);
                }

                string GetCurrentTileIconDisplayPath() {
                    string storagePath = TriggerVisualizer::Trigger::UI::S_CustomTileIconStoragePath;
                    if (storagePath == MISSING_TILE_ICON_STORAGE_PATH) return DEFAULT_MISSING_TILE_ICON_PATH + " (missing fallback)";
                    if (storagePath.Length == 0) return DEFAULT_SKULL_TILE_ICON_PATH + " (default)";
                    return IO::FromStorageFolder(storagePath);
                }

                void InvalidateSkullTileIconTexture() {
                    @g_SkullTileIconTexture = null;
                    g_TriedLoadSkullTileIconTexture = false;
                    g_LoadedSkullTileIconPath = "";
                }

                int FindBuiltInTileIconTextureCacheIndex(const string &in path) {
                    for (uint i = 0; i < g_BuiltInTileIconTexturePaths.Length; i++) {
                        if (g_BuiltInTileIconTexturePaths[i] == path) return int(i);
                    }
                    return -1;
                }

                int FindStorageTileIconTextureCacheIndex(const string &in storagePath) {
                    for (uint i = 0; i < g_StorageTileIconTexturePaths.Length; i++) {
                        if (g_StorageTileIconTexturePaths[i] == storagePath) return int(i);
                    }
                    return -1;
                }

                string BuildStoredTileIconPath(const string &in sourcePath) {
                    string baseName = Path::SanitizeFileName(Path::GetFileNameWithoutExtension(sourcePath));
                    if (baseName.Length == 0) baseName = "tile_icon";

                    string ext = Path::GetExtension(sourcePath).ToLower();
                    string fileName = baseName
                        + "_"
                        + tostring(Time::Stamp)
                        + "_"
                        + tostring(Time::Now)
                        + ext;

                    return Path::Join(TILE_ICON_STORAGE_DIR, fileName);
                }

                string CopyTileIconImageToStorage(const string &in sourcePath) {
                    if (sourcePath.Length == 0) return "";

                    if (!IO::FileExists(sourcePath)) {
                        log(
                            "Cannot import tile icon because the source file does not exist: " + sourcePath,
                            LogLevel::Warning,
                            88,
                            "TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage"
                        );
                        return "";
                    }

                    if (!IsSupportedTileIconImagePath(sourcePath)) {
                        log(
                            "Cannot import tile icon because the file type is not supported: " + sourcePath,
                            LogLevel::Warning,
                            98,
                            "TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage"
                        );
                        return "";
                    }

                    string storageFolder = GetTileIconStorageFolderPath();
                    if (!IO::FolderExists(storageFolder)) {
                        IO::CreateFolder(storageFolder, true);
                    }

                    string storagePath = BuildStoredTileIconPath(sourcePath);
                    string targetPath = IO::FromStorageFolder(storagePath);

                    try {
                        IO::Copy(sourcePath, targetPath);
                    } catch {
                        log(
                            "Failed to copy tile icon image to storage: " + sourcePath + " -> " + targetPath,
                            LogLevel::Error,
                            118,
                            "TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage"
                        );
                        return "";
                    }

                    if (!IO::FileExists(targetPath)) {
                        log(
                            "Tile icon copy did not create the expected storage file: " + targetPath,
                            LogLevel::Error,
                            128,
                            "TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage"
                        );
                        return "";
                    }

                    return storagePath;
                }

                MemoryBuffer@ ReadFileToBuffer(const string &in path) {
                    if (!IO::FileExists(path)) return null;

                    IO::File file;
                    try {
                        file.Open(path, IO::FileMode::Read);
                        uint64 size = file.Size();
                        if (size == 0) {
                            file.Close();
                            return null;
                        }

                        MemoryBuffer@ buffer = file.Read(size);
                        file.Close();
                        if (buffer !is null) buffer.Seek(0);
                        return buffer;
                    } catch {
                        log(
                            "Failed to read tile icon image file: " + path,
                            LogLevel::Warning,
                            157,
                            "TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage"
                        );
                    }
                    file.Close();

                    return null;
                }

                nvg::Texture@ LoadTileIconTexture(const string &in path, bool absolutePath) {
                    try {
                        if (!absolutePath) {
                            return nvg::LoadTexture(path);
                        }

                        MemoryBuffer@ buffer = ReadFileToBuffer(path);
                        if (buffer is null) return null;
                        return nvg::LoadTexture(buffer);
                    } catch {
                        log(
                            "Failed to load tile icon texture: " + path,
                            LogLevel::Warning,
                            179,
                            "TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage"
                        );
                    }

                    return null;
                }

                nvg::Texture@ GetMissingTileIconTexture() {
                    if (!g_TriedLoadMissingTileIconTexture) {
                        g_TriedLoadMissingTileIconTexture = true;
                        @g_MissingTileIconTexture = LoadTileIconTexture(DEFAULT_MISSING_TILE_ICON_PATH, false);
                        if (g_MissingTileIconTexture is null) {
                            log(
                                "Failed to load missing tile icon texture: " + DEFAULT_MISSING_TILE_ICON_PATH,
                                LogLevel::Warning,
                                195,
                                "TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage"
                            );
                        }
                    }
                    return g_MissingTileIconTexture;
                }

                nvg::Texture@ GetBuiltInTileIconTexture(const string &in path) {
                    if (path.Length == 0) return null;
                    if (path == DEFAULT_MISSING_TILE_ICON_PATH) return GetMissingTileIconTexture();

                    int cacheIndex = FindBuiltInTileIconTextureCacheIndex(path);
                    if (cacheIndex < 0) {
                        g_BuiltInTileIconTexturePaths.InsertLast(path);
                        g_TriedLoadBuiltInTileIconTextures.InsertLast(false);
                        g_BuiltInTileIconTextures.InsertLast(null);
                        cacheIndex = int(g_BuiltInTileIconTexturePaths.Length) - 1;
                    }

                    uint index = uint(cacheIndex);
                    if (!g_TriedLoadBuiltInTileIconTextures[index]) {
                        g_TriedLoadBuiltInTileIconTextures[index] = true;
                        @g_BuiltInTileIconTextures[index] = LoadTileIconTexture(path, false);
                        if (g_BuiltInTileIconTextures[index] is null) {
                            log(
                                "Failed to load built-in tile icon texture: " + path,
                                LogLevel::Warning,
                                223,
                                "TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage"
                            );
                            @g_BuiltInTileIconTextures[index] = GetMissingTileIconTexture();
                        }
                    }

                    return g_BuiltInTileIconTextures[index];
                }

                nvg::Texture@ GetStorageTileIconTexture(const string &in storagePath) {
                    if (storagePath.Length == 0) return null;
                    if (storagePath == MISSING_TILE_ICON_STORAGE_PATH) return GetMissingTileIconTexture();

                    int cacheIndex = FindStorageTileIconTextureCacheIndex(storagePath);
                    if (cacheIndex < 0) {
                        g_StorageTileIconTexturePaths.InsertLast(storagePath);
                        g_TriedLoadStorageTileIconTextures.InsertLast(false);
                        g_StorageTileIconTextures.InsertLast(null);
                        cacheIndex = int(g_StorageTileIconTexturePaths.Length) - 1;
                    }

                    uint index = uint(cacheIndex);
                    if (!g_TriedLoadStorageTileIconTextures[index]) {
                        g_TriedLoadStorageTileIconTextures[index] = true;
                        string path = IO::FromStorageFolder(storagePath);
                        @g_StorageTileIconTextures[index] = LoadTileIconTexture(path, true);
                        if (g_StorageTileIconTextures[index] is null) {
                            log(
                                "Failed to load custom tile icon texture: " + path,
                                LogLevel::Warning,
                                254,
                                "TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage"
                            );
                            @g_StorageTileIconTextures[index] = GetMissingTileIconTexture();
                        }
                    }

                    return g_StorageTileIconTextures[index];
                }

                string GetCustomTileIconTextureKey(const string &in storagePath) {
                    if (storagePath.Length == 0) return "";
                    if (storagePath == MISSING_TILE_ICON_STORAGE_PATH) return MISSING_TILE_ICON_TEXTURE_KEY;
                    return STORAGE_TILE_ICON_TEXTURE_KEY_PREFIX + storagePath;
                }

                bool IsCustomTileIconTextureKey(const string &in key) {
                    return key.StartsWith(STORAGE_TILE_ICON_TEXTURE_KEY_PREFIX);
                }

                string GetCustomTileIconStoragePathFromKey(const string &in key) {
                    if (!IsCustomTileIconTextureKey(key)) return "";
                    return key.SubStr(STORAGE_TILE_ICON_TEXTURE_KEY_PREFIX.Length);
                }

                nvg::Texture@ GetSkullTileIconTexture() {
                    bool useCustomImage = TriggerVisualizer::Trigger::UI::S_CustomTileIconStoragePath.Length > 0
                        && TriggerVisualizer::Trigger::UI::S_CustomTileIconStoragePath != MISSING_TILE_ICON_STORAGE_PATH;
                    string path = GetConfiguredSkullTileIconTexturePath();

                    if (!g_TriedLoadSkullTileIconTexture || g_LoadedSkullTileIconPath != path) {
                        g_TriedLoadSkullTileIconTexture = true;
                        g_LoadedSkullTileIconPath = path;
                        @g_SkullTileIconTexture = LoadTileIconTexture(path, useCustomImage);
                        if (g_SkullTileIconTexture is null) {
                            log(
                                "Failed to load configured tile icon texture: " + path,
                                LogLevel::Warning,
                                292,
                                "TriggerVisualizer::Trigger::Render::Assets::GetCustomTileIconStoragePathFromKey"
                            );
                            @g_SkullTileIconTexture = GetMissingTileIconTexture();
                            g_LoadedSkullTileIconPath = DEFAULT_MISSING_TILE_ICON_PATH;
                        }
                    }

                    return g_SkullTileIconTexture;
                }

                bool HasSkullTileIconTexture() {
                    return GetSkullTileIconTexture() !is null;
                }

                string GetMediaTrackerTileIconPathForSubtype(const string &in rawKey) {
                    string key = NormalizeTriggerTargetKey(rawKey);
                    if (key == MT_SUBTYPE_CAMERA) return MEDIATRACKER_TILE_ICON_BASE_PATH + "camera/camera_player.png";
                    if (key == MT_SUBTYPE_CUSTOM_CAMERA) return MEDIATRACKER_TILE_ICON_BASE_PATH + "camera/camera_custom.png";
                    if (key == MT_SUBTYPE_ORBITAL_CAMERA) return MEDIATRACKER_TILE_ICON_BASE_PATH + "camera/camera_orbital.png";
                    if (key == MT_SUBTYPE_PATH_CAMERA) return MEDIATRACKER_TILE_ICON_BASE_PATH + "camera/camera_path.png";
                    if (key == MT_SUBTYPE_PLAYER_CAMERA) return MEDIATRACKER_TILE_ICON_BASE_PATH + "camera/camera_player.png";
                    if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT) return MEDIATRACKER_TILE_ICON_BASE_PATH + "camera/camera_default.png";
                    if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1) return MEDIATRACKER_TILE_ICON_BASE_PATH + "camera/camera_cam1_external.png";
                    if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2) return MEDIATRACKER_TILE_ICON_BASE_PATH + "camera/camera_cam2_external.png";
                    if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3) return MEDIATRACKER_TILE_ICON_BASE_PATH + "camera/camera_cam3_internal.png";
                    if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO) return MEDIATRACKER_TILE_ICON_BASE_PATH + "camera/camera_helico.png";
                    if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE) return MEDIATRACKER_TILE_ICON_BASE_PATH + "camera/camera_free.png";
                    if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR) return MEDIATRACKER_TILE_ICON_BASE_PATH + "camera/camera_spectator.png";
                    if (key == MT_SUBTYPE_2D_TRIANGLES) return MEDIATRACKER_TILE_ICON_BASE_PATH + "triangles_2d.png";
                    if (key == MT_SUBTYPE_3D_TRIANGLES) return MEDIATRACKER_TILE_ICON_BASE_PATH + "triangles_3d.png";
                    if (key == MT_SUBTYPE_COLORS_FX) return MEDIATRACKER_TILE_ICON_BASE_PATH + "colors_fx.png";
                    if (key == MT_SUBTYPE_COLOR_GRADING) return MEDIATRACKER_TILE_ICON_BASE_PATH + "color_grading.png";
                    if (key == MT_SUBTYPE_DEPTH_OF_FIELD) return MEDIATRACKER_TILE_ICON_BASE_PATH + "depth_of_field.png";
                    if (key == MT_SUBTYPE_DIRTY_LENS) return MEDIATRACKER_TILE_ICON_BASE_PATH + "dirty_lens.png";
                    if (key == MT_SUBTYPE_FADING_TRANSITION) return MEDIATRACKER_TILE_ICON_BASE_PATH + "fading_transition.png";
                    if (key == MT_SUBTYPE_FOG) return MEDIATRACKER_TILE_ICON_BASE_PATH + "fog.png";
                    if (key == MT_SUBTYPE_GHOST) return MEDIATRACKER_TILE_ICON_BASE_PATH + "ghost.png";
                    if (key == MT_SUBTYPE_HDR_BLOOM) return MEDIATRACKER_TILE_ICON_BASE_PATH + "hdr_bloom.png";
                    if (key == MT_SUBTYPE_IMAGE) return MEDIATRACKER_TILE_ICON_BASE_PATH + "image.png";
                    if (key == MT_SUBTYPE_MANIALINK_UI) return MEDIATRACKER_TILE_ICON_BASE_PATH + "manialink_ui.png";
                    if (key == MT_SUBTYPE_MANIALINK_URL) return MEDIATRACKER_TILE_ICON_BASE_PATH + "manialink_url.png";
                    if (key == MT_SUBTYPE_MUSIC_VOLUME) return MEDIATRACKER_TILE_ICON_BASE_PATH + "music_volume.png";
                    if (key == MT_SUBTYPE_SOUND_FX) return MEDIATRACKER_TILE_ICON_BASE_PATH + "sound_fx.png";
                    if (key == MT_SUBTYPE_SPECTATORS) return MEDIATRACKER_TILE_ICON_BASE_PATH + "camera/camera_spectator.png";
                    if (key == MT_SUBTYPE_TEXT) return MEDIATRACKER_TILE_ICON_BASE_PATH + "text.png";
                    if (key == MT_SUBTYPE_TIME) return MEDIATRACKER_TILE_ICON_BASE_PATH + "time.png";
                    if (key == MT_SUBTYPE_TIME_SPEED) return MEDIATRACKER_TILE_ICON_BASE_PATH + "time_speed.png";
                    if (key == MT_SUBTYPE_RESET) return MEDIATRACKER_TILE_ICON_BASE_PATH + "reset.png";
                    if (key == MT_SUBTYPE_UNKNOWN) return DEFAULT_MISSING_TILE_ICON_PATH;
                    return DEFAULT_MISSING_TILE_ICON_PATH;
                }

                string GetMediaTrackerTileIconTextureKeyForSubtype(const string &in rawKey) {
                    string key = NormalizeTriggerTargetKey(rawKey);
                    if (!TriggerVisualizer::Trigger::UI::IsTileIconEnabledForSubtype(key)) return "";

                    string customStoragePath = TriggerVisualizer::Trigger::UI::GetTileIconCustomStoragePathForSubtype(key);
                    if (customStoragePath.Length > 0) return GetCustomTileIconTextureKey(customStoragePath);
                    return GetMediaTrackerTileIconPathForSubtype(key);
                }

                string GetMediaTrackerTileIconTextureKeyFromTargetKeys(const string &in targetKeys) {
                    const string[] priority = {
                        MT_SUBTYPE_GHOST,
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT,
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1,
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2,
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3,
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO,
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE,
                        MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR,
                        MT_SUBTYPE_CUSTOM_CAMERA,
                        MT_SUBTYPE_ORBITAL_CAMERA,
                        MT_SUBTYPE_PATH_CAMERA,
                        MT_SUBTYPE_PLAYER_CAMERA,
                        MT_SUBTYPE_CAMERA,
                        MT_SUBTYPE_2D_TRIANGLES,
                        MT_SUBTYPE_3D_TRIANGLES,
                        MT_SUBTYPE_FOG,
                        MT_SUBTYPE_IMAGE,
                        MT_SUBTYPE_TEXT,
                        MT_SUBTYPE_TIME,
                        MT_SUBTYPE_TIME_SPEED,
                        MT_SUBTYPE_FADING_TRANSITION,
                        MT_SUBTYPE_MANIALINK_UI,
                        MT_SUBTYPE_MANIALINK_URL,
                        MT_SUBTYPE_SOUND_FX,
                        MT_SUBTYPE_MUSIC_VOLUME,
                        MT_SUBTYPE_COLORS_FX,
                        MT_SUBTYPE_COLOR_GRADING,
                        MT_SUBTYPE_DIRTY_LENS,
                        MT_SUBTYPE_HDR_BLOOM,
                        MT_SUBTYPE_DEPTH_OF_FIELD,
                        MT_SUBTYPE_SPECTATORS,
                        MT_SUBTYPE_RESET,
                        MT_SUBTYPE_UNKNOWN
                    };

                    for (uint i = 0; i < priority.Length; i++) {
                        if (!TriggerTargetListContains(targetKeys, priority[i])) continue;
                        string textureKey = GetMediaTrackerTileIconTextureKeyForSubtype(priority[i]);
                        if (textureKey.Length > 0) return textureKey;
                    }

                    return "";
                }

                string GetTileIconTextureKeyForVolume(const TriggerVolume@ volume) {
                    if (volume is null) return "";
                    if (volume.Source == TRIGGER_SOURCE_OFFZONE) {
                        return TriggerVisualizer::Trigger::UI::S_ShowOffzoneTileIcon ? OFFZONE_TILE_ICON_TEXTURE_KEY : "";
                    }
                    if (TriggerTargetListContains(volume.TargetKeys, MT_SUBTYPE_UNKNOWN)) {
                        return TriggerVisualizer::Trigger::UI::IsTileIconEnabledForSubtype(MT_SUBTYPE_UNKNOWN) ?
                            MISSING_TILE_ICON_TEXTURE_KEY : "";
                    }
                    if (volume.Source != TRIGGER_SOURCE_MEDIATRACKER) return "";

                    string textureKey = GetMediaTrackerTileIconTextureKeyForSubtype(volume.SubtypeKey);
                    if (textureKey.Length > 0) return textureKey;
                    textureKey = GetMediaTrackerTileIconTextureKeyFromTargetKeys(volume.TargetKeys);
                    return textureKey;
                }

                nvg::Texture@ GetTileIconTextureByKey(const string &in key) {
                    if (key.Length == 0) return null;
                    if (key == OFFZONE_TILE_ICON_TEXTURE_KEY) return GetSkullTileIconTexture();
                    if (key == MISSING_TILE_ICON_TEXTURE_KEY) return GetMissingTileIconTexture();
                    if (IsCustomTileIconTextureKey(key)) {
                        return GetStorageTileIconTexture(GetCustomTileIconStoragePathFromKey(key));
                    }
                    return GetBuiltInTileIconTexture(key);
                }
            }
        }
    }
}
