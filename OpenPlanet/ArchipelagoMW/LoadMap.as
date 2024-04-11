namespace LoadMap
{
    string GetAPFolder()
    {
        return MAP_DOWNLOADED;
    }

    void CreateDownloadedFolder()
    {
        if (!IO::FolderExists(MAP_DOWNLOADED)) IO::CreateFolder(MAP_DOWNLOADED);
        if (!IO::FolderExists( GetAPFolder())) IO::CreateFolder(GetAPFolder());
    }

    bool DownloadMapById(const int &in mapId)
    {
        string filename = "AP-" + mapId + ".Map.Gbx";

        if(FileExistOnDrive(filename,  GetAPFolder() + "/"))
        {
            Log::Trace("Skip downloaded, file exists");
            return true;
        }

        Net::HttpRequest req;
        req.Method = Net::HttpMethod::Get;
        Log::Trace("Download: " + RMC_MX_Url+"/maps/download/"+ mapId);
        req.Url = RMC_MX_Url+"/maps/download/"+ mapId;

        Log::Trace("req.Start()");
        req.Start();

        while (!req.Finished())
        {
            yield();
        } 
        Log::Trace("req.Finished()");
        if (req.ResponseCode() == 200) {
            auto data = req.String();
            Log::Trace("Code 200");
            StoreDatafile(data, filename, GetAPFolder() + "/");
            return true;
        } else {
            Log::Trace("Erreur");
            return false;
        }
    }

    bool FileExistOnDrive(const string &in fileName, const string &in filePath)
    {
        string fullFilePathName = IO::FromUserGameFolder("Maps/Downloaded") + "/" + fileName;
        return IO::FileExists(fullFilePathName);
    }

    void StoreDatafile(const string &in data, const string &in fileName, const string &in filePath) {
        string directory = filePath;
        //if (!IO::FolderExists(directory)) {
        //    IO::CreateFolder(directory);
        //}

        string fullFilePathName = IO::FromUserGameFolder("Maps/Downloaded") + "/" + fileName;
        Log::Trace("Full Filename: " + fullFilePathName);

        IO::File file;
        file.Open(fullFilePathName, IO::FileMode::Write);
        file.Write(data);
        file.Close();

        Log::Trace("Data written to file: " + fullFilePathName);
    }

    void LaunchMap(const int &in mapId)
    {
        //string filename = GetAPFolder() + "/" + "AP-" + mapId + ".Map.Gbx";
        string filename = IO::FromUserGameFolder("Maps/Downloaded") + "/" + "AP-" + mapId + ".Map.Gbx";
        
        Log::Trace("Launch " + filename);
        CTrackMania@ app = cast<CTrackMania>(GetApp());

        while(!app.ManiaTitleControlScriptAPI.IsReady) {
            yield(); // Wait until the ManiaTitleControlScriptAPI is ready for loading the next map
        }
        app.ManiaTitleControlScriptAPI.PlayMap( filename, "", "");
        Log::Trace("Launched");
    }

    void LoadBasic(const int &in mapId)
    {
        CreateDownloadedFolder();
        if(DownloadMapById(mapId))
        {
            LaunchMap(mapId);
            CGameCtnChallengeInfo@ currentMapInfo = GetLoadedMap(mapId);
            mapObjective = currentMapInfo.TMObjective_GoldTime;
        }
    }

    CGameCtnChallengeInfo@ GetLoadedMap(const int &in mapId)
    {
        while (!IsMapLoaded())
        {
            sleep(100);
        }
        CGameCtnChallenge@ currentMapChallenge = cast<CGameCtnChallenge>(GetApp().RootMap);
        if (currentMapChallenge !is null) 
        {
            CGameCtnChallengeInfo@ currentMapInfo = currentMapChallenge.MapInfo;
            if (currentMapInfo !is null) 
            {
                Log::Trace("MapUid: " + currentMapInfo.MapUid);
                Log::Trace("AuthorNickName: " + currentMapInfo.AuthorNickName);
                Log::Trace("AT: " + currentMapInfo.TMObjective_AuthorTime);

                //Log::Trace("TMObjective_GoldTime: " + currentMapInfo.TMObjective_GoldTime);
                //float realGold =( currentMapInfo.TMObjective_AuthorTime * 1.06);
                //Log::Trace("Real Gold:" + realGold);
                //uint remains =Text::ParseInt("" + (Math::Round(realGold) % 1000));
                //Log::Trace("Remains:" + remains);
                //realGold += (1000-remains);
                //Log::Trace("Real Gold:" + realGold);

                for(uint i=0; i<GL::Locations.Length;i++)
                {
                    if(GL::Locations[i].MapId == mapId)
                    {
                        GL::Locations[i].AT_Time = currentMapInfo.TMObjective_AuthorTime;
                        GL::Locations[i].SetGoldTime();
                        GL::Locations[i].MapUID = currentMapInfo.MapUid;
                    }
                }
            }
            return currentMapInfo;
        }
        return null;
    }
        
    bool IsMapLoaded()
    {
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        if (app.RootMap is null) return false;
        else return true;
    }
}