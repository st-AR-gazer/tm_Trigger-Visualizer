namespace TriggerVisualizer {
    namespace Trigger {
        namespace Data {
            namespace Sources {
                const uint MAX_CRYSTAL_DATA_REF_SURFACE_CACHE_ENTRIES = 512;
                array<string> g_CrystalDataRefSurfaceCacheFilenames;
                array<CPlugSurface@> g_CrystalDataRefSurfaceCacheSurfaces;
                array<string> g_CrystalDataRefSurfaceCacheWarnings;

                string CrystalNormalizeDataRefFilename(const string &in rawFilename) {
                    string filename = rawFilename.Trim();
                    filename = filename.Replace("\\", "/");
                    while (filename.StartsWith("/")) {
                        filename = filename.SubStr(1);
                    }
                    return filename;
                }

                string CrystalNormalizeGameDataRefPath(const string &in rawPath) {
                    string path = CrystalNormalizeDataRefFilename(rawPath);
                    int gameDataIndex = path.IndexOf("GameData/");
                    if (gameDataIndex >= 0) return path.SubStr(gameDataIndex);
                    return path;
                }

                string CrystalDataRefDirectory(const string &in rawPath) {
                    string path = CrystalNormalizeGameDataRefPath(rawPath);
                    int index = path.LastIndexOf("/");
                    if (index < 0) return "";
                    return path.SubStr(0, index);
                }

                string CrystalNodFidPrimaryPath(CMwNod@ nod) {
                    if (nod is null) return "";

                    CSystemFidFile@ fid = null;
                    try {
                        @fid = GetFidFromNod(nod);
                    } catch {
                        @fid = null;
                    }
                    if (fid is null) return "";

                    string fullName = "";
                    try {
                        fullName = string(fid.FullFileName);
                    } catch {
                        fullName = "";
                    }
                    if (fullName.Length > 0) return fullName;

                    try {
                        return string(fid.FileName);
                    } catch {
                        return "";
                    }
                }

                int FindCrystalDataRefSurfaceCacheIndex(const string &in filename) {
                    for (uint i = 0; i < g_CrystalDataRefSurfaceCacheFilenames.Length; i++) {
                        if (g_CrystalDataRefSurfaceCacheFilenames[i] == filename) return int(i);
                    }
                    return -1;
                }

                void AddCrystalDataRefSurfaceCacheEntry(
                    const string &in filename,
                    CPlugSurface@ surface,
                    const string &in warning
                ) {
                    if (g_CrystalDataRefSurfaceCacheFilenames.Length >= MAX_CRYSTAL_DATA_REF_SURFACE_CACHE_ENTRIES) {
                        g_CrystalDataRefSurfaceCacheFilenames.Resize(0);
                        g_CrystalDataRefSurfaceCacheSurfaces.Resize(0);
                        g_CrystalDataRefSurfaceCacheWarnings.Resize(0);
                    }
                    g_CrystalDataRefSurfaceCacheFilenames.InsertLast(filename);
                    g_CrystalDataRefSurfaceCacheSurfaces.InsertLast(surface);
                    g_CrystalDataRefSurfaceCacheWarnings.InsertLast(warning);
                }

                bool AddCrystalDataRefCandidatePath(array<string> @candidates, const string &in rawPath) {
                    if (candidates is null) return false;

                    string path = CrystalNormalizeDataRefFilename(rawPath);
                    if (path.Length == 0 || path.Length > 512) return false;
                    for (uint i = 0; i < candidates.Length; i++) {
                        if (candidates[i] == path) return false;
                    }
                    candidates.InsertLast(path);
                    return true;
                }

                void AddCrystalSiblingDataRefCandidatePaths(
                    array<string> @candidates,
                    CMwNod@ nod,
                    const string &in siblingFilename
                ) {
                    if (candidates is null || nod is null || siblingFilename.Length == 0) return;

                    string primaryPath = CrystalNodFidPrimaryPath(nod);
                    string directory = CrystalDataRefDirectory(primaryPath);
                    if (directory.Length == 0) return;

                    AddCrystalDataRefCandidatePath(candidates, directory + "/" + siblingFilename);
                    if (directory.StartsWith("GameData/")) {
                        AddCrystalDataRefCandidatePath(candidates, directory.SubStr(9) + "/" + siblingFilename);
                    } else {
                        AddCrystalDataRefCandidatePath(candidates, "GameData/" + directory + "/" + siblingFilename);
                    }
                }

                CSystemFidFile@ TryGetCrystalDataRefFid(const string &in path, string &out source) {
                    source = "";
                    CSystemFidFile@ fid = null;

                    try {
                        @fid = Fids::GetResource(path);
                    } catch {
                        @fid = null;
                    }
                    if (fid !is null) {
                        source = "Resources";
                        return fid;
                    }

                    try {
                        @fid = Fids::GetGame(path);
                    } catch {
                        @fid = null;
                    }
                    if (fid !is null) {
                        source = "Game";
                        return fid;
                    }

                    try {
                        @fid = Fids::GetUser(path);
                    } catch {
                        @fid = null;
                    }
                    if (fid !is null) {
                        source = "User";
                        return fid;
                    }

                    try {
                        @fid = Fids::GetProgramData(path);
                    } catch {
                        @fid = null;
                    }
                    if (fid !is null) {
                        source = "ProgramData";
                        return fid;
                    }

                    try {
                        @fid = Fids::GetFake(path);
                    } catch {
                        @fid = null;
                    }
                    if (fid !is null) {
                        source = "Fake";
                        return fid;
                    }

                    return null;
                }

                void AddCrystalExtractDataRefCandidatePaths(array<string> @candidates, const string &in rawPath) {
                    if (candidates is null) return;

                    string path = CrystalNormalizeGameDataRefPath(rawPath);
                    if (path.Length == 0) return;

                    string gameDataPath = path.StartsWith("GameData/") ? path : "GameData/" + path;
                    AddCrystalDataRefCandidatePath(candidates, IO::FromDataFolder("Extract/" + gameDataPath));
                }

                CPlugSurface@ TryPreloadCrystalDataRefSurface(
                    const string &in filename,
                    string &out detail,
                    string &out warning
                ) {
                    detail = "";
                    warning = "";
                    auto candidates = array<string>();
                    AddCrystalDataRefCandidatePath(candidates, filename);
                    if (filename.StartsWith("GameData/")) {
                        AddCrystalDataRefCandidatePath(candidates, filename.SubStr(9));
                    } else {
                        AddCrystalDataRefCandidatePath(candidates, "GameData/" + filename);
                    }
                    AddCrystalExtractDataRefCandidatePaths(candidates, filename);
                    auto attempted = array<string>();
                    for (uint i = 0; i < candidates.Length; i++) {
                        string fidSource = "";
                        CSystemFidFile@ fid = TryGetCrystalDataRefFid(candidates[i], fidSource);
                        attempted.InsertLast(candidates[i]);
                        if (fid is null) continue;

                        CMwNod@ nod = null;
                        try {
                            @nod = Fids::Preload(fid);
                        } catch {
                            @nod = null;
                        }
                        if (nod is null) {
                            warning = "DataRef fid found but preload returned no nod: " + fidSource + ":" + candidates[i];
                            continue;
                        }

                        auto surface = cast<CPlugSurface>(nod);
                        if (surface is null) {
                            warning = "DataRef preload returned " + GetCrystalNodTypeName(nod) + ", not CPlugSurface: " + fidSource + ":" + candidates[i];
                            continue;
                        }

                        detail = "DataRef " + fidSource + ":" + candidates[i];
                        return surface;
                    }
                    warning = "Could not resolve DataRef TriggerShape filename: " + filename;
                    if (attempted.Length > 0) {
                        warning += " candidates: " + Text::Join(attempted, ", ");
                    }
                    return null;
                }

                CPlugSurface@ ResolveCrystalSiblingDataRefSurface(
                    CMwNod@ nod,
                    const string &in siblingFilename,
                    string &out detail,
                    string &out warning
                ) {
                    detail = "";
                    warning = "";
                    if (nod is null || siblingFilename.Length == 0) return null;

                    auto candidates = array<string>();
                    AddCrystalSiblingDataRefCandidatePaths(candidates, nod, siblingFilename);
                    for (uint i = 0; i < candidates.Length; i++) {
                        string filename = "";
                        string candidateDetail = "";
                        string candidateWarning = "";
                        CPlugSurface@ surface = ResolveCrystalDataRefSurface(
                            candidates[i],
                            filename,
                            candidateDetail,
                            candidateWarning
                        );
                        if (surface !is null) {
                            detail = "sibling DataRef " + siblingFilename + " from " + CrystalNodFidPrimaryPath(nod);
                            if (candidateDetail.Length > 0) detail += " | " + candidateDetail;
                            return surface;
                        }
                        warning = candidateWarning;
                    }
                    warning = "Could not resolve sibling DataRef " + siblingFilename + " from " + CrystalNodFidPrimaryPath(nod);
                    return null;
                }

                CPlugSurface@ ResolveCrystalDataRefSurface(
                    const string &in rawFilename,
                    string &out filename,
                    string &out detail,
                    string &out warning
                ) {
                    filename = CrystalNormalizeDataRefFilename(rawFilename);
                    detail = "";
                    warning = "";
                    if (filename.Length == 0) {
                        warning = "DataRef TriggerShape has no filename.";
                        return null;
                    }
                    if (filename.Length > 512) {
                        warning = "DataRef TriggerShape filename is too long.";
                        return null;
                    }

                    int cachedIndex = FindCrystalDataRefSurfaceCacheIndex(filename);
                    if (cachedIndex >= 0) {
                        uint index = uint(cachedIndex);
                        detail = "cached DataRef " + filename;
                        warning = g_CrystalDataRefSurfaceCacheWarnings[index];
                        return g_CrystalDataRefSurfaceCacheSurfaces[index];
                    }

                    CPlugSurface@ surface = TryPreloadCrystalDataRefSurface(filename, detail, warning);
                    AddCrystalDataRefSurfaceCacheEntry(filename, surface, warning);
                    return surface;
                }

                CPlugSurface@ ResolveCrystalPhyModelTriggerShapeSurface(
                    CGameObjectPhyModel@ phyModel,
                    string &out filename,
                    string &out detail,
                    string &out warning
                ) {
                    filename = "";
                    detail = "";
                    warning = "";
                    if (phyModel is null) return null;

                    string rawFilename = "";
                    try {
                        rawFilename = string(phyModel.TriggerShape.Filename);
                    } catch {
                        warning = "Could not read CGameObjectPhyModel.TriggerShape.Filename.";
                        return null;
                    }

                    return ResolveCrystalDataRefSurface(rawFilename, filename, detail, warning);
                }
            }
        }
    }
}
