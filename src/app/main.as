namespace OffzoneVisualizer {
    namespace App {
        void Main() {
            log(
                "Loaded " + OffzoneVisualizer::PluginMeta.Name + " v" + OffzoneVisualizer::PluginMeta.Version,
                LogLevel::Debug,
                4,
                "OffzoneVisualizer::App::Main"
            );
            OffzoneVisualizer::Offzone::Main();
        }

        void Render() {
            OffzoneVisualizer::Offzone::RenderWorld();
        }

        bool ShouldRenderWindow() {
            if (!S_WindowOpen) return false;
            if (S_HideWithGame && !UI::IsGameUIVisible()) return false;
            if (S_HideWithOP && !UI::IsOverlayShown()) return false;
            return true;
        }

        void RenderInterface() {
            if (!ShouldRenderWindow()) return;

            if (UI::Begin(MenuTitle() + "###main-" + OffzoneVisualizer::PluginMeta.ID, S_WindowOpen, UI::WindowFlags::None)) {
                RenderWindow();
            }
            UI::End();
        }

        void RenderMenu() {
            if (UI::MenuItem(MenuTitle(), "", S_WindowOpen)) {
                S_WindowOpen = !S_WindowOpen;
            }
        }

        void RenderWindow() {
            UI::Text(OffzoneVisualizer::PluginMeta.Name + " " + OffzoneVisualizer::PluginMeta.Version);
            UI::Separator();
            OffzoneVisualizer::Offzone::RenderPanel();
        }
    }
}
