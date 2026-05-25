namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            class RuntimeContext {
                CGameCtnApp@ App;
                CGameCtnChallenge@ RootMap;
                CGamePlayground@ Playground;
                bool HasMap = false;
                bool HasPlayground = false;
                bool IsInEditor = false;
                bool IsPlayableMap = false;
                bool IsInMenu = false;
                string MapUid;

                bool HasMapUid() const {
                    return MapUid.Length > 0;
                }

                string StateLabel() const {
                    if (IsPlayableMap) return "Playable Map";
                    if (IsInEditor) return "Editor";
                    if (IsInMenu) return "Menu / No Playground";
                    if (HasPlayground && !HasMap) return "Playground / No Map";
                    if (HasMap && !HasPlayground) return "Map Loaded / No Playground";
                    return "Unknown";
                }
            }

            string GetMapUid(CGameCtnChallenge@ map) {
                if (map is null || map.MapInfo is null) return "";
                return map.MapInfo.MapUid;
            }

            RuntimeContext@ GetRuntimeContext() {
                auto app = GetApp();
                auto ctx = RuntimeContext();

                @ctx.App = app;
                @ctx.RootMap = cast<CGameCtnChallenge>(app.RootMap);
                @ctx.Playground = app.CurrentPlayground;
                ctx.HasMap = ctx.RootMap !is null;
                ctx.HasPlayground = ctx.Playground !is null;
                ctx.IsInEditor = app.Editor !is null;
                ctx.MapUid = GetMapUid(ctx.RootMap);

                ctx.IsPlayableMap = ctx.HasMap && ctx.HasPlayground && !ctx.IsInEditor;
                ctx.IsInMenu = !ctx.IsInEditor && !ctx.HasPlayground;

                return ctx;
            }
        }
    }
}
