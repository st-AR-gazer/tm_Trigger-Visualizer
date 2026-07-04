namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                const uint CRYSTAL_OUTLINE_CIRCLE_SEGMENTS = 24;
                const uint MAX_CRYSTAL_OUTLINE_LINES = 768;
                const uint MAX_CRYSTAL_MESH_OUTLINE_TRIS = 1024;
                const float CRYSTAL_MIN_OUTLINE_LINE_LENGTH = 0.001f;
                const uint[][] CRYSTAL_OUTLINE_BOX_EDGE_INDICES = {
                    {0, 1}, {1, 2}, {2, 3}, {3, 0},
                    {4, 5}, {5, 6}, {6, 7}, {7, 4},
                    {0, 4}, {1, 5}, {2, 6}, {3, 7}
                };
                class CrystalOutlineWarningSink {
                    string Warning;

                    void Append(const string &in next) {
                        Warning = CrystalAppendWarning(Warning, next);
                    }
                }

                class CrystalOutlineLineBuffer {
                    array<vec3> Starts;
                    array<vec3> Ends;

                    uint Count() const {
                        return Starts.Length < Ends.Length ? Starts.Length : Ends.Length;
                    }

                    void Add(const vec3 &in start, const vec3 &in end) {
                        Starts.InsertLast(start);
                        Ends.InsertLast(end);
                    }
                }

                vec3 CrystalCrossVec3(const vec3 &in a, const vec3 &in b) {
                    return vec3(
                        a.y * b.z - a.z * b.y,
                        a.z * b.x - a.x * b.z,
                        a.x * b.y - a.y * b.x
                    );
                }

                vec3 CrystalNormalizeOr(const vec3 &in value, const vec3 &in fallback) {
                    if (!CrystalIsFiniteVec3(value)) return fallback;
                    float lengthSq = value.LengthSquared();
                    if (!CrystalIsFiniteFloat(lengthSq) || lengthSq <= 0.000001f) return fallback;
                    return value.Normalized();
                }

                void CrystalBuildPerpendicularBasis(const vec3 &in dir, vec3 &out u, vec3 &out v) {
                    vec3 axis = CrystalNormalizeOr(dir, vec3(0.0f, 1.0f, 0.0f));
                    vec3 seed = Math::Abs(axis.y) < 0.9f ? vec3(0.0f, 1.0f, 0.0f) : vec3(1.0f, 0.0f, 0.0f);
                    u = CrystalNormalizeOr(CrystalCrossVec3(axis, seed), vec3(1.0f, 0.0f, 0.0f));
                    v = CrystalNormalizeOr(CrystalCrossVec3(axis, u), vec3(0.0f, 0.0f, 1.0f));
                }

                bool CrystalValidateOutlinePoint(const vec3 &in point, bool worldSpace, string &out warning) {
                    warning = "";
                    if (!CrystalIsFiniteVec3(point)) {
                        warning = "Outline point contains NaN or Inf.";
                        return false;
                    }
                    if (worldSpace) {
                        vec3 absPoint = CrystalAbsVec3(point);
                        if (absPoint.x > CRYSTAL_MAX_ABS_WORLD_COORD || absPoint.y > CRYSTAL_MAX_ABS_WORLD_COORD || absPoint.z > CRYSTAL_MAX_ABS_WORLD_COORD) {
                            warning = "Outline point is outside the world sanity limit.";
                            return false;
                        }
                    }
                    return true;
                }

                bool CrystalAddOutlineLine(
                    CrystalOutlineLineBuffer@ lines,
                    const vec3 &in start,
                    const vec3 &in end,
                    bool worldSpace,
                    string &out warning
                ) {
                    warning = "";
                    if (lines is null) return false;
                    if (lines.Count() >= MAX_CRYSTAL_OUTLINE_LINES) {
                        warning = "Crystal outline line cap reached.";
                        return false;
                    }

                    string pointWarning = "";
                    if (!CrystalValidateOutlinePoint(start, worldSpace, pointWarning)) {
                        warning = pointWarning;
                        return false;
                    }
                    if (!CrystalValidateOutlinePoint(end, worldSpace, pointWarning)) {
                        warning = pointWarning;
                        return false;
                    }
                    if (Math::Distance2(start, end) <= CRYSTAL_MIN_OUTLINE_LINE_LENGTH * CRYSTAL_MIN_OUTLINE_LINE_LENGTH) {
                        warning = "Crystal outline line is zero or near-zero.";
                        return false;
                    }

                    lines.Add(start, end);
                    return true;
                }

                void CrystalAppendOutlineWarning(CrystalOutlineWarningSink@ warnings, const string &in next) {
                    if (warnings is null) return;
                    warnings.Append(next);
                }

                bool CrystalAddOutlineLineBestEffort(
                    CrystalOutlineLineBuffer@ lines,
                    const vec3 &in start,
                    const vec3 &in end,
                    bool worldSpace,
                    CrystalOutlineWarningSink@ warnings
                ) {
                    string lineWarning = "";
                    bool added = CrystalAddOutlineLine(lines, start, end, worldSpace, lineWarning);
                    if (!added && lineWarning.Length > 0) {
                        CrystalAppendOutlineWarning(
                            warnings,
                            lineWarning
                        );
                    }
                    return added;
                }

                vec3 CrystalBoxCorner(const vec3 &in min, const vec3 &in max, uint index) {
                    if (index == 0) return vec3(min.x, min.y, min.z);
                    if (index == 1) return vec3(max.x, min.y, min.z);
                    if (index == 2) return vec3(max.x, max.y, min.z);
                    if (index == 3) return vec3(min.x, max.y, min.z);
                    if (index == 4) return vec3(min.x, min.y, max.z);
                    if (index == 5) return vec3(max.x, min.y, max.z);
                    if (index == 6) return vec3(max.x, max.y, max.z);
                    return vec3(
                        min.x,
                        max.y,
                        max.z
                    );
                }

                bool CrystalAddBoxOutlineLines(
                    CrystalOutlineLineBuffer@ lines,
                    const vec3 &in rawMin,
                    const vec3 &in rawMax,
                    CrystalOutlineWarningSink@ warnings
                ) {
                    vec3 min;
                    vec3 max;
                    CrystalNormalizeBounds(rawMin, rawMax, min, max);
                    uint before = lines.Count();

                    for (uint i = 0; i < CRYSTAL_OUTLINE_BOX_EDGE_INDICES.Length; i++) {
                        auto edge = CRYSTAL_OUTLINE_BOX_EDGE_INDICES[i];
                        if (!CrystalAddOutlineLineBestEffort(lines, CrystalBoxCorner(min, max, edge[0]), CrystalBoxCorner(min, max, edge[1]), false, warnings)) {
                            if (lines.Count() >= MAX_CRYSTAL_OUTLINE_LINES) break;
                        }
                    }
                    return lines.Count() > before;
                }

                bool CrystalAddRingOutlineLines(
                    CrystalOutlineLineBuffer@ lines,
                    const vec3 &in center,
                    const vec3 &in uAxis,
                    const vec3 &in vAxis,
                    CrystalOutlineWarningSink@ warnings
                ) {
                    uint before = lines.Count();
                    float step = Math::PI * 2.0f / float(CRYSTAL_OUTLINE_CIRCLE_SEGMENTS);
                    for (uint i = 0; i < CRYSTAL_OUTLINE_CIRCLE_SEGMENTS; i++) {
                        float a0 = float(i) * step;
                        float a1 = float(i + 1) * step;
                        vec3 p0 = center + uAxis * Math::Cos(a0) + vAxis * Math::Sin(a0);
                        vec3 p1 = center + uAxis * Math::Cos(a1) + vAxis * Math::Sin(a1);
                        if (!CrystalAddOutlineLineBestEffort(lines, p0, p1, false, warnings)) {
                            if (lines.Count() >= MAX_CRYSTAL_OUTLINE_LINES) break;
                        }
                    }
                    return lines.Count() > before;
                }

                bool CrystalAddArcOutlineLines(
                    CrystalOutlineLineBuffer@ lines,
                    const vec3 &in center,
                    const vec3 &in fromAxis,
                    const vec3 &in toAxis,
                    CrystalOutlineWarningSink@ warnings
                ) {
                    uint before = lines.Count();
                    uint segments = CRYSTAL_OUTLINE_CIRCLE_SEGMENTS / 2;
                    float step = Math::PI / float(segments);
                    for (uint i = 0; i < segments; i++) {
                        float a0 = float(i) * step;
                        float a1 = float(i + 1) * step;
                        vec3 p0 = center + fromAxis * Math::Cos(a0) + toAxis * Math::Sin(a0);
                        vec3 p1 = center + fromAxis * Math::Cos(a1) + toAxis * Math::Sin(a1);
                        if (!CrystalAddOutlineLineBestEffort(lines, p0, p1, false, warnings)) {
                            if (lines.Count() >= MAX_CRYSTAL_OUTLINE_LINES) break;
                        }
                    }
                    return lines.Count() > before;
                }

                bool CrystalAddSphereOutlineLines(
                    CrystalOutlineLineBuffer@ lines,
                    const vec3 &in center,
                    float radius,
                    CrystalOutlineWarningSink@ warnings
                ) {
                    radius = Math::Abs(radius);
                    if (!CrystalIsFiniteFloat(radius) || radius <= CRYSTAL_MIN_VOLUME_AXIS_SIZE) {
                        CrystalAppendOutlineWarning(
                            warnings,
                            "Sphere outline radius is invalid."
                        );
                        return false;
                    }

                    uint before = lines.Count();
                    CrystalAddRingOutlineLines(
                        lines,
                        center,
                        vec3(radius, 0.0f, 0.0f),
                        vec3(0.0f, radius, 0.0f),
                        warnings
                    );
                    CrystalAddRingOutlineLines(
                        lines,
                        center,
                        vec3(radius, 0.0f, 0.0f),
                        vec3(0.0f, 0.0f, radius),
                        warnings
                    );
                    CrystalAddRingOutlineLines(
                        lines,
                        center,
                        vec3(0.0f, radius, 0.0f),
                        vec3(0.0f, 0.0f, radius),
                        warnings
                    );
                    return lines.Count() > before;
                }

                bool CrystalAddCylinderOutlineLines(
                    CrystalOutlineLineBuffer@ lines,
                    float halfHeight,
                    float radius,
                    CrystalOutlineWarningSink@ warnings
                ) {
                    halfHeight = Math::Abs(halfHeight);
                    radius = Math::Abs(radius);
                    if (!CrystalIsFiniteFloat(halfHeight) || !CrystalIsFiniteFloat(radius) || halfHeight <= CRYSTAL_MIN_VOLUME_AXIS_SIZE || radius <= CRYSTAL_MIN_VOLUME_AXIS_SIZE) {
                        CrystalAppendOutlineWarning(
                            warnings,
                            "Cylinder outline dimensions are invalid."
                        );
                        return false;
                    }

                    uint before = lines.Count();
                    vec3 u = vec3(radius, 0.0f, 0.0f);
                    vec3 v = vec3(0.0f, 0.0f, radius);
                    vec3 top = vec3(0.0f, halfHeight, 0.0f);
                    vec3 bottom = vec3(0.0f, -halfHeight, 0.0f);
                    CrystalAddRingOutlineLines(
                        lines,
                        top,
                        u,
                        v,
                        warnings
                    );
                    CrystalAddRingOutlineLines(
                        lines,
                        bottom,
                        u,
                        v,
                        warnings
                    );

                    for (uint i = 0; i < 4; i++) {
                        float angle = Math::PI * 0.5f * float(i);
                        vec3 radial = u * Math::Cos(angle) + v * Math::Sin(angle);
                        CrystalAddOutlineLineBestEffort(lines, bottom + radial, top + radial, false, warnings);
                    }
                    return lines.Count() > before;
                }

                bool CrystalAddCapsuleOutlineLines(
                    CrystalOutlineLineBuffer@ lines,
                    const vec3 &in center,
                    const vec3 &in rawDir,
                    float radius,
                    float length,
                    CrystalOutlineWarningSink@ warnings
                ) {
                    radius = Math::Abs(radius);
                    length = Math::Abs(length);
                    if (!CrystalIsFiniteFloat(radius) || !CrystalIsFiniteFloat(length) || radius <= CRYSTAL_MIN_VOLUME_AXIS_SIZE) {
                        CrystalAppendOutlineWarning(
                            warnings,
                            "Capsule outline dimensions are invalid."
                        );
                        return false;
                    }

                    vec3 dir = CrystalNormalizeOr(rawDir, vec3(0.0f, 1.0f, 0.0f));
                    vec3 uUnit;
                    vec3 vUnit;
                    CrystalBuildPerpendicularBasis(dir, uUnit, vUnit);
                    vec3 u = uUnit * radius;
                    vec3 v = vUnit * radius;
                    vec3 axis = dir * length;
                    vec3 a = center - axis;
                    vec3 b = center + axis;
                    uint before = lines.Count();
                    CrystalAddRingOutlineLines(
                        lines,
                        a,
                        u,
                        v,
                        warnings
                    );
                    CrystalAddRingOutlineLines(
                        lines,
                        b,
                        u,
                        v,
                        warnings
                    );
                    CrystalAddOutlineLineBestEffort(lines, a + u, b + u, false, warnings);
                    CrystalAddOutlineLineBestEffort(lines, a - u, b - u, false, warnings);
                    CrystalAddOutlineLineBestEffort(lines, a + v, b + v, false, warnings);
                    CrystalAddOutlineLineBestEffort(lines, a - v, b - v, false, warnings);
                    CrystalAddArcOutlineLines(
                        lines,
                        b,
                        u,
                        axis.LengthSquared() > 0.000001f ? dir * radius : vec3(0.0f, radius, 0.0f),
                        warnings
                    );
                    CrystalAddArcOutlineLines(
                        lines,
                        b,
                        v,
                        axis.LengthSquared() > 0.000001f ? dir * radius : vec3(0.0f, radius, 0.0f),
                        warnings
                    );
                    CrystalAddArcOutlineLines(
                        lines,
                        a,
                        u,
                        axis.LengthSquared() > 0.000001f ? dir * radius * -1.0f : vec3(0.0f, -radius, 0.0f),
                        warnings
                    );
                    CrystalAddArcOutlineLines(
                        lines,
                        a,
                        v,
                        axis.LengthSquared() > 0.000001f ? dir * radius * -1.0f : vec3(0.0f, -radius, 0.0f),
                        warnings
                    );
                    return lines.Count() > before;
                }

                bool CrystalAppendTransformedOutlineLines(
                    CrystalOutlineLineBuffer@ target,
                    CrystalOutlineLineBuffer@ source,
                    const mat4 &in transform,
                    bool worldSpace,
                    CrystalOutlineWarningSink@ warnings
                ) {
                    if (target is null || source is null) return false;
                    uint before = target.Count();
                    uint count = source.Count();
                    for (uint i = 0; i < count; i++) {
                        vec3 start = CrystalTransformPoint(transform, source.Starts[i]);
                        vec3 end = CrystalTransformPoint(transform, source.Ends[i]);
                        if (!CrystalAddOutlineLineBestEffort(target, start, end, worldSpace, warnings)) {
                            if (target.Count() >= MAX_CRYSTAL_OUTLINE_LINES) break;
                        }
                    }
                    return target.Count() > before;
                }

                bool CrystalAddMeshOutlineLines(
                    CrystalOutlineLineBuffer@ lines,
                    GmSurfMesh@ mesh,
                    CrystalOutlineWarningSink@ warnings
                ) {
                    if (mesh is null || mesh.m_Verts.Length == 0 || mesh.m_Tris.Length == 0) return false;

                    uint before = lines.Count();
                    uint count = CrystalMinUint(
                        mesh.m_Tris.Length,
                        MAX_CRYSTAL_MESH_OUTLINE_TRIS
                    );
                    for (uint i = 0; i < count; i++) {
                        auto tri = mesh.m_Tris[i];
                        uint i0 = tri.VertIndices_0_;
                        uint i1 = tri.VertIndices_1_;
                        uint i2 = tri.VertIndices_2_;
                        if (i0 >= mesh.m_Verts.Length || i1 >= mesh.m_Verts.Length || i2 >= mesh.m_Verts.Length) {
                            CrystalAppendOutlineWarning(
                                warnings,
                                "GmSurfMesh outline skipped a triangle with invalid vertex indices."
                            );
                            continue;
                        }

                        vec3 p0 = mesh.m_Verts[i0];
                        vec3 p1 = mesh.m_Verts[i1];
                        vec3 p2 = mesh.m_Verts[i2];
                        CrystalAddOutlineLineBestEffort(lines, p0, p1, false, warnings);
                        CrystalAddOutlineLineBestEffort(lines, p1, p2, false, warnings);
                        CrystalAddOutlineLineBestEffort(lines, p2, p0, false, warnings);
                        if (lines.Count() >= MAX_CRYSTAL_OUTLINE_LINES) break;
                    }
                    if (mesh.m_Tris.Length > count) {
                        CrystalAppendOutlineWarning(
                            warnings,
                            "GmSurfMesh outline used first " + tostring(count) + " triangles."
                        );
                    }
                    return lines.Count() > before;
                }

                bool BuildCrystalGmSurfLocalOutlineLinesWithWarnings(
                    GmSurf@ surf,
                    CrystalOutlineLineBuffer@ lines,
                    CrystalOutlineWarningSink@ warnings,
                    uint depth = 0
                ) {
                    if (surf is null || lines is null) return false;
                    if (depth > MAX_CRYSTAL_BOUNDS_RECURSION) {
                        CrystalAppendOutlineWarning(
                            warnings,
                            "GmSurf outline recursion limit reached."
                        );
                        return false;
                    }
                    if (lines.Count() >= MAX_CRYSTAL_OUTLINE_LINES) return false;

                    uint before = lines.Count();
                    auto sphere = cast<GmSurfSphereLocated>(surf);
                    if (sphere !is null) {
                        CrystalAddSphereOutlineLines(lines, sphere.Center, sphere.Radius, warnings);
                        return lines.Count() > before;
                    }

                    auto box = cast<GmSurfBox>(surf);
                    if (box !is null) {
                        CrystalAddBoxOutlineLines(
                            lines,
                            box.AABB.m_Center - box.AABB.m_HalfDiag,
                            box.AABB.m_Center + box.AABB.m_HalfDiag,
                            warnings
                        );
                        return lines.Count() > before;
                    }

                    auto verticalCylinder = cast<GmSurfVCylinder>(surf);
                    if (verticalCylinder !is null) {
                        CrystalAddCylinderOutlineLines(
                            lines,
                            Math::Abs(verticalCylinder.Height) * 0.5f,
                            verticalCylinder.Radius,
                            warnings
                        );
                        return lines.Count() > before;
                    }

                    auto cylinder = cast<GmSurfCylinder>(surf);
                    if (cylinder !is null) {
                        CrystalAddCylinderOutlineLines(
                            lines,
                            cylinder.RadiusY,
                            cylinder.RadiusXZ,
                            warnings
                        );
                        return lines.Count() > before;
                    }

                    auto capsule = cast<GmSurfCapsule>(surf);
                    if (capsule !is null) {
                        CrystalAddCapsuleOutlineLines(
                            lines,
                            capsule.SphereCenter,
                            capsule.Dir,
                            capsule.Radius,
                            capsule.Length,
                            warnings
                        );
                        return lines.Count() > before;
                    }

                    auto convex = cast<GmSurfConvexPolyhedron>(surf);
                    if (convex !is null) {
                        CrystalAddBoxOutlineLines(
                            lines,
                            convex.AABB.m_Center - convex.AABB.m_HalfDiag,
                            convex.AABB.m_Center + convex.AABB.m_HalfDiag,
                            warnings
                        );
                        return lines.Count() > before;
                    }

                    auto mesh = cast<GmSurfMesh>(surf);
                    if (mesh !is null) {
                        if (!CrystalAddMeshOutlineLines(lines, mesh, warnings)) {
                            vec3 min;
                            vec3 max;
                            string boundsWarning = "";
                            if (TryGetCrystalGmSurfLocalBounds(surf, min, max, boundsWarning)) {
                                CrystalAddBoxOutlineLines(
                                    lines,
                                    min,
                                    max,
                                    warnings
                                );
                            } else {
                                CrystalAppendOutlineWarning(
                                    warnings,
                                    boundsWarning
                                );
                            }
                        }
                        return lines.Count() > before;
                    }

                    auto compound = cast<GmSurfCompound>(surf);
                    if (compound !is null) {
                        uint count = CrystalMinUint(
                            compound.Surfs.Length,
                            MAX_CRYSTAL_COMPOUND_SURFS_FOR_BOUNDS
                        );
                        for (uint i = 0; i < count; i++) {
                            auto childLines = CrystalOutlineLineBuffer();
                            if (!BuildCrystalGmSurfLocalOutlineLinesWithWarnings(compound.Surfs[i], childLines, warnings, depth + 1)) continue;

                            mat4 childTransform = mat4::Identity();
                            if (i < compound.SurfLocs.Length) {
                                childTransform = mat4(compound.SurfLocs[i]);
                            }
                            CrystalAppendTransformedOutlineLines(
                                lines,
                                childLines,
                                childTransform,
                                false,
                                warnings
                            );
                            if (lines.Count() >= MAX_CRYSTAL_OUTLINE_LINES) break;
                        }
                        if (compound.Surfs.Length > count) {
                            CrystalAppendOutlineWarning(
                                warnings,
                                "GmSurfCompound outline used first " + tostring(count) + " child surfaces."
                            );
                        }
                        return lines.Count() > before;
                    }

                    auto compoundInstance = cast<GmSurfCompoundInstance>(surf);
                    if (compoundInstance !is null) {
                        if (compoundInstance.Compound is null) return false;

                        auto compoundLines = CrystalOutlineLineBuffer();
                        if (!BuildCrystalGmSurfLocalOutlineLinesWithWarnings(compoundInstance.Compound, compoundLines, warnings, depth + 1)) return false;
                        if (compoundInstance.SurfLocs.Length == 0) {
                            CrystalAppendTransformedOutlineLines(
                                lines,
                                compoundLines,
                                mat4::Identity(),
                                false,
                                warnings
                            );
                            return lines.Count() > before;
                        }

                        uint count = CrystalMinUint(
                            compoundInstance.SurfLocs.Length,
                            MAX_CRYSTAL_COMPOUND_SURFS_FOR_BOUNDS
                        );
                        for (uint i = 0; i < count; i++) {
                            CrystalAppendTransformedOutlineLines(
                                lines,
                                compoundLines,
                                mat4(compoundInstance.SurfLocs[i]),
                                false,
                                warnings
                            );
                            if (lines.Count() >= MAX_CRYSTAL_OUTLINE_LINES) break;
                        }
                        if (compoundInstance.SurfLocs.Length > count) {
                            CrystalAppendOutlineWarning(
                                warnings,
                                "GmSurfCompoundInstance outline used first " + tostring(count) + " instance transforms."
                            );
                        }
                        return lines.Count() > before;
                    }

                    return false;
                }

                bool BuildCrystalGmSurfLocalOutlineLines(
                    GmSurf@ surf,
                    CrystalOutlineLineBuffer@ lines,
                    string &out warning,
                    uint depth = 0
                ) {
                    warning = "";
                    auto warnings = CrystalOutlineWarningSink();
                    bool result = BuildCrystalGmSurfLocalOutlineLinesWithWarnings(surf, lines, warnings, depth);
                    warning = warnings.Warning;
                    return result;
                }

                bool CrystalTransformOutlineLinesToWorldWithWarnings(
                    CrystalOutlineLineBuffer@ localLines,
                    const mat4 &in worldTransform,
                    array<vec3> @worldLineStarts,
                    array<vec3> @worldLineEnds,
                    CrystalOutlineWarningSink@ warnings
                ) {
                    if (worldLineStarts is null || worldLineEnds is null) return false;
                    auto worldLines = CrystalOutlineLineBuffer();
                    bool result = CrystalAppendTransformedOutlineLines(
                        worldLines,
                        localLines,
                        worldTransform,
                        true,
                        warnings
                    );
                    uint count = worldLines.Count();
                    for (uint i = 0; i < count; i++) {
                        worldLineStarts.InsertLast(worldLines.Starts[i]);
                        worldLineEnds.InsertLast(worldLines.Ends[i]);
                    }
                    return result;
                }

                bool CrystalTransformOutlineLinesToWorld(
                    CrystalOutlineLineBuffer@ localLines,
                    const mat4 &in worldTransform,
                    array<vec3> @worldLineStarts,
                    array<vec3> @worldLineEnds,
                    string &out warning
                ) {
                    warning = "";
                    auto warnings = CrystalOutlineWarningSink();
                    bool result = CrystalTransformOutlineLinesToWorldWithWarnings(
                        localLines,
                        worldTransform,
                        worldLineStarts,
                        worldLineEnds,
                        warnings
                    );
                    warning = warnings.Warning;
                    return result;
                }
            }
        }
    }
}
