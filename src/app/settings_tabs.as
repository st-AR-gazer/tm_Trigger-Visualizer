[SettingsTab name="General" icon="Cog" order=1]
void RenderTriggerVisualizerGeneralSettingsTab() {
    TriggerVisualizer::App::RenderGeneralSettingsUI();
}

[SettingsTab name="World Rendering" icon="Cube" order=2]
void RenderTriggerVisualizerWorldRenderingSettingsTab() {
    TriggerVisualizer::App::RenderWorldRenderingSettingsUI();
}

[SettingsTab name="Performance" icon="Tachometer" order=3]
void RenderTriggerVisualizerPerformanceSettingsTab() {
    TriggerVisualizer::App::RenderPerformanceSettingsUI();
}

[SettingsTab name="Sources" icon="Filter" order=4]
void RenderTriggerVisualizerSourcesSettingsTab() {
    TriggerVisualizer::App::RenderSourcesSettingsUI();
}

[SettingsTab name="Labels" icon="Tags" order=5]
void RenderTriggerVisualizerLabelsSettingsTab() {
    TriggerVisualizer::App::RenderLabelsSettingsUI();
}

[SettingsTab name="Logging" icon="ListAlt" order=99]
void RenderTriggerVisualizerLoggingSettingsTab() {
    TriggerVisualizer::App::RenderLoggingSettingsUI();
}
