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

            class VisibleTriggerVolumeSelection {
                array<TriggerVolume@> Volumes;
                array<float> Fades;
                array<uint> Indices;
                array<float> PriorityDistances;
                bool HasWorstPriority = false;
                uint WorstPriorityIndex = 0;
                float WorstPriorityDistance = 0.0f;

                void Reserve(uint count) {
                    Volumes.Reserve(count);
                    Fades.Reserve(count);
                    Indices.Reserve(count);
                    PriorityDistances.Reserve(count);
                }
            }

            void ConsiderVisibleTriggerVolumeCandidate(
                MapSnapshot@ snapshot,
                uint volumeIndex,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState,
                int proximityMode,
                uint maxVisibleVolumes,
                VisibleTriggerVolumeSelection@ selection
            ) {
                if (snapshot is null || selection is null || volumeIndex >= snapshot.TriggerVolumes.Length) return;

                auto volume = snapshot.TriggerVolumes[volumeIndex];
                if (ShouldSkipTriggerVolumeForSpeed(volume, G_SpeedRenderSkipActive)) return;
                float fade = GetTriggerVolumeRenderFadeFactor(volume, cameraPos, proximityState, proximityMode);
                if (!IsVisibleFadeFactor(fade)) return;

                float priorityDistance = GetTriggerVolumeRenderPriorityDistanceSq(
                    volume,
                    cameraPos,
                    proximityState,
                    proximityMode
                );
                if (selection.Volumes.Length < maxVisibleVolumes) {
                    selection.Volumes.InsertLast(volume);
                    selection.Fades.InsertLast(fade);
                    selection.Indices.InsertLast(volumeIndex);
                    selection.PriorityDistances.InsertLast(priorityDistance);
                    if (selection.Volumes.Length == maxVisibleVolumes) {
                        selection.WorstPriorityIndex = FindWorstVisibleTriggerVolumePriorityIndex(selection.PriorityDistances);
                        selection.WorstPriorityDistance = selection.PriorityDistances[selection.WorstPriorityIndex];
                        selection.HasWorstPriority = true;
                    }
                    return;
                }

                if (!selection.HasWorstPriority) {
                    selection.WorstPriorityIndex = FindWorstVisibleTriggerVolumePriorityIndex(selection.PriorityDistances);
                    selection.WorstPriorityDistance = selection.PriorityDistances[selection.WorstPriorityIndex];
                    selection.HasWorstPriority = true;
                }
                if (priorityDistance >= selection.WorstPriorityDistance) return;

                @selection.Volumes[selection.WorstPriorityIndex] = volume;
                selection.Fades[selection.WorstPriorityIndex] = fade;
                selection.Indices[selection.WorstPriorityIndex] = volumeIndex;
                selection.PriorityDistances[selection.WorstPriorityIndex] = priorityDistance;
                selection.WorstPriorityIndex = FindWorstVisibleTriggerVolumePriorityIndex(selection.PriorityDistances);
                selection.WorstPriorityDistance = selection.PriorityDistances[selection.WorstPriorityIndex];
            }

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
                int proximityMode = TriggerVisualizer::Trigger::UI::GetRenderProximityModeForRuntime(ctx);
                G_SpeedRenderSkipActive = UpdateSpeedRenderSkipActiveForSpeed(ctx, proximityState);
                if (ShouldSkipWorldRenderForSpeed(ctx, proximityState)) return;
                if (!TriggerVisualizer::Trigger::UI::S_ShowOutline && !ShouldRenderWorldFillNow() && !ShouldRenderWorldLabelsNow() && !ShouldRenderWorldTileIconsNow()) return;
                ResetWorldRenderPerformanceBudgets();
                int maxVisibleVolumeCount = TriggerVisualizer::Trigger::UI::S_MaxVisibleVolumesPerFrame;
                uint maxVisibleVolumes = uint(Math::Max(maxVisibleVolumeCount, 1));
                if (IsSpatialCandidateQueryUnlimited(GetEffectiveRenderDistanceWorld())) {
                    maxVisibleVolumes = Math::Max(snapshot.TriggerVolumes.Length, 1);
                }
                auto selection = VisibleTriggerVolumeSelection();
                selection.Reserve(maxVisibleVolumes);
                auto candidateIndices = array<uint>();
                if (TryCollectSpatialTriggerVolumeCandidateIndices(snapshot, cameraPos, proximityState, proximityMode, candidateIndices)) {
                    for (uint i = 0; i < candidateIndices.Length; i++) {
                        ConsiderVisibleTriggerVolumeCandidate(
                            snapshot,
                            candidateIndices[i],
                            cameraPos,
                            proximityState,
                            proximityMode,
                            maxVisibleVolumes,
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
                            maxVisibleVolumes,
                            selection
                        );
                    }
                }
                if (selection.Volumes.Length == 0) return;
                SortVisibleTriggerVolumesByRenderPriority(
                    selection.Volumes,
                    selection.Fades,
                    selection.Indices,
                    selection.PriorityDistances
                );
                auto fillTileItems = array<WorldFillTileDrawItem@>();
                bool shouldCollectFillItems = ShouldRenderWorldFillNow() || ShouldRenderWorldTileIconsNow();
                if (shouldCollectFillItems) {
                    uint maxFrameFillItems = uint(Math::Max(GetEffectiveMaxFillTilesPerFrame(), 0));
                    for (uint i = 0; i < selection.Volumes.Length; i++) {
                        if (fillTileItems.Length >= maxFrameFillItems) break;
                        if (G_FillTileTraversalBudgetRemaining == 0) break;
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
                DrawWorldFillTileDrawItems(fillTileItems);

                if (TriggerVisualizer::Trigger::UI::S_ShowOutline) {
                    for (uint i = 0; i < selection.Volumes.Length; i++) {
                        if (G_WorldLineSegmentBudgetRemaining == 0) break;
                        DrawTriggerVolumeOutline(
                            selection.Volumes[i],
                            cameraPos,
                            GetOutlineColor(selection.Volumes[i], cameraPos, selection.Fades[i]),
                            TriggerVisualizer::Trigger::UI::S_OutlineWidth,
                            selection.Indices[i]
                        );
                    }
                }

                for (uint i = 0; i < selection.Volumes.Length; i++) {
                    if (ShouldRenderWorldLabelsNow()) {
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
