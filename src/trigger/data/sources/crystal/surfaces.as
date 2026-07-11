namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                string CrystalGmSurfKind(GmSurf@ surf) {
                    if (surf is null) return "";
                    if (cast<GmSurfSphereLocated>(surf) !is null) return "GmSurfSphereLocated";
                    if (cast<GmSurfBox>(surf) !is null) return "GmSurfBox";
                    if (cast<GmSurfVCylinder>(surf) !is null) return "GmSurfVCylinder";
                    if (cast<GmSurfCylinder>(surf) !is null) return "GmSurfCylinder";
                    if (cast<GmSurfCapsule>(surf) !is null) return "GmSurfCapsule";
                    if (cast<GmSurfMesh>(surf) !is null) return "GmSurfMesh";
                    if (cast<GmSurfCompound>(surf) !is null) return "GmSurfCompound";
                    if (cast<GmSurfCompoundInstance>(surf) !is null) return "GmSurfCompoundInstance";
                    if (cast<GmSurfConvexPolyhedron>(surf) !is null) return "GmSurfConvexPolyhedron";
                    return "GmSurf(" + tostring(int(surf.GmSurfType)) + ")";
                }

                string CrystalGmSurfDetail(GmSurf@ surf) {
                    if (surf is null) return "";

                    auto sphere = cast<GmSurfSphereLocated>(surf);
                    if (sphere !is null) {
                        return "center " + CrystalVec3Label(sphere.Center) + " radius " + Text::Format(
                            "%.3f",
                            sphere.Radius
                        );
                    }

                    auto box = cast<GmSurfBox>(surf);
                    if (box !is null) {
                        return "center " + CrystalVec3Label(box.AABB.m_Center) + " halfDiag " + CrystalVec3Label(box.AABB.m_HalfDiag);
                    }

                    auto verticalCylinder = cast<GmSurfVCylinder>(surf);
                    if (verticalCylinder !is null) {
                        return "height " + Text::Format(
                            "%.3f",
                            verticalCylinder.Height
                        ) + " radius " + Text::Format("%.3f", verticalCylinder.Radius);
                    }

                    auto cylinder = cast<GmSurfCylinder>(surf);
                    if (cylinder !is null) {
                        return "radiusY " + Text::Format(
                            "%.3f",
                            cylinder.RadiusY
                        ) + " radiusXZ " + Text::Format("%.3f", cylinder.RadiusXZ);
                    }

                    auto capsule = cast<GmSurfCapsule>(surf);
                    if (capsule !is null) {
                        return "sphereCenter " + CrystalVec3Label(capsule.SphereCenter)
                            + " dir " + CrystalVec3Label(capsule.Dir)
                            + " radius " + Text::Format("%.3f", capsule.Radius)
                            + " length " + Text::Format("%.3f", capsule.Length);
                    }

                    auto mesh = cast<GmSurfMesh>(surf);
                    if (mesh !is null) {
                        return "verts " + tostring(mesh.m_Verts.Length) + " tris " + tostring(mesh.m_Tris.Length);
                    }

                    auto compound = cast<GmSurfCompound>(surf);
                    if (compound !is null) {
                        return "surfs " + tostring(compound.Surfs.Length) + " locs " + tostring(compound.SurfLocs.Length);
                    }

                    auto compoundInstance = cast<GmSurfCompoundInstance>(surf);
                    if (compoundInstance !is null) {
                        return "compound " + CrystalBoolLabel(compoundInstance.Compound !is null) + " locs " + tostring(compoundInstance.SurfLocs.Length);
                    }

                    auto convex = cast<GmSurfConvexPolyhedron>(surf);
                    if (convex !is null) {
                        return "center " + CrystalVec3Label(convex.AABB.m_Center) + " halfDiag " + CrystalVec3Label(convex.AABB.m_HalfDiag);
                    }

                    return "";
                }

                bool TryGetCrystalGmSurfLocalBounds(
                    GmSurf@ surf,
                    vec3 &out min,
                    vec3 &out max,
                    string &out warning,
                    uint depth = 0
                ) {
                    warning = "";
                    if (surf is null) {
                        warning = "No GmSurf.";
                        return false;
                    }
                    if (depth > MAX_CRYSTAL_BOUNDS_RECURSION) {
                        warning = "GmSurf bounds recursion limit reached.";
                        return false;
                    }

                    auto sphere = cast<GmSurfSphereLocated>(surf);
                    if (sphere !is null) {
                        vec3 radius = vec3(sphere.Radius, sphere.Radius, sphere.Radius);
                        CrystalNormalizeBounds(
                            sphere.Center - radius,
                            sphere.Center + radius,
                            min,
                            max
                        );
                        return CrystalValidateBounds(min, max, false, warning);
                    }

                    auto box = cast<GmSurfBox>(surf);
                    if (box !is null) {
                        CrystalNormalizeBounds(
                            box.AABB.m_Center - box.AABB.m_HalfDiag,
                            box.AABB.m_Center + box.AABB.m_HalfDiag,
                            min,
                            max
                        );
                        return CrystalValidateBounds(min, max, false, warning);
                    }

                    auto verticalCylinder = cast<GmSurfVCylinder>(surf);
                    if (verticalCylinder !is null) {
                        float radius = Math::Abs(verticalCylinder.Radius);
                        float halfHeight = Math::Abs(verticalCylinder.Height) * 0.5f;
                        CrystalNormalizeBounds(
                            vec3(-radius, -halfHeight, -radius),
                            vec3(radius, halfHeight, radius),
                            min,
                            max
                        );
                        return CrystalValidateBounds(min, max, false, warning);
                    }

                    auto cylinder = cast<GmSurfCylinder>(surf);
                    if (cylinder !is null) {
                        float radiusY = Math::Abs(cylinder.RadiusY);
                        float radiusXZ = Math::Abs(cylinder.RadiusXZ);
                        CrystalNormalizeBounds(
                            vec3(-radiusXZ, -radiusY, -radiusXZ),
                            vec3(radiusXZ, radiusY, radiusXZ),
                            min,
                            max
                        );
                        return CrystalValidateBounds(min, max, false, warning);
                    }

                    auto capsule = cast<GmSurfCapsule>(surf);
                    if (capsule !is null) {
                        float radius = Math::Abs(capsule.Radius);
                        float length = Math::Abs(capsule.Length);
                        vec3 dir = capsule.Dir;
                        if (!CrystalIsFiniteVec3(dir) || dir.LengthSquared() <= 0.000001f) {
                            dir = vec3(0.0f, 1.0f, 0.0f);
                        } else {
                            dir = dir.Normalized();
                        }
                        vec3 axis = CrystalAbsVec3(dir) * length;
                        vec3 extent = axis + vec3(radius, radius, radius);
                        CrystalNormalizeBounds(
                            capsule.SphereCenter - extent,
                            capsule.SphereCenter + extent,
                            min,
                            max
                        );
                        return CrystalValidateBounds(min, max, false, warning);
                    }

                    auto convex = cast<GmSurfConvexPolyhedron>(surf);
                    if (convex !is null) {
                        CrystalNormalizeBounds(
                            convex.AABB.m_Center - convex.AABB.m_HalfDiag,
                            convex.AABB.m_Center + convex.AABB.m_HalfDiag,
                            min,
                            max
                        );
                        return CrystalValidateBounds(min, max, false, warning);
                    }

                    auto mesh = cast<GmSurfMesh>(surf);
                    if (mesh !is null) {
                        if (mesh.m_Verts.Length == 0) {
                            warning = "GmSurfMesh has no vertices.";
                            return false;
                        }
                        if (mesh.m_Verts.Length > MAX_CRYSTAL_MESH_VERTS_FOR_BOUNDS) {
                            warning = "GmSurfMesh has too many vertices for safe bounds: " + tostring(mesh.m_Verts.Length);
                            return false;
                        }

                        auto bounds = CrystalBoundsAccumulator();
                        for (uint i = 0; i < mesh.m_Verts.Length; i++) {
                            vec3 vertex = mesh.m_Verts[i];
                            if (!CrystalIsFiniteVec3(vertex)) {
                                warning = "GmSurfMesh contains NaN or Inf vertex data.";
                                return false;
                            }
                            bounds.Expand(vertex);
                        }
                        min = bounds.Min;
                        max = bounds.Max;
                        return CrystalValidateBounds(min, max, false, warning);
                    }

                    auto compound = cast<GmSurfCompound>(surf);
                    if (compound !is null) {
                        if (compound.Surfs.Length == 0) {
                            warning = "GmSurfCompound has no child surfaces.";
                            return false;
                        }

                        auto bounds = CrystalBoundsAccumulator();
                        uint count = MinUint(
                            compound.Surfs.Length,
                            MAX_CRYSTAL_COMPOUND_SURFS_FOR_BOUNDS
                        );
                        for (uint i = 0; i < count; i++) {
                            vec3 childMin;
                            vec3 childMax;
                            string childWarning = "";
                            if (!TryGetCrystalGmSurfLocalBounds(compound.Surfs[i], childMin, childMax, childWarning, depth + 1)) continue;

                            if (i < compound.SurfLocs.Length) {
                                vec3 transformedMin;
                                vec3 transformedMax;
                                string transformWarning = "";
                                if (!CrystalTransformBounds(compound.SurfLocs[i], childMin, childMax, transformedMin, transformedMax, transformWarning)) continue;
                                childMin = transformedMin;
                                childMax = transformedMax;
                            }
                            bounds.Expand(childMin);
                            bounds.Expand(childMax);
                        }

                        if (!bounds.Initialized) {
                            warning = "No readable child bounds in GmSurfCompound.";
                            return false;
                        }
                        min = bounds.Min;
                        max = bounds.Max;
                        if (compound.Surfs.Length > count) {
                            warning = "GmSurfCompound bounds used first " + tostring(count) + " child surfaces.";
                        }
                        string validationWarning = "";
                        if (!CrystalValidateBounds(min, max, false, validationWarning)) {
                            warning = validationWarning;
                            return false;
                        }
                        return true;
                    }

                    auto compoundInstance = cast<GmSurfCompoundInstance>(surf);
                    if (compoundInstance !is null) {
                        if (compoundInstance.Compound is null) {
                            warning = "GmSurfCompoundInstance has no compound.";
                            return false;
                        }

                        vec3 compoundMin;
                        vec3 compoundMax;
                        string compoundWarning = "";
                        if (!TryGetCrystalGmSurfLocalBounds(compoundInstance.Compound, compoundMin, compoundMax, compoundWarning, depth + 1)) {
                            warning = compoundWarning;
                            return false;
                        }

                        if (compoundInstance.SurfLocs.Length == 0) {
                            min = compoundMin;
                            max = compoundMax;
                            return true;
                        }

                        auto bounds = CrystalBoundsAccumulator();
                        uint count = MinUint(
                            compoundInstance.SurfLocs.Length,
                            MAX_CRYSTAL_COMPOUND_SURFS_FOR_BOUNDS
                        );
                        for (uint i = 0; i < count; i++) {
                            vec3 transformedMin;
                            vec3 transformedMax;
                            string transformWarning = "";
                            if (!CrystalTransformBounds(compoundInstance.SurfLocs[i], compoundMin, compoundMax, transformedMin, transformedMax, transformWarning)) continue;
                            bounds.Expand(transformedMin);
                            bounds.Expand(transformedMax);
                        }
                        if (!bounds.Initialized) {
                            warning = "No readable instance transforms in GmSurfCompoundInstance.";
                            return false;
                        }
                        min = bounds.Min;
                        max = bounds.Max;
                        return CrystalValidateBounds(min, max, false, warning);
                    }

                    warning = "GmSurf type is not handled by the safe bounds path.";
                    return false;
                }
            }
        }
    }
}
