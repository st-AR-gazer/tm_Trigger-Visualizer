namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
            [Setting hidden name="Trigger: Cull offscreen world tiles"]
            bool S_CullOffscreenWorldTiles = true;
            [Setting hidden name="Trigger: Experimental screen-occluded world tile culling"]
            bool S_CullScreenOccludedWorldTiles = false;
            [Setting hidden name="Trigger: Screen occlusion cell size" min=8 max=256]
            int S_ScreenOcclusionCellSize = 32;
            [Setting hidden name="Trigger: Fill tile minimum size" min=2 max=64]
            float S_FillTileMinSize = 4.0f;
            [Setting hidden name="Trigger: Max visible volumes per frame" min=16 max=4096]
            int S_MaxVisibleVolumesPerFrame = 512;
            [Setting hidden name="Trigger: Max fill tiles per frame" min=128 max=65536]
            int S_MaxFillTilesPerFrame = 4096;
            [Setting hidden name="Trigger: Max outline segments per frame" min=64 max=65536]
            int S_MaxOutlineSegmentsPerFrame = 1536;
            [Setting hidden name="Trigger: Max tile icon patches per frame" min=0 max=65536]
            int S_MaxTileIconPatchesPerFrame = 1600;
            [Setting hidden name="Trigger: Tile icon max subdivisions" min=1 max=12]
            int S_TileIconMaxSubdivisions = 6;
            [Setting hidden name="Trigger: MediaTracker editor refresh interval ms" min=100 max=5000]
            int S_MediaTrackerEditorRefreshIntervalMs = 500;
            [Setting hidden name="Trigger: Offzone editor refresh interval ms" min=100 max=5000]
            int S_OffzoneEditorRefreshIntervalMs = 500;
            [Setting hidden name="Trigger: Fast driving performance mode"]
            bool S_FastDrivingPerformanceMode = true;
            [Setting hidden name="Trigger: Fast driving speed threshold kmh" min=0 max=1000]
            float S_FastDrivingSpeedThresholdKmh = 60.0f;
        }
    }
}
