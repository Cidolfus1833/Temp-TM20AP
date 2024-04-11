UI::Texture@ AP_img = UI::LoadTexture("Assets/Images/AP.png");
UI::Texture@ GOLD_img = UI::LoadTexture("Assets/Images/Gold.png");

void Render_ty()
{
UI::Begin("AP", 0);
UI::Image(AP_img, vec2(64,64));
UI::End();
}

void TimerYield()
{
    yield();
        auto app = cast<CTrackMania>(GetApp());
        auto map = app.RootMap;
        CGamePlayground@ GamePlayground = cast<CGamePlayground>(app.CurrentPlayground);
        int medal = -1;
        if (map !is null && GamePlayground !is null){
            //int authorTime = map.TMObjective_AuthorTime;
            //int goldTime = map.TMObjective_GoldTime;
            int goldTime = GL::GetGoal(DM::SelectedMap);
            int time = -1;

            CSmArenaRulesMode@ PlaygroundScript = cast<CSmArenaRulesMode>(app.PlaygroundScript);
            if (PlaygroundScript !is null && GamePlayground.GameTerminals.Length > 0) {
                CSmPlayer@ player = cast<CSmPlayer>(GamePlayground.GameTerminals[0].ControlledPlayer);
                if (GamePlayground.GameTerminals[0].UISequence_Current == SGamePlaygroundUIConfig::EUISequence::Finish && player !is null) {
                    CSmScriptPlayer@ playerScriptAPI = cast<CSmScriptPlayer>(player.ScriptAPI);
                    auto ghost = PlaygroundScript.Ghost_RetrieveFromPlayer(playerScriptAPI);
                    if (ghost !is null) {
                        if (ghost.Result.Time > 0 && ghost.Result.Time < 4294967295) time = ghost.Result.Time;
                        PlaygroundScript.DataFileMgr.Ghost_Release(ghost.Id);
                    } else time = -1;
                } else time = -1;
            } else time = -1;
            if(time != -1)
                //Log::Trace("Current time: " + time);
                
                if(time<=goldTime && !DM::Gold)
                {
                    //Log::Trace("GOOOOOLD");
                    DM::Gold=true;
                    GL::SetCheck(DM::SelectedMap);
                    //GL::NewRandom();
                    SetCurrentTime(time);
                }
                else
                {
                    SetCurrentTime(time);
                }
        }

}

uint curTime = uint(-1);
void SetCurrentTime(uint newTime)
{
    if(curTime!=newTime)
    {
        curTime=newTime;
        for(uint i=0; i<GL::Locations.Length;i++)
        {
            if(GL::Locations[i].MapId == DM::SelectedMap)
            {
                if(GL::Locations[i].PlayerTime > newTime || GL::Locations[i].PlayerTime == 0)
                    GL::Locations[i].PlayerTime = newTime;
            }
        }
    }
}

void Render()
{
    
    startnew(CoroutineFunc(TimerYield));

    //UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(10, 10));
    //UI::PushStyleVar(UI::StyleVar::WindowRounding, 10.0);
    //UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(10, 6));
    //UI::PushStyleVar(UI::StyleVar::WindowTitleAlign, vec2(.5, .5));
    //UI::SetNextWindowSize(600,400);

    //
    UI::Begin("AP", 0);
    UI::Image(AP_img, vec2(64,64));
    UI::SameLine();
    GL::UpdateStats();
    UI::Text("Checks " + GL::Complete() + " on " + GL::TotalCheck());
    UI::NewLine();

    if(DM::MenuState == DM::MenuHidden)
    {
        if(UI::Button("Show main cup"))
        {
            DM::MenuState = DM::MenuMainGame;
        }
        UI::End();
        return;
    }

    UI::Separator();
    //bool preSet = uiHideComplete;
    uiHideComplete = UI::Checkbox("Hide completed",uiHideComplete);


    //UI::Text("Objectif: " + mapObjective);
    //UI::Separator();

if (UI::BeginTable("Maps Id", 3)) 
{
    UI::TableSetupColumn("Name or Id", UI::TableColumnFlags::WidthStretch);
    UI::TableSetupColumn("Current", UI::TableColumnFlags::WidthFixed, 120);
    UI::TableSetupColumn("Target", UI::TableColumnFlags::WidthFixed, 120);
    UI::TableHeadersRow();

    int s = 62364;
    int e = 62378;
    //62364 - 62378
    //for(int i = s; i <= e; i++)
    for(uint i=0; i<GL::Locations.Length;i++)
    {
        Location loc = GL::Locations[i];
        if(uiHideComplete)
        {
            if(loc.Checked)
                continue;
        }
        UI::TableNextRow();
        UI::PushID("Map #"+loc.MapId);
        UI::TableSetColumnIndex(0);
        if (UI::Button("Map #"+loc.MapId)) 
        {
            //startnew(MX::FetchMapTags);
            Log::Trace("Clicked " + loc.MapId);
            DM::SelectedMap = loc.MapId;
            CTrackMania@ app = cast<CTrackMania>(GetApp());
            app.BackToMainMenu();
            startnew(DM::doit);
        }
        if(GL::Locations[i].Checked)
        {
            UI::SameLine();
            UI::Image(GOLD_img, vec2(32,32));
        }
        UI::TableSetColumnIndex(1);
        UI::Text(Time::Format( GL::Locations[i].PlayerTime));
        UI::TableSetColumnIndex(2);
        UI::Text(Time::Format( GL::Locations[i].Gold_Time));

        UI::PopID();
    }
    
    UI::EndTable();
}

            float scale = UI::GetScale();
            //Log::Trace("scale: " + scale);
            
            //UI::SetCursorPos(vec2(UI::GetWindowSize().x*0.20, 35*scale));
            //UI::Text("\\$fc0"+Icons::ExclamationTriangle+" \\$z"+ PLUGIN_NAME + " is not responding. It might be down.");
            //UI::SetCursorPos(vec2(UI::GetWindowSize().x*0.45, 70*scale));

            if (UI::Button("Back")) {
                Log::Trace("Back clicked");
                DM::MenuState = DM::MenuHidden;
            }
            if(UI::Button("Connect!"))
            {
                Log::Trace("Connect clicked");
                startnew(HS::Handshake);
                startnew(HS::Retrieve);
            }
            /*
            if(UI::Button("Prepare"))
            {
                //Log::Trace("Prepare clicked");
                //startnew(GL::Prepare);
                //DM::SelectedMap = 62378;
                //CTrackMania@ app = cast<CTrackMania>(GetApp());
                //app.BackToMainMenu();
                //startnew(DM::doit);
            }
            */


        //UI::End();
        //UI::PopStyleVar(4);
UI::End();
}
