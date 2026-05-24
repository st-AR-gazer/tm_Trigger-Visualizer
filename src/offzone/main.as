namespace OffzoneVisualizer {
    namespace Offzone {
        OffzoneVisualizer::Offzone::Data::RuntimeContext@ g_RuntimeContext = null;
        MapSnapshot@ g_MapSnapshot = null;

        void Main() {
            RefreshCurrentState();
        }

        void RenderWorld() {
            RefreshCurrentState();
            OffzoneVisualizer::Offzone::Render::RenderWorld();
        }

        void RenderPanel() {
            RefreshCurrentState();
            OffzoneVisualizer::Offzone::UI::Dev::RenderPanelContent();
        }

        void RefreshCurrentState() {
            @g_RuntimeContext = OffzoneVisualizer::Offzone::Data::GetRuntimeContext();
            @g_MapSnapshot = BuildMapSnapshot(g_RuntimeContext);
        }

        OffzoneVisualizer::Offzone::Data::RuntimeContext@ GetCurrentRuntimeContext() {
            if (g_RuntimeContext is null) RefreshCurrentState();
            return g_RuntimeContext;
        }

        MapSnapshot@ GetCurrentMapSnapshot() {
            if (g_MapSnapshot is null) RefreshCurrentState();
            return g_MapSnapshot;
        }

        MapSnapshot@ BuildMapSnapshot(const OffzoneVisualizer::Offzone::Data::RuntimeContext@ ctx) {
            auto snapshot = MapSnapshot();
            if (ctx is null) return snapshot;

            snapshot.MapUid = ctx.MapUid;
            if (!ctx.HasMap) return snapshot;

            snapshot.RawTriggerSize = OffzoneVisualizer::Offzone::Data::ReadOffzoneTriggerSize(ctx.RootMap);
            snapshot.RawBufferPtr = OffzoneVisualizer::Offzone::Data::ReadOffzoneBufferPtr(ctx.RootMap);
            @snapshot.GridSpec = OffzoneVisualizer::Offzone::Data::BuildTriggerGridSpec(snapshot.RawTriggerSize);
            snapshot.RawRanges = OffzoneVisualizer::Offzone::Data::ReadOffzoneRawRanges(ctx.RootMap);
            snapshot.WorldBoxes = OffzoneVisualizer::Offzone::Data::TriggerRangesToWorldAabbs(
                snapshot.RawRanges,
                snapshot.GridSpec
            );

            return snapshot;
        }
    }
}
