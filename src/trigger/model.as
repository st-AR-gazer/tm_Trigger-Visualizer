namespace TriggerVisualizer {
    namespace Trigger {
        const int TRIGGER_SOURCE_OFFZONE = 0;
        const int TRIGGER_SOURCE_MEDIATRACKER = 1;
        const string TRIGGER_TARGET_OFFZONE = "offzone";
        const string TRIGGER_TARGET_MEDIATRACKER = "mediatracker";
        const string MT_SUBTYPE_CAMERA = "camera";
        const string MT_SUBTYPE_CUSTOM_CAMERA = "customcamera";
        const string MT_SUBTYPE_ORBITAL_CAMERA = "orbitalcamera";
        const string MT_SUBTYPE_PATH_CAMERA = "pathcamera";
        const string MT_SUBTYPE_PLAYER_CAMERA = "playercamera";
        const string MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT = "playercamerasubtypecamdefault";
        const string MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1 = "playercamerasubtypecam1";
        const string MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2 = "playercamerasubtypecam2";
        const string MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3 = "playercamerasubtypecam3";
        const string MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO = "playercamerasubtypecamhelico";
        const string MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE = "playercamerasubtypecamfree";
        const string MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR = "playercamerasubtypecamspectator";
        const string MT_SUBTYPE_2D_TRIANGLES = "2dtriangles";
        const string MT_SUBTYPE_3D_TRIANGLES = "3dtriangles";
        const string MT_SUBTYPE_CAR_TRAILS = "cartrails";
        const string MT_SUBTYPE_COLORS_FX = "colorsfx";
        const string MT_SUBTYPE_COLOR_GRADING = "colorgrading";
        const string MT_SUBTYPE_DEPTH_OF_FIELD = "depthoffield";
        const string MT_SUBTYPE_DIRTY_LENS = "dirtylens";
        const string MT_SUBTYPE_EDITING_CUT = "editingcut";
        const string MT_SUBTYPE_FADING_TRANSITION = "fadingtransition";
        const string MT_SUBTYPE_FOG = "fog";
        const string MT_SUBTYPE_GHOST = "ghost";
        const string MT_SUBTYPE_HDR_BLOOM = "hdrbloom";
        const string MT_SUBTYPE_IMAGE = "image";
        const string MT_SUBTYPE_INERTIAL_TRACKING_CAM_FX = "inertialtrackingcamfx";
        const string MT_SUBTYPE_MANIALINK_UI = "manialinkui";
        const string MT_SUBTYPE_MANIALINK_URL = "manialinkurl";
        const string MT_SUBTYPE_MUSIC_VOLUME = "musicvolume";
        const string MT_SUBTYPE_OPPONENT_VISIBILITY = "opponentvisibility";
        const string MT_SUBTYPE_SHAKE_CAM_FX = "shakecamfx";
        const string MT_SUBTYPE_STEREO_3D = "stereo3d";
        const string MT_SUBTYPE_SOUND_FX = "soundfx";
        const string MT_SUBTYPE_SPECTATORS = "spectators";
        const string MT_SUBTYPE_TEXT = "text";
        const string MT_SUBTYPE_TIME = "time";
        const string MT_SUBTYPE_TIME_SPEED = "timespeed";
        const string MT_SUBTYPE_TONE_MAPPING = "tonemapping";
        const string MT_SUBTYPE_VEHICLE_LIGHTS = "vehiclelights";
        const string MT_SUBTYPE_RESET = "reset";
        const string MT_SUBTYPE_MIXED = "mixed";
        const string MT_SUBTYPE_UNKNOWN = "unknown";

        string GetTriggerSourceName(int source) {
            if (source == TRIGGER_SOURCE_OFFZONE) return "Offzone";
            if (source == TRIGGER_SOURCE_MEDIATRACKER) return "MediaTracker";
            return "Unknown";
        }

        string NormalizeTriggerTargetKey(const string &in rawKey) {
            string key = rawKey.ToLower().Trim();
            key = key.Replace(" ", "").Replace("-", "").Replace("_", "").Replace("/", "");
            if (key == "media" || key == "mt" || key == "mediatracker") return TRIGGER_TARGET_MEDIATRACKER;
            if (key == "offzone" || key == "offzones") return TRIGGER_TARGET_OFFZONE;

            if (key == "cameras" || key == "camera") return MT_SUBTYPE_CAMERA;
            if (key == "customcamera" || key == "customcam" || key == "camcustom") return MT_SUBTYPE_CUSTOM_CAMERA;
            if (key == "orbitalcamera" || key == "orbitalcam" || key == "camorbital") return MT_SUBTYPE_ORBITAL_CAMERA;
            if (key == "pathcamera" || key == "pathcam" || key == "campath") return MT_SUBTYPE_PATH_CAMERA;
            if (key == "playercamera" || key == "playercam" || key == "camplayer" || key == "gamecamera") return MT_SUBTYPE_PLAYER_CAMERA;
            if (key == "defaultcamera" || key == "camdefault") return MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT;
            if (key == "externalcamera" || key == "external1camera" || key == "cam1") return MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1;
            if (key == "external2camera" || key == "cam2") return MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2;
            if (key == "internalcamera" || key == "cam3") return MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3;
            if (key == "helicocamera" || key == "helicam" || key == "helico" || key == "camhelico") return MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO;
            if (key == "freecamera" || key == "freecam" || key == "camfree") return MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE;
            if (key == "spectatorcamera" || key == "spectatorcam" || key == "camspectator") return MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR;

            if (key == "2dtriangle" || key == "2dtriangles") return MT_SUBTYPE_2D_TRIANGLES;
            if (key == "3dtriangle" || key == "3dtriangles") return MT_SUBTYPE_3D_TRIANGLES;
            if (key == "cartrail" || key == "cartrails" || key == "trail" || key == "trails") return MT_SUBTYPE_CAR_TRAILS;
            if (key == "colorsfx" || key == "colorfx") return MT_SUBTYPE_COLORS_FX;
            if (key == "colorgrading" || key == "grading") return MT_SUBTYPE_COLOR_GRADING;
            if (key == "dof" || key == "depthoffield") return MT_SUBTYPE_DEPTH_OF_FIELD;
            if (key == "dirtylens") return MT_SUBTYPE_DIRTY_LENS;
            if (key == "editingcut" || key == "cut") return MT_SUBTYPE_EDITING_CUT;
            if (key == "fadingtransition" || key == "fadetransition" || key == "transitionfade" || key == "fade") return MT_SUBTYPE_FADING_TRANSITION;
            if (key == "fog") return MT_SUBTYPE_FOG;
            if (key == "ghost" || key == "ghosts" || key == "gps" || key == "entity" || key == "entities") return MT_SUBTYPE_GHOST;
            if (key == "hdrbloom" || key == "bloomhdr" || key == "bloom") return MT_SUBTYPE_HDR_BLOOM;
            if (key == "image" || key == "images") return MT_SUBTYPE_IMAGE;
            if (key == "inertialtrackingcamfx" || key == "inertialtracking" || key == "camfxinertialtracking") return MT_SUBTYPE_INERTIAL_TRACKING_CAM_FX;
            if (key == "manialinkui" || key == "manialinkinterface" || key == "interface") return MT_SUBTYPE_MANIALINK_UI;
            if (key == "manialinkurl" || key == "manialink") return MT_SUBTYPE_MANIALINK_URL;
            if (key == "musicvolume" || key == "music" || key == "musicfx") return MT_SUBTYPE_MUSIC_VOLUME;
            if (key == "opponentvisibility" || key == "opponents") return MT_SUBTYPE_OPPONENT_VISIBILITY;
            if (key == "shakecamfx" || key == "camerashake" || key == "shake") return MT_SUBTYPE_SHAKE_CAM_FX;
            if (key == "stereo3d" || key == "3dstereo") return MT_SUBTYPE_STEREO_3D;
            if (key == "soundfx" || key == "sound" || key == "sounds") return MT_SUBTYPE_SOUND_FX;
            if (key == "spectators" || key == "spectator") return MT_SUBTYPE_SPECTATORS;
            if (key == "text") return MT_SUBTYPE_TEXT;
            if (key == "time") return MT_SUBTYPE_TIME;
            if (key == "timespeed") return MT_SUBTYPE_TIME_SPEED;
            if (key == "tonemapping") return MT_SUBTYPE_TONE_MAPPING;
            if (key == "vehiclelights" || key == "vehiclelight" || key == "lights") return MT_SUBTYPE_VEHICLE_LIGHTS;
            if (key == "reset" || key == "empty") return MT_SUBTYPE_RESET;
            if (key == "mixed") return MT_SUBTYPE_MIXED;
            if (key == "unknown") return MT_SUBTYPE_UNKNOWN;

            return key;
        }

        string GetTriggerSourceTargetKey(int source) {
            if (source == TRIGGER_SOURCE_OFFZONE) return TRIGGER_TARGET_OFFZONE;
            if (source == TRIGGER_SOURCE_MEDIATRACKER) return TRIGGER_TARGET_MEDIATRACKER;
            return "";
        }

        bool IsCameraSubtypeTargetKey(const string &in rawKey) {
            string key = NormalizeTriggerTargetKey(rawKey);
            return key == MT_SUBTYPE_CUSTOM_CAMERA
                || key == MT_SUBTYPE_ORBITAL_CAMERA
                || key == MT_SUBTYPE_PATH_CAMERA
                || key == MT_SUBTYPE_PLAYER_CAMERA
                || key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT
                || key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1
                || key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2
                || key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3
                || key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO
                || key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE
                || key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR;
        }

        bool TriggerTargetListContains(const string &in targetKeys, const string &in rawKey) {
            string key = NormalizeTriggerTargetKey(rawKey);
            if (key.Length == 0) return false;

            auto parts = targetKeys.Split("|");
            for (uint i = 0; i < parts.Length; i++) {
                if (parts[i] == key) return true;
            }
            return false;
        }

        string AddTriggerTargetKey(const string &in targetKeys, const string &in rawKey) {
            string key = NormalizeTriggerTargetKey(rawKey);
            if (key.Length == 0 || TriggerTargetListContains(targetKeys, key)) return targetKeys;
            return targetKeys + key + "|";
        }

        string MergeTriggerTargetKeys(const string &in targetKeys, const string &in extraTargetKeys) {
            string next = targetKeys;
            auto parts = extraTargetKeys.Split("|");
            for (uint i = 0; i < parts.Length; i++) {
                next = AddTriggerTargetKey(next, parts[i]);
            }
            return next;
        }

        string AddMediaTrackerSubtypeTargetKey(const string &in targetKeys, const string &in rawKey) {
            string key = NormalizeTriggerTargetKey(rawKey);
            if (key.Length == 0) return targetKeys;

            string next = AddTriggerTargetKey(targetKeys, key);
            if (IsCameraSubtypeTargetKey(key)) {
                next = AddTriggerTargetKey(next, MT_SUBTYPE_CAMERA);
            }
            return next;
        }

        string GetTriggerSourceTargetKeys(int source) {
            return AddTriggerTargetKey("", GetTriggerSourceTargetKey(source));
        }

        string GetMediaTrackerSubtypeDisplayName(const string &in rawKey) {
            string key = NormalizeTriggerTargetKey(rawKey);
            if (key == MT_SUBTYPE_CAMERA) return "Camera";
            if (key == MT_SUBTYPE_CUSTOM_CAMERA) return "Custom Camera";
            if (key == MT_SUBTYPE_ORBITAL_CAMERA) return "Orbital Camera";
            if (key == MT_SUBTYPE_PATH_CAMERA) return "Path Camera";
            if (key == MT_SUBTYPE_PLAYER_CAMERA) return "Player Camera";
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT) return "CamDefault";
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1) return "Cam1";
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2) return "Cam2";
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3) return "Cam3";
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO) return "CamHelico";
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE) return "CamFree";
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR) return "CamSpectator";
            if (key == MT_SUBTYPE_2D_TRIANGLES) return "2D Triangles";
            if (key == MT_SUBTYPE_3D_TRIANGLES) return "3D Triangles";
            if (key == MT_SUBTYPE_CAR_TRAILS) return "Car Trails";
            if (key == MT_SUBTYPE_COLORS_FX) return "Colors FX";
            if (key == MT_SUBTYPE_COLOR_GRADING) return "Color Grading";
            if (key == MT_SUBTYPE_DEPTH_OF_FIELD) return "Depth of Field";
            if (key == MT_SUBTYPE_DIRTY_LENS) return "Dirty Lens";
            if (key == MT_SUBTYPE_EDITING_CUT) return "Editing Cut";
            if (key == MT_SUBTYPE_FADING_TRANSITION) return "Fading Transition";
            if (key == MT_SUBTYPE_FOG) return "Fog";
            if (key == MT_SUBTYPE_GHOST) return "Ghost";
            if (key == MT_SUBTYPE_HDR_BLOOM) return "HDR Bloom";
            if (key == MT_SUBTYPE_IMAGE) return "Image";
            if (key == MT_SUBTYPE_INERTIAL_TRACKING_CAM_FX) return "Inertial Tracking CamFX";
            if (key == MT_SUBTYPE_MANIALINK_UI) return "ManiaLink UI";
            if (key == MT_SUBTYPE_MANIALINK_URL) return "ManiaLink URL";
            if (key == MT_SUBTYPE_MUSIC_VOLUME) return "Music Volume";
            if (key == MT_SUBTYPE_OPPONENT_VISIBILITY) return "Opponent Visibility";
            if (key == MT_SUBTYPE_SHAKE_CAM_FX) return "Shake Cam FX";
            if (key == MT_SUBTYPE_STEREO_3D) return "Stereo 3D";
            if (key == MT_SUBTYPE_SOUND_FX) return "Sound FX";
            if (key == MT_SUBTYPE_SPECTATORS) return "Spectators";
            if (key == MT_SUBTYPE_TEXT) return "Text";
            if (key == MT_SUBTYPE_TIME) return "Time";
            if (key == MT_SUBTYPE_TIME_SPEED) return "Time Speed";
            if (key == MT_SUBTYPE_TONE_MAPPING) return "ToneMapping";
            if (key == MT_SUBTYPE_VEHICLE_LIGHTS) return "Vehicle Lights";
            if (key == MT_SUBTYPE_RESET) return "Reset";
            if (key == MT_SUBTYPE_MIXED) return "Mixed";
            return "Unknown";
        }

        vec4 GetMediaTrackerTrackColorForSubtype(const string &in rawKey) {
            string key = NormalizeTriggerTargetKey(rawKey);
            if (key == MT_SUBTYPE_CAMERA) return vec4(1.0f, 0.0f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_CUSTOM_CAMERA) return vec4(1.0f, 0.0f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_ORBITAL_CAMERA) return vec4(0.5019608f, 0.0f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_PATH_CAMERA) return vec4(1.0f, 0.5019608f, 1.0f, 1.0f);
            if (key == MT_SUBTYPE_PLAYER_CAMERA) return vec4(1.0f, 0.5019608f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_DEFAULT) return vec4(1.0f, 0.5019608f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_1) return vec4(1.0f, 0.5019608f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_2) return vec4(1.0f, 0.5019608f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_3) return vec4(1.0f, 0.5019608f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_HELICO) return vec4(1.0f, 0.5019608f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_FREE) return vec4(1.0f, 0.5019608f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_PLAYER_CAMERA_SUBTYPE_CAM_SPECTATOR) return vec4(1.0f, 0.5019608f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_2D_TRIANGLES) return vec4(0.0f, 0.5019608f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_3D_TRIANGLES) return vec4(0.0f, 0.5019608f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_CAR_TRAILS) return vec4(0.0f, 0.0f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_COLORS_FX) return vec4(0.0f, 1.0f, 0.5019608f, 1.0f);
            if (key == MT_SUBTYPE_COLOR_GRADING) return vec4(0.0f, 0.5019608f, 1.0f, 1.0f);
            if (key == MT_SUBTYPE_DEPTH_OF_FIELD) return vec4(1.0f, 0.0f, 0.5019608f, 1.0f);
            if (key == MT_SUBTYPE_DIRTY_LENS) return vec4(1.0f, 1.0f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_EDITING_CUT) return vec4(0.7490196f, 0.7490196f, 0.7490196f, 1.0f);
            if (key == MT_SUBTYPE_FADING_TRANSITION) return vec4(1.0f, 1.0f, 0.5019608f, 1.0f);
            if (key == MT_SUBTYPE_FOG) return vec4(0.0f, 1.0f, 1.0f, 1.0f);
            if (key == MT_SUBTYPE_GHOST) return vec4(1.0f, 1.0f, 1.0f, 1.0f);
            if (key == MT_SUBTYPE_HDR_BLOOM) return vec4(0.5019608f, 1.0f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_IMAGE) return vec4(0.0f, 0.5019608f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_INERTIAL_TRACKING_CAM_FX) return vec4(0.2509804f, 0.5019608f, 0.5019608f, 1.0f);
            if (key == MT_SUBTYPE_MANIALINK_UI) return vec4(0.0f, 1.0f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_MANIALINK_URL) return vec4(0.1019608f, 0.5019608f, 0.1019608f, 1.0f);
            if (key == MT_SUBTYPE_MUSIC_VOLUME) return vec4(0.2509804f, 0.2509804f, 0.2509804f, 1.0f);
            if (key == MT_SUBTYPE_OPPONENT_VISIBILITY) return vec4(0.0f, 0.0f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_SHAKE_CAM_FX) return vec4(0.5019608f, 0.0f, 1.0f, 1.0f);
            if (key == MT_SUBTYPE_STEREO_3D) return vec4(0.0f, 0.0f, 0.5019608f, 1.0f);
            if (key == MT_SUBTYPE_SOUND_FX) return vec4(0.5019608f, 0.5019608f, 0.5019608f, 1.0f);
            if (key == MT_SUBTYPE_SPECTATORS) return vec4(0.0f, 0.0f, 0.5019608f, 1.0f);
            if (key == MT_SUBTYPE_TEXT) return vec4(0.5019608f, 1.0f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_TIME) return vec4(0.8509804f, 0.8509804f, 0.8509804f, 1.0f);
            if (key == MT_SUBTYPE_TIME_SPEED) return vec4(0.2f, 0.0f, 0.2f, 1.0f);
            if (key == MT_SUBTYPE_TONE_MAPPING) return vec4(0.0f, 0.3019608f, 0.6f, 1.0f);
            if (key == MT_SUBTYPE_VEHICLE_LIGHTS) return vec4(0.0f, 0.0f, 0.0f, 1.0f);
            if (key == MT_SUBTYPE_RESET) return vec4(0.0f, 0.75f, 1.0f, 1.0f);
            if (key == MT_SUBTYPE_MIXED) return vec4(0.92f, 0.74f, 0.26f, 1.0f);
            return vec4(0.85f, 0.45f, 0.95f, 1.0f);
        }

        vec4 GetMediaTrackerGpsTrackColor() {
            return vec4(1.0f, 0.20f, 0.76f, 1.0f);
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
            float WorldYAnchor = 8.0f;
            string WorldYAnchorSource = "default";
            string MapCollectionName = "";
            int MapCollectionId = -1;
            uint MapDecoBaseHeightOffset = 0;

            TriggerGridSpec() {
                CellsPerBlock = nat3(1, 1, 1);
                CellWorldSize = vec3(32.0f, 8.0f, 32.0f);
                WorldYAnchor = 8.0f;
            }

            TriggerGridSpec(const nat3 &in cellsPerBlock, const vec3 &in cellWorldSize) {
                CellsPerBlock = cellsPerBlock;
                CellWorldSize = cellWorldSize;
                WorldYAnchor = 8.0f;
            }

            TriggerGridSpec(const nat3 &in cellsPerBlock, const vec3 &in cellWorldSize, float worldYAnchor) {
                CellsPerBlock = cellsPerBlock;
                CellWorldSize = cellWorldSize;
                WorldYAnchor = worldYAnchor;
            }

            TriggerGridSpec(
                const nat3 &in cellsPerBlock,
                const vec3 &in cellWorldSize,
                float worldYAnchor,
                const string &in worldYAnchorSource,
                const string &in mapCollectionName,
                int mapCollectionId,
                uint mapDecoBaseHeightOffset
            ) {
                CellsPerBlock = cellsPerBlock;
                CellWorldSize = cellWorldSize;
                WorldYAnchor = worldYAnchor;
                WorldYAnchorSource = worldYAnchorSource;
                MapCollectionName = mapCollectionName;
                MapCollectionId = mapCollectionId;
                MapDecoBaseHeightOffset = mapDecoBaseHeightOffset;
            }
        }

        class TriggerVolume {
            vec3 Min;
            vec3 Max;
            int Source = TRIGGER_SOURCE_OFFZONE;
            uint SourceIndex = 0;
            string Label;
            string DetectedLabel;
            string SubtypeKey;
            string SubtypeLabel;
            string TargetKeys = "offzone|";
            bool HasMediaTrackerTrackColor = false;
            vec4 MediaTrackerTrackColor = vec4(1.0f, 0.45f, 0.10f, 1.0f);
            bool HasIslandIndex = false;
            uint IslandIndex = 0;
            uint IslandCount = 0;
            bool IsMergedGroup = false;
            uint MergedVolumeCount = 1;
            bool AllowRawRangeLabel = true;
            array<TriggerVolume@> ChildVolumes;

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
                TargetKeys = GetTriggerSourceTargetKeys(source);
            }

            vec3 Size() const {
                return Max - Min;
            }

            vec3 Center() const {
                return(Min + Max) * 0.5f;
            }

            bool HasChildVolumes() const {
                return ChildVolumes.Length > 0;
            }

            string SourceName() const {
                return GetTriggerSourceName(Source);
            }

            string SourceIndexLabel() const {
                if (IsMergedGroup && Source == TRIGGER_SOURCE_OFFZONE) {
                    return SourceName() + " group #" + tostring(SourceIndex);
                }
                if (IsMergedGroup) {
                    return SourceName() + " #" + tostring(SourceIndex) + " group";
                }
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
                if (IsMergedGroup && MergedVolumeCount > 1) {
                    label += " (" + tostring(MergedVolumeCount) + " joined)";
                }
                return label;
            }
        }

        bool TriggerVolumeMatchesTargetKey(const TriggerVolume@ volume, const string &in rawKey) {
            if (volume is null) return false;

            string key = NormalizeTriggerTargetKey(rawKey);
            if (key.Length == 0) return false;
            if (TriggerTargetListContains(volume.TargetKeys, key)) return true;

            string sourceKey = GetTriggerSourceTargetKey(volume.Source);
            if (sourceKey.Length > 0 && sourceKey == key) return true;
            return NormalizeTriggerTargetKey(volume.SubtypeKey) == key;
        }

        class MediaTrackerClipTriggerSnapshot {
            uint ClipIndex = 0;
            string ClipName;
            string DetectedLabel;
            string SubtypeKey;
            string SubtypeLabel;
            string TargetKeys;
            string EntityInfo;
            bool HasMediaTrackerTrackColor = false;
            vec4 MediaTrackerTrackColor = vec4(1.0f, 0.45f, 0.10f, 1.0f);
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
            array<string> SuggestOffTargets;
            array<string> ForceOffTargets;
            bool HasSuggestedDrawDistanceXZ = false;
            bool HasSuggestedDrawDistanceY = false;
            float SuggestedDrawDistanceXZ = 0.0f;
            float SuggestedDrawDistanceY = 0.0f;
            array<string> Commands;

            string DisableSummary() const {
                if (ForceOff) return "force-off";
                if (SuggestOff) return "suggest-off";
                if (ForceOffTargets.Length > 0 || SuggestOffTargets.Length > 0) return TargetDisableSummary();
                return "none";
            }

            string JoinTargets(const array<string> &in targets) const {
                string result = "";
                for (uint i = 0; i < targets.Length; i++) {
                    if (i > 0) result += ", ";
                    result += targets[i];
                }
                return result;
            }

            string TargetDisableSummary() const {
                string result = "";
                if (ForceOffTargets.Length > 0) {
                    result += "force-off: " + JoinTargets(ForceOffTargets);
                }
                if (SuggestOffTargets.Length > 0) {
                    if (result.Length > 0) result += " | ";
                    result += "suggest-off: " + JoinTargets(SuggestOffTargets);
                }
                return result.Length > 0 ? result : "none";
            }

            bool HasSuggestOffTarget(const string &in rawKey) const {
                string key = NormalizeTriggerTargetKey(rawKey);
                for (uint i = 0; i < SuggestOffTargets.Length; i++) {
                    if (SuggestOffTargets[i] == key) return true;
                }
                return false;
            }

            bool HasForceOffTarget(const string &in rawKey) const {
                string key = NormalizeTriggerTargetKey(rawKey);
                for (uint i = 0; i < ForceOffTargets.Length; i++) {
                    if (ForceOffTargets[i] == key) return true;
                }
                return false;
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
