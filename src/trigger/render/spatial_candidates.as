namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            const uint SPATIAL_CANDIDATE_MAX_QUERY_CELLS_PER_POINT = 8192;
            array<uint> g_SpatialCandidateVisitStamps;
            uint g_SpatialCandidateVisitSerial = 1;

            void PrepareSpatialCandidateVisitStamps(uint volumeCount) {
                if (g_SpatialCandidateVisitStamps.Length != volumeCount) {
                    g_SpatialCandidateVisitStamps.Resize(volumeCount);
                    for (uint i = 0; i < g_SpatialCandidateVisitStamps.Length; i++) {
                        g_SpatialCandidateVisitStamps[i] = 0;
                    }
                }
                g_SpatialCandidateVisitSerial++;
                if (g_SpatialCandidateVisitSerial == 0) {
                    g_SpatialCandidateVisitSerial = 1;
                    for (uint i = 0; i < g_SpatialCandidateVisitStamps.Length; i++) {
                        g_SpatialCandidateVisitStamps[i] = 0;
                    }
                }
            }

            void AddSpatialCandidateVolumeIndex(array<uint> @candidateIndices, uint volumeIndex) {
                if (candidateIndices is null || volumeIndex >= g_SpatialCandidateVisitStamps.Length) return;
                if (g_SpatialCandidateVisitStamps[volumeIndex] == g_SpatialCandidateVisitSerial) return;

                g_SpatialCandidateVisitStamps[volumeIndex] = g_SpatialCandidateVisitSerial;
                candidateIndices.InsertLast(volumeIndex);
            }

            bool GetSpatialCandidateCellCoordRange(
                MapSnapshot@ snapshot,
                const vec3 &in point,
                const vec3 &in renderDistance,
                int &out minX,
                int &out maxX,
                int &out minY,
                int &out maxY,
                int &out minZ,
                int &out maxZ
            ) {
                if (snapshot is null) return false;

                float cellSize = Math::Max(snapshot.SpatialIndexCellSize, 1.0f);
                minX = TriggerVisualizer::Trigger::Data::GetMapSpatialIndexCellCoord(
                    point.x - renderDistance.x,
                    cellSize
                );
                maxX = TriggerVisualizer::Trigger::Data::GetMapSpatialIndexCellCoord(
                    point.x + renderDistance.x,
                    cellSize
                );
                minY = TriggerVisualizer::Trigger::Data::GetMapSpatialIndexCellCoord(
                    point.y - renderDistance.y,
                    cellSize
                );
                maxY = TriggerVisualizer::Trigger::Data::GetMapSpatialIndexCellCoord(
                    point.y + renderDistance.y,
                    cellSize
                );
                minZ = TriggerVisualizer::Trigger::Data::GetMapSpatialIndexCellCoord(
                    point.z - renderDistance.z,
                    cellSize
                );
                maxZ = TriggerVisualizer::Trigger::Data::GetMapSpatialIndexCellCoord(
                    point.z + renderDistance.z,
                    cellSize
                );
                int xCells = maxX - minX + 1;
                int yCells = maxY - minY + 1;
                int zCells = maxZ - minZ + 1;
                if (xCells <= 0 || yCells <= 0 || zCells <= 0) return false;

                float cellCount = float(xCells) * float(yCells) * float(zCells);
                return cellCount <= float(SPATIAL_CANDIDATE_MAX_QUERY_CELLS_PER_POINT);
            }

            bool AddSpatialCandidatePointRange(
                MapSnapshot@ snapshot,
                const vec3 &in point,
                const vec3 &in renderDistance,
                array<uint> @candidateIndices
            ) {
                if (snapshot is null || candidateIndices is null) return false;

                int minX = 0;
                int maxX = 0;
                int minY = 0;
                int maxY = 0;
                int minZ = 0;
                int maxZ = 0;
                if (!GetSpatialCandidateCellCoordRange(snapshot, point, renderDistance, minX, maxX, minY, maxY, minZ, maxZ)) {
                    return false;
                }

                for (int x = minX; x <= maxX; x++) {
                    for (int y = minY; y <= maxY; y++) {
                        for (int z = minZ; z <= maxZ; z++) {
                            string key = TriggerVisualizer::Trigger::Data::GetMapSpatialIndexCellKey(x, y, z);
                            int cellIndex = -1;
                            if (!snapshot.SpatialIndexCellLookup.Get(key, cellIndex)) continue;
                            if (cellIndex < 0 || cellIndex >= int(snapshot.SpatialIndexCells.Length)) continue;

                            auto cell = snapshot.SpatialIndexCells[uint(cellIndex)];
                            if (cell is null) continue;
                            for (uint i = 0; i < cell.VolumeIndices.Length; i++) {
                                AddSpatialCandidateVolumeIndex(candidateIndices, cell.VolumeIndices[i]);
                            }
                        }
                    }
                }

                return true;
            }

            bool IsSpatialCandidateQueryUnlimited(const vec3 &in renderDistance) {
                float unlimitedThreshold = UNLIMITED_RENDER_DISTANCE_WORLD * 0.5f;
                return renderDistance.x >= unlimitedThreshold
                    || renderDistance.y >= unlimitedThreshold
                    || renderDistance.z >= unlimitedThreshold;
            }

            bool TryCollectSpatialTriggerVolumeCandidateIndices(
                MapSnapshot@ snapshot,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState,
                int proximityMode,
                array<uint> @candidateIndices
            ) {
                if (candidateIndices is null) return false;
                candidateIndices.Resize(0);
                if (snapshot is null || !snapshot.SpatialIndexReady) return false;
                if (snapshot.TriggerVolumes.Length == 0) return false;

                vec3 renderDistance = GetEffectiveRenderDistanceWorld();
                if (IsSpatialCandidateQueryUnlimited(renderDistance)) return false;

                PrepareSpatialCandidateVisitStamps(snapshot.TriggerVolumes.Length);
                for (uint i = 0; i < snapshot.SpatialIndexLargeVolumeIndices.Length; i++) {
                    AddSpatialCandidateVolumeIndex(candidateIndices, snapshot.SpatialIndexLargeVolumeIndices[i]);
                }

                bool addedPoint = false;
                if (RenderPriorityModeUsesCamera(proximityMode)) {
                    if (!AddSpatialCandidatePointRange(snapshot, cameraPos, renderDistance, candidateIndices)) return false;
                    addedPoint = true;
                }
                if (RenderPriorityModeUsesVehicle(proximityMode) && proximityState !is null && proximityState.HasVehiclePosition) {
                    if (!AddSpatialCandidatePointRange(snapshot, proximityState.VehiclePosition, renderDistance, candidateIndices)) return false;
                    addedPoint = true;
                }
                if (RenderPriorityModeUsesOrbital(proximityMode) && proximityState !is null && proximityState.HasOrbitalPoint) {
                    if (!AddSpatialCandidatePointRange(snapshot, proximityState.OrbitalPoint, renderDistance, candidateIndices)) return false;
                    addedPoint = true;
                }
                if (!addedPoint) {
                    if (!AddSpatialCandidatePointRange(snapshot, cameraPos, renderDistance, candidateIndices)) return false;
                }

                return true;
            }
        }
    }
}
