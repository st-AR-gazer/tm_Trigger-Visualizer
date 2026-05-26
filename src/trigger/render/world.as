namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            void RenderWorld() {
                if (!TriggerVisualizer::Trigger::UI::S_RenderWorld) return;
                if (!TriggerVisualizer::Trigger::UI::S_ShowOutline && !TriggerVisualizer::Trigger::UI::S_ShowFill && !TriggerVisualizer::Trigger::UI::S_ShowLabels && !TriggerVisualizer::Trigger::UI::S_ShowSkullTileIcons) return;

                auto ctx = GetCurrentRuntimeContext();
                auto snapshot = GetCurrentMapSnapshot();
                if (ctx is null || snapshot is null) return;
                if (!ctx.HasMap) return;
                if (IsWorldRenderingDisabledByMapHint(snapshot)) return;
                if (snapshot.TriggerVolumes.Length == 0) return;

                vec3 cameraPos = Camera::GetCurrentPosition();
                auto playerState = TriggerVisualizer::Trigger::Data::GetPlayerPositionState();
                ResetWorldRenderPerformanceBudgets();

                auto fillTileItems = array<WorldFillTileDrawItem@>();
                for (uint i = 0; i < snapshot.TriggerVolumes.Length; i++) {
                    float fade = GetTriggerVolumeRenderFadeFactor(snapshot.TriggerVolumes[i], cameraPos, playerState);
                    if (!IsVisibleFadeFactor(fade)) continue;

                    if (TriggerVisualizer::Trigger::UI::S_ShowFill || TriggerVisualizer::Trigger::UI::S_ShowSkullTileIcons) {
                        vec4 fillColor = TriggerVisualizer::Trigger::UI::S_ShowFill ?
                        GetFillColor(snapshot.TriggerVolumes[i], cameraPos, fade) : vec4();
                        CollectTriggerVolumeFillDrawItems(
                            snapshot.TriggerVolumes[i],
                            cameraPos,
                            fillColor,
                            i,
                            fillTileItems
                        );
                    }
                }

                DrawWorldFillTileDrawItems(fillTileItems);

                for (uint i = 0; i < snapshot.TriggerVolumes.Length; i++) {
                    float fade = GetTriggerVolumeRenderFadeFactor(snapshot.TriggerVolumes[i], cameraPos, playerState);
                    if (!IsVisibleFadeFactor(fade)) continue;

                    if (TriggerVisualizer::Trigger::UI::S_ShowOutline) {
                        DrawTriggerVolumeOutline(
                            snapshot.TriggerVolumes[i],
                            cameraPos,
                            GetOutlineColor(snapshot.TriggerVolumes[i], cameraPos, fade),
                            TriggerVisualizer::Trigger::UI::S_OutlineWidth,
                            i
                        );
                    }

                    if (TriggerVisualizer::Trigger::UI::S_ShowLabels) {
                        TriggerRangeRaw@ rawRange = null;
                        if (i < snapshot.RawRanges.Length) {
                            @rawRange = snapshot.RawRanges[i];
                        }
                        DrawTriggerVolumeLabel(snapshot.TriggerVolumes[i], rawRange, i, cameraPos, fade);
                    }
                }
            }
        }
    }
}
