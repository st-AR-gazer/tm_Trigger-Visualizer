namespace OffzoneVisualizer {
    namespace Offzone {
        namespace Data {
            const string OFFZONE_VISUALIZER_MAP_COMMAND_PREFIX = "/offzone-visualizer";
            const float MAP_HINT_BLOCK_SIZE_XZ = 32.0f;
            const float MAP_HINT_BLOCK_SIZE_Y = 8.0f;

            string ReadMapComments(CGameCtnChallenge@ map) {
                if (map is null) return "";
                return string(map.Comments);
            }

            array<string>@ SplitMapHintTokens(const string &in line) {
                auto tokens = array<string>();
                auto rawTokens = line.Replace("\t", " ").Split(" ");
                for (uint i = 0; i < rawTokens.Length; i++) {
                    string token = rawTokens[i].Trim();
                    if (token.Length == 0) continue;
                    tokens.InsertLast(token);
                }
                return tokens;
            }

            bool TryParseMapHintDistance(const string &in rawValue, float blockSize, float &out value) {
                string token = rawValue.Trim();
                if (token.Length == 0) return false;

                bool isBlocks = token.StartsWith("!");
                string numeric = isBlocks ? token.SubStr(1).Trim() : token;
                if (numeric.Length == 0) return false;

                float parsed = 0.0f;
                if (!Text::TryParseFloat(numeric, parsed)) return false;
                if (parsed < 0.0f) return false;

                value = isBlocks ? parsed * blockSize : parsed;
                return true;
            }

            void ApplyMapHintCommand(MapRenderHints@ hints, const string &in line) {
                if (hints is null) return;

                string trimmed = line.Trim();
                if (trimmed.Length == 0) return;

                string lower = trimmed.ToLower();
                if (!lower.StartsWith(OFFZONE_VISUALIZER_MAP_COMMAND_PREFIX)) return;

                auto tokens = SplitMapHintTokens(trimmed);
                if (tokens.Length < 2) return;
                if (tokens[0].ToLower() != OFFZONE_VISUALIZER_MAP_COMMAND_PREFIX) return;

                string command = tokens[1].ToLower();
                if (command == "suggest-off") {
                    hints.HasAnyCommand = true;
                    hints.SuggestOff = true;
                    hints.Commands.InsertLast(trimmed);
                    return;
                }

                if (command == "force-off") {
                    hints.HasAnyCommand = true;
                    hints.ForceOff = true;
                    hints.Commands.InsertLast(trimmed);
                    return;
                }

                if (tokens.Length < 3) return;

                float distance = 0.0f;
                if (command == "suggest-draw-distance-xz") {
                    if (!TryParseMapHintDistance(tokens[2], MAP_HINT_BLOCK_SIZE_XZ, distance)) return;
                    hints.HasAnyCommand = true;
                    hints.HasSuggestedDrawDistanceXZ = true;
                    hints.SuggestedDrawDistanceXZ = distance;
                    hints.Commands.InsertLast(trimmed);
                    return;
                }

                if (command == "suggest-draw-distance-y") {
                    if (!TryParseMapHintDistance(tokens[2], MAP_HINT_BLOCK_SIZE_Y, distance)) return;
                    hints.HasAnyCommand = true;
                    hints.HasSuggestedDrawDistanceY = true;
                    hints.SuggestedDrawDistanceY = distance;
                    hints.Commands.InsertLast(trimmed);
                    return;
                }
            }

            MapRenderHints@ ParseMapRenderHints(const string &in comments) {
                auto hints = MapRenderHints();
                string normalized = Text::StripOpenplanetFormatCodes(comments)
                    .Replace("\r\n", "\n")
                    .Replace("\r", "\n");

                auto lines = normalized.Split("\n");
                for (uint i = 0; i < lines.Length; i++) {
                    ApplyMapHintCommand(hints, lines[i]);
                }

                return hints;
            }
        }
    }
}
