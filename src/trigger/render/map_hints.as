namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            bool IsWorldRenderingDisabledByMapHint(const MapSnapshot@ snapshot) {
                if (snapshot is null || snapshot.RenderHints is null) return false;
                if (snapshot.RenderHints.ForceOff) return true;
                return snapshot.RenderHints.SuggestOff && TriggerVisualizer::Trigger::UI::S_RespectMapSuggestOff;
            }

            vec3 GetEffectiveRenderDistanceWorld() {
                vec3 distance = TriggerVisualizer::Trigger::UI::GetRenderDistanceWorld();
                if (!TriggerVisualizer::Trigger::UI::S_UseMapSuggestedDrawDistance) return distance;

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
