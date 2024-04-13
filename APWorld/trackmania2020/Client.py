import asyncio
import websockets

import colorama
import sys
import time
from typing import Any, ClassVar, Coroutine, Dict, List, Optional, Protocol, Tuple, cast
import typing
from queue import Queue

import Utils
from CommonClient import CommonContext, server_loop, gui_enabled, \
    ClientCommandProcessor, logger, get_base_parser
from MultiServer import mark_raw
from NetUtils import ClientStatus, NetworkItem, JSONtoTextParser, JSONMessagePart, encode, Endpoint
from Utils import async_start, get_file_safe_name

from .Items import item_table
BASE_ID = 183300000

from worlds import AutoWorldRegister
# "CidolfusTM:None@ws://localhost:59967"
myadresse = "ws://CidolfusTM:@localhost:59967"
# 59967



class Trackmania2020Context(CommonContext):
    game = "Trackmania 2020"
    server_task = None
    webserver_task = None
    webServer = None
    serverTemp = None
    items_handling = 0b111  # full remote
    known_name: Optional[str]

    def __init__(self, server_address: str, password: str) -> None:
        super(Trackmania2020Context, self).__init__(server_address, password)
        print("__init__ reached")
        self.known_name = None
        self.tm2020connected = False
        self.tm2020seedname = None
        self.tm2020slotname = None
        self.tm2020 = None
        self.from_game = asyncio.Queue()
        self.to_game = asyncio.Queue()
        self.got_room_info = asyncio.Event()
        self.got_slot_data = asyncio.Event()
        self.ui_toggle_map = lambda: None
        self.ui_set_rooms = lambda rooms: None
        self.serverconnected = False
        self.item_name_to_data = item_table
        self.tm2020_item_name_to_id = item_table
        self.lookup_id_to_item = item_table

    def Received(self, getcall: str):
        print("Received: " + getcall)
        result = ""
        completecall = getcall.partition("?")
        if completecall[0] == "/APConnect":
            result = self.APConnect(completecall)
        if completecall[0] == "/Retrieve":
            result = self.Retrieve(completecall)
        if completecall[0] == "/Checked":
            result = self.Checked(completecall)
        return result
        # "/APConnect"
        #return self.tm2020slotdata  # work
        # "/Retrieve"
        #return self.items_received  # too many value, but work [ [ 164084, -2, 0, 0 ], ...] (164084 is item)
        #return list(self.locations_checked)  # work but it's a list, may change to string
        #  works
        # /Checked?location=0
        #loop = asyncio.new_event_loop()
        #task = self.checkLocation(2)
        #loop.run_until_complete(task)
        # works
        # /Say?urlEncodedString=s => later
        #task = self.SendSay(getcall)
        #loop.run_until_complete(task)
        #return result
        #tasks.append(asyncio.create_task(self.send_msgs({"cmd": "Say", "Text": toret})))
        #return toret

    def APConnect(self, partis):
        return self.tm2020slotdata

    def Retrieve(self, partis):
        items = [i[0] for i in self.items_received]  # convert [ [ 164084, -2, 0, 0 ], [,,,]] => [164084,...]
        key_list = list(self.item_name_to_data.keys())
        val_list = list(self.item_name_to_data.values())
        mapids = []
        for i in items:
            mapids.append(int(key_list[val_list.index(i)]))
        #self.item_name_to_data
        location = list(self.locations_checked)  # work but it's a list, may change to string
        retrievestr = {"Items": mapids, "Checked": [x-BASE_ID for x in location]}
        return retrievestr

    def Checked(self, partis):
        loop = asyncio.new_event_loop()
        task = self.checkLocation(int(partis[2].partition("=")[2]) + BASE_ID)
        loop.run_until_complete(task)
        return ""

    async def checkLocation(self, location):
        print("checkLocation")
        try:
            await self.send_msgs([{"cmd": "LocationChecks", "locations": {int(location)}}])
        except Exception as e:
            print("Error checking: " + str(location))


    async def SendSay(self, tosay):
        print("SendSay is called")
        await self.send_msgs([{"cmd": "Say", "text": tosay}])


    async def server_auth(self, password_requested: bool = False):
        print("server_auth")
        if password_requested and not self.password:
            await super(Trackmania2020Context, self).server_auth(password_requested)
        await self.get_username()
        await self.send_connect()

    async def connection_closed(self):
        self.tm2020connected = False
        self.serverconnected = False
        await super(Trackmania2020Context, self).connection_closed()

    async def disconnect(self, allow_autoreconnect: bool = False):
        self.tm2020connected = False
        self.serverconnected = False
        await super(Trackmania2020Context, self).disconnect()

    @property
    def endpoints(self):
        if self.server:
            return [self.server]
        else:
            return []


    async def shutdown(self):
        await super(Trackmania2020Context, self).shutdown()
        self.webServer.server_close()


    def on_user_say(self, text: str) -> typing.Optional[str]:
        """Gets called before sending a Say to the server from the user.
        Returned text is sent, or sending is aborted if None is returned."""
        print("User Say: " + text)
        return text

    def on_package(self, cmd: str, args: Dict[str, Any]) -> None:
        print("On package reached")
        # self.room_item_numbers_to_ui()
        #if cmd == "Connected":
        #    logger.info("logged in to Archipelago server")
        #self.got_slot_data.set()
        if cmd in {"RoomInfo"}:
            print("Room info received")
            self.tm2020seedname = args['seed_name']
        if cmd in {"Connected"}:
            print("Connected received")
            asyncio.create_task(self.send_msgs([{"cmd": "GetDataPackage", "games": ["Trackmania 2020"]}]))
            self.tm2020slotdata = args['slot_data']
            self.locations_checked = set(args["checked_locations"])
        if cmd in {"ReceivedItems"}:
            start_index = args["index"]
            #if start_index > self.kh2_seed_save_cache["itemIndex"] and self.serverconnected:
            for item in args['items']:
                asyncio.create_task(self.give_item(item.item, item.location))
        if cmd in {"RoomUpdate"}:
            if "checked_locations" in args:
                new_locations = set(args["checked_locations"])
                self.locations_checked |= new_locations
        if cmd in {"DataPackage"}:
            self.tm2020_loc_name_to_id = args["data"]["games"]["Trackmania 2020"]["location_name_to_id"]
            self.lookup_id_to_location = {v: k for k, v in self.tm2020_loc_name_to_id.items()}
            self.tm2020_item_name_to_id = args["data"]["games"]["Trackmania 2020"]["item_name_to_id"]
            self.lookup_id_to_item = {v: k for k, v in self.tm2020_item_name_to_id.items()}
            #self.ability_code_list = [self.tm2020_item_name_to_id[item] for item in exclusion_item_table["Ability"]]

            asyncio.create_task(self.send_msgs([{'cmd': 'Sync'}]))

    async def give_item(self, item, location):
        #logger.info("give_item called " + str(item) + ", " + str(location))
        try:
            # todo: ripout all the itemtype stuff and just have one dictionary. the only thing that needs to be tracked from the server/local is abilites
            itemname = str(item)  # self.lookup_id_to_item[item]
            itemdata = item  # self.item_name_to_data[itemname]
        except Exception as e:
            if self.tm2020connected:
                self.tm2020connected = False
            logger.info(e)
            logger.info("Catch in give_item")


    def run_gui(self):
        print("run gui")
        from kvui import GameManager

        class TM2020Manager(GameManager):
            logging_pairs = [
                ("Client", "Archipelago")
            ]
            base_title = "Archipelago Trackmania 2020 Client"
        self.ui = TM2020Manager(self) # crash here
        self.ui_task = asyncio.create_task(self.ui.async_run(), name="UI")

    async def IsInShop(self, sellable):
        print("Is in shop")

    async def verifyItems(self):
        print("Verify items")

