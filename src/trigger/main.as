namespace TriggerVisualizer {
    namespace Trigger {
        TriggerVisualizer::Trigger::Data::RuntimeContext@ g_RuntimeContext = null;
        MapSnapshot@ g_MapSnapshot = null;
        TriggerSourceSnapshot@ g_CachedMediaTrackerSource = null;
        string g_CachedMediaTrackerMapUid = "";
        bool g_CachedMediaTrackerEnabled = false;
        bool g_CachedMediaTrackerCellRendering = false;
        string g_CachedMediaTrackerGroupName = "";
        uint64 g_CachedMediaTrackerGroupBufferPtr = 0;
        uint64 g_CachedMediaTrackerRefreshAt = 0;

        const uint64 MEDIATRACKER_SOURCE_CACHE_MS = 1500;

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
            @g_MapSnapshot = BuildMapSnapshot(g_RuntimeContext);
        }

        TriggerVisualizer::Trigger::Data::RuntimeContext@ GetCurrentRuntimeContext() {
            if (g_RuntimeContext is null) RefreshCurrentState();
            return g_RuntimeContext;
        }

        MapSnapshot@ GetCurrentMapSnapshot() {
            if (g_MapSnapshot is null) RefreshCurrentState();
            return g_MapSnapshot;
        }

        MapSnapshot@ BuildMapSnapshot(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            auto snapshot = MapSnapshot();
            if (ctx is null) return snapshot;

            snapshot.MapUid = ctx.MapUid;
            if (!ctx.HasMap) return snapshot;

            snapshot.MapComments = TriggerVisualizer::Trigger::Data::ReadMapComments(ctx.RootMap);
            @snapshot.RenderHints = TriggerVisualizer::Trigger::Data::ParseMapRenderHints(snapshot.MapComments);

            bool offzoneEnabled = TriggerVisualizer::Trigger::UI::IsOffzoneSourceEnabledForRuntime(ctx);
            auto offzoneSource = TriggerVisualizer::Trigger::Data::Sources::ReadOffzoneTriggerSource(
                ctx.RootMap,
                offzoneEnabled
            );
            snapshot.RawTriggerSize = offzoneSource.RawTriggerSize;
            snapshot.RawBufferPtr = offzoneSource.RawBufferPtr;
            @snapshot.GridSpec = offzoneSource.GridSpec;
            snapshot.RawRanges = offzoneSource.RawRanges;
            snapshot.AddSource(offzoneSource);

            auto mediaTrackerSource = GetMediaTrackerTriggerSource(ctx);
            snapshot.AddSource(mediaTrackerSource);

            return snapshot;
        }

        TriggerSourceSnapshot@ GetMediaTrackerTriggerSource(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            bool enabled = TriggerVisualizer::Trigger::UI::IsMediaTrackerSourceEnabledForRuntime(ctx);
            bool renderCells = true;
            string groupName = "";
            CGameCtnMediaClipGroup@ clipGroup = null;
            uint64 groupBufferPtr = 0;
            if (enabled) {
                @clipGroup = GetRuntimeMediaTrackerClipGroup(ctx, groupName);
                groupBufferPtr = TriggerVisualizer::Trigger::Data::Sources::ReadMediaTrackerClipGroupTriggerBufferPtr(clipGroup);
            }

            if (g_CachedMediaTrackerSource !is null && g_CachedMediaTrackerMapUid == ctx.MapUid && g_CachedMediaTrackerEnabled == enabled && g_CachedMediaTrackerCellRendering == renderCells && g_CachedMediaTrackerGroupName == groupName && g_CachedMediaTrackerGroupBufferPtr == groupBufferPtr && Time::Now<g_CachedMediaTrackerRefreshAt) {
                return g_CachedMediaTrackerSource;
            }

            auto source = TriggerVisualizer::Trigger::Data::Sources::ReadMediaTrackerTriggerSource(
                ctx.RootMap,
                clipGroup,
                groupName,
                enabled,
                renderCells
            );
            @g_CachedMediaTrackerSource = source;
            g_CachedMediaTrackerMapUid = ctx.MapUid;
            g_CachedMediaTrackerEnabled = enabled;
            g_CachedMediaTrackerCellRendering = renderCells;
            g_CachedMediaTrackerGroupName = groupName;
            g_CachedMediaTrackerGroupBufferPtr = groupBufferPtr;
            g_CachedMediaTrackerRefreshAt = Time::Now + MEDIATRACKER_SOURCE_CACHE_MS;

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
