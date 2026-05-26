namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            [Setting hidden name="Trigger: Render world overlay"]
            bool S_RenderWorld = true;

            [Setting hidden name="Trigger: Show labels"]
            bool S_ShowLabels = true;

            [Setting hidden name="Trigger: Label show index"]
            bool S_LabelShowIndex = true;

            [Setting hidden name="Trigger: Label show raw range"]
            bool S_LabelShowRawRange = false;

            [Setting hidden name="Trigger: Label show world size"]
            bool S_LabelShowWorldSize = false;

            [Setting hidden name="Trigger: Label show island index"]
            bool S_LabelShowIslandIndex = true;

            [Setting hidden name="Trigger: Label show source prefix"]
            bool S_LabelShowSourcePrefix = true;

            [Setting hidden name="Trigger: Label use detected trigger name"]
            bool S_LabelUseDetectedTriggerName = false;

            [Setting hidden name="Trigger: Label show detected trigger name"]
            bool S_LabelShowDetectedTriggerName = false;

            [Setting hidden name="Trigger: Label font size" min=8 max=48]
            float S_LabelFontSize = 16.0f;

            [Setting hidden name="Trigger: Label alpha" min=0 max=1]
            float S_LabelAlpha = 0.95f;

            [Setting hidden name="Trigger: Label background alpha" min=0 max=1]
            float S_LabelBackgroundAlpha = 0.20f;

            [Setting hidden name="Trigger: Show face fill"]
            bool S_ShowFill = true;

            [Setting hidden name="Trigger: Show outline"]
            bool S_ShowOutline = true;

            [Setting hidden name="Trigger: Render distance XZ" min=0 max=50000]
            float S_RenderDistanceXZ = 224.0f;

            [Setting hidden name="Trigger: Render distance Y" min=0 max=50000]
            float S_RenderDistanceY = 56.0f;

            [Setting hidden name="Trigger: Render fade band XZ" min=0 max=50000]
            float S_RenderFadeBandXZ = 32.0f;

            [Setting hidden name="Trigger: Render fade band Y" min=0 max=50000]
            float S_RenderFadeBandY = 8.0f;

            [Setting hidden name="Trigger: Unlimited render distance"]
            bool S_UnlimitedRenderDistance = false;

            [Setting hidden name="Trigger: Use map suggested draw distance"]
            bool S_UseMapSuggestedDrawDistance = true;

            [Setting hidden name="Trigger: Respect map suggest-off"]
            bool S_RespectMapSuggestOff = true;

            [Setting hidden name="Trigger: Outline alpha" min=0 max=1]
            float S_OutlineAlpha = 0.20f;

            [Setting hidden name="Trigger: Fill alpha" min=0 max=1]
            float S_FillAlpha = 0.03f;

            [Setting hidden name="Trigger: Outline width" min=0 max=16]
            float S_OutlineWidth = 2.0f;

            [Setting hidden name="Trigger: Adaptive line splitting"]
            bool S_AdaptiveLineSplitting = true;

            [Setting hidden name="Trigger: Line split minimum segment length"]
            float S_LineSplitTargetSegmentLength = 4.0f;

            [Setting hidden name="Trigger: Line split start distance factor"]
            float S_LineSplitStartDistanceFactor = 0.33f;

            [Setting hidden name="Trigger: Line split full distance factor"]
            float S_LineSplitFullDistanceFactor = 0.05f;

            [Setting hidden name="Trigger: Line split min start distance"]
            float S_LineSplitMinStartDistance = 16.0f;

            [Setting hidden name="Trigger: Line split max start distance"]
            float S_LineSplitMaxStartDistance = 50000.0f;

            [Setting hidden name="Trigger: Line split min full distance"]
            float S_LineSplitMinFullDistance = 2.0f;

            [Setting hidden name="Trigger: Line split max full distance"]
            float S_LineSplitMaxFullDistance = 96.0f;

            [Setting hidden name="Trigger: Line split max segments per edge"]
            int S_LineSplitMaxSegmentsPerEdge = 512;

            [Setting hidden name="Trigger: Cull offscreen world tiles"]
            bool S_CullOffscreenWorldTiles = true;

            [Setting hidden name="Trigger: Experimental screen-occluded world tile culling"]
            bool S_CullScreenOccludedWorldTiles = false;

            [Setting hidden name="Trigger: Screen occlusion cell size" min=8 max=256]
            int S_ScreenOcclusionCellSize = 32;

            [Setting hidden name="Trigger: Fill tile minimum size" min=2 max=64]
            float S_FillTileMinSize = 4.0f;

            [Setting hidden name="Trigger: Max fill tiles per frame" min=128 max=65536]
            int S_MaxFillTilesPerFrame = 4096;

            [Setting hidden name="Trigger: Max tile icon patches per frame" min=0 max=65536]
            int S_MaxTileIconPatchesPerFrame = 1600;

            [Setting hidden name="Trigger: Tile icon max subdivisions" min=1 max=12]
            int S_TileIconMaxSubdivisions = 6;

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
            const float LINE_SPLIT_MINIMUM_SAFE_LENGTH = 0.001f;
            const float LINE_SPLIT_TARGET_LENGTH_SLIDER_MAX = 64.0f;
            const float LINE_SPLIT_START_DISTANCE_SLIDER_MAX = 2048.0f;
            const float LINE_SPLIT_FULL_DISTANCE_SLIDER_MAX = 512.0f;
            const int LINE_SPLIT_SEGMENTS_SLIDER_MAX = 512;

            [Setting hidden name="Trigger: Color mode" min=0 max=2]
            int S_ColorMode = COLOR_MODE_STATIC;

            [Setting hidden name="Trigger: Render proximity mode" min=0 max=2]
            int S_RenderProximityMode = PROXIMITY_MODE_CAMERA_AND_PLAYER;

            [Setting hidden name="Trigger: Base trigger color"]
            vec4 S_BaseTriggerColor = vec4(1.0f, 0.45f, 0.10f, 1.0f);

            [Setting hidden name="Trigger: Distance fade color"]
            vec4 S_DistanceFadeColor = vec4(1.0f, 0.90f, 0.20f, 1.0f);

            [Setting hidden name="Trigger: Dense line split color"]
            vec4 S_DenseLineSplitColor = vec4(0.10f, 0.85f, 1.0f, 1.0f);

            [Setting hidden name="Trigger: Random outline segment colors"]
            bool S_RandomOutlineSegmentColors = false;

            [Setting hidden name="Trigger: Random fill tile colors"]
            bool S_RandomFillTileColors = false;

            [Setting hidden name="Trigger: Show skull tile icons"]
            bool S_ShowSkullTileIcons = false;

            [Setting hidden name="Trigger: Skull tile icon scale" min=0.05 max=1]
            float S_SkullTileIconScale = 0.45f;

            [Setting hidden name="Trigger: Skull tile icon alpha" min=0 max=1]
            float S_SkullTileIconAlpha = 0.85f;

            [Setting hidden name="Trigger: Custom tile icon storage path"]
            string S_CustomTileIconStoragePath = "";

            [Setting hidden name="Trigger: Show offzone source"]
            bool S_ShowOffzoneSource = true;

            [Setting hidden name="Trigger: Show offzone in playable map"]
            bool S_ShowOffzoneInPlayableMap = true;

            [Setting hidden name="Trigger: Show offzone in editor"]
            bool S_ShowOffzoneInEditor = true;

            [Setting hidden name="Trigger: Show offzone in editor test mode"]
            bool S_ShowOffzoneInEditorTestMode = true;

            [Setting hidden name="Trigger: Show offzone in editor mediatracker"]
            bool S_ShowOffzoneInEditorMediaTracker = true;

            [Setting hidden name="Trigger: Show offzone in replay editor"]
            bool S_ShowOffzoneInReplayEditor = true;

            [Setting hidden name="Trigger: Show MediaTracker source"]
            bool S_ShowMediaTrackerSource = false;

            [Setting hidden name="Trigger: Show MediaTracker in playable map"]
            bool S_ShowMediaTrackerInPlayableMap = true;

            [Setting hidden name="Trigger: Show MediaTracker in editor"]
            bool S_ShowMediaTrackerInEditor = true;

            [Setting hidden name="Trigger: Show MediaTracker in editor test mode"]
            bool S_ShowMediaTrackerInEditorTestMode = true;

            [Setting hidden name="Trigger: Show MediaTracker in editor mediatracker"]
            bool S_ShowMediaTrackerInEditorMediaTracker = true;

            [Setting hidden name="Trigger: Show MediaTracker in replay editor"]
            bool S_ShowMediaTrackerInReplayEditor = true;

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
                S_LineSplitTargetSegmentLength = Math::Max(
                    S_LineSplitTargetSegmentLength,
                    LINE_SPLIT_MINIMUM_SAFE_LENGTH
                );
                S_LineSplitStartDistanceFactor = Math::Max(S_LineSplitStartDistanceFactor, 0.0f);
                S_LineSplitFullDistanceFactor = Math::Max(S_LineSplitFullDistanceFactor, 0.0f);
                S_LineSplitMinStartDistance = Math::Max(S_LineSplitMinStartDistance, 0.0f);
                S_LineSplitMaxStartDistance = Math::Max(S_LineSplitMaxStartDistance, 0.0f);
                S_LineSplitMinFullDistance = Math::Max(S_LineSplitMinFullDistance, 0.0f);
                S_LineSplitMaxFullDistance = Math::Max(S_LineSplitMaxFullDistance, 0.0f);
                S_LineSplitMaxSegmentsPerEdge = Math::Max(S_LineSplitMaxSegmentsPerEdge, 1);
            }

            void ClampPerformanceSettings() {
                S_ScreenOcclusionCellSize = Math::Clamp(S_ScreenOcclusionCellSize, 8, 256);
                S_FillTileMinSize = Math::Clamp(S_FillTileMinSize, 2.0f, 64.0f);
                S_MaxFillTilesPerFrame = Math::Clamp(S_MaxFillTilesPerFrame, 128, 65536);
                S_MaxTileIconPatchesPerFrame = Math::Clamp(S_MaxTileIconPatchesPerFrame, 0, 65536);
                S_TileIconMaxSubdivisions = Math::Clamp(S_TileIconMaxSubdivisions, 1, 12);
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
                S_BaseTriggerColor = ClampColor(S_BaseTriggerColor);
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
                S_LabelShowIslandIndex = true;
                S_LabelShowSourcePrefix = true;
                S_LabelUseDetectedTriggerName = false;
                S_LabelShowDetectedTriggerName = false;
                S_LabelFontSize = 16.0f;
                S_LabelAlpha = 0.95f;
                S_LabelBackgroundAlpha = 0.20f;
                S_ShowFill = true;
                S_ShowOutline = true;
                S_RenderDistanceXZ = 224.0f;
                S_RenderDistanceY = 56.0f;
                S_RenderFadeBandXZ = 32.0f;
                S_RenderFadeBandY = 8.0f;
                S_UnlimitedRenderDistance = false;
                S_UseMapSuggestedDrawDistance = true;
                S_RespectMapSuggestOff = true;
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
                S_CullOffscreenWorldTiles = true;
                S_CullScreenOccludedWorldTiles = false;
                S_ScreenOcclusionCellSize = 32;
                S_FillTileMinSize = 4.0f;
                S_MaxFillTilesPerFrame = 4096;
                S_MaxTileIconPatchesPerFrame = 1600;
                S_TileIconMaxSubdivisions = 6;
                S_ColorMode = COLOR_MODE_STATIC;
                S_RenderProximityMode = PROXIMITY_MODE_CAMERA_AND_PLAYER;
                S_BaseTriggerColor = vec4(1.0f, 0.45f, 0.10f, 1.0f);
                S_DistanceFadeColor = vec4(1.0f, 0.90f, 0.20f, 1.0f);
                S_DenseLineSplitColor = vec4(0.10f, 0.85f, 1.0f, 1.0f);
                S_RandomOutlineSegmentColors = false;
                S_RandomFillTileColors = false;
                S_ShowSkullTileIcons = false;
                S_SkullTileIconScale = 0.45f;
                S_SkullTileIconAlpha = 0.85f;
                S_CustomTileIconStoragePath = "";
                S_ShowOffzoneSource = true;
                S_ShowOffzoneInPlayableMap = true;
                S_ShowOffzoneInEditor = true;
                S_ShowOffzoneInEditorTestMode = true;
                S_ShowOffzoneInEditorMediaTracker = true;
                S_ShowOffzoneInReplayEditor = true;
                S_ShowMediaTrackerSource = false;
                S_ShowMediaTrackerInPlayableMap = true;
                S_ShowMediaTrackerInEditor = true;
                S_ShowMediaTrackerInEditorTestMode = true;
                S_ShowMediaTrackerInEditorMediaTracker = true;
                S_ShowMediaTrackerInReplayEditor = true;
                G_PendingTileIconSourcePath = "";
                G_TileIconImportStatus = "";
                TriggerVisualizer::Trigger::Render::Assets::InvalidateSkullTileIconTexture();

                ClampWorldRenderingSettings();
                ClampLineSplittingSettings();
                ClampPerformanceSettings();
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

            void RenderWorldDistanceSettingsUI() {
                RenderProximitySettingsUI();

                UI::Separator();
                UI::Text("Distance");
                S_UnlimitedRenderDistance = UI::Checkbox(
                    "Unlimited distance##trigger-visualizer-settings-unlimited-distance",
                    S_UnlimitedRenderDistance
                );
                UI::TextDisabled("Ignores render distance and map-suggested distance when enabled.");

                S_RenderDistanceXZ = RenderWorldDistanceSlider(
                    "Render distance X/Z",
                    "trigger-visualizer-settings-render-distance-xz",
                    S_RenderDistanceXZ,
                    0.0f,
                    WORLD_RENDER_SLIDER_MAX_XZ,
                    WORLD_BLOCK_SIZE_XZ
                );
                S_RenderDistanceY = RenderWorldDistanceSlider(
                    "Render distance Y",
                    "trigger-visualizer-settings-render-distance-y",
                    S_RenderDistanceY,
                    0.0f,
                    WORLD_RENDER_SLIDER_MAX_Y,
                    WORLD_BLOCK_SIZE_Y
                );
                S_RenderFadeBandXZ = RenderWorldDistanceSlider(
                    "Render fade X/Z",
                    "trigger-visualizer-settings-render-fade-xz",
                    S_RenderFadeBandXZ,
                    0.0f,
                    WORLD_FADE_SLIDER_MAX_XZ,
                    WORLD_BLOCK_SIZE_XZ
                );
                S_RenderFadeBandY = RenderWorldDistanceSlider(
                    "Render fade Y",
                    "trigger-visualizer-settings-render-fade-y",
                    S_RenderFadeBandY,
                    0.0f,
                    WORLD_FADE_SLIDER_MAX_Y,
                    WORLD_BLOCK_SIZE_Y
                );
                ClampWorldRenderingSettings();
            }

            void RenderMapHintsSettingsUI() {
                UI::Text("Map Authored Hints");
                S_UseMapSuggestedDrawDistance = UI::Checkbox(
                    "Use map-suggested draw distance##trigger-visualizer-settings",
                    S_UseMapSuggestedDrawDistance
                );
                S_RespectMapSuggestOff = UI::Checkbox(
                    "Respect map suggest-off##trigger-visualizer-settings",
                    S_RespectMapSuggestOff
                );

                ClampWorldRenderingSettings();
            }

            void RenderWorldRenderingSettingsUI() {
                UI::Text("World Rendering");
                S_RenderWorld = UI::Checkbox("Enable world render##trigger-visualizer-settings", S_RenderWorld);
                S_ShowOutline = UI::Checkbox("Show outlines##trigger-visualizer-settings", S_ShowOutline);
                S_ShowFill = UI::Checkbox("Show face fill##trigger-visualizer-settings", S_ShowFill);
                S_ShowLabels = UI::Checkbox("Show labels##trigger-visualizer-settings", S_ShowLabels);

                UI::Separator();
                UI::BeginTabBar("trigger-visualizer-world-rendering-tabs");

                if (UI::BeginTabItem("Distance")) {
                    RenderWorldDistanceSettingsUI();
                    UI::EndTabItem();
                }

                if (UI::BeginTabItem("LineSplitting")) {
                    RenderLineSplittingSettingsUI();
                    UI::EndTabItem();
                }

                if (UI::BeginTabItem("Color")) {
                    RenderColorSettingsUI();
                    UI::EndTabItem();
                }

                if (UI::BeginTabItem("Image/Tiles")) {
                    RenderImageTilesSettingsUI();
                    UI::EndTabItem();
                }

                if (UI::BeginTabItem("Map Hints")) {
                    RenderMapHintsSettingsUI();
                    UI::EndTabItem();
                }

                UI::EndTabBar();
            }

            void RenderLineSplittingSettingsUI() {
                UI::Text("Adaptive Line Splitting");
                S_AdaptiveLineSplitting = UI::Checkbox(
                    "Enable adaptive line splitting##trigger-visualizer-line-splitting",
                    S_AdaptiveLineSplitting
                );

                UI::Separator();
                UI::SetNextItemWidth(220.0f);
                S_LineSplitTargetSegmentLength = UI::SliderFloat(
                    "Minimum segment length##trigger-visualizer-line-splitting",
                    S_LineSplitTargetSegmentLength,
                    LINE_SPLIT_MINIMUM_SAFE_LENGTH,
                    LINE_SPLIT_TARGET_LENGTH_SLIDER_MAX,
                    "%.3f m"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitStartDistanceFactor = UI::SliderFloat(
                    "Start distance factor##trigger-visualizer-line-splitting",
                    S_LineSplitStartDistanceFactor,
                    0.01f,
                    4.0f,
                    "%.3f"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitFullDistanceFactor = UI::SliderFloat(
                    "Full distance factor##trigger-visualizer-line-splitting",
                    S_LineSplitFullDistanceFactor,
                    0.001f,
                    1.0f,
                    "%.4f"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMinStartDistance = UI::SliderFloat(
                    "Min start distance##trigger-visualizer-line-splitting",
                    S_LineSplitMinStartDistance,
                    0.0f,
                    LINE_SPLIT_START_DISTANCE_SLIDER_MAX,
                    "%.1f m"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMaxStartDistance = UI::SliderFloat(
                    "Max start distance##trigger-visualizer-line-splitting",
                    S_LineSplitMaxStartDistance,
                    0.0f,
                    LINE_SPLIT_START_DISTANCE_SLIDER_MAX,
                    "%.1f m"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMinFullDistance = UI::SliderFloat(
                    "Min full distance##trigger-visualizer-line-splitting",
                    S_LineSplitMinFullDistance,
                    0.0f,
                    LINE_SPLIT_FULL_DISTANCE_SLIDER_MAX,
                    "%.1f m"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMaxFullDistance = UI::SliderFloat(
                    "Max full distance##trigger-visualizer-line-splitting",
                    S_LineSplitMaxFullDistance,
                    0.0f,
                    LINE_SPLIT_FULL_DISTANCE_SLIDER_MAX,
                    "%.1f m"
                );

                UI::SetNextItemWidth(220.0f);
                S_LineSplitMaxSegmentsPerEdge = UI::SliderInt(
                    "Max segments per edge##trigger-visualizer-line-splitting",
                    S_LineSplitMaxSegmentsPerEdge,
                    1,
                    LINE_SPLIT_SEGMENTS_SLIDER_MAX
                );

                ClampLineSplittingSettings();
            }

            void RenderPerformanceSettingsUI() {
                UI::Text("Performance Guardrails");

                S_CullOffscreenWorldTiles = UI::Checkbox(
                    "Cull off-screen fill/icon tiles##trigger-visualizer-performance",
                    S_CullOffscreenWorldTiles
                );

                S_CullScreenOccludedWorldTiles = UI::Checkbox(
                    "Experimental screen-covered tile culling##trigger-visualizer-performance",
                    S_CullScreenOccludedWorldTiles
                );

                UI::SetNextItemWidth(220.0f);
                S_ScreenOcclusionCellSize = UI::InputInt(
                    "Occlusion cell size##trigger-visualizer-performance",
                    S_ScreenOcclusionCellSize
                );

                UI::Separator();
                UI::SetNextItemWidth(220.0f);
                S_FillTileMinSize = UI::InputFloat(
                    "Fill tile minimum size##trigger-visualizer-performance",
                    S_FillTileMinSize
                );

                UI::SetNextItemWidth(220.0f);
                S_MaxFillTilesPerFrame = UI::InputInt(
                    "Max fill tiles per frame##trigger-visualizer-performance",
                    S_MaxFillTilesPerFrame
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

                ClampPerformanceSettings();
            }

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

                UI::Separator();
                RenderPerformanceSettingsUI();
            }

            void RenderColorSettingsUI() {
                UI::Text("Trigger Volume Color");
                if (UI::BeginCombo("Color mode##trigger-visualizer-color", GetColorModeLabel(S_ColorMode))) {
                    RenderColorModeOption(COLOR_MODE_STATIC);
                    RenderColorModeOption(COLOR_MODE_DISTANCE_FADE);
                    RenderColorModeOption(COLOR_MODE_LINE_SPLIT_DENSITY);
                    UI::EndCombo();
                }

                UI::Separator();
                S_BaseTriggerColor = UI::InputColor4("Base color##trigger-visualizer-color", S_BaseTriggerColor);
                S_DistanceFadeColor = UI::InputColor4(
                    "Distance fade color##trigger-visualizer-color",
                    S_DistanceFadeColor
                );
                S_DenseLineSplitColor = UI::InputColor4(
                    "Dense line split color##trigger-visualizer-color",
                    S_DenseLineSplitColor
                );

                UI::Separator();
                UI::Text("Appearance");
                UI::SetNextItemWidth(220.0f);
                S_OutlineAlpha = UI::SliderFloat("Outline alpha##trigger-visualizer-color", S_OutlineAlpha, 0.0f, 1.0f);

                UI::SetNextItemWidth(220.0f);
                S_FillAlpha = UI::SliderFloat("Fill alpha##trigger-visualizer-color", S_FillAlpha, 0.0f, 1.0f);

                UI::SetNextItemWidth(220.0f);
                S_OutlineWidth = UI::SliderFloat(
                    "Outline width##trigger-visualizer-color",
                    S_OutlineWidth,
                    0.5f,
                    16.0f,
                    "%.1f px"
                );

                UI::Separator();
                UI::Text("Stable Random Colors");
                S_RandomOutlineSegmentColors = UI::Checkbox(
                    "Random color per outline segment##trigger-visualizer-color",
                    S_RandomOutlineSegmentColors
                );
                S_RandomFillTileColors = UI::Checkbox(
                    "Random color per fill section/tile##trigger-visualizer-color",
                    S_RandomFillTileColors
                );

                ClampWorldRenderingSettings();
                ClampColorSettings();
            }

            void RenderProximitySettingsUI() {
                UI::Text("Render Proximity Source");
                if (UI::BeginCombo("Render based on##trigger-visualizer-proximity", GetRenderProximityModeLabel(S_RenderProximityMode))) {
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

            bool RenderSourceContextToggleUI(const string &in label, const string &in id, bool value) {
                return UI::Checkbox(label + "##" + id, value);
            }

            void RenderSourcesSettingsUI() {
                UI::Text("Trigger Sources");
                auto ctx = TriggerVisualizer::Trigger::GetCurrentRuntimeContext();
                UI::TextDisabled("Current context: " + GetRuntimeSourceContextLabel(ctx));

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
                    UI::EndTabItem();
                }

                UI::EndTabBar();
            }

            void RenderLabelsSettingsUI() {
                UI::Text("Label Rendering");
                S_ShowLabels = UI::Checkbox("Show labels##trigger-visualizer-labels", S_ShowLabels);

                UI::Separator();
                UI::Text("Content");
                S_LabelShowIndex = UI::Checkbox("Show index##trigger-visualizer-labels", S_LabelShowIndex);
                S_LabelShowRawRange = UI::Checkbox("Show raw range##trigger-visualizer-labels", S_LabelShowRawRange);
                S_LabelShowWorldSize = UI::Checkbox("Show world size##trigger-visualizer-labels", S_LabelShowWorldSize);
                S_LabelShowIslandIndex = UI::Checkbox("Show island x/n##trigger-visualizer-labels", S_LabelShowIslandIndex);
                S_LabelShowSourcePrefix = UI::Checkbox(
                    "Show source/type prefix##trigger-visualizer-labels",
                    S_LabelShowSourcePrefix
                );
                S_LabelUseDetectedTriggerName = UI::Checkbox(
                    "Overwrite name with detected trigger type##trigger-visualizer-labels",
                    S_LabelUseDetectedTriggerName
                );
                if (S_LabelUseDetectedTriggerName) {
                    S_LabelShowDetectedTriggerName = false;
                }

                UI::BeginDisabled(S_LabelUseDetectedTriggerName);
                S_LabelShowDetectedTriggerName = UI::Checkbox(
                    "Show detected trigger type with name##trigger-visualizer-labels",
                    S_LabelShowDetectedTriggerName
                );
                UI::EndDisabled();

                UI::Separator();
                UI::Text("Appearance");
                UI::SetNextItemWidth(220.0f);
                S_LabelFontSize = UI::InputFloat("Font size##trigger-visualizer-labels", S_LabelFontSize);

                UI::SetNextItemWidth(220.0f);
                S_LabelAlpha = UI::SliderFloat("Text alpha##trigger-visualizer-labels", S_LabelAlpha, 0.0f, 1.0f);

                UI::SetNextItemWidth(220.0f);
                S_LabelBackgroundAlpha = UI::SliderFloat(
                    "Background alpha##trigger-visualizer-labels",
                    S_LabelBackgroundAlpha,
                    0.0f,
                    1.0f
                );

                ClampLabelSettings();
            }
        }
    }
}
