namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            const float LINE_SPLIT_MINIMUM_SAFE_LENGTH = 0.001f;
            const float LINE_SPLIT_TARGET_LENGTH_SLIDER_MAX = 64.0f;
            const float LINE_SPLIT_START_DISTANCE_SLIDER_MAX = 2048.0f;
            const float LINE_SPLIT_FULL_DISTANCE_SLIDER_MAX = 512.0f;
            const int LINE_SPLIT_SEGMENTS_SLIDER_MAX = 512;

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
        }
    }
}
