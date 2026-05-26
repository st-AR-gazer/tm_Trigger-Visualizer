namespace TriggerVisualizer {
    namespace Trigger {
        const int TRIGGER_SOURCE_OFFZONE = 0;
        const int TRIGGER_SOURCE_MEDIATRACKER = 1;

        string GetTriggerSourceName(int source) {
            if (source == TRIGGER_SOURCE_OFFZONE) return "Offzone";
            if (source == TRIGGER_SOURCE_MEDIATRACKER) return "MediaTracker";
            return "Unknown";
        }

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

        class TriggerVolume {
            vec3 Min;
            vec3 Max;
            int Source = TRIGGER_SOURCE_OFFZONE;
            uint SourceIndex = 0;
            string Label;
            string DetectedLabel;
            bool HasIslandIndex = false;
            uint IslandIndex = 0;
            uint IslandCount = 0;

            TriggerVolume() { }

            TriggerVolume(const vec3 &in min, const vec3 &in max) {
                Min = min;
                Max = max;
            }

            TriggerVolume(
                const vec3 &in min,
                const vec3 &in max,
                int source,
                uint sourceIndex,
                const string &in label = ""
            ) {
                Min = min;
                Max = max;
                Source = source;
                SourceIndex = sourceIndex;
                Label = label;
            }

            vec3 Size() const {
                return Max - Min;
            }

            vec3 Center() const {
                return(Min + Max) * 0.5f;
            }

            string SourceName() const {
                return GetTriggerSourceName(Source);
            }

            string SourceIndexLabel() const {
                return SourceName() + " #" + tostring(SourceIndex);
            }

            string DisplayLabel() const {
                return DisplayLabelWithOptions(true, true, false, false);
            }

            string DisplayLabelWithIsland(bool includeIslandIndex) const {
                return DisplayLabelWithOptions(true, includeIslandIndex, false, false);
            }

            string DisplayLabelWithOptions(
                bool includeSourcePrefix,
                bool includeIslandIndex,
                bool useDetectedLabel,
                bool appendDetectedLabel
            ) const {
                string label = SourceIndexLabel();
                bool hasCustomLabel = Label.Length > 0;
                bool hasDetectedLabel = DetectedLabel.Length > 0;

                if (Label.Length > 0) {
                    label = Label;
                }
                if (useDetectedLabel && hasDetectedLabel) {
                    label = DetectedLabel;
                    hasCustomLabel = true;
                } else if (appendDetectedLabel && hasDetectedLabel && DetectedLabel != label) {
                    label += " (" + DetectedLabel + ")";
                }
                if (includeSourcePrefix && hasCustomLabel) {
                    label = SourceIndexLabel() + ": " + label;
                }
                if (includeIslandIndex && HasIslandIndex && IslandCount > 1) {
                    label += " island " + tostring(IslandIndex + 1) + "/" + tostring(IslandCount);
                }
                return label;
            }
        }

        class MediaTrackerClipTriggerSnapshot {
            uint ClipIndex = 0;
            string ClipName;
            string DetectedLabel;
            bool HasClip = false;
            nat3 MinCoord;
            nat3 MaxCoord;
            uint RawCoordCount = 0;
            uint RawCoordCapacity = 0;
            uint SampledCoordCount = 0;
            uint64 TriggerStructPtr = 0;
            uint64 CoordBufferPtr = 0;
            bool HasReadableCoordBuffer = false;
            bool CoordSamplesTruncated = false;
            bool RenderCoordsSkipped = false;
            bool RenderIslandsUsed = false;
            uint RenderIslandCount = 0;
            string Warning;
            array<int3> RawCoords;
            array<int3> RawCoordSamples;

            MediaTrackerClipTriggerSnapshot() {
                ClipName = "<unknown>";
                MinCoord = nat3();
                MaxCoord = nat3();
            }

            bool HasWarning() const {
                return Warning.Length > 0;
            }

            string DisplayName() const {
                if (ClipName.Length > 0) return ClipName;
                return "<unnamed clip>";
            }
        }

        class TriggerSourceSnapshot {
            int Source = TRIGGER_SOURCE_OFFZONE;
            string Name = "Offzone";
            bool Enabled = true;
            nat3 RawTriggerSize;
            uint64 RawBufferPtr = 0;
            uint RawClipCount = 0;
            uint RawTriggerCount = 0;
            uint RawTriggerCapacity = 0;
            uint RawCoordCount = 0;
            uint ReadableTriggerCount = 0;
            uint BadTriggerCount = 0;
            nat3 MapSize;
            TriggerGridSpec@ GridSpec;
            array<TriggerRangeRaw@> RawRanges;
            array<TriggerVolume@> TriggerVolumes;
            array<string> Diagnostics;
            array<MediaTrackerClipTriggerSnapshot@> MediaTrackerClipTriggers;

            TriggerSourceSnapshot() {
                RawTriggerSize = nat3(1, 1, 1);
                @GridSpec = TriggerGridSpec();
            }

            TriggerSourceSnapshot(int source, bool enabled) {
                Source = source;
                Name = GetTriggerSourceName(source);
                Enabled = enabled;
                RawTriggerSize = nat3(1, 1, 1);
                @GridSpec = TriggerGridSpec();
            }

            uint RawRangeCount() const {
                return RawRanges.Length;
            }

            uint TriggerVolumeCount() const {
                return TriggerVolumes.Length;
            }

            uint DiagnosticCount() const {
                return Diagnostics.Length;
            }

            uint MediaTrackerClipTriggerCount() const {
                return MediaTrackerClipTriggers.Length;
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
            array<TriggerSourceSnapshot@> Sources;
            array<TriggerVolume@> TriggerVolumes;

            MapSnapshot() {
                RawTriggerSize = nat3(1, 1, 1);
                @GridSpec = TriggerGridSpec();
                @RenderHints = MapRenderHints();
            }

            void AddSource(TriggerSourceSnapshot@ source) {
                if (source is null) return;

                Sources.InsertLast(source);
                if (!source.Enabled) return;

                for (uint i = 0; i < source.TriggerVolumes.Length; i++) {
                    TriggerVolumes.InsertLast(source.TriggerVolumes[i]);
                }
            }

            uint SourceCount() const {
                return Sources.Length;
            }

            uint OffzoneCount() const {
                return RawRanges.Length;
            }

            bool HasOffzones() const {
                return RawRanges.Length > 0;
            }

            uint TriggerVolumeCount() const {
                return TriggerVolumes.Length;
            }

            bool HasTriggerVolumes() const {
                return TriggerVolumes.Length > 0;
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
