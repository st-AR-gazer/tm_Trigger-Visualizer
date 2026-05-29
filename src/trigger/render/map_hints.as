namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            const float UNLIMITED_RENDER_DISTANCE_WORLD = 1000000000.0f;

            bool IsWorldRenderingDisabledByMapHint(const MapSnapshot@ snapshot) {
                if (snapshot is null || snapshot.RenderHints is null) return false;
                if (snapshot.RenderHints.ForceOff) return true;
                return snapshot.RenderHints.SuggestOff && TriggerVisualizer::Trigger::UI::S_RespectMapSuggestOff;
            }

            vec3 GetEffectiveRenderDistanceWorld() {
                auto ctx = GetCurrentRuntimeContext();
                if (TriggerVisualizer::Trigger::UI::IsUnlimitedRenderDistanceForRuntime(ctx)) {
                    return vec3(
                        UNLIMITED_RENDER_DISTANCE_WORLD,
                        UNLIMITED_RENDER_DISTANCE_WORLD,
                        UNLIMITED_RENDER_DISTANCE_WORLD
                    );
                }

                vec3 distance = TriggerVisualizer::Trigger::UI::GetRenderDistanceWorldForRuntime(ctx);
                if (!TriggerVisualizer::Trigger::UI::UseMapSuggestedDrawDistanceForRuntime(ctx)) return distance;

                auto snapshot = GetCurrentMapSnapshot();
                if (snapshot is null || snapshot.RenderHints is null) return distance;

                if (snapshot.RenderHints.HasSuggestedDrawDistanceXZ) {
                    distance.x = snapshot.RenderHints.SuggestedDrawDistanceXZ;
                    distance.z = snapshot.RenderHints.SuggestedDrawDistanceXZ;
                }

                if (snapshot.RenderHints.HasSuggestedDrawDistanceY) {
                    distance.y = snapshot.RenderHints.SuggestedDrawDistanceY;
                }

                return distance;
            }
        }
    }
}
