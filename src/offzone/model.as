namespace OffzoneVisualizer {
    namespace Offzone {
        class TriggerRangeRaw {
            int3 Start;
            int3 End;

            TriggerRangeRaw() { }

            TriggerRangeRaw(const int3 &in start, const int3 &in end) {
                Start = start;
                End = end;
            }

            int3 InclusiveSize() const {
                return End - Start + int3(1, 1, 1);
            }
        }

        class TriggerGridSpec {
            nat3 CellsPerBlock;
            vec3 CellWorldSize;

            TriggerGridSpec() {
                CellsPerBlock = nat3(1, 1, 1);
                CellWorldSize = vec3(32.0f, 8.0f, 32.0f);
            }

            TriggerGridSpec(const nat3 &in cellsPerBlock, const vec3 &in cellWorldSize) {
                CellsPerBlock = cellsPerBlock;
                CellWorldSize = cellWorldSize;
            }
        }

        class WorldAabb {
            vec3 Min;
            vec3 Max;

            WorldAabb() { }

            WorldAabb(const vec3 &in min, const vec3 &in max) {
                Min = min;
                Max = max;
            }

            vec3 Size() const {
                return Max - Min;
            }

            vec3 Center() const {
                return(Min + Max) * 0.5f;
            }
        }

        class MapSnapshot {
            string MapUid;
            nat3 RawTriggerSize;
            uint64 RawBufferPtr = 0;
            TriggerGridSpec@ GridSpec;
            array<TriggerRangeRaw@> RawRanges;
            array<WorldAabb@> WorldBoxes;

            MapSnapshot() {
                RawTriggerSize = nat3(1, 1, 1);
                @GridSpec = TriggerGridSpec();
            }

            uint OffzoneCount() const {
                return RawRanges.Length;
            }

            bool HasOffzones() const {
                return RawRanges.Length > 0;
            }
        }

        class ActiveZoneState {
            bool HasContainingZone = false;
            int ContainingZoneIndex = -1;
            bool HasNearestZone = false;
            int NearestZoneIndex = -1;
            float NearestZoneDistance = 0.0f;

            bool HasAnySelection() const {
                return HasContainingZone || HasNearestZone;
            }
        }
    }
}
