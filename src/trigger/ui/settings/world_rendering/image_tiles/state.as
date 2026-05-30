namespace TriggerVisualizer {
    namespace Trigger {
        namespace UI {
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
