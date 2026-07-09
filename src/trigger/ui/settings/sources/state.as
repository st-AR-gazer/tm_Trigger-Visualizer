namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            const int SOURCE_SETTINGS_PLAYING = 0;
            const int SOURCE_SETTINGS_EDITOR = 1;
            const int SOURCE_SETTINGS_MEDIATRACKER = 2;
            const int SOURCE_SETTINGS_MESH_MODELLER = 3;
            const string DEFAULT_MEDIATRACKER_SUBTYPES_PLAYING = "camera|customcamera|playercamera|playercamerasubtypecamdefault|playercamerasubtypecam1|playercamerasubtypecam2|playercamerasubtypecam3|gps|mediatrackerreset|";
            const string DEFAULT_MEDIATRACKER_SUBTYPES_EDITOR = "camera|customcamera|orbitalcamera|pathcamera|playercamera|playercamerasubtypecamdefault|playercamerasubtypecam1|playercamerasubtypecam2|playercamerasubtypecam3|2dtriangles|3dtriangles|cartrails|dirtylens|fadingtransition|fog|image|shakecamfx|gps|mediatrackerreset|";
            const string DEFAULT_MEDIATRACKER_SUBTYPES_MEDIATRACKER = "camera|customcamera|orbitalcamera|pathcamera|playercamera|playercamerasubtypecamdefault|playercamerasubtypecam1|playercamerasubtypecam2|playercamerasubtypecam3|playercamerasubtypecamhelico|playercamerasubtypecamfree|playercamerasubtypecamspectator|2dtriangles|3dtriangles|cartrails|colorsfx|colorgrading|depthoffield|dirtylens|editingcut|fadingtransition|fog|ghost|gps|hdrbloom|image|inertialtrackingcamfx|manialinkui|manialinkurl|musicvolume|opponentvisibility|shakecamfx|stereo3d|soundfx|spectators|text|time|timespeed|tonemapping|vehiclelights|mediatrackerreset|mixed|unknown|";
            const string DEFAULT_MEDIATRACKER_SUBTYPES_MESH_MODELLER = "camera|customcamera|orbitalcamera|pathcamera|playercamera|playercamerasubtypecamdefault|playercamerasubtypecam1|playercamerasubtypecam2|playercamerasubtypecam3|2dtriangles|3dtriangles|cartrails|dirtylens|fadingtransition|fog|image|shakecamfx|gps|mediatrackerreset|";

            [Setting hidden name="Trigger: Show offzone source"]
            bool S_ShowOffzoneSource = true;
            [Setting hidden name="Trigger: Show offzone source editor"]
            bool S_ShowOffzoneSourceEditor = true;
            [Setting hidden name="Trigger: Show offzone source mediatracker"]
            bool S_ShowOffzoneSourceMediaTracker = false;
            [Setting hidden name="Trigger: Show offzone source mesh modeler"]
            bool S_ShowOffzoneSourceMeshModeler = false;
            [Setting hidden name="Trigger: Show MediaTracker source"]
            bool S_ShowMediaTrackerSource = true;
            [Setting hidden name="Trigger: Show MediaTracker source editor"]
            bool S_ShowMediaTrackerSourceEditor = true;
            [Setting hidden name="Trigger: Show MediaTracker source mediatracker"]
            bool S_ShowMediaTrackerSourceMediaTracker = true;
            [Setting hidden name="Trigger: Show MediaTracker source mesh modeler"]
            bool S_ShowMediaTrackerSourceMeshModeler = false;
            [Setting hidden name="Trigger: Show crystal source"]
            bool S_ShowCrystalSource = false;
            [Setting hidden name="Trigger: Show crystal source editor"]
            bool S_ShowCrystalSourceEditor = true;
            [Setting hidden name="Trigger: Show crystal source mediatracker"]
            bool S_ShowCrystalSourceMediaTracker = false;
            [Setting hidden name="Trigger: Show crystal source mesh modeler"]
            bool S_ShowCrystalSourceMeshModeler = true;
            [Setting hidden name="Trigger: Crystal custom items and block-items only"]
            bool S_CrystalCustomItemsAndBlockItemsOnly = false;
            [Setting hidden name="Trigger: Show crystal source before custom-only"]
            bool S_ShowCrystalSourceBeforeCustomOnly = false;
            [Setting hidden name="Trigger: Show crystal source editor before custom-only"]
            bool S_ShowCrystalSourceEditorBeforeCustomOnly = true;
            [Setting hidden name="Trigger: Show crystal source mediatracker before custom-only"]
            bool S_ShowCrystalSourceMediaTrackerBeforeCustomOnly = false;
            [Setting hidden name="Trigger: Show crystal source mesh modeler before custom-only"]
            bool S_ShowCrystalSourceMeshModelerBeforeCustomOnly = true;
            [Setting hidden name="Trigger: MediaTracker enabled subtypes playing"]
            string S_MediaTrackerEnabledSubtypesPlaying = DEFAULT_MEDIATRACKER_SUBTYPES_PLAYING;
            [Setting hidden name="Trigger: MediaTracker enabled subtypes editor"]
            string S_MediaTrackerEnabledSubtypesEditor = DEFAULT_MEDIATRACKER_SUBTYPES_EDITOR;
            [Setting hidden name="Trigger: MediaTracker enabled subtypes mediatracker"]
            string S_MediaTrackerEnabledSubtypesMediaTracker = DEFAULT_MEDIATRACKER_SUBTYPES_MEDIATRACKER;
            [Setting hidden name="Trigger: MediaTracker enabled subtypes mesh modeler"]
            string S_MediaTrackerEnabledSubtypesMeshModeler = DEFAULT_MEDIATRACKER_SUBTYPES_MESH_MODELLER;

            const string MAP_ONLY_OVERRIDE_RENDER_WORLD = "render-world";
            const string MAP_ONLY_OVERRIDE_SOURCE_OFFZONE = "source-offzone";
            const string MAP_ONLY_OVERRIDE_SOURCE_MEDIATRACKER = "source-mediatracker";
            const string MAP_ONLY_OVERRIDE_SOURCE_CRYSTAL = "source-crystal";
            const string MAP_ONLY_OVERRIDE_CRYSTAL_CUSTOM_ONLY = "crystal-custom-only";
            dictionary G_MapOnlyOverrides;

            int GetSourceSettingsContextForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                if (ctx is null) return SOURCE_SETTINGS_PLAYING;
                if (ctx.IsReplayEditor || ctx.IsEditorMediaTracker) return SOURCE_SETTINGS_MEDIATRACKER;
                if (ctx.IsEditorTestMode || ctx.IsPlayableMap) return SOURCE_SETTINGS_PLAYING;
                if (ctx.IsMeshModeler) return SOURCE_SETTINGS_MESH_MODELLER;
                if (ctx.IsInEditor) return SOURCE_SETTINGS_EDITOR;
                return SOURCE_SETTINGS_PLAYING;
            }

            string GetMapOnlyOverrideMapKey(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                if (ctx is null || !ctx.HasMapUid()) return "";
                return ctx.MapUid;
            }

            string GetMapOnlyOverrideStorageKey(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                const string &in settingKey
            ) {
                string mapKey = GetMapOnlyOverrideMapKey(ctx);
                if (mapKey.Length == 0 || settingKey.Length == 0) return "";
                return mapKey + "|" + settingKey;
            }

            bool TryGetMapOnlyOverride(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                const string &in settingKey,
                bool &out value
            ) {
                string storageKey = GetMapOnlyOverrideStorageKey(ctx, settingKey);
                if (storageKey.Length == 0) return false;

                int raw = 0;
                if (!G_MapOnlyOverrides.Get(storageKey, raw)) return false;
                value = raw != 0;
                return true;
            }

            bool HasMapOnlyOverride(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                const string &in settingKey
            ) {
                string storageKey = GetMapOnlyOverrideStorageKey(ctx, settingKey);
                return storageKey.Length > 0 && G_MapOnlyOverrides.Exists(storageKey);
            }

            void SetMapOnlyOverride(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                const string &in settingKey,
                bool value
            ) {
                string storageKey = GetMapOnlyOverrideStorageKey(ctx, settingKey);
                if (storageKey.Length == 0) return;
                bool previous = false;
                bool changed = !TryGetMapOnlyOverride(ctx, settingKey, previous) || previous != value;
                G_MapOnlyOverrides.Set(storageKey, value ? 1 : 0);
                if (changed && settingKey == MAP_ONLY_OVERRIDE_CRYSTAL_CUSTOM_ONLY) {
                    TriggerVisualizer::Trigger::RefreshCrystalSourceCache();
                }
            }

            void ClearMapOnlyOverride(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                const string &in settingKey
            ) {
                string storageKey = GetMapOnlyOverrideStorageKey(ctx, settingKey);
                if (storageKey.Length == 0) return;
                bool existed = G_MapOnlyOverrides.Exists(storageKey);
                if (existed) G_MapOnlyOverrides.Delete(storageKey);
                if (existed && settingKey == MAP_ONLY_OVERRIDE_CRYSTAL_CUSTOM_ONLY) {
                    TriggerVisualizer::Trigger::RefreshCrystalSourceCache();
                }
            }

            void ClearCurrentMapOnlyOverrides(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                ClearMapOnlyOverride(ctx, MAP_ONLY_OVERRIDE_RENDER_WORLD);
                ClearMapOnlyOverride(ctx, MAP_ONLY_OVERRIDE_SOURCE_OFFZONE);
                ClearMapOnlyOverride(ctx, MAP_ONLY_OVERRIDE_SOURCE_MEDIATRACKER);
                ClearMapOnlyOverride(ctx, MAP_ONLY_OVERRIDE_SOURCE_CRYSTAL);
                ClearMapOnlyOverride(ctx, MAP_ONLY_OVERRIDE_CRYSTAL_CUSTOM_ONLY);
            }

            string MapOnlyOverrideBoolKey(bool value) {
                return value ? "1" : "0";
            }

            string GetMapOnlyOverridesFilterKey(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                bool value = false;
                string key = "";
                key += "|rw:";
                key += TryGetMapOnlyOverride(ctx, MAP_ONLY_OVERRIDE_RENDER_WORLD, value) ? MapOnlyOverrideBoolKey(value) : "-";
                key += "|oz:";
                key += TryGetMapOnlyOverride(ctx, MAP_ONLY_OVERRIDE_SOURCE_OFFZONE, value) ? MapOnlyOverrideBoolKey(value) : "-";
                key += "|mt:";
                key += TryGetMapOnlyOverride(ctx, MAP_ONLY_OVERRIDE_SOURCE_MEDIATRACKER, value) ? MapOnlyOverrideBoolKey(value) : "-";
                key += "|cr:";
                key += TryGetMapOnlyOverride(ctx, MAP_ONLY_OVERRIDE_SOURCE_CRYSTAL, value) ? MapOnlyOverrideBoolKey(value) : "-";
                key += "|cco:";
                key += TryGetMapOnlyOverride(ctx, MAP_ONLY_OVERRIDE_CRYSTAL_CUSTOM_ONLY, value) ? MapOnlyOverrideBoolKey(value) : "-";
                return key;
            }

            string GetSourceSettingsContextLabel(int context) {
                if (context == SOURCE_SETTINGS_EDITOR) return "Editor";
                if (context == SOURCE_SETTINGS_MEDIATRACKER) return "MediaTracker";
                if (context == SOURCE_SETTINGS_MESH_MODELLER) return "Mesh Modeller";
                return "Playing";
            }

            bool IsOffzoneSourceEnabledForContext(int context) {
                if (context == SOURCE_SETTINGS_EDITOR) return S_ShowOffzoneSourceEditor;
                if (context == SOURCE_SETTINGS_MEDIATRACKER) return S_ShowOffzoneSourceMediaTracker;
                if (context == SOURCE_SETTINGS_MESH_MODELLER) return S_ShowOffzoneSourceMeshModeler;
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
                if (context == SOURCE_SETTINGS_MESH_MODELLER) {
                    S_ShowOffzoneSourceMeshModeler = value;
                    return;
                }
                S_ShowOffzoneSource = value;
            }

            bool IsMediaTrackerSourceEnabledForContext(int context) {
                if (context == SOURCE_SETTINGS_EDITOR) return S_ShowMediaTrackerSourceEditor;
                if (context == SOURCE_SETTINGS_MEDIATRACKER) return S_ShowMediaTrackerSourceMediaTracker;
                if (context == SOURCE_SETTINGS_MESH_MODELLER) return S_ShowMediaTrackerSourceMeshModeler;
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
                if (context == SOURCE_SETTINGS_MESH_MODELLER) {
                    S_ShowMediaTrackerSourceMeshModeler = value;
                    return;
                }
                S_ShowMediaTrackerSource = value;
            }

            bool IsCrystalSourceEnabledForContext(int context) {
                if (S_CrystalCustomItemsAndBlockItemsOnly) return false;
                if (context == SOURCE_SETTINGS_EDITOR) return S_ShowCrystalSourceEditor;
                if (context == SOURCE_SETTINGS_MEDIATRACKER) return S_ShowCrystalSourceMediaTracker;
                if (context == SOURCE_SETTINGS_MESH_MODELLER) return S_ShowCrystalSourceMeshModeler;
                return S_ShowCrystalSource;
            }

            void SetAllCrystalSourceContextsEnabled(bool value) {
                S_ShowCrystalSource = value;
                S_ShowCrystalSourceEditor = value;
                S_ShowCrystalSourceMediaTracker = value;
                S_ShowCrystalSourceMeshModeler = value;
            }

            void SaveCrystalSourceContextsBeforeCustomOnly() {
                S_ShowCrystalSourceBeforeCustomOnly = S_ShowCrystalSource;
                S_ShowCrystalSourceEditorBeforeCustomOnly = S_ShowCrystalSourceEditor;
                S_ShowCrystalSourceMediaTrackerBeforeCustomOnly = S_ShowCrystalSourceMediaTracker;
                S_ShowCrystalSourceMeshModelerBeforeCustomOnly = S_ShowCrystalSourceMeshModeler;
            }

            void RestoreCrystalSourceContextsBeforeCustomOnly() {
                S_ShowCrystalSource = S_ShowCrystalSourceBeforeCustomOnly;
                S_ShowCrystalSourceEditor = S_ShowCrystalSourceEditorBeforeCustomOnly;
                S_ShowCrystalSourceMediaTracker = S_ShowCrystalSourceMediaTrackerBeforeCustomOnly;
                S_ShowCrystalSourceMeshModeler = S_ShowCrystalSourceMeshModelerBeforeCustomOnly;
            }

            void ResetCrystalSourceContextsBeforeCustomOnlyToDefaults() {
                S_ShowCrystalSourceBeforeCustomOnly = false;
                S_ShowCrystalSourceEditorBeforeCustomOnly = true;
                S_ShowCrystalSourceMediaTrackerBeforeCustomOnly = false;
                S_ShowCrystalSourceMeshModelerBeforeCustomOnly = true;
            }

            void SetCrystalSourceEnabledForContext(int context, bool value) {
                if (S_CrystalCustomItemsAndBlockItemsOnly) value = false;
                if (context == SOURCE_SETTINGS_EDITOR) {
                    S_ShowCrystalSourceEditor = value;
                    return;
                }
                if (context == SOURCE_SETTINGS_MEDIATRACKER) {
                    S_ShowCrystalSourceMediaTracker = value;
                    return;
                }
                if (context == SOURCE_SETTINGS_MESH_MODELLER) {
                    S_ShowCrystalSourceMeshModeler = value;
                    return;
                }
                S_ShowCrystalSource = value;
            }

            void SetCrystalCustomItemsAndBlockItemsOnly(bool value) {
                if (value == S_CrystalCustomItemsAndBlockItemsOnly) return;
                if (value) {
                    SaveCrystalSourceContextsBeforeCustomOnly();
                    S_CrystalCustomItemsAndBlockItemsOnly = true;
                    SetAllCrystalSourceContextsEnabled(false);
                } else {
                    S_CrystalCustomItemsAndBlockItemsOnly = false;
                    RestoreCrystalSourceContextsBeforeCustomOnly();
                }
                TriggerVisualizer::Trigger::RefreshCrystalSourceCache();
            }

            bool IsRenderWorldEnabledForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                bool value = false;
                if (TryGetMapOnlyOverride(ctx, MAP_ONLY_OVERRIDE_RENDER_WORLD, value)) return value;
                return S_RenderWorld;
            }

            bool IsCrystalCustomItemsAndBlockItemsOnlyForRuntime(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
                bool value = false;
                if (TryGetMapOnlyOverride(ctx, MAP_ONLY_OVERRIDE_CRYSTAL_CUSTOM_ONLY, value)) return value;
                return S_CrystalCustomItemsAndBlockItemsOnly;
            }

            string GetMapOnlySourceOverrideKey(int source) {
                if (source == TriggerVisualizer::Trigger::TRIGGER_SOURCE_OFFZONE) return MAP_ONLY_OVERRIDE_SOURCE_OFFZONE;
                if (source == TriggerVisualizer::Trigger::TRIGGER_SOURCE_MEDIATRACKER) return MAP_ONLY_OVERRIDE_SOURCE_MEDIATRACKER;
                if (source == TriggerVisualizer::Trigger::TRIGGER_SOURCE_CRYSTAL) return MAP_ONLY_OVERRIDE_SOURCE_CRYSTAL;
                return "";
            }

            bool TryGetMapOnlySourceEnabled(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                int source,
                bool &out enabled
            ) {
                return TryGetMapOnlyOverride(ctx, GetMapOnlySourceOverrideKey(source), enabled);
            }

            void SetMapOnlySourceEnabled(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                int source,
                bool enabled
            ) {
                SetMapOnlyOverride(ctx, GetMapOnlySourceOverrideKey(source), enabled);
            }

            void ClearMapOnlySourceEnabled(
                const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
                int source
            ) {
                ClearMapOnlyOverride(ctx, GetMapOnlySourceOverrideKey(source));
            }

            string GetMediaTrackerEnabledSubtypesForContext(int context) {
                if (context == SOURCE_SETTINGS_EDITOR) return S_MediaTrackerEnabledSubtypesEditor;
                if (context == SOURCE_SETTINGS_MEDIATRACKER) return S_MediaTrackerEnabledSubtypesMediaTracker;
                if (context == SOURCE_SETTINGS_MESH_MODELLER) return S_MediaTrackerEnabledSubtypesMeshModeler;
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
                if (context == SOURCE_SETTINGS_MESH_MODELLER) {
                    S_MediaTrackerEnabledSubtypesMeshModeler = value;
                    return;
                }
                S_MediaTrackerEnabledSubtypesPlaying = value;
            }

            string GetDefaultMediaTrackerEnabledSubtypesForContext(int context) {
                if (context == SOURCE_SETTINGS_EDITOR) return DEFAULT_MEDIATRACKER_SUBTYPES_EDITOR;
                if (context == SOURCE_SETTINGS_MEDIATRACKER) return DEFAULT_MEDIATRACKER_SUBTYPES_MEDIATRACKER;
                if (context == SOURCE_SETTINGS_MESH_MODELLER) return DEFAULT_MEDIATRACKER_SUBTYPES_MESH_MODELLER;
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

            bool MediaTrackerSubtypeTargetListContains(const string &in targetKeys, const string &in rawKey) {
                string key = TriggerVisualizer::Trigger::NormalizeTriggerTargetKey(rawKey);
                if (key == TriggerVisualizer::Trigger::MT_SUBTYPE_RESET) {
                    return TriggerVisualizer::Trigger::TriggerTargetListContains(
                        targetKeys,
                        TriggerVisualizer::Trigger::MT_SUBTYPE_RESET
                    )
                        || TriggerVisualizer::Trigger::TriggerTargetListContains(
                            targetKeys,
                            TriggerVisualizer::Trigger::TRIGGER_TYPE_RESET
                        );
                }
                return TriggerVisualizer::Trigger::TriggerTargetListContains(targetKeys, key);
            }

            string SetMediaTrackerSubtypeTargetListKeyEnabled(
                const string &in targetKeys,
                const string &in rawKey,
                bool enabled
            ) {
                string key = TriggerVisualizer::Trigger::NormalizeTriggerTargetKey(rawKey);
                if (key != TriggerVisualizer::Trigger::MT_SUBTYPE_RESET) {
                    return SetTargetListKeyEnabled(targetKeys, key, enabled);
                }

                string next = SetTargetListKeyEnabled(
                    targetKeys,
                    TriggerVisualizer::Trigger::TRIGGER_TYPE_RESET,
                    false
                );
                return SetTargetListKeyEnabled(next, TriggerVisualizer::Trigger::MT_SUBTYPE_RESET, enabled);
            }

            bool IsMediaTrackerSubtypeEnabledForContext(int context, const string &in rawKey) {
                return MediaTrackerSubtypeTargetListContains(GetMediaTrackerEnabledSubtypesForContext(context), rawKey);
            }

            void SetMediaTrackerSubtypeEnabledForContext(int context, const string &in rawKey, bool enabled) {
                string targetKeys = GetMediaTrackerEnabledSubtypesForContext(context);
                SetMediaTrackerEnabledSubtypesForContext(
                    context,
                    SetMediaTrackerSubtypeTargetListKeyEnabled(targetKeys, rawKey, enabled)
                );
            }

            void FlipMediaTrackerSubtypeKeysForContext(int context, const array<string> &in keys) {
                string targetKeys = GetMediaTrackerEnabledSubtypesForContext(context);
                for (uint i = 0; i < keys.Length; i++) {
                    bool enabled = MediaTrackerSubtypeTargetListContains(targetKeys, keys[i]);
                    targetKeys = SetMediaTrackerSubtypeTargetListKeyEnabled(targetKeys, keys[i], !enabled);
                }
                SetMediaTrackerEnabledSubtypesForContext(
                    context,
                    targetKeys
                );
            }

            void SetMediaTrackerSubtypeKeysForContext(int context, const array<string> &in keys, bool enabled) {
                string targetKeys = GetMediaTrackerEnabledSubtypesForContext(context);
                for (uint i = 0; i < keys.Length; i++) {
                    targetKeys = SetMediaTrackerSubtypeTargetListKeyEnabled(targetKeys, keys[i], enabled);
                }
                SetMediaTrackerEnabledSubtypesForContext(
                    context,
                    targetKeys
                );
            }

            void ResetSourceProfileSettingsToDefaults() {
                S_ShowOffzoneSource = true;
                S_ShowOffzoneSourceEditor = true;
                S_ShowOffzoneSourceMediaTracker = false;
                S_ShowOffzoneSourceMeshModeler = false;
                S_ShowMediaTrackerSource = true;
                S_ShowMediaTrackerSourceEditor = true;
                S_ShowMediaTrackerSourceMediaTracker = true;
                S_ShowMediaTrackerSourceMeshModeler = false;
                S_ShowCrystalSource = false;
                S_ShowCrystalSourceEditor = true;
                S_ShowCrystalSourceMediaTracker = false;
                S_ShowCrystalSourceMeshModeler = true;
                S_CrystalCustomItemsAndBlockItemsOnly = false;
                ResetCrystalSourceContextsBeforeCustomOnlyToDefaults();
                S_MediaTrackerEnabledSubtypesPlaying = DEFAULT_MEDIATRACKER_SUBTYPES_PLAYING;
                S_MediaTrackerEnabledSubtypesEditor = DEFAULT_MEDIATRACKER_SUBTYPES_EDITOR;
                S_MediaTrackerEnabledSubtypesMediaTracker = DEFAULT_MEDIATRACKER_SUBTYPES_MEDIATRACKER;
                S_MediaTrackerEnabledSubtypesMeshModeler = DEFAULT_MEDIATRACKER_SUBTYPES_MESH_MODELLER;
            }

            void ResetSourceSettingsToDefaults() {
                ResetSourceProfileSettingsToDefaults();
            }
        }
    }
}
