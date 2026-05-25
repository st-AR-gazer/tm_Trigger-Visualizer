namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            vec3 GetTriggerVolumeFaceNormal(uint faceIndex) {
                if (faceIndex == 0) return vec3(-1.0f, 0.0f, 0.0f);
                if (faceIndex == 1) return vec3(1.0f, 0.0f, 0.0f);
                if (faceIndex == 2) return vec3(0.0f, -1.0f, 0.0f);
                if (faceIndex == 3) return vec3(0.0f, 1.0f, 0.0f);
                if (faceIndex == 4) return vec3(0.0f, 0.0f, -1.0f);
                return vec3(0.0f, 0.0f, 1.0f);
            }

            array<vec3> @GetTriggerVolumeCorners(const TriggerVolume@ box) {
                auto corners = array<vec3>();
                if (box is null) return corners;

                vec3 min = box.Min;
                vec3 max = box.Max;

                corners.InsertLast(vec3(min.x, min.y, min.z));
                corners.InsertLast(vec3(max.x, min.y, min.z));
                corners.InsertLast(vec3(max.x, max.y, min.z));
                corners.InsertLast(vec3(min.x, max.y, min.z));
                corners.InsertLast(vec3(min.x, min.y, max.z));
                corners.InsertLast(vec3(max.x, min.y, max.z));
                corners.InsertLast(vec3(max.x, max.y, max.z));
                corners.InsertLast(vec3(min.x, max.y, max.z));

                return corners;
            }
        }
    }
}
