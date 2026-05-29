namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            const int COLOR_MODE_STATIC = 0;
            const int COLOR_MODE_DISTANCE_FADE = 1;
            const int COLOR_MODE_LINE_SPLIT_DENSITY = 2;

            [Setting hidden name="Trigger: Color mode" min=0 max=2]
            int S_ColorMode = COLOR_MODE_STATIC;

            [Setting hidden name="Trigger: Base trigger color"]
            vec4 S_BaseTriggerColor = vec4(1.0f, 0.45f, 0.10f, 1.0f);

            [Setting hidden name="Trigger: Distance fade color"]
            vec4 S_DistanceFadeColor = vec4(1.0f, 0.90f, 0.20f, 1.0f);

            [Setting hidden name="Trigger: Dense line split color"]
            vec4 S_DenseLineSplitColor = vec4(0.10f, 0.85f, 1.0f, 1.0f);

            [Setting hidden name="Trigger: Outline alpha" min=0 max=1]
            float S_OutlineAlpha = 0.20f;

            [Setting hidden name="Trigger: Fill alpha" min=0 max=1]
            float S_FillAlpha = 0.03f;

            [Setting hidden name="Trigger: Outline width" min=0 max=16]
            float S_OutlineWidth = 2.0f;

            [Setting hidden name="Trigger: Random outline segment colors"]
            bool S_RandomOutlineSegmentColors = false;

            [Setting hidden name="Trigger: Random fill tile colors"]
            bool S_RandomFillTileColors = false;
        }
    }
}
