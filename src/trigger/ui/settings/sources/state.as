namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            const int SOURCE_SETTINGS_PLAYING = 0;
            const int SOURCE_SETTINGS_EDITOR = 1;
            const int SOURCE_SETTINGS_MEDIATRACKER = 2;
            const string DEFAULT_MEDIATRACKER_SUBTYPES_PLAYING = "camera|customcamera|playercamera|playercamerasubtypecamdefault|playercamerasubtypecam1|playercamerasubtypecam2|playercamerasubtypecam3|gps|reset|";
            const string DEFAULT_MEDIATRACKER_SUBTYPES_EDITOR = "camera|customcamera|orbitalcamera|pathcamera|playercamera|playercamerasubtypecamdefault|playercamerasubtypecam1|playercamerasubtypecam2|playercamerasubtypecam3|2dtriangles|3dtriangles|cartrails|dirtylens|fadingtransition|fog|image|shakecamfx|gps|reset|";
            const string DEFAULT_MEDIATRACKER_SUBTYPES_MEDIATRACKER = "camera|customcamera|orbitalcamera|pathcamera|playercamera|playercamerasubtypecamdefault|playercamerasubtypecam1|playercamerasubtypecam2|playercamerasubtypecam3|playercamerasubtypecamhelico|playercamerasubtypecamfree|playercamerasubtypecamspectator|2dtriangles|3dtriangles|cartrails|colorsfx|colorgrading|depthoffield|dirtylens|editingcut|fadingtransition|fog|ghost|gps|hdrbloom|image|inertialtrackingcamfx|manialinkui|manialinkurl|musicvolume|opponentvisibility|shakecamfx|stereo3d|soundfx|spectators|text|time|timespeed|tonemapping|vehiclelights|reset|mixed|unknown|";
            [Setting hidden name="Trigger: Merge adjacent trigger volumes"]
            bool S_MergeAdjacentTriggerVolumes = true;
            [Setting hidden name="Trigger: Show offzone source"]
            bool S_ShowOffzoneSource = true;
            [Setting hidden name="Trigger: Show offzone source editor"]
            bool S_ShowOffzoneSourceEditor = true;
            [Setting hidden name="Trigger: Show offzone source mediatracker"]
            bool S_ShowOffzoneSourceMediaTracker = true;
            [Setting hidden name="Trigger: Show MediaTracker source"]
            bool S_ShowMediaTrackerSource = true;
            [Setting hidden name="Trigger: Show MediaTracker source editor"]
            bool S_ShowMediaTrackerSourceEditor = true;
            [Setting hidden name="Trigger: Show MediaTracker source mediatracker"]
            bool S_ShowMediaTrackerSourceMediaTracker = true;
            [Setting hidden name="Trigger: MediaTracker enabled subtypes playing"]
            string S_MediaTrackerEnabledSubtypesPlaying = DEFAULT_MEDIATRACKER_SUBTYPES_PLAYING;
            [Setting hidden name="Trigger: MediaTracker enabled subtypes editor"]
            string S_MediaTrackerEnabledSubtypesEditor = DEFAULT_MEDIATRACKER_SUBTYPES_EDITOR;
            [Setting hidden name="Trigger: MediaTracker enabled subtypes mediatracker"]
            string S_MediaTrackerEnabledSubtypesMediaTracker = DEFAULT_MEDIATRACKER_SUBTYPES_MEDIATRACKER;

            int GetSourceSettingsContextForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                if (ctx is null) return SOURCE_SETTINGS_PLAYING;
                if (ctx.IsReplayEditor || ctx.IsEditorMediaTracker) return SOURCE_SETTINGS_MEDIATRACKER;
                if (ctx.IsEditorTestMode || ctx.IsPlayableMap) return SOURCE_SETTINGS_PLAYING;
                if (ctx.IsInEditor) return SOURCE_SETTINGS_EDITOR;
                return SOURCE_SETTINGS_PLAYING;
            }

            string GetSourceSettingsContextLabel(int context) {
                if (context == SOURCE_SETTINGS_EDITOR) return "Editor";
                if (context == SOURCE_SETTINGS_MEDIATRACKER) return "MediaTracker";
                return "Playing";
            }

            bool IsOffzoneSourceEnabledForContext(int context) {
                if (context == SOURCE_SETTINGS_EDITOR) return S_ShowOffzoneSourceEditor;
                if (context == SOURCE_SETTINGS_MEDIATRACKER) return S_ShowOffzoneSourceMediaTracker;
                return S_ShowOffzoneSource;
            }

            void SetOffzoneSourceEnabledForContext(int context, bool value) {
                if (context == SOURCE_SETTINGS_EDITOR) {
                    S_ShowOffzoneSourceEditor = value;
                    return;
                }
                if (context == SOURCE_SETTINGS_MEDIATRACKER) {
                    S_ShowOffzoneSourceMediaTracker = value;
                    return;
                }
                S_ShowOffzoneSource = value;
            }

            bool IsMediaTrackerSourceEnabledForContext(int context) {
                if (context == SOURCE_SETTINGS_EDITOR) return S_ShowMediaTrackerSourceEditor;
                if (context == SOURCE_SETTINGS_MEDIATRACKER) return S_ShowMediaTrackerSourceMediaTracker;
                return S_ShowMediaTrackerSource;
            }

            void SetMediaTrackerSourceEnabledForContext(int context, bool value) {
                if (context == SOURCE_SETTINGS_EDITOR) {
                    S_ShowMediaTrackerSourceEditor = value;
                    return;
                }
                if (context == SOURCE_SETTINGS_MEDIATRACKER) {
                    S_ShowMediaTrackerSourceMediaTracker = value;
                    return;
                }
                S_ShowMediaTrackerSource = value;
            }

            string GetMediaTrackerEnabledSubtypesForContext(int context) {
                if (context == SOURCE_SETTINGS_EDITOR) return S_MediaTrackerEnabledSubtypesEditor;
                if (context == SOURCE_SETTINGS_MEDIATRACKER) return S_MediaTrackerEnabledSubtypesMediaTracker;
                return S_MediaTrackerEnabledSubtypesPlaying;
            }

            void SetMediaTrackerEnabledSubtypesForContext(int context, const string &in value) {
                if (context == SOURCE_SETTINGS_EDITOR) {
                    S_MediaTrackerEnabledSubtypesEditor = value;
                    return;
                }
                if (context == SOURCE_SETTINGS_MEDIATRACKER) {
                    S_MediaTrackerEnabledSubtypesMediaTracker = value;
                    return;
                }
                S_MediaTrackerEnabledSubtypesPlaying = value;
            }

            string GetDefaultMediaTrackerEnabledSubtypesForContext(int context) {
                if (context == SOURCE_SETTINGS_EDITOR) return DEFAULT_MEDIATRACKER_SUBTYPES_EDITOR;
                if (context == SOURCE_SETTINGS_MEDIATRACKER) return DEFAULT_MEDIATRACKER_SUBTYPES_MEDIATRACKER;
                return DEFAULT_MEDIATRACKER_SUBTYPES_PLAYING;
            }

            string SetTargetListKeyEnabled(const string &in targetKeys, const string &in rawKey, bool enabled) {
                string key = TriggerVisualizer::Trigger::NormalizeTriggerTargetKey(rawKey);
                if (key.Length == 0) return targetKeys;
                if (enabled) return TriggerVisualizer::Trigger::AddTriggerTargetKey(targetKeys, key);

                string next = "";
                auto parts = targetKeys.Split("|");
                for (uint i = 0; i < parts.Length; i++) {
                    string part = TriggerVisualizer::Trigger::NormalizeTriggerTargetKey(parts[i]);
                    if (part.Length == 0 || part == key) continue;
                    next = TriggerVisualizer::Trigger::AddTriggerTargetKey(next, part);
                }
                return next;
            }

            bool IsMediaTrackerSubtypeEnabledForContext(int context, const string &in rawKey) {
                return TriggerVisualizer::Trigger::TriggerTargetListContains(
                    GetMediaTrackerEnabledSubtypesForContext(context),
                    rawKey
                );
            }

            void SetMediaTrackerSubtypeEnabledForContext(int context, const string &in rawKey, bool enabled) {
                string targetKeys = GetMediaTrackerEnabledSubtypesForContext(context);
                SetMediaTrackerEnabledSubtypesForContext(context, SetTargetListKeyEnabled(targetKeys, rawKey, enabled));
            }

            void FlipMediaTrackerSubtypeKeysForContext(int context, const array<string> &in keys) {
                string targetKeys = GetMediaTrackerEnabledSubtypesForContext(context);
                for (uint i = 0; i < keys.Length; i++) {
                    bool enabled = TriggerVisualizer::Trigger::TriggerTargetListContains(targetKeys, keys[i]);
                    targetKeys = SetTargetListKeyEnabled(targetKeys, keys[i], !enabled);
                }
                SetMediaTrackerEnabledSubtypesForContext(context, targetKeys);
            }

            void SetMediaTrackerSubtypeKeysForContext(int context, const array<string> &in keys, bool enabled) {
                string targetKeys = GetMediaTrackerEnabledSubtypesForContext(context);
                for (uint i = 0; i < keys.Length; i++) {
                    targetKeys = SetTargetListKeyEnabled(targetKeys, keys[i], enabled);
                }
                SetMediaTrackerEnabledSubtypesForContext(context, targetKeys);
            }

            void ResetSourceGroupingSettingsToDefaults() {
                S_MergeAdjacentTriggerVolumes = true;
            }

            void ResetSourceProfileSettingsToDefaults() {
                S_ShowOffzoneSource = true;
                S_ShowOffzoneSourceEditor = true;
                S_ShowOffzoneSourceMediaTracker = true;
                S_ShowMediaTrackerSource = true;
                S_ShowMediaTrackerSourceEditor = true;
                S_ShowMediaTrackerSourceMediaTracker = true;
                S_MediaTrackerEnabledSubtypesPlaying = DEFAULT_MEDIATRACKER_SUBTYPES_PLAYING;
                S_MediaTrackerEnabledSubtypesEditor = DEFAULT_MEDIATRACKER_SUBTYPES_EDITOR;
                S_MediaTrackerEnabledSubtypesMediaTracker = DEFAULT_MEDIATRACKER_SUBTYPES_MEDIATRACKER;
            }

            void ResetSourceSettingsToDefaults() {
                ResetSourceGroupingSettingsToDefaults();
                ResetSourceProfileSettingsToDefaults();
            }
        }
    }
}
