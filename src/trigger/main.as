namespace TriggerVisualizer {
    namespace Trigger {
        TriggerVisualizer::Trigger::Data::RuntimeContext@ g_RuntimeContext = null;
        MapSnapshot@ g_MapSnapshot = null;
        CGameCtnChallenge@ g_CachedMapSnapshotRootMap = null;
        string g_CachedMapSnapshotContextKey = "";
        string g_CachedMapSnapshotFilterKey = "";
        bool g_CachedMapSnapshotOffzoneEnabled = false;
        bool g_CachedMapSnapshotMediaTrackerEnabled = false;
        bool g_CachedMapSnapshotCrystalEnabled = false;
        uint g_CachedMapSnapshotRefreshTime = 0;
        TriggerSourceSnapshot@ g_CachedOffzoneSource = null;
        CGameCtnChallenge@ g_CachedOffzoneRootMap = null;
        uint g_CachedOffzoneSourceRefreshTime = 0;
        TriggerSourceSnapshot@ g_CachedMediaTrackerSource = null;
        CGameCtnChallenge@ g_CachedMediaTrackerRootMap = null;
        string g_CachedMediaTrackerContextKey = "";
        bool g_CachedMediaTrackerCellRendering = false;
        string g_CachedMediaTrackerGroupName = "";
        uint64 g_CachedMediaTrackerGroupBufferPtr = 0;
        uint g_CachedMediaTrackerSourceRefreshTime = 0;
        TriggerSourceSnapshot@ g_CachedCrystalSource = null;
        CGameCtnChallenge@ g_CachedCrystalRootMap = null;
        string g_CachedCrystalContextKey = "";
        uint g_CachedCrystalBlockCount = 0;
        uint g_CachedCrystalBakedBlockCount = 0;
        uint g_CachedCrystalAnchoredObjectCount = 0;
        uint g_CachedCrystalSourceCacheVersion = 0;
        bool g_CachedCrystalCustomItemsAndBlockItemsOnly = false;
        bool g_CachedCrystalMergeAdjacentTriggerVolumes = true;
        uint g_CrystalSourceCacheVersion = 1;
        uint g_CachedCrystalSourceRefreshTime = 0;
        bool g_CrystalSourceRefreshInProgress = false;
        CGameCtnChallenge@ g_PendingCrystalRootMap = null;
        string g_PendingCrystalContextKey = "";
        uint g_PendingCrystalBlockCount = 0;
        uint g_PendingCrystalBakedBlockCount = 0;
        uint g_PendingCrystalAnchoredObjectCount = 0;
        uint g_PendingCrystalSourceCacheVersion = 0;
        bool g_PendingCrystalCustomItemsAndBlockItemsOnly = false;
        bool g_PendingCrystalMergeAdjacentTriggerVolumes = true;
        uint g_CrystalSourceProgressPublishTime = 0;
        uint g_CrystalSourceProgressPublishVolumeCount = 0;

        const uint CRYSTAL_SOURCE_PROGRESS_PUBLISH_INTERVAL_MS = 250;
        const bool MEDIATRACKER_RENDER_CELLS = true;

        void RenderWorld() {
            RefreshCurrentState();
            TriggerVisualizer::Trigger::Render::RenderWorld();
        }

        void RenderDevPanel() {
            RefreshCurrentState();
            TriggerVisualizer::Trigger::UI::Dev::RenderDevPanelContent();
        }

        void RefreshCurrentState() {
            @g_RuntimeContext = TriggerVisualizer::Trigger::Data::GetRuntimeContext();
            if (CanReuseMapSnapshot(g_RuntimeContext)) return;

            @g_MapSnapshot = BuildMapSnapshot(g_RuntimeContext);
            StoreMapSnapshotCacheState(g_RuntimeContext);
        }

        TriggerVisualizer::Trigger::Data::RuntimeContext@ GetCurrentRuntimeContext() {
            if (g_RuntimeContext is null) RefreshCurrentState();
            return g_RuntimeContext;
        }

        MapSnapshot@ GetCurrentMapSnapshot() {
            if (g_MapSnapshot is null) RefreshCurrentState();
            return g_MapSnapshot;
        }

        string GetMapSnapshotContextKey(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            if (ctx is null) return "<null>";

            string key = ctx.HasMap ? "map" : "no-map";
            if (ctx.IsReplayEditor) return key + "|replay-editor";
            if (ctx.IsEditorMediaTracker) return key + "|editor-mediatracker";
            if (ctx.IsEditorTestMode) return key + "|editor-test";
            if (ctx.IsMapEditor) return key + "|map-editor";
            if (ctx.IsPlayableMap) return key + "|playable";
            if (ctx.IsMeshModeler) return key + "|mesh-modeler";
            if (ctx.IsInEditor) return key + "|editor";
            if (ctx.IsInMenu) return key + "|menu";
            return key + "|unknown";
        }

        uint GetMediaTrackerRefreshIntervalMs(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            return uint(TriggerVisualizer::Trigger::UI::GetMediaTrackerRefreshIntervalMsForRuntime(ctx));
        }

        uint GetOffzoneRefreshIntervalMs(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            return uint(TriggerVisualizer::Trigger::UI::GetOffzoneRefreshIntervalMsForRuntime(ctx));
        }

        uint GetCrystalRefreshIntervalMs(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            return uint(TriggerVisualizer::Trigger::UI::GetCrystalRefreshIntervalMsForRuntime(ctx));
        }

        bool UsesPeriodicOffzoneRefresh(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            bool offzoneEnabled
        ) {
            return offzoneEnabled && ctx !is null && GetOffzoneRefreshIntervalMs(ctx) > 0;
        }

        bool UsesPeriodicMediaTrackerRefresh(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            bool mediaTrackerEnabled
        ) {
            return mediaTrackerEnabled && ctx !is null && GetMediaTrackerRefreshIntervalMs(ctx) > 0;
        }

        bool UsesPeriodicCrystalRefresh(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            bool crystalEnabled
        ) {
            return crystalEnabled && ctx !is null && GetCrystalRefreshIntervalMs(ctx) > 0;
        }

        bool IsOffzoneRefreshDue(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx, uint lastRefreshTime) {
            if (lastRefreshTime == 0) return true;
            return Time::Now - lastRefreshTime >= GetOffzoneRefreshIntervalMs(ctx);
        }

        bool IsMediaTrackerRefreshDue(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            uint lastRefreshTime
        ) {
            if (lastRefreshTime == 0) return true;
            return Time::Now - lastRefreshTime >= GetMediaTrackerRefreshIntervalMs(ctx);
        }

        bool IsCrystalRefreshDue(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx, uint lastRefreshTime) {
            if (lastRefreshTime == 0) return true;
            return Time::Now - lastRefreshTime >= GetCrystalRefreshIntervalMs(ctx);
        }

        bool CanReuseMapSnapshot(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            if (g_MapSnapshot is null || ctx is null) return false;

            bool offzoneEnabled = TriggerVisualizer::Trigger::UI::IsOffzoneSourceEnabledForRuntime(ctx);
            bool mediaTrackerEnabled = TriggerVisualizer::Trigger::UI::IsMediaTrackerSourceEnabledForRuntime(ctx);
            bool crystalEnabled = TriggerVisualizer::Trigger::UI::IsCrystalSourceEnabledForRuntime(ctx);
            if (UsesPeriodicOffzoneRefresh(ctx, offzoneEnabled) && IsOffzoneRefreshDue(ctx, g_CachedOffzoneSourceRefreshTime)) {
                return false;
            }
            if (UsesPeriodicMediaTrackerRefresh(ctx, mediaTrackerEnabled) && IsMediaTrackerRefreshDue(ctx, g_CachedMediaTrackerSourceRefreshTime)) {
                return false;
            }
            if (UsesPeriodicCrystalRefresh(ctx, crystalEnabled) && IsCrystalRefreshDue(ctx, g_CachedCrystalSourceRefreshTime) && !IsCrystalSourceRefreshInProgressFor(ctx)) {
                return false;
            }

            return ctx.RootMap is g_CachedMapSnapshotRootMap
                && g_CachedMapSnapshotContextKey == GetMapSnapshotContextKey(ctx)
                && g_CachedMapSnapshotFilterKey == TriggerVisualizer::Trigger::UI::GetMapSnapshotFilterSettingsKey(ctx)
                && g_CachedMapSnapshotOffzoneEnabled == offzoneEnabled
                && g_CachedMapSnapshotMediaTrackerEnabled == mediaTrackerEnabled
                && g_CachedMapSnapshotCrystalEnabled == crystalEnabled
                && CanReuseCrystalTriggerSource(ctx, crystalEnabled);
        }

        void StoreMapSnapshotCacheState(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            if (ctx is null) {
                @g_CachedMapSnapshotRootMap = null;
                g_CachedMapSnapshotContextKey = "<null>";
                g_CachedMapSnapshotFilterKey = "";
                g_CachedMapSnapshotOffzoneEnabled = false;
                g_CachedMapSnapshotMediaTrackerEnabled = false;
                g_CachedMapSnapshotCrystalEnabled = false;
                g_CachedMapSnapshotRefreshTime = 0;
                return;
            }

            @g_CachedMapSnapshotRootMap = ctx.RootMap;
            g_CachedMapSnapshotContextKey = GetMapSnapshotContextKey(ctx);
            g_CachedMapSnapshotFilterKey = TriggerVisualizer::Trigger::UI::GetMapSnapshotFilterSettingsKey(ctx);
            g_CachedMapSnapshotOffzoneEnabled = TriggerVisualizer::Trigger::UI::IsOffzoneSourceEnabledForRuntime(ctx);
            g_CachedMapSnapshotMediaTrackerEnabled = TriggerVisualizer::Trigger::UI::IsMediaTrackerSourceEnabledForRuntime(ctx);
            g_CachedMapSnapshotCrystalEnabled = TriggerVisualizer::Trigger::UI::IsCrystalSourceEnabledForRuntime(ctx);
            g_CachedMapSnapshotRefreshTime = Time::Now;
        }

        MapSnapshot@ BuildMapSnapshot(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            auto snapshot = MapSnapshot();
            if (ctx is null) return snapshot;

            snapshot.MapUid = ctx.MapUid;
            if (!ctx.HasMap) return snapshot;

            snapshot.MapComments = TriggerVisualizer::Trigger::Data::ReadMapComments(ctx.RootMap);
            @snapshot.RenderHints = TriggerVisualizer::Trigger::Data::ParseMapRenderHints(snapshot.MapComments);
            bool offzoneEnabled = TriggerVisualizer::Trigger::UI::IsOffzoneSourceEnabledForRuntime(ctx);
            auto offzoneSource = GetOffzoneTriggerSource(ctx, offzoneEnabled);
            snapshot.RawTriggerSize = offzoneSource.RawTriggerSize;
            snapshot.RawBufferPtr = offzoneSource.RawBufferPtr;
            @snapshot.GridSpec = offzoneSource.GridSpec;
            snapshot.RawRanges = offzoneSource.RawRanges;
            AddSourceToMapSnapshot(snapshot, offzoneSource, ctx);
            auto mediaTrackerSource = GetMediaTrackerTriggerSource(ctx);
            AddSourceToMapSnapshot(snapshot, mediaTrackerSource, ctx);
            bool crystalEnabled = TriggerVisualizer::Trigger::UI::IsCrystalSourceEnabledForRuntime(ctx);
            auto crystalSource = GetCrystalTriggerSource(ctx, crystalEnabled);
            AddSourceToMapSnapshot(snapshot, crystalSource, ctx);
            TriggerVisualizer::Trigger::Data::BuildMapSnapshotStaticOutlineCache(snapshot);
            TriggerVisualizer::Trigger::Data::BuildMapSnapshotSpatialIndex(snapshot);

            return snapshot;
        }

        bool IsMapHintTargetDisabled(const MapRenderHints@ hints, const string &in targetKey) {
            if (hints is null || targetKey.Length == 0) return false;
            if (hints.HasForceOffTarget(targetKey)) return true;
            return hints.HasSuggestOffTarget(targetKey) && TriggerVisualizer::Trigger::UI::S_RespectMapSuggestOff;
        }

        bool IsGlobalWorldRenderingDisabledByMapHints(const MapRenderHints@ hints) {
            if (hints is null) return false;
            if (hints.ForceOff) return true;
            return hints.SuggestOff && TriggerVisualizer::Trigger::UI::S_RespectMapSuggestOff;
        }

        string GetGlobalWorldRenderingMapHintDisableSummary(const MapRenderHints@ hints) {
            if (hints is null) return "";
            if (hints.ForceOff) return "/trigger-visualizer force-off";
            if (hints.SuggestOff && TriggerVisualizer::Trigger::UI::S_RespectMapSuggestOff) {
                return "/trigger-visualizer suggest-off";
            }
            return "";
        }

        string GetWorldRenderingHiddenByMapCommentSummary() {
            auto snapshot = GetCurrentMapSnapshot();
            if (snapshot is null) return "";
            return GetGlobalWorldRenderingMapHintDisableSummary(snapshot.RenderHints);
        }

        bool IsWorldRenderingHiddenByMapComment() {
            return GetWorldRenderingHiddenByMapCommentSummary().Length > 0;
        }

        bool IsSourceDisabledByMapHints(const MapRenderHints@ hints, int source) {
            return IsMapHintTargetDisabled(hints, GetTriggerSourceTargetKey(source));
        }

        bool IsTriggerVolumeDisabledByMapHints(const MapRenderHints@ hints, const TriggerVolume@ volume) {
            if (hints is null || volume is null) return false;

            for (uint i = 0; i < hints.ForceOffTargets.Length; i++) {
                if (TriggerVolumeMatchesTargetKey(volume, hints.ForceOffTargets[i])) return true;
            }
            if (!TriggerVisualizer::Trigger::UI::S_RespectMapSuggestOff) return false;
            for (uint i = 0; i < hints.SuggestOffTargets.Length; i++) {
                if (TriggerVolumeMatchesTargetKey(volume, hints.SuggestOffTargets[i])) return true;
            }

            return false;
        }

        void AddSourceToMapSnapshot(
            MapSnapshot@ snapshot,
            TriggerSourceSnapshot@ source,
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx
        ) {
            if (snapshot is null || source is null) return;

            snapshot.Sources.InsertLast(source);
            if (!source.Enabled) return;
            if (IsSourceDisabledByMapHints(snapshot.RenderHints, source.Source)) return;

            auto filteredVolumes = array<TriggerVolume@>();
            for (uint i = 0; i < source.TriggerVolumes.Length; i++) {
                auto volume = source.TriggerVolumes[i];
                if (IsTriggerVolumeDisabledByMapHints(snapshot.RenderHints, volume)) continue;
                if (!TriggerVisualizer::Trigger::UI::IsTriggerVolumeEnabledBySubtypeSettings(volume, ctx)) continue;
                filteredVolumes.InsertLast(volume);
            }
            bool canMergeSource = source.Source != TRIGGER_SOURCE_CRYSTAL;
            if (canMergeSource && TriggerVisualizer::Trigger::UI::S_MergeAdjacentTriggerVolumes) {
                auto mergedVolumes = TriggerVisualizer::Trigger::Data::MergeAdjacentTriggerVolumes(filteredVolumes);
                for (uint i = 0; i < mergedVolumes.Length; i++) {
                    snapshot.TriggerVolumes.InsertLast(mergedVolumes[i]);
                }
                return;
            }

            for (uint i = 0; i < filteredVolumes.Length; i++) {
                snapshot.TriggerVolumes.InsertLast(filteredVolumes[i]);
            }
        }

        TriggerSourceSnapshot@ GetOffzoneTriggerSource(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            bool enabled
        ) {
            if (ctx is null || ctx.RootMap is null) {
                return TriggerVisualizer::Trigger::Data::Sources::ReadOffzoneTriggerSource(null, enabled);
            }

            bool forceRefresh = UsesPeriodicOffzoneRefresh(ctx, enabled)
                && IsOffzoneRefreshDue(ctx, g_CachedOffzoneSourceRefreshTime);

            if (forceRefresh || g_CachedOffzoneSource is null || ctx.RootMap !is g_CachedOffzoneRootMap) {
                @g_CachedOffzoneSource = TriggerVisualizer::Trigger::Data::Sources::ReadOffzoneTriggerSource(
                    ctx.RootMap,
                    true
                );
                @g_CachedOffzoneRootMap = ctx.RootMap;
                g_CachedOffzoneSourceRefreshTime = Time::Now;
            }
            g_CachedOffzoneSource.Enabled = enabled;
            return g_CachedOffzoneSource;
        }

        uint GetCrystalMapBlockCount(CGameCtnChallenge@ map) {
            if (map is null) return 0;
            try {
                return map.Blocks.Length;
            } catch {
                return 0;
            }
        }

        uint GetCrystalMapBakedBlockCount(CGameCtnChallenge@ map) {
            if (map is null) return 0;
            try {
                return map.BakedBlocks.Length;
            } catch {
                return 0;
            }
        }

        uint GetCrystalMapAnchoredObjectCount(CGameCtnChallenge@ map) {
            if (map is null) return 0;
            try {
                return map.AnchoredObjects.Length;
            } catch {
                return 0;
            }
        }

        bool GetCrystalCustomItemsAndBlockItemsOnly(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            return TriggerVisualizer::Trigger::UI::IsCrystalCustomItemsAndBlockItemsOnlyForRuntime(ctx);
        }

        bool GetCrystalMergeAdjacentTriggerVolumes() {
            return TriggerVisualizer::Trigger::UI::S_MergeAdjacentTriggerVolumes;
        }

        bool CachedCrystalSourceMatchesBuildIdentity(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            const string &in contextKey,
            uint blockCount,
            uint bakedBlockCount,
            uint anchoredObjectCount
        ) {
            return g_CachedCrystalSource !is null
                && ctx !is null
                && ctx.RootMap !is null
                && ctx.RootMap is g_CachedCrystalRootMap
                && g_CachedCrystalContextKey == contextKey
                && g_CachedCrystalBlockCount == blockCount
                && g_CachedCrystalBakedBlockCount == bakedBlockCount
                && g_CachedCrystalAnchoredObjectCount == anchoredObjectCount
                && g_CachedCrystalSourceCacheVersion == g_CrystalSourceCacheVersion
                && g_CachedCrystalCustomItemsAndBlockItemsOnly == GetCrystalCustomItemsAndBlockItemsOnly(ctx);
        }

        bool CachedCrystalSourceMatchesCurrentMergeState(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            const string &in contextKey,
            uint blockCount,
            uint bakedBlockCount,
            uint anchoredObjectCount
        ) {
            return CachedCrystalSourceMatchesBuildIdentity(
                ctx,
                contextKey,
                blockCount,
                bakedBlockCount,
                anchoredObjectCount
            ) && g_CachedCrystalMergeAdjacentTriggerVolumes == GetCrystalMergeAdjacentTriggerVolumes();
        }

        bool CanUseCachedCrystalSourceDuringMergeRefresh(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            const string &in contextKey,
            uint blockCount,
            uint bakedBlockCount,
            uint anchoredObjectCount
        ) {
            return CachedCrystalSourceMatchesBuildIdentity(
                ctx,
                contextKey,
                blockCount,
                bakedBlockCount,
                anchoredObjectCount
            ) && g_CachedCrystalMergeAdjacentTriggerVolumes != GetCrystalMergeAdjacentTriggerVolumes();
        }

        TriggerSourceSnapshot@ RebuildCachedCrystalSourceForCurrentMergeState(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            const string &in contextKey,
            uint blockCount,
            uint bakedBlockCount,
            uint anchoredObjectCount
        ) {
            if (!CanUseCachedCrystalSourceDuringMergeRefresh(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount)) {
                return null;
            }

            @g_CachedCrystalSource = TriggerVisualizer::Trigger::Data::Sources::CloneCrystalSourceForMergeMode(
                g_CachedCrystalSource,
                GetCrystalMergeAdjacentTriggerVolumes()
            );
            if (g_CachedCrystalSource is null) return null;

            g_CachedCrystalMergeAdjacentTriggerVolumes = GetCrystalMergeAdjacentTriggerVolumes();
            g_CachedCrystalSource.Enabled = true;
            return g_CachedCrystalSource;
        }

        bool IsCrystalSourceRefreshInProgressFor(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            if (!g_CrystalSourceRefreshInProgress || ctx is null || ctx.RootMap is null) return false;
            return ctx.RootMap is g_PendingCrystalRootMap
                && g_PendingCrystalContextKey == GetMapSnapshotContextKey(ctx)
                && g_PendingCrystalBlockCount == GetCrystalMapBlockCount(ctx.RootMap)
                && g_PendingCrystalBakedBlockCount == GetCrystalMapBakedBlockCount(ctx.RootMap)
                && g_PendingCrystalAnchoredObjectCount == GetCrystalMapAnchoredObjectCount(ctx.RootMap)
                && g_PendingCrystalSourceCacheVersion == g_CrystalSourceCacheVersion
                && g_PendingCrystalCustomItemsAndBlockItemsOnly == GetCrystalCustomItemsAndBlockItemsOnly(ctx)
                && g_PendingCrystalMergeAdjacentTriggerVolumes == GetCrystalMergeAdjacentTriggerVolumes();
        }

        bool CanReuseCrystalTriggerSource(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            bool enabled
        ) {
            if (!enabled) return true;
            if (ctx is null || ctx.RootMap is null) return false;

            string contextKey = GetMapSnapshotContextKey(ctx);
            uint blockCount = GetCrystalMapBlockCount(ctx.RootMap);
            uint bakedBlockCount = GetCrystalMapBakedBlockCount(ctx.RootMap);
            uint anchoredObjectCount = GetCrystalMapAnchoredObjectCount(ctx.RootMap);
            if (IsCrystalSourceRefreshInProgressFor(ctx)) {
                if (CachedCrystalSourceMatchesCurrentMergeState(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount)) {
                    return true;
                }
                return !CanUseCachedCrystalSourceDuringMergeRefresh(
                    ctx,
                    contextKey,
                    blockCount,
                    bakedBlockCount,
                    anchoredObjectCount
                );
            }

            return CachedCrystalSourceMatchesCurrentMergeState(
                ctx,
                contextKey,
                blockCount,
                bakedBlockCount,
                anchoredObjectCount
            );
        }

        void RefreshCrystalSourceCache() {
            g_CrystalSourceCacheVersion++;
            @g_CachedCrystalSource = null;
            @g_CachedCrystalRootMap = null;
            g_CachedCrystalContextKey = "";
            g_CachedCrystalBlockCount = 0;
            g_CachedCrystalBakedBlockCount = 0;
            g_CachedCrystalAnchoredObjectCount = 0;
            g_CachedCrystalSourceCacheVersion = 0;
            g_CachedCrystalCustomItemsAndBlockItemsOnly = false;
            g_CachedCrystalMergeAdjacentTriggerVolumes = true;
            g_CachedCrystalSourceRefreshTime = 0;
            g_CrystalSourceRefreshInProgress = false;
            @g_PendingCrystalRootMap = null;
            g_PendingCrystalContextKey = "";
            g_PendingCrystalBlockCount = 0;
            g_PendingCrystalBakedBlockCount = 0;
            g_PendingCrystalAnchoredObjectCount = 0;
            g_PendingCrystalSourceCacheVersion = 0;
            g_PendingCrystalCustomItemsAndBlockItemsOnly = false;
            g_PendingCrystalMergeAdjacentTriggerVolumes = true;
            g_CrystalSourceProgressPublishTime = 0;
            g_CrystalSourceProgressPublishVolumeCount = 0;
            @g_MapSnapshot = null;
        }

        TriggerSourceSnapshot@ CreateCrystalRefreshingSource(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            bool enabled
        ) {
            auto source = TriggerVisualizer::Trigger::Data::Sources::CreateCrystalTriggerSourceShell(ctx, enabled);
            if (enabled) {
                TriggerVisualizer::Trigger::Data::Sources::AddCrystalDiagnostic(
                    source,
                    "Crystal source cache refresh is running in the background; existing cached Crystal volumes are reused when available."
                );
            }
            return source;
        }

        void QueueCrystalSourceRefresh(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            const string &in contextKey,
            uint blockCount,
            uint bakedBlockCount,
            uint anchoredObjectCount
        ) {
            if (ctx is null || ctx.RootMap is null) return;
            bool customItemsOnly = GetCrystalCustomItemsAndBlockItemsOnly(ctx);
            bool mergeAdjacent = GetCrystalMergeAdjacentTriggerVolumes();
            if (g_CrystalSourceRefreshInProgress && ctx.RootMap is g_PendingCrystalRootMap && g_PendingCrystalContextKey == contextKey && g_PendingCrystalBlockCount == blockCount && g_PendingCrystalBakedBlockCount == bakedBlockCount && g_PendingCrystalAnchoredObjectCount == anchoredObjectCount && g_PendingCrystalSourceCacheVersion == g_CrystalSourceCacheVersion && g_PendingCrystalCustomItemsAndBlockItemsOnly == customItemsOnly && g_PendingCrystalMergeAdjacentTriggerVolumes == mergeAdjacent) {
                return;
            }

            g_CrystalSourceRefreshInProgress = true;
            @g_PendingCrystalRootMap = ctx.RootMap;
            g_PendingCrystalContextKey = contextKey;
            g_PendingCrystalBlockCount = blockCount;
            g_PendingCrystalBakedBlockCount = bakedBlockCount;
            g_PendingCrystalAnchoredObjectCount = anchoredObjectCount;
            g_PendingCrystalSourceCacheVersion = g_CrystalSourceCacheVersion;
            g_PendingCrystalCustomItemsAndBlockItemsOnly = customItemsOnly;
            g_PendingCrystalMergeAdjacentTriggerVolumes = mergeAdjacent;
            startnew(
                CoroutineFuncUserdataUint64(RefreshCrystalSourceCacheAsync),
                uint64(g_PendingCrystalSourceCacheVersion)
            );
        }

        bool CrystalSourceRefreshRequestMatches(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            const string &in contextKey,
            uint blockCount,
            uint bakedBlockCount,
            uint anchoredObjectCount,
            uint cacheVersion
        ) {
            return ctx !is null
                && ctx.RootMap !is null
                && ctx.RootMap is g_PendingCrystalRootMap
                && g_PendingCrystalContextKey == contextKey
                && g_PendingCrystalBlockCount == blockCount
                && g_PendingCrystalBakedBlockCount == bakedBlockCount
                && g_PendingCrystalAnchoredObjectCount == anchoredObjectCount
                && cacheVersion == g_PendingCrystalSourceCacheVersion
                && cacheVersion == g_CrystalSourceCacheVersion
                && g_PendingCrystalCustomItemsAndBlockItemsOnly == GetCrystalCustomItemsAndBlockItemsOnly(ctx)
                && g_PendingCrystalMergeAdjacentTriggerVolumes == GetCrystalMergeAdjacentTriggerVolumes();
        }

        bool StoreCrystalSourceCacheIfCurrent(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            const string &in contextKey,
            uint blockCount,
            uint bakedBlockCount,
            uint anchoredObjectCount,
            uint cacheVersion,
            TriggerSourceSnapshot@ source
        ) {
            if (source is null) return false;
            if (!CrystalSourceRefreshRequestMatches(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion)) {
                return false;
            }

            @g_CachedCrystalSource = source;
            @g_CachedCrystalRootMap = ctx.RootMap;
            g_CachedCrystalContextKey = contextKey;
            g_CachedCrystalBlockCount = blockCount;
            g_CachedCrystalBakedBlockCount = bakedBlockCount;
            g_CachedCrystalAnchoredObjectCount = anchoredObjectCount;
            g_CachedCrystalSourceCacheVersion = cacheVersion;
            g_CachedCrystalCustomItemsAndBlockItemsOnly = g_PendingCrystalCustomItemsAndBlockItemsOnly;
            g_CachedCrystalMergeAdjacentTriggerVolumes = g_PendingCrystalMergeAdjacentTriggerVolumes;
            g_CachedCrystalSourceRefreshTime = Time::Now;
            @g_MapSnapshot = null;
            return true;
        }

        bool StoreCrystalSourceProgressCacheIfCurrent(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            const string &in contextKey,
            uint blockCount,
            uint bakedBlockCount,
            uint anchoredObjectCount,
            uint cacheVersion,
            TriggerSourceSnapshot@ source
        ) {
            auto progressSource = TriggerVisualizer::Trigger::Data::CloneTriggerSourceSnapshotForCache(source);
            TriggerVisualizer::Trigger::Data::Sources::MergeCrystalExpandableFinishWaypointVolumes(
                progressSource,
                g_PendingCrystalMergeAdjacentTriggerVolumes
            );
            return StoreCrystalSourceCacheIfCurrent(
                ctx,
                contextKey,
                blockCount,
                bakedBlockCount,
                anchoredObjectCount,
                cacheVersion,
                progressSource
            );
        }

        void ResetCrystalSourceProgressPublishState() {
            g_CrystalSourceProgressPublishTime = 0;
            g_CrystalSourceProgressPublishVolumeCount = 0;
        }

        bool PublishCrystalSourceBuildProgressIfDue(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            const string &in contextKey,
            uint blockCount,
            uint bakedBlockCount,
            uint anchoredObjectCount,
            uint cacheVersion,
            TriggerSourceSnapshot@ source,
            bool force = false
        ) {
            if (source is null) return false;
            if (ctx is null || contextKey.Length == 0) return true;
            uint volumeCount = source.TriggerVolumes.Length;
            if (!force) {
                if (volumeCount == 0 || volumeCount == g_CrystalSourceProgressPublishVolumeCount) return true;
                if (g_CrystalSourceProgressPublishTime > 0 && Time::Now - g_CrystalSourceProgressPublishTime < CRYSTAL_SOURCE_PROGRESS_PUBLISH_INTERVAL_MS) return true;
            }

            if (!StoreCrystalSourceProgressCacheIfCurrent(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, source)) {
                return false;
            }
            g_CrystalSourceProgressPublishTime = Time::Now;
            g_CrystalSourceProgressPublishVolumeCount = volumeCount;
            return true;
        }

        void FinishCrystalSourceRefresh(uint cacheVersion) {
            if (cacheVersion != g_CrystalSourceCacheVersion) return;
            if (cacheVersion != g_PendingCrystalSourceCacheVersion) return;
            g_CrystalSourceRefreshInProgress = false;
        }

        void RefreshCrystalSourceCacheAsync(uint64 requestCacheVersion) {
            uint cacheVersion = uint(requestCacheVersion);
            auto ctx = TriggerVisualizer::Trigger::Data::GetRuntimeContext();
            if (ctx is null || ctx.RootMap is null) {
                FinishCrystalSourceRefresh(cacheVersion);
                return;
            }

            string contextKey = GetMapSnapshotContextKey(ctx);
            uint blockCount = GetCrystalMapBlockCount(ctx.RootMap);
            uint bakedBlockCount = GetCrystalMapBakedBlockCount(ctx.RootMap);
            uint anchoredObjectCount = GetCrystalMapAnchoredObjectCount(ctx.RootMap);
            if (!CrystalSourceRefreshRequestMatches(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion)) {
                FinishCrystalSourceRefresh(cacheVersion);
                return;
            }

            auto source = TriggerVisualizer::Trigger::Data::Sources::CreateCrystalTriggerSourceShell(ctx, true);
            ResetCrystalSourceProgressPublishState();
            uint frameStart = Time::Now;
            if (!TriggerVisualizer::Trigger::Data::Sources::ProbeCrystalAnchoredObjectsWithProgress(source, ctx.RootMap, ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, g_PendingCrystalCustomItemsAndBlockItemsOnly)) {
                FinishCrystalSourceRefresh(cacheVersion);
                return;
            }
            frameStart = TriggerVisualizer::Trigger::Data::Sources::CrystalSourceBuildCheckpoint(frameStart);
            if (!PublishCrystalSourceBuildProgressIfDue(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, source, true)) {
                FinishCrystalSourceRefresh(cacheVersion);
                return;
            }
            if (g_PendingCrystalCustomItemsAndBlockItemsOnly) {
                TriggerVisualizer::Trigger::Data::Sources::AddCrystalDiagnostic(
                    source,
                    "Crystal custom block/item mode is enabled; Nadeo block and expandable rectangle probing is skipped."
                );
                if (!TriggerVisualizer::Trigger::Data::Sources::ProbeCrystalBlocksWithProgress(source, ctx.RootMap, ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, true)) {
                    FinishCrystalSourceRefresh(cacheVersion);
                    return;
                }
                frameStart = TriggerVisualizer::Trigger::Data::Sources::CrystalSourceBuildCheckpoint(frameStart);
                if (!PublishCrystalSourceBuildProgressIfDue(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, source, true)) {
                    FinishCrystalSourceRefresh(cacheVersion);
                    return;
                }
            } else {
                TriggerVisualizer::Trigger::Data::Sources::ProbeCrystalExpandableBlockUnitTriggers(
                    source,
                    ctx.RootMap,
                    g_PendingCrystalMergeAdjacentTriggerVolumes
                );
                frameStart = TriggerVisualizer::Trigger::Data::Sources::CrystalSourceBuildCheckpoint(frameStart);
                if (!PublishCrystalSourceBuildProgressIfDue(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, source, true)) {
                    FinishCrystalSourceRefresh(cacheVersion);
                    return;
                }
                if (!TriggerVisualizer::Trigger::Data::Sources::ProbeCrystalBlocksWithProgress(source, ctx.RootMap, ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion)) {
                    FinishCrystalSourceRefresh(cacheVersion);
                    return;
                }
                frameStart = TriggerVisualizer::Trigger::Data::Sources::CrystalSourceBuildCheckpoint(frameStart);
                if (!PublishCrystalSourceBuildProgressIfDue(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, source, true)) {
                    FinishCrystalSourceRefresh(cacheVersion);
                    return;
                }
            }
            TriggerVisualizer::Trigger::Data::Sources::MergeCrystalExpandableFinishWaypointVolumes(
                source,
                g_PendingCrystalMergeAdjacentTriggerVolumes
            );
            frameStart = TriggerVisualizer::Trigger::Data::Sources::CrystalSourceBuildCheckpoint(frameStart);
            if (!PublishCrystalSourceBuildProgressIfDue(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount, cacheVersion, source, true)) {
                FinishCrystalSourceRefresh(cacheVersion);
                return;
            }
            TriggerVisualizer::Trigger::Data::Sources::AddCrystalFinalCountsDiagnostic(source);
            StoreCrystalSourceCacheIfCurrent(
                ctx,
                contextKey,
                blockCount,
                bakedBlockCount,
                anchoredObjectCount,
                cacheVersion,
                source
            );
            FinishCrystalSourceRefresh(cacheVersion);
        }

        TriggerSourceSnapshot@ GetCrystalTriggerSource(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            bool enabled
        ) {
            if (ctx is null || ctx.RootMap is null) {
                return TriggerVisualizer::Trigger::Data::Sources::ReadCrystalTriggerSource(ctx, enabled);
            }

            string contextKey = GetMapSnapshotContextKey(ctx);
            uint blockCount = GetCrystalMapBlockCount(ctx.RootMap);
            uint bakedBlockCount = GetCrystalMapBakedBlockCount(ctx.RootMap);
            uint anchoredObjectCount = GetCrystalMapAnchoredObjectCount(ctx.RootMap);
            bool forceRefresh = UsesPeriodicCrystalRefresh(ctx, enabled)
                && IsCrystalRefreshDue(ctx, g_CachedCrystalSourceRefreshTime);
            auto mergeModeSource = RebuildCachedCrystalSourceForCurrentMergeState(
                ctx,
                contextKey,
                blockCount,
                bakedBlockCount,
                anchoredObjectCount
            );
            if (mergeModeSource !is null) {
                mergeModeSource.Enabled = enabled;
                return mergeModeSource;
            }

            if (forceRefresh) {
                QueueCrystalSourceRefresh(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount);
                if (CachedCrystalSourceMatchesCurrentMergeState(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount)) {
                    g_CachedCrystalSource.Enabled = enabled;
                    return g_CachedCrystalSource;
                }
                return CreateCrystalRefreshingSource(ctx, enabled);
            }

            if (CachedCrystalSourceMatchesCurrentMergeState(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount)) {
                g_CachedCrystalSource.Enabled = enabled;
                return g_CachedCrystalSource;
            }

            QueueCrystalSourceRefresh(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount);
            if (CachedCrystalSourceMatchesCurrentMergeState(ctx, contextKey, blockCount, bakedBlockCount, anchoredObjectCount)) {
                g_CachedCrystalSource.Enabled = enabled;
                return g_CachedCrystalSource;
            }
            return CreateCrystalRefreshingSource(ctx, enabled);
        }

        TriggerSourceSnapshot@ GetMediaTrackerTriggerSource(const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx) {
            bool enabled = TriggerVisualizer::Trigger::UI::IsMediaTrackerSourceEnabledForRuntime(ctx);
            string contextKey = GetMapSnapshotContextKey(ctx);

            if (!enabled) {
                if (g_CachedMediaTrackerSource !is null && ctx !is null && ctx.RootMap is g_CachedMediaTrackerRootMap && g_CachedMediaTrackerContextKey == contextKey) {
                    g_CachedMediaTrackerSource.Enabled = false;
                    return g_CachedMediaTrackerSource;
                }

                return TriggerVisualizer::Trigger::Data::Sources::ReadMediaTrackerTriggerSource(
                    ctx is null ? null : ctx.RootMap,
                    null,
                    "",
                    false,
                    MEDIATRACKER_RENDER_CELLS
                );
            }

            string groupName = "";
            CGameCtnMediaClipGroup@ clipGroup = null;
            uint64 groupBufferPtr = 0;
            @clipGroup = GetRuntimeMediaTrackerClipGroup(ctx, groupName);
            groupBufferPtr = TriggerVisualizer::Trigger::Data::Sources::ReadMediaTrackerClipGroupTriggerBufferPtr(clipGroup);
            bool forceRefresh = UsesPeriodicMediaTrackerRefresh(ctx, enabled)
                && IsMediaTrackerRefreshDue(ctx, g_CachedMediaTrackerSourceRefreshTime);

            if (!forceRefresh && g_CachedMediaTrackerSource !is null && ctx !is null && ctx.RootMap is g_CachedMediaTrackerRootMap && g_CachedMediaTrackerContextKey == contextKey && g_CachedMediaTrackerCellRendering == MEDIATRACKER_RENDER_CELLS && g_CachedMediaTrackerGroupName == groupName && g_CachedMediaTrackerGroupBufferPtr == groupBufferPtr) {
                g_CachedMediaTrackerSource.Enabled = true;
                return g_CachedMediaTrackerSource;
            }

            auto source = TriggerVisualizer::Trigger::Data::Sources::ReadMediaTrackerTriggerSource(
                ctx.RootMap,
                clipGroup,
                groupName,
                enabled,
                MEDIATRACKER_RENDER_CELLS
            );
            @g_CachedMediaTrackerSource = source;
            @g_CachedMediaTrackerRootMap = ctx.RootMap;
            g_CachedMediaTrackerContextKey = contextKey;
            g_CachedMediaTrackerCellRendering = MEDIATRACKER_RENDER_CELLS;
            g_CachedMediaTrackerGroupName = groupName;
            g_CachedMediaTrackerGroupBufferPtr = groupBufferPtr;
            g_CachedMediaTrackerSourceRefreshTime = Time::Now;

            return source;
        }

        CGameCtnMediaClipGroup@ GetRuntimeMediaTrackerClipGroup(
            const TriggerVisualizer::Trigger::Data::RuntimeContext@ ctx,
            string &out groupName
        ) {
            groupName = "InGame";
            if (ctx is null || ctx.RootMap is null) return null;

            if (ctx.HasMediaTrackerEditor && ctx.App !is null) {
                auto mediaTrackerEditor = cast<CGameEditorMediaTracker>(ctx.App.Editor);
                if (mediaTrackerEditor !is null) {
                    auto pluginApi = cast<CGameEditorMediaTrackerPluginAPI>(mediaTrackerEditor.PluginAPI);
                    if (pluginApi !is null && pluginApi.ClipGroup !is null) {
                        groupName = ctx.IsEditorMediaTracker ? "EditorActive" : "ReplayEditorActive";
                        return pluginApi.ClipGroup;
                    }
                }
            }

            return ctx.RootMap.ClipGroupInGame;
        }
    }
}
