class Location
{
    string LocationId;//used for sorting, AA, AB, .., ZZ (Pack start at B*)
    int MapId;
    string MapUID;// Unique Id, from ChallengeInfo
    uint AT_Time=0;//get AT time from file
    uint Gold_Time=0;//calculated from AT_Time
    bool Checked;
    uint PlayerTime;

    void SetGoldTime()
    {
        uint Goal = Text::ParseInt("" + Math::Round(AT_Time * ObjectiveMedal));
        if(UseCeilForGoal == "1")
        {
            //uint realGold = Text::ParseInt("" + Math::Round(AT_Time * ObjectiveMedal));
            uint remains = Goal % 1000;
            Gold_Time = Goal + (1000-remains);
        }
        else
        {
            Gold_Time = Goal;
        }
    }

    bool GoalReached(int mapId)
    {
        bool GR=false;
        uint GoalTime = GL::GetGoal(mapId);

        if(PlayerTime<=GoalTime)
        {
            Checked=true;
            GR=true;
        }
        return GR;
    }
}