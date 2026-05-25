namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            class PlayerPositionState {
                bool HasVehicle = false;
                vec3 Position = vec3();

                string StateLabel() const {
                    return HasVehicle ? "Vehicle" : "No vehicle";
                }
            }

            PlayerPositionState@ GetPlayerPositionState() {
                auto state = PlayerPositionState();
                auto vehicleState = VehicleState::ViewingPlayerState();
                if (vehicleState is null) return state;

                state.HasVehicle = true;
                state.Position = vehicleState.Position;
                return state;
            }
        }
    }
}
