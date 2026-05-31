namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            [Setting hidden name="Trigger: Show labels"]
            bool S_ShowLabels = true;

            [Setting hidden name="Trigger: Label show index"]
            bool S_LabelShowIndex = false;

            [Setting hidden name="Trigger: Label show raw range"]
            bool S_LabelShowRawRange = false;

            [Setting hidden name="Trigger: Label show world size"]
            bool S_LabelShowWorldSize = false;

            [Setting hidden name="Trigger: Label show island index"]
            bool S_LabelShowIslandIndex = false;

            [Setting hidden name="Trigger: Label show source prefix"]
            bool S_LabelShowSourcePrefix = false;

            [Setting hidden name="Trigger: Label use detected trigger name"]
            bool S_LabelUseDetectedTriggerName = true;

            [Setting hidden name="Trigger: Label show detected trigger name"]
            bool S_LabelShowDetectedTriggerName = false;

            [Setting hidden name="Trigger: Label font size" min=8 max=48]
            float S_LabelFontSize = 16.0f;

            [Setting hidden name="Trigger: Label alpha" min=0 max=1]
            float S_LabelAlpha = 0.95f;

            [Setting hidden name="Trigger: Label background alpha" min=0 max=1]
            float S_LabelBackgroundAlpha = 0.20f;
        }
    }
}
