[SettingsTab name="General" icon="Cog" order=1]
void RenderOffzoneVisualizerGeneralSettingsTab() {
    OffzoneVisualizer::App::RenderGeneralSettingsUI();
}

[SettingsTab name="World Rendering" icon="Cube" order=2]
void RenderOffzoneVisualizerWorldRenderingSettingsTab() {
    OffzoneVisualizer::App::RenderWorldRenderingSettingsUI();
}

[SettingsTab name="Line Splitting" icon="Sliders" order=3]
void RenderOffzoneVisualizerLineSplittingSettingsTab() {
    OffzoneVisualizer::App::RenderLineSplittingSettingsUI();
}

[SettingsTab name="Color" icon="Tint" order=4]
void RenderOffzoneVisualizerColorSettingsTab() {
    OffzoneVisualizer::App::RenderColorSettingsUI();
}

[SettingsTab name="Proximity" icon="Car" order=5]
void RenderOffzoneVisualizerProximitySettingsTab() {
    OffzoneVisualizer::App::RenderProximitySettingsUI();
}

[SettingsTab name="Labels" icon="Tags" order=6]
void RenderOffzoneVisualizerLabelsSettingsTab() {
    OffzoneVisualizer::App::RenderLabelsSettingsUI();
}

[SettingsTab name="Logging" icon="ListAlt" order=99]
void RenderOffzoneVisualizerLoggingSettingsTab() {
    OffzoneVisualizer::App::RenderLoggingSettingsUI();
}
