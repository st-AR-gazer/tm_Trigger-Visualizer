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
            [Setting hidden name="Trigger: Label show joined count"]
            bool S_LabelShowJoinedCount = false;
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
            const string DEFAULT_LABEL_TARGET_KEYS = "offzone|mediatracker|crystal|checkpoint|finish|startfinish|turbo|turbo2|turboroulette|boost|boost2|cruise|nobrakes|noengine|nosteering|slowmo|fragile|reset|forceacceleration|nogrip|vehicletransformreset|vehicletransformcarsnow|vehicletransformcarrally|vehicletransformcardesert|camera|customcamera|orbitalcamera|pathcamera|playercamera|playercamerasubtypecamdefault|playercamerasubtypecam1|playercamerasubtypecam2|playercamerasubtypecam3|playercamerasubtypecamhelico|playercamerasubtypecamfree|playercamerasubtypecamspectator|2dtriangles|3dtriangles|colorsfx|colorgrading|depthoffield|dirtylens|fadingtransition|fog|hdrbloom|image|inertialtrackingcamfx|shakecamfx|stereo3d|tonemapping|vehiclelights|cartrails|ghost|manialinkui|manialinkurl|musicvolume|opponentvisibility|soundfx|spectators|text|time|timespeed|gps|editingcut|mediatrackerreset|mixed|unknown|crystalblock|crystalblockwaypoint|crystalscreeninteraction|crystalgate|crystalteleporter|crystalitem|crystalblockitem|";
            const string DEFAULT_LABEL_TARGET_OVERRIDE_TEXTS = "checkpoint=Checkpoint|finish=Finish|startfinish=Multilap|turbo=Turbo|turbo2=Turbo2|turboroulette=TurboR|boost=Boost|boost2=Boost2|cruise=Cruise|nobrakes=No%20Brakes|noengine=No%20Engine|nosteering=No%20Steering|slowmo=Slowmo|fragile=Fragile|reset=Reset|forceacceleration=Forced%20Acceleration|nogrip=No%20Grip|vehicletransformreset=Stadium%20Car|vehicletransformcarsnow=Snow%20Car|vehicletransformcarrally=Rally%20Car|vehicletransformcardesert=Desert%20Car|";

            [Setting hidden name="Trigger: Label target keys"]
            string S_LabelTargetKeys = DEFAULT_LABEL_TARGET_KEYS;
            [Setting hidden name="Trigger: Label target override texts"]
            string S_LabelTargetOverrideTexts = DEFAULT_LABEL_TARGET_OVERRIDE_TEXTS;
            dictionary G_LabelTargetOverrideInputs;
            string G_LabelTargetKeyCacheSource;
            array<string> G_LabelTargetKeyCache;

            string EncodeLabelTargetOverrideText(const string &in value) {
                return Net::UrlEncode(value);
            }

            string DecodeLabelTargetOverrideText(const string &in value) {
                return Net::UrlDecode(value);
            }

            string GetLabelTargetOverrideText(const string &in rawKey) {
                string key = TriggerVisualizer::Trigger::NormalizeTriggerTargetKey(rawKey);
                if (key.Length == 0 || S_LabelTargetOverrideTexts.Length == 0) return "";

                auto entries = S_LabelTargetOverrideTexts.Split("|");
                for (uint i = 0; i < entries.Length; i++) {
                    string entry = entries[i];
                    int separator = entry.IndexOf("=");
                    if (separator <= 0) continue;
                    string entryKey = TriggerVisualizer::Trigger::NormalizeTriggerTargetKey(entry.SubStr(0, separator));
                    if (entryKey != key) continue;
                    return DecodeLabelTargetOverrideText(entry.SubStr(separator + 1));
                }
                return "";
            }

            void SetLabelTargetOverrideText(const string &in rawKey, const string &in value) {
                string key = TriggerVisualizer::Trigger::NormalizeTriggerTargetKey(rawKey);
                if (key.Length == 0) return;

                string next;
                auto entries = S_LabelTargetOverrideTexts.Split("|");
                for (uint i = 0; i < entries.Length; i++) {
                    string entry = entries[i];
                    int separator = entry.IndexOf("=");
                    if (separator <= 0) continue;
                    string entryKey = TriggerVisualizer::Trigger::NormalizeTriggerTargetKey(entry.SubStr(0, separator));
                    if (entryKey.Length == 0 || entryKey == key) continue;
                    next += entryKey + "=" + entry.SubStr(separator + 1) + "|";
                }

                string trimmedValue = value.Trim();
                if (trimmedValue.Length > 0) {
                    next += key + "=" + EncodeLabelTargetOverrideText(trimmedValue) + "|";
                }
                S_LabelTargetOverrideTexts = next;
            }

            string GetLabelTargetOverrideInputValue(const string &in rawKey) {
                string key = TriggerVisualizer::Trigger::NormalizeTriggerTargetKey(rawKey);
                if (key.Length == 0) return "";

                string value;
                if (!G_LabelTargetOverrideInputs.Get(key, value)) {
                    value = GetLabelTargetOverrideText(key);
                    G_LabelTargetOverrideInputs.Set(key, value);
                }
                return value;
            }

            void SetLabelTargetOverrideInputValue(const string &in rawKey, const string &in value) {
                string key = TriggerVisualizer::Trigger::NormalizeTriggerTargetKey(rawKey);
                if (key.Length == 0) return;
                G_LabelTargetOverrideInputs.Set(key, value);
                SetLabelTargetOverrideText(key, value);
            }

            void RebuildLabelTargetKeyCacheIfNeeded() {
                if (G_LabelTargetKeyCacheSource == S_LabelTargetKeys) return;

                G_LabelTargetKeyCacheSource = S_LabelTargetKeys;
                G_LabelTargetKeyCache.Resize(0);
                auto parts = S_LabelTargetKeys.Split("|");
                for (uint i = 0; i < parts.Length; i++) {
                    string key = TriggerVisualizer::Trigger::NormalizeTriggerTargetKey(parts[i]);
                    if (key.Length == 0 || IsLabelSourceTargetKey(key)) continue;
                    G_LabelTargetKeyCache.InsertLast(key);
                }
            }

            bool IsLabelTargetEnabled(const string &in rawKey) {
                return TriggerVisualizer::Trigger::TriggerTargetListContains(S_LabelTargetKeys, rawKey);
            }

            void SetLabelTargetEnabled(const string &in rawKey, bool enabled) {
                S_LabelTargetKeys = SetTargetListKeyEnabled(S_LabelTargetKeys, rawKey, enabled);
            }

            void SetLabelTargetKeysEnabled(const array<string> &in keys, bool enabled) {
                for (uint i = 0; i < keys.Length; i++) {
                    SetLabelTargetEnabled(keys[i], enabled);
                }
            }

            void FlipLabelTargetKeys(const array<string> &in keys) {
                for (uint i = 0; i < keys.Length; i++) {
                    SetLabelTargetEnabled(keys[i], !IsLabelTargetEnabled(keys[i]));
                }
            }

            bool ShouldShowLabelForVolume(const TriggerVolume@ volume) {
                if (volume is null) return false;
                if (S_LabelTargetKeys.Length == 0) return false;

                string sourceKey = TriggerVisualizer::Trigger::GetTriggerSourceTargetKey(volume.Source);
                if (sourceKey.Length > 0 && TriggerVisualizer::Trigger::TriggerTargetListContains(S_LabelTargetKeys, sourceKey)) return true;

                RebuildLabelTargetKeyCacheIfNeeded();
                for (uint i = 0; i < G_LabelTargetKeyCache.Length; i++) {
                    if (TriggerVisualizer::Trigger::TriggerVolumeMatchesTargetKey(volume, G_LabelTargetKeyCache[i])) return true;
                }
                return false;
            }

            bool IsLabelSourceTargetKey(const string &in key) {
                return key == TriggerVisualizer::Trigger::TRIGGER_TARGET_OFFZONE
                    || key == TriggerVisualizer::Trigger::TRIGGER_TARGET_MEDIATRACKER
                    || key == TriggerVisualizer::Trigger::TRIGGER_TARGET_CRYSTAL;
            }

            string GetCustomLabelTextForVolume(const TriggerVolume@ volume) {
                if (volume is null || S_LabelTargetOverrideTexts.Length == 0) return "";

                string sourceFallback = "";
                auto entries = S_LabelTargetOverrideTexts.Split("|");
                for (uint i = 0; i < entries.Length; i++) {
                    string entry = entries[i];
                    int separator = entry.IndexOf("=");
                    if (separator <= 0) continue;

                    string key = TriggerVisualizer::Trigger::NormalizeTriggerTargetKey(entry.SubStr(0, separator));
                    if (key.Length == 0) continue;
                    if (!TriggerVisualizer::Trigger::TriggerVolumeMatchesTargetKey(volume, key)) continue;

                    string value = DecodeLabelTargetOverrideText(entry.SubStr(separator + 1));
                    if (value.Length == 0) continue;
                    if (IsLabelSourceTargetKey(key)) {
                        if (sourceFallback.Length == 0) sourceFallback = value;
                        continue;
                    }
                    return value;
                }
                return sourceFallback;
            }
        }
    }
}
