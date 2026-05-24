namespace OffzoneVisualizer {
    namespace Offzone {
        namespace UI {
            [Setting hidden name="Offzone: Render world overlay"]
            bool S_RenderWorld = true;

            [Setting hidden name="Offzone: Show labels"]
            bool S_ShowLabels = true;

            [Setting hidden name="Offzone: Label show index"]
            bool S_LabelShowIndex = true;

            [Setting hidden name="Offzone: Label show raw range"]
            bool S_LabelShowRawRange = false;

            [Setting hidden name="Offzone: Label show world size"]
            bool S_LabelShowWorldSize = false;

            [Setting hidden name="Offzone: Label font size" min=8 max=48]
            float S_LabelFontSize = 16.0f;

            [Setting hidden name="Offzone: Label alpha" min=0 max=1]
            float S_LabelAlpha = 0.95f;

            [Setting hidden name="Offzone: Label background alpha" min=0 max=1]
            float S_LabelBackgroundAlpha = 0.20f;

            [Setting hidden name="Offzone: Show face fill"]
            bool S_ShowFill = true;

            [Setting hidden name="Offzone: Show outline"]
            bool S_ShowOutline = true;

            [Setting hidden name="Offzone: Render distance XZ" min=0 max=50000]
            float S_RenderDistanceXZ = 128.0f;

            [Setting hidden name="Offzone: Render distance Y" min=0 max=50000]
            float S_RenderDistanceY = 32.0f;

            [Setting hidden name="Offzone: Render fade band XZ" min=0 max=50000]
            float S_RenderFadeBandXZ = 32.0f;

            [Setting hidden name="Offzone: Render fade band Y" min=0 max=50000]
            float S_RenderFadeBandY = 8.0f;

            [Setting hidden name="Offzone: Outline alpha" min=0 max=1]
            float S_OutlineAlpha = 0.20f;

            [Setting hidden name="Offzone: Fill alpha" min=0 max=1]
            float S_FillAlpha = 0.03f;

            [Setting hidden name="Offzone: Outline width" min=0 max=16]
            float S_OutlineWidth = 2.0f;

            [Setting hidden name="Offzone: Adaptive line splitting"]
            bool S_AdaptiveLineSplitting = true;

            [Setting hidden name="Offzone: Line split minimum segment length" min=4 max=512]
            float S_LineSplitTargetSegmentLength = 4.0f;

            [Setting hidden name="Offzone: Line split start distance factor" min=0.01 max=4]
            float S_LineSplitStartDistanceFactor = 0.33f;

            [Setting hidden name="Offzone: Line split full distance factor" min=0.001 max=1]
            float S_LineSplitFullDistanceFactor = 0.05f;

            [Setting hidden name="Offzone: Line split min start distance" min=0 max=50000]
            float S_LineSplitMinStartDistance = 16.0f;

            [Setting hidden name="Offzone: Line split max start distance" min=0 max=50000]
            float S_LineSplitMaxStartDistance = 50000.0f;

            [Setting hidden name="Offzone: Line split min full distance" min=0 max=50000]
            float S_LineSplitMinFullDistance = 2.0f;

            [Setting hidden name="Offzone: Line split max full distance" min=0 max=50000]
            float S_LineSplitMaxFullDistance = 96.0f;

            [Setting hidden name="Offzone: Line split max segments per edge" min=1 max=512]
            int S_LineSplitMaxSegmentsPerEdge = 512;

            const int COLOR_MODE_STATIC = 0;
            const int COLOR_MODE_DISTANCE_FADE = 1;
            const int COLOR_MODE_LINE_SPLIT_DENSITY = 2;

            const int PROXIMITY_MODE_CAMERA_ONLY = 0;
            const int PROXIMITY_MODE_PLAYER_ONLY = 1;
            const int PROXIMITY_MODE_CAMERA_AND_PLAYER = 2;

            const float WORLD_BLOCK_SIZE_XZ = 32.0f;
            const float WORLD_BLOCK_SIZE_Y = 8.0f;
            const float WORLD_RENDER_SLIDER_MAX_XZ = WORLD_BLOCK_SIZE_XZ * 48.0f;
            const float WORLD_RENDER_SLIDER_MAX_Y = WORLD_BLOCK_SIZE_Y * 40.0f;
            const float WORLD_FADE_SLIDER_MAX_XZ = WORLD_BLOCK_SIZE_XZ * 5.0f;
            const float WORLD_FADE_SLIDER_MAX_Y = WORLD_BLOCK_SIZE_Y * 5.0f;
            const float WORLD_RENDER_SETTING_MAX = 50000.0f;

            [Setting hidden name="Offzone: Color mode" min=0 max=2]
            int S_ColorMode = COLOR_MODE_STATIC;

            [Setting hidden name="Offzone: Render proximity mode" min=0 max=2]
            int S_RenderProximityMode = PROXIMITY_MODE_CAMERA_AND_PLAYER;

            [Setting hidden name="Offzone: Base offzone color"]
            vec4 S_BaseOffzoneColor = vec4(1.0f, 0.45f, 0.10f, 1.0f);

            [Setting hidden name="Offzone: Distance fade color"]
            vec4 S_DistanceFadeColor = vec4(1.0f, 0.90f, 0.20f, 1.0f);

            [Setting hidden name="Offzone: Dense line split color"]
            vec4 S_DenseLineSplitColor = vec4(0.10f, 0.85f, 1.0f, 1.0f);

            [Setting hidden name="Offzone: Random outline segment colors"]
            bool S_RandomOutlineSegmentColors = false;

            [Setting hidden name="Offzone: Random fill tile colors"]
            bool S_RandomFillTileColors = false;

            [Setting hidden name="Offzone: Show skull tile icons"]
            bool S_ShowSkullTileIcons = false;

            [Setting hidden name="Offzone: Skull tile icon scale" min=0.05 max=1]
            float S_SkullTileIconScale = 0.45f;

            [Setting hidden name="Offzone: Skull tile icon alpha" min=0 max=1]
            float S_SkullTileIconAlpha = 0.85f;

            [Setting hidden name="Offzone: Custom tile icon storage path"]
            string S_CustomTileIconStoragePath = "";

            string G_PendingTileIconSourcePath = "";
            string G_TileIconImportStatus = "";

            vec3 GetRenderDistanceWorld() {
                return vec3(S_RenderDistanceXZ, S_RenderDistanceY, S_RenderDistanceXZ);
            }

            vec3 GetRenderFadeBandWorld() {
                return vec3(S_RenderFadeBandXZ, S_RenderFadeBandY, S_RenderFadeBandXZ);
            }

            void ClampWorldRenderingSettings() {
                S_RenderDistanceXZ = Math::Clamp(S_RenderDistanceXZ, 0.0f, WORLD_RENDER_SETTING_MAX);
                S_RenderDistanceY = Math::Clamp(S_RenderDistanceY, 0.0f, WORLD_RENDER_SETTING_MAX);
                S_RenderFadeBandXZ = Math::Clamp(S_RenderFadeBandXZ, 0.0f, WORLD_RENDER_SETTING_MAX);
                S_RenderFadeBandY = Math::Clamp(S_RenderFadeBandY, 0.0f, WORLD_RENDER_SETTING_MAX);
                S_OutlineAlpha = Math::Clamp(S_OutlineAlpha, 0.0f, 1.0f);
                S_FillAlpha = Math::Clamp(S_FillAlpha, 0.0f, 1.0f);
                S_OutlineWidth = Math::Clamp(S_OutlineWidth, 0.5f, 16.0f);
            }

            void ClampLineSplittingSettings() {
                S_LineSplitTargetSegmentLength = Math::Clamp(S_LineSplitTargetSegmentLength, 4.0f, 512.0f);
                S_LineSplitStartDistanceFactor = Math::Clamp(S_LineSplitStartDistanceFactor, 0.01f, 4.0f);
                S_LineSplitFullDistanceFactor = Math::Clamp(S_LineSplitFullDistanceFactor, 0.001f, 1.0f);

                S_LineSplitMinStartDistance = Math::Clamp(S_LineSplitMinStartDistance, 0.0f, 50000.0f);
                S_LineSplitMaxStartDistance = Math::Clamp(S_LineSplitMaxStartDistance, 0.0f, 50000.0f);
                if (S_LineSplitMinStartDistance > S_LineSplitMaxStartDistance) {
                    S_LineSplitMaxStartDistance = S_LineSplitMinStartDistance;
                }

                S_LineSplitMinFullDistance = Math::Clamp(S_LineSplitMinFullDistance, 0.0f, 50000.0f);
                S_LineSplitMaxFullDistance = Math::Clamp(S_LineSplitMaxFullDistance, 0.0f, 50000.0f);
                if (S_LineSplitMinFullDistance > S_LineSplitMaxFullDistance) {
                    S_LineSplitMaxFullDistance = S_LineSplitMinFullDistance;
                }

                S_LineSplitMaxSegmentsPerEdge = Math::Clamp(S_LineSplitMaxSegmentsPerEdge, 1, 512);
            }

            vec4 ClampColor(const vec4 &in color) {
                return vec4(
                    Math::Clamp(color.x, 0.0f, 1.0f),
                    Math::Clamp(color.y, 0.0f, 1.0f),
                    Math::Clamp(color.z, 0.0f, 1.0f),
                    Math::Clamp(color.w, 0.0f, 1.0f)
                );
            }

            void ClampColorSettings() {
                S_ColorMode = Math::Clamp(S_ColorMode, COLOR_MODE_STATIC, COLOR_MODE_LINE_SPLIT_DENSITY);
                S_BaseOffzoneColor = ClampColor(S_BaseOffzoneColor);
                S_DistanceFadeColor = ClampColor(S_DistanceFadeColor);
                S_DenseLineSplitColor = ClampColor(S_DenseLineSplitColor);
                S_SkullTileIconScale = Math::Clamp(S_SkullTileIconScale, 0.05f, 1.0f);
                S_SkullTileIconAlpha = Math::Clamp(S_SkullTileIconAlpha, 0.0f, 1.0f);
            }

            void ClampLabelSettings() {
                S_LabelFontSize = Math::Clamp(S_LabelFontSize, 8.0f, 48.0f);
                S_LabelAlpha = Math::Clamp(S_LabelAlpha, 0.0f, 1.0f);
                S_LabelBackgroundAlpha = Math::Clamp(S_LabelBackgroundAlpha, 0.0f, 1.0f);
            }

            void ResetSettingsToDefaults() {
                S_RenderWorld = true;
                S_ShowLabels = true;
                S_LabelShowIndex = true;
                S_LabelShowRawRange = false;
                S_LabelShowWorldSize = false;
                S_LabelFontSize = 16.0f;
                S_LabelAlpha = 0.95f;
                S_LabelBackgroundAlpha = 0.20f;
                S_ShowFill = true;
                S_ShowOutline = true;
                S_RenderDistanceXZ = 128.0f;
                S_RenderDistanceY = 32.0f;
                S_RenderFadeBandXZ = 32.0f;
                S_RenderFadeBandY = 8.0f;
                S_OutlineAlpha = 0.20f;
                S_FillAlpha = 0.03f;
                S_OutlineWidth = 2.0f;
                S_AdaptiveLineSplitting = true;
                S_LineSplitTargetSegmentLength = 4.0f;
                S_LineSplitStartDistanceFactor = 0.33f;
                S_LineSplitFullDistanceFactor = 0.05f;
                S_LineSplitMinStartDistance = 16.0f;
                S_LineSplitMaxStartDistance = 50000.0f;
                S_LineSplitMinFullDistance = 2.0f;
                S_LineSplitMaxFullDistance = 96.0f;
                S_LineSplitMaxSegmentsPerEdge = 512;
                S_ColorMode = COLOR_MODE_STATIC;
                S_RenderProximityMode = PROXIMITY_MODE_CAMERA_AND_PLAYER;
                S_BaseOffzoneColor = vec4(1.0f, 0.45f, 0.10f, 1.0f);
                S_DistanceFadeColor = vec4(1.0f, 0.90f, 0.20f, 1.0f);
                S_DenseLineSplitColor = vec4(0.10f, 0.85f, 1.0f, 1.0f);
                S_RandomOutlineSegmentColors = false;
                S_RandomFillTileColors = false;
                S_ShowSkullTileIcons = false;
                S_SkullTileIconScale = 0.45f;
                S_SkullTileIconAlpha = 0.85f;
                S_CustomTileIconStoragePath = "";
                G_PendingTileIconSourcePath = "";
                G_TileIconImportStatus = "";
                OffzoneVisualizer::Offzone::Render::Assets::InvalidateSkullTileIconTexture();

                ClampWorldRenderingSettings();
                ClampLineSplittingSettings();
                ClampColorSettings();
                ClampLabelSettings();
            }

            string GetColorModeLabel(int mode) {
                if (mode == COLOR_MODE_DISTANCE_FADE) return "Distance fade";
                if (mode == COLOR_MODE_LINE_SPLIT_DENSITY) return "Line split density";
                return "Static";
            }

            string GetRenderProximityModeLabel(int mode) {
                if (mode == PROXIMITY_MODE_PLAYER_ONLY) return "Car only";
                if (mode == PROXIMITY_MODE_CAMERA_AND_PLAYER) return "Camera + car";
                return "Camera only";
            }

            void RenderColorModeOption(int mode) {
                bool selected = S_ColorMode == mode;
                if (UI::Selectable(GetColorModeLabel(mode), selected)) {
                    S_ColorMode = mode;
                }
            }

            void RenderProximityModeOption(int mode) {
                bool selected = S_RenderProximityMode == mode;
                if (UI::Selectable(GetRenderProximityModeLabel(mode), selected)) {
                    S_RenderProximityMode = mode;
                }
            }

            float SnapWorldDistanceToPreviousBlock(float value, float blockSize) {
                if (blockSize <= 0.0f) return value;

                float blocks = value / blockSize;
                float snappedBlocks = Math::Floor(blocks);
                if (Math::Abs(snappedBlocks - blocks) <= 0.001f) {
                    snappedBlocks -= 1.0f;
                }

                return Math::Clamp(snappedBlocks * blockSize, 0.0f, WORLD_RENDER_SETTING_MAX);
            }

            float SnapWorldDistanceToNextBlock(float value, float blockSize) {
                if (blockSize <= 0.0f) return value;

                float blocks = value / blockSize;
                float snappedBlocks = Math::Ceil(blocks);
                if (Math::Abs(snappedBlocks - blocks) <= 0.001f) {
                    snappedBlocks += 1.0f;
                }

                return Math::Clamp(snappedBlocks * blockSize, 0.0f, WORLD_RENDER_SETTING_MAX);
            }

            float RenderWorldDistanceSlider(
                const string &in label,
                const string &in id,
                float value,
                float minValue,
                float maxValue,
                float blockSize
            ) {
                UI::SetNextItemWidth(260.0f);
                value = UI::SliderFloat(label + "##" + id, value, minValue, maxValue, "%.0f m");

                float buttonSize = UI::GetFrameHeight();
                UI::SameLine();
                if (UI::Button("-##" + id + "-prev-block", vec2(buttonSize, buttonSize))) {
                    value = SnapWorldDistanceToPreviousBlock(value, blockSize);
                }

                UI::SameLine();
                if (UI::Button("+##" + id + "-next-block", vec2(buttonSize, buttonSize))) {
                    value = SnapWorldDistanceToNextBlock(value, blockSize);
                }

                UI::SameLine();
                UI::TextDisabled("~" + Text::Format("%.1f", value / blockSize) + " blocks");
                return value;
            }

            void RenderWorldRenderingSettingsUI() {
                UI::Text("World Rendering");
                S_RenderWorld = UI::Checkbox("Enable world render##offzone-visualizer-settings", S_RenderWorld);
                S_ShowOutline = UI::Checkbox("Show outlines##offzone-visualizer-settings", S_ShowOutline);
                S_ShowFill = UI::Checkbox("Show face fill##offzone-visualizer-settings", S_ShowFill);
                S_ShowLabels = UI::Checkbox("Show labels##offzone-visualizer-settings", S_ShowLabels);

                UI::Separator();
                UI::Text("Distance");
                S_RenderDistanceXZ = RenderWorldDistanceSlider(
                    "Render distance X/Z",
                    "offzone-visualizer-settings-render-distance-xz",
                    S_RenderDistanceXZ,
                    0.0f,
                    WORLD_RENDER_SLIDER_MAX_XZ,
                    WORLD_BLOCK_SIZE_XZ
                );
                S_RenderDistanceY = RenderWorldDistanceSlider(
                    "Render distance Y",
                    "offzone-visualizer-settings-render-distance-y",
                    S_RenderDistanceY,
                    0.0f,
                    WORLD_RENDER_SLIDER_MAX_Y,
                    WORLD_BLOCK_SIZE_Y
                );
                S_RenderFadeBandXZ = RenderWorldDistanceSlider(
                    "Render fade X/Z",
                    "offzone-visualizer-settings-render-fade-xz",
                    S_RenderFadeBandXZ,
                    0.0f,
                    WORLD_FADE_SLIDER_MAX_XZ,
                    WORLD_BLOCK_SIZE_XZ
                );
                S_RenderFadeBandY = RenderWorldDistanceSlider(
                    "Render fade Y",
                    "offzone-visualizer-settings-render-fade-y",
                    S_RenderFadeBandY,
                    0.0f,
                    WORLD_FADE_SLIDER_MAX_Y,
                    WORLD_BLOCK_SIZE_Y
                );

                ClampWorldRenderingSettings();
            }

            void RenderLineSplittingSettingsUI() {
                UI::Text("Adaptive Line Splitting");
                S_AdaptiveLineSplitting = UI::Checkbox(
                    "Enable adaptive line splitting##offzone-visualizer-line-splitting",
                    S_AdaptiveLineSplitting
                );
                UI::TextDisabled("Splitting always uses camera distance, even when proximity uses the player.");
                UI::TextDisabled("Closest edges use the minimum segment length. The default keeps segments at least 4m long.");
                UI::TextDisabled("Smaller segment lengths and higher segment caps cost more render work.");

                UI::Separator();
                UI::SetNextItemWidth(220.0f);
                S_LineSplitTargetSegmentLength = UI::InputFloat(
                    "Minimum segment length##offzone-visualizer-line-splitting",
                    S_LineSplitTargetSegmentLength
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitStartDistanceFactor = UI::SliderFloat(
                    "Start distance factor##offzone-visualizer-line-splitting",
                    S_LineSplitStartDistanceFactor,
                    0.01f,
                    4.0f
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitFullDistanceFactor = UI::SliderFloat(
                    "Full distance factor##offzone-visualizer-line-splitting",
                    S_LineSplitFullDistanceFactor,
                    0.001f,
                    1.0f
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMinStartDistance = UI::InputFloat(
                    "Min start distance##offzone-visualizer-line-splitting",
                    S_LineSplitMinStartDistance
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMaxStartDistance = UI::InputFloat(
                    "Max start distance##offzone-visualizer-line-splitting",
                    S_LineSplitMaxStartDistance
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMinFullDistance = UI::InputFloat(
                    "Min full distance##offzone-visualizer-line-splitting",
                    S_LineSplitMinFullDistance
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMaxFullDistance = UI::InputFloat(
                    "Max full distance##offzone-visualizer-line-splitting",
                    S_LineSplitMaxFullDistance
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMaxSegmentsPerEdge = UI::InputInt(
                    "Max segments per edge##offzone-visualizer-line-splitting",
                    S_LineSplitMaxSegmentsPerEdge
                );

                ClampLineSplittingSettings();
            }

            void AddPendingTileIconImage() {
                if (G_PendingTileIconSourcePath.Length == 0) return;

                string storagePath = OffzoneVisualizer::Offzone::Render::Assets::CopyTileIconImageToStorage(G_PendingTileIconSourcePath);

                if (storagePath.Length == 0) {
                    G_TileIconImportStatus = "Could not add image. Make sure it is a supported image file.";
                    NotifyWarning(G_TileIconImportStatus, OffzoneVisualizer::PluginMeta.Name, 6000);
                    return;
                }

                S_CustomTileIconStoragePath = storagePath;
                G_PendingTileIconSourcePath = "";
                G_TileIconImportStatus = "Added image: " + IO::FromStorageFolder(storagePath);
                OffzoneVisualizer::Offzone::Render::Assets::InvalidateSkullTileIconTexture();
                NotifyInfo("Tile icon image added.", OffzoneVisualizer::PluginMeta.Name, 5000);
            }

            void RenderTileIconImagePickerUI() {
                UI::Text("Image");
                UI::TextDisabled("Images are copied into plugin storage under assets/ so they keep working later.");
                UI::TextDisabled("Paste or type a local image path, then click Add this image.");

                UI::PushItemWidth(520.0f);
                G_PendingTileIconSourcePath = UI::InputText(
                    "Image path##offzone-visualizer-tile-icon-manual-path",
                    G_PendingTileIconSourcePath
                );
                UI::PopItemWidth();

                UI::Text("Current image:");
                UI::PushItemWidth(520.0f);
                UI::InputText(
                    "##offzone-visualizer-current-tile-icon-path",
                    OffzoneVisualizer::Offzone::Render::Assets::GetCurrentTileIconDisplayPath(),
                    UI::InputTextFlags::ReadOnly
                );
                UI::PopItemWidth();

                if (S_CustomTileIconStoragePath.Length > 0) {
                    if (UI::Button("Use default image##offzone-visualizer-tile-icon-use-default")) {
                        S_CustomTileIconStoragePath = "";
                        OffzoneVisualizer::Offzone::Render::Assets::InvalidateSkullTileIconTexture();
                        G_TileIconImportStatus = "Using default image.";
                    }
                }

                if (G_PendingTileIconSourcePath.Length > 0) {
                    UI::Separator();
                    if (!OffzoneVisualizer::Offzone::Render::Assets::IsSupportedTileIconImagePath(G_PendingTileIconSourcePath)) {
                        UI::TextDisabled("Supported file types: png, jpg, jpeg, webp, bmp.");
                    } else if (UI::Button("Add this image##offzone-visualizer-tile-icon-add-selected")) {
                        AddPendingTileIconImage();
                    }

                    UI::SameLine();
                    if (UI::Button("Clear selection##offzone-visualizer-tile-icon-clear-selected")) {
                        G_PendingTileIconSourcePath = "";
                        G_TileIconImportStatus = "";
                    }
                }

                if (G_TileIconImportStatus.Length > 0) {
                    UI::TextWrapped(G_TileIconImportStatus);
                }
            }

            void RenderColorSettingsUI() {
                UI::Text("Offzone Color");
                if (UI::BeginCombo("Color mode##offzone-visualizer-color", GetColorModeLabel(S_ColorMode))) {
                    RenderColorModeOption(COLOR_MODE_STATIC);
                    RenderColorModeOption(COLOR_MODE_DISTANCE_FADE);
                    RenderColorModeOption(COLOR_MODE_LINE_SPLIT_DENSITY);
                    UI::EndCombo();
                }

                UI::Separator();
                S_BaseOffzoneColor = UI::InputColor4("Base color##offzone-visualizer-color", S_BaseOffzoneColor);
                S_DistanceFadeColor = UI::InputColor4(
                    "Distance fade color##offzone-visualizer-color",
                    S_DistanceFadeColor
                );
                S_DenseLineSplitColor = UI::InputColor4(
                    "Dense line split color##offzone-visualizer-color",
                    S_DenseLineSplitColor
                );

                UI::Separator();
                UI::Text("Appearance");
                UI::SetNextItemWidth(220.0f);
                S_OutlineAlpha = UI::SliderFloat("Outline alpha##offzone-visualizer-color", S_OutlineAlpha, 0.0f, 1.0f);

                UI::SetNextItemWidth(220.0f);
                S_FillAlpha = UI::SliderFloat("Fill alpha##offzone-visualizer-color", S_FillAlpha, 0.0f, 1.0f);

                UI::SetNextItemWidth(220.0f);
                S_OutlineWidth = UI::SliderFloat(
                    "Outline width##offzone-visualizer-color",
                    S_OutlineWidth,
                    0.5f,
                    16.0f,
                    "%.1f px"
                );

                UI::Separator();
                UI::Text("Stable Random Colors");
                S_RandomOutlineSegmentColors = UI::Checkbox(
                    "Random color per outline segment##offzone-visualizer-color",
                    S_RandomOutlineSegmentColors
                );
                S_RandomFillTileColors = UI::Checkbox(
                    "Random color per fill section/tile##offzone-visualizer-color",
                    S_RandomFillTileColors
                );

                UI::Separator();
                UI::Text("Tile Icons");
                S_ShowSkullTileIcons = UI::Checkbox(
                    "Show tile icon at tile centers##offzone-visualizer-color",
                    S_ShowSkullTileIcons
                );

                UI::SetNextItemWidth(220.0f);
                S_SkullTileIconScale = UI::SliderFloat(
                    "Tile icon scale##offzone-visualizer-color",
                    S_SkullTileIconScale,
                    0.05f,
                    1.0f
                );

                UI::SetNextItemWidth(220.0f);
                S_SkullTileIconAlpha = UI::SliderFloat(
                    "Tile icon alpha##offzone-visualizer-color",
                    S_SkullTileIconAlpha,
                    0.0f,
                    1.0f
                );

                RenderTileIconImagePickerUI();

                UI::TextDisabled("Anchors a plane-projected PNG at the center of each adaptive fill tile.");

                ClampWorldRenderingSettings();
                ClampColorSettings();
            }

            void RenderProximitySettingsUI() {
                UI::Text("Render Proximity Source");
                if (UI::BeginCombo("Render based on##offzone-visualizer-proximity", GetRenderProximityModeLabel(S_RenderProximityMode))) {
                    RenderProximityModeOption(PROXIMITY_MODE_CAMERA_ONLY);
                    RenderProximityModeOption(PROXIMITY_MODE_PLAYER_ONLY);
                    RenderProximityModeOption(PROXIMITY_MODE_CAMERA_AND_PLAYER);
                    UI::EndCombo();
                }

                S_RenderProximityMode = Math::Clamp(
                    S_RenderProximityMode,
                    PROXIMITY_MODE_CAMERA_ONLY,
                    PROXIMITY_MODE_CAMERA_AND_PLAYER
                );
            }

            void RenderLabelsSettingsUI() {
                UI::Text("Label Rendering");
                S_ShowLabels = UI::Checkbox("Show labels##offzone-visualizer-labels", S_ShowLabels);

                UI::Separator();
                UI::Text("Content");
                S_LabelShowIndex = UI::Checkbox("Show index##offzone-visualizer-labels", S_LabelShowIndex);
                S_LabelShowRawRange = UI::Checkbox("Show raw range##offzone-visualizer-labels", S_LabelShowRawRange);
                S_LabelShowWorldSize = UI::Checkbox("Show world size##offzone-visualizer-labels", S_LabelShowWorldSize);

                UI::Separator();
                UI::Text("Appearance");
                UI::SetNextItemWidth(220.0f);
                S_LabelFontSize = UI::InputFloat("Font size##offzone-visualizer-labels", S_LabelFontSize);

                UI::SetNextItemWidth(220.0f);
                S_LabelAlpha = UI::SliderFloat("Text alpha##offzone-visualizer-labels", S_LabelAlpha, 0.0f, 1.0f);

                UI::SetNextItemWidth(220.0f);
                S_LabelBackgroundAlpha = UI::SliderFloat(
                    "Background alpha##offzone-visualizer-labels",
                    S_LabelBackgroundAlpha,
                    0.0f,
                    1.0f
                );

                ClampLabelSettings();
            }
        }
    }
}
