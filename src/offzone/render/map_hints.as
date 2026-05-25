namespace OffzoneVisualizer {
    namespace Offzone {
        namespace Render {
            bool IsWorldRenderingDisabledByMapHint(const MapSnapshot@ snapshot) {
                if (snapshot is null || snapshot.RenderHints is null) return false;
                if (snapshot.RenderHints.ForceOff) return true;
                return snapshot.RenderHints.SuggestOff && OffzoneVisualizer::Offzone::UI::S_RespectMapSuggestOff;
            }

            vec3 GetEffectiveRenderDistanceWorld() {
                vec3 distance = OffzoneVisualizer::Offzone::UI::GetRenderDistanceWorld();
                if (!OffzoneVisualizer::Offzone::UI::S_UseMapSuggestedDrawDistance) return distance;

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
