namespace TriggerVisualizer {
    Meta::Plugin@ PluginMeta = Meta::ExecutingPlugin();

    namespace App {
        [Setting hidden name="Dev panel open"]
        bool S_DevPanelOpen = true;

        [Setting hidden name="Hide with game UI"]
        bool S_HideWithGame = true;

        [Setting hidden name="Hide with Openplanet UI"]
        bool S_HideWithOP = false;

        string g_MenuIcon = "";

        void ResetSettingsToDefaults() {
            S_DevPanelOpen = true;
            S_HideWithGame = true;
            S_HideWithOP = false;
        }

        string PluginNameHash() {
            return Crypto::MD5(TriggerVisualizer::PluginMeta.Name);
        }

        string MenuIcon() {
            if (g_MenuIcon.Length == 0) {
                g_MenuIcon = _Text::StableIconForSeed(PluginNameHash());
            }
            return g_MenuIcon;
        }

        string MenuTitle() {
            string hash = PluginNameHash();
            return "\\$" + hash.SubStr(0, 3) + MenuIcon() + "\\$z " + TriggerVisualizer::PluginMeta.Name;
        }
    }
}
