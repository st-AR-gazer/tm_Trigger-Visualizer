namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            float GetDistanceToWorldQuad(
                const vec3 &in point,
                const vec3 &in origin,
                const vec3 &in uEdge,
                const vec3 &in vEdge
            ) {
                float uLenSq = uEdge.LengthSquared();
                float vLenSq = vEdge.LengthSquared();
                float u = uLenSq <= 0.0001f ? 0.0f : Math::Dot(point - origin, uEdge) / uLenSq;
                float v = vLenSq <= 0.0001f ? 0.0f : Math::Dot(point - origin, vEdge) / vLenSq;
                u = Math::Clamp(u, 0.0f, 1.0f);
                v = Math::Clamp(v, 0.0f, 1.0f);
                return Math::Distance(point, origin + uEdge * u + vEdge * v);
            }

            bool ShouldSplitWorldFaceTile(
                const vec3 &in origin,
                const vec3 &in uEdge,
                const vec3 &in vEdge,
                const vec3 &in cameraPos,
                uint depth,
                bool forceSplit
            ) {
                if (depth >= FILL_TILE_MAX_DEPTH) return false;

                float uLen = Math::Distance(origin, origin + uEdge);
                float vLen = Math::Distance(origin, origin + vEdge);
                float minTileSize = GetFillTileMinSize();
                if (uLen <= minTileSize && vLen <= minTileSize) return false;
                if (forceSplit) return true;

                float longestEdge = Math::Max(uLen, vLen);
                float cameraDistance = GetDistanceToWorldQuad(cameraPos, origin, uEdge, vEdge);
                float splitDistance = Math::Max(longestEdge * FILL_TILE_SPLIT_DISTANCE_FACTOR, minTileSize);
                return cameraDistance <= splitDistance;
            }

            float GetWorldFillTileSortDistanceSq(
                const vec3 &in origin,
                const vec3 &in uEdge,
                const vec3 &in vEdge,
                const vec3 &in cameraPos
            ) {
                vec3 center = origin + (uEdge + vEdge) * 0.5f;
                return Math::Distance2(cameraPos, center);
            }

            uint CollectAdaptiveWorldFaceTileDrawItems(
                array<WorldFillTileDrawItem@> @items,
                const vec3 &in origin,
                const vec3 &in uEdge,
                const vec3 &in vEdge,
                const vec3 &in cameraPos,
                const vec4 &in baseColor,
                float tileSeed,
                uint depth,
                uint budget,
                const string &in tileIconTextureKey = ""
            ) {
                if (items is null) return 0;
                if (budget == 0) return 0;

                vec3 p0 = origin;
                vec3 p1 = origin + uEdge;
                vec3 p2 = origin + uEdge + vEdge;
                vec3 p3 = origin + vEdge;
                int primitiveClass = ClassifyWorldQuadForFrustum(p0, p1, p2, p3);
                if (primitiveClass == WORLD_PRIMITIVE_OUTSIDE) return 0;
                bool isMixed = primitiveClass == WORLD_PRIMITIVE_MIXED;
                int maxFrameTiles = GetFillTileFrameSafetyLimit();
                if (int(items.Length) >= maxFrameTiles) return 0;

                uint remainingFrameBudget = uint(maxFrameTiles - int(items.Length));
                if (budget > remainingFrameBudget) {
                    budget = remainingFrameBudget;
                }

                float uLen = Math::Distance(origin, origin + uEdge);
                float vLen = Math::Distance(origin, origin + vEdge);
                float minTileSize = GetFillTileMinSize();
                bool splitU = uLen > minTileSize;
                bool splitV = vLen > minTileSize;
                if (!ShouldSplitWorldFaceTile(origin, uEdge, vEdge, cameraPos, depth, isMixed) || (!splitU && !splitV)) {
                    WorldFillTileDrawItem@ item = WorldFillTileDrawItem(
                        origin,
                        uEdge,
                        vEdge,
                        GetFillTileColor(baseColor, tileSeed),
                        tileSeed,
                        GetWorldFillTileSortDistanceSq(origin, uEdge, vEdge, cameraPos)
                    );
                    item.TileIconTextureKey = tileIconTextureKey;
                    if (!UpdateWorldFillTileScreenProjection(item)) return 0;
                    items.InsertLast(item);
                    return 1;
                }

                uint drawn = 0;
                vec3 halfU = uEdge * 0.5f;
                vec3 halfV = vEdge * 0.5f;

                if (splitU && splitV) {
                    drawn += CollectAdaptiveWorldFaceTileDrawItems(
                        items,
                        origin,
                        halfU,
                        halfV,
                        cameraPos,
                        baseColor,
                        tileSeed * 4.0f + 1.0f,
                        depth + 1,
                        budget - drawn,
                        tileIconTextureKey
                    );
                    if (drawn >= budget) return drawn;
                    drawn += CollectAdaptiveWorldFaceTileDrawItems(
                        items,
                        origin + halfU,
                        halfU,
                        halfV,
                        cameraPos,
                        baseColor,
                        tileSeed * 4.0f + 2.0f,
                        depth + 1,
                        budget - drawn,
                        tileIconTextureKey
                    );
                    if (drawn >= budget) return drawn;
                    drawn += CollectAdaptiveWorldFaceTileDrawItems(
                        items,
                        origin + halfV,
                        halfU,
                        halfV,
                        cameraPos,
                        baseColor,
                        tileSeed * 4.0f + 3.0f,
                        depth + 1,
                        budget - drawn,
                        tileIconTextureKey
                    );
                    if (drawn >= budget) return drawn;
                    drawn += CollectAdaptiveWorldFaceTileDrawItems(
                        items,
                        origin + halfU + halfV,
                        halfU,
                        halfV,
                        cameraPos,
                        baseColor,
                        tileSeed * 4.0f + 4.0f,
                        depth + 1,
                        budget - drawn,
                        tileIconTextureKey
                    );
                    return drawn;
                }

                if (splitU) {
                    drawn += CollectAdaptiveWorldFaceTileDrawItems(
                        items,
                        origin,
                        halfU,
                        vEdge,
                        cameraPos,
                        baseColor,
                        tileSeed * 2.0f + 1.0f,
                        depth + 1,
                        budget - drawn,
                        tileIconTextureKey
                    );
                    if (drawn >= budget) return drawn;
                    drawn += CollectAdaptiveWorldFaceTileDrawItems(
                        items,
                        origin + halfU,
                        halfU,
                        vEdge,
                        cameraPos,
                        baseColor,
                        tileSeed * 2.0f + 2.0f,
                        depth + 1,
                        budget - drawn,
                        tileIconTextureKey
                    );
                    return drawn;
                }

                drawn += CollectAdaptiveWorldFaceTileDrawItems(
                    items,
                    origin,
                    uEdge,
                    halfV,
                    cameraPos,
                    baseColor,
                    tileSeed * 2.0f + 1.0f,
                    depth + 1,
                    budget - drawn,
                    tileIconTextureKey
                );
                if (drawn >= budget) return drawn;
                drawn += CollectAdaptiveWorldFaceTileDrawItems(
                    items,
                    origin + halfV,
                    uEdge,
                    halfV,
                    cameraPos,
                    baseColor,
                    tileSeed * 2.0f + 2.0f,
                    depth + 1,
                    budget - drawn,
                    tileIconTextureKey
                );
                return drawn;
            }

            bool AreFillTileColorsEquivalent(const vec4 &in a, const vec4 &in b) {
                return Math::Abs(a.x - b.x) <= 0.0001f
                    && Math::Abs(a.y - b.y) <= 0.0001f
                    && Math::Abs(a.z - b.z) <= 0.0001f
                    && Math::Abs(a.w - b.w) <= 0.0001f;
            }

            bool AddWorldFillTilePath(WorldFillTileDrawItem@ item) {
                if (item is null) return false;
                if (item.Occluded) return false;

                if (!item.HasScreenProjection && !UpdateWorldFillTileScreenProjection(item)) return false;
                if (!IsProjectedQuadPotentiallyVisible(item.Screen0, item.Screen1, item.Screen2, item.Screen3, SCREEN_QUAD_VISIBILITY_MARGIN)) return false;

                nvg::MoveTo(item.Screen0.xy);
                nvg::LineTo(item.Screen1.xy);
                nvg::LineTo(item.Screen2.xy);
                nvg::LineTo(item.Screen3.xy);
                nvg::ClosePath();
                return true;
            }

            void DrawWorldFillTileFillBatch(
                array<WorldFillTileDrawItem@> @items,
                uint startIndex,
                uint endIndex,
                const vec4 &in color
            ) {
                if (items is null || startIndex >= endIndex || color.w <= 0.001f) return;

                nvg::FillColor(color);
                for (uint i = startIndex; i < endIndex && i < items.Length; i++) {
                    if (items[i] is null || items[i].Occluded) continue;

                    nvg::BeginPath();
                    if (AddWorldFillTilePath(items[i])) {
                        nvg::Fill();
                    }
                    nvg::ClosePath();
                }
            }

            void DrawWorldFillTileIconBatch(array<WorldFillTileDrawItem@> @items, uint startIndex, uint endIndex) {
                if (items is null || !ShouldRepeatTileIconsOnSplitFillTilesNow()) return;

                for (uint i = startIndex; i < endIndex && i < items.Length; i++) {
                    if (items[i] is null || items[i].Occluded || !items[i].AllowTileIcon) continue;
                    DrawTileIconOnWorldTile(
                        items[i].Origin,
                        items[i].UEdge,
                        items[i].VEdge,
                        Assets::GetTileIconTextureByKey(items[i].TileIconTextureKey)
                    );
                }
            }

            bool WorldFillTileDrawItemBackToFrontLess(
                const WorldFillTileDrawItem@ const &in left,
                const WorldFillTileDrawItem@ const &in right
            ) {
                if (left is null) return false;
                if (right is null) return true;
                if (left.SortDistanceSq != right.SortDistanceSq) {
                    return left.SortDistanceSq > right.SortDistanceSq;
                }
                return left.SortOrder < right.SortOrder;
            }

            void MarkDuplicateWorldFillTileDrawItems(array<WorldFillTileDrawItem@> @items) {
                if (items is null || items.Length <= 1) return;

                dictionary seenGeometry;
                for (int i = int(items.Length) - 1; i >= 0; i--) {
                    WorldFillTileDrawItem@ item = items[uint(i)];
                    if (item is null || item.Occluded || item.GeometryKey.Length == 0) continue;

                    if (seenGeometry.Exists(item.GeometryKey)) {
                        item.Occluded = true;
                        continue;
                    }

                    seenGeometry.Set(item.GeometryKey, true);
                }
            }

            void DrawWorldFillTileDrawItems(array<WorldFillTileDrawItem@> @items) {
                if (items is null || items.Length == 0) return;

                if (items.Length > 1) {
                    for (uint i = 0; i < items.Length; i++) {
                        if (items[i] !is null) items[i].SortOrder = i;
                    }
                    items.Sort(WorldFillTileDrawItemBackToFrontLess);
                }
                MarkDuplicateWorldFillTileDrawItems(items);
                nvg::Reset();
                uint groupStart = 0;
                while (groupStart < items.Length) {
                    WorldFillTileDrawItem@ groupItem = items[groupStart];
                    vec4 groupColor = groupItem is null ? vec4() : groupItem.Color;
                    uint groupEnd = groupStart + 1;
                    while (groupEnd < items.Length) {
                        WorldFillTileDrawItem@ nextItem = items[groupEnd];
                        if (nextItem is null || !AreFillTileColorsEquivalent(nextItem.Color, groupColor)) break;
                        groupEnd++;
                    }
                    DrawWorldFillTileFillBatch(items, groupStart, groupEnd, groupColor);
                    DrawWorldFillTileIconBatch(items, groupStart, groupEnd);
                    groupStart = groupEnd;
                }
            }

            bool WorldTileIconDrawItemBackToFrontLess(
                const WorldTileIconDrawItem@ const &in left,
                const WorldTileIconDrawItem@ const &in right
            ) {
                if (left is null) return false;
                if (right is null) return true;
                if (left.SortDistanceSq != right.SortDistanceSq) {
                    return left.SortDistanceSq > right.SortDistanceSq;
                }
                return left.SortOrder < right.SortOrder;
            }

            void MarkDuplicateWorldTileIconDrawItems(array<WorldTileIconDrawItem@> @items) {
                if (items is null || items.Length <= 1) return;

                dictionary seenGeometry;
                for (int i = int(items.Length) - 1; i >= 0; i--) {
                    WorldTileIconDrawItem@ item = items[uint(i)];
                    if (item is null || item.Occluded || item.GeometryKey.Length == 0) continue;

                    if (seenGeometry.Exists(item.GeometryKey)) {
                        item.Occluded = true;
                        continue;
                    }

                    seenGeometry.Set(item.GeometryKey, true);
                }
            }

            void DrawWorldTileIconDrawItems(array<WorldTileIconDrawItem@> @items) {
                if (items is null || items.Length == 0 || !ShouldRenderWorldTileIconsNow()) return;

                if (items.Length > 1) {
                    for (uint i = 0; i < items.Length; i++) {
                        if (items[i] !is null) items[i].SortOrder = i;
                    }
                    items.Sort(WorldTileIconDrawItemBackToFrontLess);
                }
                MarkDuplicateWorldTileIconDrawItems(items);
                nvg::Reset();
                for (uint i = 0; i < items.Length; i++) {
                    if (items[i] is null || items[i].Occluded || items[i].TextureKey.Length == 0) continue;
                    DrawTileIconOnWorldTile(
                        items[i].Origin,
                        items[i].UEdge,
                        items[i].VEdge,
                        Assets::GetTileIconTextureByKey(items[i].TextureKey)
                    );
                }
            }

            uint CountAdaptiveWorldFaceTiles(
                const vec3 &in origin,
                const vec3 &in uEdge,
                const vec3 &in vEdge,
                const vec3 &in cameraPos,
                uint depth,
                uint budget
            ) {
                if (budget == 0) return 0;

                vec3 p0 = origin;
                vec3 p1 = origin + uEdge;
                vec3 p2 = origin + uEdge + vEdge;
                vec3 p3 = origin + vEdge;
                int primitiveClass = ClassifyWorldQuadForFrustum(p0, p1, p2, p3);
                if (primitiveClass == WORLD_PRIMITIVE_OUTSIDE) return 0;
                bool isMixed = primitiveClass == WORLD_PRIMITIVE_MIXED;
                float uLen = Math::Distance(origin, origin + uEdge);
                float vLen = Math::Distance(origin, origin + vEdge);
                float minTileSize = GetFillTileMinSize();
                bool splitU = uLen > minTileSize;
                bool splitV = vLen > minTileSize;
                if (!ShouldSplitWorldFaceTile(origin, uEdge, vEdge, cameraPos, depth, isMixed) || (!splitU && !splitV)) {
                    return 1;
                }

                uint count = 0;
                vec3 halfU = uEdge * 0.5f;
                vec3 halfV = vEdge * 0.5f;

                if (splitU && splitV) {
                    count += CountAdaptiveWorldFaceTiles(
                        origin,
                        halfU,
                        halfV,
                        cameraPos,
                        depth + 1,
                        budget - count
                    );
                    if (count >= budget) return count;
                    count += CountAdaptiveWorldFaceTiles(
                        origin + halfU,
                        halfU,
                        halfV,
                        cameraPos,
                        depth + 1,
                        budget - count
                    );
                    if (count >= budget) return count;
                    count += CountAdaptiveWorldFaceTiles(
                        origin + halfV,
                        halfU,
                        halfV,
                        cameraPos,
                        depth + 1,
                        budget - count
                    );
                    if (count >= budget) return count;
                    count += CountAdaptiveWorldFaceTiles(
                        origin + halfU + halfV,
                        halfU,
                        halfV,
                        cameraPos,
                        depth + 1,
                        budget - count
                    );
                    return count;
                }

                if (splitU) {
                    count += CountAdaptiveWorldFaceTiles(
                        origin,
                        halfU,
                        vEdge,
                        cameraPos,
                        depth + 1,
                        budget - count
                    );
                    if (count >= budget) return count;
                    count += CountAdaptiveWorldFaceTiles(
                        origin + halfU,
                        halfU,
                        vEdge,
                        cameraPos,
                        depth + 1,
                        budget - count
                    );
                    return count;
                }

                count += CountAdaptiveWorldFaceTiles(
                    origin,
                    uEdge,
                    halfV,
                    cameraPos,
                    depth + 1,
                    budget - count
                );
                if (count >= budget) return count;
                count += CountAdaptiveWorldFaceTiles(
                    origin + halfV,
                    uEdge,
                    halfV,
                    cameraPos,
                    depth + 1,
                    budget - count
                );
                return count;
            }

            uint CollectAdaptiveWorldFaceFillDrawItems(
                array<WorldFillTileDrawItem@> @items,
                const array<vec3> @corners,
                const uint[]@ face,
                const vec3 &in cameraPos,
                const vec4 &in baseColor,
                uint boxIndex,
                uint faceIndex,
                const string &in tileIconTextureKey = ""
            ) {
                if (items is null) return 0;
                if (corners is null || face is null || face.Length != 4) return 0;
                vec3 origin = corners[face[0]];
                vec3 uEdge = corners[face[1]] - origin;
                vec3 vEdge = corners[face[3]] - origin;
                return CollectAdaptiveWorldFaceTileDrawItems(
                    items,
                    origin,
                    uEdge,
                    vEdge,
                    cameraPos,
                    baseColor,
                    GetFillTileColorSeed(boxIndex, faceIndex),
                    0,
                    FILL_TILE_MAX_TILES_PER_FACE,
                    tileIconTextureKey
                );
            }

            uint CountAdaptiveWorldFaceFillTiles(
                const array<vec3> @corners,
                const uint[]@ face,
                const vec3 &in cameraPos
            ) {
                if (corners is null || face is null || face.Length != 4) return 0;

                vec3 origin = corners[face[0]];
                vec3 uEdge = corners[face[1]] - origin;
                vec3 vEdge = corners[face[3]] - origin;
                return CountAdaptiveWorldFaceTiles(origin, uEdge, vEdge, cameraPos, 0, FILL_TILE_MAX_TILES_PER_FACE);
            }

            bool IsTriggerVolumeFaceCameraFacing(
                const array<vec3> @corners,
                const uint[]@ face,
                uint faceIndex,
                const vec3 &in cameraPos
            ) {
                if (corners is null || face is null || face.Length != 4) return false;

                vec3 center = vec3();
                for (uint i = 0; i < face.Length; i++) {
                    center += corners[face[i]];
                }
                center *= 0.25f;

                return Math::Dot(GetTriggerVolumeFaceNormal(faceIndex), cameraPos - center) > 0.0f;
            }

            uint CountTriggerVolumeCameraFacingFaces(const TriggerVolume@ box, const vec3 &in cameraPos) {
                if (box !is null && box.HasChildVolumes()) {
                    uint groupCount = 0;
                    for (uint i = 0; i < box.ChildVolumes.Length; i++) {
                        groupCount += CountTriggerVolumeCameraFacingFaces(box.ChildVolumes[i], cameraPos);
                    }
                    return groupCount;
                }
                if (box !is null && box.HasCustomOutlineGeometry()) return 0;

                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return 0;

                uint count = 0;
                for (uint i = 0; i < TRIGGER_VOLUME_FACE_INDICES.Length; i++) {
                    if (IsTriggerVolumeFaceCameraFacing(corners, TRIGGER_VOLUME_FACE_INDICES[i], i, cameraPos)) {
                        count++;
                    }
                }
                return count;
            }

            uint CountTriggerVolumesCameraFacingFacesForProximity(
                const array<TriggerVolume@> @boxes,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    if (!IsTriggerVolumeInRenderRangeForProximity(boxes[i], cameraPos, proximityState)) continue;
                    count += CountTriggerVolumeCameraFacingFaces(boxes[i], cameraPos);
                }
                return count;
            }

            uint CountTriggerVolumeFillTiles(const TriggerVolume@ box, const vec3 &in cameraPos) {
                if (box !is null && box.HasChildVolumes()) {
                    uint groupCount = 0;
                    for (uint i = 0; i < box.ChildVolumes.Length; i++) {
                        groupCount += CountTriggerVolumeFillTiles(box.ChildVolumes[i], cameraPos);
                    }
                    return groupCount;
                }
                if (box !is null && box.HasCustomOutlineGeometry()) return 0;

                if (ShouldRenderTriggerVolumeSimpleFill(box)) return CountTriggerVolumeCameraFacingFaces(
                    box,
                    cameraPos
                );
                if (!ShouldRenderTriggerVolumeFillTiles(box)) return 0;

                auto corners = GetTriggerVolumeCorners(box);
                if (corners.Length != 8) return 0;

                uint count = 0;
                for (uint i = 0; i < TRIGGER_VOLUME_FACE_INDICES.Length; i++) {
                    auto face = TRIGGER_VOLUME_FACE_INDICES[i];
                    if (!IsTriggerVolumeFaceCameraFacing(corners, face, i, cameraPos)) continue;
                    count += CountAdaptiveWorldFaceFillTiles(corners, face, cameraPos);
                }
                return count;
            }

            uint CountTriggerVolumesFillTilesForProximity(
                const array<TriggerVolume@> @boxes,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                if (boxes is null) return 0;

                uint count = 0;
                uint maxFrameTiles = uint(GetFillTileFrameSafetyLimit());
                for (uint i = 0; i < boxes.Length; i++) {
                    if (count >= maxFrameTiles) return count;
                    if (!IsTriggerVolumeInRenderRangeForProximity(boxes[i], cameraPos, proximityState)) continue;
                    uint remaining = maxFrameTiles - count;
                    uint boxCount = CountTriggerVolumeFillTiles(boxes[i], cameraPos);
                    if (boxCount > remaining) {
                        count += remaining;
                    } else {
                        count += boxCount;
                    }
                }
                return count;
            }
        }
    }
}
