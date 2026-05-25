[SettingsTab name="General" icon="Cog" order=1]
void RenderTriggerVisualizerGeneralSettingsTab() {
    TriggerVisualizer::App::RenderGeneralSettingsUI();
}

[SettingsTab name="World Rendering" icon="Cube" order=2]
void RenderTriggerVisualizerWorldRenderingSettingsTab() {
    TriggerVisualizer::App::RenderWorldRenderingSettingsUI();
}

[SettingsTab name="Line Splitting" icon="Sliders" order=3]
void RenderTriggerVisualizerLineSplittingSettingsTab() {
    TriggerVisualizer::App::RenderLineSplittingSettingsUI();
}

[SettingsTab name="Performance" icon="Tachometer" order=4]
void RenderTriggerVisualizerPerformanceSettingsTab() {
    TriggerVisualizer::App::RenderPerformanceSettingsUI();
}

[SettingsTab name="Color" icon="Tint" order=5]
void RenderTriggerVisualizerColorSettingsTab() {
    TriggerVisualizer::App::RenderColorSettingsUI();
}

[SettingsTab name="Proximity" icon="Car" order=6]
void RenderTriggerVisualizerProximitySettingsTab() {
    TriggerVisualizer::App::RenderProximitySettingsUI();
}

[SettingsTab name="Sources" icon="Filter" order=7]
void RenderTriggerVisualizerSourcesSettingsTab() {
    TriggerVisualizer::App::RenderSourcesSettingsUI();
}

[SettingsTab name="Labels" icon="Tags" order=8]
void RenderTriggerVisualizerLabelsSettingsTab() {
    TriggerVisualizer::App::RenderLabelsSettingsUI();
}

[SettingsTab name="Logging" icon="ListAlt" order=99]
void RenderTriggerVisualizerLoggingSettingsTab() {
    TriggerVisualizer::App::RenderLoggingSettingsUI();
}
