namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            const vec3 OFFZONE_BLOCK_WORLD_SIZE = vec3(32.0f, 8.0f, 32.0f);
            const int OFFZONE_WORLD_Y_ANCHOR = 8;

            string NormalizeMapCollectionName(const string &in rawName) {
                return rawName.ToLower().Trim().Replace(" ", "").Replace("-", "").Replace("_", "");
            }

            string GetMapCollectionName(CGameCtnChallenge@ map) {
                if (map is null) return "";

                string name = map.CollectionName;
                if (name.Length == 0 && map.MapInfo !is null) {
                    name = map.MapInfo.CollectionName;
                }
                if (name.Length == 0 && map.Collection !is null) {
                    name = string(map.Collection.DisplayName);
                }
                if (name.Length == 0 && map.Collection !is null) {
                    name = string(map.Collection.CollectionId_Text);
                }
                return name;
            }

            int GetMapCollectionId(CGameCtnChallenge@ map) {
                if (map is null || map.Collection is null) return -1;
                return int(map.Collection.CollectionId);
            }

            bool TryGetKnownVistaTriggerWorldYAnchor(
                const string &in rawCollectionName,
                int collectionId,
                float &out worldYAnchor,
                string &out source
            ) {
                string key = NormalizeMapCollectionName(rawCollectionName);

                if (key == "stadium" || key == "stadium2020") {
                    worldYAnchor = 8.0f;
                    source = "vista:Stadium";
                    return true;
                }
                if (key == "bluebay" || collectionId == 28) {
                    worldYAnchor = 5.0f;
                    source = "vista:BlueBay";
                    return true;
                }
                if (key == "greencoast" || collectionId == 15) {
                    worldYAnchor = 4.0f;
                    source = "vista:GreenCoast";
                    return true;
                }
                if (key == "redisland" || collectionId == 16) {
                    worldYAnchor = 4.0f;
                    source = "vista:RedIsland";
                    return true;
                }
                if (key == "whiteshore" || collectionId == 29) {
                    worldYAnchor = 4.0f;
                    source = "vista:WhiteShore";
                    return true;
                }

                return false;
            }

            float GetMapTriggerWorldYAnchor(
                CGameCtnChallenge@ map,
                string &out source,
                string &out collectionName,
                int &out collectionId,
                uint &out decoBaseHeightOffset
            ) {
                source = "default";
                collectionName = GetMapCollectionName(map);
                collectionId = GetMapCollectionId(map);
                decoBaseHeightOffset = map is null ? 0 : map.DecoBaseHeightOffset;
                if (map is null) return float(OFFZONE_WORLD_Y_ANCHOR);

                float knownVistaAnchor = float(OFFZONE_WORLD_Y_ANCHOR);
                string knownVistaSource = "";
                if (TryGetKnownVistaTriggerWorldYAnchor(collectionName, collectionId, knownVistaAnchor, knownVistaSource)) {
                    source = knownVistaSource;
                    return knownVistaAnchor;
                }

                uint anchor = map.DecoBaseHeightOffset;
                if (anchor > 0 && anchor <= 1024) {
                    source = "DecoBaseHeightOffset";
                    return float(anchor);
                }

                source = "default";
                return float(OFFZONE_WORLD_Y_ANCHOR);
            }

            nat3 NormalizeCellsPerBlock(const nat3 &in cellsPerBlock) {
                return nat3(
                    Math::Max(cellsPerBlock.x, 1),
                    Math::Max(cellsPerBlock.y, 1),
                    Math::Max(cellsPerBlock.z, 1)
                );
            }

            TriggerGridSpec@ BuildTriggerGridSpec(const nat3 &in cellsPerBlock) {
                return BuildTriggerGridSpec(cellsPerBlock, float(OFFZONE_WORLD_Y_ANCHOR));
            }

            TriggerGridSpec@ BuildTriggerGridSpec(const nat3 &in cellsPerBlock, float worldYAnchor) {
                nat3 normalized = NormalizeCellsPerBlock(cellsPerBlock);
                vec3 cellWorldSize = vec3(
                    OFFZONE_BLOCK_WORLD_SIZE.x / float(normalized.x),
                    OFFZONE_BLOCK_WORLD_SIZE.y / float(normalized.y),
                    OFFZONE_BLOCK_WORLD_SIZE.z / float(normalized.z)
                );
                return TriggerGridSpec(normalized, cellWorldSize, worldYAnchor);
            }

            TriggerGridSpec@ BuildTriggerGridSpec(CGameCtnChallenge@ map, const nat3 &in cellsPerBlock) {
                string source = "";
                string collectionName = "";
                int collectionId = -1;
                uint decoBaseHeightOffset = 0;
                float worldYAnchor = GetMapTriggerWorldYAnchor(
                    map,
                    source,
                    collectionName,
                    collectionId,
                    decoBaseHeightOffset
                );
                nat3 normalized = NormalizeCellsPerBlock(cellsPerBlock);
                vec3 cellWorldSize = vec3(
                    OFFZONE_BLOCK_WORLD_SIZE.x / float(normalized.x),
                    OFFZONE_BLOCK_WORLD_SIZE.y / float(normalized.y),
                    OFFZONE_BLOCK_WORLD_SIZE.z / float(normalized.z)
                );
                return TriggerGridSpec(
                    normalized,
                    cellWorldSize,
                    worldYAnchor,
                    source,
                    collectionName,
                    collectionId,
                    decoBaseHeightOffset
                );
            }

            vec3 TriggerCoordToWorldPos(const int3 &in coord, const TriggerGridSpec@ spec) {
                if (spec is null) return vec3();
                return vec3(
                    coord.x * spec.CellWorldSize.x,
                    (float(coord.y) - spec.WorldYAnchor) * spec.CellWorldSize.y,
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
                auto volume = TriggerVolume(
                    min,
                    max,
                    source,
                    sourceIndex,
                    GetTriggerSourceName(source) + " #" + tostring(sourceIndex)
                );
                if (source == TRIGGER_SOURCE_OFFZONE) {
                    volume.DetectedLabel = GetTriggerSourceName(source);
                }
                return volume;
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
