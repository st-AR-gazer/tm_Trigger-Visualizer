namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            namespace Assets {
                const string DEFAULT_SKULL_TILE_ICON_PATH = "src/assets/skull_and_crossbones.png";
                const string TILE_ICON_STORAGE_DIR = "assets/";

                nvg::Texture@ g_SkullTileIconTexture = null;
                bool g_TriedLoadSkullTileIconTexture = false;
                string g_LoadedSkullTileIconPath = "";

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
                    return IO::FromStorageFolder(storagePath);
                }

                string GetCurrentTileIconDisplayPath() {
                    string storagePath = TriggerVisualizer::Trigger::UI::S_CustomTileIconStoragePath;
                    if (storagePath.Length == 0) return DEFAULT_SKULL_TILE_ICON_PATH + " (default)";
                    return IO::FromStorageFolder(storagePath);
                }

                void InvalidateSkullTileIconTexture() {
                    @g_SkullTileIconTexture = null;
                    g_TriedLoadSkullTileIconTexture = false;
                    g_LoadedSkullTileIconPath = "";
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
                            58,
                            "TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage"
                        );
                        return "";
                    }

                    if (!IsSupportedTileIconImagePath(sourcePath)) {
                        log(
                            "Cannot import tile icon because the file type is not supported: " + sourcePath,
                            LogLevel::Warning,
                            68,
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
                            88,
                            "TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage"
                        );
                        return "";
                    }

                    if (!IO::FileExists(targetPath)) {
                        log(
                            "Tile icon copy did not create the expected storage file: " + targetPath,
                            LogLevel::Error,
                            98,
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
                            127,
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
                            149,
                            "TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage"
                        );
                    }

                    return null;
                }

                nvg::Texture@ GetSkullTileIconTexture() {
                    bool useCustomImage = TriggerVisualizer::Trigger::UI::S_CustomTileIconStoragePath.Length > 0;
                    string path = GetConfiguredSkullTileIconTexturePath();

                    if (!g_TriedLoadSkullTileIconTexture || g_LoadedSkullTileIconPath != path) {
                        g_TriedLoadSkullTileIconTexture = true;
                        g_LoadedSkullTileIconPath = path;
                        @g_SkullTileIconTexture = LoadTileIconTexture(path, useCustomImage);

                        if (g_SkullTileIconTexture is null) {
                            log(
                                "Failed to load configured tile icon texture: " + path,
                                LogLevel::Warning,
                                170,
                                "TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage"
                            );

                            if (path != DEFAULT_SKULL_TILE_ICON_PATH) {
                                @g_SkullTileIconTexture = LoadTileIconTexture(DEFAULT_SKULL_TILE_ICON_PATH, false);
                                g_LoadedSkullTileIconPath = DEFAULT_SKULL_TILE_ICON_PATH;
                            }
                        }
                    }

                    return g_SkullTileIconTexture;
                }

                bool HasSkullTileIconTexture() {
                    return GetSkullTileIconTexture() !is null;
                }
            }
        }
    }
}
