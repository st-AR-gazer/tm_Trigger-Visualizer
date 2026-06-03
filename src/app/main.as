namespace TriggerVisualizer {
    namespace App {
        void PushPluginButtonStyleUI() {
            UI::PushStyleColor(UI::Col::Button, vec4(0.16f, 0.30f, 0.36f, 0.78f));
            UI::PushStyleColor(UI::Col::ButtonHovered, vec4(0.20f, 0.39f, 0.46f, 0.92f));
            UI::PushStyleColor(UI::Col::ButtonActive, vec4(0.24f, 0.46f, 0.54f, 1.00f));
        }

        void PopPluginButtonStyleUI() {
            UI::PopStyleColor(3);
        }

        void Main() {
            log(
                "Loaded " + TriggerVisualizer::PluginMeta.Name + " v" + TriggerVisualizer::PluginMeta.Version,
                LogLevel::Debug,
                14,
                "TriggerVisualizer::App::Main"
            );
            TriggerVisualizer::Trigger::Main();
        }

        void Render() {
            if (!ShouldRenderWorld()) return;
            TriggerVisualizer::Trigger::RenderWorld();
        }

        bool ShouldRenderWithUiVisibility() {
            auto ctx = TriggerVisualizer::Trigger::GetCurrentRuntimeContext();
            bool isEditorContext = ctx !is null && ctx.IsInEditor;
            if (S_HideWithGame && !isEditorContext && !UI::IsGameUIVisible()) return false;
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
            PushPluginButtonStyleUI();
            FILE_EXPLORER_BASE_RENDERER();
            PopPluginButtonStyleUI();
            if (!ShouldRenderWindow()) return;

            bool devPanelOpen = S_DevPanelOpen;
            PushPluginButtonStyleUI();
            if (UI::Begin(MenuTitle() + "###dev-panel-" + TriggerVisualizer::PluginMeta.ID, devPanelOpen, UI::WindowFlags::None)) {
                RenderWindow();
            }
            PopPluginButtonStyleUI();
            S_DevPanelOpen = devPanelOpen;
            UI::End();
        }

        void RenderMenu() {
            string mapCommentHideSummary = TriggerVisualizer::Trigger::GetWorldRenderingHiddenByMapCommentSummary();
            bool hiddenByMapComment = mapCommentHideSummary.Length > 0;
            string menuLabel = hiddenByMapComment
                ? "\\$888" + MenuIcon() + " " + TriggerVisualizer::PluginMeta.Name + " (hidden by map)\\$z"
                : MenuTitle();

            bool toggleClicked = UI::MenuItem(menuLabel, "", TriggerVisualizer::Trigger::UI::S_RenderWorld);
            if (hiddenByMapComment) {
                UI::SetItemTooltip("Rendering is hidden by current map comment: " + mapCommentHideSummary);
            }
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
