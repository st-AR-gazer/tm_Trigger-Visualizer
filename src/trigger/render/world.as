namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            float GetTriggerVolumeSortDistanceSq(const TriggerVolume@ volume, const vec3 &in cameraPos) {
                if (volume is null) return 0.0f;
                return Math::Distance2(cameraPos, volume.Center());
            }

            void SortVisibleTriggerVolumesBackToFront(
                array<TriggerVolume@> @volumes,
                array<float> @fades,
                array<uint> @indices,
                const vec3 &in cameraPos
            ) {
                if (volumes is null || fades is null || indices is null || volumes.Length <= 1) return;

                uint gap = volumes.Length / 2;
                while (gap > 0) {
                    for (uint i = gap; i < volumes.Length; i++) {
                        TriggerVolume@ volume = volumes[i];
                        float fade = fades[i];
                        uint index = indices[i];
                        float sortDistanceSq = GetTriggerVolumeSortDistanceSq(volume, cameraPos);
                        uint j = i;

                        while (j >= gap && GetTriggerVolumeSortDistanceSq(volumes[j - gap], cameraPos) < sortDistanceSq) {
                            @volumes[j] = volumes[j - gap];
                            fades[j] = fades[j - gap];
                            indices[j] = indices[j - gap];
                            j -= gap;
                        }

                        @volumes[j] = volume;
                        fades[j] = fade;
                        indices[j] = index;
                    }

                    gap /= 2;
                }
            }

            void RenderWorld() {
                G_FastDrivingPerformanceModeActive = false;
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
                G_FastDrivingPerformanceModeActive = ShouldUseFastDrivingPerformanceMode(ctx, proximityState);
                if (!TriggerVisualizer::Trigger::UI::S_ShowOutline && !ShouldRenderWorldFillNow() && !ShouldRenderWorldLabelsNow() && !ShouldRenderWorldTileIconsNow()) return;
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
                SortVisibleTriggerVolumesBackToFront(visibleVolumes, visibleFades, visibleIndices, cameraPos);
                int fastMaxVisibleVolumes = Math::Max(TriggerVisualizer::Trigger::UI::S_FastDrivingMaxVisibleVolumes, 1);
                if (IsFastDrivingPerformanceModeActive() && int(visibleVolumes.Length) > fastMaxVisibleVolumes) {
                    auto trimmedVolumes = array<TriggerVolume@>();
                    auto trimmedFades = array<float>();
                    auto trimmedIndices = array<uint>();
                    uint firstKept = visibleVolumes.Length - uint(fastMaxVisibleVolumes);
                    for (uint i = firstKept; i < visibleVolumes.Length; i++) {
                        trimmedVolumes.InsertLast(visibleVolumes[i]);
                        trimmedFades.InsertLast(visibleFades[i]);
                        trimmedIndices.InsertLast(visibleIndices[i]);
                    }
                    visibleVolumes = trimmedVolumes;
                    visibleFades = trimmedFades;
                    visibleIndices = trimmedIndices;
                }

                auto fillTileItems = array<WorldFillTileDrawItem@>();
                bool shouldCollectFillItems = ShouldRenderWorldFillNow() || ShouldRenderWorldTileIconsNow();
                if (shouldCollectFillItems) {
                    uint maxFrameFillItems = uint(Math::Max(GetEffectiveMaxFillTilesPerFrame(), 0));
                    for (uint i = 0; i < visibleVolumes.Length; i++) {
                        if (fillTileItems.Length >= maxFrameFillItems) break;
                        if (G_FillTileTraversalBudgetRemaining == 0) break;
                        vec4 fillColor = ShouldRenderWorldFillNow() ?
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

                    if (ShouldRenderWorldLabelsNow()) {
                        TriggerRangeRaw@ rawRange = null;
                        auto volume = visibleVolumes[i];
                        if (
                            volume !is null
                            && volume.Source == TRIGGER_SOURCE_OFFZONE
                            && volume.AllowRawRangeLabel
                            && volume.SourceIndex < snapshot.RawRanges.Length
                        ) {
                            @rawRange = snapshot.RawRanges[volume.SourceIndex];
                        }
                        DrawTriggerVolumeLabel(
                            volume,
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
