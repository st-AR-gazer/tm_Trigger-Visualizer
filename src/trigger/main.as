namespace TriggerVisualizer {
    namespace Trigger {
        TriggerVisualizer::Trigger::Data::RuntimeContext@ g_RuntimeContext = null;
        MapSnapshot@ g_MapSnapshot = null;
        CGameCtnChallenge@ g_CachedMapSnapshotRootMap = null;
        string g_CachedMapSnapshotContextKey = "";
        bool g_CachedMapSnapshotOffzoneEnabled = false;
        bool g_CachedMapSnapshotMediaTrackerEnabled = false;
        TriggerSourceSnapshot@ g_CachedOffzoneSource = null;
        CGameCtnChallenge@ g_CachedOffzoneRootMap = null;
        TriggerSourceSnapshot@ g_CachedMediaTrackerSource = null;
        CGameCtnChallenge@ g_CachedMediaTrackerRootMap = null;
        string g_CachedMediaTrackerContextKey = "";
        bool g_CachedMediaTrackerCellRendering = false;
        string g_CachedMediaTrackerGroupName = "";
        uint64 g_CachedMediaTrackerGroupBufferPtr = 0;

        const bool MEDIATRACKER_RENDER_CELLS = true;

        void Main() {
            RefreshCurrentState();
        }

        void RenderWorld() {
            RefreshCurrentState();
            TriggerVisualizer::Trigger::Render::RenderWorld();
        }

        void RenderDevPanel() {
            RefreshCurrentState();
            TriggerVisualizer::Trigger::UI::Dev::RenderDevPanelContent();
        }

        void RefreshCurrentState() {
            @g_RuntimeContext = TriggerVisualizer::Trigger::Data::GetRuntimeContext();
            if (CanReuseMapSnapshot(g_RuntimeContext)) return;

            @g_MapSnapshot = BuildMapSnapshot(g_RuntimeContext);
            StoreMapSnapshotCacheState(g_RuntimeContext);
        }

        TriggerVisualizer::Trigger::Data::RuntimeContext@ GetCurrentRuntimeContext() {
            if (g_RuntimeContext is null) RefreshCurrentState();
            return g_RuntimeContext;
        }

        MapSnapshot@ GetCurrentMapSnapshot() {
            if (g_MapSnapshot is null) RefreshCurrentState();
            return g_MapSnapshot;
        }

        string GetMapSnapshotContextKey(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            if (ctx is null) return "<null>";

            string key = ctx.HasMap ? "map" : "no-map";
            if (ctx.IsReplayEditor) return key + "|replay-editor";
            if (ctx.IsEditorMediaTracker) return key + "|editor-mediatracker";
            if (ctx.IsEditorTestMode) return key + "|editor-test";
            if (ctx.IsMapEditor) return key + "|map-editor";
            if (ctx.IsPlayableMap) return key + "|playable";
            if (ctx.IsInEditor) return key + "|editor";
            if (ctx.IsInMenu) return key + "|menu";
            return key + "|unknown";
        }

        bool CanReuseMapSnapshot(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            if (g_MapSnapshot is null || ctx is null) return false;

            bool offzoneEnabled = TriggerVisualizer::Trigger::UI::IsOffzoneSourceEnabledForRuntime(ctx);
            bool mediaTrackerEnabled = TriggerVisualizer::Trigger::UI::IsMediaTrackerSourceEnabledForRuntime(ctx);
            return ctx.RootMap is g_CachedMapSnapshotRootMap
                && g_CachedMapSnapshotContextKey == GetMapSnapshotContextKey(ctx)
                && g_CachedMapSnapshotOffzoneEnabled == offzoneEnabled
                && g_CachedMapSnapshotMediaTrackerEnabled == mediaTrackerEnabled;
        }

        void StoreMapSnapshotCacheState(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            if (ctx is null) {
                @g_CachedMapSnapshotRootMap = null;
                g_CachedMapSnapshotContextKey = "<null>";
                g_CachedMapSnapshotOffzoneEnabled = false;
                g_CachedMapSnapshotMediaTrackerEnabled = false;
                return;
            }

            @g_CachedMapSnapshotRootMap = ctx.RootMap;
            g_CachedMapSnapshotContextKey = GetMapSnapshotContextKey(ctx);
            g_CachedMapSnapshotOffzoneEnabled = TriggerVisualizer::Trigger::UI::IsOffzoneSourceEnabledForRuntime(ctx);
            g_CachedMapSnapshotMediaTrackerEnabled = TriggerVisualizer::Trigger::UI::IsMediaTrackerSourceEnabledForRuntime(ctx);
        }

        MapSnapshot@ BuildMapSnapshot(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            auto snapshot = MapSnapshot();
            if (ctx is null) return snapshot;

            snapshot.MapUid = ctx.MapUid;
            if (!ctx.HasMap) return snapshot;

            snapshot.MapComments = TriggerVisualizer::Trigger::Data::ReadMapComments(ctx.RootMap);
            @snapshot.RenderHints = TriggerVisualizer::Trigger::Data::ParseMapRenderHints(snapshot.MapComments);

            bool offzoneEnabled = TriggerVisualizer::Trigger::UI::IsOffzoneSourceEnabledForRuntime(ctx);
            auto offzoneSource = GetOffzoneTriggerSource(ctx, offzoneEnabled);
            snapshot.RawTriggerSize = offzoneSource.RawTriggerSize;
            snapshot.RawBufferPtr = offzoneSource.RawBufferPtr;
            @snapshot.GridSpec = offzoneSource.GridSpec;
            snapshot.RawRanges = offzoneSource.RawRanges;
            snapshot.AddSource(offzoneSource);

            auto mediaTrackerSource = GetMediaTrackerTriggerSource(ctx);
            snapshot.AddSource(mediaTrackerSource);

            return snapshot;
        }

        TriggerSourceSnapshot@ GetOffzoneTriggerSource(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            bool enabled
        ) {
            if (ctx is null || ctx.RootMap is null) {
                return TriggerVisualizer::Trigger::Data::Sources::ReadOffzoneTriggerSource(null, enabled);
            }

            if (g_CachedOffzoneSource is null || ctx.RootMap !is g_CachedOffzoneRootMap) {
                @g_CachedOffzoneSource = TriggerVisualizer::Trigger::Data::Sources::ReadOffzoneTriggerSource(
                    ctx.RootMap,
                    true
                );
                @g_CachedOffzoneRootMap = ctx.RootMap;
            }

            g_CachedOffzoneSource.Enabled = enabled;
            return g_CachedOffzoneSource;
        }

        TriggerSourceSnapshot@ GetMediaTrackerTriggerSource(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            bool enabled = TriggerVisualizer::Trigger::UI::IsMediaTrackerSourceEnabledForRuntime(ctx);
            string contextKey = GetMapSnapshotContextKey(ctx);

            if (!enabled) {
                if (
                    g_CachedMediaTrackerSource !is null
                    && ctx !is null
                    && ctx.RootMap is g_CachedMediaTrackerRootMap
                    && g_CachedMediaTrackerContextKey == contextKey
                ) {
                    g_CachedMediaTrackerSource.Enabled = false;
                    return g_CachedMediaTrackerSource;
                }

                return TriggerVisualizer::Trigger::Data::Sources::ReadMediaTrackerTriggerSource(
                    ctx is null ? null : ctx.RootMap,
                    null,
                    "",
                    false,
                    MEDIATRACKER_RENDER_CELLS
                );
            }

            if (
                g_CachedMediaTrackerSource !is null
                && ctx !is null
                && ctx.RootMap is g_CachedMediaTrackerRootMap
                && g_CachedMediaTrackerContextKey == contextKey
                && g_CachedMediaTrackerCellRendering == MEDIATRACKER_RENDER_CELLS
            ) {
                g_CachedMediaTrackerSource.Enabled = true;
                return g_CachedMediaTrackerSource;
            }

            string groupName = "";
            CGameCtnMediaClipGroup@ clipGroup = null;
            uint64 groupBufferPtr = 0;
            @clipGroup = GetRuntimeMediaTrackerClipGroup(ctx, groupName);
            groupBufferPtr = TriggerVisualizer::Trigger::Data::Sources::ReadMediaTrackerClipGroupTriggerBufferPtr(clipGroup);

            auto source = TriggerVisualizer::Trigger::Data::Sources::ReadMediaTrackerTriggerSource(
                ctx.RootMap,
                clipGroup,
                groupName,
                enabled,
                MEDIATRACKER_RENDER_CELLS
            );
            @g_CachedMediaTrackerSource = source;
            @g_CachedMediaTrackerRootMap = ctx.RootMap;
            g_CachedMediaTrackerContextKey = contextKey;
            g_CachedMediaTrackerCellRendering = MEDIATRACKER_RENDER_CELLS;
            g_CachedMediaTrackerGroupName = groupName;
            g_CachedMediaTrackerGroupBufferPtr = groupBufferPtr;

            return source;
        }

        CGameCtnMediaClipGroup@ GetRuntimeMediaTrackerClipGroup(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            string &out groupName
        ) {
            groupName = "InGame";
            if (ctx is null || ctx.RootMap is null) return null;

            if (ctx.IsEditorMediaTracker && ctx.App !is null) {
                auto mediaTrackerEditor = cast<CGameEditorMediaTracker>(ctx.App.Editor);
                if (mediaTrackerEditor !is null) {
                    auto pluginApi = cast<CGameEditorMediaTrackerPluginAPI>(mediaTrackerEditor.PluginAPI);
                    if (pluginApi !is null && pluginApi.ClipGroup !is null) {
                        groupName = "EditorActive";
                        return pluginApi.ClipGroup;
                    }
                }
            }

            return ctx.RootMap.ClipGroupInGame;
        }
    }
}
