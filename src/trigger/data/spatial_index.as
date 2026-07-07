namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            const float MAP_SPATIAL_INDEX_CELL_SIZE = 128.0f;
            const uint MAP_SPATIAL_INDEX_MAX_CELLS_PER_VOLUME = 512;

            int GetMapSpatialIndexCellCoord(float value, float cellSize) {
                cellSize = Math::Max(cellSize, 1.0f);
                return int(Math::Floor(value / cellSize));
            }

            string GetMapSpatialIndexCellKey(int x, int y, int z) {
                return tostring(x) + "," + tostring(y) + "," + tostring(z);
            }

            void ResetMapSnapshotSpatialIndex(MapSnapshot@ snapshot) {
                if (snapshot is null) return;

                snapshot.SpatialIndexReady = false;
                snapshot.SpatialIndexCellSize = MAP_SPATIAL_INDEX_CELL_SIZE;
                snapshot.SpatialIndexCellLookup.DeleteAll();
                snapshot.SpatialIndexCells.Resize(0);
                snapshot.SpatialIndexLargeVolumeIndices.Resize(0);
                snapshot.SpatialIndexVolumeReferenceCount = 0;
            }

            TriggerSpatialIndexCell@ GetOrCreateMapSpatialIndexCell(MapSnapshot@ snapshot, const string &in key) {
                if (snapshot is null || key.Length == 0) return null;

                int cellIndex = -1;
                if (snapshot.SpatialIndexCellLookup.Get(key, cellIndex)) {
                    if (cellIndex >= 0 && cellIndex < int(snapshot.SpatialIndexCells.Length)) {
                        return snapshot.SpatialIndexCells[uint(cellIndex)];
                    }
                }

                auto cell = TriggerSpatialIndexCell(key);
                cellIndex = int(snapshot.SpatialIndexCells.Length);
                snapshot.SpatialIndexCells.InsertLast(cell);
                snapshot.SpatialIndexCellLookup.Set(key, cellIndex);
                return cell;
            }

            void AddMapSpatialIndexCellVolume(
                MapSnapshot@ snapshot,
                int x,
                int y,
                int z,
                uint volumeIndex
            ) {
                auto cell = GetOrCreateMapSpatialIndexCell(
                    snapshot,
                    GetMapSpatialIndexCellKey(x, y, z)
                );
                if (cell is null) return;

                cell.VolumeIndices.InsertLast(volumeIndex);
                snapshot.SpatialIndexVolumeReferenceCount++;
            }

            bool ShouldStoreMapSpatialIndexVolumeGlobally(
                int minX,
                int maxX,
                int minY,
                int maxY,
                int minZ,
                int maxZ
            ) {
                int xCells = maxX - minX + 1;
                int yCells = maxY - minY + 1;
                int zCells = maxZ - minZ + 1;
                if (xCells <= 0 || yCells <= 0 || zCells <= 0) return true;

                float cellCount = float(xCells) * float(yCells) * float(zCells);
                return cellCount > float(MAP_SPATIAL_INDEX_MAX_CELLS_PER_VOLUME);
            }

            void AddMapSpatialIndexVolume(MapSnapshot@ snapshot, uint volumeIndex, const TriggerVolume@ volume) {
                if (snapshot is null || volume is null) return;

                float cellSize = snapshot.SpatialIndexCellSize;
                int minX = GetMapSpatialIndexCellCoord(volume.Min.x, cellSize);
                int maxX = GetMapSpatialIndexCellCoord(volume.Max.x, cellSize);
                int minY = GetMapSpatialIndexCellCoord(volume.Min.y, cellSize);
                int maxY = GetMapSpatialIndexCellCoord(volume.Max.y, cellSize);
                int minZ = GetMapSpatialIndexCellCoord(volume.Min.z, cellSize);
                int maxZ = GetMapSpatialIndexCellCoord(volume.Max.z, cellSize);

                if (ShouldStoreMapSpatialIndexVolumeGlobally(minX, maxX, minY, maxY, minZ, maxZ)) {
                    snapshot.SpatialIndexLargeVolumeIndices.InsertLast(volumeIndex);
                    snapshot.SpatialIndexVolumeReferenceCount++;
                    return;
                }

                for (int x = minX; x <= maxX; x++) {
                    for (int y = minY; y <= maxY; y++) {
                        for (int z = minZ; z <= maxZ; z++) {
                            AddMapSpatialIndexCellVolume(snapshot, x, y, z, volumeIndex);
                        }
                    }
                }
            }

            void BuildMapSnapshotSpatialIndex(MapSnapshot@ snapshot) {
                ResetMapSnapshotSpatialIndex(snapshot);
                if (snapshot is null || snapshot.TriggerVolumes.Length == 0) return;

                for (uint i = 0; i < snapshot.TriggerVolumes.Length; i++) {
                    AddMapSpatialIndexVolume(snapshot, i, snapshot.TriggerVolumes[i]);
                }
                snapshot.SpatialIndexReady = snapshot.SpatialIndexCells.Length > 0
                    || snapshot.SpatialIndexLargeVolumeIndices.Length > 0;
            }
        }
    }
}
