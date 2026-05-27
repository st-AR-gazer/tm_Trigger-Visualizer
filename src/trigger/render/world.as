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
                auto proximityState = TriggerVisualizer::Trigger::Data::GetProximityReferenceState(ctx);
                ResetWorldRenderPerformanceBudgets();

                auto visibleVolumes = array<TriggerVolume@>();
                auto visibleFades = array<float>();
                auto visibleIndices = array<uint>();
                visibleVolumes.Reserve(snapshot.TriggerVolumes.Length);
                visibleFades.Reserve(snapshot.TriggerVolumes.Length);
                visibleIndices.Reserve(snapshot.TriggerVolumes.Length);

                for (uint i = 0; i < snapshot.TriggerVolumes.Length; i++) {
                    auto volume = snapshot.TriggerVolumes[i];
                    float fade = GetTriggerVolumeRenderFadeFactor(volume, cameraPos, proximityState);
                    if (!IsVisibleFadeFactor(fade)) continue;

                    visibleVolumes.InsertLast(volume);
                    visibleFades.InsertLast(fade);
                    visibleIndices.InsertLast(i);
                }

                if (visibleVolumes.Length == 0) return;

                auto fillTileItems = array<WorldFillTileDrawItem@>();
                bool shouldCollectFillItems = TriggerVisualizer::Trigger::UI::S_ShowFill || TriggerVisualizer::Trigger::UI::S_ShowSkullTileIcons;
                if (shouldCollectFillItems) {
                    for (uint i = 0; i < visibleVolumes.Length; i++) {
                        vec4 fillColor = TriggerVisualizer::Trigger::UI::S_ShowFill ?
                        GetFillColor(visibleVolumes[i], cameraPos, visibleFades[i]) : vec4();
                        CollectTriggerVolumeFillDrawItems(
                            visibleVolumes[i],
                            cameraPos,
                            fillColor,
                            visibleIndices[i],
                            fillTileItems
                        );
                    }
                }

                DrawWorldFillTileDrawItems(fillTileItems);

                for (uint i = 0; i < visibleVolumes.Length; i++) {
                    if (TriggerVisualizer::Trigger::UI::S_ShowOutline) {
                        DrawTriggerVolumeOutline(
                            visibleVolumes[i],
                            cameraPos,
                            GetOutlineColor(visibleVolumes[i], cameraPos, visibleFades[i]),
                            TriggerVisualizer::Trigger::UI::S_OutlineWidth,
                            visibleIndices[i]
                        );
                    }

                    if (TriggerVisualizer::Trigger::UI::S_ShowLabels) {
                        TriggerRangeRaw@ rawRange = null;
                        uint sourceIndex = visibleIndices[i];
                        if (sourceIndex < snapshot.RawRanges.Length) {
                            @rawRange = snapshot.RawRanges[sourceIndex];
                        }
                        DrawTriggerVolumeLabel(
                            visibleVolumes[i],
                            rawRange,
                            visibleIndices[i],
                            cameraPos,
                            visibleFades[i]
                        );
                    }
                }
            }
        }
    }
}
