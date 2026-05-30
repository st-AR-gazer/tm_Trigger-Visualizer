namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            void AddPendingTileIconImage() {
                if (G_PendingTileIconSourcePath.Length == 0) return;

                string storagePath = TriggerVisualizer::Trigger::Render::Assets::CopyTileIconImageToStorage(G_PendingTileIconSourcePath);

                if (storagePath.Length == 0) {
                    G_TileIconImportStatus = "Could not add image. Make sure it is a supported image file.";
                    NotifyWarning(G_TileIconImportStatus, TriggerVisualizer::PluginMeta.Name, 6000);
                    return;
                }

                S_CustomTileIconStoragePath = storagePath;
                G_PendingTileIconSourcePath = "";
                G_TileIconImportStatus = "Added image: " + IO::FromStorageFolder(storagePath);
                TriggerVisualizer::Trigger::Render::Assets::InvalidateSkullTileIconTexture();
                NotifyInfo("Tile icon image added.", TriggerVisualizer::PluginMeta.Name, 5000);
            }

            void RenderTileIconImagePickerUI() {
                UI::Text("Image");

                UI::PushItemWidth(520.0f);
                G_PendingTileIconSourcePath = UI::InputText(
                    "Image path##trigger-visualizer-tile-icon-manual-path",
                    G_PendingTileIconSourcePath
                );
                UI::PopItemWidth();

                UI::Text("Current image:");
                UI::PushItemWidth(520.0f);
                UI::InputText(
                    "##trigger-visualizer-current-tile-icon-path",
                    TriggerVisualizer::Trigger::Render::Assets::GetCurrentTileIconDisplayPath(),
                    UI::InputTextFlags::ReadOnly
                );
                UI::PopItemWidth();

                if (S_CustomTileIconStoragePath.Length > 0) {
                    if (UI::Button("Use default image##trigger-visualizer-tile-icon-use-default")) {
                        S_CustomTileIconStoragePath = "";
                        TriggerVisualizer::Trigger::Render::Assets::InvalidateSkullTileIconTexture();
                        G_TileIconImportStatus = "Using default image.";
                    }
                }

                if (G_PendingTileIconSourcePath.Length > 0) {
                    UI::Separator();
                    if (!TriggerVisualizer::Trigger::Render::Assets::IsSupportedTileIconImagePath(G_PendingTileIconSourcePath)) {
                        UI::TextDisabled("Supported file types: png, jpg, jpeg, webp, bmp.");
                    } else if (UI::Button("Add this image##trigger-visualizer-tile-icon-add-selected")) {
                        AddPendingTileIconImage();
                    }

                    UI::SameLine();
                    if (UI::Button("Clear selection##trigger-visualizer-tile-icon-clear-selected")) {
                        G_PendingTileIconSourcePath = "";
                        G_TileIconImportStatus = "";
                    }
                }

                if (G_TileIconImportStatus.Length > 0) {
                    UI::TextWrapped(G_TileIconImportStatus);
                }
            }

            void RenderTileIconSettingsUI() {
                UI::Text("Tile Icons");
                S_ShowSkullTileIcons = UI::Checkbox(
                    "Show tile icon at tile centers##trigger-visualizer-image-tiles",
                    S_ShowSkullTileIcons
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

                RenderTileIconImagePickerUI();

                ClampColorSettings();
            }

            void RenderImageTilesSettingsUI() {
                RenderTileIconSettingsUI();
            }
        }
    }
}