def finishedGame(ctx: Trackmania2020Context, message):
    print("finished: " + message)
    return False  # not winning for now

async def tm2020_watcher(ctx: Trackmania2020Context):
    while not ctx.exit_event.is_set():
        try:
            if ctx.tm2020connected and ctx.serverconnected:
                ctx.sending = []
                await asyncio.create_task(ctx.checkWorldLocations())
                await asyncio.create_task(ctx.checkLevels())
                await asyncio.create_task(ctx.checkSlots())
                await asyncio.create_task(ctx.verifyChests())
                await asyncio.create_task(ctx.verifyItems())
                await asyncio.create_task(ctx.verifyLevel())
                message = [{"cmd": 'LocationChecks', "locations": ctx.sending}]
                if finishedGame(ctx, message) and not ctx.tm2020_finished_game:
                    await ctx.send_msgs([{"cmd": "StatusUpdate", "status": ClientStatus.CLIENT_GOAL}])
                    ctx.tm2020_finished_game = True
                await ctx.send_msgs(message)
            elif not ctx.tm2020connected and ctx.serverconnected:
                logger.info("Game Connection lost. waiting 15 seconds until trying to reconnect.")
                ctx.tm2020 = None
                while not ctx.tm2020connected and ctx.serverconnected:
                    await asyncio.sleep(15)
                    #ctx.tm2020 = pymem.Pymem(process_name="KINGDOM HEARTS II FINAL MIX")
                    #if ctx.tm2020 is not None:
                    #    logger.info("You are now auto-tracking")
                    ctx.tm2020connected = True
        except Exception as e:
            if ctx.tm2020connected:
                ctx.tm2020connected = False
            logger.info(e)
            logger.info("tmwatcher exception")
        await asyncio.sleep(0.5)


