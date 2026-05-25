namespace TriggerVisualizer {
    namespace Trigger {
        TriggerVisualizer::Trigger::Data::RuntimeContext@ g_RuntimeContext = null;
        MapSnapshot@ g_MapSnapshot = null;

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

            auto offzoneSource = TriggerVisualizer::Trigger::Data::Sources::ReadOffzoneTriggerSource(
                ctx.RootMap,
                TriggerVisualizer::Trigger::UI::S_ShowOffzoneSource
            );
            snapshot.RawTriggerSize = offzoneSource.RawTriggerSize;
            snapshot.RawBufferPtr = offzoneSource.RawBufferPtr;
            @snapshot.GridSpec = offzoneSource.GridSpec;
            snapshot.RawRanges = offzoneSource.RawRanges;
            snapshot.AddSource(offzoneSource);

            return snapshot;
        }
    }
}
