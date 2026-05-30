namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                // ty XertroV for the RE :PeepoHeart:
                // https://github.com/XertroV/tm-editor-plus-plus/blob/fcace8e59e0039f703247528e20b4cd475f04865/src/Dev.as#L566
                // https://github.com/XertroV/tm-editor-plus-plus/blob/fcace8e59e0039f703247528e20b4cd475f04865/src/Editor/OffzonePatch.as#L23

                uint16 GetMemberOffset(const string &in className, const string &in memberName) {
                    auto ty = Reflection::GetType(className);
                    return ty.GetMember(memberName).Offset;
                }

                const uint16 O_MAP_SCRIPTMETADATA = GetMemberOffset("CGameCtnChallenge", "ScriptMetadata");
                const uint16 O_MAP_OFFZONE_SIZE_OFFSET = O_MAP_SCRIPTMETADATA + (0x6A0 - 0x668);
                const uint16 O_MAP_OFFZONE_BUF_OFFSET = O_MAP_SCRIPTMETADATA + (0x6B0 - 0x668);

                bool HasReadableOffzoneData(CGameCtnChallenge@ map) {
                    return map !is null;
                }

                nat3 ReadOffzoneTriggerSize(CGameCtnChallenge@ map) {
                    if (!HasReadableOffzoneData(map)) return nat3(1, 1, 1);
                    return Dev::GetOffsetNat3(map, O_MAP_OFFZONE_SIZE_OFFSET);
                }

                uint ReadOffzoneCount(CGameCtnChallenge@ map) {
                    if (!HasReadableOffzoneData(map)) return 0;
                    return Dev::GetOffsetUint32(map, O_MAP_OFFZONE_BUF_OFFSET + 0x8);
                }

                uint64 ReadOffzoneBufferPtr(CGameCtnChallenge@ map) {
                    if (!HasReadableOffzoneData(map)) return 0;
                    return Dev::GetOffsetUint64(map, O_MAP_OFFZONE_BUF_OFFSET);
                }

                array<TriggerRangeRaw@> @ReadOffzoneRawRanges(CGameCtnChallenge@ map) {
                    auto ranges = array<TriggerRangeRaw@>();
                    if (!HasReadableOffzoneData(map)) return ranges;

                    uint offzoneCount = ReadOffzoneCount(map);
                    uint64 offzoneBufPtr = ReadOffzoneBufferPtr(map);
                    if (offzoneCount == 0 || offzoneBufPtr == 0) return ranges;

                    for (uint i = 0; i < offzoneCount; i++) {
                        uint64 startPtr = offzoneBufPtr + i * 0x18;
                        uint64 endPtr = startPtr + 0xC;
                        auto start = Dev::ReadInt3(startPtr);
                        auto end = Dev::ReadInt3(endPtr);
                        ranges.InsertLast(TriggerRangeRaw(start, end));
                    }

                    return ranges;
                }

                TriggerSourceSnapshot@ ReadOffzoneTriggerSource(CGameCtnChallenge@ map, bool enabled) {
                    auto source = TriggerSourceSnapshot(TRIGGER_SOURCE_OFFZONE, enabled);
                    source.RawTriggerSize = ReadOffzoneTriggerSize(map);
                    source.RawBufferPtr = ReadOffzoneBufferPtr(map);
                    @source.GridSpec = BuildTriggerGridSpec(map, source.RawTriggerSize);
                    source.RawRanges = ReadOffzoneRawRanges(map);
                    source.TriggerVolumes = TriggerRangesToTriggerVolumes(
                        source.RawRanges,
                        source.GridSpec,
                        TRIGGER_SOURCE_OFFZONE
                    );
                    return source;
                }
            }
        }
    }
}
