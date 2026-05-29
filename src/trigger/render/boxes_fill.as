namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            float GetDistanceToWorldQuad(
                const vec3 &in point,
                const vec3 &in origin,
                const vec3 &in uEdge,
                const vec3 &in vEdge
            ) {
                float uLenSq = Math::Dot(uEdge, uEdge);
                float vLenSq = Math::Dot(vEdge, vEdge);
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
                uint budget
            ) {
                if (items is null) return 0;
                if (budget == 0) return 0;
                if (!ConsumeWorldFillTileTraversalBudget()) return 0;

                vec3 p0 = origin;
                vec3 p1 = origin + uEdge;
                vec3 p2 = origin + uEdge + vEdge;
                vec3 p3 = origin + vEdge;
                int primitiveClass = ClassifyWorldQuadForFrustum(p0, p1, p2, p3);
                if (primitiveClass == WORLD_PRIMITIVE_OUTSIDE) return 0;
                bool isMixed = primitiveClass == WORLD_PRIMITIVE_MIXED;

                int maxFrameTiles = Math::Max(TriggerVisualizer::Trigger::UI::S_MaxFillTilesPerFrame, 1);
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
                        budget - drawn
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
                        budget - drawn
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
                        budget - drawn
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
                        budget - drawn
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
                        budget - drawn
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
                        budget - drawn
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
                    budget - drawn
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
                    budget - drawn
                );
                return drawn;
            }

            bool AreFillTileColorsEquivalent(const vec4 &in a, const vec4 &in b) {
                return Math::Abs(a.x - b.x) <= 0.0001f
                    && Math::Abs(a.y - b.y) <= 0.0001f
                    && Math::Abs(a.z - b.z) <= 0.0001f
                    && Math::Abs(a.w - b.w) <= 0.0001f;
            }

            bool AreAllWorldFillTileColorsEquivalent(array<WorldFillTileDrawItem@> @items) {
                if (items is null || items.Length <= 1) return true;

                uint firstIndex = 0;
                while (firstIndex < items.Length && items[firstIndex] is null) {
                    firstIndex++;
                }
                if (firstIndex >= items.Length) return true;

                vec4 color = items[firstIndex].Color;
                for (uint i = firstIndex + 1; i < items.Length; i++) {
                    if (items[i] is null) continue;
                    if (!AreFillTileColorsEquivalent(items[i].Color, color)) return false;
                }
                return true;
            }

            bool ShouldSortWorldFillTileDrawItems(array<WorldFillTileDrawItem@> @items) {
                return items !is null && items.Length > 1;
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
                    nvg::BeginPath();
                    if (AddWorldFillTilePath(items[i])) {
                        nvg::Fill();
                    }
                    nvg::ClosePath();
                }
            }

            void DrawWorldFillTileIconBatch(array<WorldFillTileDrawItem@> @items, uint startIndex, uint endIndex) {
                if (items is null || !TriggerVisualizer::Trigger::UI::S_ShowSkullTileIcons) return;

                for (uint i = startIndex; i < endIndex && i < items.Length; i++) {
                    if (items[i] is null || items[i].Occluded || !items[i].AllowTileIcon) continue;
                    DrawSkullTileIconOnWorldTile(items[i].Origin, items[i].UEdge, items[i].VEdge);
                }
            }

            void SortWorldFillTileDrawItemsBackToFront(array<WorldFillTileDrawItem@> @items) {
                if (items is null || items.Length <= 1) return;

                uint gap = items.Length / 2;
                while (gap > 0) {
                    for (uint i = gap; i < items.Length; i++) {
                        WorldFillTileDrawItem@ item = items[i];
                        uint j = i;

                        while (j >= gap && items[j - gap].SortDistanceSq < item.SortDistanceSq) {
                            @items[j] = items[j - gap];
                            j -= gap;
                        }

                        @items[j] = item;
                    }

                    gap /= 2;
                }
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

            void MarkScreenOccludedWorldFillTileDrawItems(array<WorldFillTileDrawItem@> @items) {
                if (items is null || items.Length <= 1) return;
                if (!TriggerVisualizer::Trigger::UI::S_CullScreenOccludedWorldTiles) return;

                int displayWidth = Display::GetWidth();
                int displayHeight = Display::GetHeight();
                if (displayWidth <= 0 || displayHeight <= 0) return;

                int cellSize = Math::Clamp(TriggerVisualizer::Trigger::UI::S_ScreenOcclusionCellSize, 8, 256);
                int columns = Math::Max(1, int(Math::Ceil(float(displayWidth) / float(cellSize))));
                int rows = Math::Max(1, int(Math::Ceil(float(displayHeight) / float(cellSize))));
                auto occupied = array<bool>(uint(columns * rows), false);

                for (int i = int(items.Length) - 1; i >= 0; i--) {
                    WorldFillTileDrawItem@ item = items[uint(i)];
                    if (item is null) continue;

                    item.Occluded = false;

                    float minX = 0.0f;
                    float maxX = 0.0f;
                    float minY = 0.0f;
                    float maxY = 0.0f;
                    vec3 s0 = vec3();
                    vec3 s1 = vec3();
                    vec3 s2 = vec3();
                    vec3 s3 = vec3();
                    if (!item.HasScreenProjection && !UpdateWorldFillTileScreenProjection(item)) {
                        item.Occluded = true;
                        continue;
                    }
                    s0 = item.Screen0;
                    s1 = item.Screen1;
                    s2 = item.Screen2;
                    s3 = item.Screen3;

                    if (!GetProjectedQuadScreenBounds(s0, s1, s2, s3, minX, maxX, minY, maxY)) {
                        item.Occluded = true;
                        continue;
                    }

                    if (maxX < 0.0f || minX > float(displayWidth) || maxY < 0.0f || minY > float(displayHeight)) {
                        item.Occluded = true;
                        continue;
                    }

                    int minCellX = Math::Clamp(int(Math::Floor(minX / float(cellSize))), 0, columns - 1);
                    int maxCellX = Math::Clamp(int(Math::Floor(maxX / float(cellSize))), 0, columns - 1);
                    int minCellY = Math::Clamp(int(Math::Floor(minY / float(cellSize))), 0, rows - 1);
                    int maxCellY = Math::Clamp(int(Math::Floor(maxY / float(cellSize))), 0, rows - 1);

                    bool hasCell = false;
                    bool fullyCovered = true;
                    for (int y = minCellY; y <= maxCellY; y++) {
                        for (int x = minCellX; x <= maxCellX; x++) {
                            if (!IsCellCoveredByProjectedQuad(x, y, cellSize, s0, s1, s2, s3)) continue;

                            hasCell = true;
                            if (!occupied[uint(GetScreenOcclusionCellIndex(x, y, columns))]) {
                                fullyCovered = false;
                            }
                        }
                    }

                    if (hasCell && fullyCovered) {
                        item.Occluded = true;
                        continue;
                    }

                    for (int y = minCellY; y <= maxCellY; y++) {
                        for (int x = minCellX; x <= maxCellX; x++) {
                            if (!IsCellCoveredByProjectedQuad(x, y, cellSize, s0, s1, s2, s3)) continue;

                            occupied[uint(GetScreenOcclusionCellIndex(x, y, columns))] = true;
                        }
                    }
                }
            }

            void DrawWorldFillTileDrawItems(array<WorldFillTileDrawItem@> @items) {
                if (items is null || items.Length == 0) return;

                bool sorted = ShouldSortWorldFillTileDrawItems(items);
                if (sorted) {
                    SortWorldFillTileDrawItemsBackToFront(items);
                }
                MarkDuplicateWorldFillTileDrawItems(items);
                MarkScreenOccludedWorldFillTileDrawItems(items);

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
                    count += CountAdaptiveWorldFaceTiles(origin, halfU, halfV, cameraPos, depth + 1, budget - count);
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
                    count += CountAdaptiveWorldFaceTiles(origin, halfU, vEdge, cameraPos, depth + 1, budget - count);
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

                count += CountAdaptiveWorldFaceTiles(origin, uEdge, halfV, cameraPos, depth + 1, budget - count);
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
                uint faceIndex
            ) {
                if (items is null) return 0;
                if (corners is null || face is null || face.Length != 4) return 0;
                if (G_FillTileTraversalBudgetRemaining == 0) return 0;

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
                    FILL_TILE_MAX_TILES_PER_FACE
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

            uint CountTriggerVolumesCameraFacingFaces(const array<TriggerVolume@> @boxes, const vec3 &in cameraPos) {
                if (boxes is null) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    if (!IsTriggerVolumeInRenderRange(boxes[i], cameraPos)) continue;
                    count += CountTriggerVolumeCameraFacingFaces(boxes[i], cameraPos);
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
                uint maxFrameTiles = uint(Math::Max(TriggerVisualizer::Trigger::UI::S_MaxFillTilesPerFrame, 1));
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