def WebServerMain(ctx):
    MyServer.Context = ctx
    webserver = HTTPServer((hostName, serverPort), MyServer)
    ctx.webServer = webserver
    try:
        ctx.webServer.serve_forever()
    except KeyboardInterrupt:
        pass

    ctx.webServer.server_close()
    print("Server stopped.")


import threading


def launch() -> None:
    async def main(args):
        print("start main")
        ctx = Trackmania2020Context(args.connect, args.password)
        ctx.server_task = asyncio.create_task(server_loop(ctx, myadresse), name="ServerLoop")
        if gui_enabled:
            ctx.run_gui()
        ctx.run_cli()
        progression_watcher = asyncio.create_task(
            tm2020_watcher(ctx), name="TM2020ProgressionWatcher")

        hello_thread = threading.Thread(target=WebServerMain, args=(ctx,))
        hello_thread.start()

        await ctx.exit_event.wait()
        ctx.server_address = None

        await progression_watcher

        await ctx.shutdown()

    import colorama

    parser = get_base_parser(description="Trackmania 2020 Client, for text interfacing.")

    args, rest = parser.parse_known_args()
    colorama.init()
    asyncio.get_event_loop().run_until_complete(main(args))
    colorama.deinit()


def check_stdin() -> None:
    if Utils.is_windows and sys.stdin:
        print("WARNING: Console input is not routed reliably on Windows, use the GUI instead.")

from http.server import BaseHTTPRequestHandler, HTTPServer
import json

hostName = "localhost"
serverPort = 8080

class MyServer(BaseHTTPRequestHandler):
    GetCall:str = ""
    GetEvent = asyncio.Event
    Context = None
    def do_GET(self):
        # ctx = Trackmania2020Context("http://localhost:59967", None)  # Trackmania2020Context("http://localhost:59967", "")
        # cmd = Trackmania2020CommandProcessor()

        # selon self.path, lance la bonne procédure
        # /Message?urlEncodedString=Test => Post & return messages
        # /APConnect => SlotData
        # /Retrieve => Message & items since last called
        # /Retrieve/AllItems => Every message
        # /Checked?locationId=1 => Commit a checked
        # cmd.Message(self.path)
        toReturn = self.Context.Received(self.path)
        val = json.dumps(toReturn, indent=0)
        # val = "\"" + val + "\""
        # retourner la réponse dans le body, en json
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(bytes(val, "utf-8"))
        # self.wfile.write(bytes("<html><head><title>https://pythonbasics.org</title></head>", "utf-8"))
        # self.wfile.write(bytes("<p>Request: %s</p>" % self.path, "utf-8"))
        # self.wfile.write(bytes("<body>", "utf-8"))
        # self.wfile.write(bytes("<p>" + val + "</p>", "utf-8"))
        # self.wfile.write(bytes("</body></html>", "utf-8"))


