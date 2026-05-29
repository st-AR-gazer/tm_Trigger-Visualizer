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

            [Setting hidden name="Trigger: Max fill tiles per frame" min=128 max=65536]
            int S_MaxFillTilesPerFrame = 4096;

            [Setting hidden name="Trigger: Max tile icon patches per frame" min=0 max=65536]
            int S_MaxTileIconPatchesPerFrame = 1600;

            [Setting hidden name="Trigger: Tile icon max subdivisions" min=1 max=12]
            int S_TileIconMaxSubdivisions = 6;

            [Setting hidden name="Trigger: Show skull tile icons"]
            bool S_ShowSkullTileIcons = false;

            [Setting hidden name="Trigger: Skull tile icon scale" min=0.05 max=1]
            float S_SkullTileIconScale = 0.45f;

            [Setting hidden name="Trigger: Skull tile icon alpha" min=0 max=1]
            float S_SkullTileIconAlpha = 0.85f;

            [Setting hidden name="Trigger: Custom tile icon storage path"]
            string S_CustomTileIconStoragePath = "";

            string G_PendingTileIconSourcePath = "";
            string G_TileIconImportStatus = "";
        }
    }
}
