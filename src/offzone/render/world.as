namespace OffzoneVisualizer {
    namespace Offzone {
        namespace Render {
            void RenderWorld() {
                if (!OffzoneVisualizer::Offzone::UI::S_RenderWorld) return;
                if (!OffzoneVisualizer::Offzone::UI::S_ShowOutline) return;

                auto ctx = GetCurrentRuntimeContext();
                auto snapshot = GetCurrentMapSnapshot();
                if (ctx is null || snapshot is null) return;
                if (!ctx.IsPlayableMap) return;
                if (snapshot.WorldBoxes.Length == 0) return;

                vec3 cameraPos = Camera::GetCurrentPosition();
                for (uint i = 0; i < snapshot.WorldBoxes.Length; i++) {
                    float fade = GetWorldBoxFadeFactor(snapshot.WorldBoxes[i], cameraPos);
                    if (!IsVisibleFadeFactor(fade)) continue;

                    vec4 outlineColor = GetOutlineColor(snapshot.WorldBoxes[i], cameraPos, fade);
                    DrawWorldBoxOutline(snapshot.WorldBoxes[i], cameraPos, outlineColor);
                }
            }
        }
    }
}
