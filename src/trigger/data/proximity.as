namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            class ProximityReferenceState {
                bool HasVehiclePosition = false;
                vec3 VehiclePosition = vec3();
                bool HasOrbitalPoint = false;
                vec3 OrbitalPoint = vec3();

                string StateLabel() const {
                    string vehicle = HasVehiclePosition ? "vehicle position" : "no vehicle position";
                    string orbital = HasOrbitalPoint ? "orbital point" : "no orbital point";
                    return vehicle + ", " + orbital;
                }
            }

            bool TrySetOrbitalPoint(ProximityReferenceState@ state, CGameControlCameraEditorOrbital@ orbitalCamera) {
                if (state is null || orbitalCamera is null) return false;

                state.HasOrbitalPoint = true;
                state.OrbitalPoint = orbitalCamera.m_TargetedPosition;
                return true;
            }

            void PopulateOrbitalPoint(ProximityReferenceState@ state) {
                if (state is null) return;

                auto app = GetApp();
                if (app is null || app.Editor is null) return;

                auto mapEditor = cast<CGameCtnEditorFree>(app.Editor);
                if (mapEditor !is null) {
                    TrySetOrbitalPoint(state, mapEditor.OrbitalCameraControl);
                }
            }

            void PopulateVehiclePosition(ProximityReferenceState@ state) {
                if (state is null) return;

                auto vehicleState = VehicleState::ViewingPlayerState();
                if (vehicleState is null) return;

                state.HasVehiclePosition = true;
                state.VehiclePosition = vehicleState.Position;
            }

            ProximityReferenceState@ GetProximityReferenceState(const RuntimeContext@ ctx) {
                auto state = ProximityReferenceState();
                if (ctx is null) return state;

                if (ctx.IsPlayableMap || ctx.IsEditorTestMode) {
                    PopulateVehiclePosition(state);
                }

                if (ctx.IsInEditor && !ctx.IsEditorTestMode) {
                    PopulateOrbitalPoint(state);
                }

                return state;
            }

            ProximityReferenceState@ GetProximityReferenceState() {
                return GetProximityReferenceState(GetRuntimeContext());
            }
        }
    }
}
