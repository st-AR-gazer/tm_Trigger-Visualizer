namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            vec3 MoveLocalPoint(const iso4 &in transform, const vec3 &in delta) {
                iso4 moved = transform;
                moved.Translate(delta.x, delta.y, delta.z);
                return vec3(moved.tx, moved.ty, moved.tz);
            }

            float GetCameraForwardSign(const iso4 &in cameraTransform) {
                mat4 cameraMatrix = mat4(cameraTransform);
                mat4 viewMatrix = mat4::Inverse(cameraMatrix);
                vec4 cameraAhead = viewMatrix * MoveLocalPoint(cameraTransform, vec3(0.0f, 0.0f, 1.0f));
                return cameraAhead.z >= 0.0f ? 1.0f :-1.0f;
            }

            void UpdateWorldFrustumState() {
                g_WorldFrustumState.Valid = false;
                CHmsCamera@ camera = Camera::GetCurrent();
                if (camera is null) return;

                iso4 transform = camera.Location;
                g_WorldFrustumState.ViewMatrix = mat4::Inverse(mat4(transform));
                g_WorldFrustumState.ForwardSign = GetCameraForwardSign(transform);
                g_WorldFrustumState.NearZ = Math::Max(camera.NearZ, FRUSTUM_EPSILON);
                g_WorldFrustumState.FarZ = Math::Max(camera.FarZ, g_WorldFrustumState.NearZ + 1.0f);
                g_WorldFrustumState.TanHalfY = Math::Tan(Math::ToRad(camera.Fov) * 0.5f);
#if TMNEXT
                g_WorldFrustumState.Aspect = camera.Width_Height;
#else
                g_WorldFrustumState.Aspect = camera.RatioXY;
#endif
                g_WorldFrustumState
                    .Valid = g_WorldFrustumState
                    .TanHalfY > 0.0001f && g_WorldFrustumState
                    .Aspect > 0.0001f;
            }

            vec3 WorldToFrustumCameraPoint(const vec3 &in worldPoint) {
                vec3 camera = (g_WorldFrustumState.ViewMatrix * worldPoint).xyz;
                return vec3(camera.x, camera.y, camera.z * g_WorldFrustumState.ForwardSign);
            }

            float GetFrustumPlaneDistance(const vec3 &in point, int plane) {
                float halfY = g_WorldFrustumState.TanHalfY * point.z;
                float halfX = halfY * g_WorldFrustumState.Aspect;
                if (plane == FRUSTUM_NEAR) return point.z - g_WorldFrustumState.NearZ;
                if (plane == FRUSTUM_FAR) return g_WorldFrustumState.FarZ - point.z;
                if (plane == FRUSTUM_LEFT) return point.x + halfX;
                if (plane == FRUSTUM_RIGHT) return halfX - point.x;
                if (plane == FRUSTUM_BOTTOM) return point.y + halfY;
                return halfY - point.y;
            }

            int ClassifyCameraQuadForFrustum(
                const vec3 &in p0,
                const vec3 &in p1,
                const vec3 &in p2,
                const vec3 &in p3
            ) {
                bool allInside = true;
                for (int plane = FRUSTUM_NEAR; plane <= FRUSTUM_TOP; plane++) {
                    bool i0 = GetFrustumPlaneDistance(p0, plane) >= FRUSTUM_EPSILON;
                    bool i1 = GetFrustumPlaneDistance(p1, plane) >= FRUSTUM_EPSILON;
                    bool i2 = GetFrustumPlaneDistance(p2, plane) >= FRUSTUM_EPSILON;
                    bool i3 = GetFrustumPlaneDistance(p3, plane) >= FRUSTUM_EPSILON;
                    if (!i0 && !i1 && !i2 && !i3) return WORLD_PRIMITIVE_OUTSIDE;
                    allInside = allInside && i0 && i1 && i2 && i3;
                }

                return allInside ? WORLD_PRIMITIVE_FRONT : WORLD_PRIMITIVE_MIXED;
            }

            int ClassifyWorldQuadForFrustum(
                const vec3 &in p0,
                const vec3 &in p1,
                const vec3 &in p2,
                const vec3 &in p3
            ) {
                vec3 s0 = Camera::ToScreen(p0);
                vec3 s1 = Camera::ToScreen(p1);
                vec3 s2 = Camera::ToScreen(p2);
                vec3 s3 = Camera::ToScreen(p3);
                bool screenFrontVisible = IsProjectedQuadPotentiallyVisible(
                    s0,
                    s1,
                    s2,
                    s3,
                    SCREEN_QUAD_VISIBILITY_MARGIN
                );
                if (screenFrontVisible) return WORLD_PRIMITIVE_FRONT;

                bool allScreenFront = s0.z < 0 && s1.z < 0 && s2.z < 0 && s3.z < 0;
                if (allScreenFront) return WORLD_PRIMITIVE_OUTSIDE;

                bool anyScreenFront = s0.z < 0 || s1.z < 0 || s2.z < 0 || s3.z < 0;
                if (!g_WorldFrustumState.Valid) {
                    return anyScreenFront ? WORLD_PRIMITIVE_MIXED : WORLD_PRIMITIVE_OUTSIDE;
                }

                int frustumClass = ClassifyCameraQuadForFrustum(
                    WorldToFrustumCameraPoint(p0),
                    WorldToFrustumCameraPoint(p1),
                    WorldToFrustumCameraPoint(p2),
                    WorldToFrustumCameraPoint(p3)
                );
                if (frustumClass == WORLD_PRIMITIVE_OUTSIDE && anyScreenFront) return WORLD_PRIMITIVE_MIXED;
                return frustumClass;
            }

            int ClassifyCameraLineForFrustum(const vec3 &in p0, const vec3 &in p1) {
                bool allInside = true;
                for (int plane = FRUSTUM_NEAR; plane <= FRUSTUM_TOP; plane++) {
                    bool i0 = GetFrustumPlaneDistance(p0, plane) >= FRUSTUM_EPSILON;
                    bool i1 = GetFrustumPlaneDistance(p1, plane) >= FRUSTUM_EPSILON;
                    if (!i0 && !i1) return WORLD_PRIMITIVE_OUTSIDE;
                    allInside = allInside && i0 && i1;
                }

                return allInside ? WORLD_PRIMITIVE_FRONT : WORLD_PRIMITIVE_MIXED;
            }
        }
    }
}
