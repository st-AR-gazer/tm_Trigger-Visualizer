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
        }

        void Render() {
            if (!ShouldRenderWorld()) return;
            TriggerVisualizer::Trigger::RenderWorld();
        }

        bool ShouldRenderWithUiVisibility(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            bool isEditorContext = ctx !is null && ctx.IsInEditor;
            if (S_HideWithGame && !isEditorContext && !UI::IsGameUIVisible()) return false;
            if (S_HideWithOP && !UI::IsOverlayShown()) return false;
            return true;
        }

        bool ShouldRenderWithUiVisibility() {
            return ShouldRenderWithUiVisibility(TriggerVisualizer::Trigger::Data::GetRuntimeContext());
        }

        bool ShouldSkipWorldRenderForFastViewedCar(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            if (!TriggerVisualizer::Trigger::UI::S_FastDrivingPerformanceMode) return false;
            if (ctx is null || (!ctx.IsPlayableMap && !ctx.IsEditorTestMode)) return false;
            if (!TriggerVisualizer::Trigger::UI::ShouldSpeedRenderSkipHideAllRuntimeSources(ctx)) return false;

            auto proximityState = TriggerVisualizer::Trigger::Data::GetProximityReferenceState(ctx);
            TriggerVisualizer::Trigger::Render::UpdateSpeedRenderSkipActiveForSpeed(ctx, proximityState);
            return TriggerVisualizer::Trigger::Render::ShouldSkipWorldRenderForSpeed(ctx, proximityState);
        }

        bool ShouldRenderWorld() {
            auto ctx = TriggerVisualizer::Trigger::Data::GetRuntimeContext();
            if (!TriggerVisualizer::Trigger::UI::IsRenderWorldEnabledForRuntime(ctx)) return false;
            if (!ShouldRenderWithUiVisibility(ctx)) return false;
            if (ShouldSkipWorldRenderForFastViewedCar(ctx)) return false;
            return true;
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
            UI::End();
            PopPluginButtonStyleUI();
            S_DevPanelOpen = devPanelOpen;
        }

        bool IsRenderMenuShiftHeld() {
            return UI::IsKeyDown(UI::Key::ModShift)
                || UI::IsKeyDown(UI::Key::LeftShift)
                || UI::IsKeyDown(UI::Key::RightShift);
        }

        bool RenderSubmenuSelectable(const string &in label, bool checked = false) {
            int flags = UI::SelectableFlags::NoAutoClosePopups | UI::SelectableFlags::SpanAllColumns;
            string displayLabel = checked ? "\\$5df" + Icons::Check + " " + label + "\\$z" : label;
            bool clicked = UI::Selectable(displayLabel + "##" + label, false, flags);
            if (clicked && !IsRenderMenuShiftHeld()) {
                UI::CloseCurrentPopup();
            }
            return clicked;
        }

        bool RenderGlobalSourceMenuItem(
            const string &in label,
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            int source
        ) {
            int context = TriggerVisualizer::Trigger::UI::GetSourceSettingsContextForRuntime(ctx);
            bool enabled = false;
            if (source == TriggerVisualizer::Trigger::TRIGGER_SOURCE_OFFZONE) {
                enabled = TriggerVisualizer::Trigger::UI::IsOffzoneSourceEnabledForContext(context);
            } else if (source == TriggerVisualizer::Trigger::TRIGGER_SOURCE_MEDIATRACKER) {
                enabled = TriggerVisualizer::Trigger::UI::IsMediaTrackerSourceEnabledForContext(context);
            } else if (source == TriggerVisualizer::Trigger::TRIGGER_SOURCE_CRYSTAL) {
                enabled = TriggerVisualizer::Trigger::UI::IsCrystalSourceEnabledForContext(context);
            }
            if (!RenderSubmenuSelectable(label, enabled)) return false;

            bool next = !enabled;
            if (source == TriggerVisualizer::Trigger::TRIGGER_SOURCE_OFFZONE) {
                TriggerVisualizer::Trigger::UI::SetOffzoneSourceEnabledForContext(context, next);
            } else if (source == TriggerVisualizer::Trigger::TRIGGER_SOURCE_MEDIATRACKER) {
                TriggerVisualizer::Trigger::UI::SetMediaTrackerSourceEnabledForContext(context, next);
            } else if (source == TriggerVisualizer::Trigger::TRIGGER_SOURCE_CRYSTAL) {
                TriggerVisualizer::Trigger::UI::SetCrystalSourceEnabledForContext(context, next);
            }
            return true;
        }

        string MapOverrideStateSuffix(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            const string &in key
        ) {
            bool value = false;
            if (!TriggerVisualizer::Trigger::UI::TryGetMapOnlyOverride(ctx, key, value)) {
                return "\\$888 (global)\\$z";
            }
            return value ? "\\$8f8 (show)\\$z" : "\\$f88 (hide)\\$z";
        }

        void RenderMapOnlyOverrideMenu(
            const string &in label,
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            const string &in key
        ) {
            bool canUseMap = TriggerVisualizer::Trigger::UI::GetMapOnlyOverrideMapKey(ctx).Length > 0;
            bool value = false;
            bool hasOverride = TriggerVisualizer::Trigger::UI::TryGetMapOnlyOverride(ctx, key, value);
            string menuLabel = label + " " + MapOverrideStateSuffix(ctx, key);
            if (!canUseMap) UI::BeginDisabled();
            if (UI::BeginMenu(menuLabel + "###trigger-visualizer-map-override-" + key)) {
                if (RenderSubmenuSelectable("Use global setting", !hasOverride)) {
                    TriggerVisualizer::Trigger::UI::ClearMapOnlyOverride(ctx, key);
                }
                if (RenderSubmenuSelectable("Show on this map", hasOverride && value)) {
                    TriggerVisualizer::Trigger::UI::SetMapOnlyOverride(ctx, key, true);
                }
                if (RenderSubmenuSelectable("Hide on this map", hasOverride && !value)) {
                    TriggerVisualizer::Trigger::UI::SetMapOnlyOverride(ctx, key, false);
                }
                UI::EndMenu();
            }
            if (!canUseMap) UI::EndDisabled();
        }

        void RenderMapOnlySourceOverrideMenu(
            const string &in label,
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            int source
        ) {
            RenderMapOnlyOverrideMenu(
                label,
                ctx,
                TriggerVisualizer::Trigger::UI::GetMapOnlySourceOverrideKey(source)
            );
        }

        void RenderGlobalRenderMenuOptions(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            int context = TriggerVisualizer::Trigger::UI::GetSourceSettingsContextForRuntime(ctx);
            string contextLabel = TriggerVisualizer::Trigger::UI::GetSourceSettingsContextLabel(context);
            UI::TextDisabled("Global");
            if (RenderSubmenuSelectable("Trigger rendering", TriggerVisualizer::Trigger::UI::S_RenderWorld)) {
                TriggerVisualizer::Trigger::UI::S_RenderWorld = !TriggerVisualizer::Trigger::UI::S_RenderWorld;
            }
            UI::Separator();
            UI::TextDisabled("Sources (" + contextLabel + ")");
            RenderGlobalSourceMenuItem("Offzone", ctx, TriggerVisualizer::Trigger::TRIGGER_SOURCE_OFFZONE);
            RenderGlobalSourceMenuItem("MediaTracker", ctx, TriggerVisualizer::Trigger::TRIGGER_SOURCE_MEDIATRACKER);
            UI::BeginDisabled(TriggerVisualizer::Trigger::UI::S_CrystalCustomItemsAndBlockItemsOnly);
            RenderGlobalSourceMenuItem("Crystal", ctx, TriggerVisualizer::Trigger::TRIGGER_SOURCE_CRYSTAL);
            UI::EndDisabled();
            if (RenderSubmenuSelectable("Crystal (only custom)", TriggerVisualizer::Trigger::UI::S_CrystalCustomItemsAndBlockItemsOnly)) {
                TriggerVisualizer::Trigger::UI::SetCrystalCustomItemsAndBlockItemsOnly(!TriggerVisualizer::Trigger::UI::S_CrystalCustomItemsAndBlockItemsOnly);
            }
        }

        void RenderMapOnlyRenderMenuOptions(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            bool canUseMap = TriggerVisualizer::Trigger::UI::GetMapOnlyOverrideMapKey(ctx).Length > 0;
            UI::TextDisabled("This map");
            if (!canUseMap) {
                UI::TextDisabled("No MapUid available.");
                return;
            }

            RenderMapOnlyOverrideMenu(
                "Trigger rendering",
                ctx,
                TriggerVisualizer::Trigger::UI::MAP_ONLY_OVERRIDE_RENDER_WORLD
            );
            UI::Separator();
            RenderMapOnlySourceOverrideMenu(
                "Offzone",
                ctx,
                TriggerVisualizer::Trigger::TRIGGER_SOURCE_OFFZONE
            );
            RenderMapOnlySourceOverrideMenu(
                "MediaTracker",
                ctx,
                TriggerVisualizer::Trigger::TRIGGER_SOURCE_MEDIATRACKER
            );
            RenderMapOnlySourceOverrideMenu(
                "Crystal",
                ctx,
                TriggerVisualizer::Trigger::TRIGGER_SOURCE_CRYSTAL
            );
            RenderMapOnlyOverrideMenu(
                "Crystal (only custom)",
                ctx,
                TriggerVisualizer::Trigger::UI::MAP_ONLY_OVERRIDE_CRYSTAL_CUSTOM_ONLY
            );
            UI::Separator();
            if (RenderSubmenuSelectable("Clear map overrides")) {
                TriggerVisualizer::Trigger::UI::ClearCurrentMapOnlyOverrides(ctx);
            }
        }

        void RenderMenuOptions(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            RenderGlobalRenderMenuOptions(ctx);
            UI::Separator();
            RenderMapOnlyRenderMenuOptions(ctx);
            UI::Separator();
            if (RenderSubmenuSelectable("Open settings")) {
                Meta::OpenSettings(TriggerVisualizer::PluginMeta);
            }
        }

        string RenderMenuRootTitle(bool hiddenByMapComment) {
            return hiddenByMapComment ?
                "\\$888" + MenuIcon() + " " + TriggerVisualizer::PluginMeta.Name + " (hidden by map)\\$z" : MenuTitle();
        }

        void RenderMenuRootCheck(
            UI::DrawList@ parentDrawList,
            const vec4 &in rowRect,
            float contentRight
        ) {
            if (!TriggerVisualizer::Trigger::UI::S_RenderWorld) return;

            vec2 checkSize = UI::MeasureString(Icons::Check);
            float arrowWidth = UI::GetTextLineHeight();
            float spacing = UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing).x;
            float rowHeight = rowRect.w - rowRect.y;
            float opticalOffsetY = 4.0f * UI::GetScale();
            vec2 checkPos = vec2(
                contentRight - arrowWidth - spacing * 0.35f - checkSize.x,
                rowRect.y + Math::Max((rowHeight - checkSize.y) * 0.5f, 0.0f) + opticalOffsetY
            );
            parentDrawList.AddText(checkPos, vec4(1.0f, 1.0f, 1.0f, 1.0f), Icons::Check);
        }

        void RenderMenu() {
            auto ctx = TriggerVisualizer::Trigger::Data::GetRuntimeContext();
            string mapCommentHideSummary = TriggerVisualizer::Trigger::GetWorldRenderingHiddenByMapCommentSummary();
            bool hiddenByMapComment = mapCommentHideSummary.Length > 0;
            vec2 rowStart = UI::GetCursorScreenPos();
            float contentRight = rowStart.x + UI::GetContentRegionAvail().x;
            UI::DrawList@ parentDrawList = UI::GetWindowDrawList();
            bool menuOpen = UI::BeginMenu(RenderMenuRootTitle(hiddenByMapComment) + "##trigger-visualizer-render-menu-root");
            bool toggleClicked = UI::IsItemClicked(UI::MouseButton::Left);
            bool settingsClicked = UI::IsItemClicked(UI::MouseButton::Right);
            vec4 rowRect = UI::GetItemRect();
            if (hiddenByMapComment) {
                UI::SetItemTooltip("Rendering is hidden by current map comment: " + mapCommentHideSummary);
            }
            if (settingsClicked) {
                Meta::OpenSettings(TriggerVisualizer::PluginMeta);
            }
            bool closeRenderMenu = toggleClicked && !IsRenderMenuShiftHeld();
            if (toggleClicked) {
                TriggerVisualizer::Trigger::UI::S_RenderWorld = !TriggerVisualizer::Trigger::UI::S_RenderWorld;
            }
            RenderMenuRootCheck(parentDrawList, rowRect, contentRight);
            if (menuOpen) {
                RenderMenuOptions(ctx);
                UI::EndMenu();
            }
            if (closeRenderMenu) {
                UI::CloseCurrentPopup();
            }
        }

        void RenderWindow() {
            UI::Text(TriggerVisualizer::PluginMeta.Name + " " + TriggerVisualizer::PluginMeta.Version);
            UI::Separator();
            TriggerVisualizer::Trigger::RenderDevPanel();
        }
    }
}
