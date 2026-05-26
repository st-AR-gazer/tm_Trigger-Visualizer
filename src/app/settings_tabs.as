[SettingsTab name="General" icon="Cog" order=1]
void RenderTriggerVisualizerGeneralSettingsTab() {
    TriggerVisualizer::App::RenderGeneralSettingsUI();
}

[SettingsTab name="World Rendering" icon="Cube" order=2]
void RenderTriggerVisualizerWorldRenderingSettingsTab() {
    TriggerVisualizer::App::RenderWorldRenderingSettingsUI();
}

[SettingsTab name="Sources" icon="Filter" order=3]
void RenderTriggerVisualizerSourcesSettingsTab() {
    TriggerVisualizer::App::RenderSourcesSettingsUI();
}

[SettingsTab name="Labels" icon="Tags" order=4]
void RenderTriggerVisualizerLabelsSettingsTab() {
    TriggerVisualizer::App::RenderLabelsSettingsUI();
}

[SettingsTab name="Logging" icon="ListAlt" order=99]
void RenderTriggerVisualizerLoggingSettingsTab() {
    TriggerVisualizer::App::RenderLoggingSettingsUI();
}
