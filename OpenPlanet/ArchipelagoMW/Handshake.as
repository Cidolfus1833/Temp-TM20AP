namespace HS
{
    string ApUser="";
    string ApPass="";
    string ApServ="";
    uint ApPort;

    void SendMessage(const string &in message)
    {
        Net::HttpRequest req;
        req.Method = Net::HttpMethod::Get;
        string url = bridge + "/Message?urlEncodedString=" + Net::UrlEncode(message);
        Log::Trace("Download: " + url);
        req.Url = url;

        Log::Trace("req.Start()");
        req.Start();
        while (!req.Finished())
        {
            yield();
        } 
        if (req.ResponseCode() == 200) {
            auto data = req.String();
            Log::Trace("Data: "+ data);
        }
        else
        {
            Log::Trace("Response != 200 => " + req.ResponseCode() );
        }

    }

    void SendChecked(uint locationId)
    {
        Net::HttpRequest req;
        req.Method = Net::HttpMethod::Get;
        string url = bridge + "/Checked?locationId=" + locationId;
        Log::Trace("Download: " + url);
        req.Url = url;

        Log::Trace("req.Start()");
        req.Start();
        while (!req.Finished())
        {
            yield();
        } 
        if (req.ResponseCode() == 200) {
            auto data = req.String();
            Log::Trace("Data: "+ data);
        }
        else
        {
            Log::Trace("Response != 200 => " + req.ResponseCode() );
        }

    }

    void Handshake()
    {
        Net::HttpRequest req;
        req.Method = Net::HttpMethod::Get;
        string url = bridge + "/APConnect";
        Log::Trace("Download: " + url);
        req.Url = url;

        Log::Trace("req.Start()");
        req.Start();
        while (!req.Finished())
        {
            yield();
        } 
        if (req.ResponseCode() == 200) {
            auto data = req.String();
            Log::Trace("APC Data: "+ data);
            auto json = Json::Parse(data);
            ObjectiveMedal =  Text::ParseFloat(json["goalPerMaps"])/100;
            Log::Trace("ObjectiveMedal: " + ObjectiveMedal);
            UseCeilForGoal = json["ceilToSeconds"];
        }
        else
        {
            Log::Trace("Response != 200 => " + req.ResponseCode() );
        }
    }

    void Retrieve()
    {
        //while(true)
        {
            yield();
            sleep(500);// each .5s

            Net::HttpRequest req;
            req.Method = Net::HttpMethod::Get;
            string url = bridge + "/Retrieve";
            Log::Trace("Download: " + url);
            req.Url = url;

            Log::Trace("req.Start()");
            req.Start();
            while (!req.Finished())
            {
                yield();
            } 
            if (req.ResponseCode() == 200) 
            {
                auto data = req.String();
                Log::Trace("Data: "+ data);
                auto json = Json::Parse(data);
                Log::Trace("Data: " + json["Items"].Length);
                Log::Trace("Data: " + json["Checked"].Length);
                    auto res = json["Items"];
                    auto comp= json["Checked"];

                    for (uint i = 0; i < res.Length; i++) 
                    {
                        int mapLooped = Text::ParseInt(res[i]);
                        if(!GL::MapAlreadyIn(mapLooped))
                        {
                            Location loc;
                            loc.MapId = mapLooped;
                            GL::Locations.InsertLast(loc);
                            //GL::SetCheck(l1);
                        }
                    }

                    for (uint i = 0; i < comp.Length; i++) 
                    {
                        if(comp[i] != "")
                        {
                            uint mapLooped = Text::ParseInt(comp[i]);
                            if(mapLooped>=0 || mapLooped<=GL::Locations.Length)
                                GL::Locations[mapLooped-1].Checked = true;
                        }
                    }
            }
            else
            {
                Log::Trace("Response != 200 => " + req.ResponseCode() );
            }
        }
        GL::UpdateStats();
    }
}

/*
    void Handshake_verybad()
    {
        ApUser=apuser;
        ApPass=appass;
        ApServ=apserv;
        ApPort=42725;

        Net::SecureSocket socket;
        Log::Trace("a");
        bool con = socket.Connect("http://archipelago.gg",ApPort);
        //bool con = socket.Connect("http://localhost/test", 5108);
        Log::Trace("b");
        if(con)
        {
            //Log::Trace("Distant: " + socket.GetRemoteIP());
            Log::Trace("c");
            Log::Trace("Avail: " +socket.Available());
            Log::Trace("cc");

//Net::Socket receiver = socket.Accept();
//bool cr = receiver.CanRead();
//Log::Trace("Can read: " + cr);

// [{"cmd": "GetDataPackage"}]
socket.WriteRaw("[{\"cmd\": \"GetDataPackage\"}]");
Log::Trace("ccc");
            if(socket.CanRead()){
                Log::Trace("d");
                int avail = socket.Available();
                Log::Trace("e: " + avail);
                auto ret = socket.ReadRaw(avail);
                Log::Trace("f");
                Log::Trace(ret);
            }
        }
    }

*/