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
            string MapComments;
            nat3 RawTriggerSize;
            uint64 RawBufferPtr = 0;
            TriggerGridSpec@ GridSpec;
            MapRenderHints@ RenderHints;
            array<TriggerRangeRaw@> RawRanges;
            array<WorldAabb@> WorldBoxes;

            MapSnapshot() {
                RawTriggerSize = nat3(1, 1, 1);
                @GridSpec = TriggerGridSpec();
                @RenderHints = MapRenderHints();
            }

            uint OffzoneCount() const {
                return RawRanges.Length;
            }

            bool HasOffzones() const {
                return RawRanges.Length > 0;
            }
        }

        class MapRenderHints {
            bool HasAnyCommand = false;
            bool SuggestOff = false;
            bool ForceOff = false;
            bool HasSuggestedDrawDistanceXZ = false;
            bool HasSuggestedDrawDistanceY = false;
            float SuggestedDrawDistanceXZ = 0.0f;
            float SuggestedDrawDistanceY = 0.0f;
            array<string> Commands;

            string DisableSummary() const {
                if (ForceOff) return "force-off";
                if (SuggestOff) return "suggest-off";
                return "none";
            }

            string DistanceSummary() const {
                string xz = HasSuggestedDrawDistanceXZ ? Text::Format("%.0f", SuggestedDrawDistanceXZ) + "m X/Z" : "no X/Z";
                string y = HasSuggestedDrawDistanceY ? Text::Format("%.0f", SuggestedDrawDistanceY) + "m Y" : "no Y";
                return xz + ", " + y;
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
