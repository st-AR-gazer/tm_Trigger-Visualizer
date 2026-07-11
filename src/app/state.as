namespace TriggerVisualizer {
    Meta::Plugin@ g_PluginMeta = Meta::ExecutingPlugin();

    namespace App {
        [Setting hidden name="Dev panel open"]
        bool S_DevPanelOpen = false;
        [Setting hidden name="Hide with game UI"]
        bool S_HideWithGame = true;
        [Setting hidden name="Hide with Openplanet UI"]
        bool S_HideWithOP = false;

        void ResetGeneralVisibilitySettingsToDefaults() {
            S_HideWithGame = true;
            S_HideWithOP = false;
        }

        void ResetGeneralDeveloperSettingsToDefaults() {
            S_DevPanelOpen = false;
        }

        void ResetGeneralSettingsToDefaults() {
            ResetGeneralVisibilitySettingsToDefaults();
            ResetGeneralDeveloperSettingsToDefaults();
        }

        string MenuIcon() {
            return Icons::Linode;
        }

        string MenuTitle() {
            string hash = Crypto::MD5(TriggerVisualizer::g_PluginMeta.Name);
            return "\\$" + hash.SubStr(0, 3) + MenuIcon() + "\\$z " + TriggerVisualizer::g_PluginMeta.Name;
        }
    }
}
