namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            void SortVisibleTriggerVolumesByRenderPriority(
                array<TriggerVolume@> @volumes,
                array<float> @fades,
                array<uint> @indices,
                array<float> @priorityDistances
            ) {
                if (volumes is null || fades is null || indices is null || priorityDistances is null || volumes.Length <= 1) return;

                uint gap = volumes.Length / 2;
                while (gap > 0) {
                    for (uint i = gap; i < volumes.Length; i++) {
                        TriggerVolume@ volume = volumes[i];
                        float fade = fades[i];
                        uint index = indices[i];
                        float sortDistanceSq = priorityDistances[i];
                        uint j = i;

                        while (j >= gap && priorityDistances[j - gap] > sortDistanceSq) {
                            @volumes[j] = volumes[j - gap];
                            fades[j] = fades[j - gap];
                            indices[j] = indices[j - gap];
                            priorityDistances[j] = priorityDistances[j - gap];
                            j -= gap;
                        }
                        @volumes[j] = volume;
                        fades[j] = fade;
                        indices[j] = index;
                        priorityDistances[j] = sortDistanceSq;
                    }
                    gap /= 2;
                }
            }

            uint FindWorstVisibleTriggerVolumePriorityIndex(array<float> @priorityDistances) {
                if (priorityDistances is null || priorityDistances.Length == 0) return 0;

                uint worstIndex = 0;
                float worstDistance = priorityDistances[0];
                for (uint i = 1; i < priorityDistances.Length; i++) {
                    if (priorityDistances[i] > worstDistance) {
                        worstDistance = priorityDistances[i];
                        worstIndex = i;
                    }
                }
                return worstIndex;
            }

            void RenderWorld() {
                G_SpeedRenderSkipActive = false;
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
                int proximityMode = TriggerVisualizer::Trigger::UI::GetRenderProximityModeForRuntime(ctx);
                G_SpeedRenderSkipActive = ShouldSkipWorldRenderForSpeed(ctx, proximityState);
                if (G_SpeedRenderSkipActive) return;
                if (!TriggerVisualizer::Trigger::UI::S_ShowOutline && !ShouldRenderWorldFillNow() && !ShouldRenderWorldLabelsNow() && !ShouldRenderWorldTileIconsNow()) return;
                ResetWorldRenderPerformanceBudgets();
                int maxVisibleVolumeCount = TriggerVisualizer::Trigger::UI::S_MaxVisibleVolumesPerFrame;
                uint maxVisibleVolumes = uint(Math::Max(maxVisibleVolumeCount, 1));
                auto visibleVolumes = array<TriggerVolume@>();
                auto visibleFades = array<float>();
                auto visibleIndices = array<uint>();
                auto visiblePriorityDistances = array<float>();
                visibleVolumes.Reserve(maxVisibleVolumes);
                visibleFades.Reserve(maxVisibleVolumes);
                visibleIndices.Reserve(maxVisibleVolumes);
                visiblePriorityDistances.Reserve(maxVisibleVolumes);
                bool hasWorstVisiblePriority = false;
                uint worstVisiblePriorityIndex = 0;
                float worstVisiblePriorityDistance = 0.0f;

                for (uint i = 0; i < snapshot.TriggerVolumes.Length; i++) {
                    auto volume = snapshot.TriggerVolumes[i];
                    float fade = GetTriggerVolumeRenderFadeFactor(volume, cameraPos, proximityState, proximityMode);
                    if (!IsVisibleFadeFactor(fade)) continue;

                    float priorityDistance = GetTriggerVolumeRenderPriorityDistanceSq(
                        volume,
                        cameraPos,
                        proximityState,
                        proximityMode
                    );
                    if (visibleVolumes.Length < maxVisibleVolumes) {
                        visibleVolumes.InsertLast(volume);
                        visibleFades.InsertLast(fade);
                        visibleIndices.InsertLast(i);
                        visiblePriorityDistances.InsertLast(priorityDistance);
                        if (visibleVolumes.Length == maxVisibleVolumes) {
                            worstVisiblePriorityIndex = FindWorstVisibleTriggerVolumePriorityIndex(visiblePriorityDistances);
                            worstVisiblePriorityDistance = visiblePriorityDistances[worstVisiblePriorityIndex];
                            hasWorstVisiblePriority = true;
                        }
                        continue;
                    }

                    if (!hasWorstVisiblePriority) {
                        worstVisiblePriorityIndex = FindWorstVisibleTriggerVolumePriorityIndex(visiblePriorityDistances);
                        worstVisiblePriorityDistance = visiblePriorityDistances[worstVisiblePriorityIndex];
                        hasWorstVisiblePriority = true;
                    }
                    if (priorityDistance >= worstVisiblePriorityDistance) continue;

                    @visibleVolumes[worstVisiblePriorityIndex] = volume;
                    visibleFades[worstVisiblePriorityIndex] = fade;
                    visibleIndices[worstVisiblePriorityIndex] = i;
                    visiblePriorityDistances[worstVisiblePriorityIndex] = priorityDistance;
                    worstVisiblePriorityIndex = FindWorstVisibleTriggerVolumePriorityIndex(visiblePriorityDistances);
                    worstVisiblePriorityDistance = visiblePriorityDistances[worstVisiblePriorityIndex];
                }
                if (visibleVolumes.Length == 0) return;
                SortVisibleTriggerVolumesByRenderPriority(
                    visibleVolumes,
                    visibleFades,
                    visibleIndices,
                    visiblePriorityDistances
                );
                auto fillTileItems = array<WorldFillTileDrawItem@>();
                bool shouldCollectFillItems = ShouldRenderWorldFillNow() || ShouldRenderWorldTileIconsNow();
                if (shouldCollectFillItems) {
                    uint maxFrameFillItems = uint(Math::Max(GetEffectiveMaxFillTilesPerFrame(), 0));
                    for (uint i = 0; i < visibleVolumes.Length; i++) {
                        if (fillTileItems.Length >= maxFrameFillItems) break;
                        if (G_FillTileTraversalBudgetRemaining == 0) break;
                        if (visibleVolumes[i] !is null && visibleVolumes[i].HasCustomOutlineGeometry()) continue;
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

                if (TriggerVisualizer::Trigger::UI::S_ShowOutline) {
                    for (uint i = 0; i < visibleVolumes.Length; i++) {
                        if (G_WorldLineSegmentBudgetRemaining == 0) break;
                        DrawTriggerVolumeOutline(
                            visibleVolumes[i],
                            cameraPos,
                            GetOutlineColor(visibleVolumes[i], cameraPos, visibleFades[i]),
                            TriggerVisualizer::Trigger::UI::S_OutlineWidth,
                            visibleIndices[i]
                        );
                    }
                }

                for (uint i = 0; i < visibleVolumes.Length; i++) {
                    if (ShouldRenderWorldLabelsNow()) {
                        TriggerRangeRaw@ rawRange = null;
                        auto volume = visibleVolumes[i];
                        if (volume !is null && volume.Source == TRIGGER_SOURCE_OFFZONE && volume.AllowRawRangeLabel && volume.SourceIndex < snapshot.RawRanges.Length) {
                            @rawRange = snapshot.RawRanges[volume.SourceIndex];
                        }
                        DrawTriggerVolumeLabel(volume, rawRange, visibleIndices[i], cameraPos, visibleFades[i]);
                    }
                }
            }
        }
    }
}
