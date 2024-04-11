  uint mapObjective = uint(-1);

namespace DM
{
  int MenuState=1;
  const int MenuHidden = 0;
  const int MenuMainGame = 1;
  const int MenuMap = 2;
  const int CurrentMapPack=0;//0=default=MainCup
  bool Gold=false;

  int SelectedMap =0;
  void doit()
  {
    Gold=false;
    if(SelectedMap==0)
      return;
    DownloadMap(SelectedMap);
  }
}


// test: Mappack = 1582
// maps: 62364 - 62378

void DownloadMap(const int &in mapId)
{
  LoadMap::LoadBasic(mapId);
}

void Main()
{
  Log::Trace("Main func has started");
  NadeoServices::AddAudience("NadeoClubServices");
  while (!NadeoServices::IsAuthenticated("NadeoClubServices")) { yield(); }

  LogAPSetting();

  //DownloadMap(62365, "test");
  HS::SendMessage("Test");
}

void RenderMenu()
{
  if (UI::MenuItem("Connect to Archipelago")) {
    print("Open AP settings");
    startnew(DM::doit);
    //DownloadMap(62364, "test");
  }
}

[SettingsTab name="AP Connect"  category="AP Connect" icon=Icons::Adjust]

[Setting name="Name" description="Nom du monde" category="AP Connect"]
string apuser="";
[Setting name="Password" description="Mot de passe" category="AP Connect"]
string appass="";
[Setting name="URL" description="Serveur" category="AP Connect"]
string apserv="archipelago.gg";
[Setting name="Port" description="Port" category="AP Connect"]
string apport="";
[Setting name="Bridge port" category="AP Connect"]
string bridge="http://127.0.0.1:5108";

[Setting hidden]
float ObjectiveMedal = 1.06;// 1=AT, 1.06=Gold, 1.20=Silver 1.50=Bronze
[Setting hidden]
string UseCeilForGoal = "1";
[Setting hidden]
bool uiHideComplete;

/*
[Setting name="AP Connect" category="AP Connect"]
void RenderSettings()
{
  if (UI::Button("Verification")) {
    print("Configuration actuel");
    print(apuser);
    print(appass);
    print(apserv);
    print(apport);
  }
}*/

void LogAPSetting(){
    Log::Trace("Configuration actuel");
    Log::Trace(apuser);
    Log::Trace(appass);
    Log::Trace(apserv);
    Log::Trace(apport);
}

void LogYamlSetting(){
  Log::Trace("Configuration du Yaml.");
}

// https://trackmania.exchange/maps/download/62364
// c:\users\rlvla\Documents\Trackmania\Maps\Downloaded