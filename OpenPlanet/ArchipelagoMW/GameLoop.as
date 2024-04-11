namespace GL
{
    bool IsReady = false;
    int MaxNumberOfChecked = 100;
    int TotalCurrentChecked = 0;
    array<Location@> Locations;

    void SetCheck(int mapid, bool dontSend=false)
    {
        for(uint i=0; i<GL::Locations.Length;i++)
        {
            if(Locations[i].MapId == mapid)
            {
                if(Locations[i].Checked==true)
                    return;
                Locations[i].Checked=true;
                if(!dontSend)
                {
                    HS::SendChecked(i+1); // mapid);
                    HS::Retrieve();
                }
            }
        }
    }

    void UpdateStats()
    {
        int chk = 0;
        for(uint i=0; i<GL::Locations.Length;i++)
        {
            if(Locations[i].Checked)
            {
                chk++;
            }
        }
        TotalCurrentChecked=chk;
    }

    bool MapAlreadyIn(int rnd)
    {
        for(uint i=0; i<GL::Locations.Length;i++)
        {
            if(Locations[i].MapId == rnd)
            {
                return true;
            }
        }
        return false;
    }

    uint GetGoal(int mapid)
    {
        for(uint i=0; i<GL::Locations.Length;i++)
        {
            if(Locations[i].MapId == mapid)
            {
                return Locations[i].Gold_Time;
            }
        }
        return uint(-1);
    }

    void Prepare()
    {
        NewRandom();
        //Location premier;
        //premier.LocationId = "AA";
        //premier.MapId = 62376;
        //Locations.InsertLast(premier);
        //IsReady=true;
        //UpdateStats();
    }

    void NewRandom()
    {
        int nextRnd=0;
        while(nextRnd==0)
        {
            nextRnd = Math::Rand(62364, 62378);
            if(MapAlreadyIn(nextRnd)) nextRnd = 0;
        }
        Log::Trace("New random");
        Location premier;
        premier.LocationId = "AB";
        premier.MapId = nextRnd;        


        Locations.InsertLast(premier);
        UpdateStats();
    }

    int Complete()
    {
        return TotalCurrentChecked;
    }

    int TotalCheck()
    {
        return MaxNumberOfChecked;
    }
}

/*
        auto app = cast<CTrackMania>(GetApp());
        auto map = app.RootMap;
        CGamePlayground@ GamePlayground = cast<CGamePlayground>(app.CurrentPlayground);
        int medal = -1;
        if (map !is null && GamePlayground !is null){
            premier.AT_Time = map.TMObjective_AuthorTime;
            premier.SetGoldTime();
        }
        */