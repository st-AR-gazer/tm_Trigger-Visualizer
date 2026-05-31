namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            class ProximityReferenceState {
                bool HasVehiclePosition = false;
                vec3 VehiclePosition = vec3();
                bool HasVehicleSpeed = false;
                float VehicleSpeedKmh = 0.0f;
                bool HasOrbitalPoint = false;
                vec3 OrbitalPoint = vec3();

                string StateLabel() const {
                    string vehicle = HasVehiclePosition ? "vehicle position" : "no vehicle position";
                    if (HasVehicleSpeed) {
                        vehicle += " @ " + Text::Format("%.1f km/h", VehicleSpeedKmh);
                    }
                    string orbital = HasOrbitalPoint ? "orbital point" : "no orbital point";
                    return vehicle + ", " + orbital;
                }
            }

            bool G_HasPreviousVehiclePosition = false;
            vec3 G_PreviousVehiclePosition = vec3();
            int64 G_PreviousVehiclePositionTime = 0;
            float G_LastVehicleSpeedKmh = 0.0f;

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
                if (vehicleState is null) {
                    G_HasPreviousVehiclePosition = false;
                    G_PreviousVehiclePositionTime = 0;
                    G_LastVehicleSpeedKmh = 0.0f;
                    return;
                }

                state.HasVehiclePosition = true;
                state.VehiclePosition = vehicleState.Position;
                state.HasVehicleSpeed = true;

                int64 now = Time::Now;
                if (G_HasPreviousVehiclePosition && G_PreviousVehiclePositionTime > 0) {
                    int64 deltaMs = now - G_PreviousVehiclePositionTime;
                    if (deltaMs > 0 && deltaMs < 2000) {
                        float deltaSeconds = float(deltaMs) / 1000.0f;
                        G_LastVehicleSpeedKmh = Math::Distance(
                            vehicleState.Position,
                            G_PreviousVehiclePosition
                        ) / deltaSeconds * 3.6f;
                    }
                }

                G_HasPreviousVehiclePosition = true;
                G_PreviousVehiclePosition = vehicleState.Position;
                G_PreviousVehiclePositionTime = now;
                state.VehicleSpeedKmh = G_LastVehicleSpeedKmh;
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
