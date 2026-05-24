[SettingsTab name="General" icon="Cog" order=1]
void RenderOffzoneVisualizerGeneralSettingsTab() {
    OffzoneVisualizer::App::RenderGeneralSettingsUI();
}

[SettingsTab name="Line Splitting" icon="Sliders" order=2]
void RenderOffzoneVisualizerLineSplittingSettingsTab() {
    OffzoneVisualizer::App::RenderLineSplittingSettingsUI();
}

[SettingsTab name="Color" icon="Tint" order=3]
void RenderOffzoneVisualizerColorSettingsTab() {
    OffzoneVisualizer::App::RenderColorSettingsUI();
}

[SettingsTab name="Logging" icon="ListAlt" order=99]
void RenderOffzoneVisualizerLoggingSettingsTab() {
    OffzoneVisualizer::App::RenderLoggingSettingsUI();
}
