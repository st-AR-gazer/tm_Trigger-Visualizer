namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            const int COLOR_MODE_STATIC = 0;
            const int COLOR_MODE_DISTANCE_FADE = 1;
            const int COLOR_MODE_LINE_SPLIT_DENSITY = 2;
            const int COLOR_MODE_MEDIATRACKER_TRACK_COLORS = 3;
            const int COLOR_SOURCE_UNIFORM = 0;
            const int COLOR_SOURCE_MEDIATRACKER_TRACK_COLORS = 1;

            [Setting hidden name="Trigger: Color mode" min=0 max=3]
            int S_ColorMode = COLOR_MODE_MEDIATRACKER_TRACK_COLORS;
            [Setting hidden name="Trigger: Color mode migrated"]
            bool S_ColorModeMigrated = false;
            [Setting hidden name="Trigger: Color source" min=0 max=1]
            int S_ColorSource = COLOR_SOURCE_MEDIATRACKER_TRACK_COLORS;
            [Setting hidden name="Trigger: Enable distance fade color"]
            bool S_EnableDistanceFadeColor = false;
            [Setting hidden name="Trigger: Enable line split density color"]
            bool S_EnableLineSplitDensityColor = false;
            [Setting hidden name="Trigger: Base trigger color"]
            vec4 S_BaseTriggerColor = vec4(0.85f, 0.71f, 1.0f, 1.0f);
            [Setting hidden name="Trigger: Distance fade color"]
            vec4 S_DistanceFadeColor = vec4(1.0f, 0.90f, 0.20f, 1.0f);
            [Setting hidden name="Trigger: Dense line split color"]
            vec4 S_DenseLineSplitColor = vec4(0.10f, 0.85f, 1.0f, 1.0f);
            [Setting hidden name="Trigger: MediaTracker track outline hue shift" min=-1 max=1]
            float S_MediaTrackerTrackOutlineHueShift = 0.06f;
            [Setting hidden name="Trigger: Animate turbo roulette color"]
            bool S_AnimateTurboRouletteColor = true;
            [Setting hidden name="Trigger: Turbo roulette yellow duration ms" min=50 max=5000]
            int S_TurboRouletteYellowDurationMs = 800;
            [Setting hidden name="Trigger: Turbo roulette cyan duration ms" min=50 max=5000]
            int S_TurboRouletteCyanDurationMs = 350;
            [Setting hidden name="Trigger: Turbo roulette purple duration ms" min=50 max=5000]
            int S_TurboRoulettePurpleDurationMs = 350;
            [Setting hidden name="Trigger: Turbo roulette phase offset ms" min=-10000 max=10000]
            int S_TurboRoulettePhaseOffsetMs = 0;
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
