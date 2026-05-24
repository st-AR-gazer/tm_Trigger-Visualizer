namespace OffzoneVisualizer {
    namespace Offzone {
        namespace UI {
            [Setting hidden name="Offzone: Render world overlay"]
            bool S_RenderWorld = true;

            [Setting hidden name="Offzone: Show panel contents"]
            bool S_ShowPanel = true;

            [Setting hidden name="Offzone: Show labels"]
            bool S_ShowLabels = false;

            [Setting hidden name="Offzone: Show face fill"]
            bool S_ShowFill = false;

            [Setting hidden name="Offzone: Show outline"]
            bool S_ShowOutline = true;

            [Setting hidden name="Offzone: Render distance XZ" min=32 max=50000]
            float S_RenderDistanceXZ = 128.0f;

            [Setting hidden name="Offzone: Render distance Y" min=8 max=50000]
            float S_RenderDistanceY = 32.0f;

            [Setting hidden name="Offzone: Render fade band XZ" min=1 max=50000]
            float S_RenderFadeBandXZ = 32.0f;

            [Setting hidden name="Offzone: Render fade band Y" min=1 max=50000]
            float S_RenderFadeBandY = 8.0f;

            [Setting hidden name="Offzone: Outline alpha" min=0 max=1]
            float S_OutlineAlpha = 0.95f;

            [Setting hidden name="Offzone: Fill alpha" min=0 max=1]
            float S_FillAlpha = 0.18f;

            [Setting hidden name="Offzone: Adaptive line splitting"]
            bool S_AdaptiveLineSplitting = true;

            [Setting hidden name="Offzone: Line split target segment length" min=0.25 max=4]
            float S_LineSplitTargetSegmentLength = 4.0f;

            [Setting hidden name="Offzone: Line split start distance factor" min=0.01 max=4]
            float S_LineSplitStartDistanceFactor = 0.33f;

            [Setting hidden name="Offzone: Line split full distance factor" min=0.001 max=1]
            float S_LineSplitFullDistanceFactor = 0.05f;

            [Setting hidden name="Offzone: Line split min start distance" min=0 max=50000]
            float S_LineSplitMinStartDistance = 16.0f;

            [Setting hidden name="Offzone: Line split max start distance" min=0 max=50000]
            float S_LineSplitMaxStartDistance = 512.0f;

            [Setting hidden name="Offzone: Line split min full distance" min=0 max=50000]
            float S_LineSplitMinFullDistance = 2.0f;

            [Setting hidden name="Offzone: Line split max full distance" min=0 max=50000]
            float S_LineSplitMaxFullDistance = 96.0f;

            [Setting hidden name="Offzone: Line split max segments per edge" min=1 max=512]
            int S_LineSplitMaxSegmentsPerEdge = 512;

            const int COLOR_MODE_STATIC = 0;
            const int COLOR_MODE_DISTANCE_FADE = 1;
            const int COLOR_MODE_LINE_SPLIT_DENSITY = 2;

            [Setting hidden name="Offzone: Color mode" min=0 max=2]
            int S_ColorMode = COLOR_MODE_STATIC;

            [Setting hidden name="Offzone: Base offzone color"]
            vec4 S_BaseOffzoneColor = vec4(1.0f, 0.45f, 0.10f, 1.0f);

            [Setting hidden name="Offzone: Distance fade color"]
            vec4 S_DistanceFadeColor = vec4(1.0f, 0.90f, 0.20f, 1.0f);

            [Setting hidden name="Offzone: Dense line split color"]
            vec4 S_DenseLineSplitColor = vec4(0.10f, 0.85f, 1.0f, 1.0f);

            vec3 GetRenderDistanceWorld() {
                return vec3(S_RenderDistanceXZ, S_RenderDistanceY, S_RenderDistanceXZ);
            }

            vec3 GetRenderFadeBandWorld() {
                return vec3(S_RenderFadeBandXZ, S_RenderFadeBandY, S_RenderFadeBandXZ);
            }

            void ClampLineSplittingSettings() {
                S_LineSplitTargetSegmentLength = Math::Clamp(S_LineSplitTargetSegmentLength, 0.25f, 4.0f);
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
            }

            string GetColorModeLabel(int mode) {
                if (mode == COLOR_MODE_DISTANCE_FADE) return "Distance fade";
                if (mode == COLOR_MODE_LINE_SPLIT_DENSITY) return "Line split density";
                return "Static";
            }

            void RenderColorModeOption(int mode) {
                bool selected = S_ColorMode == mode;
                if (UI::Selectable(GetColorModeLabel(mode), selected)) {
                    S_ColorMode = mode;
                }
            }

            void RenderSettingsUI() {
                UI::Text("World Rendering");
                S_RenderWorld = UI::Checkbox("Enable world render##offzone-visualizer-settings", S_RenderWorld);
                S_ShowOutline = UI::Checkbox("Show outlines##offzone-visualizer-settings", S_ShowOutline);
                S_ShowFill = UI::Checkbox("Show face fill##offzone-visualizer-settings", S_ShowFill);
                S_ShowLabels = UI::Checkbox("Show labels##offzone-visualizer-settings", S_ShowLabels);

                UI::SetNextItemWidth(220.0f);
                S_RenderDistanceXZ = UI::InputFloat(
                    "Render distance X/Z##offzone-visualizer-settings",
                    S_RenderDistanceXZ
                );
                S_RenderDistanceXZ = Math::Clamp(S_RenderDistanceXZ, 32.0f, 50000.0f);

                UI::SetNextItemWidth(220.0f);
                S_RenderDistanceY = UI::InputFloat("Render distance Y##offzone-visualizer-settings", S_RenderDistanceY);
                S_RenderDistanceY = Math::Clamp(S_RenderDistanceY, 8.0f, 50000.0f);

                UI::SetNextItemWidth(220.0f);
                S_RenderFadeBandXZ = UI::InputFloat("Render fade X/Z##offzone-visualizer-settings", S_RenderFadeBandXZ);
                S_RenderFadeBandXZ = Math::Clamp(S_RenderFadeBandXZ, 1.0f, S_RenderDistanceXZ);

                UI::SetNextItemWidth(220.0f);
                S_RenderFadeBandY = UI::InputFloat("Render fade Y##offzone-visualizer-settings", S_RenderFadeBandY);
                S_RenderFadeBandY = Math::Clamp(S_RenderFadeBandY, 1.0f, S_RenderDistanceY);

                UI::SetNextItemWidth(220.0f);
                S_OutlineAlpha = UI::SliderFloat(
                    "Outline alpha##offzone-visualizer-settings",
                    S_OutlineAlpha,
                    0.0f,
                    1.0f
                );

                UI::SetNextItemWidth(220.0f);
                S_FillAlpha = UI::SliderFloat("Fill alpha##offzone-visualizer-settings", S_FillAlpha, 0.0f, 1.0f);

                UI::Separator();
                UI::Text("Panel");
                S_ShowPanel = UI::Checkbox("Show panel contents##offzone-visualizer-settings", S_ShowPanel);
                UI::TextDisabled("World rendering uses axis-aware distance culling with a soft fade band. Fill and labels come in later steps.");
            }

            void RenderLineSplittingSettingsUI() {
                UI::Text("Adaptive Line Splitting");
                S_AdaptiveLineSplitting = UI::Checkbox(
                    "Enable adaptive line splitting##offzone-visualizer-line-splitting",
                    S_AdaptiveLineSplitting
                );
                UI::TextDisabled("Fully split edges target 4m segments by default: one eighth of a 32m block.");
                UI::TextDisabled("Smaller target segments and higher segment caps cost more render work.");

                UI::Separator();
                UI::SetNextItemWidth(220.0f);
                S_LineSplitTargetSegmentLength = UI::InputFloat(
                    "Target segment length##offzone-visualizer-line-splitting",
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

            void RenderColorSettingsUI() {
                UI::Text("Offzone Color");
                if (UI::BeginCombo("Color mode##offzone-visualizer-color", GetColorModeLabel(S_ColorMode))) {
                    RenderColorModeOption(COLOR_MODE_STATIC);
                    RenderColorModeOption(COLOR_MODE_DISTANCE_FADE);
                    RenderColorModeOption(COLOR_MODE_LINE_SPLIT_DENSITY);
                    UI::EndCombo();
                }

                UI::TextDisabled("Distance fade blends by render fade. Line split density blends by the heaviest edge segment count.");

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
                UI::TextDisabled("Color alpha is multiplied by the outline alpha and distance fade.");

                ClampColorSettings();
            }
        }
    }
}
