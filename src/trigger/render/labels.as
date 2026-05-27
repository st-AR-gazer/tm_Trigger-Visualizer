namespace TriggerVisualizer {
    namespace Trigger {
        namespace Render {
            vec3 GetTriggerVolumeLabelPosition(const TriggerVolume@ box) {
                if (box is null) return vec3();

                vec3 center = box.Center();
                return vec3(center.x, box.Max.y + 1.0f, center.z);
            }

            bool IsScreenPositionVisible(const vec2 &in pos, float margin = 64.0f) {
                return pos.x >= -margin
                    && pos.y >= -margin
                    && pos.x <= float(Display::GetWidth()) + margin
                    && pos.y <= float(Display::GetHeight()) + margin;
            }

            string FormatRawRangeLabel(const TriggerRangeRaw@ rawRange) {
                if (rawRange is null) return "";
                return rawRange.Start.ToString() + " -> " + rawRange.End.ToString();
            }

            string FormatWorldSizeLabel(const TriggerVolume@ box) {
                if (box is null) return "";
                vec3 size = box.Size();
                float sx = size.x;
                float sy = size.y;
                float sz = size.z;
                return Text::Format("%.1f", sx)
                    + " x " + Text::Format("%.1f", sy)
                    + " x " + Text::Format("%.1f", sz)
                    + " m";
            }

            string BuildTriggerVolumeLabelText(uint index, const TriggerRangeRaw@ rawRange, const TriggerVolume@ box) {
                array<string> parts;

                if (TriggerVisualizer::Trigger::UI::S_LabelShowIndex) {
                    parts.InsertLast("#" + index);
                }

                if (box !is null && box.Source == TRIGGER_SOURCE_MEDIATRACKER) {
                    parts.InsertLast(box.DisplayLabelWithOptions(TriggerVisualizer::Trigger::UI::S_LabelShowSourcePrefix, TriggerVisualizer::Trigger::UI::S_LabelShowIslandIndex, TriggerVisualizer::Trigger::UI::S_LabelUseDetectedTriggerName, TriggerVisualizer::Trigger::UI::S_LabelShowDetectedTriggerName));
                }

                if (TriggerVisualizer::Trigger::UI::S_LabelShowRawRange && rawRange !is null) {
                    parts.InsertLast(FormatRawRangeLabel(rawRange));
                }

                if (TriggerVisualizer::Trigger::UI::S_LabelShowWorldSize) {
                    parts.InsertLast(FormatWorldSizeLabel(box));
                }

                if (parts.Length == 0) {
                    parts.InsertLast("#" + index);
                }

                return string::Join(parts, " | ");
            }

            vec4 GetLabelTextColor(float fade) {
                float alpha = TriggerVisualizer::Trigger::UI::S_LabelAlpha * Math::Clamp(fade, 0.0f, 1.0f);
                return vec4(1.0f, 1.0f, 1.0f, alpha);
            }

            vec4 GetLabelBackgroundColor(float fade) {
                float alpha = TriggerVisualizer::Trigger::UI::S_LabelBackgroundAlpha * Math::Clamp(fade, 0.0f, 1.0f);
                return vec4(0.0f, 0.0f, 0.0f, alpha);
            }

            bool ShouldDrawTriggerVolumeLabel(const TriggerVolume@ box, const vec3 &in cameraPos) {
                if (!TriggerVisualizer::Trigger::UI::S_ShowLabels) return false;
                if (box is null) return false;

                vec3 screenPos = Camera::ToScreen(GetTriggerVolumeLabelPosition(box));
                return screenPos.z < 0 && IsScreenPositionVisible(screenPos.xy);
            }

            void DrawLabelCard(const vec2 &in screenPos, const string &in label, float fade) {
                if (label.Length == 0) return;

                nvg::Reset();
                nvg::FontSize(TriggerVisualizer::Trigger::UI::S_LabelFontSize);
                nvg::TextAlign(nvg::Align::Left | nvg::Align::Top);

                vec2 textSize = nvg::TextBounds(label);
                vec2 padding = vec2(6.0f, 4.0f);
                vec2 cardSize = textSize + padding * 2.0f;
                vec2 cardPos = screenPos - vec2(cardSize.x * 0.5f, cardSize.y + 8.0f);
                vec2 textPos = cardPos + padding;

                nvg::BeginPath();
                nvg::RoundedRect(cardPos, cardSize, 4.0f);
                nvg::FillColor(GetLabelBackgroundColor(fade));
                nvg::Fill();
                nvg::ClosePath();

                nvg::FillColor(vec4(0.0f, 0.0f, 0.0f, 0.65f * Math::Clamp(fade, 0.0f, 1.0f)));
                nvg::Text(textPos + vec2(1.0f, 1.0f), label);
                nvg::FillColor(GetLabelTextColor(fade));
                nvg::Text(textPos, label);
            }

            void DrawTriggerVolumeLabel(
                const TriggerVolume@ box,
                const TriggerRangeRaw@ rawRange,
                uint index,
                const vec3 &in cameraPos,
                float fade
            ) {
                if (!ShouldDrawTriggerVolumeLabel(box, cameraPos)) return;
                if (!IsVisibleFadeFactor(fade)) return;

                vec3 screenPos = Camera::ToScreen(GetTriggerVolumeLabelPosition(box));
                DrawLabelCard(screenPos.xy, BuildTriggerVolumeLabelText(index, rawRange, box), fade);
            }

            uint CountVisibleTriggerVolumeLabels(
                const array<TriggerVolume@> @boxes,
                const vec3 &in cameraPos,
                const TriggerVisualizer::Trigger::Data::ProximityReferenceState@ proximityState
            ) {
                if (boxes is null || !TriggerVisualizer::Trigger::UI::S_ShowLabels) return 0;

                uint count = 0;
                for (uint i = 0; i < boxes.Length; i++) {
                    float fade = GetTriggerVolumeRenderFadeFactor(boxes[i], cameraPos, proximityState);
                    if (!IsVisibleFadeFactor(fade)) continue;
                    if (ShouldDrawTriggerVolumeLabel(boxes[i], cameraPos)) count++;
                }
                return count;
            }
        }
    }
}
