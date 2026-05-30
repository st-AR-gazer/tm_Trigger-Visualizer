namespace TriggerVisualizer {
    namespace App {
        void Main() {
            log(
                "Loaded " + TriggerVisualizer::PluginMeta.Name + " v" + TriggerVisualizer::PluginMeta.Version,
                LogLevel::Debug,
                4,
                "TriggerVisualizer::App::Main"
            );
            TriggerVisualizer::Trigger::Main();
        }

        void Render() {
            if (!ShouldRenderWorld()) return;
            TriggerVisualizer::Trigger::RenderWorld();
        }

        bool ShouldRenderWithUiVisibility() {
            if (S_HideWithGame && !UI::IsGameUIVisible()) return false;
            if (S_HideWithOP && !UI::IsOverlayShown()) return false;
            return true;
        }

        bool ShouldRenderWorld() {
            if (!TriggerVisualizer::Trigger::UI::S_RenderWorld) return false;
            return ShouldRenderWithUiVisibility();
        }

        bool ShouldRenderWindow() {
            return S_DevPanelOpen;
        }

        void RenderInterface() {
            if (!ShouldRenderWindow()) return;

            bool devPanelOpen = S_DevPanelOpen;
            if (UI::Begin(MenuTitle() + "###dev-panel-" + TriggerVisualizer::PluginMeta.ID, devPanelOpen, UI::WindowFlags::None)) {
                RenderWindow();
            }
            S_DevPanelOpen = devPanelOpen;
            UI::End();
        }

        void RenderMenu() {
            bool toggleClicked = UI::MenuItem(MenuTitle(), "", TriggerVisualizer::Trigger::UI::S_RenderWorld);
            if (UI::IsItemClicked(UI::MouseButton::Right)) {
                Meta::OpenSettings(TriggerVisualizer::PluginMeta);
                return;
            }

            if (toggleClicked) {
                TriggerVisualizer::Trigger::UI::S_RenderWorld = !TriggerVisualizer::Trigger::UI::S_RenderWorld;
            }
        }

        void RenderWindow() {
            UI::Text(TriggerVisualizer::PluginMeta.Name + " " + TriggerVisualizer::PluginMeta.Version);
            UI::Separator();
            TriggerVisualizer::Trigger::RenderDevPanel();
        }
    }
}
