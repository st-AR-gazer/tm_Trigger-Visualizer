namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            const vec3 OFFZONE_BLOCK_WORLD_SIZE = vec3(32.0f, 8.0f, 32.0f);
            const int OFFZONE_WORLD_Y_ANCHOR = 8;

            nat3 NormalizeCellsPerBlock(const nat3 &in cellsPerBlock) {
                return nat3(
                    Math::Max(cellsPerBlock.x, 1),
                    Math::Max(cellsPerBlock.y, 1),
                    Math::Max(cellsPerBlock.z, 1)
                );
            }

            TriggerGridSpec@ BuildTriggerGridSpec(const nat3 &in cellsPerBlock) {
                nat3 normalized = NormalizeCellsPerBlock(cellsPerBlock);
                vec3 cellWorldSize = vec3(
                    OFFZONE_BLOCK_WORLD_SIZE.x / float(normalized.x),
                    OFFZONE_BLOCK_WORLD_SIZE.y / float(normalized.y),
                    OFFZONE_BLOCK_WORLD_SIZE.z / float(normalized.z)
                );
                return TriggerGridSpec(normalized, cellWorldSize);
            }

            vec3 TriggerCoordToWorldPos(const int3 &in coord, const TriggerGridSpec@ spec) {
                if (spec is null) return vec3();
                return vec3(
                    coord.x * spec.CellWorldSize.x,
                    (coord.y - OFFZONE_WORLD_Y_ANCHOR) * spec.CellWorldSize.y,
                    coord.z * spec.CellWorldSize.z
                );
            }

            TriggerVolume@ TriggerRangeToTriggerVolume(
                const TriggerRangeRaw@ range,
                const TriggerGridSpec@ spec,
                int source,
                uint sourceIndex
            ) {
                if (range is null || spec is null) return TriggerVolume();
                vec3 min = TriggerCoordToWorldPos(range.Start, spec);
                vec3 max = TriggerCoordToWorldPos(range.End + int3(1, 1, 1), spec);
                return TriggerVolume(
                    min,
                    max,
                    source,
                    sourceIndex,
                    GetTriggerSourceName(source) + " #" + tostring(sourceIndex)
                );
            }

            array<TriggerVolume@> @TriggerRangesToTriggerVolumes(
                const array<TriggerRangeRaw@> @ranges,
                const TriggerGridSpec@ spec,
                int source
            ) {
                auto volumes = array<TriggerVolume@>();
                if (ranges is null || spec is null) return volumes;

                for (uint i = 0; i < ranges.Length; i++) {
                    volumes.InsertLast(TriggerRangeToTriggerVolume(ranges[i], spec, source, i));
                }

                return volumes;
            }
        }
    }
}
