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
            if (!ShouldRenderWorld()) return;
            OffzoneVisualizer::Offzone::RenderWorld();
        }

        bool ShouldRenderWithUiVisibility() {
            if (S_HideWithGame && !UI::IsGameUIVisible()) return false;
            if (S_HideWithOP && !UI::IsOverlayShown()) return false;
            return true;
        }

        bool ShouldRenderWorld() {
            if (!OffzoneVisualizer::Offzone::UI::S_RenderWorld) return false;
            return ShouldRenderWithUiVisibility();
        }

        bool ShouldRenderWindow() {
            return S_DevPanelOpen;
        }

        void RenderInterface() {
            if (!ShouldRenderWindow()) return;

            bool devPanelOpen = S_DevPanelOpen;
            if (UI::Begin(MenuTitle() + "###dev-panel-" + OffzoneVisualizer::PluginMeta.ID, devPanelOpen, UI::WindowFlags::None)) {
                RenderWindow();
            }
            S_DevPanelOpen = devPanelOpen;
            UI::End();
        }

        void RenderMenu() {
            if (UI::MenuItem(MenuTitle(), "", S_DevPanelOpen)) {
                S_DevPanelOpen = !S_DevPanelOpen;
            }
        }

        void RenderWindow() {
            UI::Text(OffzoneVisualizer::PluginMeta.Name + " " + OffzoneVisualizer::PluginMeta.Version);
            UI::Separator();
            OffzoneVisualizer::Offzone::RenderDevPanel();
        }
    }
}
