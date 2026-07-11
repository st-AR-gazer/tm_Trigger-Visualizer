namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            class VisibleTriggerVolumeSelection {
                array<TriggerVolume@> Volumes;
                array<float> Fades;
                array<uint> Indices;

                void Reserve(uint count) {
                    Volumes.Reserve(count);
                    Fades.Reserve(count);
                    Indices.Reserve(count);
                }
            }

            void ConsiderVisibleTriggerVolumeCandidate(
                MapSnapshot@ snapshot,
                uint volumeIndex,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState,
                int proximityMode,
                VisibleTriggerVolumeSelection@ selection
            ) {
                if (snapshot is null || selection is null || volumeIndex >= snapshot.TriggerVolumes.Length) return;

                auto volume = snapshot.TriggerVolumes[volumeIndex];
                if (ShouldSkipTriggerVolumeForSpeed(volume, g_SpeedRenderSkipActive)) return;
                float fade = GetTriggerVolumeRenderFadeFactor(volume, cameraPos, proximityState, proximityMode);
                if (!IsVisibleFadeFactor(fade)) return;

                selection.Volumes.InsertLast(volume);
                selection.Fades.InsertLast(fade);
                selection.Indices.InsertLast(volumeIndex);
            }

            void RenderWorld() {
                auto ctx = GetCurrentRuntimeContext();
                if (!TriggerVisualizer::Trigger::Ui::IsRenderWorldEnabledForRuntime(ctx)) return;
                if (!TriggerVisualizer::Trigger::Ui::S_ShowOutline && !TriggerVisualizer::Trigger::Ui::S_ShowFill && !TriggerVisualizer::Trigger::Ui::S_ShowLabels && !TriggerVisualizer::Trigger::Ui::S_ShowSkullTileIcons) return;

                auto snapshot = GetCurrentMapSnapshot();
                if (ctx is null || snapshot is null) return;
                if (!ctx.HasMap) return;
                if (IsWorldRenderingDisabledByMapHint(snapshot)) return;
                if (snapshot.TriggerVolumes.Length == 0) return;

                vec3 cameraPos = Camera::GetCurrentPosition();
                auto proximityState = TriggerVisualizer::Trigger::Data::GetProximityReferenceState(ctx);
                int proximityMode = TriggerVisualizer::Trigger::Ui::GetRenderProximityModeForRuntime(ctx);
                g_SpeedRenderSkipActive = UpdateSpeedRenderSkipActiveForSpeed(ctx, proximityState);
                if (ShouldSkipWorldRenderForSpeed(ctx, proximityState)) return;
                if (!TriggerVisualizer::Trigger::Ui::S_ShowOutline && !ShouldRenderWorldFillNow() && !ShouldRenderWorldLabelsNow() && !ShouldRenderWorldTileIconsNow()) return;
                PrepareWorldRenderFrame();
                auto selection = VisibleTriggerVolumeSelection();
                selection.Reserve(snapshot.TriggerVolumes.Length);
                auto candidateIndices = array<uint>();
                if (TryCollectSpatialTriggerVolumeCandidateIndices(snapshot, cameraPos, proximityState, proximityMode, candidateIndices)) {
                    for (uint i = 0; i < candidateIndices.Length; i++) {
                        ConsiderVisibleTriggerVolumeCandidate(
                            snapshot,
                            candidateIndices[i],
                            cameraPos,
                            proximityState,
                            proximityMode,
                            selection
                        );
                    }
                } else {
                    for (uint i = 0; i < snapshot.TriggerVolumes.Length; i++) {
                        ConsiderVisibleTriggerVolumeCandidate(
                            snapshot,
                            i,
                            cameraPos,
                            proximityState,
                            proximityMode,
                            selection
                        );
                    }
                }
                if (selection.Volumes.Length == 0) return;
                auto fillTileItems = array<WorldFillTileDrawItem@>();
                auto tileIconItems = array<WorldTileIconDrawItem@>();
                bool shouldCollectFillItems = ShouldRenderWorldFillNow() || ShouldRepeatTileIconsOnSplitFillTilesNow();
                bool shouldCollectTileIcons = ShouldCollectTileIconsSeparatelyNow();
                if (shouldCollectFillItems) {
                    uint maxFrameFillItems = uint(GetFillTileFrameSafetyLimit());
                    for (uint i = 0; i < selection.Volumes.Length; i++) {
                        if (fillTileItems.Length >= maxFrameFillItems) break;
                        if (selection.Volumes[i] !is null && selection.Volumes[i].HasCustomOutlineGeometry()) continue;
                        vec4 fillColor = ShouldRenderWorldFillNow() ?
                            GetFillColor(selection.Volumes[i], cameraPos, selection.Fades[i]) : vec4();
                        CollectTriggerVolumeFillDrawItems(
                            selection.Volumes[i],
                            cameraPos,
                            fillColor,
                            selection.Indices[i],
                            fillTileItems
                        );
                    }
                }
                if (shouldCollectTileIcons) {
                    for (uint i = 0; i < selection.Volumes.Length; i++) {
                        CollectTriggerVolumeTileIconDrawItems(
                            selection.Volumes[i],
                            cameraPos,
                            tileIconItems
                        );
                    }
                }
                DrawWorldFillTileDrawItems(fillTileItems);
                DrawWorldTileIconDrawItems(tileIconItems);

                if (TriggerVisualizer::Trigger::Ui::S_ShowOutline) {
                    for (uint i = 0; i < selection.Volumes.Length; i++) {
                        DrawTriggerVolumeOutline(
                            selection.Volumes[i],
                            cameraPos,
                            GetOutlineColor(selection.Volumes[i], cameraPos, selection.Fades[i]),
                            TriggerVisualizer::Trigger::Ui::S_OutlineWidth,
                            selection.Indices[i]
                        );
                    }
                }

                if (ShouldRenderWorldLabelsNow()) {
                    for (uint i = 0; i < selection.Volumes.Length; i++) {
                        TriggerRangeRaw@ rawRange = null;
                        auto volume = selection.Volumes[i];
                        if (volume !is null && volume.Source == TRIGGER_SOURCE_OFFZONE && volume.AllowRawRangeLabel && volume.SourceIndex < snapshot.RawRanges.Length) {
                            @rawRange = snapshot.RawRanges[volume.SourceIndex];
                        }
                        DrawTriggerVolumeLabel(volume, rawRange, selection.Indices[i], cameraPos, selection.Fades[i]);
                    }
                }
            }
        }
    }
}
