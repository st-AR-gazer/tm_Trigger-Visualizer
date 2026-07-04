namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                const uint MAX_CRYSTAL_TRIGGER_PROBES = 256;
                const uint MAX_CRYSTAL_MESH_VERTS_FOR_BOUNDS = 20000;
                const uint MAX_CRYSTAL_COMPOUND_SURFS_FOR_BOUNDS = 512;
                const uint MAX_CRYSTAL_BLOCK_ITEM_TRIGGER_SHAPES = 512;
                const uint MAX_CRYSTAL_BLOCK_MOBIL_TRIGGER_SURFACES = 512;
                const uint MAX_CRYSTAL_EXPANDABLE_BLOCK_UNITS = 8192;
                const uint MAX_CRYSTAL_EXPANDABLE_BLOCK_COMPONENTS = 512;
                const uint MAX_CRYSTAL_EXPANDABLE_COMPONENT_RECTANGLES = 2048;
                const uint MAX_CRYSTAL_EXPANDABLE_EVIDENCE_UNITS_PER_BLOCK = 64;
                const uint MAX_CRYSTAL_EXPANDABLE_EVIDENCE_CLIPS_PER_UNIT = 64;
                const uint CRYSTAL_EXPANDABLE_PICKED_BLOCK_STICKY_MS = 15000;
                const uint MAX_CRYSTAL_EXPANDABLE_EDITOR_SCRIPT_CLIP_SEEDS = 512;
                const uint MAX_CRYSTAL_EXPANDABLE_EDITOR_SCRIPT_CLIP_BLOCKS = 1024;
                const uint MAX_CRYSTAL_EXPANDABLE_EDITOR_SCRIPT_CLIPS_PER_BLOCK = 128;
                const uint MAX_CRYSTAL_PREFAB_ENTS = 128;
                const uint MAX_CRYSTAL_PREFAB_RECURSION = 4;
                const uint MAX_CRYSTAL_ITEM_VARIANTS = 64;
                const uint MAX_CRYSTAL_BOUNDS_RECURSION = 6;
                const uint MAX_CRYSTAL_SURFACE_MATERIAL_IDS_FOR_TYPE = 128;
                const uint MAX_CRYSTAL_MATERIAL_MODIFIER_FOLDER_LEAVES = 32;
                const uint16 O_CRYSTAL_MATERIAL_GAMEPLAY_ID = 0x29;  // ty XertroV for the RE :PeepoHeart:
                const int CRYSTAL_GAMEPLAY_ID_NONE = 0;
                const int CRYSTAL_GAMEPLAY_ID_MAX_KNOWN = 23;
                const int CRYSTAL_GAMEPLAY_ID_XXX_NULL = 24;
                const uint CRYSTAL_MAX_BLOCK_COORD_SIZE = 256;
                const float CRYSTAL_MIN_VOLUME_AXIS_SIZE = 0.01f;
                const float CRYSTAL_MAX_VOLUME_AXIS_SIZE = 8192.0f;
                const float CRYSTAL_MAX_ABS_WORLD_COORD = 100000.0f;
                const float CRYSTAL_EXPANDABLE_TRIGGER_THICKNESS = 0.125f;
                const float CRYSTAL_EXPANDABLE_TRIGGER_BOTTOM_INSET = 2.0f;
                const float CRYSTAL_EXPANDABLE_TRIGGER_TOP_INSET = 0.1f;

                uint CrystalMinUint(uint a, uint b) {
                    return a < b ? a : b;
                }

                string GetCrystalNodTypeName(CMwNod@ nod) {
                    if (nod is null) return "";
                    try {
                        auto typeInfo = Reflection::TypeOf(nod);
                        return typeInfo is null ? "" : typeInfo.Name;
                    } catch {
                        return "";
                    }
                }

                string CrystalBoolLabel(bool value) {
                    return value ? "yes" : "no";
                }

                string CrystalVec3Label(const vec3 &in value) {
                    return "(" + Text::Format(
                        "%.3f",
                        value.x
                    ) + ", " + Text::Format("%.3f", value.y) + ", " + Text::Format("%.3f", value.z) + ")";
                }

                string CrystalInt3Label(const int3 &in value) {
                    return "(" + tostring(value.x) + ", " + tostring(value.y) + ", " + tostring(value.z) + ")";
                }

                bool CrystalIsFiniteFloat(float value) {
                    return !Math::IsNaN(value) && !Math::IsInf(value);
                }

                bool CrystalIsFiniteVec3(const vec3 &in value) {
                    return CrystalIsFiniteFloat(value.x)
                        && CrystalIsFiniteFloat(value.y)
                        && CrystalIsFiniteFloat(value.z);
                }

                bool CrystalIsFiniteQuat(const quat &in value) {
                    return CrystalIsFiniteFloat(value.x)
                        && CrystalIsFiniteFloat(value.y)
                        && CrystalIsFiniteFloat(value.z)
                        && CrystalIsFiniteFloat(value.w);
                }

                vec3 CrystalMinVec3(const vec3 &in a, const vec3 &in b) {
                    return vec3(
                        Math::Min(a.x, b.x),
                        Math::Min(a.y, b.y),
                        Math::Min(a.z, b.z)
                    );
                }

                vec3 CrystalMaxVec3(const vec3 &in a, const vec3 &in b) {
                    return vec3(
                        Math::Max(a.x, b.x),
                        Math::Max(a.y, b.y),
                        Math::Max(a.z, b.z)
                    );
                }

                vec3 CrystalAbsVec3(const vec3 &in value) {
                    return vec3(
                        Math::Abs(value.x),
                        Math::Abs(value.y),
                        Math::Abs(value.z)
                    );
                }

                vec3 CrystalNat3ToVec3(const nat3 &in value) {
                    return vec3(
                        float(value.x),
                        float(value.y),
                        float(value.z)
                    );
                }

                vec3 CrystalDegToRadVec3(const vec3 &in value) {
                    float scale = Math::PI / 180.0f;
                    return vec3(
                        value.x * scale,
                        value.y * scale,
                        value.z * scale
                    );
                }

                float CrystalCardinalDirectionToYaw(int dir) {
                    return -Math::PI * 0.5f * float(dir) + (dir >= 2 ? Math::PI * 2.0f : 0.0f);
                }

                mat4 CrystalEulerToMat(const vec3 &in euler) {
                    mat4 pitch = mat4::Rotate(-euler.x, vec3(1.0f, 0.0f, 0.0f));
                    mat4 yaw = mat4::Rotate(-euler.y, vec3(0.0f, 1.0f, 0.0f));
                    mat4 roll = mat4::Rotate(-euler.z, vec3(0.0f, 0.0f, 1.0f));
                    return mat4::Inverse(pitch * roll * yaw);
                }

                bool TryGetCrystalTransQuatTransform(
                    const vec3 &in trans,
                    const quat &in rotation,
                    mat4 &out transform,
                    string &out detail,
                    string &out warning
                ) {
                    transform = mat4::Identity();
                    detail = "";
                    warning = "";

                    if (!CrystalIsFiniteVec3(trans) || !CrystalIsFiniteQuat(rotation)) {
                        warning = "Prefab entity transform contains NaN or Inf.";
                        return false;
                    }

                    float lengthSquared = rotation.LengthSquared();
                    if (!CrystalIsFiniteFloat(lengthSquared) || lengthSquared <= 0.000001f) {
                        warning = "Prefab entity quaternion is not usable.";
                        return false;
                    }

                    quat normalized = rotation.Normalized();
                    float angle = normalized.Angle();
                    vec3 axis = normalized.Axis();
                    if (!CrystalIsFiniteFloat(angle) || !CrystalIsFiniteVec3(axis) || axis.LengthSquared() <= 0.000001f) {
                        transform = mat4::Translate(trans);
                        detail = "local prefab ent translation " + CrystalVec3Label(trans);
                        return true;
                    }

                    transform = mat4::Translate(trans) * mat4::Rotate(angle, axis);
                    detail = "local prefab ent transform trans " + CrystalVec3Label(trans)
                        + " angle " + Text::Format("%.3f", angle)
                        + " axis " + CrystalVec3Label(axis);
                    return true;
                }

                bool CrystalQuatLooksVerticalFlip(const quat &in rotation) {
                    if (!CrystalIsFiniteQuat(rotation)) return false;

                    float lengthSquared = rotation.LengthSquared();
                    if (!CrystalIsFiniteFloat(lengthSquared) || lengthSquared <= 0.000001f) return false;

                    quat normalized = rotation.Normalized();
                    float angle = normalized.Angle();
                    vec3 axis = normalized.Axis();
                    if (!CrystalIsFiniteFloat(angle) || !CrystalIsFiniteVec3(axis)) return false;

                    return Math::Abs(angle - Math::PI) <= 0.01f
                        && Math::Abs(axis.x) >= 0.99f
                        && Math::Abs(axis.y) <= 0.05f
                        && Math::Abs(axis.z) <= 0.05f;
                }

                class CrystalBoundsAccumulator {
                    vec3 Min;
                    vec3 Max;
                    bool Initialized = false;

                    void Expand(const vec3 &in point) {
                        if (!Initialized) {
                            Min = point;
                            Max = point;
                            Initialized = true;
                            return;
                        }

                        Min = CrystalMinVec3(Min, point);
                        Max = CrystalMaxVec3(Max, point);
                    }
                }

                void CrystalNormalizeBounds(
                    const vec3 &in rawMin,
                    const vec3 &in rawMax,
                    vec3 &out min,
                    vec3 &out max
                ) {
                    min = CrystalMinVec3(rawMin, rawMax);
                    max = CrystalMaxVec3(rawMin, rawMax);
                }

                bool CrystalValidateBounds(
                    const vec3 &in rawMin,
                    const vec3 &in rawMax,
                    bool worldBounds,
                    string &out warning
                ) {
                    warning = "";
                    vec3 min;
                    vec3 max;
                    CrystalNormalizeBounds(rawMin, rawMax, min, max);

                    if (!CrystalIsFiniteVec3(min) || !CrystalIsFiniteVec3(max)) {
                        warning = "Bounds contain NaN or Inf.";
                        return false;
                    }

                    vec3 size = max - min;
                    if (size.x <= CRYSTAL_MIN_VOLUME_AXIS_SIZE || size.y <= CRYSTAL_MIN_VOLUME_AXIS_SIZE || size.z <= CRYSTAL_MIN_VOLUME_AXIS_SIZE) {
                        warning = "Bounds are zero or near-zero: " + CrystalVec3Label(size);
                        return false;
                    }

                    if (size.x > CRYSTAL_MAX_VOLUME_AXIS_SIZE || size.y > CRYSTAL_MAX_VOLUME_AXIS_SIZE || size.z > CRYSTAL_MAX_VOLUME_AXIS_SIZE) {
                        warning = "Bounds are too large: " + CrystalVec3Label(size);
                        return false;
                    }

                    if (worldBounds) {
                        vec3 absMin = CrystalAbsVec3(min);
                        vec3 absMax = CrystalAbsVec3(max);
                        if (absMin.x > CRYSTAL_MAX_ABS_WORLD_COORD || absMin.y > CRYSTAL_MAX_ABS_WORLD_COORD || absMin.z > CRYSTAL_MAX_ABS_WORLD_COORD || absMax.x > CRYSTAL_MAX_ABS_WORLD_COORD || absMax.y > CRYSTAL_MAX_ABS_WORLD_COORD || absMax.z > CRYSTAL_MAX_ABS_WORLD_COORD) {
                            warning = "World bounds are outside the sanity limit.";
                            return false;
                        }
                    }

                    return true;
                }

                vec3 CrystalTransformPoint(const mat4 &in transform, const vec3 &in point) {
                    vec4 transformed = transform * vec4(point, 1.0f);
                    return vec3(
                        transformed.x,
                        transformed.y,
                        transformed.z
                    );
                }

                bool CrystalTransformBounds(
                    const mat4 &in transform,
                    const vec3 &in localMin,
                    const vec3 &in localMax,
                    vec3 &out worldMin,
                    vec3 &out worldMax,
                    string &out warning
                ) {
                    warning = "";
                    auto bounds = CrystalBoundsAccumulator();
                    bounds.Expand(CrystalTransformPoint(transform, vec3(localMin.x, localMin.y, localMin.z)));
                    bounds.Expand(CrystalTransformPoint(transform, vec3(localMax.x, localMin.y, localMin.z)));
                    bounds.Expand(CrystalTransformPoint(transform, vec3(localMax.x, localMax.y, localMin.z)));
                    bounds.Expand(CrystalTransformPoint(transform, vec3(localMin.x, localMax.y, localMin.z)));
                    bounds.Expand(CrystalTransformPoint(transform, vec3(localMin.x, localMin.y, localMax.z)));
                    bounds.Expand(CrystalTransformPoint(transform, vec3(localMax.x, localMin.y, localMax.z)));
                    bounds.Expand(CrystalTransformPoint(transform, vec3(localMax.x, localMax.y, localMax.z)));
                    bounds.Expand(CrystalTransformPoint(transform, vec3(localMin.x, localMax.y, localMax.z)));

                    if (!bounds.Initialized) {
                        warning = "No bounds corners were transformed.";
                        return false;
                    }
                    worldMin = bounds.Min;
                    worldMax = bounds.Max;
                    return true;
                }

                bool CrystalTransformBounds(
                    const iso4 &in transform,
                    const vec3 &in localMin,
                    const vec3 &in localMax,
                    vec3 &out worldMin,
                    vec3 &out worldMax,
                    string &out warning
                ) {
                    return CrystalTransformBounds(mat4(transform), localMin, localMax, worldMin, worldMax, warning);
                }
            }
        }
    }
}
