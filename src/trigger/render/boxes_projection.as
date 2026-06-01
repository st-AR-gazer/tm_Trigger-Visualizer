namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            float GetScreenDistance(const vec2 &in start, const vec2 &in end) {
                vec2 delta = end - start;
                return Math::Sqrt(delta.x * delta.x + delta.y * delta.y);
            }

            vec2 NormalizeScreenVector(const vec2 &in value) {
                float length = Math::Sqrt(value.x * value.x + value.y * value.y);
                if (length <= 0.001f) return vec2();
                return value * (1.0f / length);
            }

            float DotScreen(const vec2 &in a, const vec2 &in b) {
                return a.x * b.x + a.y * b.y;
            }

            bool IsProjectedQuadPotentiallyVisible(
                const vec3 &in s0,
                const vec3 &in s1,
                const vec3 &in s2,
                const vec3 &in s3,
                float margin
            ) {
                if (s0.z >= 0 || s1.z >= 0 || s2.z >= 0 || s3.z >= 0) return false;
                if (!TriggerVisualizer::Trigger::UI::S_CullOffscreenWorldTiles) return true;

                int displayWidth = Display::GetWidth();
                int displayHeight = Display::GetHeight();
                if (displayWidth <= 0 || displayHeight <= 0) return true;

                float minX = Math::Min(Math::Min(s0.x, s1.x), Math::Min(s2.x, s3.x));
                float maxX = Math::Max(Math::Max(s0.x, s1.x), Math::Max(s2.x, s3.x));
                float minY = Math::Min(Math::Min(s0.y, s1.y), Math::Min(s2.y, s3.y));
                float maxY = Math::Max(Math::Max(s0.y, s1.y), Math::Max(s2.y, s3.y));
                if (maxX < -margin) return false;
                if (minX > float(displayWidth) + margin) return false;
                if (maxY < -margin) return false;
                if (minY > float(displayHeight) + margin) return false;
                return true;
            }

            bool IsProjectedLinePotentiallyVisible(const vec3 &in s0, const vec3 &in s1, float margin) {
                if (s0.z >= 0 || s1.z >= 0) return false;
                if (!TriggerVisualizer::Trigger::UI::S_CullOffscreenWorldTiles) return true;

                int displayWidth = Display::GetWidth();
                int displayHeight = Display::GetHeight();
                if (displayWidth <= 0 || displayHeight <= 0) return true;

                float minX = Math::Min(s0.x, s1.x);
                float maxX = Math::Max(s0.x, s1.x);
                float minY = Math::Min(s0.y, s1.y);
                float maxY = Math::Max(s0.y, s1.y);
                if (maxX < -margin) return false;
                if (minX > float(displayWidth) + margin) return false;
                if (maxY < -margin) return false;
                if (minY > float(displayHeight) + margin) return false;
                return true;
            }

            bool IsWorldQuadPotentiallyVisible(
                const vec3 &in p0,
                const vec3 &in p1,
                const vec3 &in p2,
                const vec3 &in p3,
                float margin
            ) {
                return IsProjectedQuadPotentiallyVisible(
                    Camera::ToScreen(p0),
                    Camera::ToScreen(p1),
                    Camera::ToScreen(p2),
                    Camera::ToScreen(p3),
                    margin
                );
            }

            bool GetProjectedQuadScreenBounds(
                const vec3 &in s0,
                const vec3 &in s1,
                const vec3 &in s2,
                const vec3 &in s3,
                float &out minX,
                float &out maxX,
                float &out minY,
                float &out maxY
            ) {
                if (s0.z >= 0 || s1.z >= 0 || s2.z >= 0 || s3.z >= 0) return false;

                minX = Math::Min(Math::Min(s0.x, s1.x), Math::Min(s2.x, s3.x));
                maxX = Math::Max(Math::Max(s0.x, s1.x), Math::Max(s2.x, s3.x));
                minY = Math::Min(Math::Min(s0.y, s1.y), Math::Min(s2.y, s3.y));
                maxY = Math::Max(Math::Max(s0.y, s1.y), Math::Max(s2.y, s3.y));
                return true;
            }

            bool UpdateWorldFillTileScreenProjection(WorldFillTileDrawItem@ item) {
                if (item is null) return false;
                item.Screen0 = Camera::ToScreen(item.Origin);
                item.Screen1 = Camera::ToScreen(item.Origin + item.UEdge);
                item.Screen2 = Camera::ToScreen(item.Origin + item.UEdge + item.VEdge);
                item.Screen3 = Camera::ToScreen(item.Origin + item.VEdge);
                item.HasScreenProjection = true;
                return IsProjectedQuadPotentiallyVisible(
                    item.Screen0,
                    item.Screen1,
                    item.Screen2,
                    item.Screen3,
                    SCREEN_QUAD_VISIBILITY_MARGIN
                );
            }

            float GetScreenTriangleSide(const vec2 &in point, const vec2 &in a, const vec2 &in b) {
                vec2 ab = b - a;
                vec2 ap = point - a;
                return ab.x * ap.y - ab.y * ap.x;
            }

            bool IsPointInsideScreenTriangle(
                const vec2 &in point,
                const vec2 &in a,
                const vec2 &in b,
                const vec2 &in c
            ) {
                float d0 = GetScreenTriangleSide(point, a, b);
                float d1 = GetScreenTriangleSide(point, b, c);
                float d2 = GetScreenTriangleSide(point, c, a);
                bool hasNegative = d0 < 0.0f || d1 < 0.0f || d2 < 0.0f;
                bool hasPositive = d0 > 0.0f || d1 > 0.0f || d2 > 0.0f;
                return !(hasNegative && hasPositive);
            }

            bool IsPointInsideProjectedQuad(
                const vec2 &in point,
                const vec3 &in s0,
                const vec3 &in s1,
                const vec3 &in s2,
                const vec3 &in s3
            ) {
                return IsPointInsideScreenTriangle(point, s0.xy, s1.xy, s2.xy)
                    || IsPointInsideScreenTriangle(point, s0.xy, s2.xy, s3.xy);
            }

            bool IsCellCoveredByProjectedQuad(
                int x,
                int y,
                int cellSize,
                const vec3 &in s0,
                const vec3 &in s1,
                const vec3 &in s2,
                const vec3 &in s3
            ) {
                float left = float(x * cellSize);
                float top = float(y * cellSize);
                float right = left + float(cellSize);
                float bottom = top + float(cellSize);
                vec2 center = vec2((left + right) * 0.5f, (top + bottom) * 0.5f);
                if (IsPointInsideProjectedQuad(center, s0, s1, s2, s3)) return true;
                if (IsPointInsideProjectedQuad(vec2(left, top), s0, s1, s2, s3)) return true;
                if (IsPointInsideProjectedQuad(vec2(right, top), s0, s1, s2, s3)) return true;
                if (IsPointInsideProjectedQuad(vec2(right, bottom), s0, s1, s2, s3)) return true;
                if (IsPointInsideProjectedQuad(vec2(left, bottom), s0, s1, s2, s3)) return true;
                return false;
            }

            int GetScreenOcclusionCellIndex(int x, int y, int columns) {
                return y * columns + x;
            }

            float GetProjectedQuadMaxScreenEdge(
                const vec3 &in s0,
                const vec3 &in s1,
                const vec3 &in s2,
                const vec3 &in s3
            ) {
                return Math::Max(
                    Math::Max(GetScreenDistance(s0.xy, s1.xy), GetScreenDistance(s1.xy, s2.xy)),
                    Math::Max(GetScreenDistance(s2.xy, s3.xy), GetScreenDistance(s3.xy, s0.xy))
                );
            }

            float GetProjectedQuadPerspectiveError(
                const vec3 &in s0,
                const vec3 &in s1,
                const vec3 &in s2,
                const vec3 &in s3
            ) {
                return GetScreenDistance(s2.xy, s1.xy + (s3.xy - s0.xy));
            }

            uint GetTexturedWorldQuadSubdivisionCount(
                const vec3 &in p0,
                const vec3 &in p1,
                const vec3 &in p2,
                const vec3 &in p3
            ) {
                vec3 s0 = Camera::ToScreen(p0);
                vec3 s1 = Camera::ToScreen(p1);
                vec3 s2 = Camera::ToScreen(p2);
                vec3 s3 = Camera::ToScreen(p3);
                if (!IsProjectedQuadPotentiallyVisible(s0, s1, s2, s3, SCREEN_QUAD_VISIBILITY_MARGIN)) return 0;

                int screenSizeSplits = int(Math::Ceil(GetProjectedQuadMaxScreenEdge(s0, s1, s2, s3) / SKULL_TILE_ICON_TARGET_PATCH_SCREEN_SIZE));
                int perspectiveSplits = int(Math::Ceil(GetProjectedQuadPerspectiveError(s0, s1, s2, s3) / SKULL_TILE_ICON_TARGET_PATCH_PERSPECTIVE_ERROR));
                int subdivisions = Math::Max(1, Math::Max(screenSizeSplits, perspectiveSplits));
                int maxSubdivisions = Math::Clamp(
                    TriggerVisualizer::Trigger::UI::S_TileIconMaxSubdivisions,
                    1,
                    int(SKULL_TILE_ICON_HARD_MAX_SUBDIVISIONS)
                );
                return uint(Math::Clamp(subdivisions, 1, maxSubdivisions));
            }

            bool DrawAffineTexturedWorldQuadPatch(
                const vec3 &in p0,
                const vec3 &in p1,
                const vec3 &in p2,
                const vec3 &in p3,
                nvg::Texture@ texture,
                float alpha,
                const vec2 &in uvMin,
                const vec2 &in uvMax
            ) {
                if (texture is null) return false;

                vec2 uvSize = uvMax - uvMin;
                if (uvSize.x <= 0.0001f || uvSize.y <= 0.0001f) return false;

                vec3 s0 = Camera::ToScreen(p0);
                vec3 s1 = Camera::ToScreen(p1);
                vec3 s2 = Camera::ToScreen(p2);
                vec3 s3 = Camera::ToScreen(p3);
                if (!IsProjectedQuadPotentiallyVisible(s0, s1, s2, s3, SCREEN_QUAD_VISIBILITY_MARGIN)) return false;

                vec2 xEdge = s1.xy - s0.xy;
                vec2 yEdge = s3.xy - s0.xy;
                vec2 xAxis = NormalizeScreenVector(xEdge);
                if (xAxis.x == 0.0f && xAxis.y == 0.0f) return false;

                float xLen = GetScreenDistance(s0.xy, s1.xy);
                if (xLen < SKULL_TILE_ICON_MIN_SCREEN_SIZE) return false;

                vec2 yAxis = vec2(-xAxis.y, xAxis.x);
                float yParallel = DotScreen(yEdge, xAxis);
                float yPerpendicular = DotScreen(yEdge, yAxis);
                if (Math::Abs(yPerpendicular) < SKULL_TILE_ICON_MIN_SCREEN_SIZE) return false;

                vec2 p2Delta = s2.xy - s0.xy;
                float p2LocalY = DotScreen(p2Delta, yAxis) / yPerpendicular;
                float p2LocalX = (DotScreen(p2Delta, xAxis) - yParallel * p2LocalY) / xLen;
                vec2 patternOrigin = vec2(-uvMin.x / uvSize.x, -uvMin.y / uvSize.y);
                vec2 patternSize = vec2(1.0f / uvSize.x, 1.0f / uvSize.y);
                nvg::Save();
                nvg::Translate(s0.xy);
                nvg::Rotate(Math::Atan2(xAxis.y, xAxis.x));
                nvg::SkewX(Math::Atan2(yParallel, yPerpendicular));
                nvg::Scale(xLen, yPerpendicular);
                nvg::BeginPath();
                nvg::MoveTo(vec2(0.0f, 0.0f));
                nvg::LineTo(vec2(1.0f, 0.0f));
                nvg::LineTo(vec2(p2LocalX, p2LocalY));
                nvg::LineTo(vec2(0.0f, 1.0f));
                nvg::ClosePath();
                nvg::FillPaint(nvg::TexturePattern(patternOrigin, patternSize, 0.0f, texture, alpha));
                nvg::Fill();
                nvg::Restore();
                return true;
            }

            bool DrawSubdividedTexturedWorldQuad(
                const vec3 &in p0,
                const vec3 &in p1,
                const vec3 &in p2,
                const vec3 &in p3,
                nvg::Texture@ texture,
                float alpha
            ) {
                if (texture is null) return false;

                uint subdivisions = GetTexturedWorldQuadSubdivisionCount(p0, p1, p2, p3);
                if (subdivisions == 0) return false;
                if (G_TileIconPatchBudgetRemaining == 0) return false;

                uint patchCount = subdivisions * subdivisions;
                if (patchCount > G_TileIconPatchBudgetRemaining) {
                    uint budgetedSubdivisions = uint(Math::Floor(Math::Sqrt(float(G_TileIconPatchBudgetRemaining))));
                    if (budgetedSubdivisions == 0) return false;
                    if (subdivisions > budgetedSubdivisions) {
                        subdivisions = budgetedSubdivisions;
                    }
                    patchCount = subdivisions * subdivisions;
                }

                bool drewAny = false;
                vec3 rightEdge = p1 - p0;
                vec3 downEdge = p3 - p0;
                float step = 1.0f / float(subdivisions);
                for (uint y = 0; y < subdivisions; y++) {
                    float v0 = float(y) * step;
                    float v1 = float(y + 1) * step;
                    for (uint x = 0; x < subdivisions; x++) {
                        float u0 = float(x) * step;
                        float u1 = float(x + 1) * step;
                        vec3 q0 = p0 + rightEdge * u0 + downEdge * v0;
                        vec3 q1 = p0 + rightEdge * u1 + downEdge * v0;
                        vec3 q2 = p0 + rightEdge * u1 + downEdge * v1;
                        vec3 q3 = p0 + rightEdge * u0 + downEdge * v1;
                        drewAny = DrawAffineTexturedWorldQuadPatch(
                            q0,
                            q1,
                            q2,
                            q3,
                            texture,
                            alpha,
                            vec2(u0, v0),
                            vec2(u1, v1)
                        ) || drewAny;
                    }
                }
                if (patchCount >= G_TileIconPatchBudgetRemaining) {
                    G_TileIconPatchBudgetRemaining = 0;
                } else {
                    G_TileIconPatchBudgetRemaining -= patchCount;
                }

                return drewAny;
            }

            vec3 NormalizeWorldVector(const vec3 &in value) {
                float length = Math::Sqrt(Math::Dot(value, value));
                if (length <= 0.0001f) return vec3();
                return value * (1.0f / length);
            }

            vec3 GetPositiveWorldDirection(const vec3 &in direction) {
                vec3 normalized = NormalizeWorldVector(direction);
                if (normalized.x < -0.001f) return normalized * -1.0f;
                if (Math::Abs(normalized.x) <= 0.001f && normalized.z < -0.001f) return normalized * -1.0f;
                return normalized;
            }

            bool DrawTileIconOnWorldTile(
                const vec3 &in origin,
                const vec3 &in uEdge,
                const vec3 &in vEdge,
                nvg::Texture@ texture
            ) {
                if (!ShouldRenderWorldTileIconsNow()) return false;
                if (G_TileIconPatchBudgetRemaining == 0) return false;
                if (texture is null) return false;

                float uLen = Math::Distance(origin, origin + uEdge);
                float vLen = Math::Distance(origin, origin + vEdge);
                float iconSize = Math::Min(uLen, vLen) * TriggerVisualizer::Trigger::UI::S_SkullTileIconScale;
                if (iconSize <= 0.001f) return false;

                vec3 center = origin + (uEdge + vEdge) * 0.5f;
                vec3 uDir = NormalizeWorldVector(uEdge);
                vec3 vDir = NormalizeWorldVector(vEdge);
                if (uDir == vec3() || vDir == vec3()) return false;

                vec3 rightDir = uDir;
                vec3 downDir = vDir;
                bool uIsVertical = Math::Abs(uDir.y) > Math::Abs(vDir.y) && Math::Abs(uDir.y) > 0.5f;
                bool vIsVertical = Math::Abs(vDir.y) >= Math::Abs(uDir.y) && Math::Abs(vDir.y) > 0.5f;
                if (uIsVertical || vIsVertical) {
                    vec3 upDir = uIsVertical ? uDir : vDir;
                    if (upDir.y < 0.0f) upDir *= -1.0f;

                    rightDir = GetPositiveWorldDirection(uIsVertical ? vDir : uDir);
                    downDir = upDir * -1.0f;
                }

                vec3 halfRight = rightDir * iconSize * 0.5f;
                vec3 halfDown = downDir * iconSize * 0.5f;
                vec3 p0 = center - halfRight - halfDown;
                vec3 p1 = center + halfRight - halfDown;
                vec3 p2 = center + halfRight + halfDown;
                vec3 p3 = center - halfRight + halfDown;
                if (!IsWorldQuadPotentiallyVisible(p0, p1, p2, p3, SCREEN_QUAD_VISIBILITY_MARGIN)) return false;

                return DrawSubdividedTexturedWorldQuad(
                    p0,
                    p1,
                    p2,
                    p3,
                    texture,
                    TriggerVisualizer::Trigger::UI::S_SkullTileIconAlpha
                );
            }

            bool DrawProjectedQuad(
                const vec3 &in p0,
                const vec3 &in p1,
                const vec3 &in p2,
                const vec3 &in p3,
                const vec4 &in color
            ) {
                vec3 s0 = Camera::ToScreen(p0);
                vec3 s1 = Camera::ToScreen(p1);
                vec3 s2 = Camera::ToScreen(p2);
                vec3 s3 = Camera::ToScreen(p3);
                if (!IsProjectedQuadPotentiallyVisible(s0, s1, s2, s3, SCREEN_QUAD_VISIBILITY_MARGIN)) return false;

                bool drewFill = false;
                if (color.w > 0.001f) {
                    nvg::BeginPath();
                    nvg::FillColor(color);
                    nvg::MoveTo(s0.xy);
                    nvg::LineTo(s1.xy);
                    nvg::LineTo(s2.xy);
                    nvg::LineTo(s3.xy);
                    nvg::ClosePath();
                    nvg::Fill();
                    drewFill = true;
                }

                return drewFill;
            }
        }
    }
}
