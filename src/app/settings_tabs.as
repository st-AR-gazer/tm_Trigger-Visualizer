[SettingsTab name="General" icon="Cog" order=1]
void RenderTriggerVisualizerGeneralSettingsTab() {
    TriggerVisualizer::App::RenderGeneralSettingsUi();
}

[SettingsTab name="World Rendering" icon="Cube" order=2]
void RenderTriggerVisualizerWorldRenderingSettingsTab() {
    TriggerVisualizer::App::RenderWorldRenderingSettingsUi();
}

[SettingsTab name="Performance" icon="Tachometer" order=3]
void RenderTriggerVisualizerPerformanceSettingsTab() {
    TriggerVisualizer::App::RenderPerformanceSettingsUi();
}

[SettingsTab name="Sources" icon="Filter" order=4]
void RenderTriggerVisualizerSourcesSettingsTab() {
    TriggerVisualizer::App::RenderSourcesSettingsUi();
}

[SettingsTab name="Labels" icon="Tags" order=5]
void RenderTriggerVisualizerLabelsSettingsTab() {
    TriggerVisualizer::App::RenderLabelsSettingsUi();
}

[SettingsTab name="Logging" icon="ListAlt" order=99]
void RenderTriggerVisualizerLoggingSettingsTab() {
    TriggerVisualizer::App::RenderLoggingSettingsUi();
}
